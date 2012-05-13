# Text Analysis in Julia

Using this package, you can:

* Create a corpus from a directory of text files.
* Create a document-term matrix from a corpus.
* Perform LDA on a document-term matrix.

# Usage Examples

## Analysis of a Corpus of State of the Union Addresses
Here, we create a document-term matrix for all of the State of the Union (SOTU) addresses on record and then compute correlations betweens rows in this matrix to see which SOTU adddresses are most similar to each other:

    load("src/init.jl")
    
    corpus = generate_corpus("data/sotu")
    
    dtm = generate_dtm(corpus)

    similarity_matrix = cor(dtm.dtm')

## LDA Analysis of a Simulated Corpus

Here, we use a random number generator to create an artificial corpus of 50 documents according to the LDA generative model. We then use this simulated corpus to infer the parameters of our generative model as a way to test our estimation strategy's accuracy:

    load("src/init.jl")
    
    xi = 1000.0
    alpha = [0.01, 0.01]
    beta = [0.45 0.05 0.05 0.45; 0.05 0.45 0.45 0.05;]
    
    (document_theta, document) = generate_document(xi, alpha, beta)
    
    (theta, corpus) = generate_corpus(50, xi, alpha, beta)
    
    (inferred_theta, inferred_beta) = lda(corpus, 2, 20, true)
    
    mean(abs(beta - inferred_beta))
    mean(round(theta) != round(inferred_theta), 1)
