module TestMetadata
    using Base.Test
    using Languages
    using TextAnalysis

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    sd = StringDocument(sample_text1)

    @assert isequal(name(sd), "Unnamed Document")
    @assert isequal(language(sd), TextAnalysis.Languages.EnglishLanguage)
    @assert isequal(author(sd), "Unknown Author")
    @assert isequal(timestamp(sd), "Unknown Time")
end
