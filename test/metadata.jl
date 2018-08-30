
@testset "Metadata" begin

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    sd1 = StringDocument(sample_text1)
    sd2 = StringDocument(sample_text2)
    crps = Corpus([sd1, sd2])

    # Single document metadata getters
    @test isequal(name(sd1), "Unnamed Document")
    @test isequal(language(sd1), Languages.English())
    @test isequal(author(sd1), "Unknown Author")
    @test isequal(timestamp(sd1), "Unknown Time")

    # Single document metadata setters
    name!(sd1, "Document")
    language!(sd1, Languages.German())
    author!(sd1, "Author")
    timestamp!(sd1, "Time")
    @test isequal(name(sd1), "Document")
    @test isequal(language(sd1), Languages.German())
    @test isequal(author(sd1), "Author")
    @test isequal(timestamp(sd1), "Time")

    # Metadata getters for an entire corpus
    @test isequal(TextAnalysis.names(crps), ["Document", "Unnamed Document"])
    @test isequal(languages(crps), [Languages.German(), Languages.English()])
    @test isequal(authors(crps), ["Author", "Unknown Author"])
    @test isequal(timestamps(crps), ["Time", "Unknown Time"])
end
