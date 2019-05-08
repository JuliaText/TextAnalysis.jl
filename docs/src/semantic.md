## LSA: Latent Semantic Analysis

Often we want to think about documents from the perspective of semantic
content. One standard approach to doing this is to perform Latent Semantic
Analysis or LSA on the corpus. You can do this using the `lsa` function:

    lsa(crps)

## LDA: Latent Dirichlet Allocation

Another way to get a handle on the semantic content of a corpus is to use
[Latent Dirichlet Allocation](https://en.wikipedia.org/wiki/Latent_Dirichlet_allocation):

First we need to produce the DocumentTermMatrix
```julia
julia> crps = Corpus([StringDocument("This is the Foo Bar Document"), StringDocument("This document has too Foo words")])
julia> update_lexicon!(crps)
julia> m = DocumentTermMatrix(crps)
```

Latent Dirchlet Allocation has two hyper parameters -
* _α_ : The hyperparameter for topic distribution per document. `α<1` yields a sparse topic mixture for each document. `α>1` yields a more uniform topic mixture for each document.
- _β_ : The hyperparameter for word distribution per topic. `β<1` yields a sparse word mixture for each topic. `β>1` yields a more uniform word mixture for each topic.

```julia
julia> k = 2            # number of topics
julia> iterations = 1000 # number of gibbs sampling iterations

julia> α = 0.1      # hyper parameter
julia> β  = 0.1       # hyper parameter

julia> ϕ, θ  = lda(m, k, iterations, α, β)
(
  [2 ,  1]  =  0.333333
  [2 ,  2]  =  0.333333
  [1 ,  3]  =  0.222222
  [1 ,  4]  =  0.222222
  [1 ,  5]  =  0.111111
  [1 ,  6]  =  0.111111
  [1 ,  7]  =  0.111111
  [2 ,  8]  =  0.333333
  [1 ,  9]  =  0.111111
  [1 , 10]  =  0.111111, [0.5 1.0; 0.5 0.0])
```
See `?lda` for more help.
