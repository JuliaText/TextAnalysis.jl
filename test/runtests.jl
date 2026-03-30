using SparseArrays
using Test
using Languages
using TextAnalysis
using WordTokenizers
using Serialization

tests = [
    "coom.jl"
    "tokenizer.jl"
    "ngramizer.jl"
    "document.jl"
    "metadata.jl"
    "corpus.jl"
    "preprocessing.jl"
    "dtm.jl"
    "stemmer.jl"
    "tf_idf.jl"
    "lda.jl"
    "lsa.jl"
    "summarizer.jl"
    "bayes.jl"
    "taggingschemes.jl"
    "evaluation_metrics.jl"
    "LM.jl"
    "translate_evaluation.jl"
]

function run_tests()
    for test in tests
        @info "Test: $test"
        Test.@testset verbose = true "\U1F4C2 $test" begin
            include(test)
        end
    end
end

@static if VERSION >= v"1.7"
    Test.@testset verbose = true showtiming = true "All tests" begin
        run_tests()
    end
else
    Test.@testset verbose = true begin
        run_tests()
    end
end
