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
    "text": "The basic unit of text analysis is a document. The TextAnalysis package allows one to work with documents stored in a variety of formats:FileDocument : A document represented using a plain text file on disk\nStringDocument : A document represented using a UTF8 String stored in RAM\nTokenDocument : A document represented as a sequence of UTF8 tokens\nNGramDocument : A document represented as a bag of n-grams, which are UTF8 n-grams that map to countsnote: Note\nThese formats represent a hierarchy: you can always move down the hierachy, but can generally not move up the hierachy. A FileDocument can easily become a StringDocument, but an NGramDocument cannot easily become a FileDocument.Creating any of the four basic types of documents is very easy:julia> str = \"To be or not to be...\"\n\"To be or not to be...\"\n\njulia> sd = StringDocument(str)\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\n\njulia> pathname = \"/usr/share/dict/words\"\n\"/usr/share/dict/words\"\n\njulia> fd = FileDocument(pathname)\nA FileDocument\n * Language: Languages.English()\n * Title: /usr/share/dict/words\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: A A\'s AMD AMD\'s AOL AOL\'s Aachen Aachen\'s Aaliyah\n\njulia> my_tokens = String[\"To\", \"be\", \"or\", \"not\", \"to\", \"be...\"]\n6-element Array{String,1}:\n \"To\"   \n \"be\"   \n \"or\"   \n \"not\"  \n \"to\"   \n \"be...\"\n\njulia> td = TokenDocument(my_tokens)\nA TokenDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***\n\n\njulia> my_ngrams = Dict{String, Int}(\"To\" => 1, \"be\" => 2,\n                                    \"or\" => 1, \"not\" => 1,\n                                    \"to\" => 1, \"be...\" => 1)\nDict{String,Int64} with 6 entries:\n  \"or\"    => 1\n  \"be...\" => 1\n  \"not\"   => 1\n  \"to\"    => 1\n  \"To\"    => 1\n  \"be\"    => 2\n\njulia> ngd = NGramDocument(my_ngrams)\nA NGramDocument{AbstractString}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***An NGramDocument consisting of bigrams or any higher order representation N can be easily created by passing the parameter N to NGramDocumentjulia> NGramDocument(\"To be or not to be ...\", 2)\nA NGramDocument{AbstractString}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***For every type of document except a FileDocument, you can also construct a new document by simply passing in a string of text:julia> sd = StringDocument(\"To be or not to be...\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\n\njulia> td = TokenDocument(\"To be or not to be...\")\nA TokenDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***\n\njulia> ngd = NGramDocument(\"To be or not to be...\")\nA NGramDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***The system will automatically perform tokenization or n-gramization in order to produce the required data. Unfortunately, FileDocument\'s cannot be constructed this way because filenames are themselves strings. It would cause chaos if filenames were treated as the text contents of a document.That said, there is one way around this restriction: you can use the generic Document() constructor function, which will guess at the type of the inputs and construct the appropriate type of document object:julia> Document(\"To be or not to be...\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\njulia> Document(\"/usr/share/dict/words\")\nA FileDocument\n * Language: Languages.English()\n * Title: /usr/share/dict/words\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: A A\'s AMD AMD\'s AOL AOL\'s Aachen Aachen\'s Aaliyah\n\njulia> Document(String[\"To\", \"be\", \"or\", \"not\", \"to\", \"be...\"])\nA TokenDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***\n\njulia> Document(Dict{String, Int}(\"a\" => 1, \"b\" => 3))\nA NGramDocument{AbstractString}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***This constructor is very convenient for working in the REPL, but should be avoided in permanent code because, unlike the other constructors, the return type of the Document function cannot be known at compile-time."
},

{
    "location": "documents/#Basic-Functions-for-Working-with-Documents-1",
    "page": "Documents",
    "title": "Basic Functions for Working with Documents",
    "category": "section",
    "text": "Once you\'ve created a document object, you can work with it in many ways. The most obvious thing is to access its text using the text() function:julia> sd = StringDocument(\"To be or not to be...\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\n\njulia> text(sd)\n\"To be or not to be...\"note: Note\nThis function works without warnings on StringDocument\'s and FileDocument\'s. For TokenDocument\'s it is not possible to know if the text can be reconstructed perfectly, so calling text(TokenDocument(\"This is text\")) will produce a warning message before returning an approximate reconstruction of the text as it existed before tokenization. It is entirely impossible to reconstruct the text of an NGramDocument, so text(NGramDocument(\"This is text\")) raises an error.Instead of working with the text itself, you can work with the tokens or n-grams of a document using the tokens() and ngrams() functions:julia> tokens(sd)\n7-element Array{String,1}:\n \"To\"  \n \"be\"  \n \"or\"  \n \"not\"\n \"to\"  \n \"be..\"\n \".\"   \n\n julia> ngrams(sd)\n Dict{String,Int64} with 7 entries:\n  \"or\"   => 1\n  \"not\"  => 1\n  \"to\"   => 1\n  \"To\"   => 1\n  \"be\"   => 1\n  \"be..\" => 1\n  \".\"    => 1By default the ngrams() function produces unigrams. If you would like to produce bigrams or trigrams, you can specify that directly using a numeric argument to the ngrams() function:julia> ngrams(sd, 2)\nDict{AbstractString,Int64} with 13 entries:\n  \"To be\"   => 1\n  \"or not\"  => 1\n  \"be or\"   => 1\n  \"not to\"  => 1\n  \"to be..\" => 1\n  \"be.. .\"  => 1The ngrams() function can also be called with multiple arguments:julia> ngrams(sd, 2, 3)\nDict{AbstractString,Int64} with 11 entries:\n  \"or not to\"   => 1\n  \"be or\"       => 1\n  \"not to\"      => 1\n  \"be or not\"   => 1\n  \"not to be..\" => 1\n  \"To be\"       => 1\n  \"or not\"      => 1\n  \"to be.. .\"   => 1\n  \"to be..\"     => 1\n  \"be.. .\"      => 1\n  \"To be or\"    => 1If you have a NGramDocument, you can determine whether an NGramDocument contains unigrams, bigrams or a higher-order representation using the ngram_complexity() function:julia> ngd = NGramDocument(\"To be or not to be ...\", 2)\nA NGramDocument{AbstractString}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***\n\njulia> ngram_complexity(ngd)\n2This information is not available for other types of Document objects because it is possible to produce any level of complexity when constructing n-grams from raw text or tokens."
},

{
    "location": "documents/#Document-Metadata-1",
    "page": "Documents",
    "title": "Document Metadata",
    "category": "section",
    "text": "In addition to methods for manipulating the representation of the text of a document, every document object also stores basic metadata about itself, including the following pieces of information:language(): What language is the document in? Defaults to Languages.English(), a Language instance defined by the Languages package.\ntitle(): What is the title of the document? Defaults to \"Untitled Document\".\nauthor(): Who wrote the document? Defaults to \"Unknown Author\".\ntimestamp(): When was the document written? Defaults to \"Unknown Time\".Try these functions out on a StringDocument to see how the defaults work in practice:julia> StringDocument(\"This document has too foo words\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: This document has too foo words\n\njulia> language(sd)\nLanguages.English()\n\njulia> title(sd)\n\"Untitled Document\"\n\njulia> author(sd)\n\"Unknown Author\"\n\njulia> timestamp(sd)\n\"Unknown Time\"If you need reset these fields, you can use the mutating versions of the same functions:julia> language!(sd, Languages.Spanish())\nLanguages.Spanish()\n\njulia> title!(sd, \"El Cid\")\n\"El Cid\"\n\njulia> author!(sd, \"Desconocido\")\n\"Desconocido\"\n\njulia> timestamp!(sd, \"Desconocido\")\n\"Desconocido\""
},

{
    "location": "documents/#Preprocessing-Documents-1",
    "page": "Documents",
    "title": "Preprocessing Documents",
    "category": "section",
    "text": "Having easy access to the text of a document and its metadata is very important, but most text analysis tasks require some amount of preprocessing.At a minimum, your text source may contain corrupt characters. You can remove these using the remove_corrupt_utf8!() function:remove_corrupt_utf8!(sd)Alternatively, you may want to edit the text to remove items that are hard to process automatically. For example, our sample text sentence taken from Hamlet has three periods that we might like to discard. We can remove this kind of punctuation using the prepare!() function:julia> str = StringDocument(\"here are some punctuations !!!...\")\n\njulia> prepare!(str, strip_punctuation)\n\njulia> text(str)\n\"here are some punctuations \"To remove case distinctions, use remove_case!() function:\nAt times you\'ll want to remove specific words from a document like a person\'sname. To do that, use the remove_words!() function:julia> sd = StringDocument(\"Lear is mad\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: Lear is mad\n\njulia> remove_case!(sd)\n\njulia> text(sd)\n\"lear is mad\"\n\njulia> remove_words!(sd, [\"lear\"])\n\njulia> text(sd)\n\" is mad\"At other times, you\'ll want to remove whole classes of words. To make this easier, we can use several classes of basic words defined by the Languages.jl package:Articles : \"a\", \"an\", \"the\"\nIndefinite Articles : \"a\", \"an\"\nDefinite Articles : \"the\"\nPrepositions : \"across\", \"around\", \"before\", ...\nPronouns : \"I\", \"you\", \"he\", \"she\", ...\nStop Words : \"all\", \"almost\", \"alone\", ...These special classes can all be removed using specially-named parameters:prepare!(sd, strip_articles)\nprepare!(sd, strip_indefinite_articles)\nprepare!(sd, strip_definite_articles)\nprepare!(sd, strip_preposition)\nprepare!(sd, strip_pronouns)\nprepare!(sd, strip_stopwords)\nprepare!(sd, strip_numbers)\nprepare!(sd, strip_non_letters)\nprepare!(sd, strip_spares_terms)\nprepare!(sd, strip_frequent_terms)\nprepare!(sd, strip_html_tags)These functions use words lists, so they are capable of working for many different languages without change, also these operations can be combined together for improved performance:prepare!(sd, strip_articles| strip_numbers| strip_html_tags)In addition to removing words, it is also common to take words that are closely related like \"dog\" and \"dogs\" and stem them in order to produce a smaller set of words for analysis. We can do this using the stem!() function:julia> sd = StringDocument(\"They write, it writes\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: They write, it writes\n\njulia> stem!(sd)\n\njulia> text(sd)\n\"They write , it write\""
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
    "text": "Working with isolated documents gets boring quickly. We typically want to work with a collection of documents. We represent collections of documents using the Corpus type:julia> crps = Corpus([StringDocument(\"Document 1\"),\n                      StringDocument(\"Document 2\")])\nA Corpus with 2 documents:\n * 2 StringDocument\'s\n * 0 FileDocument\'s\n * 0 TokenDocument\'s\n * 0 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens"
},

{
    "location": "corpus/#Standardizing-a-Corpus-1",
    "page": "Corpus",
    "title": "Standardizing a Corpus",
    "category": "section",
    "text": "A Corpus may contain many different types of documents:julia> crps = Corpus([StringDocument(\"Document 1\"),\n                          TokenDocument(\"Document 2\"),\n                          NGramDocument(\"Document 3\")])\nA Corpus with 3 documents:\n * 1 StringDocument\'s\n * 0 FileDocument\'s\n * 1 TokenDocument\'s\n * 1 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokensIt is generally more convenient to standardize all of the documents in a corpus using a single type. This can be done using the standardize! function:julia> standardize!(crps, NGramDocument)After this step, you can check that the corpus only contains NGramDocument\'s:julia> crps\nA Corpus with 3 documents:\n * 0 StringDocument\'s\n * 0 FileDocument\'s\n * 0 TokenDocument\'s\n * 3 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens"
},

{
    "location": "corpus/#Processing-a-Corpus-1",
    "page": "Corpus",
    "title": "Processing a Corpus",
    "category": "section",
    "text": "We can apply the same sort of preprocessing steps that are defined for individual documents to an entire corpus at once:julia> crps = Corpus([StringDocument(\"Document ..!!\"),\n                          StringDocument(\"Document ..!!\")])\n\njulia> prepare!(crps, strip_punctuation)\n\njulia> text(crps[1])\n\"Document \"\n\njulia> text(crps[2])\n\"Document \"These operations are run on each document in the corpus individually."
},

{
    "location": "corpus/#Corpus-Statistics-1",
    "page": "Corpus",
    "title": "Corpus Statistics",
    "category": "section",
    "text": "Often we wish to think broadly about properties of an entire corpus at once. In particular, we want to work with two constructs:Lexicon: The lexicon of a corpus consists of all the terms that occur in any document in the corpus. The lexical frequency of a term tells us how often a term occurs across all of the documents. Often the most interesting words in a document are those words whose frequency within a document is higher than their frequency in the corpus as a whole.\nInverse Index: If we are interested in a specific term, we often want to know which documents in a corpus contain that term. The inverse index tells us this and therefore provides a simplistic sort of search algorithm.Because computations involving the lexicon can take a long time, a Corpus\'s default lexicon is blank:julia> crps = Corpus([StringDocument(\"Name Foo\"),\n                          StringDocument(\"Name Bar\")])\njulia> lexicon(crps)\nDict{String,Int64} with 0 entriesIn order to work with the lexicon, you have to update it and then access it:julia> update_lexicon!(crps)\n\njulia> lexicon(crps)\nDict{String,Int64} with 3 entries:\n  \"Bar\"    => 1\n  \"Foo\"    => 1\n  \"Name\" => 2But once this work is done, you can easier address lots of interesting questions about a corpus:julia> lexical_frequency(crps, \"Name\")\n0.5\n\njulia> lexical_frequency(crps, \"Foo\")\n0.25Like the lexicon, the inverse index for a corpus is blank by default:julia> inverse_index(crps)\nDict{String,Array{Int64,1}} with 0 entriesAgain, you need to update it before you can work with it:julia> update_inverse_index!(crps)\n\njulia> inverse_index(crps)\nDict{String,Array{Int64,1}} with 3 entries:\n  \"Bar\"    => [2]\n  \"Foo\"    => [1]\n  \"Name\" => [1, 2]But once you\'ve updated the inverse index, you can easily search the entire corpus:julia> crps[\"Name\"]\n\n2-element Array{Int64,1}:\n 1\n 2\n\njulia> crps[\"Foo\"]\n1-element Array{Int64,1}:\n 1\n\njulia> crps[\"Summer\"]\n0-element Array{Int64,1}"
},

