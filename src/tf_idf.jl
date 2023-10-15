"""
    tf!(dtm::AbstractMatrix{Real}, tf::AbstractMatrix{AbstractFloat})

Overwrite `tf` with the term frequency of the `dtm`.

Works correctly if `dtm` and `tf` are same matrix.

See also: [`tf`](@ref), [`tf_idf`](@ref), [`tf_idf!`](@ref)
"""
function tf!(dtm::AbstractMatrix{T1}, tf::AbstractMatrix{T2}) where {T1 <: Real, T2 <: AbstractFloat}
    n, p = size(dtm)

    # TF tells us what proportion of a document is defined by a term
    for i in 1:n
        words_in_document = 0
        for j in 1:p
            words_in_document += dtm[i, j]
        end
        tf[i, :] = dtm[i, :] ./ max(words_in_document, one(T1))
    end

    return tf
end

"""
    tf!(dtm::SparseMatrixCSC{Real}, tf::SparseMatrixCSC{AbstractFloat})

Overwrite `tf` with the term frequency of the `dtm`.

`tf` should have the has same nonzeros as `dtm`.

See also: [`tf`](@ref), [`tf_idf`](@ref), [`tf_idf!`](@ref)
"""
function tf!(dtm::SparseMatrixCSC{T}, tf::SparseMatrixCSC{F}) where {T <: Real, F <: AbstractFloat}
    rows = rowvals(dtm)
    dtmvals = nonzeros(dtm)
    tfvals = nonzeros(tf)
    @assert size(dtmvals) == size(tfvals)

    # TF tells us what proportion of a document is defined by a term
    words_in_documents = sum(dtm,dims=2)

    n, p = size(dtm)
    for i = 1:p
       for j in nzrange(dtm, i)
          row = rows[j]
          tfvals[j] = dtmvals[j] / max(words_in_documents[row], one(T))
       end
    end
    return tf
end

tf!(dtm::AbstractMatrix{T}) where {T <: Real} = tf!(dtm, dtm)

tf!(dtm::SparseMatrixCSC{T}) where {T <: Real} = tf!(dtm, dtm)

"""
    tf(dtm::DocumentTermMatrix)
    tf(dtm::SparseMatrixCSC{Real})
    tf(dtm::Matrix{Real})

Compute the `term-frequency` of the input.

# Example

```julia-repl
julia> crps = Corpus([StringDocument("To be or not to be"),
              StringDocument("To become or not to become")])

julia> update_lexicon!(crps)

julia> m = DocumentTermMatrix(crps)

julia> tf(m)
2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:
  [1, 1]  =  0.166667
  [2, 1]  =  0.166667
  [1, 2]  =  0.333333
  [2, 3]  =  0.333333
  [1, 4]  =  0.166667
  [2, 4]  =  0.166667
  [1, 5]  =  0.166667
  [2, 5]  =  0.166667
  [1, 6]  =  0.166667
  [2, 6]  =  0.166667
```

See also: [`tf!`](@ref), [`tf_idf`](@ref), [`tf_idf!`](@ref)
"""
tf(dtm::DocumentTermMatrix) = tf(dtm.dtm)

tf(dtm::Matrix{T}) where {T <: Real} = tf!(dtm, Array{Float64}(undef, size(dtm)...))

tf(dtm::SparseMatrixCSC{T}) where {T <: Real} =  tf!(dtm, similar(dtm, Float64))

"""
    tf_idf!(dtm::AbstractMatrix{Real}, tf_idf::AbstractMatrix{AbstractFloat})

Overwrite `tf_idf` with the tf-idf (Term Frequency - Inverse Doc Frequency) of the `dtm`.

`dtm` and `tf-idf` must be matrices of same dimensions.

See also: [`tf`](@ref), [`tf!`](@ref) , [`tf_idf`](@ref)
"""
function tf_idf!(dtm::AbstractMatrix{T1}, tfidf::AbstractMatrix{T2}) where {T1 <: Real, T2 <: AbstractFloat}
    n, p = size(dtm)

    # TF tells us what proportion of a document is defined by a term
    tf!(dtm, tfidf)

    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, dims=1))
    idf = log.(n ./ documents_containing_term)

    # TF-IDF is the product of TF and IDF
    for i in 1:n,
        j in 1:p

        tfidf[i, j] *= idf[j]
    end

    return tfidf
