var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#Preface-1",
    "page": "Home",
    "title": "Preface",
    "category": "section",
    "text": "This manual is designed to get you started doing text analysis in Julia. It assumes that you already familiar with the basic methods of text analysis."
},

{
    "location": "#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The TextAnalysis package can be installed using Julia\'s package manager:Pkg.add(\"TextAnalysis\")"
},

{
    "location": "#Getting-Started-1",
    "page": "Home",
    "title": "Getting Started",
    "category": "section",
    "text": "In all of the examples that follow, we\'ll assume that you have the TextAnalysis package fully loaded. This means that we think you\'ve implicitly typedusing TextAnalysisbefore every snippet of code."
},

{
    "location": "documents/#",
    "page": "Documents",
    "title": "Documents",
    "category": "page",
    "text": ""
},

{
    "location": "documents/#Creating-Documents-1",
    "page": "Documents",
    "title": "Creating Documents",
    "category": "section",
    "text": "The basic unit of text analysis is a document. The TextAnalysis package allows one to work with documents stored in a variety of formats:FileDocument : A document represented using a plain text file on disk\nStringDocument : A document represented using a UTF8 String stored in RAM\nTokenDocument : A document represented as a sequence of UTF8 tokens\nNGramDocument : A document represented as a bag of n-grams, which are UTF8 n-grams that map to countsThese format represent a hierarchy: you can always move down the hierachy, but can generally not move up the hierachy. A FileDocument can easily become a StringDocument, but an NGramDocument cannot easily become a FileDocument.Creating any of the four basic types of documents is very easy:julia> str = \"To be or not to be...\"\n\"To be or not to be...\"\n\njulia> sd = StringDocument(str)\nStringDocument{String}(\"To be or not to be...\", TextAnalysis.DocumentMetadata(Languages.English(), \"Unnamed Document\", \"Unknown Author\", \"Unknown Time\"))\n\njulia> pathname = \"/usr/share/dict/words\"\n\"/usr/share/dict/words\"\n\njulia> fd = FileDocument(pathname)\nFileDocument(\"/usr/share/dict/words\", TextAnalysis.DocumentMetadata(Languages.English(), \"/usr/share/dict/words\", \"Unknown Author\", \"Unknown Time\"))\n\njulia> my_tokens = String[\"To\", \"be\", \"or\", \"not\", \"to\", \"be...\"]\n6-element Array{String,1}:\n \"To\"   \n \"be\"   \n \"or\"   \n \"not\"  \n \"to\"   \n \"be...\"\n\njulia> td = TokenDocument(my_tokens)\nTokenDocument{String}([\"To\", \"be\", \"or\", \"not\", \"to\", \"be...\"], TextAnalysis.DocumentMetadata(Languages.English(), \"Unnamed Document\", \"Unknown Author\", \"Unknown Time\"))\n\njulia> my_ngrams = Dict{String, Int}(\"To\" => 1, \"be\" => 2,\n                                    \"or\" => 1, \"not\" => 1,\n                                    \"to\" => 1, \"be...\" => 1)\nDict{String,Int64} with 6 entries:\n  \"or\"    => 1\n  \"be...\" => 1\n  \"not\"   => 1\n  \"to\"    => 1\n  \"To\"    => 1\n  \"be\"    => 2\n\njulia> ngd = NGramDocument(my_ngrams)\nNGramDocument{AbstractString}(Dict{AbstractString,Int64}(\"or\"=>1,\"be...\"=>1,\"not\"=>1,\"to\"=>1,\"To\"=>1,\"be\"=>2), 1, TextAnalysis.DocumentMetadata(Languages.English(), \"Unnamed Document\", \"Unknown Author\", \"Unknown Time\"))For every type of document except a FileDocument, you can also construct a new document by simply passing in a string of text:sd = StringDocument(\"To be or not to be...\")\ntd = TokenDocument(\"To be or not to be...\")\nngd = NGramDocument(\"To be or not to be...\")The system will automatically perform tokenization or n-gramization in order to produce the required data. Unfortunately, FileDocument\'s cannot be constructed this way because filenames are themselves strings. It would cause chaos if filenames were treated as the text contents of a document.That said, there is one way around this restriction: you can use the generic Document() constructor function, which will guess at the type of the inputs and construct the appropriate type of document object:Document(\"To be or not to be...\")\nDocument(\"/usr/share/dict/words\")\nDocument(String[\"To\", \"be\", \"or\", \"not\", \"to\", \"be...\"])\nDocument(Dict{String, Int}(\"a\" => 1, \"b\" => 3))This constructor is very convenient for working in the REPL, but should be avoided in permanent code because, unlike the other constructors, the return type of the Document function cannot be known at compile-time."
},