{
    "location": "corpus/#Converting-a-DataFrame-from-a-Corpus-1",
    "page": "Corpus",
    "title": "Converting a DataFrame from a Corpus",
    "category": "section",
    "text": "Sometimes we want to apply non-text specific data analysis operations to a corpus. The easiest way to do this is to convert a Corpus object into a DataFrame:convert(DataFrame, crps)"
},

{
    "location": "corpus/#Corpus-Metadata-1",
    "page": "Corpus",
    "title": "Corpus Metadata",
    "category": "section",
    "text": "You can also retrieve the metadata for every document in a Corpus at once:languages(): What language is the document in? Defaults to Languages.English(), a Language instance defined by the Languages package.\ntitles(): What is the title of the document? Defaults to \"Untitled Document\".\nauthors(): Who wrote the document? Defaults to \"Unknown Author\".\ntimestamps(): When was the document written? Defaults to \"Unknown Time\".julia> crps = Corpus([StringDocument(\"Name Foo\"),\n                                 StringDocument(\"Name Bar\")])\n\njulia> languages(crps)\n2-element Array{Languages.English,1}:\n Languages.English()\n Languages.English()\n\njulia> titles(crps)\n2-element Array{String,1}:\n \"Untitled Document\"\n \"Untitled Document\"\n\njulia> authors(crps)\n2-element Array{String,1}:\n \"Unknown Author\"\n \"Unknown Author\"\n\njulia> timestamps(crps)\n2-element Array{String,1}:\n \"Unknown Time\"\n \"Unknown Time\"It is possible to change the metadata fields for each document in a Corpus. These functions use the same metadata value for every document:julia> languages!(crps, Languages.German())\njulia> titles!(crps, \"\")\njulia> authors!(crps, \"Me\")\njulia> timestamps!(crps, \"Now\")Additionally, you can specify the metadata fields for each document in a Corpus individually:julia> languages!(crps, [Languages.German(), Languages.English\njulia> titles!(crps, [\"\", \"Untitled\"])\njulia> authors!(crps, [\"Ich\", \"You\"])\njulia> timestamps!(crps, [\"Unbekannt\", \"2018\"])"
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
    "text": "Often we want to represent documents as a matrix of word counts so that we can apply linear algebra operations and statistical techniques. Before we do this, we need to update the lexicon:julia> crps = Corpus([StringDocument(\"To be or not to be\"),\n                             StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\nA 2 X 6 DocumentTermMatrixA DocumentTermMatrix object is a special type. If you would like to use a simple sparse matrix, call dtm() on this object:julia> dtm(m)\n2×6 SparseArrays.SparseMatrixCSC{Int64,Int64} with 10 stored entries:\n  [1, 1]  =  1\n  [2, 1]  =  1\n  [1, 2]  =  2\n  [2, 3]  =  2\n  [1, 4]  =  1\n  [2, 4]  =  1\n  [1, 5]  =  1\n  [2, 5]  =  1\n  [1, 6]  =  1\n  [2, 6]  =  1If you would like to use a dense matrix instead, you can pass this as an argument to the dtm function:julia> dtm(m, :dense)\n2×6 Array{Int64,2}:\n 1  2  0  1  1  1\n 1  0  2  1  1  1"
},

{
    "location": "features/#Creating-Individual-Rows-of-a-Document-Term-Matrix-1",
    "page": "Features",
    "title": "Creating Individual Rows of a Document Term Matrix",
    "category": "section",
    "text": "In many cases, we don\'t need the entire document term matrix at once: we can make do with just a single row. You can get this using the dtv function. Because individual\'s document do not have a lexicon associated with them, we have to pass in a lexicon as an additional argument:julia> dtv(crps[1], lexicon(crps))\n1×6 Array{Int64,2}:\n 1  2  0  1  1  1"
},

{
    "location": "features/#The-Hash-Trick-1",
    "page": "Features",
    "title": "The Hash Trick",
    "category": "section",
    "text": "The need to create a lexicon before we can construct a document term matrix is often prohibitive. We can often employ a trick that has come to be called the \"Hash Trick\" in which we replace terms with their hashed valued using a hash function that outputs integers from 1 to N. To construct such a hash function, you can use the TextHashFunction(N) constructor:julia> h = TextHashFunction(10)\nTextHashFunction(hash, 10)You can see how this function maps strings to numbers by calling the index_hash function:julia> index_hash(\"a\", h)\n8\n\njulia> index_hash(\"b\", h)\n7Using a text hash function, we can represent a document as a vector with N entries by calling the hash_dtv function:julia> hash_dtv(crps[1], h)\n1×10 Array{Int64,2}:\n 0  2  0  0  1  3  0  0  0  0This can be done for a corpus as a whole to construct a DTM without defining a lexicon in advance:julia> hash_dtm(crps, h)\n2×10 Array{Int64,2}:\n 0  2  0  0  1  3  0  0  0  0\n 0  2  0  0  1  1  0  0  2  0Every corpus has a hash function built-in, so this function can be called using just one argument:julia> hash_dtm(crps)\n2×100 Array{Int64,2}:\n 0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0\n 0  0  0  0  0  0  0  0  2  0  0  0  0     0  0  0  0  0  0  0  0  0  0  0  0Moreover, if you do not specify a hash function for just one row of the hash DTM, a default hash function will be constructed for you:julia> hash_dtv(crps[1])\n1×100 Array{Int64,2}:\n 0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0"
},

{
    "location": "features/#TF-(Term-Frequency)-1",
    "page": "Features",
    "title": "TF (Term Frequency)",
    "category": "section",
    "text": "Often we need to find out the proportion of a document is contributed by each term. This can be done by finding the term frequency functiontf(dtm)The parameter, dtm can be of the types - DocumentTermMatrix , SparseMatrixCSC or Matrixjulia> crps = Corpus([StringDocument(\"To be or not to be\"),\n              StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\n\njulia> tf(m)\n2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:\n  [1, 1]  =  0.166667\n  [2, 1]  =  0.166667\n  [1, 2]  =  0.333333\n  [2, 3]  =  0.333333\n  [1, 4]  =  0.166667\n  [2, 4]  =  0.166667\n  [1, 5]  =  0.166667\n  [2, 5]  =  0.166667\n  [1, 6]  =  0.166667\n  [2, 6]  =  0.166667"
},

{
    "location": "features/#TF-IDF-(Term-Frequency-Inverse-Document-Frequency)-1",
    "page": "Features",
    "title": "TF-IDF (Term Frequency - Inverse Document Frequency)",
    "category": "section",
    "text": "tf_idf(dtm)In many cases, raw word counts are not appropriate for use because:(A) Some documents are longer than other documents\n(B) Some words are more frequent than other wordsYou can work around this by performing TF-IDF on a DocumentTermMatrix:julia> crps = Corpus([StringDocument(\"To be or not to be\"),\n              StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\nDocumentTermMatrix(\n  [1, 1]  =  1\n  [2, 1]  =  1\n  [1, 2]  =  2\n  [2, 3]  =  2\n  [1, 4]  =  1\n  [2, 4]  =  1\n  [1, 5]  =  1\n  [2, 5]  =  1\n  [1, 6]  =  1\n  [2, 6]  =  1, [\"To\", \"be\", \"become\", \"not\", \"or\", \"to\"], Dict(\"or\"=>5,\"not\"=>4,\"to\"=>6,\"To\"=>1,\"be\"=>2,\"become\"=>3))\n\njulia> tf_idf(m)\n2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:\n  [1, 1]  =  0.0\n  [2, 1]  =  0.0\n  [1, 2]  =  0.231049\n  [2, 3]  =  0.231049\n  [1, 4]  =  0.0\n  [2, 4]  =  0.0\n  [1, 5]  =  0.0\n  [2, 5]  =  0.0\n  [1, 6]  =  0.0\n  [2, 6]  =  0.0As you can see, TF-IDF has the effect of inserting 0\'s into the columns of words that occur in all documents. This is a useful way to avoid having to remove those words during preprocessing."
},

{
    "location": "features/#Okapi-BM-25-1",
    "page": "Features",
    "title": "Okapi BM-25",
    "category": "section",
    "text": "From the document term matparamterix, Okapi BM25 document-word statistic can be created.bm_25(dtm::AbstractMatrix; κ, β)\nbm_25(dtm::DocumentTermMatrixm, κ, β)It can also be used via the following methods Overwrite the bm25 with calculated weights.bm_25!(dtm, bm25, κ, β)The inputs matrices can also be a Sparse Matrix. The parameters κ and β default to 2 and 0.75 respectively.Here is an example usage -julia> crps = Corpus([StringDocument(\"a a a sample text text\"), StringDocument(\"another example example text text\"), StringDocument(\"\"), StringDocument(\"another another text text text text\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\n\njulia> bm_25(m)\n4×5 SparseArrays.SparseMatrixCSC{Float64,Int64} with 8 stored entries:\n  [1, 1]  =  1.29959\n  [2, 2]  =  0.882404\n  [4, 2]  =  1.40179\n  [2, 3]  =  1.54025\n  [1, 4]  =  1.89031\n  [1, 5]  =  0.405067\n  [2, 5]  =  0.405067\n  [4, 5]  =  0.676646"
},

{
    "location": "features/#Co-occurrence-matrix-(COOM)-1",
    "page": "Features",
    "title": "Co occurrence matrix (COOM)",
    "category": "section",
    "text": "The elements of the Co occurrence matrix indicate how many times two words co-occur in a (sliding) word window of a given size. The COOM can be calculated for objects of type Corpus, AbstractDocument (with the exception of NGramDocument).CooMatrix(crps; window, normalize)\nCooMatrix(doc; window, normalize)It takes following keyword arguments:window::Integer -length of the Window size, defaults to 5. The actual size of the sliding window is 2 * window + 1, with the keyword argument window specifying how many words to consider to the left and right of the center one\nnormalize::Bool -normalizes counts to distance between words, defaults to trueIt returns the CooMatrix structure from which the matrix can be extracted using coom(::CooMatrix). The terms can also be extracted from this. Here is an example usage -\njulia> crps = Corpus([StringDocument(\"this is a string document\"),\n\njulia> C = CooMatrix(crps, window=1, normalize=false)\nCooMatrix{Float64}(\n  [2, 1]  =  2.0\n  [6, 1]  =  2.0\n  [1, 2]  =  2.0\n  [3, 2]  =  2.0\n  [2, 3]  =  2.0\n  [6, 3]  =  2.0\n  [5, 4]  =  4.0\n  [4, 5]  =  4.0\n  [6, 5]  =  4.0\n  [1, 6]  =  2.0\n  [3, 6]  =  2.0\n  [5, 6]  =  4.0, [\"string\", \"document\", \"token\", \"this\", \"is\", \"a\"], OrderedDict(\"string\"=>1,\"document\"=>2,\"token\"=>3,\"this\"=>4,\"is\"=>5,\"a\"=>6))\n\njulia> coom(C)\n6×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 12 stored entries:\n  [2, 1]  =  2.0\n  [6, 1]  =  2.0\n  [1, 2]  =  2.0\n  [3, 2]  =  2.0\n  [2, 3]  =  2.0\n  [6, 3]  =  2.0\n  [5, 4]  =  4.0\n  [4, 5]  =  4.0\n  [6, 5]  =  4.0\n  [1, 6]  =  2.0\n  [3, 6]  =  2.0\n  [5, 6]  =  4.0\n\njulia> C.terms\n6-element Array{String,1}:\n \"string\"\n \"document\"\n \"token\"\n \"this\"\n \"is\"\n \"a\"\nIt can also be called to calculate the terms for a specific list of words / terms in the document. In other cases it calculates the the co occurrence elements for all the terms.CooMatrix(crps, terms; window, normalize)\nCooMatrix(doc, terms; window, normalize)julia> C = CooMatrix(crps, [\"this\", \"is\", \"a\"], window=1, normalize=false)\nCooMatrix{Float64}(\n  [2, 1]  =  4.0\n  [1, 2]  =  4.0\n  [3, 2]  =  4.0\n  [2, 3]  =  4.0, [\"this\", \"is\", \"a\"], OrderedCollections.OrderedDict(\"this\"=>1,\"is\"=>2,\"a\"=>3))\nThe type can also be specified for CooMatrix with the weights of type T. T defaults to Float64.CooMatrix{T}(crps; window, normalize) where T <: AbstractFloat\nCooMatrix{T}(doc; window, normalize) where T <: AbstractFloat\nCooMatrix{T}(crps, terms; window, normalize) where T <: AbstractFloat\nCooMatrix{T}(doc, terms; window, normalize) where T <: AbstractFloatRemarks:The sliding window used to count co-occurrences does not take into consideration sentence stops however, it does with documents i.e. does not span across documents\nThe co-occurrence matrices of the documents in a corpus are summed up when calculating the matrix for an entire corpusnote: Note\nThe Co occurrence matrix does not work for NGramDocument, or a Corpus containing an NGramDocument.julia> C = CooMatrix(NGramDocument(\"A document\"), window=1, normalize=false) # fails, documents are NGramDocument\nERROR: The tokens of an NGramDocument cannot be reconstructed"
},

{
    "location": "features/#Sentiment-Analyzer-1",
    "page": "Features",
    "title": "Sentiment Analyzer",
    "category": "section",
    "text": "It can be used to find the sentiment score (between 0 and 1) of a word, sentence or a Document. A trained model (using Flux) on IMDB word corpus with weights saved are used to calculate the sentiments.model = SentimentAnalyzer(doc)\nmodel = SentimentAnalyzer(doc, handle_unknown)doc              = Input Document for calculating document (AbstractDocument type)\nhandle_unknown   = A function for handling unknown words. Should return an array (default (x)->[])"
},

