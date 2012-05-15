type Corpus
  documents::Array{Document,1}
end

function Corpus()
  documents = Array(Document,1)
  del(documents, 1)
  Corpus(documents)
end

function add_document(corpus::Corpus, document::Document)
  corpus.documents = append(corpus.documents, [document])
  corpus
end

function remove_document(corpus::Corpus, document::Document)
  del(corpus.documents, find(corpus.documents == document)[1])
end

function Corpus{S<:String}(filenames::Array{S,1})
  corpus = Corpus()
  for filename in filenames
    add_document(corpus, Document(filename))
  end
  corpus
end

function Corpus(directory_name::String)
  filenames = dir(directory_name)
  Corpus(filenames)
end

function remove_words{S<:String}(corpus::Corpus, words::Array{S,1})
  for document in corpus.documents
    remove_words(document, words)
  end
end

function remove_numbers(corpus::Corpus)
  for document in corpus.documents
    remove_numbers(document)
  end
end

function remove_punctuation(corpus::Corpus)
  for document in corpus.documents
    remove_punctuation(document)
  end
end

function remove_case(corpus::Corpus)
  for document in corpus.documents
    remove_case(document)
  end
end

function to_n_gram_corpus(corpus::Corpus)
  n_gram_corpus = NGramCorpus()
  
  for document in corpus.documents
    add_document(n_gram_corpus, to_n_gram_document(document))
  end
  
  n_gram_corpus
end

function to_dtm(corpus::Corpus)
  to_dtm(to_n_gram_corpus(corpus))
end
