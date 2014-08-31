##############################################################################
#
# TD-IDF
#
##############################################################################

function tf_idf{T <: Real}(dtm::Matrix{T})
    n, p = size(dtm)

    # TF tells us what proportion of a document is defined by a term
    tf = Array(Float64, n, p)
    for i in 1:n
        words_in_document = 0
        for j in 1:p
            words_in_document += dtm[i, j]
        end
        tf[i, :] = dtm[i, :] ./ words_in_document
    end

    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, 1))
    idf = log(n ./ documents_containing_term)

    # TF-IDF is the product of TF and IDF
    # We store it in the TF matrix to save space
    for i in 1:n
        for j in 1:p
           tf[i, j] = tf[i, j] * idf[j]
        end
    end

    return tf
end

# TODO: Rewrite this definition to return a sparse matrix
function tf_idf{T <: Real}(dtm::SparseMatrixCSC{T})
    n, p = size(dtm)

    # TF tells us what proportion of a document is defined by a term
    tf = Array(Float64, n, p)
    for i in 1:n
        words_in_document = 0
        for j in 1:p
            words_in_document += dtm[i, j]
        end
        tf[i, :] = dtm[i, :] ./ words_in_document
    end

    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, 1))
    idf = log(n ./ documents_containing_term)

    # TF-IDF is the product of TF and IDF
    # We store it in the TF matrix to save space
    for i in 1:n
        for j in 1:p
           tf[i, j] = tf[i, j] * idf[j]
        end
    end

    return tf
end

function tf_idf!{T <: Real}(dtm::Matrix{T})
    error("not yet implemented")
end

function tf_idf!{T <: Real}(dtm::SparseMatrixCSC{T})
    error("not yet implemented")
end

function tf_idf(dtm::DocumentTermMatrix)
    tf_idf(dtm.dtm)
end

function tf_idf!(dtm::DocumentTermMatrix)
    tf_idf!(dtm.dtm)
end