{
    "location": "features/#Summarizer-1",
    "page": "Features",
    "title": "Summarizer",
    "category": "section",
    "text": "TextAnalysis offers a simple text-rank based summarizer for its various document types.summarize(d, ns)It takes 2 arguments:d : A document of type StringDocument, FileDocument or TokenDocument\nns : (Optional) Mention the number of sentences in the Summary, defaults to 5 sentences.julia> s = StringDocument(\"Assume this Short Document as an example. Assume this as an example summarizer. This has too foo sentences.\")\n\njulia> summarize(s, ns=2)\n2-element Array{SubString{String},1}:\n \"Assume this Short Document as an example.\"\n \"This has too foo sentences.\""
},

{
    "location": "features/#Tagging_schemes-1",
    "page": "Features",
    "title": "Tagging_schemes",
    "category": "section",
    "text": "There are many tagging schemes used for sequence labelling. TextAnalysis currently offers functions for conversion between these tagging format.BIO1\nBIO2\nBIOESjulia> tags = [\"I-LOC\", \"O\", \"I-PER\", \"B-MISC\", \"I-MISC\", \"B-PER\", \"I-PER\", \"I-PER\"]\n\njulia> tag_scheme!(tags, \"BIO1\", \"BIOES\")\n\njulia> tags\n8-element Array{String,1}:\n \"S-LOC\"\n \"O\"\n \"S-PER\"\n \"B-MISC\"\n \"E-MISC\"\n \"B-PER\"\n \"I-PER\"\n \"E-PER\""
},

{
    "location": "features/#Parts-of-Speech-Tagging-1",
    "page": "Features",
    "title": "Parts of Speech Tagging",
    "category": "section",
    "text": "This package provides with two different Part of Speech Tagger."
},

{
    "location": "features/#Average-Perceptron-Part-of-Speech-Tagger-1",
    "page": "Features",
    "title": "Average Perceptron Part of Speech Tagger",
    "category": "section",
    "text": "This tagger can be used to find the POS tag of a word or token in a given sentence. It is a based on Average Perceptron Algorithm. The model can be trained from scratch and weights are saved in specified location. The pretrained model can also be loaded and can be used directly to predict tags."
},

{
    "location": "features/#To-train-model:-1",
    "page": "Features",
    "title": "To train model:",
    "category": "section",
    "text": "julia> tagger = PerceptronTagger(false) #we can use tagger = PerceptronTagger()\njulia> fit!(tagger, [[(\"today\",\"NN\"),(\"is\",\"VBZ\"),(\"good\",\"JJ\"),(\"day\",\"NN\")]])\niteration : 1\niteration : 2\niteration : 3\niteration : 4\niteration : 5"
},

{
    "location": "features/#To-load-pretrained-model:-1",
    "page": "Features",
    "title": "To load pretrained model:",
    "category": "section",
    "text": "julia> tagger = PerceptronTagger(true)\nloaded successfully\nPerceptronTagger(AveragePerceptron(Set(Any[\"JJS\", \"NNP_VBZ\", \"NN_NNS\", \"CC\", \"NNP_NNS\", \"EX\", \"NNP_TO\", \"VBD_DT\", \"LS\", (\"Council\", \"NNP\")  …  \"NNPS\", \"NNP_LS\", \"VB\", \"NNS_NN\", \"NNP_SYM\", \"VBZ\", \"VBZ_JJ\", \"UH\", \"SYM\", \"NNP_NN\", \"CD\"]), Dict{Any,Any}(\"i+2 word wetlands\"=>Dict{Any,Any}(\"NNS\"=>0.0,\"JJ\"=>0.0,\"NN\"=>0.0),\"i-1 tag+i word NNP basic\"=>Dict{Any,Any}(\"JJ\"=>0.0,\"IN\"=>0.0),\"i-1 tag+i word DT chloride\"=>Dict{Any,Any}(\"JJ\"=>0.0,\"NN\"=>0.0),\"i-1 tag+i word NN choo\"=>Dict{Any,Any}(\"NNP\"=>0.0,\"NN\"=>0.0),\"i+1 word antarctica\"=>Dict{Any,Any}(\"FW\"=>0.0,\"NN\"=>0.0),\"i-1 tag+i word -START- appendix\"=>Dict{Any,Any}(\"NNP\"=>0.0,\"NNPS\"=>0.0,\"NN\"=>0.0),\"i-1 word wahoo\"=>Dict{Any,Any}(\"JJ\"=>0.0,\"VBD\"=>0.0),\"i-1 tag+i word DT children\'s\"=>Dict{Any,Any}(\"NNS\"=>0.0,\"NN\"=>0.0),\"i word dnipropetrovsk\"=>Dict{Any,Any}(\"NNP\"=>0.003,\"NN\"=>-0.003),\"i suffix hla\"=>Dict{Any,Any}(\"JJ\"=>0.0,\"NN\"=>0.0)…), DefaultDict{Any,Any,Int64}(), DefaultDict{Any,Any,Int64}(), 1, [\"-START-\", \"-START2-\"]), Dict{Any,Any}(\"is\"=>\"VBZ\",\"at\"=>\"IN\",\"a\"=>\"DT\",\"and\"=>\"CC\",\"for\"=>\"IN\",\"by\"=>\"IN\",\"Retrieved\"=>\"VBN\",\"was\"=>\"VBD\",\"He\"=>\"PRP\",\"in\"=>\"IN\"…), Set(Any[\"JJS\", \"NNP_VBZ\", \"NN_NNS\", \"CC\", \"NNP_NNS\", \"EX\", \"NNP_TO\", \"VBD_DT\", \"LS\", (\"Council\", \"NNP\")  …  \"NNPS\", \"NNP_LS\", \"VB\", \"NNS_NN\", \"NNP_SYM\", \"VBZ\", \"VBZ_JJ\", \"UH\", \"SYM\", \"NNP_NN\", \"CD\"]), [\"-START-\", \"-START2-\"], [\"-END-\", \"-END2-\"], Any[])"
},

{
    "location": "features/#To-predict-tags:-1",
    "page": "Features",
    "title": "To predict tags:",
    "category": "section",
    "text": "The perceptron tagger can predict tags over various document types-predict(tagger, sentence::String)\npredict(tagger, Tokens::Array{String, 1})\npredict(tagger, sd::StringDocument)\npredict(tagger, fd::FileDocument)\npredict(tagger, td::TokenDocument)This can also be done by -     tagger(input)julia> predict(tagger, [\"today\", \"is\"])\n2-element Array{Any,1}:\n (\"today\", \"NN\")\n (\"is\", \"VBZ\")\n\njulia> tagger([\"today\", \"is\"])\n2-element Array{Any,1}:\n (\"today\", \"NN\")\n (\"is\", \"VBZ\")PerceptronTagger(load::Bool)load      = Boolean argument if true then pretrained model is loadedfit!(self::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, save_loc::String, nr_iter::Integer)self      = PerceptronTagger object\nsentences = Vector of Vector of Tuple of pair of word or token and its POS tag [see above example]\nsave_loc  = location of file to save the trained weights\nnr_iter   = Number of iterations to pass the sentences to train the model ( default 5)predict(self::PerceptronTagger, tokens)self      = PerceptronTagger\ntokens    = Vector of words or tokens for which to predict tags"
},

{
    "location": "features/#Neural-Model-for-Part-of-Speech-tagging-using-LSTMs,-CNN-and-CRF-1",
    "page": "Features",
    "title": "Neural Model for Part of Speech tagging using LSTMs, CNN and CRF",
    "category": "section",
    "text": "The API provided is a pretrained model for tagging Part of Speech. The current model tags all the POS Tagging is done based on convention used in Penn Treebank, with 36 different Part of Speech tags excludes punctuation.To use the API, we first load the model weights into an instance of tagger. The function also accepts the path of modelweights and modeldicts (for character and word embeddings)PoSTagger()\nPoSTagger(dicts_path, weights_path)julia> pos = PoSTagger()\nnote: Note\nWhen you call PoSTagger() for the first time, the package will request permission for download the Model_dicts and Model_weights. Upon downloading, these are store locally and managed by DataDeps. So, on subsequent uses the weights will not need to be downloaded again.Once we create an instance, we can call it to tag a String (sentence), sequence of tokens, AbstractDocument or Corpus.(pos::PoSTagger)(sentence::String)\n(pos::PoSTagger)(tokens::Array{String, 1})\n(pos::PoSTagger)(sd::StringDocument)\n(pos::PoSTagger)(fd::FileDocument)\n(pos::PoSTagger)(td::TokenDocument)\n(pos::PoSTagger)(crps::Corpus)\njulia> sentence = \"This package is maintained by John Doe.\"\n\"This package is maintained by John Doe.\"\n\njulia> tags = pos(sentence)\n8-element Array{String,1}:\n \"DT\"\n \"NN\"\n \"VBZ\"\n \"VBN\"\n \"IN\"\n \"NNP\"\n \"NNP\"\n \".\"\nThe API tokenizes the input sentences via the default tokenizer provided by WordTokenizers, this currently being set to the multilingual TokTok Tokenizer.\njulia> using WordTokenizers\n\njulia> collect(zip(WordTokenizers.tokenize(sentence), tags))\n8-element Array{Tuple{String,String},1}:\n (\"This\", \"DT\")\n (\"package\", \"NN\")\n (\"is\", \"VBZ\")\n (\"maintained\", \"VBN\")\n (\"by\", \"IN\")\n (\"John\", \"NNP\")\n (\"Doe\", \"NNP\")\n (\".\", \".\")\nFor tagging a multisentence text or document, once can use split_sentences from WordTokenizers.jl package and run the pos model on each.julia> sentences = \"Rabinov is winding up his term as ambassador. He will be replaced by Eliahu Ben-Elissar, a former Israeli envoy to Egypt and right-wing Likud party politiian.\" # Sentence taken from CoNLL 2003 Dataset\n\njulia> splitted_sents = WordTokenizers.split_sentences(sentences)\n\njulia> tag_sequences = pos.(splitted_sents)\n2-element Array{Array{String,1},1}:\n [\"NNP\", \"VBZ\", \"VBG\", \"RP\", \"PRP\\$\", \"NN\", \"IN\", \"NN\", \".\"]\n [\"PRP\", \"MD\", \"VB\", \"VBN\", \"IN\", \"NNP\", \"NNP\", \",\", \"DT\", \"JJ\", \"JJ\", \"NN\", \"TO\", \"NNP\", \"CC\", \"JJ\", \"NNP\", \"NNP\", \"NNP\", \".\"]\n\njulia> zipped = [collect(zip(tag_sequences[i], WordTokenizers.tokenize(splitted_sents[i]))) for i in eachindex(splitted_sents)]\n\njulia> zipped[1]\n9-element Array{Tuple{String,String},1}:\n (\"NNP\", \"Rabinov\")\n (\"VBZ\", \"is\")\n (\"VBG\", \"winding\")\n (\"RP\", \"up\")\n (\"PRP\\$\", \"his\")\n (\"NN\", \"term\")\n (\"IN\", \"as\")\n (\"NN\", \"ambassador\")\n (\".\", \".\")\n\njulia> zipped[2]\n20-element Array{Tuple{String,String},1}:\n (\"PRP\", \"He\")\n (\"MD\", \"will\")\n (\"VB\", \"be\")\n (\"VBN\", \"replaced\")\n (\"IN\", \"by\")\n (\"NNP\", \"Eliahu\")\n (\"NNP\", \"Ben-Elissar\")\n (\",\", \",\")\n (\"DT\", \"a\")\n (\"JJ\", \"former\")\n (\"JJ\", \"Israeli\")\n (\"NN\", \"envoy\")\n (\"TO\", \"to\")\n (\"NNP\", \"Egypt\")\n (\"CC\", \"and\")\n (\"JJ\", \"right-wing\")\n (\"NNP\", \"Likud\")\n (\"NNP\", \"party\")\n (\"NNP\", \"politiian\")\n (\".\", \".\")\nSince the tagging the Part of Speech is done on sentence level, the text of AbstractDocument is sentence_tokenized and then labelled for over sentence. However is not possible for NGramDocument as text cannot be recreated. For TokenDocument, text is approximated for splitting into sentences, hence the following throws a warning when tagging the Corpus.\njulia> crps = Corpus([StringDocument(\"We aRE vErY ClOSE tO ThE HEaDQuarTeRS.\"), TokenDocument(\"this is Bangalore.\")])\nA Corpus with 2 documents:\n * 1 StringDocument\'s\n * 0 FileDocument\'s\n * 1 TokenDocument\'s\n * 0 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\n\njulia> pos(crps)\n┌ Warning: TokenDocument\'s can only approximate the original text\n└ @ TextAnalysis ~/.julia/dev/TextAnalysis/src/document.jl:220\n2-element Array{Array{Array{String,1},1},1}:\n [[\"PRP\", \"VBP\", \"RB\", \"JJ\", \"TO\", \"DT\", \"NN\", \".\"]]\n [[\"DT\", \"VBZ\", \"NNP\", \".\"]]\n"
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
    "text": "Often we want to think about documents from the perspective of semantic content. One standard approach to doing this, is to perform Latent Semantic Analysis or LSA on the corpus.lsa(crps)\nlsa(dtm)lsa uses tf_idf for statistics.julia> crps = Corpus([StringDocument(\"this is a string document\"), TokenDocument(\"this is a token document\")])\n\njulia> F1.lsa(crps)\nLinearAlgebra.SVD{Float64,Float64,Array{Float64,2}}([1.0 0.0; 0.0 1.0], [0.138629, 0.138629], [0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 1.0])lsa can also be performed on a DocumentTermMatrix.julia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\nA 2 X 6 DocumentTermMatrix\n\njulia> F2 = lsa(m)\nSVD{Float64,Float64,Array{Float64,2}}([1.0 0.0; 0.0 1.0], [0.138629, 0.138629], [0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 1.0])"
},

