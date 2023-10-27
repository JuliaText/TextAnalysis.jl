## Creating a Corpus

Working with isolated documents gets boring quickly. We typically want to
work with a collection of documents. We represent collections of documents
using the Corpus type:
```@docs
Corpus
```

## Standardizing a Corpus

A `Corpus` may contain many different types of documents. It is generally more convenient to standardize all of the documents in a
corpus using a single type. This can be done using the `standardize!`
function:

```@docs
standardize!
```

## Processing a Corpus

We can apply the same sort of preprocessing steps that are defined for
individual documents to an entire corpus at once:

```@repl
using TextAnalysis
crps = Corpus([StringDocument("Document ..!!"),
               StringDocument("Document ..!!")])
prepare!(crps, strip_punctuation)
text(crps[1])
text(crps[2])
```

These operations are run on each document in the corpus individually.

## Corpus Statistics

Often we wish to think broadly about properties of an entire corpus at once.
In particular, we want to work with two constructs:

* _Lexicon_: The lexicon of a corpus consists of all the terms that occur in any document in the corpus. The lexical frequency of a term tells us how often a term occurs across all of the documents. Often the most interesting words in a document are those words whose frequency within a document is higher than their frequency in the corpus as a whole.
* _Inverse Index_: If we are interested in a specific term, we often want to know which documents in a corpus contain that term. The inverse index tells us this and therefore provides a simplistic sort of search algorithm.

Because computations involving the lexicon can take a long time, a
`Corpus`'s default lexicon is blank:

```julia
julia> crps = Corpus([StringDocument("Name Foo"),
                          StringDocument("Name Bar")])
julia> lexicon(crps)
Dict{String,Int64} with 0 entries
```

In order to work with the lexicon, you have to update it and then access it:

```julia
julia> update_lexicon!(crps)

julia> lexicon(crps)
Dict{String,Int64} with 3 entries:
  "Bar"    => 1
  "Foo"    => 1
  "Name" => 2
```

But once this work is done, you can easier address lots of interesting
questions about a corpus:
```julia
julia> lexical_frequency(crps, "Name")
0.5

julia> lexical_frequency(crps, "Foo")
0.25
```

Like the lexicon, the inverse index for a corpus is blank by default:

```julia
julia> inverse_index(crps)
Dict{String,Array{Int64,1}} with 0 entries
```

Again, you need to update it before you can work with it:

```julia
julia> update_inverse_index!(crps)

julia> inverse_index(crps)
Dict{String,Array{Int64,1}} with 3 entries:
  "Bar"    => [2]
  "Foo"    => [1]
  "Name" => [1, 2]
```

But once you've updated the inverse index, you can easily search the entire
corpus:

```julia
julia> crps["Name"]

2-element Array{Int64,1}:
 1
 2

julia> crps["Foo"]
1-element Array{Int64,1}:
 1

julia> crps["Summer"]
0-element Array{Int64,1}
```

## Converting a DataFrame from a Corpus

Sometimes we want to apply non-text specific data analysis operations to a
corpus. The easiest way to do this is to convert a `Corpus` object into
a `DataFrame`:

    convert(DataFrame, crps)

## Corpus Metadata

You can also retrieve the metadata for every document in a `Corpus` at once:

* `languages()`: What language is the document in? Defaults to `Languages.English()`, a Language instance defined by the Languages package.
* `titles()`: What is the title of the document? Defaults to `"Untitled Document"`.
* `authors()`: Who wrote the document? Defaults to `"Unknown Author"`.
* `timestamps()`: When was the document written? Defaults to `"Unknown Time"`.

```julia
julia> crps = Corpus([StringDocument("Name Foo"),
                                 StringDocument("Name Bar")])

julia> languages(crps)
2-element Array{Languages.English,1}:
 Languages.English()
 Languages.English()

julia> titles(crps)
2-element Array{String,1}:
 "Untitled Document"
 "Untitled Document"

julia> authors(crps)
2-element Array{String,1}:
 "Unknown Author"
 "Unknown Author"

julia> timestamps(crps)
2-element Array{String,1}:
 "Unknown Time"
 "Unknown Time"
```

It is possible to change the metadata fields for each document in a `Corpus`.
These functions use the same metadata value for every document:

```julia
julia> languages!(crps, Languages.German())
julia> titles!(crps, "")
julia> authors!(crps, "Me")
julia> timestamps!(crps, "Now")
```
Additionally, you can specify the metadata fields for each document in
a `Corpus` individually:

```julia
julia> languages!(crps, [Languages.German(), Languages.English
julia> titles!(crps, ["", "Untitled"])
julia> authors!(crps, ["Ich", "You"])
julia> timestamps!(crps, ["Unbekannt", "2018"])
```
