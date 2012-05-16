# Split string into tokens.
# Construct n-grams uses single space concatenation.
function tokenize(s::String, n::Int)
  words = split(s, r"\s+")
  
  tokens = Dict()
  
  for index in 1:(length(words) - n + 1)
    token = join(words[index:(index + n - 1)], " ")
    if has(tokens, token)
      tokens[token] = tokens[token] + 1
    else
      tokens[token] = 1
    end
  end
  
  tokens
end
