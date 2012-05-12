# Idea adapted from Stefan's comment on Doug Bates' blog.
# Should be able to use 1D array or 2D array with 1xN dim.
function rmultinom(n::Int, p::Array{Float64, 1})
  if any(p < 0)
    error("Negative probabilities not allowed")
  end
  l = size(p, 1)
  s = zeros(l)
  for i = 1:n
    r = rand()
    for j = 1:l
      r -= p[j]
      if r <= 0.0
        s[j] = s[j] + 1.0
        break
      end
    end
  end
  s
end

# Idea taken from R's MCMCpack rdirichlet function.
# Should be able to use 1D array or 2D array with 1xN dim.
function rdirichlet(n::Integer, alpha::Array{Float64, 1})
  l = length(alpha)
  x = zeros(n, l)
  for i = 1:n
    for j = 1:l
      x[i, j] = rgamma(1, alpha[j])[1]
    end
    x[i, :] = x[i, :] ./ sum(x[i, :])
  end
  x
end
