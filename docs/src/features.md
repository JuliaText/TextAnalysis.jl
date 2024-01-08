## Creating a Document Term Matrix

Often we want to represent documents as a matrix of word counts so that we
can apply linear algebra operations and statistical techniques. Before
we do this, we need to update the lexicon:

```@repl
using TextAnalysis
crps = Corpus([StringDocument("To be or not to be"),
               StringDocument("To become or not to become")])
update_lexicon!(crps)
m = DocumentTermMatrix(crps)
```

A `DocumentTermMatrix` object is a special type. If you would like to use
a simple sparse matrix, call `dtm()` on this object:

```julia
julia> dtm(m)
2×6 SparseArrays.SparseMatrixCSC{Int64,Int64} with 10 stored entries:
  [1, 1]  =  1
  [2, 1]  =  1
  [1, 2]  =  2
  [2, 3]  =  2
  [1, 4]  =  1
  [2, 4]  =  1
  [1, 5]  =  1
  [2, 5]  =  1
  [1, 6]  =  1
  [2, 6]  =  1
```

If you would like to use a dense matrix instead, you can pass this as
an argument to the `dtm` function:

```julia
julia> dtm(m, :dense)
2×6 Array{Int64,2}:
 1  2  0  1  1  1
 1  0  2  1  1  1
```

## Creating Individual Rows of a Document Term Matrix

In many cases, we don't need the entire document term matrix at once: we can
make do with just a single row. You can get this using the `dtv` function.
Because individual's document do not have a lexicon associated with them, we
have to pass in a lexicon as an additional argument:

```julia
julia> dtv(crps[1], lexicon(crps))
1×6 Array{Int64,2}:
 1  2  0  1  1  1
```

## The Hash Trick

The need to create a lexicon before we can construct a document term matrix is often prohibitive. We can often employ a trick that has come to be called the
"Hash Trick" in which we replace terms with their hashed valued using a hash
function that outputs integers from 1 to N. To construct such a hash function,
you can use the `TextHashFunction(N)` constructor:

```julia
julia> h = TextHashFunction(10)
TextHashFunction(hash, 10)
```

You can see how this function maps strings to numbers by calling the
`index_hash` function:

```julia
julia> index_hash("a", h)
8

julia> index_hash("b", h)
7
```

Using a text hash function, we can represent a document as a vector with N
entries by calling the `hash_dtv` function:

```julia
julia> hash_dtv(crps[1], h)
1×10 Array{Int64,2}:
 0  2  0  0  1  3  0  0  0  0
```

This can be done for a corpus as a whole to construct a DTM without defining
a lexicon in advance:

```julia
julia> hash_dtm(crps, h)
2×10 Array{Int64,2}:
 0  2  0  0  1  3  0  0  0  0
 0  2  0  0  1  1  0  0  2  0
```

Every corpus has a hash function built-in, so this function can be called
using just one argument:

```julia
julia> hash_dtm(crps)
2×100 Array{Int64,2}:
 0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0
 0  0  0  0  0  0  0  0  2  0  0  0  0     0  0  0  0  0  0  0  0  0  0  0  0
```

Moreover, if you do not specify a hash function for just one row of the hash
DTM, a default hash function will be constructed for you:

```julia
julia> hash_dtv(crps[1])
1×100 Array{Int64,2}:
 0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0
```

## TF (Term Frequency)

Often we need to find out the proportion of a document is contributed
by each term. This can be done by finding the term frequency function

```@docs
tf
```

The parameter, `dtm` can be of the types - `DocumentTermMatrix` , `SparseMatrixCSC` or `Matrix`

```@repl
using TextAnalysis
crps = Corpus([StringDocument("To be or not to be"),
               StringDocument("To become or not to become")])
update_lexicon!(crps)
m = DocumentTermMatrix(crps)
tf(m)
```

## TF-IDF (Term Frequency - Inverse Document Frequency)

```@docs
tf_idf
```
In many cases, raw word counts are not appropriate for use because:

* (A) Some documents are longer than other documents
* (B) Some words are more frequent than other words

