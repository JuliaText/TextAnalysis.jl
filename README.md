TextAnalysis.jl
===============

# Preface

This manual is designed to get you started doing text analysis in Julia.
It assumes that you already familiar with the basic methods of text analysis
in order to present all of the available methods more quickly.

# Outline

* Installation
* Getting Started
* Creating Documents
    * StringDocument
    * FileDocument
    * TokenDocument
    * NGramDocument
* Basic Functions for Working with Documents
    * text
    * tokens
    * ngrams
* Document Metadata
    * language
    * name
    * author
    * timestamp
* Preprocessing Documents
    * Removing Corrupt UTF8
    * Removing Punctuation
    * Removing Case Distinctions
    * Removing Words
        * Stop Words
        * Articles
        * Indefinite Articles
        * Definite Articles
        * Prepositions
        * Pronouns
    * Stemming
    * Removing Rare Words
    * Removing Sparse Words
* Creating a Corpus
* Processing a Corpus
* Corpus Statistics
    * Lexicon
    * Inverse Index
* Creating a Document Term Matrix
* Creating Individual Rows of a Document Term Matrix
* The Hash Trick
    * Hashed DTV's
    * Hashed DTM's
* TF-IDF
* LSA: Latent Semantic Analysis
* LDA: Latent Dirichlet Allocation
* Extended Usage Example: Analyzing the State of the Union Addresses

# Installation

The TextAnalysis package can be installed using Julia's package manager:

    Pkg.add("TextAnalysis")

# Getting Started

In all of the examples that follow, we'll assume that you have the
TextAnalysis package fully loaded:

    using TextAnalysis

# Creating Documents

The basic unit of text analysis is a document. The TextAnalysis package
allows one to work with documents stored in a variety of formats:

* _StringDocument_: A document represented using a UTF8String stored in RAM
* _FileDocument_: A document represented using a plain text file on disk
* _TokenDocument_: A document represented as a sequence of UTF8 tokens
* _NGramDocument_: A document represented as a bag of n-grams

Creating these kind of documents is very easy when you already have the basic
data available:

    str = "To be or not to be..."
    sd = StringDocument(str)

    pathname = "/usr/share/dict/words"
    fd = FileDocument(pathname)

    my_tokens = ["To", "be", "or", "not", "to", "be..."]
    td = TokenDocument(my_tokens)

    my_ngrams = Dict{UTF8String,Int}()
    my_ngrams["To"] = 1
    my_ngrams["be"] = 2
    my_ngrams["or"] = 1
    my_ngrams["not"] = 1
    my_ngrams["to"] = 1
    my_ngrams["be..."] = 1
    ngd = NGramDocument(my_ngrams)

For every type of document except a `FileDocument`, you can also construct a
new document by simply passing in a string of text:

    sd = StringDocument("To be or not to be...")
    td = TokenDocument("To be or not to be...")
    ngd = NGramDocument("To be or not to be...")

The system will automatically perform tokenization or n-gramization in order
to produce the required data. Unfortunately, `FileDocument`'s cannot be
constructed this way because filenames are themselves strings. It would cause
chaos if filenames were treated as the text contents of a document.

That said, there is one way around this restriction: you can use the generic
`Document()` constructor function, which will guess at the type of the inputs
and construct the appropriate type of document object:

    Document("To be or not to be...")
    Document("/usr/share/dict/words")
    Document(["To", "be", "or", "not", "to", "be..."])
    ng = Dict{UTF8String,Int}()
    ng["a"] = 1
    ng["b"] = 3
    Document(ng)

# Basic Functions for Working with Documents

Once you've created a document object, you can work with it in many ways. The
most obvious thing is to access its text using the `text()` function:

    text(sd)

This function works without warnings on `StringDocument`'s and
`FileDocument`'s. For `TokenDocument`'s it is not possible to know if the
text can be reconstructed perfectly, so calling
`text(TokenDocument("This is text"))` will produce a warning message before
returning an approximate reconstruction of the text as it existed before
tokenization. It is entirely impossible to reconstruct the text of an
`NGramDocument`, so `text(NGramDocument("This is text"))` raises an error.

Instead of working with the text itself, you can work with the tokens or
n-grams of a document using the `tokens()` and `ngrams()` functions:

    tokens(sd)
    ngrams(sd)

By default the `ngrams()` function produces unigrams. If you would like to
produce bigrams or trigrams, you can specify that directly using a numeric
argument to the `ngrams()` function:

    ngrams(sd, 2)

If you have a `NGramDocument`, you can determine whether an `NGramDocument`
contains unigrams, bigrams or trigrams using the `ngram_complexity()` function:

    ngram_complexity(ngd)

This information is not available for other types of `Document` objects
because it is possible to produce any level of complexity when constructing
n-grams from raw text or tokens.

# Document Metadata

In addition to methods for manipulating the representation of the text of a
document, every document object also stores basic metadata about itself,
including the following pieces of information:

* `language()`: What language is the document in? Defaults to `EnglishLanguage`, a Language type defined by the Languages package.
* `name()`: What is the name of the document? Defaults to `"Unnamed Document"`.
* `author()`: Who wrote the document? Defaults to `"Unknown Author"`.
* `timestamp()`: When was the document written? Defaults to `"Unknown Time"`.

Try these functions out on a `StringDocument` to see how the defaults work
in practice:

    language(sd)
    name(sd)
    author(sd)
    timestamp(sd)

