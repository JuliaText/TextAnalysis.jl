abstract type Langmodel end
abstract type gammamodel <: Langmodel end #BaseNgram with Add-one smoothing algo
abstract type InterpolatedLanguageModel <: Langmodel end #Interpolated language model with smoothing

#DataType MLE
#Type for providing MLE ngram model scores.
#Implementation of Base Ngram Model.

struct MLE <: Langmodel
    vocab::Vocabulary
end

"""
    MLE(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}

Initiate Type for providing MLE ngram model scores.

Implementation of Base Ngram Model.
   
"""
function MLE(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}
    MLE(Vocabulary(word, unk_cutoff, unk_label))
end

function (lm::MLE)(text::Vector{T}, min::Integer, max::Integer) where {T <: AbstractString}
    text = lookup(lm.vocab, text)
    text=convert(Array{String}, text)
    return counter2(text, min, max)
end

struct Lidstone <: gammamodel
    vocab::Vocabulary
    gamma::Float64
end

"""
    Lidstone(word::Vector{T}, gamma:: Float64, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}

Function to initiate Type(Lidstone) for providing Lidstone-smoothed scores.

In addition to initialization arguments from BaseNgramModel also requires 
a number by which to increase the counts, gamma.
"""
function Lidstone(word::Vector{T}, gamma = 1.0, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}
    Lidstone(Vocabulary(word, unk_cutoff, unk_label), gamma)
end

function (lm::Lidstone)(text::Vector{T}, min::Integer, max::Integer) where {T <: AbstractString}
    text = lookup(lm.vocab, text)
    text=convert(Array{String}, text)
    return counter2(text, min, max)
end

"""
    Laplace(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}
Function to initiate Type(Laplace) for providing Laplace-smoothed scores.

In addition to initialization arguments from BaseNgramModel also requires
a number by which to increase the counts, gamma = 1.
"""
struct Laplace <: gammamodel
    vocab::Vocabulary
    gamma::Float64
end

function Laplace(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}
    Laplace(Vocabulary(word, unk_cutoff, unk_label), 1.0)
end

function (lm::Laplace)(text, min::Integer, max::Integer) 
    text = lookup(lm.vocab, text)
    text = convert(Array{String}, text)
    return counter2(text, min, max)
end

"""
	score(m::gammamodel, temp_lm::DefaultDict, word::AbstractString, context::AbstractString)	

score is used to output probability of word given that context 

Add-one smoothing to Lidstone or Laplace(gammamodel) models
        
"""
function score(m::gammamodel, temp_lm::DefaultDict, word, context) #score for gammamodel output probabl
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

"""
To get probability of word given that context

In other words, for given context calculate frequency distribution of word
  
"""
function prob(m::Langmodel, templ_lm::DefaultDict, word, context=nothing)::Float64
    (isnothing(context) || isempty(context)) && return 1.0/length(templ_lm) #provide distribution

    accum = templ_lm[context]
    s = float(sum(accum)) 
    for (text, count) in accum
        if text == word
            return(float(count) / s)
        end
    end
    if context in keys(m.vocab.vocab)
        return 0.0
    end
    return(Inf)
end

"""
	score(m::MLE, temp_lm::DefaultDict, word::AbstractString, context::AbstractString)	

score is used to output probability of word given that context in MLE
        
"""
function score(m::MLE, temp_lm::DefaultDict, word, context=nothing)
    prob(m, temp_lm, word, context)
end

struct WittenBellInterpolated <: InterpolatedLanguageModel 
    vocab ::Vocabulary
end

"""
    WittenBellInterpolated(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}

Initiate Type for providing Interpolated version of Witten-Bell smoothing.

The idea to abstract this comes from Chen & Goodman 1995.

"""
function WittenBellInterpolated(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}
    WittenBellInterpolated(Vocabulary(word, unk_cutoff, unk_label))
end

function (lm::WittenBellInterpolated)(text::Vector{T}, min::Integer, max::Integer) where {T <: AbstractString}
    text = lookup(lm.vocab, text)
    text=convert(Array{String}, text)
    return counter2(text, min, max)
end
# alpha_gamma function for KneserNeyInterpolated
function alpha_gammma(m::WittenBellInterpolated, templ_lm::DefaultDict, word, context)
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
    return alpha*(1- gam), gam 
end

function count_non_zero_vals(accum::Accumulator{})
    return(length(accum))
end
    
function gamma(accum)
    nplus=count_non_zero_vals(accum)
    return(nplus/(nplus+float(sum(accum))))
end

"""
	score(m::InterpolatedLanguageModel, temp_lm::DefaultDict, word::AbstractString, context::AbstractString)	

score is used to output probability of word given that context in InterpolatedLanguageModel

Apply Kneserney and WittenBell smoothing
depending upon the sub-Type
        
"""
function score(m::InterpolatedLanguageModel, temp_lm::DefaultDict, word, context=nothing)
    (isnothing(context) || isempty(context)) && return prob(m, temp_lm, word)

    if context in keys(temp_lm)
        alpha,gamma = alpha_gammma(m, temp_lm, word, context)
        return (alpha + gamma*score(m, temp_lm, word, context_reduce(context)))
    else
        return score(m, temp_lm, word, context_reduce(context))
    end
end
        
function context_reduce(context)
    context = split(context)
    join(context[2:end], " ")
end


struct KneserNeyInterpolated <: InterpolatedLanguageModel 
    vocab::Vocabulary
    discount::Float64
end

"""
    KneserNeyInterpolated(word::Vector{T}, discount:: Float64,unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}

Initiate Type for providing KneserNey Interpolated language model.

The idea to abstract this comes from Chen & Goodman 1995.

"""
function KneserNeyInterpolated(word::Vector{T}, disc = 0.1, unk_cutoff=1, unk_label="<unk>") where {T <: AbstractString}
    KneserNeyInterpolated(Vocabulary(word, unk_cutoff, unk_label) ,disc)
end

function (lm::KneserNeyInterpolated)(text::Vector{T}, min::Integer, max::Integer) where {T <: AbstractString}
    text = lookup(lm.vocab, text)
    text=convert(Array{String}, text)
    return counter2(text, min, max)
end
# alpha_gamma function for KneserNeyInterpolated
function alpha_gammma(m::KneserNeyInterpolated, templ_lm::DefaultDict, word, context)
    local alpha
    local gamma   
    accum = templ_lm[context]
    s = float(sum(accum)) 
    for (text, count) in accum
        if text == word
            alpha=(max(float(count)-m.discount, 0.0) / s)
            break 
        else
            alpha = 1/length(m.vocab.vocab)
        end
    end
    gamma = (m.discount * count_non_zero_vals(accum) /s)
    return alpha, gamma
end
