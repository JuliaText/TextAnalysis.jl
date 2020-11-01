using Snowball
@testset "Stemmer" begin

    algs = stemmer_types()
    @test !isempty(algs)

    for alg in algs
        stmr = Stemmer(alg)
        Snowball.release(stmr)
    end

    test_cases = Dict{String, Any}(
        "english" => Dict{AbstractString, AbstractString}(
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
