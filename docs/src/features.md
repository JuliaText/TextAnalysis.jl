## Creating a Document Term Matrix

Often we want to represent documents as a matrix of word counts so that we
can apply linear algebra operations and statistical techniques. Before
we do this, we need to update the lexicon:

    update_lexicon!(crps)
    m = DocumentTermMatrix(crps)

A `DocumentTermMatrix` object is a special type. If you would like to use
a simple sparse matrix, call `dtm()` on this object:

    dtm(m)

If you would like to use a dense matrix instead, you can pass this as
an argument to the `dtm` function:

    dtm(m, :dense)

## Creating Individual Rows of a Document Term Matrix

In many cases, we don't need the entire document term matrix at once: we can
make do with just a single row. You can get this using the `dtv` function.
Because individual's document do not have a lexicon associated with them, we
have to pass in a lexicon as an additional argument:

    dtv(crps[1], lexicon(crps))

## The Hash Trick

The need to create a lexicon before we can construct a document term matrix is often prohibitive. We can often employ a trick that has come to be called the
"Hash Trick" in which we replace terms with their hashed valued using a hash
function that outputs integers from 1 to N. To construct such a hash function,
you can use the `TextHashFunction(N)` constructor:

    h = TextHashFunction(10)

You can see how this function maps strings to numbers by calling the
`index_hash` function:

    index_hash("a", h)
    index_hash("b", h)

Using a text hash function, we can represent a document as a vector with N
entries by calling the `hash_dtv` function:

    hash_dtv(crps[1], h)

This can be done for a corpus as a whole to construct a DTM without defining
a lexicon in advance:

    hash_dtm(crps, h)

Every corpus has a hash function built-in, so this function can be called
using just one argument:

    hash_dtm(crps)

Moreover, if you do not specify a hash function for just one row of the hash
DTM, a default hash function will be constructed for you:

    hash_dtv(crps[1])

## TF-IDF

In many cases, raw word counts are not appropriate for use because:

* (A) Some documents are longer than other documents
* (B) Some words are more frequent than other words

You can work around this by performing TF-IDF on a DocumentTermMatrix:

    m = DocumentTermMatrix(crps)
    tf_idf(m)

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
 
