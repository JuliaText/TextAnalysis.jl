#
# Correctness Tests
#

require("pkg")

require("TextAnalysis")
using TextAnalysis

require("extras/test.jl")

my_tests = ["test/document.jl",
            "test/metadata.jl",
            "test/corpus.jl",
            "test/preprocessing.jl",
            "test/dtm.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