{
    "location": "documents/#Basic-Functions-for-Working-with-Documents-1",
    "page": "Documents",
    "title": "Basic Functions for Working with Documents",
    "category": "section",
    "text": "Once you\'ve created a document object, you can work with it in many ways. The most obvious thing is to access its text using the text() function:text(sd)This function works without warnings on StringDocument\'s and FileDocument\'s. For TokenDocument\'s it is not possible to know if the text can be reconstructed perfectly, so calling text(TokenDocument(\"This is text\")) will produce a warning message before returning an approximate reconstruction of the text as it existed before tokenization. It is entirely impossible to reconstruct the text of an NGramDocument, so text(NGramDocument(\"This is text\")) raises an error.Instead of working with the text itself, you can work with the tokens or n-grams of a document using the tokens() and ngrams() functions:tokens(sd)\nngrams(sd)By default the ngrams() function produces unigrams. If you would like to produce bigrams or trigrams, you can specify that directly using a numeric argument to the ngrams() function:ngrams(sd, 2)If you have a NGramDocument, you can determine whether an NGramDocument contains unigrams, bigrams or a higher-order representation using the ngram_complexity() function:ngram_complexity(ngd)This information is not available for other types of Document objects because it is possible to produce any level of complexity when constructing n-grams from raw text or tokens."
},

{
    "location": "documents/#Document-Metadata-1",
    "page": "Documents",
    "title": "Document Metadata",
    "category": "section",
    "text": "In addition to methods for manipulating the representation of the text of a document, every document object also stores basic metadata about itself, including the following pieces of information:language(): What language is the document in? Defaults to Languages.English(), a Language instance defined by the Languages package.\ntitle(): What is the name of the document? Defaults to \"Untitled Document\".\nauthor(): Who wrote the document? Defaults to \"Unknown Author\".\ntimestamp(): When was the document written? Defaults to \"Unknown Time\".Try these functions out on a StringDocument to see how the defaults work in practice:language(sd)\ntitle(sd)\nauthor(sd)\ntimestamp(sd)If you need reset these fields, you can use the mutating versions of the same functions:language!(sd, Languages.Spanish())\ntitle!(sd, \"El Cid\")\nauthor!(sd, \"Desconocido\")\ntimestamp!(sd, \"Desconocido\")You can also retrieve the metadata for every document in a Corpus at once:languages(crps)\ntitles(crps)\nauthors(crps)\ntimestamps(crps)It is possible to change the metadata fields for each document in a Corpus. These functions use the same metadata value for every document:languages!(crps, Languages.German())\ntitles!(crps, \"\")\nauthors!(crps, \"Me\")\ntimestamps!(crps, \"Now\")Additionally, you can specify the metadata fields for each document in a Corpus individually:languages!(crps, [Languages.German(), Languages.English()])\ntitles!(crps, [\"\", \"Untitled\"])\nauthors!(crps, [\"Ich\", \"You\"])\ntimestamps!(crps, [\"Unbekannt\", \"2018\"])"
},

{
    "location": "documents/#Preprocessing-Documents-1",
    "page": "Documents",
    "title": "Preprocessing Documents",
    "category": "section",
    "text": "Having easy access to the text of a document and its metadata is very important, but most text analysis tasks require some amount of preprocessing.At a minimum, your text source may contain corrupt characters. You can remove these using the remove_corrupt_utf8!() function:remove_corrupt_utf8!(sd)Alternatively, you may want to edit the text to remove items that are hard to process automatically. For example, our sample text sentence taken from Hamlet has three periods that we might like to discard. We can remove this kind of punctuation using the prepare!() function:prepare!(sd, strip_punctuation)Like punctuation, numbers and case distinctions are often easier removed than dealt with. To remove numbers or case distinctions, use the remove_numbers!() and remove_case!() functions:remove_numbers!(sd)\nremove_case!(sd)At times you\'ll want to remove specific words from a document like a person\'s name. To do that, use the remove_words!() function:sd = StringDocument(\"Lear is mad\")\nremove_words!(sd, [\"Lear\"])At other times, you\'ll want to remove whole classes of words. To make this easier, we can use several classes of basic words defined by the Languages.jl package:Articles : \"a\", \"an\", \"the\"\nIndefinite Articles : \"a\", \"an\"\nDefinite Articles : \"the\"\nPrepositions : \"across\", \"around\", \"before\", ...\nPronouns : \"I\", \"you\", \"he\", \"she\", ...\nStop Words : \"all\", \"almost\", \"alone\", ...These special classes can all be removed using specially-named parameters:prepare!(sd, strip_articles)\nprepare!(sd, strip_indefinite_articles)\nprepare!(sd, strip_definite_articles)\nprepare!(sd, strip_preposition)\nprepare!(sd, strip_pronouns)\nprepare!(sd, strip_stopwords)\nprepare!(sd, strip_numbers)\nprepare!(sd, strip_non_letters)\nprepare!(sd, strip_spares_terms)\nprepare!(sd, strip_frequent_terms)\nprepare!(sd, strip_html_tags)These functions use words lists, so they are capable of working for many different languages without change, also these operations can be combined together for improved performance:prepare!(sd, strip_articles| strip_numbers| strip_html_tags)In addition to removing words, it is also common to take words that are closely related like \"dog\" and \"dogs\" and stem them in order to produce a smaller set of words for analysis. We can do this using the stem!() function:stem!(sd)"
},

