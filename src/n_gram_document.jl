# Contains n-gram as key, occurrence count as value
type NGramDocument
  n::Int
  tokens::Dict
end

function NGramDocument(n::Int)
  NGramDocument(n, Dict())
end

function NGramDocument()
  NGramDocument(1, Dict())
end

function remove_words{S<:String}(n_gram_document::NGramDocument, words::Array{S,1})
  for word in words
    if has(n_gram_document.tokens, word)
      del(n_gram_document.tokens, word)
    end
  end
end

# Conversion functions from Document's to NGramDocument's.
function to_n_gram_document(n::Int, document::Document)
  n_gram_document = NGramDocument(n)
  n_gram_document.tokens = tokenize(document.text, n)
  n_gram_document
end

function to_n_gram_document(document::Document)
  n_gram_document = NGramDocument(1)
  n_gram_document.tokens = tokenize(document.text, 1)
  n_gram_document
end
