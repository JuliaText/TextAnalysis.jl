function pronouns{T <: String}(language::T)
  filename = strcat("data/pronouns/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end

function articles{T <: String}(language::T)
  filename = strcat("data/articles/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end

function prepositions{T <: String}(language::T)
  filename = strcat("data/prepositions/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end

function stopwords{T <: String}(language::T)
  filename = strcat("data/stopwords/", language, ".txt")
  f = open(filename, "r")
  words = map(x -> chomp(x), readlines(f))
  close(f)
  convert(Array{String,1}, words)
end
