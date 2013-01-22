using TextAnalysis

sample_text = "this is some sample text"
tkns = TextAnalysis.tokenize(Languages.EnglishLanguage, sample_text)
@assert isequal(tkns, UTF8String["this", "is", "some", "sample", "text"])
