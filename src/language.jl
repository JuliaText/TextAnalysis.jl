function pronouns(language)
  filename = strcat("data/pronouns/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end

function articles(language)
  filename = strcat("data/articles/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end

function prepositions(language)
  filename = strcat("data/prepositions/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end

function stopwords(language)
  filename = strcat("data/stopwords/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end
