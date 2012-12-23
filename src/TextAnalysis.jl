require("pkg")
require("FileFind")
require("Languages")
require("DataFrames")

using DataFrames

module TextAnalysis
	using Base
	using Languages
	using DataFrames

	import Base.print, Base.show, Base.repl_show, Base.summary
	import Base.ref, Base.assign
	import Base.start, Base.next, Base.done
	import Base.length
	import Base.convert
	import Base.push, Base.pop, Base.enqueue, Base.shift, Base.insert, Base.del
	import DataFrames.DataFrame

	export AbstractDocument, Document
	export FileDocument, StringDocument, TokenDocument, NGramDocument
	export GenericDocument
	export Corpus, DirectoryCorpus
	export DocumentTermMatrix
	export text, tokens, ngrams
	export text!, tokens!, ngrams!
	export documents
	export language, name, author, timestamp
	export language!, name!, author!, timestamp!
	export ngram_complexity
	export lexicon, update_lexicon!, lexical_frequency, lexicon_size
	export inverse_index, update_inverse_index!, index_size
	export remove_corrupt_utf8
	export remove_corrupt_utf8!
	export remove_punctuation, remove_numbers, remove_case, remove_whitespace
	export remove_punctuation!, remove_numbers!, remove_case!, remove_whitespace!
	export remove_words, remove_stop_words, remove_articles
	export remove_words!, remove_stop_words!, remove_articles!
	export remove_definite_articles, remove_indefinite_articles
	export remove_definite_articles!, remove_indefinite_articles!
	export remove_prepositions, remove_pronouns, stem, tag_pos
	export remove_prepositions!, remove_pronouns!, stem!, tag_pos!
	export dtv, each_dtv, dtm, tdv, each_tdv, tdm
	export TextHashFunction, index_hash, cardinality, hash_function, hash_function!
	export hash_dtv, each_hash_dtv, hash_dtm, hash_tdv, each_hash_tdv, hash_tdm
	export standardize!
	export tf_idf, lsa, lda

	require("TextAnalysis/src/tokenizer.jl")
	require("TextAnalysis/src/ngramizer.jl")
	require("TextAnalysis/src/document.jl")
	require("TextAnalysis/src/hash.jl")
	require("TextAnalysis/src/corpus.jl")
	require("TextAnalysis/src/metadata.jl")
	require("TextAnalysis/src/preprocessing.jl")
	require("TextAnalysis/src/dtm.jl")
	require("TextAnalysis/src/tf_idf.jl")
	require("TextAnalysis/src/lsa.jl")
	require("TextAnalysis/src/lda.jl")
	require("TextAnalysis/src/show.jl")
end