end

"""
    tf_idf!(dtm::SparseMatrixCSC{Real}, tfidf::SparseMatrixCSC{AbstractFloat})

Overwrite `tfidf` with the tf-idf (Term Frequency - Inverse Doc Frequency) of the `dtm`.

The arguments must have same number of nonzeros.

See also: [`tf`](@ref), [`tf_idf`](@ref), [`tf_idf!`](@ref)
"""
function tf_idf!(dtm::SparseMatrixCSC{T}, tfidf::SparseMatrixCSC{F}) where {T <: Real, F <: AbstractFloat}
    rows = rowvals(dtm)
    dtmvals = nonzeros(dtm)
    tfidfvals = nonzeros(tfidf)
    @assert size(dtmvals) == size(tfidfvals)

    n, p = size(dtm)

    # TF tells us what proportion of a document is defined by a term
    words_in_documents = F.(sum(dtm, dims=2))
    oneval = one(F)

    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, dims=1))
    idf = log.(n ./ documents_containing_term)

    for i = 1:p
       for j in nzrange(dtm, i)
          row = rows[j]
          tfidfvals[j] = dtmvals[j] / max(words_in_documents[row], oneval) * idf[i]
       end
    end

    return tfidf
end

"""
    tf_idf!(dtm)

Compute tf-idf for `dtm`
"""
tf_idf!(dtm::AbstractMatrix{T}) where {T <: Real} = tf_idf!(dtm, dtm)

tf_idf!(dtm::SparseMatrixCSC{T}) where {T <: Real} = tf_idf!(dtm, dtm)

# This does not make sense, since DocumentTermMatrix is based on an array of integers
#tf_idf!(dtm::DocumentTermMatrix) = tf_idf!(dtm.dtm)

"""
    tf(dtm::DocumentTermMatrix)
    tf(dtm::SparseMatrixCSC{Real})
    tf(dtm::Matrix{Real})

Compute `tf-idf` value (Term Frequency - Inverse Document Frequency) for the input.

In many cases, raw word counts are not appropriate for use because:

- Some documents are longer than other documents
- Some words are more frequent than other words

A simple workaround this can be done by performing `TF-IDF` on a `DocumentTermMatrix`

# Example

```julia-repl
julia> crps = Corpus([StringDocument("To be or not to be"),
              StringDocument("To become or not to become")])

julia> update_lexicon!(crps)

julia> m = DocumentTermMatrix(crps)

julia> tf_idf(m)
2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:
  [1, 1]  =  0.0
  [2, 1]  =  0.0
  [1, 2]  =  0.231049
  [2, 3]  =  0.231049
  [1, 4]  =  0.0
  [2, 4]  =  0.0
  [1, 5]  =  0.0
  [2, 5]  =  0.0
  [1, 6]  =  0.0
  [2, 6]  =  0.0
```

See also: [`tf!`](@ref), [`tf_idf`](@ref), [`tf_idf!`](@ref)
"""
tf_idf(dtm::DocumentTermMatrix) = tf_idf(dtm.dtm)

tf_idf(dtm::SparseMatrixCSC{T}) where {T <: Real} =  tf_idf!(dtm, similar(dtm, Float64))

tf_idf(dtm::Matrix{T}) where {T <: Real} = tf_idf!(dtm, Array{Float64}(undef, size(dtm)...))

