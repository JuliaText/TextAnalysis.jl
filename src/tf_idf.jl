##############################################################################
#
# TD
#
##############################################################################

tf{T <: Real}(dtm::Matrix{T}) = tf!(dtm, Array(Float64, size(dtm)...))

function tf{T <: Real}(dtm::SparseMatrixCSC{T})
    # TF tells us what proportion of a document is defined by a term
    n, p = size(dtm)
    rows = rowvals(dtm)
    vals = nonzeros(dtm)
    words_in_documents = sum(dtm,2)

    tfrows = Array(Int, 0)
    tfcols = Array(Int, 0)
    tfvals = Array(Float64, 0)

    for col = 1:p
      for j in nzrange(dtm, col)
        row = rows[j]
        val = vals[j]
        push!(tfrows, row)
        push!(tfcols, col)
        push!(tfvals, val/words_in_documents[row])
      end
    end
    sparse(tfrows, tfcols, tfvals)
end

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
        tf[i, :] = dtm[i, :] ./ words_in_document
    end

    return tf
end

##############################################################################
#
# TD-IDF
#
##############################################################################

tf_idf{T <: Real}(dtm::Matrix{T}) = tf_idf!(dtm, Array(Float64, size(dtm)...))

function tf_idf{T <: Real}(dtm::SparseMatrixCSC{T})
    n, p = size(dtm)
    rows = rowvals(dtm)
    vals = nonzeros(dtm)

    # TF tells us what proportion of a document is defined by a term
    words_in_documents = sum(dtm,2)

    # IDF tells us how rare a term is in the corpus
    documents_containing_term = vec(sum(dtm .> 0, 1))
    idf = log(n ./ documents_containing_term)

    tfidfrows = Array(Int, 0)
    tfidfcols = Array(Int, 0)
    tfidfvals = Array(Float64, 0)

    for col = 1:p
      for j in nzrange(dtm, col)
        row = rows[j]
        val = vals[j]
        push!(tfidfrows, row)
        push!(tfidfcols, col)
        push!(tfidfvals, val/words_in_documents[row] * idf[col])
      end
    end
    sparse(tfidfrows, tfidfcols, tfidfvals)
end

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
    idf = log(n ./ documents_containing_term)

    # TF-IDF is the product of TF and IDF
    for i in 1:n
        for j in 1:p
           tfidf[i, j] = tfidf[i, j] * idf[j]
        end
    end

    return tfidf
end
