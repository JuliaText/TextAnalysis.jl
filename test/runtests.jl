module TestTextAnalysis
    using Base.Test
    using Languages
    using TextAnalysis

    my_tests = [
        "tokenizer.jl",
        "ngramizer.jl",
        "document.jl",
        "metadata.jl",
        "corpus.jl",
        "preprocessing.jl",
        "dtm.jl",
    ]

    println("Running tests:")

    for my_test in my_tests
        println(" * $(my_test)")
        include(my_test)
    end
end
