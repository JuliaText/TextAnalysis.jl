module TextAnalysis
    using SparseArrays
    using Printf
    using LinearAlgebra

    using Languages
    using DataFrames
    using WordTokenizers

    using DataDeps
    using DataStructures
    using Statistics

    using Flux, Tracker
    using Flux: identity, onehot, onecold, @treelike, onehotbatch

    import DataFrames.DataFrame
    import Base.depwarn

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
    export tf, tf_idf, bm_25, lsa, lda, summarize
    export tf!, tf_idf!, bm_25!, lda!
    export remove_patterns!, remove_patterns

    export strip_patterns, strip_corrupt_utf8, strip_case, stem_words, tag_part_of_speech, strip_whitespace, strip_punctuation
    export strip_numbers, strip_non_letters, strip_indefinite_articles, strip_definite_articles, strip_articles
    export strip_prepositions, strip_pronouns, strip_stopwords, strip_sparse_terms, strip_frequent_terms, strip_html_tags

    export SentimentAnalyzer
    export tag_scheme!
    export rouge_l_summary, rouge_l_sentence, rouge_n
    export PerceptronTagger, fit!, predict

    export CRF, viterbi_decode, crf_loss

    export NERTagger, PoSTagger, Tracker, Flux

    include("tokenizer.jl")
    include("ngramizer.jl")
    include("document.jl")
    include("hash.jl")
    include("corpus.jl")
    include("metadata.jl")
    include("preprocessing.jl")

    # Load libstemmer from our deps.jl
    const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
    if !isfile(depsjl_path)
        error("Snowball Stemmer not installed properly, run Pkg.build(\"TextAnalysis\"), restart Julia and try again")
    end
    include(depsjl_path)

    include("stemmer.jl")
    include("dtm.jl")
    include("tf_idf.jl")
    include("lsa.jl")
    include("lda.jl")
    include("summarizer.jl")
    include("show.jl")
    include("sentiment.jl")
    include("bayes.jl")
    include("deprecations.jl")
    include("tagging_schemes.jl")
    include("utils.jl")
    include("averagePerceptronTagger.jl")

    include("evaluation_metrics.jl")
    include("coom.jl")

    # CRF
    include("CRF/crf.jl")
    include("CRF/predict.jl")
    include("CRF/crf_utils.jl")
    include("CRF/loss.jl")

    # NER and POS
    include("sequence/ner_datadeps.jl")
    include("sequence/ner.jl")
    include("sequence/pos_datadeps.jl")
    include("sequence/pos.jl")
    include("sequence/sequence_models.jl")
    # ALBERT 
    include("./albert/ALBERT.jl")

    function __init__()
        pos_tagger_datadep_register()
        ner_datadep_register()
        pos_datadep_register()
    end
end
