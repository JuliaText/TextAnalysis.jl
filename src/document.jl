type Document
  name::String
  date::String
  author::String
  text::String
  language::String
end

function Document()
  Document("", "", "", "", "english")
end

function Document(filename::String)
  document = Document()
  document.name = filename
  f = open(filename, "r")
  document.text = readall(f)
  close(f)
  document
end

function remove_numbers(document::Document)
  # Currently removes all numeric characters.
  # Should we just remove number tokens?
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

function remove_words{S<:String}(document::Document, words::Array{S,1})
  chunks = split(document.text, r"\s+")
  results = []
  for index in 1:length(chunks)
    if length(find(chunks[index] == words)) == 0
      results = [results, index]
    end
  end
  document.text = join(chunks[results], " ")
end

function remove_articles(document::Document)
  remove_words(document, articles(document.language))
end

function remove_prepositions(document::Document)
  remove_words(document, prepositions(document.language))
end

function remove_pronouns(document::Document)
  remove_words(document, pronouns(document.language))
end

function remove_stopwords(document::Document)
  remove_words(document, stopwords(document.language))
end

function print(document::Document)
  println("Document:")
  println("  Name: $(document.name)")
  println("  Date: $(document.date)")
  println("  Author: $(document.author)")
  println("  Language: $(document.language)")
  println("  Text: ...")  
end

function show(document::Document)
  print(document)
end
