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
