# Text Analysis in Julia

Using this package, you can do basic text analysis, including:

* Creating a corpus from a directory of text files.
* Creating a document-term matrix from a corpus.
* Performing LDA on a document-term matrix.

# Real-World Usage Examples

To show off, let's start with some real-world usage examples of this package. These examples are quite computationally intensive, so be prepared to wait a minute or two (or more) for the examples to finish running.

## Analysis of a Corpus of State of the Union Addresses

Here, we create a document-term matrix for all of the State of the Union (SOTU) addresses on record and then compute correlations betweens rows in this matrix to see which SOTU adddresses are most similar to each other:

    load("src/init.jl")
    
    filenames = convert(Array{String,1},
                        map(x -> strcat("data/sotu/", chomp(x)),
                            readlines(`ls data/sotu`)))
    
    corpus = Corpus(filenames)
    
    dtm = DocumentTermMatrix(corpus)

    similarity_matrix = cor(dtm.counts')

## LDA Analysis of a Simulated Corpus

Here, we use a random number generator to create an artificial corpus of 50 documents according to the LDA model for generating random documents. We then use this simulated corpus to infer the parameters of our generative model as a way to test that our estimation strategy is accurate:

    load("src/init.jl")
    
    # Make sure all users get similar results.
    srand(1)
    
    # Set the parameters of the LDA model.
    xi = 1000.0
    alpha = [0.01, 0.01]
    beta = [0.45 0.05 0.05 0.45; 0.05 0.45 0.45 0.05;]
    
    (document_theta, document) = generate_document(xi, alpha, beta)
    
    (theta, corpus) = generate_corpus(50, xi, alpha, beta)
    
    # Run inference using Gibbs sampling.
    # This will divide the corpus into 2 topics.
    # We will use only 20 samples to infer the theta and beta parameters.
    # We will have the system print out a trace of its state at each step.
    (inferred_theta, inferred_beta) = lda(corpus, 2, 20, true)
    
    # Now we can check the accuracy of our results.
    # These vary considerably between runs of the sampler.
    # Inference for beta is quite reliable.
    # Inference for theta is generally quite poor at best.
    # We should also keep in mind that relabelling of the topics may occur.
    mean(abs(beta - inferred_beta))
    mean(round(theta) != round(inferred_theta), 1)

# Package Walkthrough

Hopefully you're now interested in learning how to use this package. To get you started, we'll walk you through the basic data structures and functions.

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
