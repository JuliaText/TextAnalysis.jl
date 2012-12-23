sample_text1 = "This is a string"
sample_text2 = "This is also a string"
sample_file = file_path(Pkg.package_directory("TextAnalysis"), "test", "data", "poem.txt")

sd = StringDocument(sample_text1)

@assert isequal(name(sd), "Unnamed Document")
@assert isequal(language(sd), TextAnalysis.Languages.EnglishLanguage)
@assert isequal(author(sd), "Unknown Author")
@assert isequal(timestamp(sd), "Unknown Time")
