load("src/init.jl")

dtm = generate_dtm(generate_corpus("data/sotu"))

# Compute similarity scores for documents.
tdm = dtm["dtm"]'
dm = abs(-log(cor(tdm)))

csvwrite("examples/dm.csv", dm)
