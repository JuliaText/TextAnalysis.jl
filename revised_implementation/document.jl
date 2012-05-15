type Document
  name::String
  date::String
  author::String
  text::String
end

function Document()
  Document("", "", "", "")
end

function Document(filename::String)
  document = Document()
  document.name = filename
  f = open(filename, "r")
  document.text = readall(f)
  close(f)
  document
end

#function remove_words(document::Document, words::Array{String,1})
function remove_words(document::Document, words)
  # Need to do some sort of tokenization first.
  for word in words
    document.text = replace(document.text, word, "")
  end
end

function remove_numbers(document::Document)
  # Remove all numeric characeters? Or just number tokens?
  document.text = replace(document.text, r"\d", "")
end

function remove_punctuation(document::Document)
  document.text = replace(document.text, ",", "")
  document.text = replace(document.text, ";", "")
  document.text = replace(document.text, ":", "")
  document.text = replace(document.text, ".", "")
  document.text = replace(document.text, "!", "")
  document.text = replace(document.text, "?", "")
  document.text = replace(document.text, r"\s+", " ")
end

function remove_case(document::Document)
  document.text = lowercase(document.text)
end

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
