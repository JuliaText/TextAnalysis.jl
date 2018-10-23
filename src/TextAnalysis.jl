module TextAnalysis
    using SparseArrays
    using Printf
    using LinearAlgebra
    
    using Languages
    using DataFrames
    using WordTokenizers

    import DataFrames.DataFrame
    import Base: depwarn, show, names

    export AbstractDocument, Document
    export FileDocument, StringDocument, TokenDocument, NGramDocument
    export GenericDocument
    export Corpus, DirectoryCorpus
    export stemmer_types, Stemmer
    export DocumentTermMatrix
    export text, tokens, ngrams
    export text!, tokens!, ngrams!
    export documents
    export language, name, author, timestamp
    export languages, names, authors, timestamps
    export language!, name!, author!, timestamp!
    export languages!, names!, authors!, timestamps!
    export id, publisher, published_year, edition_year, documenttype, note
    export id!, publisher!, published_year!, edition_year!, documenttype!, note!
    export ids, publishers, published_years, edition_years, documenttypes, notes
    export ids!, publishers!, published_years!, edition_years!, documenttypes!, notes!
    export ngram_complexity
    export lexicon, update_lexicon!, lexical_frequency, lexicon_size
    export inverse_index, update_inverse_index!, index_size
    export remove_corrupt_utf8
    export remove_corrupt_utf8!
    export remove_punctuation, remove_numbers, remove_case, remove_whitespace
    export remove_punctuation!, remove_numbers!, remove_case!, remove_whitespace!
    export remove_nonletters, remove_nonletters!
    export remove_words, remove_stop_words, remove_articles
    export remove_words!, remove_stop_words!, remove_articles!
    export remove_definite_articles, remove_indefinite_articles
    export remove_definite_articles!, remove_indefinite_articles!
    export remove_prepositions, remove_pronouns, stem, tag_pos
    export remove_prepositions!, remove_pronouns!, stem!, tag_pos!
    export remove_html_tags, remove_html_tags!
    export prepare!
    export frequent_terms, sparse_terms
    export remove_frequent_terms!, remove_sparse_terms!
    export dtv, each_dtv, dtm, tdm
    export TextHashFunction, index_hash, cardinality, hash_function, hash_function!
    export hash_dtv, each_hash_dtv, hash_dtm, hash_tdm
    export standardize!
    export tf, tf_idf, lsa, lda, summarize
    export tf!, tf_idf!, lsa!, lda!
    export remove_patterns!, remove_patterns

    export strip_patterns, strip_corrupt_utf8, strip_case, stem_words, tag_part_of_speech, strip_whitespace, strip_punctuation
    export strip_numbers, strip_non_letters, strip_indefinite_articles, strip_definite_articles, strip_articles
    export strip_prepositions, strip_pronouns, strip_stopwords, strip_sparse_terms, strip_frequent_terms, strip_html_tags
    export SentimentAnalyzer

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
    include("deprecations.jl")
end
