module TestTextAnalysis
using SparseArrays
using Test
using Languages
using TextAnalysis
using WordTokenizers

# @testset "TextAnalysis" begin

println("Running tests:")

include("tokenizer.jl")
include("ngramizer.jl")
include("document.jl")
include("metadata.jl")
include("corpus.jl")
include("preprocessing.jl")
include("dtm.jl")
include("stemmer.jl")
include("tf_idf.jl")
include("lda.jl")
include("summarizer.jl")
include("sentiment.jl")
include("bayes.jl")
include("taggingschemes.jl")
include("rouge.jl")


# end
end