function bm_25!(dtm::AbstractMatrix{T},
                bm25::AbstractMatrix{F};
                κ::Int=2,
                β::Float64=0.75
               ) where {T<:Real, F<:AbstractFloat}
    @assert size(dtm) == size(bm25)
    # Initializations
    k = F(κ)
    b = F(β)
    p, n = size(dtm)
    oneval = one(F)
    # TF tells us what proportion of a document is defined by a term
    words_in_documents = F.(sum(dtm, dims=1))
    ln = words_in_documents./mean(words_in_documents)
    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, dims=2)) .+ one(T)
    idf = log.(n ./ documents_containing_term) .+ oneval
    # BM25 is the product of IDF and a fudged TF
    tf_bm25!(dtm, bm25)
    @inbounds @simd for i in 1:n
        for j in 1:p
            bm25[j, i] = idf[j] *
                ((k + 1) * bm25[j, i]) /
                (k * (oneval - b + b * ln[i]) + bm25[j, i])
        end
    end
    return bm25
end

function bm_25!(dtm::SparseMatrixCSC{T},
                bm25::SparseMatrixCSC{F};
                κ::Int=2,
                β::Float64=0.75
               ) where {T<:Real, F<:AbstractFloat}
    @assert size(dtm) == size(bm25)
    # Initializations
    k = F(κ)
    b = F(β)
    rows = rowvals(dtm)
    dtmvals = nonzeros(dtm)
    bm25vals = nonzeros(bm25)
    @assert size(dtmvals) == size(bm25vals)
    p, n = size(dtm)
    # TF tells us what proportion of a document is defined by a term
    words_in_documents = F.(sum(dtm, dims=1))
    ln = words_in_documents./mean(words_in_documents)
    oneval = one(F)
    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, dims=2)) .+ one(T)
    idf = log.(n ./ documents_containing_term) .+ oneval
    for i = 1:n
       for j in nzrange(dtm, i)
          row = rows[j]
          tf = sqrt.(dtmvals[j] / max(words_in_documents[i], oneval))
          bm25vals[j] = idf[row] * ((k + 1) * tf) /
                        (k * (oneval - b + b * ln[i]) + tf)
       end
    end
    return bm25
end

bm_25(dtm::AbstractMatrix{T}; κ::Int=2, β::Float64=0.75) where T<:Integer =
    bm_25!(dtm, similar(dtm, Float64), κ=κ, β=β)

bm_25(dtm::AbstractMatrix{T}; κ::Int=2, β::Float64=0.75) where T<:AbstractFloat =
    bm_25!(dtm, similar(dtm, T), κ=κ, β=β)

bm_25(dtm::DocumentTermMatrix; κ::Int=2, β::Float64=0.75) =
    bm_25(dtm.dtm, κ=κ, β=β)

bm_25!(dtm::DocumentTermMatrix; κ::Int=2, β::Float64=0.75) =
    bm_25!(dtm.dtm, κ=κ, β=β)

# The score was modified according to for bm25:
#   https://opensourceconnections.com/blog/2015/10/16/bm25-the-next-generation-of-lucene-relevation/
function tf_bm25!(dtm::AbstractMatrix{T}, tf::AbstractMatrix{F}
            ) where {T<:Real, F<:AbstractFloat}
    @assert size(dtm) == size(tf)
    p, n = size(dtm)
    # TF tells us what proportion of a document is defined by a term
    words_in_documents = sum(dtm, dims=1)
    @inbounds for i in 1:n
        tf[:, i] = sqrt.(dtm[:, i] ./ max(words_in_documents[i], one(T)))
    end
    return tf
end

"""
    function cos_similarity(tfm::AbstractMatrix)

`cos_similarity` calculates the cosine similarity from a term frequency matrix (typically the tf-idf matrix).

# Example
```
crps = Corpus( StringDocument.([
    "to be or not to be",
    "to sing or not to sing",
    "to talk or to silence"]) )
update_lexicon!(crps)
d = dtm(crps)
tfm = tf_idf(d)
cs = cos_similarity(tfm)
Matrix(cs)
    # 3×3 Array{Float64,2}:
    #  1.0        0.0329318  0.0
    #  0.0329318  1.0        0.0
    #  0.0        0.0        1.0
```
"""
function cos_similarity(tfm::AbstractMatrix)
    cs = tfm * tfm'
    d = sqrt.(diag(cs))
    # prevent division by zero  (only occurs for empty documents)
    d[findall(iszero, d)] .= 1
    cs ./ (d * d')
end