{
    "location": "semantic/#LDA:-Latent-Dirichlet-Allocation-1",
    "page": "Semantic Analysis",
    "title": "LDA: Latent Dirichlet Allocation",
    "category": "section",
    "text": "Another way to get a handle on the semantic content of a corpus is to use Latent Dirichlet Allocation:First we need to produce the DocumentTermMatrixjulia> crps = Corpus([StringDocument(\"This is the Foo Bar Document\"), StringDocument(\"This document has too Foo words\")])\njulia> update_lexicon!(crps)\njulia> m = DocumentTermMatrix(crps)Latent Dirchlet Allocation has two hyper parameters -α : The hyperparameter for topic distribution per document. α<1 yields a sparse topic mixture for each document. α>1 yields a more uniform topic mixture for each document.\nβ : The hyperparameter for word distribution per topic. β<1 yields a sparse word mixture for each topic. β>1 yields a more uniform word mixture for each topic.julia> k = 2            # number of topics\njulia> iterations = 1000 # number of gibbs sampling iterations\n\njulia> α = 0.1      # hyper parameter\njulia> β  = 0.1       # hyper parameter\n\njulia> ϕ, θ  = lda(m, k, iterations, α, β)\n(\n  [2 ,  1]  =  0.333333\n  [2 ,  2]  =  0.333333\n  [1 ,  3]  =  0.222222\n  [1 ,  4]  =  0.222222\n  [1 ,  5]  =  0.111111\n  [1 ,  6]  =  0.111111\n  [1 ,  7]  =  0.111111\n  [2 ,  8]  =  0.333333\n  [1 ,  9]  =  0.111111\n  [1 , 10]  =  0.111111, [0.5 1.0; 0.5 0.0])See ?lda for more help."
},

{
    "location": "classify/#",
    "page": "Classifier",
    "title": "Classifier",
    "category": "page",
    "text": ""
},

{
    "location": "classify/#Classifier-1",
    "page": "Classifier",
    "title": "Classifier",
    "category": "section",
    "text": "Text Analysis currently offers a Naive Bayes Classifier for text classification.To load the Naive Bayes Classifier, use the following command -using TextAnalysis: NaiveBayesClassifier, fit!, predict"
},

{
    "location": "classify/#Basic-Usage-1",
    "page": "Classifier",
    "title": "Basic Usage",
    "category": "section",
    "text": "Its usage can be done in the following 3 steps.1- Create an instance of the Naive Bayes Classifier model -model = NaiveBayesClassifier(dict, classes)It takes two arguments-classes: An array of possible classes that the concerned data could belong to.\ndict:(Optional Argument) An Array of possible tokens (words). This is automatically updated if a new token is detected in the Step 2) or 3)2- Fitting the model weights on input -fit!(model, str, class)3- Predicting for the input case -predict(model, str)"
},

{
    "location": "classify/#Example-1",
    "page": "Classifier",
    "title": "Example",
    "category": "section",
    "text": "julia> m = NaiveBayesClassifier([:legal, :financial])\nNaiveBayesClassifier{Symbol}(String[], Symbol[:legal, :financial], Array{Int64}(0,2))julia> fit!(m, \"this is financial doc\", :financial)\nNaiveBayesClassifier{Symbol}([\"financial\", \"this\", \"is\", \"doc\"], Symbol[:legal, :financial], [1 2; 1 2; 1 2; 1 2])\n\njulia> fit!(m, \"this is legal doc\", :legal)\nNaiveBayesClassifier{Symbol}([\"financial\", \"this\", \"is\", \"doc\", \"legal\"], Symbol[:legal, :financial], [1 2; 2 2; … ; 2 2; 2 1])julia> predict(m, \"this should be predicted as a legal document\")\nDict{Symbol,Float64} with 2 entries:\n  :legal     => 0.666667\n  :financial => 0.333333"
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
    "text": "To show you how text analysis might work in practice, we\'re going to work with a text corpus composed of political speeches from American presidents given as part of the State of the Union Address tradition.using TextAnalysis, MultivariateStats, Clustering\n\ncrps = DirectoryCorpus(\"sotu\")\n\nstandardize!(crps, StringDocument)\n\ncrps = Corpus(crps[1:30])\n\nremove_case!(crps)\nprepare!(crps, strip_punctuation)\n\nupdate_lexicon!(crps)\nupdate_inverse_index!(crps)\n\ncrps[\"freedom\"]\n\nm = DocumentTermMatrix(crps)\n\nD = dtm(m, :dense)\n\nT = tf_idf(D)\n\ncl = kmeans(T, 5)"
},

{
    "location": "evaluation_metrics/#",
    "page": "Evaluation Metrics",
    "title": "Evaluation Metrics",
    "category": "page",
    "text": ""
},

{
    "location": "evaluation_metrics/#Evaluation-Metrics-1",
    "page": "Evaluation Metrics",
    "title": "Evaluation Metrics",
    "category": "section",
    "text": "Natural Language Processing tasks require certain Evaluation Metrics. As of now TextAnalysis provides the following evaluation metrics.ROUGE-N\nROUGE-L"
},

{
    "location": "evaluation_metrics/#ROUGE-N-1",
    "page": "Evaluation Metrics",
    "title": "ROUGE-N",
    "category": "section",
    "text": "This metric evaluatrion based on the overlap of N-grams between the system and reference summaries.rouge_n(references, candidate, n; avg, lang)The function takes the following arguments -references::Array{T} where T<: AbstractString = The list of reference summaries.\ncandidate::AbstractString = Input candidate summary, to be scored against reference summaries.\nn::Integer = Order of NGrams\navg::Bool = Setting this parameter to true, applies jackkniving the calculated scores. Defaults to true\nlang::Language = Language of the text, usefule while generating N-grams. Defaults to English i.e. Languages.English()julia> candidate_summary =  \"Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits.\"\n\"Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits.\"\n\njulia> reference_summaries = [\"Brazil, Russia, India and China are the next big poltical powers in the global economy. Together referred to as BRIC(S) along with South Korea.\", \"Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit.\"]\n2-element Array{String,1}:\n \"Brazil, Russia, India and China are the next big poltical powers in the global economy. Together referred to as BRIC(S) along with South Korea.\"\n \"Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit.\"                                    \n\njulia> rouge_n(reference_summaries, candidate_summary, 2, avg=true)\n0.1317241379310345\n\njulia> rouge_n(reference_summaries, candidate_summary, 1, avg=true)\n0.5051282051282051"
},

{
    "location": "crf/#",
    "page": "Conditional Random Fields",
    "title": "Conditional Random Fields",
    "category": "page",
    "text": ""
},

{
    "location": "crf/#Conditional-Random-Fields-1",
    "page": "Conditional Random Fields",
    "title": "Conditional Random Fields",
    "category": "section",
    "text": "This package currently provides support for Linear Chain Conditional Random Fields.Let us first load the dependencies-using Flux\nusing Flux: onehot, train!, Params, gradient, LSTM, Dense, reset!\nusing TextAnalysis: CRF, viterbi_decode, crf_lossConditional Random Field layer is essentially like a softmax that operates on the top most layer.Let us suppose the following input seqeunce to the CRF with NUM_LABELS = 2julia> SEQUENCE_LENGTH = 2 # CRFs can handle variable length inputs sequences\njulia> input_seq = [rand(NUM_LABELS + 2) for i in 1:SEQUENCE_LENGTH] # NUM_LABELS + 2, where two exra features correspond to the :START and :END label.\n2-element Array{Array{Float64,1},1}:\n [0.523462, 0.455434, 0.274347, 0.755279]\n [0.610991, 0.315381, 0.0863632, 0.693031]\nWe define our crf layer as -CRF(NUM_LABELS::Integer)julia> c = CRF(NUM_LABELS) # The API internally append the START and END tags to NUM_LABELS.\nCRF with 4 distinct tags (including START and STOP tags).Now as for the initial variable in Viterbi Decode or Forward Algorithm, we define our input asjulia>  init_α = fill(-10000, (c.n + 2, 1))\njulia>  init_α[c.n + 1] = 0Optionally this could be shifted to GPU by init_α = gpu(init_α), considering the input sequence to be CuArray in this case. To shift a CRF c to gpu, one can use c = gpu(c).To find out the crf loss, we use the following function -crf_loss(c::CRF, input_seq, label_sequence, init_α)julia> label_seq1 = [onehot(1, 1:2), onehot(1, 1:2)]\n\njulia> label_seq2 = [onehot(1, 1:2), onehot(2, 1:2)]\n\njulia> label_seq3 = [onehot(2, 1:2), onehot(1, 1:2)]\n\njulia> label_seq4 = [onehot(2, 1:2), onehot(2, 1:2)]\n\njulia> crf_loss(c, input_seq, label_seq1, init_α)\n1.9206894963901504 (tracked)\n\njulia> crf_loss(c, input_seq, label_seq2, init_α)\n1.4972745472075206 (tracked)\n\njulia> crf_loss(c, input_seq, label_seq3, init_α)\n1.543210471592448 (tracked)\n\njulia> crf_loss(c, input_seq, label_seq4, init_α)\n0.876923329893466 (tracked)\nWe can decode this using Viterbi Decode.viterbi_decode(c::CRF, input_seq, init_α)julia> viterbi_decode(c, input_seq, init_α) # Gives the label_sequence with least loss\n2-element Array{Flux.OneHotVector,1}:\n [false, true]\n [false, true]\nThis algorithm decodes for the label sequence with lowest loss value in polynomial time.Currently the Viterbi Decode only support cpu arrays. When working with GPU, use viterbi_decode as followsviterbi_decode(cpu(c), cpu.(input_seq), cpu(init_α))"
},

{
    "location": "crf/#Working-with-Flux-layers-1",
    "page": "Conditional Random Fields",
    "title": "Working with Flux layers",
    "category": "section",
    "text": "CRFs smoothly work over Flux layers-julia> NUM_FEATURES = 20\n\njulia> input_seq = [rand(NUM_FEATURES) for i in 1:SEQUENCE_LENGTH]\n2-element Array{Array{Float64,1},1}:\n [0.948219, 0.719964, 0.352734, 0.0677656, 0.570564, 0.187673, 0.525125, 0.787807, 0.262452, 0.472472, 0.573259, 0.643369, 0.00592054, 0.945258, 0.951466, 0.323156, 0.679573, 0.663285, 0.218595, 0.152846]\n [0.433295, 0.11998, 0.99615, 0.530107, 0.188887, 0.897213, 0.993726, 0.0799431, 0.953333, 0.941808, 0.982638, 0.0919345, 0.27504, 0.894169, 0.66818, 0.449537, 0.93063, 0.384957, 0.415114, 0.212203]\n\njulia> m1 = Dense(NUM_FEATURES, NUM_LABELS + 2)\n\njulia> loss1(input_seq, label_seq) = crf_loss(c, m1.(input_seq), label_seq, init_α) # loss for model m1\n\njulia> loss1(input_seq,  [onehot(1, 1:2), onehot(1, 1:2)])\n4.6620379898687485 (tracked)\nHere is an example of CRF with LSTM and Dense layer -julia> LSTM_SIZE = 10\n\njulia> lstm = LSTM(NUM_FEATURES, LSTM_SIZE)\n\njulia> dense_out = Dense(LSTM_SIZE, NUM_LABELS + 2)\n\njulia> m2(x) = dense_out.(lstm.(x))\n\njulia> loss2(input_seq, label_seq) = crf_loss(c, m2(input_seq), label_seq, init_α) # loss for model m2\n\njulia> loss2(input_seq,  [onehot(1, 1:2), onehot(1, 1:2)])\n1.6501050910529504 (tracked)\n\njulia> reset!(lstm)"
},

{
    "location": "ner/#",
    "page": "Named Entity Recognition",
    "title": "Named Entity Recognition",
    "category": "page",
    "text": ""
},

