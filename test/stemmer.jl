module TestStemmer
    using Base.Test
    using Languages
    using TextAnalysis
    using Compat

    algs = stemmer_types()
    @test !isempty(algs)

    for alg in algs
        stmr = Stemmer(alg)
        TextAnalysis.release(stmr)
    end

    test_cases = @compat Dict{Compat.ASCIIString, Any}(
        "english" => @compat Dict{AbstractString, AbstractString}(
            "working" => "work",
            "worker" => "worker",
            "aβc" => "aβc",
            "a∀c" => "a∀c"
        )
    )

    for (alg, test_words) in test_cases
        stmr = Stemmer(alg)
        for (n,v) in test_words
            @test v == stem(stmr, n)
        end
    end
end
