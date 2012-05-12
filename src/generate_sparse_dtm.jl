# Corpus contains files, all_tokens, documents
function generate_sparse_dtm(corpus)
  # Create a map from keys(all_tokens) into ordered set of natural numbers.
  sorted_tokens = sort(keys(corpus.tokens))
  mapping = Dict()
  for i = 1:length(sorted_tokens)
    mapping[sorted_tokens[i]] = i
  end
  
  # Create a (sparse?) matrix that as many rows as files and as many columns as there are keys.
  # Then insert entries into this matrix for every file.
  n = length(corpus.files)
  m = length(sorted_tokens)
  
  load("extras/sparse.jl")
  
  dtm = spzeros(n, m)
  
  for i = 1:n
    file = corpus.files[i]
    for token in corpus.documents[file]
      dtm[i, mapping[token[1]]] = token[2]
    end
  end
  
  result = DocumentTermMatrix(sorted_tokens, dtm)
  result
end
