type DocumentTermMatrix
  terms::Dict
  counts::Array{Int64,2}
end

function DocumentTermMatrix()
  DocumentTermMatrix(Dict(), zeros(Int64, 0, 0))
end

function DocumentTermMatrix(n_gram_corpus::NGramCorpus)
  aggregate_terms = map(x -> keys(x.tokens), n_gram_corpus.n_gram_documents)
  convert(Array{String}, aggregate_terms)
  all_terms = reduce(push, aggregate_terms)
  # Hack to get uniques.
  terms_dict = Dict()
  for term in sort(all_terms)
    terms_dict[term] = 0
  end
  sorted_terms = sort(keys(terms_dict))
  
  # Create a map from keys(all_terms) into ordered set of natural numbers.
  mapping = Dict()
  for i = 1:length(sorted_terms)
    mapping[sorted_terms[i]] = i
  end
  
  # Create a (sparse?) matrix that as many rows as the corpus has documents
  # and as many columns as the corpus has terms. Then insert entries into
  # this matrix for every document.
  n = length(n_gram_corpus.n_gram_documents)
  m = length(sorted_terms)
  counts = zeros(Int, n, m)
  
  for i = 1:n
    for token in n_gram_corpus.n_gram_documents[i].tokens
      j = mapping[token[1]]
      counts[i, j] = token[2]
    end
  end
  
  DocumentTermMatrix(mapping, counts)
end

function DocumentTermMatrix(corpus::Corpus)
  DocumentTermMatrix(NGramCorpus(corpus))
end

function term_frequencies(dtm::DocumentTermMatrix)
  sum(int(dtm.counts > 0), 1) / size(dtm.counts, 1)
end

# This breaks with dtm.terms change. Perhaps change isn't worth it.
function remove_infrequent_terms(dtm::DocumentTermMatrix, alpha::Float64)
  frequent_term_indices = find(term_frequencies(dtm) > alpha)
  frequent_term_keys = find_keys_with_values(frequent_term_indices)
  dtm.terms = dtm.terms[frequent_term_indices]
  dtm.counts = dtm.counts[:, frequent_term_indices]
end

function remove_infrequent_terms(dtm::DocumentTermMatrix)
  n = size(dtm.counts, 1)
  alpha = 1.0 / float(n)
  remove_infrequent_terms(dtm, alpha)
end

function remove_frequent_terms(dtm::DocumentTermMatrix, alpha::Float64)
  infrequent_term_indices = find(term_frequencies(dtm) <= alpha)
  dtm.terms = dtm.terms[infrequent_term_indices]
  dtm.counts = dtm.counts[:, infrequent_term_indices]
end

function remove_frequent_terms(dtm::DocumentTermMatrix)
  n = size(dtm.counts, 1)
  alpha = float(n - 1) / float(n)
  remove_frequent_terms(dtm, alpha)
end

function tf_idf(dtm::DocumentTermMatrix)
  tf = zeros(Float64, size(dtm.counts))
  for i in 1:size(dtm.counts, 1)
    tf[i, :] = dtm.counts[i, :] ./ sum(dtm.counts, 2)[i]
  end

  idf = log(size(dtm.counts, 1) / sum(dtm.counts > 0, 1))

  # Store TF-IDF in TF matrix to save space.
  for i in 1:size(dtm.counts, 1)
    for j in 1:size(dtm.counts, 2)
      tf[i, j] = tf[i, j] * idf[1, j]
    end
  end
  
  tf
end

function print(dtm::DocumentTermMatrix)
  println("DocumentTermMatrix:")
  println("  Terms: $(length(keys(dtm.terms)))")
  println("  Documents: $(size(dtm.counts, 1))")
end

function show(dtm::DocumentTermMatrix)
  print(dtm)
end

function ref(dtm::DocumentTermMatrix, i::Int, j::Int)
  dtm.counts[i, j]
end

# Add ref(dtm::DocumentTermMatrix, i::Int, term::Any) that looks up j in dtm.terms, then calls previous ref().

function add_document(dtm::DocumentTermMatrix, doc::Document)
  add_document(dtm, NGramDocument(doc))
end

function add_document(dtm::Document, doc::NGramDocument)
  i = size(dtm.counts, 1) + 1
  for token in keys(doc.tokens)
    if has(dtm.terms, token)
      j = dtm.terms[token]
      dtm.counts[i, j] = doc.tokens[token]
    else
      j = size(dtm.counts, 2) + 1
      dtm.terms[token] = j
      dtm.counts[i, j] = doc.tokens[token]
    end
  end
end
