# Human tests, not automated tests.

load("src/init.jl")

#
# From src/tokenize.jl
#

sample_text = "this is some sample text"
tokenize(sample_text, 1)
tokenize(sample_text, 2)
tokenize(sample_text, 3)

#
# From src/document.jl
#

document = Document("", "", "", "")
document = Document()
document = Document("data/sotu/0001.txt")

remove_words(document, ["government"])
document.text

remove_numbers(document)
document.text

remove_punctuation(document)
document.text

remove_case(document)
document.text

#
# From src/n_gram_document.jl
#

sample_text = "this is some sample text"
n_gram_document = NGramDocument(1, tokenize(sample_text, 1))
n_gram_document = NGramDocument(1)
n_gram_document = NGramDocument()

n_gram_document = NGramDocument(1, tokenize(sample_text, 1))

remove_words(n_gram_document, ["this"])
n_gram_document.tokens

document = Document("data/sotu/0001.txt")
to_n_gram_document(1, document)

document = Document("data/sotu/0001.txt")
to_n_gram_document(document)

#
# src/corpus.jl
#

document = Document("data/sotu/0001.txt")
corpus = Corpus([document])
corpus.documents

corpus = Corpus()
corpus.documents
document = Document("data/sotu/0001.txt")
add_document(corpus, document)
corpus.documents
remove_document(corpus, document)
corpus.documents

filenames = convert(Array{String,1},
                    map(x -> strcat("data/mini/", chomp(x)),
                        readlines(`ls data/mini`)))
corpus = Corpus(filenames)
corpus.documents

# This doesn't work because no dir() exists yet.
#corpus = Corpus("data/mini")

corpus = Corpus(["data/sotu/0001.txt", "data/sotu/0002.txt"])
corpus.documents
remove_words(corpus, ["a"])
corpus.documents[1]
remove_numbers(corpus)
corpus.documents[1]
remove_punctuation(corpus)
corpus.documents[1]
remove_case(corpus)
corpus.documents[1]

#
# From src/n_gram_corpus.jl
#

document = Document("data/sotu/0001.txt")
n_gram_document = to_n_gram_document(document)
n_gram_corpus = NGramCorpus([n_gram_document])
n_gram_corpus.n_gram_documents[1]

n_gram_corpus = NGramCorpus()

document = Document("data/sotu/0001.txt")
n_gram_corpus = NGramCorpus([document])
n_gram_corpus.n_gram_documents[1]

n_gram_corpus = NGramCorpus()
document = Document("data/sotu/0001.txt")
n_gram_document = to_n_gram_document(document)
add_document(n_gram_corpus, n_gram_document)
n_gram_corpus.n_gram_documents[1]
remove_document(n_gram_corpus, n_gram_document)
n_gram_corpus.n_gram_documents
add_document(n_gram_corpus, n_gram_document)
n_gram_corpus.n_gram_documents[1]
n_gram_corpus.n_gram_documents[1].tokens["a"]
remove_words(n_gram_corpus, ["a"])
n_gram_corpus.n_gram_documents[1].tokens["a"]

corpus = Corpus(["data/sotu/0001.txt", "data/sotu/0002.txt"])
to_n_gram_corpus(corpus)

#
# From src/document_term_matrix.jl
#

tokens = {"one", "two"}
counts = zeros(Int, 2, 2)
dtm = DocumentTermMatrix(tokens, counts)

dtm = DocumentTermMatrix()

n_gram_corpus = NGramCorpus()
add_document(n_gram_corpus, to_n_gram_document(Document("data/sotu/0001.txt")))
add_document(n_gram_corpus, to_n_gram_document(Document("data/sotu/0002.txt")))
dtm = to_dtm(n_gram_corpus)

corpus = Corpus([Document("data/sotu/0001.txt")])
dtm = to_dtm(corpus)

# td_idf(dtm)
