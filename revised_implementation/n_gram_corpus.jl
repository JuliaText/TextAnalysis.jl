type NGramCorpus
  n_gram_documents::Array{NGramDocument,1}
end

function NGramCorpus()
  n_gram_documents = Array(NGramDocument, 1)
  del(n_gram_documents, 1)
  n_gram_corpus = NGramCorpus(n_gram_documents)
  n_gram_corpus
end

function NGramCorpus(documents::Array{Document,1})
  n_gram_corpus = NGramCorpus()
  
  for document in documents
    add_document(n_gram_corpus, to_n_gram_document(document))
  end
  
  n_gram_corpus
end

function add_document(n_gram_corpus::NGramCorpus, n_gram_document::NGramDocument)
  n_gram_corpus.n_gram_documents = append(n_gram_corpus.n_gram_documents, [n_gram_document])
  n_gram_corpus
end

function remove_document(n_gram_corpus::NGramCorpus, n_gram_document::NGramDocument)
  del(n_gram_corpus.n_gram_documents, find(n_gram_corpus.n_gram_documents == n_gram_document)[1])
end

function remove_words{S<:String}(n_gram_corpus::NGramCorpus, words::Array{S,1})
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_words(n_gram_document, words)
  end
end

function to_dtm(n_gram_corpus::NGramCorpus)
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
