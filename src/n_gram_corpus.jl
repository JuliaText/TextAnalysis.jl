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
    add_document(n_gram_corpus, NGramDocument(document))
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

# Conversion tools.
function NGramCorpus(corpus::Corpus)
  n_gram_corpus = NGramCorpus()
  
  for document in corpus.documents
    add_document(n_gram_corpus, NGramDocument(document))
  end
  
  n_gram_corpus
end

function remove_numbers(n_gram_corpus::NGramCorpus)
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_numbers(n_gram_document)
  end
end

function remove_punctuation(n_gram_corpus::NGramCorpus)
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_punctuation(n_gram_document)
  end
end

function remove_case(n_gram_corpus::NGramCorpus)
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_case(n_gram_document)
  end
end

function remove_words{S<:String}(n_gram_corpus::NGramCorpus, words::Array{S,1})
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_words(n_gram_document, words)
  end
end

function remove_articles(n_gram_corpus::NGramCorpus)
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_words(n_gram_document, articles(n_gram_document.language))
  end
end

function remove_prepositions(n_gram_corpus::NGramCorpus)
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_words(n_gram_document, prepositions(n_gram_document.language))
  end
end

function remove_pronouns(n_gram_corpus::NGramCorpus)
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_words(n_gram_document, pronouns(n_gram_document.language))
  end
end

function remove_stopwords(n_gram_corpus::NGramCorpus)
  for n_gram_document in n_gram_corpus.n_gram_documents
    remove_words(n_gram_document, stopwords(n_gram_document.language))
  end
end

function print(n_gram_corpus::NGramCorpus)
  println("NGramCorpus:")
  println("  N-Gram Documents: $(length(n_gram_corpus.n_gram_documents))")
end

function show(n_gram_corpus::NGramCorpus)
  print(n_gram_corpus)
end

function ref(n_gram_corpus::NGramCorpus, index::Int)
  n_gram_corpus.n_gram_documents[index]
end

function assign(n_gram_corpus::NGramCorpus, n_gram_document::NGramDocument, index::Int)
  n_gram_corpus.n_gram_documents[index] = n_gram_document
end
