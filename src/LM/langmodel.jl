abstract type Langmodel end
abstract type gammamodel <: Langmodel end #BaseNgram with smoothing algo
abstract type InterpolatedLanguageModel <: Langmodel end #Interpolated language model with smoothing

"""
    Type for providing MLE ngram model scores.
    Implementation of Base Ngram Model.

"""
struct MLE <: Langmodel
    vocab ::Vocabulary
end
"""
    MLE(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
Return Datatype MLE 

# Example

```julia-repl
julia> seq = ["To","be","or","not"]
julia> a = everygram(seq,min_len=1, max_len=-1)
 10-element Array{Any,1}:
  "or"          
  "not"         
  "To"          
  "be"                  
  "or not" 
  "be or"       
  "be or not"   
  "To be or"    
  "To be or not"
```
   
"""
function MLE(word, unk_cutoff=1, unk_label="<unk>")
    MLE(Vocabulary(word, unk_cutoff, unk_label))
end

function (lm::MLE)(text, min::Integer, max::Integer) 
    text = lookup(lm.vocab, text)
    text=convert(Array{String}, text)
    return counter2(text, min, max)
end

 """
    Type for providing Lidstone-smoothed scores.

    In addition to initialization arguments from BaseNgramModel also requires
    a number by which to increase the counts, gamma.
"""
struct Lidstone <: gammamodel
    vocab ::Vocabulary
    gamma ::Integer
end

function Lidstone(word, gamma,unk_cutoff=1, unk_label="<unk>")
    Lidstone(Vocabulary(word, unk_cutoff, unk_label), gamma)
end

function (lm::Lidstone)(text, min::Integer, max::Integer) 
    text = lookup(lm.vocab, text)
    text=convert(Array{String}, text)
    return counter2(text, min, max)
end
"""Type for providing Laplace-smoothed scores.

    In addition to initialization arguments from BaseNgramModel also requires
    a number by which to increase the counts, gamma = 1.
"""

struct Laplace <: gammamodel
    vocab ::Vocabulary
    gamma ::Integer
end

function Laplace(word, unk_cutoff=1, unk_label="<unk>")
    Lidstone(Vocabulary(word, unk_cutoff, unk_label), 1)
end

function (lm::Laplace)(text, min::Integer, max::Integer) 
    text = lookup(lm.vocab, text)
    text = convert(Array{String}, text)
    return counter2(text, min, max)
end

"""Add-one smoothing: Lidstone or Laplace.(gammamodel)
   To see what kind, look at `gamma` attribute on the class.
"""
function score(m::gammamodel, temp_lm, word,context)
    accum = temp_lm[context]
    #print(accum)
    s = float(sum(accum)+(m.gamma)*length(m.vocab.vocab)) 
    for (text, count) in accum
        if text == word
            return(float(count+m.gamma)/s)
        end
    end
    return(float(m.gamma)/s)
end

"""To get probability of word given that context
   In otherwords, for given context calculate frequency distribution of word
  
"""
function prob(templ_lm::DefaultDict, word,context=nothing)
    if context == nothing || context == ""
        return(1/float(length(templ_lm))) #provide distribution 
    else
        accum = templ_lm[context]
    end
    s = float(sum(accum)) 
    for (text,count) in accum
        if text == word
            return(float(count) / s)
        end
    end
    return(Inf)
end

function score(m::MLE,temp_lm,word,context = nothing)
    prob(temp_lm , word, context)
end
struct WittenBellInterpolated <: InterpolatedLanguageModel 
    vocab ::Vocabulary
end

function WittenBellInterpolated(word,unk_cutoff=1 ,unk_label="<unk>")
    WittenBellInterpolated(Vocabulary(word,unk_cutoff ,unk_label))
end

function (lm::WittenBellInterpolated)(text,min::Integer,max::Integer) 
    text = lookup(lm.vocab ,text)
    text=convert(Array{String}, text)
    return counter2(text,min,max)
end

function alpha_gammma(templ_lm::DefaultDict, word,context)
    local alpha
    local gam
    accum = templ_lm[context]
    s = float(sum(accum)) 
    for (text,count) in accum
        if text == word
            alpha=(float(count) / s)
            break 
        else
            alpha = 1/s
        end
    end
   
    gam = gamma(accum)
    return alpha*(1- gam),gam 
end

function count_non_zero_vals(accum::Accumulator{})
    return(length(accum))
end
    
function gamma(accum)
    nplus=count_non_zero_vals(accum)
    return(nplus/(nplus+float(sum(accum))))
end

function score(m::InterpolatedLanguageModel,temp_lm::DefaultDict,word,context=nothing)
    if context == nothing || context == ""
        return prob(temp_lm,word,context)
    end
    if context in keys(temp_lm)
        alpha,gamma = alpha_gammma(temp_lm,word,context)
        return (alpha + gamma*score(m,temp_lm,word,context_reduce(context)))
    else
        return score(m,temp_lm,word,context_reduce(context))
    end
end
        
function context_reduce(context)
    context = split(context)
    join(context[2:end]," ")
end
struct KneserNeyInterpolated <: InterpolatedLanguageModel 
    vocab::Vocabulary
    discount::Float64
end



function KneserNeyInterpolated(word,gamma,unk_cutoff=1 ,unk_label="<unk>")
    KneserNeyInterpolate(Vocabulary(word,unk_cutoff ,unk_label),gamma)
end

function (lm::KneserNeyInterpolated)(text,min::Integer,max::Integer) 
    text = lookup(lm.vocab ,text)
    text=convert(Array{String}, text)
    return counter2(text,min,max)
end
function alpha_gammma(m::KneserNeyInterpolated,templ_lm::DefaultDict, word,context)
    accum = templ_lm[context]
    s = float(sum(accum)) 
   for (text,count) in accum
       if text == word
           alpha=(max(float(count)-m.discount,0.0) / s)
           break 
       else
           alpha = 1/length(m.vocab.vocab)
       end
    end
    gamma = (m.discount * count_non_zero_vals(accum) /s)
end


