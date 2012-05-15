#
#
#

load("revised_implementation/tokenize.jl")

sample_text = "this is some sample text"
tokenize(sample_text, 1)
tokenize(sample_text, 2)
tokenize(sample_text, 3)

#
#
#

load("revised_implementation/document.jl")

document = Document("", "", "", "")
document = Document()
document = Document("data/sotu/0001.txt")

remove_words(document, ["government"]) # Fails with ASCIIString error. TMP fix in place.
remove_numbers(document)
remove_punctuation(document)
remove_case(document)

#
#
#

load("revised_implementation/n_gram_document.jl")

to_n_gram_document(1, document) # From document.jl
to_n_gram_document(document) # From document.jl

n_gram_document = NGramDocument(1, tokenize(sample_text, 1))
n_gram_document = NGramDocument(1)
n_gram_document = NGramDocument()

n_gram_document = NGramDocument(1, tokenize(sample_text, 1))
remove_words(n_gram_document, ["this"]) # Fails with ASCIIString error. TMP fix in place.

#
#
#

load("revised_implementation/corpus.jl")

document = Document("data/sotu/0001.txt")
corpus = Corpus([document])
corpus.documents

corpus = Corpus()
corpus.documents

add_document(corpus, document)

remove_document(corpus, document)

filenames = convert(Array{String,1},
                    map(x -> strcat("data/mini/", chomp(x)),
                        readlines(`ls data/mini`)))

corpus = Corpus(filenames)

#corpus = Corpus("data/mini") # Doesn't work because no dir() exists yet.

remove_words(corpus, ["a"]) # Fails with ASCIIString error.

remove_numbers(corpus)

remove_punctuation(corpus)

remove_case(corpus)

#
#
#

load("revised_implementation/n_gram_corpus.jl")

to_n_gram_corpus(corpus) # From corpus.jl

document = Document("data/sotu/0001.txt")
n_gram_document = to_n_gram_document(document)
n_gram_corpus = NGramCorpus([n_gram_document])

n_gram_corpus = NGramCorpus()

add_document(n_gram_corpus, n_gram_document)

remove_document(n_gram_corpus, n_gram_document)

remove_words(n_gram_corpus, ["a"])

#
#
#

load("revised_implementation/document_term_matrix.jl")

to_dtm(n_gram_corpus) # From n_gram_corpus.jl
to_dtm(corpus) # From corpus.jl

dtm = DocumentTermMatrix(counts)

dtm = DocumentTermMatrix()

# td_idf(dtm)

n_gram_corpus = NGramCorpus()
add_document(n_gram_corpus, to_n_gram_document(Document("data/sotu/0001.txt")))
add_document(n_gram_corpus, to_n_gram_document(Document("data/sotu/0002.txt")))
dtm = to_dtm(n_gram_corpus)

#Corpus(["data/sotu/0001.txt", "data/sotu/0002.txt"])
# Still doesn't work.

