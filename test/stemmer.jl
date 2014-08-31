module TestStemmer
    using Base.Test
    using Languages
    using TextAnalysis

    algs = stemmer_types()
    @assert !isempty(algs)

    for alg in algs
        stmr = Stemmer(alg)
        TextAnalysis.release(stmr)
    end

    test_cases = {
        "english" => {
            "working" => "work",
            "worker" => "worker"
        }
    }

    for (alg, test_words) in test_cases
        stmr = Stemmer(alg)
        for (n,v) in test_words
            @assert v == stem(stmr, n)
        end
    end
end
