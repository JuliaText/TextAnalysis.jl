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

# Conversion tools.
function to_n_gram_corpus(corpus::Corpus)
  n_gram_corpus = NGramCorpus()
  
  for document in corpus.documents
    add_document(n_gram_corpus, to_n_gram_document(document))
  end
  
  n_gram_corpus
end
