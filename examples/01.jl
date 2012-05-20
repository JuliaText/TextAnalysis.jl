# Load all of this package's functionality.
load("src/init.jl")

# Show how we currently tokenize a string.
sample_text = "this is some sample text"
tokenize(sample_text, 1)
tokenize(sample_text, 2)

# Create a Document type variable.
document = Document("data/sotu/0001.txt")

# Look at the document's fields.
document.name
document.date
document.author
document.text
document.language

# Now remove things from the Document.
remove_words(document, ["government"])
document.text

remove_numbers(document)
document.text

remove_punctuation(document)
document.text

remove_case(document)
document.text

# Now we'll create an NGramDocument by converting a Document.
document = Document("data/sotu/0001.txt")
n_gram_document = NGramDocument(document)

# Look at the NGramDocument's fields.
n_gram_document.n
n_gram_document.tokens

# Now remove things from the NGramDocument.
n_gram_document.tokens["government"]
remove_words(n_gram_document, ["government"])
n_gram_document.tokens["government"]

# Now we'll create a Corpus type variable.
document = Document("data/sotu/0001.txt")
corpus = Corpus([document])

# Look at the Corpus's fields.
corpus.documents

# Create an empty Corpus and then add and remove Document's one-by-one.
corpus = Corpus()
add_document(corpus, document)
corpus.documents
remove_document(corpus, document)
corpus.documents

# Create a new Corpus and remove things from all of the Document's in it.
corpus = Corpus(["data/sotu/0001.txt"])
remove_words(corpus, ["a"])
corpus.documents[1]
remove_numbers(corpus)
corpus.documents[1]
remove_punctuation(corpus)
corpus.documents[1]
remove_case(corpus)
corpus.documents[1]

# Create an NGramCorpus from an array of NGramDocument's.
document = Document("data/sotu/0001.txt")
n_gram_document = NGramDocument(document)
n_gram_corpus = NGramCorpus([n_gram_document])
n_gram_corpus.n_gram_documents[1]

# Create an NGramCorpus from an array of Document's.
document = Document("data/sotu/0001.txt")
n_gram_corpus = NGramCorpus([document])
n_gram_corpus.n_gram_documents[1]

# Create an empty NGramCorpus, then add and remove Document's one-by-one.
n_gram_corpus = NGramCorpus()
document = Document("data/sotu/0001.txt")
n_gram_document = NGramDocument(document)
add_document(n_gram_corpus, n_gram_document)
n_gram_corpus.n_gram_documents[1]
remove_document(n_gram_corpus, n_gram_document)
n_gram_corpus.n_gram_documents
add_document(n_gram_corpus, n_gram_document)

# Remove words from all NGramDocument's in an NGramCorpus.
n_gram_corpus.n_gram_documents[1]
n_gram_corpus.n_gram_documents[1].tokens["a"]
remove_words(n_gram_corpus, ["a"])
n_gram_corpus.n_gram_documents[1].tokens["a"]

# Convert a Corpus into an NGramCorpus.
corpus = Corpus(["data/sotu/0001.txt", "data/sotu/0002.txt"])
NGramCorpus(corpus)

# Create a toy DTM and examine its contents.
tokens = {"one", "two"}
counts = zeros(Int, 2, 2)
dtm = DocumentTermMatrix(tokens, counts)
dtm.tokens
dtm.counts

# Create a DTM from an NGramCorpus.
n_gram_corpus = NGramCorpus()
add_document(n_gram_corpus, NGramDocument(Document("data/sotu/0001.txt")))
add_document(n_gram_corpus, NGramDocument(Document("data/sotu/0002.txt")))
dtm = DocumentTermMatrix(n_gram_corpus)

# Create a DTM from a Corpus.
corpus = Corpus([Document("data/sotu/0001.txt"), Document("data/sotu/0002.txt")])
dtm = DocumentTermMatrix(corpus)
