"""
    ngramize(lang, tokens, n)

Compute the ngrams of `tokens` of the order `n`.

# Example

```julia-repl
julia> ngramize(Languages.English(), ["To", "be", "or", "not", "to"], 3)
Dict{AbstractString,Int64} with 3 entries:
  "be or not" => 1
  "or not to" => 1
  "To be or"  => 1
```
"""
function ngramize(lang::S, words::Vector{T}, n::Int) where {S <: Language, T <: AbstractString}
    (n == 1) && return onegramize(lang, words)

    n_words = length(words)

    tokens = Dict{AbstractString, Int}()

    for index in 1:(n_words - n + 1)
        token = join(words[index:(index + n - 1)], " ")
        tokens[token] = get(tokens, token, 0) + 1
    end
    return tokens
end

"""
    onegramize(lang, tokens)

Create the unigrams dict for input tokens.

# Example

```julia-repl
julia> onegramize(Languages.English(), ["To", "be", "or", "not", "to", "be"])
Dict{String,Int64} with 5 entries:
  "or"  => 1
  "not" => 1
  "to"  => 1
  "To"  => 1
  "be"  => 2
```
"""
function onegramize(lang::S, words::Vector{T}) where {S <: Language, T <: AbstractString}
    n_words = length(words)
    tokens = Dict{T, Int}()

    for word in words
        tokens[word] = get(tokens, word, 0) + 1
    end

    return tokens
end
