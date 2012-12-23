    # Example data
    dtm = spzeros(3, 10)

    dtm[1, 1] = 5
    dtm[1, 8] = 3
    dtm[2, 2] = 7
    dtm[2, 8] = 3
    dtm[3, 5] = 2
    dtm[3, 8] = 1

    # The following type of invocation of spzeros() doesn't exist
    tf_idf = spzeros(Float64, size(dtm))

    # The following type of invocation of spzeros() doesn't exist
    tf_idf = spzeros(size(dtm))

    # This invocation style does exist.
    tf_idf = spzeros(size(dtm, 1), size(dtm, 2))

    # This fails
    document_sizes = sum(dtm, 2)
    for i in 1:size(dtm, 1)
      tf_idf[i, :] = dtm[i, :] / document_sizes[i]
    end

    # This also fails
    document_sizes = sum(dtm, 2)
    for i in 1:size(dtm, 1)
      tf_idf[i, :] = dtm[i, :] ./ document_sizes[i]
    end

    # And even this fails
    for i in 1:size(dtm, 1)
      tf_idf[i, :] = dtm[i, :] / (sum(dtm[i, :])[1])
    end

    # This fails because of inequality operators return an Array{Any}
    idf = log(size(dtm, 1) ./ sum(dtm .> 0, 1))

    # Store TF-IDF in TF matrix to save space.
    for i in 1:size(dtm, 1)
      for j in 1:size(dtm, 2)
        tf_idf[i, j] = tf_idf[i, j] * idf[1, j]
      end
    end
