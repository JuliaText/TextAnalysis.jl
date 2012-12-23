* Document Type
   * Description: A document
   * Attributes:
	   * text
	   * tokens
	   * n_grams
   * Children Types:
       * FileDocument
       * StringDocument
       * NGramDocument
* Corpus Type
	* Description: A vector of Document objects of any Document-based type
	* Attributes:
		* lexicon: Counts of terms across all documents
		* index + inverted index of terms in all documents
		* search(term): Return all documents containing a term
		* ref/assign
		* number_of_documents
* DocumentTermMatrix
* TermDocumentMatrix
* Preprocessing Operations:
	* Case standardization
	* Stemming
	* Stop word removal
* TF/IDF normalization

tokens -> converts string to token array retaining order
n_grams -> converts string to token array to bag of words n-gram representation

index: int to term mapping (Array)
inverted_index: term to int mapping (Dict)

document_term_matrix(dense + sparse versions all using Int64) [Specify lexicon]
term_document_matrix(dense + sparse versions all using Int64) [Specify lexicon]

each_document_term_vector: Iterator over rows of DTM
each_term_document_vector: Iterator over rows of TDM

What is API for using hashing trick instead of terms?
What is API for stop words?

text(Document)
tokens(Document)
n_grams(Document, n = 1)

How to update lexicon and corpus when new documents are added?
 * For Corpus

push(Corpus, Document)
Corpus[1] = Document
search(Corpus, Document)
search(Corpus, Term)
Corpus[Term]
Corpus[Int64]
Document[Term] - Word Counts
