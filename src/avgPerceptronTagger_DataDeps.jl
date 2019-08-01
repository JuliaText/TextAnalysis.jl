using DataDeps

register(DataDep("POS Perceptron Tagger Weights",
    """
    The trained weights for the average Perceptron Tagger on Part of Speech Tagging task.
    """,
    "https://github.com/JuliaText/TextAnalysis.jl/raw/2467ae2f379490af9ba1b181ce25f1a415a4be4d/src/pretrainedMod.bson",
    "3305c8ee73d9de6d653d6a6e4eaf83dc5031114aaebe621b1625f11d7810a5f4",
    post_fetch_method = function(fn)
        file = readdir(".")[1]
        println(readdir("."))
        mv(file, "POSWeights.bson")
    end
))
