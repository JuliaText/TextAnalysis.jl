# Text Analysis in Julia

* Create document-term matrices (DTM's) from a directory of files.

# Example

    load("text.jl")

    (document_names, terms, dtm) = generate_corpus("documents")
