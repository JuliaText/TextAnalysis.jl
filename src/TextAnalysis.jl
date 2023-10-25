module TextAnalysis
    using SparseArrays
    using Printf
    using LinearAlgebra
    using StatsBase: countmap,addcounts!
    using Languages
    using WordTokenizers
    using Snowball

    using Tables
    using DataStructures
    using Statistics
    using Serialization
    using ProgressMeter
    using DocStringExtensions

    import Base: depwarn, merge!
    import Serialization: serialize, deserialize

    export AbstractDocument, Document
    export FileDocument, StringDocument, TokenDocument, NGramDocument
    export GenericDocument
    export Corpus, DirectoryCorpus
    export stemmer_types, Stemmer
    export DocumentTermMatrix
    export text, tokens, ngrams
    export text!, tokens!, ngrams!
    export documents
    export language, title, author, timestamp
    export languages, titles, authors, timestamps
    export language!, title!, author!, timestamp!
    export languages!, titles!, authors!, timestamps!
    export ngram_complexity
    export lexicon, update_lexicon!, lexical_frequency, lexicon_size
    export inverse_index, update_inverse_index!, index_size
    export remove_corrupt_utf8
    export remove_corrupt_utf8!
    export remove_case
    export remove_case!
    export remove_words, remove_stop_words
    export remove_words!, remove_stop_words!
    export stem, tag_pos
    export stem!, tag_pos!
    export remove_html_tags, remove_html_tags!
    export prepare!
    export frequent_terms, sparse_terms
    export remove_frequent_terms!, remove_sparse_terms!
    export dtv, each_dtv, dtm, tdm
    export TextHashFunction, index_hash, cardinality, hash_function, hash_function!
    export hash_dtv, each_hash_dtv, hash_dtm, hash_tdm
    export CooMatrix, coom
    export standardize!
    export tf, tf_idf, bm_25, lsa, lda, summarize, cos_similarity
    export tf!, tf_idf!, bm_25!, lda!
    export remove_patterns!, remove_patterns
    export prune!

    export strip_patterns, strip_corrupt_utf8, strip_case, stem_words, tag_part_of_speech, strip_whitespace, strip_punctuation
    export strip_numbers, strip_non_letters, strip_indefinite_articles, strip_definite_articles, strip_articles
    export strip_prepositions, strip_pronouns, strip_stopwords, strip_sparse_terms, strip_frequent_terms, strip_html_tags

    export NaiveBayesClassifier
    export tag_scheme!

    export rouge_l_summary, rouge_l_sentence, rouge_n, Score, average, argmax
    export bleu_score

    export PerceptronTagger, fit!, predict

    export Vocabulary, lookup, update
    export everygram, padding_ngram
    export maskedscore, logscore, entropy, perplexity
    export MLE, Lidstone, Laplace, WittenBellInterpolated, KneserNeyInterpolated, score

    export tokenize #imported from WordTokenizers

    include("tokenizer.jl")
    include("ngramizer.jl")
    include("document.jl")
    include("hash.jl")
    include("corpus.jl")
    include("metadata.jl")
    include("preprocessing.jl")

    include("stemmer.jl")
    include("dtm.jl")
    include("tf_idf.jl")
    include("lsa.jl")
    include("lda.jl")
    include("summarizer.jl")
    include("show.jl")
    include("bayes.jl")
    include("deprecations.jl")
    include("tagging_schemes.jl")
    include("utils.jl")

    include("evaluation_metrics.jl")
    include("translate_evaluation/bleu_score.jl")
    include("coom.jl")



    # Lang_model
    include("LM/vocab.jl")
    include("LM/langmodel.jl")
    include("LM/api.jl")
    include("LM/counter.jl")
    include("LM/preprocessing.jl")



    function __init__()

    end
end
