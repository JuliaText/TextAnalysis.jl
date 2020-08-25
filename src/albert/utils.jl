using WordTokenizers

"""
    preprocess_albert(training_batch::Array{Array{String,1},1}, spm ,task=nothing; pad_id::Int=1)
preprocess text for finetuning.

# Example:
julia> sentences = [["i love julia language"],["It is fast as C"]]
julia> using WordTokenizers #using tokenizer 
julia> spm = load(ALBERT_V1)
WordTokenizers.SentencePieceModel(Dict("▁shots" => (-11.2373, 
7281),"▁ordered" => (-9.84973, 1906),"▁doubtful" => (-12.7799, 
22569),"▁glancing" => (-11.6676, 10426),"▁disrespect" => (-13.13, 
26682),"▁without" => (-8.34227, 367),"▁pol" => (-10.7694, 4828),"chem" 
=> (-12.3713, 17661),"▁1947," => (-11.7544, 11199),"▁kw" => (-10.4402, 
3511)…), 2)
julia> TextAnalysis.ALBERT.preprocess_albert(sentences, spm)
((tok = [3; 32; … ; 2; 4], segment = [1; 1; … ; 2; 2]), Float32[1.0 1.0 
… 1.0 1.0])

"""
function preprocess_albert(training_batch,spm ,task=nothing; pad_id::Int=1)
    ids =[]
    sent = []
    for i in 1:length(training_batch[1])
        sent1 = spm(training_batch[1][i])
        sent2 = spm(training_batch[2][i])
        comb_sent = makesentence(sent1,sent2)
        push!(sent, comb_sent)
        push!(ids,ids_from_tokens(spm,comb_sent))
    end
    mask = getmask(convert(Array{Array{String,1},1}, sent)) 
    E = Flux.batchseq(ids,1)
    E = Flux.stack(E,1) #pad token always
    segment = fill!(similar(E), pad_id)
    for (i, sent) ∈ enumerate(sent)
        j = findfirst(isequal("[SEP]"), sent)
        if j !== nothing
            @view(segment[j+1:end, i]) .= 2
        end
    end
    data = (tok = E,segment = segment)
    if task != nothing
        labels = get_labels(task)
        label = Flux.onehotbatch(training_batch[3], labels)
        return(data,label,mask)
    end
    return(data,mask)
end
makesentence(s1, s2) = ["[CLS]"; s1; "[SEP]"; s2; "[SEP]"]
