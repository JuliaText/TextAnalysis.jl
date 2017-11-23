##############################################################################
#
# TF
#
##############################################################################

tf{T <: Real}(dtm::Matrix{T}) = tf!(dtm, Array{Float64}(size(dtm)...))

tf{T <: Real}(dtm::SparseMatrixCSC{T}) =  tf!(dtm, similar(dtm, Float64))

tf!{T <: Real}(dtm::AbstractMatrix{T}) = tf!(dtm, dtm)

tf!{T <: Real}(dtm::SparseMatrixCSC{T}) = tf!(dtm, dtm)

tf(dtm::DocumentTermMatrix) = tf(dtm.dtm)

# The second Matrix will be overwritten with the result
# Will work correctly if dtm and tfidf are the same matrix
function tf!{T1 <: Real, T2 <: AbstractFloat}(dtm::AbstractMatrix{T1}, tf::AbstractMatrix{T2})
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

# assumes second matrix has same nonzeros as first one
function tf!{T <: Real, F <: AbstractFloat}(dtm::SparseMatrixCSC{T}, tf::SparseMatrixCSC{F})
    rows = rowvals(dtm)
    dtmvals = nonzeros(dtm)
    tfvals = nonzeros(tf)
    @assert size(dtmvals) == size(tfvals)

    # TF tells us what proportion of a document is defined by a term
    words_in_documents = sum(dtm,2)

    n, p = size(dtm)
    for i = 1:p
       for j in nzrange(dtm, i)
          row = rows[j]
          tfvals[j] = dtmvals[j] / max(words_in_documents[row], one(T))
       end
    end
    tf
end

##############################################################################
#
# TF-IDF
#
##############################################################################

tf_idf{T <: Real}(dtm::Matrix{T}) = tf_idf!(dtm, Array{Float64}(size(dtm)...))

tf_idf{T <: Real}(dtm::SparseMatrixCSC{T}) =  tf_idf!(dtm, similar(dtm, Float64))

tf_idf!{T <: Real}(dtm::AbstractMatrix{T}) = tf_idf!(dtm, dtm)

tf_idf!{T <: Real}(dtm::SparseMatrixCSC{T}) = tf_idf!(dtm, dtm)

tf_idf(dtm::DocumentTermMatrix) = tf_idf(dtm.dtm)

# This does not make sense, since DocumentTermMatrix is based on an array of integers
#tf_idf!(dtm::DocumentTermMatrix) = tf_idf!(dtm.dtm)


# The second Matrix will be overwritten with the result
# Will work correctly if dtm and tfidf are the same matrix
function tf_idf!{T1 <: Real, T2 <: AbstractFloat}(dtm::AbstractMatrix{T1}, tfidf::AbstractMatrix{T2})
    n, p = size(dtm)

    # TF tells us what proportion of a document is defined by a term
    tf!(dtm, tfidf)

    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, 1))
    idf = log.(n ./ documents_containing_term)

    # TF-IDF is the product of TF and IDF
    for i in 1:n
        for j in 1:p
           tfidf[i, j] = tfidf[i, j] * idf[j]
        end
    end

    return tfidf
end

# sparse version
function tf_idf!{T <: Real, F <: AbstractFloat}(dtm::SparseMatrixCSC{T}, tfidf::SparseMatrixCSC{F})
    rows = rowvals(dtm)
    dtmvals = nonzeros(dtm)
    tfidfvals = nonzeros(tfidf)
    @assert size(dtmvals) == size(tfidfvals)

    n, p = size(dtm)

    # TF tells us what proportion of a document is defined by a term
    words_in_documents = F.(sum(dtm,2))
    const oneval = one(F)

    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, 1))
    idf = log.(n ./ documents_containing_term)

    for i = 1:p
       for j in nzrange(dtm, i)
          row = rows[j]
          tfidfvals[j] = dtmvals[j] / max(words_in_documents[row], oneval) * idf[i]
       end
    end

    tfidf
end
