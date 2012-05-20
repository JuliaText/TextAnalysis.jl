load("src/init.jl")

corpus = Corpus(["data/mini/0001.txt", "data/mini/0002.txt", "data/mini/0003.txt"])
remove_punctuation(corpus)
remove_case(corpus)

dtm = DocumentTermMatrix(corpus)

@assert size(dtm.counts) == (3, 12) # Includes space as a token.
