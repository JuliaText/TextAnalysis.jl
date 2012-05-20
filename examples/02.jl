load("src/init.jl")

dtm = DocumentTermMatrix(Corpus("data/sotu"))

# Compute similarity scores for documents.
tdm = dtm.dtm'
dm = abs(-log(cor(tdm)))

csvwrite("examples/dm.csv", dm)