If you need reset these fields, you can use the mutating versions of the same
functions:

    language!(sd, TextAnalysis.Languages.SpanishLanguage)
    name!(sd, "El Cid")
    author!(sd, "Desconocido")
    timestamp!(sd, "Desconocido")

# Preprocessing Documents

Having easy access to the text of a document and its metadata is very
important, but most text analysis tasks require some amount of preprocessing.

At a minimum, your text source may contain corrupt characters. You can remove
these using the `remove_corrupt_utf8!()` function:

    remove_corrupt_utf8!(sd)

Alternatively, you may want to edit the text to remove items that are hard
to process automatically. For example, our sample text sentence taken from Hamlet
has three periods that we might like to discard. We can remove this kind of
punctuation using the `remove_punctuation!()` function:

    remove_punctuation!(sd)

Like punctuation, numbers and case distinctions are often easier removed than
dealt with. To remove numbers or case distinctions, use the
`remove_numbers!()` and `remove_case!()` functions:

    remove_numbers!(sd)
    remove_case!(sd)

At times you'll want to remove specific words from a document like a person's
name. To do that, use the `remove_words!()` function:

    sd = StringDocument("Lear is mad")
    remove_words!(sd, ["Lear"])

At other times, you'll want to remove whole classes of words. To make this
easier, we can use several classes of basic words defined by the Languages.jl
package:

* _Articles_: "a", "an", "the"
* _Indefinite Articles_: "a", "an"
* _Definite Articles_: "the"
* _Prepositions_: "across", "around", "before", ...
* _Pronouns_: "I", "you", "he", "she", ...
* _Stop Words_: "all", "almost", "alone", ...

These special classes can all be removed using specially-named functions:

* `remove_articles!()`
* `remove_indefinite_articles!()`
* `remove_definite_articles!()`
* `remove_prepositions!()`
* `remove_pronouns!()`
* `remove_stop_words!()`

These functions use words lists, so they are capable of working for many
different languages without change:

    remove_articles!(sd)
    remove_indefinite_articles!(sd)
    remove_definite_articles!(sd)
    remove_prepositions!(sd)
    remove_pronouns!(sd)
    remove_stop_words!(sd)

In addition to removing words, it is also common to take words that are
closely related like "dog" and "dogs" and stem them in order to produce a
smaller set of words for analysis. We can do this using the `stem!()`
function:

    stem!(sd)

# Creating a Corpus

Working with isolated documents gets boring quickly. We typically want to
work with a collection of documents. We represent collections of documents
using the Corpus type:

    crps = Corpus({StringDocument("Document 1"),
                   StringDocument("Document 2")})

# Standardizing a Corpus

A `Corpus` may contain many different types of `Document` objects:

    crps = Corpus({StringDocument("Document 1"),
                   TokenDocument("Document 2"),
                   NGramDocument("Document 3")})

# Processing a Corpus

We can apply the same sort of preprocessing steps that are defined for
individual documents to an entire corpus at once:

    crps = Corpus({StringDocument("Document 1"),
                   StringDocument("Document 2")})
    remove_punctuation!(crps)

# Corpus Statistics

Often we wish to think broadly about properties of an entire corpus at once.
In particular, we want to work with two constructs:

* _Lexicon_: The lexicon of a corpus consists of all the terms that occur in any document in the corpus. The lexical frequency of a term tells us how often a term occurs across all of the documents. Often the most interesting words in a document are those words whose frequency within a document is higher than their frequency in the corpus as a whole.
* _Inverse Index_: If we are interested in a specific term, we often want to know which documents in a corpus contain that term. The inverse index tells us this and therefore provides a simplistic sort of search algorithm.

Because computations involving the lexicon can take a long time, a
`Corpus`'s default lexicon is blank:

    lexicon(crps)

In order to work with the lexicon, you have to update it and then access it:

    update_lexicon!(crps)
    lexicon(crps)

But once this work is done, you can easier address lots of interesting
questions about a corpus:

    lexical_frequency(crps, "Summer")
    lexical_frequency(crps, "Document")

Like the lexicon, the inverse index for a corpus is blank by default:

    inverse_index(crps)

Again, you need to update it before you can work with it:

    update_inverse_index!(crps)
    inverse_index(crps)

But once you've updated the inverse index, you can easily search the entire
corpus:

    crps["Document"]
    crps["1"]
    crps["Summer"]

# Creating a DataFrame from a Corpus

Sometimes we want to apply non-text specific data analysis operations to a
corpus. The easiest way to do this is to transform a `Corpus` object into
a `DataFrame`:

    DataFrame(Corpus)

# Creating a Document Term Matrix

    m = DocumentTermMatrix(crps)
    dtm(m)
    dtm(m, :dense)

# Creating Individual Rows of a Document Term Matrix

    dtv(crps[1], lexicon(crps))

# The Hash Trick

    hash_dtm(crps)
    hash_dtv(crps[1])
    hash_dtv(crps[1], TextHashFunction(10))

# TF-IDF

    m = DocumentTermMatrix(crps)
    tf_idf!(m)

# LSA: Latent Semantic Indexing

    lsa(crps)

# LDA: Latent Dirichlet Analysis

    lda(crps)

# Extended Usage Example

To show you how text analysis might work in practice, we're going to work with
a text corpus composed of political speeches from American presidents given
as part of the State of the Union Address tradition.

    TODO: FILL IN
