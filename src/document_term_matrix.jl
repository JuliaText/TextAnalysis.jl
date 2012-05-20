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

function td_idf(dtm::DocumentTermMatrix)
end

function remove_sparse_terms(dtm::DocumentTermMatrix)
  not_sparse_indices = sum(int(dtm.counts == 0), 1) > 0.05 * size(dtm.counts, 1)
  dtm.counts = dtm.counts[:, not_sparse_indices]
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
