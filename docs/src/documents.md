## Creating Documents

The basic unit of text analysis is a document. The TextAnalysis package
allows one to work with documents stored in a variety of formats:

* _FileDocument_ : A document represented using a plain text file on disk
* _StringDocument_ : A document represented using a UTF8 String stored in RAM
* _TokenDocument_ : A document represented as a sequence of UTF8 tokens
* _NGramDocument_ : A document represented as a bag of n-grams, which are UTF8 n-grams that map to counts

!!! note
    These formats represent a hierarchy: you can always move down the hierarchy, but can generally not move up the hierarchy. A `FileDocument` can easily become a `StringDocument`, but an `NGramDocument` cannot easily become a `FileDocument`.

Creating any of the four basic types of documents is very easy:

```@docs
StringDocument
FileDocument
TokenDocument
NGramDocument
```

An NGramDocument consisting of bigrams or any higher order representation `N`
can be easily created by passing the parameter `N` to `NGramDocument`

```@repl
using TextAnalysis
NGramDocument("To be or not to be ...", 2)
```

For every type of document except a `FileDocument`, you can also construct a
new document by simply passing in a string of text:

```@repl
using TextAnalysis
sd = StringDocument("To be or not to be...")
td = TokenDocument("To be or not to be...")
ngd = NGramDocument("To be or not to be...")
```

The system will automatically perform tokenization or n-gramization in order
to produce the required data. Unfortunately, `FileDocument`'s cannot be
constructed this way because filenames are themselves strings. It would cause
chaos if filenames were treated as the text contents of a document.

That said, there is one way around this restriction: you can use the generic
`Document()` constructor function, which will guess at the type of the inputs
and construct the appropriate type of document object:

```julia
julia> Document("To be or not to be...")
A StringDocument{String}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: To be or not to be...
julia> Document("/usr/share/dict/words")
A FileDocument
 * Language: Languages.English()
 * Title: /usr/share/dict/words
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: A A's AMD AMD's AOL AOL's Aachen Aachen's Aaliyah

julia> Document(String["To", "be", "or", "not", "to", "be..."])
A TokenDocument{String}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: ***SAMPLE TEXT NOT AVAILABLE***

julia> Document(Dict{String, Int}("a" => 1, "b" => 3))
A NGramDocument{AbstractString}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: ***SAMPLE TEXT NOT AVAILABLE***
```

This constructor is very convenient for working in the REPL, but should be avoided in permanent code because, unlike the other constructors, the return type of the `Document` function cannot be known at compile-time.

## Basic Functions for Working with Documents

Once you've created a document object, you can work with it in many ways. The
most obvious thing is to access its text using the `text()` function:

```@repl
using TextAnalysis
sd = StringDocument("To be or not to be...");
text(sd)
```

!!! note
    This function works without warnings on `StringDocument`'s and
    `FileDocument`'s. For `TokenDocument`'s it is not possible to know if the
    text can be reconstructed perfectly, so calling
    `text(TokenDocument("This is text"))` will produce a warning message before
    returning an approximate reconstruction of the text as it existed before
    tokenization. It is entirely impossible to reconstruct the text of an
    `NGramDocument`, so `text(NGramDocument("This is text"))` raises an error.

Instead of working with the text itself, you can work with the tokens or
n-grams of a document using the `tokens()` and `ngrams()` functions:

```@repl
using TextAnalysis
sd = StringDocument("To be or not to be...");
tokens(sd)
ngrams(sd)
```

By default the `ngrams()` function produces unigrams. If you would like to
produce bigrams or trigrams, you can specify that directly using a numeric
argument to the `ngrams()` function:

```@repl
using TextAnalysis
sd = StringDocument("To be or not to be...");
ngrams(sd, 2)
```

The `ngrams()` function can also be called with multiple arguments:

```@repl
using TextAnalysis
sd = StringDocument("To be or not to be...");
ngrams(sd, 2, 3)
```

