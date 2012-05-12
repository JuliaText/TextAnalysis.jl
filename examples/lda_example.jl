# Create a sample corpus with known parameters
# Perform inference to estimate parameters
# Test accuracy of estimated parameters

load("src/init.jl")

# Average document is 1,000 words long
# There are 2 topics
# There are 4 possible words in the language
# Each document is mostly associated with one topic
# The two topics have largely non-overlapping word frequencies
xi = 1000.0
alpha = [0.01, 0.01]
beta = [0.45 0.05 0.05 0.45; 0.05 0.45 0.45 0.05;]

(theta, document) = generate_document(xi, alpha, beta)
(theta, corpus) = generate_corpus(50, xi, alpha, beta)

# Perform 20 Gibbs sampling sweeps
# Keep only final sample
# Monitor trace of inferred parameters
(inferred_theta, inferred_beta) = lda(corpus, 2, 20, true)

mean(abs(beta - inferred_beta))
sum(int(round(theta)) != int(round(inferred_theta)), 1)[1, 1] / size(corpus, 1)