{
    "location": "corpus/#",
    "page": "Corpus",
    "title": "Corpus",
    "category": "page",
    "text": ""
},

{
    "location": "corpus/#Creating-a-Corpus-1",
    "page": "Corpus",
    "title": "Creating a Corpus",
    "category": "section",
    "text": "Working with isolated documents gets boring quickly. We typically want to work with a collection of documents. We represent collections of documents using the Corpus type:crps = Corpus([StringDocument(\"Document 1\"),\n               StringDocument(\"Document 2\")])"
},

{
    "location": "corpus/#Standardizing-a-Corpus-1",
    "page": "Corpus",
    "title": "Standardizing a Corpus",
    "category": "section",
    "text": "A Corpus may contain many different types of documents:crps = Corpus([StringDocument(\"Document 1\"),\n               TokenDocument(\"Document 2\"),\n               NGramDocument(\"Document 3\")])It is generally more convenient to standardize all of the documents in a corpus using a single type. This can be done using the standardize! function:standardize!(crps, NGramDocument)After this step, you can check that the corpus only contains NGramDocument\'s:crps"
},

{
    "location": "corpus/#Processing-a-Corpus-1",
    "page": "Corpus",
    "title": "Processing a Corpus",
    "category": "section",
    "text": "We can apply the same sort of preprocessing steps that are defined for individual documents to an entire corpus at once:crps = Corpus([StringDocument(\"Document 1\"),\n               StringDocument(\"Document 2\")])\nremove_punctuation!(crps)These operations are run on each document in the corpus individually."
},

{
    "location": "corpus/#Corpus-Statistics-1",
    "page": "Corpus",
    "title": "Corpus Statistics",
    "category": "section",
    "text": "Often we wish to think broadly about properties of an entire corpus at once. In particular, we want to work with two constructs:Lexicon: The lexicon of a corpus consists of all the terms that occur in any document in the corpus. The lexical frequency of a term tells us how often a term occurs across all of the documents. Often the most interesting words in a document are those words whose frequency within a document is higher than their frequency in the corpus as a whole.\nInverse Index: If we are interested in a specific term, we often want to know which documents in a corpus contain that term. The inverse index tells us this and therefore provides a simplistic sort of search algorithm.Because computations involving the lexicon can take a long time, a Corpus\'s default lexicon is blank:lexicon(crps)In order to work with the lexicon, you have to update it and then access it:update_lexicon!(crps)\nlexicon(crps)But once this work is done, you can easier address lots of interesting questions about a corpus:lexical_frequency(crps, \"Summer\")\nlexical_frequency(crps, \"Document\")Like the lexicon, the inverse index for a corpus is blank by default:inverse_index(crps)Again, you need to update it before you can work with it:update_inverse_index!(crps)\ninverse_index(crps)But once you\'ve updated the inverse index, you can easily search the entire corpus:crps[\"Document\"]\ncrps[\"1\"]\ncrps[\"Summer\"]"
},

{
    "location": "corpus/#Converting-a-DataFrame-from-a-Corpus-1",
    "page": "Corpus",
    "title": "Converting a DataFrame from a Corpus",
    "category": "section",
    "text": "Sometimes we want to apply non-text specific data analysis operations to a corpus. The easiest way to do this is to convert a Corpus object into a DataFrame:convert(DataFrame, crps)"
},

{
    "location": "features/#",
    "page": "Features",
    "title": "Features",
    "category": "page",
    "text": ""
},

{
    "location": "features/#Creating-a-Document-Term-Matrix-1",
    "page": "Features",
    "title": "Creating a Document Term Matrix",
    "category": "section",
    "text": "Often we want to represent documents as a matrix of word counts so that we can apply linear algebra operations and statistical techniques. Before we do this, we need to update the lexicon:update_lexicon!(crps)\nm = DocumentTermMatrix(crps)A DocumentTermMatrix object is a special type. If you would like to use a simple sparse matrix, call dtm() on this object:dtm(m)If you would like to use a dense matrix instead, you can pass this as an argument to the dtm function:dtm(m, :dense)"
},

