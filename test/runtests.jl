module TestTextAnalysis
    using Base.Test
    using Languages
    using TextAnalysis
    using Compat

    my_tests = [
        "tokenizer.jl",
        "ngramizer.jl",
        "document.jl",
        "metadata.jl",
        "corpus.jl",
        "preprocessing.jl",
        "dtm.jl",
        "stemmer.jl",
        "tf_idf.jl",
        "lda.jl"
    ]

    println("Running tests:")
    println(typeof(Compat.String))

    for my_test in my_tests
        println(" * $(my_test)")
        include(my_test)
    end
end
