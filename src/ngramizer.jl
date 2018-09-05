##############################################################################
#
# Construct n-grams using single space concatenation
#
##############################################################################

function ngramize(lang::S, words::Vector{T}, n::Int) where {S <: Language, T <: AbstractString}
    (n == 1) && return onegramize(lang, words)

    n_words = length(words)

    tokens = Dict{AbstractString, Int}()

    for m in 1:n
        for index in 1:(n_words - m + 1)
            token = join(words[index:(index + m - 1)], " ")
            tokens[token] = get(tokens, token, 0) + 1
        end
    end

    return tokens
end

function onegramize(lang::S, words::Vector{T}) where {S <: Language, T <: AbstractString}
    n_words = length(words)
    tokens = Dict{T, Int}()

    for word in words
        tokens[word] = get(tokens, word, 0) + 1
    end

    tokens
end
