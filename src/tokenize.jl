function tokenize(s::String)
  raw_words = split(s, r"\s+")
  tokens = Dict()
  for word in raw_words
    if has(tokens, word)
      tokens[word] = tokens[word] + 1
    else
      tokens[word] = 1
    end
  end
  tokens
end
