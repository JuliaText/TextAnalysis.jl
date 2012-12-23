#load("newsgroups.jl")

dtm = spzeros()

# tf = spzeros(Float64, size(dtm)) Doesn't exist
# tf = spzeros(size(dtm)) # Doesn't exist
tf = spzeros(size(dtm, 1), size(dtm, 2))

# Problem because sum(sparse) is not sparse
document_sizes = sum(dtm, 2)
for i in 1:size(dtm, 1)
  tf[i, :] = dtm[i, :] ./ document_sizes[i]
end

# Problem because sum(sparse) is not sparse
document_sizes = sum(dtm, 2)
for i in 1:size(dtm, 1)
  tf[i, :] = dtm[i, :] / document_sizes[i]
end

# Problem because sum(sparse) is not sparse
for i in 1:size(dtm, 1)
  tf[i, :] = dtm[i, :] / (sum(dtm[i, :])[1])
end

# What about sparse vectors and not just sparse matrices?

idf = log(size(dtm.counts, 1) / sum(dtm.counts > 0, 1))

# Store TF-IDF in TF matrix to save space.
for i in 1:size(dtm, 1)
  for j in 1:size(dtm, 2)
    tf[i, j] = tf[i, j] * idf[1, j]
  end
end
  
tf
