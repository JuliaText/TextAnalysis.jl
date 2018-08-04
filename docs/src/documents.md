## Creating Documents

The basic unit of text analysis is a document. The TextAnalysis package
allows one to work with documents stored in a variety of formats:

* _FileDocument_ : A document represented using a plain text file on disk
* _StringDocument_ : A document represented using a UTF8 String stored in RAM
* _TokenDocument_ : A document represented as a sequence of UTF8 tokens
* _NGramDocument_ : A document represented as a bag of n-grams, which are UTF8 n-grams that map to counts

These format represent a hierarchy: you can always move down the hierachy, but can generally not move up the hierachy. A `FileDocument` can easily become a `StringDocument`, but an `NGramDocument` cannot easily become a `FileDocument`.

Creating any of the four basic types of documents is very easy:

    str = "To be or not to be..."
    sd = StringDocument(str)

    pathname = "/usr/share/dict/words"
    fd = FileDocument(pathname)

    my_tokens = String["To", "be", "or", "not", "to", "be..."]
    td = TokenDocument(my_tokens)

    my_ngrams = Dict{String, Int}("To" => 1, "be" => 2,
                                    "or" => 1, "not" => 1,
                                    "to" => 1, "be..." => 1)
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
    Document(String["To", "be", "or", "not", "to", "be..."])
    Document(Dict{String, Int}("a" => 1, "b" => 3))

This constructor is very convenient for working in the REPL, but should be avoided in permanent code because, unlike the other constructors, the return type of the `Document` function cannot be known at compile-time.

## Basic Functions for Working with Documents

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
contains unigrams, bigrams or a higher-order representation using the `ngram_complexity()` function:

    ngram_complexity(ngd)

This information is not available for other types of `Document` objects
because it is possible to produce any level of complexity when constructing
n-grams from raw text or tokens.

## Document Metadata

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

    language!(sd, Languages.SpanishLanguage)
    name!(sd, "El Cid")
    author!(sd, "Desconocido")
    timestamp!(sd, "Desconocido")

## Preprocessing Documents

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

* _Articles_ : "a", "an", "the"
* _Indefinite Articles_ : "a", "an"
* _Definite Articles_ : "the"
* _Prepositions_ : "across", "around", "before", ...
* _Pronouns_ : "I", "you", "he", "she", ...
* _Stop Words_ : "all", "almost", "alone", ...

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
