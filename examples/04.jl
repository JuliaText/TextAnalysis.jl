load("src/init.jl")

dtm = DocumentTermMatrix(Corpus("data/sotu"))

results = k_means(dtm.dtm, 2)

results["Assignments"]
max(abs(results["Centers"][1, :] - results["Centers"][2, :]))
