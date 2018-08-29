## LSA: Latent Semantic Analysis

Often we want to think about documents from the perspective of semantic
content. One standard approach to doing this is to perform Latent Semantic
Analysis or LSA on the corpus. You can do this using the `lsa` function:

    lsa(crps)

## LDA: Latent Dirichlet Allocation

Another way to get a handle on the semantic content of a corpus is to use
[Latent Dirichlet Allocation](https://en.wikipedia.org/wiki/Latent_Dirichlet_allocation):

    m = DocumentTermMatrix(crps)
    k = 2            # number of topics
    iteration = 1000 # number of gibbs sampling iterations
    alpha = 0.1      # hyper parameter
    beta  = 0.1       # hyber parameter
    ϕ, θ  = lda(m, k, iteration, alpha, beta) # ϕ is k x word matrix.
                                              # value is probablity of occurrence of a word in a topic.
See `?lda` for more help.
