abstract type Langmodel end

struct MLE <: Langmodel
    vocab ::Vocabulary
    #counter::Dict{SubString{String},Array{Tuple{String,Float64},1}}
end

function MLE(word,unk_cutoff=1 ,unk_label="<unk>")
   MLE(Vocabulary(word,unk_cutoff ,unk_label))
end

function (lm::MLE)(text,min::Integer,max::Integer) 
     text = lookup(lm.vocab ,text)
     text=convert(Array{String}, text)
     return counter1(text,min,max,normalize)
end

struct Lidstone <: Langmodel
    vocab ::Vocabulary
    gamma ::Integer
end

function Lidstone(word,gamma,unk_cutoff=1 ,unk_label="<unk>")
   Lidstone(Vocabulary(word,unk_cutoff ,unk_label),gamma)
end

function (lm::Lidstone)(text,min::Integer,max::Integer) 
     text = lookup(lm.vocab ,text)
     text=convert(Array{String}, text)
     return counter1(text,min,max,lid_norm,gamma = lm.gamma)
end


struct Laplace <: Langmodel
    vocab ::Vocabulary
    gamma ::Integer
end

function Laplace(word,unk_cutoff=1 ,unk_label="<unk>")
   Lidstone(Vocabulary(word,unk_cutoff ,unk_label),1)
end

function (lm::Laplace)(text,min::Integer,max::Integer) 
     text = lookup(lm.vocab ,text)
     text=convert(Array{String}, text)
     return counter1(text,min,max,lid_norm,gamma = lm.gamma)
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
