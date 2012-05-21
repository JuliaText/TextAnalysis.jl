# Contains n-gram as key, occurrence count as value
type NGramDocument
  n::Int
  tokens::Dict
  language::String
end

function NGramDocument(n::Int, tokens::Dict)
  NGramDocument(n, tokens, "english")
end

function NGramDocument(n::Int)
  NGramDocument(n, Dict(), "english")
end

function NGramDocument()
  NGramDocument(1, Dict(), "english")
end

# Conversion functions from Document's to NGramDocument's.
function NGramDocument(n::Int, document::Document)
  n_gram_document = NGramDocument(n)
  n_gram_document.tokens = tokenize(document.text, n)
  n_gram_document
end

function NGramDocument(document::Document)
  n_gram_document = NGramDocument(1)
  n_gram_document.tokens = tokenize(document.text, 1)
  n_gram_document
end

function remove_words{S<:String}(n_gram_document::NGramDocument, words::Array{S,1})
  for word in words
    if has(n_gram_document.tokens, word)
      del(n_gram_document.tokens, word)
    end
  end
end

function remove_numbers(n_gram_document::NGramDocument)
  for token in keys(n_gram_document.tokens)
    if matches(r"\d+", token)
      del(n_gram_document.tokens, token)
    end
  end
end

function remove_punctuation(n_gram_document::NGramDocument)
  for token in keys(n_gram_document.tokens)
    if matches(r"[,;:.!?]", token)      
      del(n_gram_document.tokens, token)
    end
  end
end

function remove_case(n_gram_document::NGramDocument)
  for token in keys(n_gram_document.tokens)
    lc_token = lowercase(token)
    if lc_token != token
	    if has(n_gram_document.tokens, lc_token)
        n_gram_document.tokens[lc_token] = n_gram_document.tokens[lc_token] + n_gram_document.tokens[token]
      else
        n_gram_document.tokens[lc_token] = n_gram_document.tokens[token]
      end
      del(n_gram_document.tokens, token)
    end
  end
end

function remove_articles(n_gram_document::NGramDocument)
  remove_words(n_gram_document, articles(n_gram_document.language))
end

function remove_prepositions(n_gram_document::NGramDocument)
  remove_words(n_gram_document, prepositions(n_gram_document.language))
end

function remove_pronouns(n_gram_document::NGramDocument)
  remove_words(n_gram_document, pronouns(n_gram_document.language))
end

function remove_stopwords(n_gram_document::NGramDocument)
  remove_words(n_gram_document, stopwords(n_gram_document.language))
end

function print(n_gram_document::NGramDocument)
  println("An NGramDocument with $(length(n_gram_document.tokens)) $(n_gram_document.n)-gram tokens")
end

function show(n_gram_document::NGramDocument)
  println("An NGramDocument with $(length(n_gram_document.tokens)) $(n_gram_document.n)-gram tokens")
end
