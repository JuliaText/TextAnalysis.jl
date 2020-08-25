using SparseArrays
using Test
using Languages
using TextAnalysis
using WordTokenizers

println("Running tests:")

include("albert.jl")
include("pos.jl")
include("ner.jl")
include("coom.jl")
include("crf.jl")
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
include("sentiment.jl")
include("bayes.jl")
include("taggingschemes.jl")
include("averagePerceptronTagger.jl")
include("evaluation_metrics.jl")
include("ulmfit.jl")

