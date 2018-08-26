module TestMetadata
    using Base.Test
    using Languages
    using TextAnalysis

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    sd = StringDocument(sample_text1)

    @assert isequal(name(sd), "Unnamed Document")
    @assert isequal(language(sd), Languages.English())
    @assert isequal(author(sd), "Unknown Author")
    @assert isequal(timestamp(sd), "Unknown Time")

    language!(sd, Languages.German())
    @assert isequal(language(sd), Languages.German())
end