You can work around this by performing TF-IDF on a DocumentTermMatrix:

```@repl
using TextAnalysis
crps = Corpus([StringDocument("To be or not to be"),
               StringDocument("To become or not to become")])
update_lexicon!(crps)
m = DocumentTermMatrix(crps)
tf_idf(m)
```

As you can see, TF-IDF has the effect of inserting 0's into the columns of
words that occur in all documents. This is a useful way to avoid having to
remove those words during preprocessing.

## Okapi BM-25

From the document term matparamterix, [Okapi BM25](https://en.wikipedia.org/wiki/Okapi_BM25) document-word statistic can be created.

    bm_25(dtm::AbstractMatrix; κ, β)
    bm_25(dtm::DocumentTermMatrixm, κ, β)

It can also be used via the following methods Overwrite the `bm25` with calculated weights.

    bm_25!(dtm, bm25, κ, β)

The inputs matrices can also be a `Sparse Matrix`.
The parameters κ and β default to 2 and 0.75 respectively.

Here is an example usage -

```@repl
using TextAnalysis
crps = Corpus([
  StringDocument("a a a sample text text"), 
  StringDocument("another example example text text"), 
  StringDocument(""), 
  StringDocument("another another text text text text")
])
update_lexicon!(crps)
m = DocumentTermMatrix(crps)

bm_25(m)
```

## Co occurrence matrix (COOM)

The elements of the Co occurrence matrix indicate how many times two words co-occur
in a (sliding) word window of a given size.
The COOM can be calculated for objects of type `Corpus`,
`AbstractDocument` (with the exception of `NGramDocument`).

    CooMatrix(crps; window, normalize)
    CooMatrix(doc; window, normalize)

It takes following keyword arguments:

* `window::Integer` -length of the Window size, defaults to `5`. The actual size of the sliding window is 2 * window + 1, with the keyword argument window specifying how many words to consider to the left and right of the center one
* `normalize::Bool` -normalizes counts to distance between words, defaults to `true`

It returns the `CooMatrix` structure from which
the matrix can be extracted using `coom(::CooMatrix)`.
The `terms` can also be extracted from this.
Here is an example usage -

```@repl
using TextAnalysis
crps = Corpus([StringDocument("this is a string document")])
C = CooMatrix(crps, window=1, normalize=false)
coom(C)
C.terms
```

It can also be called to calculate the terms for
a specific list of words / terms in the document.
In other cases it calculates the the co occurrence elements
for all the terms.

    CooMatrix(crps, terms; window, normalize)
    CooMatrix(doc, terms; window, normalize)

```julia
julia> C = CooMatrix(crps, ["this", "is", "a"], window=1, normalize=false)
CooMatrix{Float64}(
  [2, 1]  =  4.0
  [1, 2]  =  4.0
  [3, 2]  =  4.0
  [2, 3]  =  4.0, ["this", "is", "a"], OrderedCollections.OrderedDict("this"=>1,"is"=>2,"a"=>3))

```

The type can also be specified for `CooMatrix`
with the weights of type `T`. `T` defaults to `Float64`.

    CooMatrix{T}(crps; window, normalize) where T <: AbstractFloat
    CooMatrix{T}(doc; window, normalize) where T <: AbstractFloat
    CooMatrix{T}(crps, terms; window, normalize) where T <: AbstractFloat
    CooMatrix{T}(doc, terms; window, normalize) where T <: AbstractFloat

Remarks:

* The sliding window used to count co-occurrences does not take into consideration sentence stops however, it does with documents i.e. does not span across documents
* The co-occurrence matrices of the documents in a corpus are summed up when calculating the matrix for an entire corpus

!!! note
    The Co occurrence matrix does not work for `NGramDocument`,
    or a Corpus containing an `NGramDocument`.

```julia
julia> C = CooMatrix(NGramDocument("A document"), window=1, normalize=false) # fails, documents are NGramDocument
ERROR: The tokens of an NGramDocument cannot be reconstructed
```

## Summarizer

TextAnalysis offers a simple text-rank based summarizer for its various document types.

```@docs
summarize
```