{
    "location": "features/#Creating-Individual-Rows-of-a-Document-Term-Matrix-1",
    "page": "Features",
    "title": "Creating Individual Rows of a Document Term Matrix",
    "category": "section",
    "text": "In many cases, we don\'t need the entire document term matrix at once: we can make do with just a single row. You can get this using the dtv function. Because individual\'s document do not have a lexicon associated with them, we have to pass in a lexicon as an additional argument:dtv(crps[1], lexicon(crps))"
},

{
    "location": "features/#The-Hash-Trick-1",
    "page": "Features",
    "title": "The Hash Trick",
    "category": "section",
    "text": "The need to create a lexicon before we can construct a document term matrix is often prohibitive. We can often employ a trick that has come to be called the \"Hash Trick\" in which we replace terms with their hashed valued using a hash function that outputs integers from 1 to N. To construct such a hash function, you can use the TextHashFunction(N) constructor:h = TextHashFunction(10)You can see how this function maps strings to numbers by calling the index_hash function:index_hash(\"a\", h)\nindex_hash(\"b\", h)Using a text hash function, we can represent a document as a vector with N entries by calling the hash_dtv function:hash_dtv(crps[1], h)This can be done for a corpus as a whole to construct a DTM without defining a lexicon in advance:hash_dtm(crps, h)Every corpus has a hash function built-in, so this function can be called using just one argument:hash_dtm(crps)Moreover, if you do not specify a hash function for just one row of the hash DTM, a default hash function will be constructed for you:hash_dtv(crps[1])"
},

{
    "location": "features/#TF-IDF-1",
    "page": "Features",
    "title": "TF-IDF",
    "category": "section",
    "text": "In many cases, raw word counts are not appropriate for use because:(A) Some documents are longer than other documents\n(B) Some words are more frequent than other wordsYou can work around this by performing TF-IDF on a DocumentTermMatrix:m = DocumentTermMatrix(crps)\ntf_idf(m)As you can see, TF-IDF has the effect of inserting 0\'s into the columns of words that occur in all documents. This is a useful way to avoid having to remove those words during preprocessing."
},

{
    "location": "features/#Sentiment-Analyzer-1",
    "page": "Features",
    "title": "Sentiment Analyzer",
    "category": "section",
    "text": "It can be used to find the sentiment score (between 0 and 1) of a word, sentence or a Document. A trained model (using Flux) on IMDB word corpus with weights saved are used to calculate the sentiments.model = SentimentAnalyzer(doc)\nmodel = SentimentAnalyzer(doc, handle_unknown)doc              = Input Document for calculating document (AbstractDocument type)\nhandle_unknown   = A function for handling unknown words. Should return an array (default (x)->[])"
},

{
    "location": "semantic/#",
    "page": "Semantic Analysis",
    "title": "Semantic Analysis",
    "category": "page",
    "text": ""
},

{
    "location": "semantic/#LSA:-Latent-Semantic-Analysis-1",
    "page": "Semantic Analysis",
    "title": "LSA: Latent Semantic Analysis",
    "category": "section",
    "text": "Often we want to think about documents from the perspective of semantic content. One standard approach to doing this is to perform Latent Semantic Analysis or LSA on the corpus. You can do this using the lsa function:lsa(crps)"
},

{
    "location": "semantic/#LDA:-Latent-Dirichlet-Allocation-1",
    "page": "Semantic Analysis",
    "title": "LDA: Latent Dirichlet Allocation",
    "category": "section",
    "text": "Another way to get a handle on the semantic content of a corpus is to use Latent Dirichlet Allocation:m = DocumentTermMatrix(crps)\nk = 2            # number of topics\niteration = 1000 # number of gibbs sampling iterations\nalpha = 0.1      # hyper parameter\nbeta  = 0.1       # hyber parameter\nϕ, θ  = lda(m, k, iteration, alpha, beta) # ϕ is k x word matrix.\n                                          # value is probablity of occurrence of a word in a topic.See ?lda for more help."
},

{
    "location": "example/#",
    "page": "Extended Example",
    "title": "Extended Example",
    "category": "page",
    "text": ""
},

{
    "location": "example/#Extended-Usage-Example-1",
    "page": "Extended Example",
    "title": "Extended Usage Example",
    "category": "section",
    "text": "To show you how text analysis might work in practice, we\'re going to work with a text corpus composed of political speeches from American presidents given as part of the State of the Union Address tradition.using TextAnalysis, MultivariateStats, Clustering\n\ncrps = DirectoryCorpus(\"sotu\")\n\nstandardize!(crps, StringDocument)\n\ncrps = Corpus(crps[1:30])\n\nremove_case!(crps)\nremove_punctuation!(crps)\n\nupdate_lexicon!(crps)\nupdate_inverse_index!(crps)\n\ncrps[\"freedom\"]\n\nm = DocumentTermMatrix(crps)\n\nD = dtm(m, :dense)\n\nT = tf_idf(D)\n\ncl = kmeans(T, 5)"
},

]}
