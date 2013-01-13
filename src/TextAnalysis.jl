using FileFind
using DataFrames

module TextAnalysis
	using Languages
	using DataFrames

	import Base.show, Base.repl_show, Base.summary
	import Base.ref, Base.assign
	import Base.start, Base.next, Base.done
	import Base.length
	import Base.convert
	import Base.push!, Base.pop!, Base.unshift!, Base.shift!, Base.insert!, Base.delete!
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

	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "tokenizer.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "ngramizer.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "document.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "hash.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "corpus.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "metadata.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "preprocessing.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "dtm.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "tf_idf.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "lsa.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "lda.jl"))
	include(joinpath(julia_pkgdir(), "TextAnalysis", "src", "show.jl"))
end
