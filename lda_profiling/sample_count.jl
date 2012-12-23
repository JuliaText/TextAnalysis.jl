load("src/init.jl")

srand(1)

S = 5
N = 20

inference_quality = zeros(S * N, 4)

for iteration = 1:S
  for sample_count = 1:N
    index = (iteration - 1) * N + sample_count
    xi = 1000.0
    alpha = [0.01, 0.01]
    beta = [0.45 0.05 0.05 0.45; 0.05 0.45 0.45 0.05;]
    
    (document_theta, document) = generate_document(xi, alpha, beta)
    
    (theta, corpus) = generate_corpus(50, xi, alpha, beta)
  
    (inferred_theta, inferred_beta) = lda(corpus, 2, sample_count, false)
  
    inference_quality[index, 1] = iteration
    inference_quality[index, 2] = sample_count
    inference_quality[index, 3] = mean(abs(beta - inferred_beta))
    inference_quality[index, 4] = mean(round(theta) != round(inferred_theta), 1)[1, 1]
  end
end

csvwrite("lda_inference.csv", inference_quality)
