# Need to code up inference procedure.
# Gibbs
# Variational
# SVD

function expanded_representation(word_counts)
  result = []
  
  for i = 1:size(word_counts, 2)
    result = [result, repmat([i], word_counts[1, i], 1)]
  end
  
  result
end

function find_theta(document_topic_counts)
  theta = copy(document_topic_counts)
  theta = convert(Array{Float64,2}, theta)
  for i in 1:size(theta, 1)
    theta[i, :] = theta[i, :] ./ sum(theta[i, :])
  end
  theta
end

function find_beta(topic_term_counts)
  beta = copy(topic_term_counts)
  beta = convert(Array{Float64,2}, beta)
  for i in 1:size(beta, 1)
    beta[i, :] = beta[i, :] ./ sum(beta[i, :])
  end
  beta
end

# Gibbs Sampling Algorithm from Gregor Heinrich
function lda(corpus, k, max_iterations, trace_iterations)
  m = size(corpus, 1)
  l = size(corpus, 2)
  
  document_topic_counts = zeros(Int, m, k)
  topic_term_counts = zeros(Int, k, l)
  z = zeros(Int, m, max(sum(corpus, 2)))
  
  # Initialization
  # Represent topic as expanded number of entries for each word for ease.
  for document_index = 1:m
    n = sum(corpus, 2)[document_index]
    representation = expanded_representation(corpus[document_index, :])
    for word_index = 1:n
      t = representation[word_index]
      topic_index = find(rmultinom(1, ones(k) * 1 / k) == 1.0)[1]
      z[document_index, word_index] = topic_index
      document_topic_counts[document_index, topic_index] = document_topic_counts[document_index, topic_index] + 1
      topic_term_counts[topic_index, t] = topic_term_counts[topic_index, t] + 1
    end
  end

  # Perform specified number of Gibbs sampling sweeps.
  for iteration = 1:max_iterations
    for document_index = 1:m
      n = sum(corpus, 2)[document_index]
      representation = expanded_representation(corpus[document_index, :])
      for word_index = 1:n
        t = representation[word_index]
        topic_index = z[document_index, word_index]
        
        # Remove word from hidden variables.
        # There may be some problems with 0 count events.
        document_topic_counts[document_index, topic_index] = document_topic_counts[document_index, topic_index] - 1
        if document_topic_counts[document_index, topic_index] <= 0
          document_topic_counts[document_index, topic_index] = 0
        end      
        topic_term_counts[topic_index, t] = topic_term_counts[topic_index, t] - 1
        if topic_term_counts[topic_index, t] <= 0
          topic_term_counts[topic_index, t] = 0
        end
        
        theta = find_theta(document_topic_counts)
        
        p = reshape(theta[document_index, :], k)
        
        topic_index = find(rmultinom(1, p) == 1.0)[1]
        
        document_topic_counts[document_index, topic_index] = document_topic_counts[document_index, topic_index] + 1
        topic_term_counts[topic_index, t] = topic_term_counts[topic_index, t] + 1
      end
    end
    
    if trace_iterations
      println(strcat("theta = ", find_theta(document_topic_counts)))
      println()
      println(strcat("beta = ", find_beta(topic_term_counts)))
    end
  end
  
  (find_theta(document_topic_counts), find_beta(topic_term_counts))
end
