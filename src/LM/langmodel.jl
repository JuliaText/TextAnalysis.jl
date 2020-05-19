abstract type Langmodel end

struct mle <: Langmodel
    vocab ::Vocabulary
    #counter::Dict{SubString{String},Array{Tuple{String,Float64},1}}
end

function mle(word,unk_cutoff=1 ,unk_label="<unk>")
    mle(Vocabulary(word,unk_cutoff ,unk_label))
end

function fit!(lm::Langmodel,text,min::Integer,max::Integer)
    text = lookup(lm.vocab ,text)
    text = convert(Array{String}, text)
    return counter1(text,min,max)
end

function unmaskscore(a::Dict{SubString{String},Array{Tuple{String,Float64},1}},word,context)
    for i in a[context]
        if word == i[1]
            return i[2]
        end
    end
end

function score(voc::Langmodel,model::Dict{SubString{String},Array{Tuple{String,Float64},1}} ,word ,context )
        """Masks out of vocab (OOV) words and computes their model score.
        For model-specific logic of calculating scores, see the `unmasked_score`
        method.
        """
    return unmaskscore(model,word,context )
end

function logscore(word, context= None)
        """Evaluate the log score of this word in this context.
        The arguments are the same as for `score` and `unmasked_score`.
        """
    return log2(score(word, context))
end