If you have a `NGramDocument`, you can determine whether an `NGramDocument`
contains unigrams, bigrams or a higher-order representation using the `ngram_complexity()` function:

```@repl
using TextAnalysis
ngd = NGramDocument("To be or not to be ...", 2);
ngram_complexity(ngd)
```

This information is not available for other types of `Document` objects
because it is possible to produce any level of complexity when constructing
n-grams from raw text or tokens.

## Document Metadata

In addition to methods for manipulating the representation of the text of a
document, every document object also stores basic metadata about itself,
including the following pieces of information:

* `language()`: What language is the document in? Defaults to `Languages.English()`, a Language instance defined by the Languages package.
* `title()`: What is the title of the document? Defaults to `"Untitled Document"`.
* `author()`: Who wrote the document? Defaults to `"Unknown Author"`.
* `timestamp()`: When was the document written? Defaults to `"Unknown Time"`.

Try these functions out on a `StringDocument` to see how the defaults work
in practice:

```@repl
using TextAnalysis
sd = StringDocument("This document has too foo words")
language(sd)
title(sd)
author(sd)
timestamp(sd)
```

If you need reset these fields, you can use the mutating versions of the same
functions:

```@repl
using TextAnalysis, Languages
sd = StringDocument("This document has too foo words")
language!(sd, Languages.Spanish())
title!(sd, "El Cid")
author!(sd, "Desconocido")
timestamp!(sd, "Desconocido")
```

## Preprocessing Documents

Having easy access to the text of a document and its metadata is very
important, but most text analysis tasks require some amount of preprocessing.

At a minimum, your text source may contain corrupt characters. You can remove
these using the `remove_corrupt_utf8!()` function:

```@docs
remove_corrupt_utf8!
```

Alternatively, you may want to edit the text to remove items that are hard
to process automatically. For example, our sample text sentence taken from Hamlet
has three periods that we might like to discard. We can remove this kind of
punctuation using the `prepare!()` function:

```@repl
using TextAnalysis
str = StringDocument("here are some punctuations !!!...")
prepare!(str, strip_punctuation)
text(str)
```

* To remove case distinctions, use `remove_case!()` function:
* At times you'll want to remove specific words from a document like a person's
name. To do that, use the `remove_words!()` function:

```@repl
using TextAnalysis
sd = StringDocument("Lear is mad")
remove_case!(sd)
text(sd)
remove_words!(sd, ["lear"])
text(sd)
```

At other times, you'll want to remove whole classes of words. To make this
easier, we can use several classes of basic words defined by the Languages.jl
package:

* _Articles_ : "a", "an", "the"
* _Indefinite Articles_ : "a", "an"
* _Definite Articles_ : "the"
* _Prepositions_ : "across", "around", "before", ...
* _Pronouns_ : "I", "you", "he", "she", ...
* _Stop Words_ : "all", "almost", "alone", ...

These special classes can all be removed using specially-named parameters:

* `prepare!(sd, strip_articles)`
* `prepare!(sd, strip_indefinite_articles)`
* `prepare!(sd, strip_definite_articles)`
* `prepare!(sd, strip_prepositions)`
* `prepare!(sd, strip_pronouns)`
* `prepare!(sd, strip_stopwords)`
* `prepare!(sd, strip_numbers)`
* `prepare!(sd, strip_non_letters)`
* `prepare!(sd, strip_sparse_terms)`
* `prepare!(sd, strip_frequent_terms)`
* `prepare!(sd, strip_html_tags)`

These functions use words lists, so they are capable of working for many
different languages without change, also these operations can be combined
together for improved performance:

* `prepare!(sd, strip_articles| strip_numbers| strip_html_tags)`

In addition to removing words, it is also common to take words that are
closely related like "dog" and "dogs" and stem them in order to produce a
smaller set of words for analysis. We can do this using the `stem!()`
function:

```@repl
using TextAnalysis
sd = StringDocument("They write, it writes")
stem!(sd)
text(sd)
```
