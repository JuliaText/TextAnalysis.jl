## LSA: Latent Semantic Analysis

Often we want to think about documents
from the perspective of semantic content.
One standard approach to doing this,
is to perform Latent Semantic Analysis or LSA on the corpus.
```@docs
lsa
```

lsa uses `tf_idf` for statistics.


```@repl
using TextAnalysis
crps = Corpus([
  StringDocument("this is a string document"),
  TokenDocument("this is a token document")
])
lsa(crps)
```
lsa can also be performed on a `DocumentTermMatrix`.
```@repl
using TextAnalysis
crps = Corpus([
  StringDocument("this is a string document"),
  TokenDocument("this is a token document")
]);
update_lexicon!(crps)

m = DocumentTermMatrix(crps)

lsa(m)
```


## LDA: Latent Dirichlet Allocation

Another way to get a handle on the semantic content of a corpus is to use
[Latent Dirichlet Allocation](https://en.wikipedia.org/wiki/Latent_Dirichlet_allocation):

First we need to produce the DocumentTermMatrix
```@docs
lda
```
```@repl
using TextAnalysis
crps = Corpus([
  StringDocument("This is the Foo Bar Document"),
  StringDocument("This document has too Foo words")
]);
update_lexicon!(crps)
m = DocumentTermMatrix(crps)

k = 2             # number of topics
iterations = 1000 # number of gibbs sampling iterations
α = 0.1           # hyper parameter
β  = 0.1          # hyper parameter

ϕ, θ  = lda(m, k, iterations, α, β);
ϕ
θ
```
See `?lda` for more help.
