load("src/init.jl")

articles("english")
prepositions("english")
pronouns("english")
stopwords("english")

doc = Document()
doc.text = "this is sample text"
remove_articles(doc)
doc.text

doc = Document()
doc.text = "this is sample text"
remove_prepositions(doc)
doc.text

doc = Document()
doc.text = "this is sample text"
remove_pronouns(doc)
doc.text

doc = Document()
doc.text = "this is sample text"
remove_stopwords(doc)
doc.text