{
    "location": "ner/#Named-Entity-Recognition-1",
    "page": "Named Entity Recognition",
    "title": "Named Entity Recognition",
    "category": "section",
    "text": "The API provided is a pretrained model for tagging Named Entities. The current model support 4 types of Named Entities -PER: Person\nLOC: Location\nORG: Organisation\nMISC: Miscellaneous\nO: Not a Named EntityTo use the API, we first load the model weights into an instance of tagger. The function also accepts the path of modelweights and modeldicts (for character and word embeddings)NERTagger()\nNERTagger(dicts_path, weights_path)julia> ner = NERTagger()note: Note\nWhen you call NERTagger() for the first time, the package will request permission for download the Model_dicts and Model_weights. Upon downloading, these are store locally and managed by DataDeps. So, on subsequent uses the weights will not need to be downloaded again.Once we create an instance, we can call it to tag a String (sentence), sequence of tokens, AbstractDocument or Corpus.(ner::NERTagger)(sentence::String)\n(ner::NERTagger)(tokens::Array{String, 1})\n(ner::NERTagger)(sd::StringDocument)\n(ner::NERTagger)(fd::FileDocument)\n(ner::NERTagger)(td::TokenDocument)\n(ner::NERTagger)(crps::Corpus)julia> sentence = \"This package is maintained by John Doe.\"\n\"This package is maintained by John Doe.\"\n\njulia> tags = ner(sentence)\n8-element Array{String,1}:\n \"O\"\n \"O\"\n \"O\"\n \"O\"\n \"O\"\n \"PER\"\n \"PER\"\n \"O\"\nThe API tokenizes the input sentences via the default tokenizer provided by WordTokenizers, this currently being set to the multilingual TokTok Tokenizer.julia> using WordTokenizers\n\njulia> collect(zip(WordTokenizers.tokenize(sentence), tags))\n8-element Array{Tuple{String,String},1}:\n (\"This\", \"O\")\n (\"package\", \"O\")\n (\"is\", \"O\")\n (\"maintained\", \"O\")\n (\"by\", \"O\")\n (\"John\", \"PER\")\n (\"Doe\", \"PER\")\n (\".\", \"O\")\nFor tagging a multisentence text or document, once can use split_sentences from WordTokenizers.jl package and run the ner model on each.julia> sentences = \"Rabinov is winding up his term as ambassador. He will be replaced by Eliahu Ben-Elissar, a former Israeli envoy to Egypt and right-wing Likud party politiian.\" # Sentence taken from CoNLL 2003 Dataset\n\njulia> splitted_sents = WordTokenizers.split_sentences(sentences)\n\njulia> tag_sequences = ner.(splitted_sents)\n2-element Array{Array{String,1},1}:\n [\"PER\", \"O\", \"O\", \"O\", \"O\", \"O\", \"O\", \"O\", \"O\"]\n [\"O\", \"O\", \"O\", \"O\", \"O\", \"PER\", \"PER\", \"O\", \"O\", \"O\", \"MISC\", \"O\", \"O\", \"LOC\", \"O\", \"O\", \"ORG\", \"ORG\", \"O\", \"O\"]\n\njulia> zipped = [collect(zip(tag_sequences[i], WordTokenizers.tokenize(splitted_sents[i]))) for i in eachindex(splitted_sents)]\n\njulia> zipped[1]\n9-element Array{Tuple{String,String},1}:\n (\"PER\", \"Rabinov\")\n (\"O\", \"is\")\n (\"O\", \"winding\")\n (\"O\", \"up\")\n (\"O\", \"his\")\n (\"O\", \"term\")\n (\"O\", \"as\")\n (\"O\", \"ambassador\")\n (\"O\", \".\")\n\njulia> zipped[2]\n20-element Array{Tuple{String,String},1}:\n (\"O\", \"He\")\n (\"O\", \"will\")\n (\"O\", \"be\")\n (\"O\", \"replaced\")\n (\"O\", \"by\")\n (\"PER\", \"Eliahu\")\n (\"PER\", \"Ben-Elissar\")\n (\"O\", \",\")\n (\"O\", \"a\")\n (\"O\", \"former\")\n (\"MISC\", \"Israeli\")\n (\"O\", \"envoy\")\n (\"O\", \"to\")\n (\"LOC\", \"Egypt\")\n (\"O\", \"and\")\n (\"O\", \"right-wing\")\n (\"ORG\", \"Likud\")\n (\"ORG\", \"party\")\n (\"O\", \"politiian\")\n (\"O\", \".\")Since the tagging the Named Entities is done on sentence level, the text of AbstractDocument is sentence_tokenized and then labelled for over sentence. However is not possible for NGramDocument as text cannot be recreated. For TokenDocument, text is approximated for splitting into sentences, hence the following throws a warning when tagging the Corpus.julia> crps = Corpus([StringDocument(\"We aRE vErY ClOSE tO ThE HEaDQuarTeRS.\"), TokenDocument(\"this is Bangalore.\")])\nA Corpus with 2 documents:\n * 1 StringDocument\'s\n * 0 FileDocument\'s\n * 1 TokenDocument\'s\n * 0 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\n\njulia> ner(crps)\n┌ Warning: TokenDocument\'s can only approximate the original text\n└ @ TextAnalysis ~/.julia/dev/TextAnalysis/src/document.jl:220\n2-element Array{Array{Array{String,1},1},1}:\n [[\"O\", \"O\", \"O\", \"O\", \"O\", \"O\", \"O\", \"O\"]]\n [[\"O\", \"O\", \"LOC\", \"O\"]]"
},

{
    "location": "APIReference/#",
    "page": "API References",
    "title": "API References",
    "category": "page",
    "text": ""
},

