##############################################################################
#
# TD-IDF
#
##############################################################################

tf_idf{T <: Real}(dtm::Matrix{T}) = tf_idf!(dtm, Array{Float64}(size(dtm)...))

tf_idf{T <: Real}(dtm::SparseMatrixCSC{T}) =  tf_idf!(dtm, sparse(Int[], Int[], 0.0, size(dtm)...))

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
    for i in 1:n
        words_in_document = 0
        for j in 1:p
            words_in_document += dtm[i, j]
        end
        tfidf[i, :] = dtm[i, :] ./ maximum([words_in_document, 1])
    end

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
