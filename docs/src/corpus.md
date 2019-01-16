## Creating a Corpus

Working with isolated documents gets boring quickly. We typically want to
work with a collection of documents. We represent collections of documents
using the Corpus type:

    crps = Corpus([StringDocument("Document 1"),
                   StringDocument("Document 2")])

## Standardizing a Corpus

A `Corpus` may contain many different types of documents:

    crps = Corpus([StringDocument("Document 1"),
                   TokenDocument("Document 2"),
                   NGramDocument("Document 3")])

It is generally more convenient to standardize all of the documents in a
corpus using a single type. This can be done using the `standardize!`
function:

    standardize!(crps, NGramDocument)

After this step, you can check that the corpus only contains `NGramDocument`'s:

    crps

## Processing a Corpus

We can apply the same sort of preprocessing steps that are defined for
individual documents to an entire corpus at once:

    crps = Corpus([StringDocument("Document 1"),
                   StringDocument("Document 2")])
    remove_punctuation!(crps)

These operations are run on each document in the corpus individually.

## Corpus Statistics

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

## Converting a DataFrame from a Corpus

Sometimes we want to apply non-text specific data analysis operations to a
corpus. The easiest way to do this is to convert a `Corpus` object into
a `DataFrame`:

    convert(DataFrame, crps)
