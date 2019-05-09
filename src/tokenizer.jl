"""
    tokenize(language, str)

Splits Strings into words and other tokens such as puntuation.
The output may vary as per the default tokenizer of WordTokenizers.jl

# Example
```julia-repl
julia> tokenize(Languages.English(), "Too foo words!")
4-element Array{String,1}:
 "Too"
 "foo"
 "words"
 "!"
```
"""
tokenize(lang::S, s::T) where {S <: Language, T <: AbstractString} = WordTokenizers.tokenize(s)


"""
    sentence_tokenize(language, str)

Splits Strings into sentences.

# Example
```julia-repl
julia> sentence_tokenize(Languages.English(), "Here are few words! I am Foo Bar.")
2-element Array{SubString{String},1}:
 "Here are few words!"
 "I am Foo Bar."
```
"""
sentence_tokenize(lang::S, s::T) where {S <: Language, T<:AbstractString} = WordTokenizers.split_sentences(s)
