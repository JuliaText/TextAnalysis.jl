# TODO
# * strip_sparse_terms
# * strip_frequent_terms
# * strip_html_tags
# * strip_non_letters
"""
Preprocessing functions

* strip_case

* corrupt_utf8
* whitespace
* punctuation
* numbers
* indefinite_articles
* definite_articles
* articles
* stopwords
* prepositions
* pronouns
"""
mutable struct PreprocessBuffer
    input::Vector{Char}
    buffer::Vector{Char}
    idx::Int
end

PreprocessBuffer(input) = PreprocessBuffer(input, [], 1)

PreprocessBuffer(input::AbstractString) = PreprocessBuffer(collect(input))

Base.getindex(ps::PreprocessBuffer, i = ps.idx) = ps.input[i]

isdone(ps::PreprocessBuffer) = ps.idx > length(ps.input)
