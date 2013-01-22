sample_text1 = "This is 1 MESSED UP string!"
sample_text1_wo_punctuation = "This is 1 MESSED UP string"
sample_text1_wo_punctuation_numbers = "This is  MESSED UP string"
sample_text1_wo_punctuation_numbers_case = "this is  messed up string"

sd = StringDocument(sample_text1)

remove_punctuation!(sd)

remove_numbers!(sd)

remove_case!(sd)

# Need to only remove words at word boundaries

doc = Document("this is sample text")
remove_words!(doc, ["sample"])
@assert isequal(doc.text, "this is   text")

doc = Document("this is sample text")
remove_articles!(doc)
@assert isequal(doc.text, "this is sample text")

doc = Document("this is sample text")
remove_definite_articles!(doc)
@assert isequal(doc.text, "this is sample text")

doc = Document("this is sample text")
remove_indefinite_articles!(doc)
@assert isequal(doc.text, "this is sample text")

doc = Document("this is sample text")
remove_prepositions!(doc)
@assert isequal(doc.text, "this is sample text")

doc = Document("this is sample text")
remove_pronouns!(doc)
@assert isequal(doc.text, "this is sample text")

doc = Document("this is sample text")
remove_stop_words!(doc)
@assert isequal(doc.text, "    sample text")

doc = Document("this is sample text")
remove_whitespace!(doc)
@assert isequal(doc.text, "this is sample text")

# stem!(sd)
# tag_pos!(sd)

# Do preprocessing on TokenDocument, NGramDocument, Corpus
d = NGramDocument("this is sample text")
remove_words!(d, ["sample"])
