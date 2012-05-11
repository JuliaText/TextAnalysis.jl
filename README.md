# Text Analysis in Julia

* Create a corpus from a directory of text files.
* Create document-term matrices from a corpus.

# Example

    load("src/init.jl")
    
    corpus = generate_corpus("documents")
    
    dtm = generate_dtm(corpus)
