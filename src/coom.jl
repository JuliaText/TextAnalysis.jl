# This file originally copied from StringAnalysis.jl
# Copyright (c) 2018: Corneliu Cofaru.

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""
    coo_matrix(::Type{T}, doc::Vector{AbstractString}, vocab::OrderedDict{AbstractString, Int}, window::Int, normalize::Bool, mode::Symbol)

Basic low-level function that calculates the co-occurrence matrix of a document.
Returns a sparse co-occurrence matrix sized `n × n` where `n = length(vocab)`
with elements of type `T`. The document `doc` is represented by a vector of its
terms (in order)`. The keywords `window` and `normalize` indicate the size of the
sliding word window in which co-occurrences are counted and whether to normalize
of not the counts by the distance between word positions. The `mode` keyword can be either `:default` or `:directional` and indicates whether the co-occurrence  matrix should be directional or not. This means that if `mode` is `:directional` then the co-occurrence matrix will be a `n × n` matrix where `n = length(vocab)` and `coom[i,j]` will be the number of times `vocab[i]` co-occurs with `vocab[j]` in the document `doc`. If `mode` is `:default` then the co-occurrence matrix will be a `n × n` matrix where `n = length(vocab)` and `coom[i,j]` will be twice the number of times `vocab[i]` co-occurs with `vocab[j]` in the document `doc` (once for each direction, from i to j + from j to i).

# Example
```
julia> using TextAnalysis, DataStructures
       doc = StringDocument("This is a text about an apple. There are many texts about apples.")
       docv = TextAnalysis.tokenize(language(doc), text(doc))
       vocab = OrderedDict("This"=>1, "is"=>2, "apple."=>3)
       TextAnalysis.coo_matrix(Float16, docv, vocab, 5, true)

3×3 SparseArrays.SparseMatrixCSC{Float16,Int64} with 4 stored entries:
13×13 SparseArrays.SparseMatrixCSC{Float16, Int64} with 106 stored entries:
  ⋅   2.0  1.0  0.6665  0.5     0.4      ⋅    ⋅      ⋅       ⋅    ⋅       ⋅    ⋅ 
 2.0   ⋅   2.0  1.0     0.6665  0.5     0.4   ⋅      ⋅       ⋅    ⋅       ⋅    ⋅ 
 1.0  2.0   ⋅   2.0     1.0     0.6665  0.5  0.4     ⋅       ⋅    ⋅       ⋅    ⋅ 
 ⋮                              ⋮                                ⋮            
  ⋅    ⋅    ⋅    ⋅      2.0      ⋅      0.4  1.166  0.6665  1.0  2.0      ⋅   1.0
  ⋅    ⋅    ⋅    ⋅      2.0      ⋅       ⋅   2.0    0.4     0.5  0.6665  1.0   ⋅ 

julia> using TextAnalysis, DataStructures
       doc = StringDocument("This is a text about an apple. There are many texts about apples.")
       docv = TextAnalysis.tokenize(language(doc), text(doc))
       vocab = vocab(doc)
       TextAnalysis.coo_matrix(Float16, docv, vocab, 5, true, :directional)

13×13 SparseArrays.SparseMatrixCSC{Float16, Int64} with 106 stored entries:
  ⋅   1.0  0.5  0.3333  0.25    0.2      ⋅     ⋅      ⋅       ⋅     ⋅       ⋅    ⋅ 
 1.0   ⋅   1.0  0.5     0.3333  0.25    0.2    ⋅      ⋅       ⋅     ⋅       ⋅    ⋅ 
 0.5  1.0   ⋅   1.0     0.5     0.3333  0.25  0.2     ⋅       ⋅     ⋅       ⋅    ⋅ 
 ⋮                              ⋮                                  ⋮            
  ⋅    ⋅    ⋅    ⋅      1.0      ⋅      0.2   0.583  0.3333  0.5   1.0      ⋅   0.5
  ⋅    ⋅    ⋅    ⋅      1.0      ⋅       ⋅    1.0    0.2     0.25  0.3333  0.5   ⋅ 
