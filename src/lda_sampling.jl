function generate_document(xi::Number, alpha::Array{Float64, 1}, beta::Matrix{Float64})
  N = int(rpois(1, xi)[1])
  theta = rdirichlet(1, alpha)
  z = zeros(Int, N, length(theta))
  w = zeros(Int, N, size(beta, 2))
  for i = 1:N
    z[i, :] = rmultinom(1, reshape(theta', length(theta)))'
    w[i, :] = rmultinom(1, reshape(z[i, :] * beta, size(beta, 2)))'
  end
  document = sum(w, 1)
  (theta, document)
end

function generate_corpus(n::Integer, xi::Number, alpha::Array{Float64, 1}, beta::Matrix{Float64})
  theta = zeros(n, size(beta, 1))
  corpus = zeros(Int, n, size(beta, 2))
  for i = 1:n
    (document_theta, document) = generate_document(xi, alpha, beta)
    theta[i, :] = document_theta
    corpus[i, :] = document
  end
  (theta, corpus)
end
