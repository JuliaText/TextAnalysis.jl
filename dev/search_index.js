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
    "text": "Often we need to find out the proportion of a document is contributed by each term. This can be done by finding the term frequency functiontf(dtm)The paramter, dtm can be of the types - DocumentTermMatrix , SparseMatrixCSC or Matrixjulia> crps = Corpus([StringDocument(\"To be or not to be\"),\n              StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\n\njulia> tf(m)\n2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:\n  [1, 1]  =  0.166667\n  [2, 1]  =  0.166667\n  [1, 2]  =  0.333333\n  [2, 3]  =  0.333333\n  [1, 4]  =  0.166667\n  [2, 4]  =  0.166667\n  [1, 5]  =  0.166667\n  [2, 5]  =  0.166667\n  [1, 6]  =  0.166667\n  [2, 6]  =  0.166667"
},

{
    "location": "features/#TF-IDF-(Term-Frequency-Inverse-Document-Frequency)-1",
    "page": "Features",
    "title": "TF-IDF (Term Frequency - Inverse Document Frequency)",
    "category": "section",
    "text": "tf_idf(dtm)In many cases, raw word counts are not appropriate for use because:(A) Some documents are longer than other documents\n(B) Some words are more frequent than other wordsYou can work around this by performing TF-IDF on a DocumentTermMatrix:julia> crps = Corpus([StringDocument(\"To be or not to be\"),\n              StringDocument(\"To become or not to become\")])\n\njulia> update_lexicon!(crps)\n\njulia> m = DocumentTermMatrix(crps)\nDocumentTermMatrix(\n  [1, 1]  =  1\n  [2, 1]  =  1\n  [1, 2]  =  2\n  [2, 3]  =  2\n  [1, 4]  =  1\n  [2, 4]  =  1\n  [1, 5]  =  1\n  [2, 5]  =  1\n  [1, 6]  =  1\n  [2, 6]  =  1, [\"To\", \"be\", \"become\", \"not\", \"or\", \"to\"], Dict(\"or\"=>5,\"not\"=>4,\"to\"=>6,\"To\"=>1,\"be\"=>2,\"become\"=>3))\n\njulia> tf_idf(m)\n2×6 SparseArrays.SparseMatrixCSC{Float64,Int64} with 10 stored entries:\n  [1, 1]  =  0.0\n  [2, 1]  =  0.0\n  [1, 2]  =  0.231049\n  [2, 3]  =  0.231049\n  [1, 4]  =  0.0\n  [2, 4]  =  0.0\n  [1, 5]  =  0.0\n  [2, 5]  =  0.0\n  [1, 6]  =  0.0\n  [2, 6]  =  0.0As you can see, TF-IDF has the effect of inserting 0\'s into the columns of words that occur in all documents. This is a useful way to avoid having to remove those words during preprocessing."
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
    "location": "features/#Parts-of-Speech-Tagger-1",
    "page": "Features",
    "title": "Parts of Speech Tagger",
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
    "text": "julia> predict(tagger, [\"today\", \"is\"])\n2-element Array{Any,1}:\n (\"today\", \"NN\")\n (\"is\", \"VBZ\")PerceptronTagger(load::Bool)load      = Boolean argument if true then pretrained model is loadedfit!(self::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, save_loc::String, nr_iter::Integer)self      = PerceptronTagger object\nsentences = Vector of Vector of Tuple of pair of word or token and its POS tag [see above example]\nsave_loc  = location of file to save the trained weights\nnr_iter   = Number of iterations to pass the sentences to train the model ( default 5)predict(self::PerceptronTagger, tokens)self      = PerceptronTagger\ntokens    = Vector of words or tokens for which to predict tags"
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

]}
