#
# Correctness Tests
#

using TextAnalysis

require("test.jl")

my_tests = ["test/tokenizer.jl",
            "test/ngramizer.jl",
            "test/document.jl",
            "test/metadata.jl",
            "test/corpus.jl",
            "test/preprocessing.jl",
            "test/dtm.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
