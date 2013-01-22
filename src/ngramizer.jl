##############################################################################
#
# Construct n-grams using single space concatenation
#
##############################################################################

function ngramize{S <: Language, T <: String}(::Type{S},
                                              words::Vector{T},
                                              n::Int)
    n_words = length(words)

    tokens = Dict{UTF8String, Int}()

    for m in 1:n
        for index in 1:(n_words - m + 1)
            token = join(words[index:(index + m - 1)], " ")
            tokens[token] = get(tokens, token, 0) + 1
        end
    end

    return tokens
end
