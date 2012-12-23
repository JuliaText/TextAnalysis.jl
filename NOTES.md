Document
 * FileDocument: On disk representation of document as text (i.e String)
 * StringDocument: In memory representation of document as String
 * NGramDocument: Bag of words representation of document as Dict(String,Int64)
 * ParseTreeDocument: Parse-tree representation of document (TO DO)

Want ability to operate with items on disk

Corpus is an array
 Lexicon
 Hash

DocumentMetadata
 Language

=

corpus[1]
each_document()

Stream documents, produce tokens, produce hashed feature representation or DTM feature vector using lexicon

If generate full DTM, generate Sparse matrix

# Behaviors

* Create documents from files on disk
 * Change representation of documents
* Tokenize documents into n-gram bag of words
* Parse documents
* Tag words as special
* Perform stemming
* Stream documents to produce
* Assign categories to documents
* Classification and regresssion

