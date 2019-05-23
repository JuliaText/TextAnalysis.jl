## Creating a Document Term Matrix

Often we want to represent documents as a matrix of word counts so that we
can apply linear algebra operations and statistical techniques. Before
we do this, we need to update the lexicon:

```julia
julia> crps = Corpus([StringDocument("To be or not to be"),
                             StringDocument("To become or not to become")])

julia> update_lexicon!(crps)

julia> m = DocumentTermMatrix(crps)
A 2 X 6 DocumentTermMatrix
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

    tf(dtm)

The paramter, `dtm` can be of the types - `DocumentTermMatrix` , `SparseMatrixCSC` or `Matrix`

```julia
julia> crps = Corpus([StringDocument("To be or not to be"),
              StringDocument("To become or not to become")])

julia> update_lexicon!(crps)

julia> m = DocumentTermMatrix(crps)

julia> tf(m)
2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:
  [1, 1]  =  0.166667
  [2, 1]  =  0.166667
  [1, 2]  =  0.333333
  [2, 3]  =  0.333333
  [1, 4]  =  0.166667
  [2, 4]  =  0.166667
  [1, 5]  =  0.166667
  [2, 5]  =  0.166667
  [1, 6]  =  0.166667
  [2, 6]  =  0.166667
```

## TF-IDF (Term Frequency - Inverse Document Frequency)

    tf_idf(dtm)

In many cases, raw word counts are not appropriate for use because:

* (A) Some documents are longer than other documents
* (B) Some words are more frequent than other words

You can work around this by performing TF-IDF on a DocumentTermMatrix:

```julia
julia> crps = Corpus([StringDocument("To be or not to be"),
              StringDocument("To become or not to become")])

julia> update_lexicon!(crps)

julia> m = DocumentTermMatrix(crps)
DocumentTermMatrix(
  [1, 1]  =  1
  [2, 1]  =  1
  [1, 2]  =  2
  [2, 3]  =  2
  [1, 4]  =  1
  [2, 4]  =  1
  [1, 5]  =  1
  [2, 5]  =  1
  [1, 6]  =  1
  [2, 6]  =  1, ["To", "be", "become", "not", "or", "to"], Dict("or"=>5,"not"=>4,"to"=>6,"To"=>1,"be"=>2,"become"=>3))

julia> tf_idf(m)
2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:
  [1, 1]  =  0.0
  [2, 1]  =  0.0
  [1, 2]  =  0.231049
  [2, 3]  =  0.231049
  [1, 4]  =  0.0
  [2, 4]  =  0.0
  [1, 5]  =  0.0
  [2, 5]  =  0.0
  [1, 6]  =  0.0
  [2, 6]  =  0.0
```

As you can see, TF-IDF has the effect of inserting 0's into the columns of
words that occur in all documents. This is a useful way to avoid having to
remove those words during preprocessing.

## Sentiment Analyzer

It can be used to find the sentiment score (between 0 and 1) of a word, sentence or a Document.
A trained model (using Flux) on IMDB word corpus with weights saved are used to calculate the sentiments.

    model = SentimentAnalyzer(doc)
    model = SentimentAnalyzer(doc, handle_unknown)

*  doc              = Input Document for calculating document (AbstractDocument type)
*  handle_unknown   = A function for handling unknown words. Should return an array (default (x)->[])

## Summarizer

TextAnalysis offers a simple text-rank based summarizer for its various document types.

    summarize(d, ns)

It takes 2 arguments:

* `d` : A document of type `StringDocument`, `FileDocument` or `TokenDocument`
* `ns` : (Optional) Mention the number of sentences in the Summary, defaults to `5` sentences.

```julia
julia> s = StringDocument("Assume this Short Document as an example. Assume this as an example summarizer. This has too foo sentences.")

julia> summarize(s, ns=2)
2-element Array{SubString{String},1}:
 "Assume this Short Document as an example."
 "This has too foo sentences."
```
