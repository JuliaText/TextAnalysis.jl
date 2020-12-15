using SparseArrays
using Test
using Languages
using TextAnalysis
using WordTokenizers
using Serialization

println("Running tests:")

include("coom.jl")
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
include("lsa.jl")
include("summarizer.jl")
include("bayes.jl")
include("taggingschemes.jl")
include("evaluation_metrics.jl")
include("LM.jl")