```
"""
function coo_matrix(::Type{T},
    doc::Vector{<:AbstractString},
    vocab::OrderedDict{<:AbstractString,
        Int},
    window::Int,
    normalize::Bool=true,
    mode::Symbol=:default) where {T<:AbstractFloat}
    # Initializations
    n = length(vocab)
    m = length(doc)
    coom = spzeros(T, n, n)
    # Count co-occurrences
    for (i, token) in enumerate(doc)
        inner_range = if mode == :directional
            i:min(m, i + window)
        else
            max(1, i - window):min(m, i + window)
        end
        row = get(vocab, token, nothing)
        isnothing(row) && continue

        # looking forward
        @inbounds for j in inner_range
            i == j && continue

            wtoken = doc[j]
            col = get(vocab, wtoken, nothing)
            isnothing(col) && continue
            nm = T(ifelse(normalize, abs(i - j), 1))
            coom[row, col] += one(T) / nm
            coom[col, row] = coom[row, col]
        end
    end
    return coom
end

coo_matrix(::Type{T}, doc::Vector{<:AbstractString}, vocab::Dict{<:AbstractString,Int},
    window::Int, normalize::Bool=true, mode::Symbol=:default) where {T<:AbstractFloat} =
    coo_matrix(T, doc, OrderedDict(vocab), window, normalize, mode)

"""
Basic Co-occurrence Matrix (COOM) type.
# Fields
  * `coom::SparseMatriCSC{T,Int}` the actual COOM; elements represent
co-occurrences of two terms within a given window
  * `terms::Vector{String}` a list of terms that represent the lexicon of
the document or corpus
  * `column_indices::OrderedDict{String, Int}` a map between the `terms` and the
columns of the co-occurrence matrix
"""
struct CooMatrix{T}
    coom::SparseMatrixCSC{T,Int}
    terms::Vector{String}
    column_indices::OrderedDict{String,Int}
end


"""
    CooMatrix{T}(crps::Corpus [,terms] [;window=5, normalize=true])

Auxiliary constructor(s) of the `CooMatrix` type. The type `T` has to be
a subtype of `AbstractFloat`. The constructor(s) requires a corpus `crps` and
a `terms` structure representing the lexicon of the corpus. The latter
can be a `Vector{String}`, an `AbstractDict` where the keys are the lexicon,
or can be omitted, in which case the `lexicon` field of the corpus is used.
"""
function CooMatrix{T}(crps::Corpus,
    terms::Vector{String};
    window::Int=5,
    normalize::Bool=true,
    mode::Symbol=:default) where {T<:AbstractFloat}
    column_indices = OrderedDict(columnindices(terms))
    n = length(terms)
    coom = spzeros(T, n, n)
    for doc in crps
        coom .+= coo_matrix(T, tokens(doc), column_indices, window, normalize, mode)
    end
    return CooMatrix{T}(coom, terms, column_indices)
end

CooMatrix(crps::Corpus, terms::Vector{String}; window::Int=5, normalize::Bool=true, mode::Symbol=:default) =
    CooMatrix{Float64}(crps, terms, window=window, normalize=normalize, mode=mode)

CooMatrix{T}(crps::Corpus, lex::AbstractDict; window::Int=5, normalize::Bool=true, mode::Symbol=:default) where {T<:AbstractFloat} =
    CooMatrix{T}(crps, collect(keys(lex)), window=window, normalize=normalize, mode=mode)

CooMatrix(crps::Corpus, lex::AbstractDict; window::Int=5, normalize::Bool=true, mode::Symbol=:default) =
    CooMatrix{Float64}(crps, lex, window=window, normalize=normalize, mode=mode)

CooMatrix{T}(crps::Corpus; window::Int=5, normalize::Bool=true, mode::Symbol=:default) where {T<:AbstractFloat} = begin
    isempty(lexicon(crps)) && update_lexicon!(crps)
    CooMatrix{T}(crps, lexicon(crps), window=window, normalize=normalize, mode=mode)
end

CooMatrix(crps::Corpus; window::Int=5, normalize::Bool=true, mode::Symbol=:default) = begin
    isempty(lexicon(crps)) && update_lexicon!(crps)
    CooMatrix{Float64}(crps, lexicon(crps), window=window, normalize=normalize, mode=mode)
end

# Document methods
function CooMatrix{T}(doc::AbstractDocument,
    terms::Vector{String};
    window::Int=5,
    normalize::Bool=true,
    mode::Symbol=:default) where {T<:AbstractFloat}
    # Initializations
    column_indices = OrderedDict(columnindices(terms))
    coom = coo_matrix(T, tokens(doc), column_indices, window, normalize, mode)
    return CooMatrix{T}(coom, terms, column_indices)
end

function CooMatrix{T}(doc::NGramDocument,
    terms::Vector{String};
    window::Int=5,
    normalize::Bool=true,
    mode::Symbol=:default) where {T<:AbstractFloat}
    error("The Co occurrence matrix of an NGramDocument can't be created.")
end

CooMatrix(doc, terms::Vector{String}; window::Int=5, normalize::Bool=true, mode::Symbol=:default) =
    CooMatrix{Float64}(doc, terms, window=window, normalize=normalize, mode=mode)

function CooMatrix{T}(doc; window::Int=5, normalize::Bool=true, mode::Symbol=:default) where {T<:AbstractFloat}
    terms = unique(String.(tokens(doc)))
    CooMatrix{T}(doc, terms, window=window, normalize=normalize, mode=mode)
end

CooMatrix(doc; window::Int=5, normalize::Bool=true, mode::Symbol=:default) =
    CooMatrix{Float64}(doc, window=window, normalize=normalize, mode=mode)

"""
    coom(c::CooMatrix)

Access the co-occurrence matrix field `coom` of a `CooMatrix` `c`.
"""
coom(c::CooMatrix) = c.coom

"""
    coom(entity, eltype=DEFAULT_FLOAT_TYPE [;window=5, normalize=true])

Access the co-occurrence matrix of the `CooMatrix` associated
with the `entity`. The `CooMatrix{T}` will first have to
be created in order for the actual matrix to be accessed.
"""
coom(entity, eltype::Type{T}=Float;
    window::Int=5, normalize::Bool=true, mode::Symbol=:default) where {T<:AbstractFloat} =
    coom(CooMatrix{T}(entity, window=window, normalize=normalize, mode=mode))
