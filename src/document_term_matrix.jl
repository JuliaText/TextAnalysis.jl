type DocumentTermMatrix
  tokens::Array{Any,1}
  counts::Array{Int,2}
end

function DocumentTermMatrix()
  tokens = {}
  counts = zeros(Int, 0, 0)
  dtm = DocumentTermMatrix(tokens, counts)
  dtm
end

# Conversion tools.
function DocumentTermMatrix(n_gram_corpus::NGramCorpus)
  aggregate_tokens = map(x -> keys(x.tokens), n_gram_corpus.n_gram_documents)
  all_tokens = reduce(append, aggregate_tokens)
  tokens_dict = Dict()
  for token in sort(all_tokens)
    tokens_dict[token] = 0
  end
  sorted_tokens = sort(keys(tokens_dict))
  
  # Create a map from keys(all_tokens) into ordered set of natural numbers.
  mapping = Dict()
  for i = 1:length(sorted_tokens)
    mapping[sorted_tokens[i]] = i
  end
  
  # Create a (sparse?) matrix that as many rows as the corpus has documents
  # and as many columns as the corpus has tokens.
  #
  # Then insert entries into this matrix for every document.
  n = length(n_gram_corpus.n_gram_documents)
  m = length(sorted_tokens)
  counts = zeros(Int, n, m)
  
  for i = 1:n
    for token in n_gram_corpus.n_gram_documents[i].tokens
      counts[i, mapping[token[1]]] = token[2]
    end
  end
  
  DocumentTermMatrix(sorted_tokens, counts)
end

function DocumentTermMatrix(corpus::Corpus)
  DocumentTermMatrix(NGramCorpus(corpus))
end

function remove_sparse_tokens(dtm::DocumentTermMatrix, alpha::Float)
  nonsparse_term_indices = find(sum(dtm.counts, 1) > size(dtm.counts, 1) * alpha)
  dtm.tokens = dtm.tokens[nonsparse_term_indices]
  dtm.counts = dtm.counts[:, nonsparse_term_indices]
end

function remove_sparse_tokens(dtm::DocumentTermMatrix)
  remove_sparse_tokens(dtm, 0.05)
end

function tf_idf(dtm::DocumentTermMatrix)
  # Calculate TF.
  tf = zeros(Float, size(dtm.counts))
  for i in 1:size(dtm.counts, 1)
    tf[i, :] = dtm.counts[i, :] ./ sum(dtm.counts, 2)[i]
  end

  # Calculate IDF.
  idf = log(size(dtm.counts, 1) / sum(dtm.counts > 0, 1))

  # Store TF-IDF in TF matrix.
  for i in 1:size(dtm.counts, 1)
    for j in 1:size(dtm.counts, 2)
      tf[i, j] = tf[i, j] * idf[1, j]
    end
  end
  
  tf
end

function print(dtm::DocumentTermMatrix)
  println("DTM Tokens")
  println("DTM Counts")
end

function show(dtm::DocumentTermMatrix)
  println("DTM Tokens")
  println("DTM Counts")
end
