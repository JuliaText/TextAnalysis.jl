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

The parameter, `dtm` can be of the types - `DocumentTermMatrix` , `SparseMatrixCSC` or `Matrix`

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

## Okapi BM-25

From the document term matparamterix, [Okapi BM25](https://en.wikipedia.org/wiki/Okapi_BM25) document-word statistic can be created.

    bm_25(dtm::AbstractMatrix; κ, β)
    bm_25(dtm::DocumentTermMatrixm, κ, β)

It can also be used via the following methods Overwrite the `bm25` with calculated weights.

    bm_25!(dtm, bm25, κ, β)

The inputs matrices can also be a `Sparse Matrix`.
The parameters κ and β default to 2 and 0.75 respectively.

Here is an example usage -

```julia
julia> crps = Corpus([StringDocument("a a a sample text text"), StringDocument("another example example text text"), StringDocument(""), StringDocument("another another text text text text")])

julia> update_lexicon!(crps)

julia> m = DocumentTermMatrix(crps)

julia> bm_25(m)
4×5 SparseArrays.SparseMatrixCSC{Float64,Int64} with 8 stored entries:
  [1, 1]  =  1.29959
  [2, 2]  =  0.882404
  [4, 2]  =  1.40179
  [2, 3]  =  1.54025
  [1, 4]  =  1.89031
  [1, 5]  =  0.405067
  [2, 5]  =  0.405067
  [4, 5]  =  0.676646
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

```julia

julia> crps = Corpus([StringDocument("this is a string document"),

julia> C = CooMatrix(crps, window=1, normalize=false)
CooMatrix{Float64}(
  [2, 1]  =  2.0
  [6, 1]  =  2.0
  [1, 2]  =  2.0
  [3, 2]  =  2.0
  [2, 3]  =  2.0
  [6, 3]  =  2.0
  [5, 4]  =  4.0
  [4, 5]  =  4.0
  [6, 5]  =  4.0
  [1, 6]  =  2.0
  [3, 6]  =  2.0
  [5, 6]  =  4.0, ["string", "document", "token", "this", "is", "a"], OrderedDict("string"=>1,"document"=>2,"token"=>3,"this"=>4,"is"=>5,"a"=>6))

julia> coom(C)
6×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 12 stored entries:
  [2, 1]  =  2.0
  [6, 1]  =  2.0
  [1, 2]  =  2.0
  [3, 2]  =  2.0
  [2, 3]  =  2.0
  [6, 3]  =  2.0
  [5, 4]  =  4.0
  [4, 5]  =  4.0
  [6, 5]  =  4.0
  [1, 6]  =  2.0
  [3, 6]  =  2.0
  [5, 6]  =  4.0

julia> C.terms
6-element Array{String,1}:
 "string"
 "document"
 "token"
 "this"
 "is"
 "a"

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

## Tagging_schemes

There are many tagging schemes used for sequence labelling.
TextAnalysis currently offers functions for conversion between these tagging format.

*   BIO1
*   BIO2
*   BIOES

```julia
julia> tags = ["I-LOC", "O", "I-PER", "B-MISC", "I-MISC", "B-PER", "I-PER", "I-PER"]

julia> tag_scheme!(tags, "BIO1", "BIOES")

julia> tags
8-element Array{String,1}:
 "S-LOC"
 "O"
 "S-PER"
 "B-MISC"
 "E-MISC"
 "B-PER"
 "I-PER"
 "E-PER"
```

## Parts of Speech Tagger

This tagger can be used to find the POS tag of a word or token in a given sentence. It is a based on `Average Perceptron Algorithm`.
The model can be trained from scratch and weights are saved in specified location.
The pretrained model can also be loaded and can be used directly to predict tags.

### To train model:
```julia
julia> tagger = PerceptronTagger(false) #we can use tagger = PerceptronTagger()
julia> fit!(tagger, [[("today","NN"),("is","VBZ"),("good","JJ"),("day","NN")]])
iteration : 1
iteration : 2
iteration : 3
iteration : 4
iteration : 5
```

### To load pretrained model:
```julia
julia> tagger = PerceptronTagger(true)
loaded successfully
PerceptronTagger(AveragePerceptron(Set(Any["JJS", "NNP_VBZ", "NN_NNS", "CC", "NNP_NNS", "EX", "NNP_TO", "VBD_DT", "LS", ("Council", "NNP")  …  "NNPS", "NNP_LS", "VB", "NNS_NN", "NNP_SYM", "VBZ", "VBZ_JJ", "UH", "SYM", "NNP_NN", "CD"]), Dict{Any,Any}("i+2 word wetlands"=>Dict{Any,Any}("NNS"=>0.0,"JJ"=>0.0,"NN"=>0.0),"i-1 tag+i word NNP basic"=>Dict{Any,Any}("JJ"=>0.0,"IN"=>0.0),"i-1 tag+i word DT chloride"=>Dict{Any,Any}("JJ"=>0.0,"NN"=>0.0),"i-1 tag+i word NN choo"=>Dict{Any,Any}("NNP"=>0.0,"NN"=>0.0),"i+1 word antarctica"=>Dict{Any,Any}("FW"=>0.0,"NN"=>0.0),"i-1 tag+i word -START- appendix"=>Dict{Any,Any}("NNP"=>0.0,"NNPS"=>0.0,"NN"=>0.0),"i-1 word wahoo"=>Dict{Any,Any}("JJ"=>0.0,"VBD"=>0.0),"i-1 tag+i word DT children's"=>Dict{Any,Any}("NNS"=>0.0,"NN"=>0.0),"i word dnipropetrovsk"=>Dict{Any,Any}("NNP"=>0.003,"NN"=>-0.003),"i suffix hla"=>Dict{Any,Any}("JJ"=>0.0,"NN"=>0.0)…), DefaultDict{Any,Any,Int64}(), DefaultDict{Any,Any,Int64}(), 1, ["-START-", "-START2-"]), Dict{Any,Any}("is"=>"VBZ","at"=>"IN","a"=>"DT","and"=>"CC","for"=>"IN","by"=>"IN","Retrieved"=>"VBN","was"=>"VBD","He"=>"PRP","in"=>"IN"…), Set(Any["JJS", "NNP_VBZ", "NN_NNS", "CC", "NNP_NNS", "EX", "NNP_TO", "VBD_DT", "LS", ("Council", "NNP")  …  "NNPS", "NNP_LS", "VB", "NNS_NN", "NNP_SYM", "VBZ", "VBZ_JJ", "UH", "SYM", "NNP_NN", "CD"]), ["-START-", "-START2-"], ["-END-", "-END2-"], Any[])
```

### To predict tags:

The perceptron tagger can predict tags over various document types-

    predict(tagger, sentence::String)
    predict(tagger, Tokens::Array{String, 1})
    predict(tagger, sd::StringDocument)
    predict(tagger, fd::FileDocument)
    predict(tagger, td::TokenDocument)

This can also be done by -
    tagger(input)


```julia
julia> predict(tagger, ["today", "is"])
2-element Array{Any,1}:
 ("today", "NN")
 ("is", "VBZ")

julia> tagger(["today", "is"])
2-element Array{Any,1}:
 ("today", "NN")
 ("is", "VBZ")
```

`PerceptronTagger(load::Bool)`

* load      = Boolean argument if `true` then pretrained model is loaded

`fit!(self::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, save_loc::String, nr_iter::Integer)`

* self      = `PerceptronTagger` object
* sentences = `Vector` of `Vector` of `Tuple` of pair of word or token and its POS tag [see above example]
* save_loc  = location of file to save the trained weights
* nr_iter   = Number of iterations to pass the `sentences` to train the model ( default 5)

`predict(self::PerceptronTagger, tokens)`

* self      = PerceptronTagger
* tokens    = `Vector` of words or tokens for which to predict tags