{
    "location": "APIReference/#TextAnalysis.DirectoryCorpus-Tuple{AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.DirectoryCorpus",
    "category": "method",
    "text": "DirectoryCorpus(dirname::AbstractString)\n\nConstruct a Corpus from a directory of text files.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.author!-Tuple{AbstractDocument,AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.author!",
    "category": "method",
    "text": "author!(doc, author)\n\nSet the author metadata of doc to author.\n\nSee also: author, authors, authors!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.author-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.author",
    "category": "method",
    "text": "author(doc)\n\nReturn the author metadata for doc.\n\nSee also: author!, authors, authors!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.authors!-Tuple{Corpus,Array{String,1}}",
    "page": "API References",
    "title": "TextAnalysis.authors!",
    "category": "method",
    "text": "authors!(crps, athrs)\nauthors!(crps, athr)\n\nSet the authors of the documents in crps to the athrs, respectively.\n\nSee also: authors, author!, author\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.authors-Tuple{Corpus}",
    "page": "API References",
    "title": "TextAnalysis.authors",
    "category": "method",
    "text": "authors(crps)\n\nReturn the authors for each document in crps.\n\nSee also: authors!, author, author!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.coom-Tuple{CooMatrix}",
    "page": "API References",
    "title": "TextAnalysis.coom",
    "category": "method",
    "text": "coom(c::CooMatrix)\n\nAccess the co-occurrence matrix field coom of a CooMatrix c.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.coom-Union{Tuple{Any}, Tuple{T}, Tuple{Any,Type{T}}} where T<:AbstractFloat",
    "page": "API References",
    "title": "TextAnalysis.coom",
    "category": "method",
    "text": "coom(entity, eltype=DEFAULT_FLOAT_TYPE [;window=5, normalize=true])\n\nAccess the co-occurrence matrix of the CooMatrix associated with the entity. The CooMatrix{T} will first have to be created in order for the actual matrix to be accessed.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.dtm-Tuple{DocumentTermMatrix,Symbol}",
    "page": "API References",
    "title": "TextAnalysis.dtm",
    "category": "method",
    "text": "dtm(crps::Corpus)\ndtm(d::DocumentTermMatrix)\ndtm(d::DocumentTermMatrix, density::Symbol)\n\nCreates a simple sparse matrix of DocumentTermMatrix object.\n\nExamples\n\njulia> crps = Corpus([StringDocument(\"To be or not to be\"),\n                      StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> dtm(DocumentTermMatrix(crps))\n2×6 SparseArrays.SparseMatrixCSC{Int64,Int64} with 10 stored entries:\n  [1, 1]  =  1\n  [2, 1]  =  1\n  [1, 2]  =  2\n  [2, 3]  =  2\n  [1, 4]  =  1\n  [2, 4]  =  1\n  [1, 5]  =  1\n  [2, 5]  =  1\n  [1, 6]  =  1\n  [2, 6]  =  1\n\njulia> dtm(DocumentTermMatrix(crps), :dense)\n2×6 Array{Int64,2}:\n 1  2  0  1  1  1\n 1  0  2  1  1  1\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.dtv-Tuple{AbstractDocument,Dict{String,Int64}}",
    "page": "API References",
    "title": "TextAnalysis.dtv",
    "category": "method",
    "text": "dtv(d::AbstractDocument, lex::Dict{String, Int})\n\nProduce a single row of a DocumentTermMatrix.\n\nIndividual documents do not have a lexicon associated with them, we have to pass in a lexicon as an additional argument.\n\nExamples\n\njulia> dtv(crps[1], lexicon(crps))\n1×6 Array{Int64,2}:\n 1  2  0  1  1  1\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.fit!-Tuple{NaiveBayesClassifier,AbstractArray{T,1} where T<:Integer,Any}",
    "page": "API References",
    "title": "TextAnalysis.fit!",
    "category": "method",
    "text": "fit!(model::NaiveBayesClassifier, str, class)\nfit!(model::NaiveBayesClassifier, ::Features, class)\n\nFit the weights for the model on the input data.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.fit!-Tuple{PerceptronTagger,Array{Array{Tuple{String,String},1},1},String,Integer}",
    "page": "API References",
    "title": "TextAnalysis.fit!",
    "category": "method",
    "text": "fit!(::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, save_loc::String, nr_iter::Integer)\n\nUsed for training a new model or can be used for training an existing model by using pretrained weigths and classes\n\nContains main training loop for number of epochs. After training weights, tagdict and classes are stored in the specified location.\n\nArguments:\n\n::PerceptronTagger : Input PerceptronTagger model\nsentences::Vector{Vector{Tuple{String, String}}} : Array of the all token seqeunces with target POS tag\nsave_loc::String : To specify the saving location\nnr_iter::Integer : Total number of training iterations for given sentences(or number of epochs)\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.frequent_terms",
    "page": "API References",
    "title": "TextAnalysis.frequent_terms",
    "category": "function",
    "text": "frequent_terms(crps, alpha=0.95)\n\nFind the frequent terms from Corpus, occuring more than alpha percentage of the documents.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"This is Document 1\"),\n                      StringDocument(\"This is Document 2\")])\nA Corpus with 2 documents:\n * 2 StringDocument\'s\n * 0 FileDocument\'s\n * 0 TokenDocument\'s\n * 0 NGramDocument\'s\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\njulia> frequent_terms(crps)\n3-element Array{String,1}:\n \"is\"\n \"This\"\n \"Document\"\n\nSee also: remove_frequent_terms!, sparse_terms\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.hash_dtm-Tuple{Corpus,TextHashFunction}",
    "page": "API References",
    "title": "TextAnalysis.hash_dtm",
    "category": "method",
    "text": "hash_dtm(crps::Corpus)\nhash_dtm(crps::Corpus, h::TextHashFunction)\n\nRepresents a Corpus as a Matrix with N entries.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.hash_dtv-Tuple{AbstractDocument,TextHashFunction}",
    "page": "API References",
    "title": "TextAnalysis.hash_dtv",
    "category": "method",
    "text": "hash_dtv(d::AbstractDocument)\nhash_dtv(d::AbstractDocument, h::TextHashFunction)\n\nRepresents a document as a vector with N entries.\n\nExamples\n\njulia> crps = Corpus([StringDocument(\"To be or not to be\"),\n                      StringDocument(\"To become or not to become\")])\n\njulia> h = TextHashFunction(10)\nTextHashFunction(hash, 10)\n\njulia> hash_dtv(crps[1], h)\n1×10 Array{Int64,2}:\n 0  2  0  0  1  3  0  0  0  0\n\njulia> hash_dtv(crps[1])\n1×100 Array{Int64,2}:\n 0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.index_hash-Tuple{AbstractString,TextHashFunction}",
    "page": "API References",
    "title": "TextAnalysis.index_hash",
    "category": "method",
    "text": "index_hash(str, TextHashFunc)\n\nShows mapping of string to integer.\n\nParameters: 	-  str		   = Max index used for hashing (default 100)  	-  TextHashFunc    = TextHashFunction type object\n\njulia> h = TextHashFunction(10)\nTextHashFunction(hash, 10)\n\njulia> index_hash(\"a\", h)\n8\n\njulia> index_hash(\"b\", h)\n7\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.inverse_index-Tuple{Corpus}",
    "page": "API References",
    "title": "TextAnalysis.inverse_index",
    "category": "method",
    "text": "inverse_index(crps::Corpus)\n\nShows the inverse index of a corpus.\n\nIf we are interested in a specific term, we often want to know which documents in a corpus contain that term. The inverse index tells us this and therefore provides a simplistic sort of search algorithm.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.language!-Tuple{AbstractDocument,Languages.Language}",
    "page": "API References",
    "title": "TextAnalysis.language!",
    "category": "method",
    "text": "language!(doc, lang::Language)\n\nSet the language of doc to lang.\n\nExample\n\njulia> d = StringDocument(\"String Document 1\")\n\njulia> language!(d, Languages.Spanish())\n\njulia> d.metadata.language\nLanguages.Spanish()\n\nSee also: language, languages, languages!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.language-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.language",
    "category": "method",
    "text": "language(doc)\n\nReturn the language metadata for doc.\n\nSee also: language!, languages, languages!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.languages!-Union{Tuple{T}, Tuple{Corpus,Array{T,1}}} where T<:Languages.Language",
    "page": "API References",
    "title": "TextAnalysis.languages!",
    "category": "method",
    "text": "languages!(crps, langs::Vector{Language})\nlanguages!(crps, lang::Language)\n\nUpdate languages of documents in a Corpus.\n\nIf the input is a Vector, then language of the ith document is set to the ith element in the vector, respectively. However, the number of documents must equal the length of vector.\n\nSee also: languages, language!, language\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.languages-Tuple{Corpus}",
    "page": "API References",
    "title": "TextAnalysis.languages",
    "category": "method",
    "text": "languages(crps)\n\nReturn the languages for each document in crps.\n\nSee also: languages!, language, language!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.lda-Tuple{DocumentTermMatrix,Int64,Int64,Float64,Float64}",
    "page": "API References",
    "title": "TextAnalysis.lda",
    "category": "method",
    "text": "ϕ, θ = lda(dtm::DocumentTermMatrix, ntopics::Int, iterations::Int, α::Float64, β::Float64)\n\nPerform Latent Dirichlet allocation.\n\nArguments\n\nα Dirichlet dist. hyperparameter for topic distribution per document. α<1 yields a sparse topic mixture for each document. α>1 yields a more uniform topic mixture for each document.\nβ Dirichlet dist. hyperparameter for word distribution per topic. β<1 yields a sparse word mixture for each topic. β>1 yields a more uniform word mixture for each topic.\n\nReturn values\n\nϕ: ntopics × nwords Sparse matrix of probabilities s.t. sum(ϕ, 1) == 1\nθ: ntopics × ndocs Dense matrix of probabilities s.t. sum(θ, 1) == 1\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.lexical_frequency-Tuple{Corpus,AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.lexical_frequency",
    "category": "method",
    "text": "lexical_frequency(crps::Corpus, term::AbstractString)\n\nTells us how often a term occurs across all of the documents.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.lexicon-Tuple{Corpus}",
    "page": "API References",
    "title": "TextAnalysis.lexicon",
    "category": "method",
    "text": "lexicon(crps::Corpus)\n\nShows the lexicon of the corpus.\n\nLexicon of a corpus consists of all the terms that occur in any document in the corpus.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"Name Foo\"),\n                          StringDocument(\"Name Bar\")])\nA Corpus with 2 documents:\n* 2 StringDocument\'s\n* 0 FileDocument\'s\n* 0 TokenDocument\'s\n* 0 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\n\njulia> lexicon(crps)\nDict{String,Int64} with 0 entries\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.lexicon_size-Tuple{Corpus}",
    "page": "API References",
    "title": "TextAnalysis.lexicon_size",
    "category": "method",
    "text": "lexicon_size(crps::Corpus)\n\nTells the total number of terms in a lexicon.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.lsa-Tuple{DocumentTermMatrix}",
    "page": "API References",
    "title": "TextAnalysis.lsa",
    "category": "method",
    "text": "lsa(dtm::DocumentTermMatrix)\nlsa(crps::Corpus)\n\nPerforms Latent Semantic Analysis or LSA on a corpus.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.ngrams-Tuple{NGramDocument,Integer}",
    "page": "API References",
    "title": "TextAnalysis.ngrams",
    "category": "method",
    "text": "ngrams(ngd::NGramDocument, n::Integer)\nngrams(d::AbstractDocument, n::Integer)\nngrams(d::NGramDocument)\nngrams(d::AbstractDocument)\n\nAccess the document text as n-gram counts.\n\nExample\n\njulia> sd = StringDocument(\"To be or not to be...\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\n\njulia> ngrams(sd)\n Dict{String,Int64} with 7 entries:\n  \"or\"   => 1\n  \"not\"  => 1\n  \"to\"   => 1\n  \"To\"   => 1\n  \"be\"   => 1\n  \"be..\" => 1\n  \".\"    => 1\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.predict-Tuple{NaiveBayesClassifier,AbstractArray{T,1} where T<:Integer}",
    "page": "API References",
    "title": "TextAnalysis.predict",
    "category": "method",
    "text": "predict(::NaiveBayesClassifier, str)\npredict(::NaiveBayesClassifier, ::Features)\n\nPredict probabilities for each class on the input Features or String.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.predict-Tuple{PerceptronTagger,Array{String,1}}",
    "page": "API References",
    "title": "TextAnalysis.predict",
    "category": "method",
    "text": "predict(::PerceptronTagger, tokens)\npredict(::PerceptronTagger, sentence)\n\nUsed for predicting the tags for given sentence or array of tokens\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.predict-Tuple{TextAnalysis.AveragePerceptron,Any}",
    "page": "API References",
    "title": "TextAnalysis.predict",
    "category": "method",
    "text": "Predicting the class using current weights by doing Dot-product of features and weights and return the scores\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.prepare!-Tuple{Corpus,UInt32}",
    "page": "API References",
    "title": "TextAnalysis.prepare!",
    "category": "method",
    "text": "prepare!(doc, flags)\nprepare!(crps, flags)\n\nPreprocess document or corpus based on the input flags.\n\nList of Flags\n\nstrip_patterns\nstripcorruptutf8\nstrip_case\nstem_words\ntagpartof_speech\nstrip_whitespace\nstrip_punctuation\nstrip_numbers\nstripnonletters\nstripindefinitearticles\nstripdefinitearticles\nstrip_articles\nstrip_prepositions\nstrip_pronouns\nstrip_stopwords\nstripsparseterms\nstripfrequentterms\nstriphtmltags\n\nExample\n\njulia> doc = StringDocument(\"This is a document of mine\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: This is a document of mine\njulia> prepare!(doc, strip_pronouns | strip_articles)\njulia> text(doc)\n\"This is   document of \"\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_case!-Tuple{FileDocument}",
    "page": "API References",
    "title": "TextAnalysis.remove_case!",
    "category": "method",
    "text": "remove_case!(doc)\nremove_case!(crps)\n\nConvert the text of doc or crps to lowercase. Does not support FileDocument or crps containing FileDocument.\n\nExample\n\njulia> str = \"The quick brown fox jumps over the lazy dog\"\njulia> sd = StringDocument(str)\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: The quick brown fox jumps over the lazy dog\njulia> remove_case!(sd)\njulia> sd.text\n\"the quick brown fox jumps over the lazy dog\"\n\nSee also: remove_case\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_case-Union{Tuple{T}, Tuple{T}} where T<:AbstractString",
    "page": "API References",
    "title": "TextAnalysis.remove_case",
    "category": "method",
    "text": "remove_case(str)\n\nConvert str to lowercase. See also: remove_case!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_corrupt_utf8!-Tuple{StringDocument}",
    "page": "API References",
    "title": "TextAnalysis.remove_corrupt_utf8!",
    "category": "method",
    "text": "remove_corrupt_utf8!(doc)\nremove_corrupt_utf8!(crps)\n\nRemove corrupt UTF8 characters for doc or documents in crps. Does not support FileDocument or Corpus containing FileDocument. See also: remove_corrupt_utf8\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_corrupt_utf8-Tuple{AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.remove_corrupt_utf8",
    "category": "method",
    "text": "remove_corrupt_utf8(str)\n\nRemove corrupt UTF8 characters in str. See also: remove_corrupt_utf8!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_frequent_terms!",
    "page": "API References",
    "title": "TextAnalysis.remove_frequent_terms!",
    "category": "function",
    "text": "remove_frequent_terms!(crps, alpha=0.95)\n\nRemove terms in crps, occuring more than alpha percent of documents.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"This is Document 1\"),\n                      StringDocument(\"This is Document 2\")])\nA Corpus with 2 documents:\n* 2 StringDocument\'s\n* 0 FileDocument\'s\n* 0 TokenDocument\'s\n* 0 NGramDocument\'s\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\njulia> remove_frequent_terms!(crps)\njulia> text(crps[1])\n\"     1\"\njulia> text(crps[2])\n\"     2\"\n\nSee also: remove_sparse_terms!, frequent_terms\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_html_tags!-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.remove_html_tags!",
    "category": "method",
    "text": "remove_html_tags!(doc::StringDocument)\nremove_html_tags!(crps)\n\nRemove html tags from the StringDocument or documents crps. Does not work for documents other than StringDocument.\n\nExample\n\njulia> html_doc = StringDocument(\n             \"\n               <html>\n                   <head><script language=\"javascript\">x = 20;</script></head>\n                   <body>\n                       <h1>Hello</h1><a href=\"world\">world</a>\n                   </body>\n               </html>\n             \"\n            )\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet:  <html> <head><s\njulia> remove_html_tags!(html_doc)\njulia> strip(text(html_doc))\n\"Hello world\"\n\nSee also: remove_html_tags\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_html_tags-Tuple{AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.remove_html_tags",
    "category": "method",
    "text": "remove_html_tags(str)\n\nRemove html tags from str, including the style and script tags. See also: remove_html_tags!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_patterns!-Tuple{FileDocument,Regex}",
    "page": "API References",
    "title": "TextAnalysis.remove_patterns!",
    "category": "method",
    "text": "remove_patterns!(doc, rex::Regex)\nremove_patterns!(crps, rex::Regex)\n\nRemove patterns matched by rex in document or Corpus. Does not modify FileDocument or Corpus containing FileDocument. See also: remove_patterns\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_patterns-Tuple{AbstractString,Regex}",
    "page": "API References",
    "title": "TextAnalysis.remove_patterns",
    "category": "method",
    "text": "remove_patterns(str, rex::Regex)\n\nRemove the part of str matched by rex. See also: remove_patterns!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_sparse_terms!",
    "page": "API References",
    "title": "TextAnalysis.remove_sparse_terms!",
    "category": "function",
    "text": "remove_sparse_terms!(crps, alpha=0.05)\n\nRemove sparse terms in crps, occuring less than alpha percent of documents.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"This is Document 1\"),\n                      StringDocument(\"This is Document 2\")])\nA Corpus with 2 documents:\n * 2 StringDocument\'s\n * 0 FileDocument\'s\n * 0 TokenDocument\'s\n * 0 NGramDocument\'s\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\njulia> remove_sparse_terms!(crps, 0.5)\njulia> crps[1].text\n\"This is Document \"\njulia> crps[2].text\n\"This is Document \"\n\nSee also: remove_frequent_terms!, sparse_terms\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_words!-Union{Tuple{T}, Tuple{Union{AbstractDocument, Corpus},Array{T,1}}} where T<:AbstractString",
    "page": "API References",
    "title": "TextAnalysis.remove_words!",
    "category": "method",
    "text": "remove_words!(doc, words::Vector{AbstractString})\nremove_words!(crps, words::Vector{AbstractString})\n\nRemove the occurences of words from doc or crps.\n\nExample\n\njulia> str=\"The quick brown fox jumps over the lazy dog\"\njulia> sd=StringDocument(str);\njulia> remove_words = [\"fox\", \"over\"]\njulia> remove_words!(sd, remove_words)\njulia> sd.text\n\"the quick brown   jumps   the lazy dog\"\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.rouge_l_sentence",
    "page": "API References",
    "title": "TextAnalysis.rouge_l_sentence",
    "category": "function",
    "text": "rouge_l_sentence(references, candidate, β, average)\n\nCalculate the ROUGE-L score between references and candidate at sentence level.\n\nSee Rouge: A package for automatic evaluation of summaries\n\nSee also: rouge_n, rouge_l_summary\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.rouge_l_summary",
    "page": "API References",
    "title": "TextAnalysis.rouge_l_summary",
    "category": "function",
    "text": "rouge_l_summary(references, candidate, β, average)\n\nCalculate the ROUGE-L score between references and candidate at summary level.\n\nSee Rouge: A package for automatic evaluation of summaries\n\nSee also: rouge_l_sentence(), rouge_l_summary\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.rouge_n-Tuple{Any,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.rouge_n",
    "category": "method",
    "text": "rouge_n(references::Array{T}, candidate::AbstractString, n; avg::Bool, lang::Language) where T<: AbstractString\n\nCompute n-gram recall between candidate and the references summaries.\n\nSee Rouge: A package for automatic evaluation of summaries\n\nSee also: rouge_l_sentence, rouge_l_summary\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.sparse_terms",
    "page": "API References",
    "title": "TextAnalysis.sparse_terms",
    "category": "function",
    "text": "sparse_terms(crps, alpha=0.05])\n\nFind the sparse terms from Corpus, occuring in less than alpha percentage of the documents.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"This is Document 1\"),\n                      StringDocument(\"This is Document 2\")])\nA Corpus with 2 documents:\n* 2 StringDocument\'s\n* 0 FileDocument\'s\n* 0 TokenDocument\'s\n* 0 NGramDocument\'s\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\njulia> sparse_terms(crps, 0.5)\n2-element Array{String,1}:\n \"1\"\n \"2\"\n\nSee also: remove_sparse_terms!, frequent_terms\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.standardize!-Union{Tuple{T}, Tuple{Corpus,Type{T}}} where T<:AbstractDocument",
    "page": "API References",
    "title": "TextAnalysis.standardize!",
    "category": "method",
    "text": "standardize!(crps::Corpus, ::Type{T}) where T <: AbstractDocument\n\nStandardize the documents in a Corpus to a common type.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"Document 1\"),\n		              TokenDocument(\"Document 2\"),\n		              NGramDocument(\"Document 3\")])\nA Corpus with 3 documents:\n * 1 StringDocument\'s\n * 0 FileDocument\'s\n * 1 TokenDocument\'s\n * 1 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\n\n\njulia> standardize!(crps, NGramDocument)\n\njulia> crps\nA Corpus with 3 documents:\n * 0 StringDocument\'s\n * 0 FileDocument\'s\n * 0 TokenDocument\'s\n * 3 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.stem!-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.stem!",
    "category": "method",
    "text": "stem!(doc)\nstem!(crps)\n\nStems the document or documents in crps with a suitable stemmer.\n\nStemming cannot be done for FileDocument and Corpus made of these type of documents.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.stem-Tuple{Stemmer,AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.stem",
    "category": "method",
    "text": "stem(stemmer::Stemmer, str)\nstem(stemmer::Stemmer, words::Array)\n\nStem the input with the Stemming algorthm of stemmer.\n\nSee also: stem!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.stemmer_types-Tuple{}",
    "page": "API References",
    "title": "TextAnalysis.stemmer_types",
    "category": "method",
    "text": "stemmer_types()\n\nList all the stemmer algorithms loaded.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.summarize-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.summarize",
    "category": "method",
    "text": "summarize(doc [, ns])\n\nSummarizes the document and returns ns number of sentences. By default ns is set to the value 5.\n\nExample\n\njulia> s = StringDocument(\"Assume this Short Document as an example. Assume this as an example summarizer. This has too foo sentences.\")\n\njulia> summarize(s, ns=2)\n2-element Array{SubString{String},1}:\n \"Assume this Short Document as an example.\"\n \"This has too foo sentences.\"\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tag_scheme!-Tuple{Any,String,String}",
    "page": "API References",
    "title": "TextAnalysis.tag_scheme!",
    "category": "method",
    "text": "tag_scheme!(tags, current_scheme::String, new_scheme::String)\n\nConvert tags from current_scheme to new_scheme.\n\nList of tagging schemes currently supported-\n\nBIO1 (BIO)\nBIO2\nBIOES\n\nExample\n\njulia> tags = [\"I-LOC\", \"O\", \"I-PER\", \"B-MISC\", \"I-MISC\", \"B-PER\", \"I-PER\", \"I-PER\"]\n\njulia> tag_scheme!(tags, \"BIO1\", \"BIOES\")\n\njulia> tags\n8-element Array{String,1}:\n \"S-LOC\"\n \"O\"\n \"S-PER\"\n \"B-MISC\"\n \"E-MISC\"\n \"B-PER\"\n \"I-PER\"\n \"E-PER\"\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.text-Tuple{FileDocument}",
    "page": "API References",
    "title": "TextAnalysis.text",
    "category": "method",
    "text": "text(fd::FileDocument)\ntext(sd::StringDocument)\ntext(ngd::NGramDocument)\n\nAccess the text of Document as a string.\n\nExample\n\njulia> sd = StringDocument(\"To be or not to be...\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\n\njulia> text(sd)\n\"To be or not to be...\"\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tf!-Union{Tuple{F}, Tuple{T}, Tuple{SparseMatrixCSC{T,Ti} where Ti<:Integer,SparseMatrixCSC{F,Ti} where Ti<:Integer}} where F<:AbstractFloat where T<:Real",
    "page": "API References",
    "title": "TextAnalysis.tf!",
    "category": "method",
    "text": "tf!(dtm::SparseMatrixCSC{Real}, tf::SparseMatrixCSC{AbstractFloat})\n\nOverwrite tf with the term frequency of the dtm.\n\ntf should have the has same nonzeros as dtm.\n\nSee also: tf, tf_idf, tf_idf!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tf!-Union{Tuple{T2}, Tuple{T1}, Tuple{AbstractArray{T1,2},AbstractArray{T2,2}}} where T2<:AbstractFloat where T1<:Real",
    "page": "API References",
    "title": "TextAnalysis.tf!",
    "category": "method",
    "text": "tf!(dtm::AbstractMatrix{Real}, tf::AbstractMatrix{AbstractFloat})\n\nOverwrite tf with the term frequency of the dtm.\n\nWorks correctly if dtm and tf are same matrix.\n\nSee also: tf, tf_idf, tf_idf!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tf-Tuple{DocumentTermMatrix}",
    "page": "API References",
    "title": "TextAnalysis.tf",
    "category": "method",
    "text": "tf(dtm::DocumentTermMatrix)\ntf(dtm::SparseMatrixCSC{Real})\ntf(dtm::Matrix{Real})\n\nCompute the term-frequency of the input.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"To be or not to be\"),\n              StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\n\njulia> tf(m)\n2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:\n  [1, 1]  =  0.166667\n  [2, 1]  =  0.166667\n  [1, 2]  =  0.333333\n  [2, 3]  =  0.333333\n  [1, 4]  =  0.166667\n  [2, 4]  =  0.166667\n  [1, 5]  =  0.166667\n  [2, 5]  =  0.166667\n  [1, 6]  =  0.166667\n  [2, 6]  =  0.166667\n\nSee also: tf!, tf_idf, tf_idf!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tf_idf!-Union{Tuple{AbstractArray{T,2}}, Tuple{T}} where T<:Real",
    "page": "API References",
    "title": "TextAnalysis.tf_idf!",
    "category": "method",
    "text": "tf_idf!(dtm)\n\nCompute tf-idf for dtm\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tf_idf!-Union{Tuple{F}, Tuple{T}, Tuple{SparseMatrixCSC{T,Ti} where Ti<:Integer,SparseMatrixCSC{F,Ti} where Ti<:Integer}} where F<:AbstractFloat where T<:Real",
    "page": "API References",
    "title": "TextAnalysis.tf_idf!",
    "category": "method",
    "text": "tf_idf!(dtm::SparseMatrixCSC{Real}, tfidf::SparseMatrixCSC{AbstractFloat})\n\nOverwrite tfidf with the tf-idf (Term Frequency - Inverse Doc Frequency) of the dtm.\n\nThe arguments must have same number of nonzeros.\n\nSee also: tf, tf_idf, tf_idf!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tf_idf!-Union{Tuple{T2}, Tuple{T1}, Tuple{AbstractArray{T1,2},AbstractArray{T2,2}}} where T2<:AbstractFloat where T1<:Real",
    "page": "API References",
    "title": "TextAnalysis.tf_idf!",
    "category": "method",
    "text": "tf_idf!(dtm::AbstractMatrix{Real}, tf_idf::AbstractMatrix{AbstractFloat})\n\nOverwrite tf_idf with the tf-idf (Term Frequency - Inverse Doc Frequency) of the dtm.\n\ndtm and tf-idf must be matrices of same dimensions.\n\nSee also: tf, tf! , tf_idf\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tf_idf-Tuple{DocumentTermMatrix}",
    "page": "API References",
    "title": "TextAnalysis.tf_idf",
    "category": "method",
    "text": "tf(dtm::DocumentTermMatrix)\ntf(dtm::SparseMatrixCSC{Real})\ntf(dtm::Matrix{Real})\n\nCompute tf-idf value (Term Frequency - Inverse Document Frequency) for the input.\n\nIn many cases, raw word counts are not appropriate for use because:\n\nSome documents are longer than other documents\nSome words are more frequent than other words\n\nA simple workaround this can be done by performing TF-IDF on a DocumentTermMatrix\n\nExample\n\njulia> crps = Corpus([StringDocument(\"To be or not to be\"),\n              StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\n\njulia> tf_idf(m)\n2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:\n  [1, 1]  =  0.0\n  [2, 1]  =  0.0\n  [1, 2]  =  0.231049\n  [2, 3]  =  0.231049\n  [1, 4]  =  0.0\n  [2, 4]  =  0.0\n  [1, 5]  =  0.0\n  [2, 5]  =  0.0\n  [1, 6]  =  0.0\n  [2, 6]  =  0.0\n\nSee also: tf!, tf_idf, tf_idf!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.timestamp!-Tuple{AbstractDocument,AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.timestamp!",
    "category": "method",
    "text": "timestamp!(doc, timestamp::AbstractString)\n\nSet the timestamp metadata of doc to timestamp.\n\nSee also: timestamp, timestamps, timestamps!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.timestamp-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.timestamp",
    "category": "method",
    "text": "timestamp(doc)\n\nReturn the timestamp metadata for doc.\n\nSee also: timestamp!, timestamps, timestamps!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.timestamps!-Tuple{Corpus,Array{String,1}}",
    "page": "API References",
    "title": "TextAnalysis.timestamps!",
    "category": "method",
    "text": "timestamps!(crps, times::Vector{String})\ntimestamps!(crps, time::AbstractString)\n\nSet the timestamps of the documents in crps to the timestamps in times, respectively.\n\nSee also: timestamps, timestamp!, timestamp\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.timestamps-Tuple{Corpus}",
    "page": "API References",
    "title": "TextAnalysis.timestamps",
    "category": "method",
    "text": "timestamps(crps)\n\nReturn the timestamps for each document in crps.\n\nSee also: timestamps!, timestamp, timestamp!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.title!-Tuple{AbstractDocument,AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.title!",
    "category": "method",
    "text": "title!(doc, str)\n\nSet the title of doc to str.\n\nSee also: title, titles, titles!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.title-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.title",
    "category": "method",
    "text": "title(doc)\n\nReturn the title metadata for doc.\n\nSee also: title!, titles, titles!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.titles!-Tuple{Corpus,Array{String,1}}",
    "page": "API References",
    "title": "TextAnalysis.titles!",
    "category": "method",
    "text": "titles!(crps, vec::Vector{String})\ntitles!(crps, str)\n\nUpdate titles of the documents in a Corpus.\n\nIf the input is a String, set the same title for all documents. If the input is a vector, set title of ith document to corresponding ith element in the vector vec. In the latter case, the number of documents must equal the length of vector.\n\nSee also: titles, title!, title\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.titles-Tuple{Corpus}",
    "page": "API References",
    "title": "TextAnalysis.titles",
    "category": "method",
    "text": "titles(crps)\n\nReturn the titles for each document in crps.\n\nSee also: titles!, title, title!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tokens-Tuple{Union{FileDocument, StringDocument}}",
    "page": "API References",
    "title": "TextAnalysis.tokens",
    "category": "method",
    "text": "tokens(d::TokenDocument)\ntokens(d::(Union{FileDocument, StringDocument}))\n\nAccess the document text as a token array.\n\nExample\n\njulia> sd = StringDocument(\"To be or not to be...\")\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\n\njulia> tokens(sd)\n7-element Array{String,1}:\n    \"To\"\n    \"be\"\n    \"or\"\n    \"not\"\n    \"to\"\n    \"be..\"\n    \".\"\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.viterbi_decode-Tuple{CRF,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.viterbi_decode",
    "category": "method",
    "text": "viterbi_decode(::CRF, input_sequence)\n\nPredicts the most probable label sequence of input_sequence.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.CRF",
    "page": "API References",
    "title": "TextAnalysis.CRF",
    "category": "type",
    "text": "Linear Chain - CRF Layer.\n\nFor input sequence x, predicts the most probable tag sequence y, over the set of all possible tagging sequences Y.\n\nIn this CRF, two kinds of potentials are defined, emission and Transition.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.CRF-Tuple{Integer}",
    "page": "API References",
    "title": "TextAnalysis.CRF",
    "category": "method",
    "text": "Second last index for start tag, last one for stop tag .\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.CooMatrix",
    "page": "API References",
    "title": "TextAnalysis.CooMatrix",
    "category": "type",
    "text": "Basic Co-occurrence Matrix (COOM) type.\n\nFields\n\ncoom::SparseMatriCSC{T,Int} the actual COOM; elements represent\n\nco-occurrences of two terms within a given window\n\nterms::Vector{String} a list of terms that represent the lexicon of\n\nthe document or corpus\n\ncolumn_indices::OrderedDict{String, Int} a map between the terms and the\n\ncolumns of the co-occurrence matrix\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.CooMatrix-Union{Tuple{T}, Tuple{Corpus,Array{String,1}}} where T<:AbstractFloat",
    "page": "API References",
    "title": "TextAnalysis.CooMatrix",
    "category": "method",
    "text": "CooMatrix{T}(crps::Corpus [,terms] [;window=5, normalize=true])\n\nAuxiliary constructor(s) of the CooMatrix type. The type T has to be a subtype of AbstractFloat. The constructor(s) requires a corpus crps and a terms structure representing the lexicon of the corpus. The latter can be a Vector{String}, an AbstractDict where the keys are the lexicon, or can be omitted, in which case the lexicon field of the corpus is used.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.Corpus-Union{Tuple{Array{T,1}}, Tuple{T}} where T<:AbstractDocument",
    "page": "API References",
    "title": "TextAnalysis.Corpus",
    "category": "method",
    "text": "Corpus(docs::Vector{T}) where {T <: AbstractDocument}\n\nCollections of documents are represented using the Corpus type.\n\nExample\n\njulia> crps = Corpus([StringDocument(\"Document 1\"),\n		              StringDocument(\"Document 2\")])\nA Corpus with 2 documents:\n * 2 StringDocument\'s\n * 0 FileDocument\'s\n * 0 TokenDocument\'s\n * 0 NGramDocument\'s\n\nCorpus\'s lexicon contains 0 tokens\nCorpus\'s index contains 0 tokens\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.DocumentTermMatrix-Tuple{Corpus,Array{String,1}}",
    "page": "API References",
    "title": "TextAnalysis.DocumentTermMatrix",
    "category": "method",
    "text": "DocumentTermMatrix(crps::Corpus)\nDocumentTermMatrix(crps::Corpus, terms::Vector{String})\nDocumentTermMatrix(crps::Corpus, lex::AbstractDict)\nDocumentTermMatrix(dtm::SparseMatrixCSC{Int, Int},terms::Vector{String})\n\nRepresent documents as a matrix of word counts.\n\nAllow us to apply linear algebra operations and statistical techniques. Need to update lexicon before use.\n\nExamples\n\njulia> crps = Corpus([StringDocument(\"To be or not to be\"),\n                      StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\nA 2 X 6 DocumentTermMatrix\n\njulia> m.dtm\n2×6 SparseArrays.SparseMatrixCSC{Int64,Int64} with 10 stored entries:\n  [1, 1]  =  1\n  [2, 1]  =  1\n  [1, 2]  =  2\n  [2, 3]  =  2\n  [1, 4]  =  1\n  [2, 4]  =  1\n  [1, 5]  =  1\n  [2, 5]  =  1\n  [1, 6]  =  1\n  [2, 6]  =  1\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.FileDocument-Tuple{AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.FileDocument",
    "category": "method",
    "text": "FileDocument(pathname::AbstractString)\n\nRepresents a document using a plain text file on disk.\n\nExample\n\njulia> pathname = \"/usr/share/dict/words\"\n\"/usr/share/dict/words\"\n\njulia> fd = FileDocument(pathname)\nA FileDocument\n * Language: Languages.English()\n * Title: /usr/share/dict/words\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: A A\'s AMD AMD\'s AOL AOL\'s Aachen Aachen\'s Aaliyah\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.NGramDocument-Tuple{AbstractString,TextAnalysis.DocumentMetadata,Vararg{Integer,N} where N}",
    "page": "API References",
    "title": "TextAnalysis.NGramDocument",
    "category": "method",
    "text": "NGramDocument(txt::AbstractString, n::Integer=1)\nNGramDocument(txt::AbstractString, dm::DocumentMetadata, n::Integer=1)\nNGramDocument(ng::Dict{T, Int}, n::Integer=1) where T <: AbstractString\n\nRepresents a document as a bag of n-grams, which are UTF8 n-grams and map to counts.\n\nExample\n\njulia> my_ngrams = Dict{String, Int}(\"To\" => 1, \"be\" => 2,\n                                     \"or\" => 1, \"not\" => 1,\n                                     \"to\" => 1, \"be...\" => 1)\nDict{String,Int64} with 6 entries:\n  \"or\"    => 1\n  \"be...\" => 1\n  \"not\"   => 1\n  \"to\"    => 1\n  \"To\"    => 1\n  \"be\"    => 2\n\njulia> ngd = NGramDocument(my_ngrams)\nA NGramDocument{AbstractString}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.NaiveBayesClassifier-Tuple{Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.NaiveBayesClassifier",
    "category": "method",
    "text": "NaiveBayesClassifier([dict, ]classes)\n\nA Naive Bayes Classifier for classifying documents.\n\nExample\n\njulia> using TextAnalysis: NaiveBayesClassifier, fit!, predict\njulia> m = NaiveBayesClassifier([:spam, :non_spam])\nNaiveBayesClassifier{Symbol}(String[], Symbol[:spam, :non_spam], Array{Int64}(0,2))\n\njulia> fit!(m, \"this is spam\", :spam)\nNaiveBayesClassifier{Symbol}([\"this\", \"is\", \"spam\"], Symbol[:spam, :non_spam], [2 1; 2 1; 2 1])\n\njulia> fit!(m, \"this is not spam\", :non_spam)\nNaiveBayesClassifier{Symbol}([\"this\", \"is\", \"spam\", \"not\"], Symbol[:spam, :non_spam], [2 2; 2 2; 2 2; 1 2])\n\njulia> predict(m, \"is this a spam\")\nDict{Symbol,Float64} with 2 entries:\n  :spam     => 0.59883\n  :non_spam => 0.40117\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.PerceptronTagger",
    "page": "API References",
    "title": "TextAnalysis.PerceptronTagger",
    "category": "type",
    "text": "PERCEPTRON TAGGER\n\nThis struct contains the POS tagger \"PerceptronTagger\" which uses model in \"AveragePerceptron\" In this training can be done and weights can be saved Or a pretrain weights can be used (which are trained on same features) and train more or can be used to predict\n\nTo train:\n\njulia> tagger = PerceptronTagger(false)\n\njulia> fit!(tagger, [[(\"today\",\"NN\"),(\"is\",\"VBZ\"),(\"good\",\"JJ\"),(\"day\",\"NN\")]])\n\nTo load pretrain model:\n\njulia> tagger = PerceptronTagger(true)\n\nTo predict tag:\n\njulia> predict(tagger, [\"today\", \"is\"])\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.SentimentAnalyzer",
    "page": "API References",
    "title": "TextAnalysis.SentimentAnalyzer",
    "category": "type",
    "text": "model = SentimentAnalyzer(doc)\nmodel = SentimentAnalyzer(doc, handle_unknown)\n\nPredict sentiment of the input doc in range 0 to 1, 0 being least sentiment score and 1 being the highest.\n\nArguments\n\ndoc              = Input Document for calculating document (AbstractDocument type)\nhandle_unknown   = A function for handling unknown words. Should return an array (default x->tuple())\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.StringDocument-Tuple{AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.StringDocument",
    "category": "method",
    "text": "StringDocument(txt::AbstractString)\n\nRepresents a document using a UTF8 String stored in RAM.\n\nExample\n\njulia> str = \"To be or not to be...\"\n\"To be or not to be...\"\n\njulia> sd = StringDocument(str)\nA StringDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: To be or not to be...\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.TextHashFunction-Tuple{Int64}",
    "page": "API References",
    "title": "TextAnalysis.TextHashFunction",
    "category": "method",
    "text": "TextHashFunction(cardinality)\nTextHashFunction(hash_function, cardinality)\n\nThe need to create a lexicon before we can construct a document term matrix is often prohibitive. We can often employ a trick that has come to be called the Hash Trick in which we replace terms with their hashed valued using a hash function that outputs integers from 1 to N.\n\nParameters: 	-  cardinality	    = Max index used for hashing (default 100)  	-  hash_function    = function used for hashing process (default function present, see code-base)\n\njulia> h = TextHashFunction(10)\nTextHashFunction(hash, 10)\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.TokenDocument-Tuple{AbstractString,TextAnalysis.DocumentMetadata}",
    "page": "API References",
    "title": "TextAnalysis.TokenDocument",
    "category": "method",
    "text": "TokenDocument(txt::AbstractString)\nTokenDocument(txt::AbstractString, dm::DocumentMetadata)\nTokenDocument(tkns::Vector{T}) where T <: AbstractString\n\nRepresents a document as a sequence of UTF8 tokens.\n\nExample\n\njulia> my_tokens = String[\"To\", \"be\", \"or\", \"not\", \"to\", \"be...\"]\n6-element Array{String,1}:\n    \"To\"\n    \"be\"\n    \"or\"\n    \"not\"\n    \"to\"\n    \"be...\"\n\njulia> td = TokenDocument(my_tokens)\nA TokenDocument{String}\n * Language: Languages.English()\n * Title: Untitled Document\n * Author: Unknown Author\n * Timestamp: Unknown Time\n * Snippet: ***SAMPLE TEXT NOT AVAILABLE***\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis._decode-Tuple{CRF,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis._decode",
    "category": "method",
    "text": "Computes the forward pass for viterbi algorithm.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.average_weights-Tuple{TextAnalysis.AveragePerceptron}",
    "page": "API References",
    "title": "TextAnalysis.average_weights",
    "category": "method",
    "text": "Averaging the weights over all time stamps\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.columnindices-Tuple{Array{String,1}}",
    "page": "API References",
    "title": "TextAnalysis.columnindices",
    "category": "method",
    "text": "columnindices(terms::Vector{String})\n\nCreates a column index lookup dictionary from a vector of terms.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.coo_matrix-Union{Tuple{T}, Tuple{Type{T},Array{#s52,1} where #s52<:AbstractString,OrderedDict{#s51,Int64} where #s51<:AbstractString,Int64}, Tuple{Type{T},Array{#s50,1} where #s50<:AbstractString,OrderedDict{#s49,Int64} where #s49<:AbstractString,Int64,Bool}} where T<:AbstractFloat",
    "page": "API References",
    "title": "TextAnalysis.coo_matrix",
    "category": "method",
    "text": "coo_matrix(::Type{T}, doc::Vector{AbstractString}, vocab::OrderedDict{AbstractString, Int}, window::Int, normalize::Bool)\n\nBasic low-level function that calculates the co-occurence matrix of a document. Returns a sparse co-occurence matrix sized n × n where n = length(vocab) with elements of type T. The document doc is represented by a vector of its terms (in order). The keywordswindowandnormalize` indicate the size of the sliding word window in which co-occurrences are counted and whether to normalize of not the counts by the distance between word positions.\n\nExample\n\njulia> using TextAnalysis, DataStructures\n       doc = StringDocument(\"This is a text about an apple. There are many texts about apples.\")\n       docv = TextAnalysis.tokenize(language(doc), text(doc))\n       vocab = OrderedDict(\"This\"=>1, \"is\"=>2, \"apple.\"=>3)\n       TextAnalysis.coo_matrix(Float16, docv, vocab, 5, true)\n\n3×3 SparseArrays.SparseMatrixCSC{Float16,Int64} with 4 stored entries:\n  [2, 1]  =  2.0\n  [1, 2]  =  2.0\n  [3, 2]  =  0.3999\n  [2, 3]  =  0.3999\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.extend!-Tuple{NaiveBayesClassifier,Any}",
    "page": "API References",
    "title": "TextAnalysis.extend!",
    "category": "method",
    "text": "extend!(model::NaiveBayesClassifier, dictElement)\n\nAdd the dictElement to dictionary of the Classifier model.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.features-Tuple{AbstractDict,Any}",
    "page": "API References",
    "title": "TextAnalysis.features",
    "category": "method",
    "text": "features(::AbstractDict, dict)\n\nCompute an Array, mapping the value corresponding to elements of dict to the input AbstractDict.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.fmeasure_lcs",
    "page": "API References",
    "title": "TextAnalysis.fmeasure_lcs",
    "category": "function",
    "text": "fmeasure_lcs(RLCS, PLCS, β)\n\nCompute the F-measure based on WLCS.\n\nArguments\n\nRLCS - Recall Factor\nPLCS - Precision Factor\nβ - Parameter\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.forward_score-Tuple{CRF,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.forward_score",
    "category": "method",
    "text": "forward_score(c::CRF, x::Array)\n\nCompute the Normalization / partition function or the Forward Algorithm score - Z\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.frequencies-Tuple{Any}",
    "page": "API References",
    "title": "TextAnalysis.frequencies",
    "category": "method",
    "text": "Create a dict that maps elements in input array to their frequencies.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.getFeatures-Tuple{PerceptronTagger,Any,Any,Any,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.getFeatures",
    "category": "method",
    "text": "Converting the token into a feature representation, implemented as Dict If the features change, a new model should be trained\n\nArguments:\n\ni - index of word(or token) in sentence\nword - token\ncontext - array of tokens with starting and ending specifiers\nprev == \"-START-\" prev2 == \"-START2-\" - Start specifiers\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.jackknife_avg-Tuple{Any}",
    "page": "API References",
    "title": "TextAnalysis.jackknife_avg",
    "category": "method",
    "text": "jackknife_avg(`scores`)\n\nApply jackknife on the input list of scores\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.log_sum_exp-Tuple{Any}",
    "page": "API References",
    "title": "TextAnalysis.log_sum_exp",
    "category": "method",
    "text": "log_sum_exp(z::Array)\n\nA stable implementation f(x) = log ∘ sum ∘ exp (x). Since exponentiation can lead to very large numbers.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.makeTagDict-Tuple{PerceptronTagger,Any}",
    "page": "API References",
    "title": "TextAnalysis.makeTagDict",
    "category": "method",
    "text": "makes a dictionary for single-tag words params : sentences - an array of tuples which contains word and correspinding tag\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.ngramize-Union{Tuple{T}, Tuple{S}, Tuple{S,Array{T,1},Vararg{Integer,N} where N}} where T<:AbstractString where S<:Languages.Language",
    "page": "API References",
    "title": "TextAnalysis.ngramize",
    "category": "method",
    "text": "ngramize(lang, tokens, n)\n\nCompute the ngrams of tokens of the order n.\n\nExample\n\njulia> ngramize(Languages.English(), [\"To\", \"be\", \"or\", \"not\", \"to\"], 3)\nDict{AbstractString,Int64} with 3 entries:\n  \"be or not\" => 1\n  \"or not to\" => 1\n  \"To be or\"  => 1\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.normalize-Tuple{Any}",
    "page": "API References",
    "title": "TextAnalysis.normalize",
    "category": "method",
    "text": "This function is used to normalize the given word params : word - String\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.onegramize-Union{Tuple{T}, Tuple{S}, Tuple{S,Array{T,1}}} where T<:AbstractString where S<:Languages.Language",
    "page": "API References",
    "title": "TextAnalysis.onegramize",
    "category": "method",
    "text": "onegramize(lang, tokens)\n\nCreate the unigrams dict for input tokens.\n\nExample\n\njulia> onegramize(Languages.English(), [\"To\", \"be\", \"or\", \"not\", \"to\", \"be\"])\nDict{String,Int64} with 5 entries:\n  \"or\"  => 1\n  \"not\" => 1\n  \"to\"  => 1\n  \"To\"  => 1\n  \"be\"  => 2\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.preds_first-Tuple{CRF,Any}",
    "page": "API References",
    "title": "TextAnalysis.preds_first",
    "category": "method",
    "text": "Scores for the first tag in the tagging sequence.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.preds_last-Tuple{CRF,Any}",
    "page": "API References",
    "title": "TextAnalysis.preds_last",
    "category": "method",
    "text": "Scores for the last tag in the tagging sequence.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.preds_single-Tuple{CRF,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.preds_single",
    "category": "method",
    "text": "Scores for the tags other than the starting one.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_whitespace!-Tuple{StringDocument}",
    "page": "API References",
    "title": "TextAnalysis.remove_whitespace!",
    "category": "method",
    "text": "remove_whitespace!(doc)\nremove_whitespace!(crps)\n\nSquash multiple whitespaces to a single space and remove all leading and trailing whitespaces in document or crps. Does no-op for FileDocument, TokenDocument or NGramDocument. See also: remove_whitespace\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.remove_whitespace-Tuple{AbstractString}",
    "page": "API References",
    "title": "TextAnalysis.remove_whitespace",
    "category": "method",
    "text": "remove_whitespace(str)\n\nSquash multiple whitespaces to a single one. And remove all leading and trailing whitespaces. See also: remove_whitespace!\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.score_sequence-Tuple{CRF,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.score_sequence",
    "category": "method",
    "text": "score_sequence(c::CRF, xs, label_seq)\n\nCalculating the score of the desired label_seq against sequence xs. Not exponentiated as required for negative log likelihood, thereby preventing operation.\n\nlabel_seq<:Array/ CuArray eltype(label_seq) = Flux.OneHotVector\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.sentence_tokenize-Union{Tuple{T}, Tuple{S}, Tuple{S,T}} where T<:AbstractString where S<:Languages.Language",
    "page": "API References",
    "title": "TextAnalysis.sentence_tokenize",
    "category": "method",
    "text": "sentence_tokenize(language, str)\n\nSplit str into sentences.\n\nExample\n\njulia> sentence_tokenize(Languages.English(), \"Here are few words! I am Foo Bar.\")\n2-element Array{SubString{String},1}:\n \"Here are few words!\"\n \"I am Foo Bar.\"\n\nSee also: tokenize\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.stemmer_for_document-Tuple{AbstractDocument}",
    "page": "API References",
    "title": "TextAnalysis.stemmer_for_document",
    "category": "method",
    "text": "stemmer_for_document(doc)\n\nSearch for an appropriate stemmer based on the language of the document.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.tokenize-Union{Tuple{T}, Tuple{S}, Tuple{S,T}} where T<:AbstractString where S<:Languages.Language",
    "page": "API References",
    "title": "TextAnalysis.tokenize",
    "category": "method",
    "text": "tokenize(language, str)\n\nSplit str into words and other tokens such as punctuation.\n\nExample\n\njulia> tokenize(Languages.English(), \"Too foo words!\")\n4-element Array{String,1}:\n \"Too\"\n \"foo\"\n \"words\"\n \"!\"\n\nSee also: sentence_tokenize\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.update-Tuple{TextAnalysis.AveragePerceptron,Any,Any,Any}",
    "page": "API References",
    "title": "TextAnalysis.update",
    "category": "method",
    "text": "Applying the perceptron learning algorithm Increment the truth weights and decrementing the guess weights, if the guess is wrong\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.weighted_lcs",
    "page": "API References",
    "title": "TextAnalysis.weighted_lcs",
    "category": "function",
    "text": "weighted_lcs(X, Y, weight_score::Bool, returns_string::Bool, weigthing_function::Function)\n\nCompute the Weighted Longest Common Subsequence of X and Y.\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.AveragePerceptron",
    "page": "API References",
    "title": "TextAnalysis.AveragePerceptron",
    "category": "type",
    "text": "This file contains the Average Perceptron model and Perceptron Tagger which was original implemented by Matthew Honnibal.\n\nThe model learns by basic perceptron algorithm but after all iterations weights are being averaged\n\nAVERAGE PERCEPTRON MODEL\n\nThis struct contains the actual Average Perceptron Model\n\n\n\n\n\n"
},

{
    "location": "APIReference/#TextAnalysis.DocumentMetadata-Tuple{}",
    "page": "API References",
    "title": "TextAnalysis.DocumentMetadata",
    "category": "method",
    "text": "DocumentMetadata(language, title::String, author::String, timestamp::String)\n\nStores basic metadata about Document.\n\n...\n\nArguments\n\nlanguage: What language is the document in? Defaults to Languages.English(), a Language instance defined by the Languages package.\ntitle::String : What is the title of the document? Defaults to \"Untitled Document\".\nauthor::String : Who wrote the document? Defaults to \"Unknown Author\".\ntimestamp::String : When was the document written? Defaults to \"Unknown Time\".\n\n...\n\n\n\n\n\n"
},

{
    "location": "APIReference/#API-References-1",
    "page": "API References",
    "title": "API References",
    "category": "section",
    "text": "Modules = [TextAnalysis]\nOrder   = [:function, :type]"
},

]}
