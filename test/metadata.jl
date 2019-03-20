@testset "Metadata" begin
    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"

    sd1 = StringDocument(sample_text1)
    sd2 = StringDocument(sample_text2)
    crps = Corpus([sd1, sd2])

    # Single document metadata getters
    @test isequal(title(sd1), "Untitled Document")
    @test isequal(language(sd1), Languages.English())
    @test isequal(author(sd1), "Unknown Author")
    @test isequal(timestamp(sd1), "Unknown Time")

    # Single document metadata setters
    title!(sd1, "Document")
    language!(sd1, Languages.German())
    author!(sd1, "Author")
    timestamp!(sd1, "Time")
    @test isequal(title(sd1), "Document")
    @test isequal(language(sd1), Languages.German())
    @test isequal(author(sd1), "Author")
    @test isequal(timestamp(sd1), "Time")

    # Metadata getters for an entire corpus
    @test isequal(TextAnalysis.titles(crps), ["Document", "Untitled Document"])
    @test isequal(languages(crps), [Languages.German(), Languages.English()])
    @test isequal(authors(crps), ["Author", "Unknown Author"])
    @test isequal(timestamps(crps), ["Time", "Unknown Time"])

    # Metadata setters for an entire corpus
    titles!(crps, "Document")
    languages!(crps, Languages.Spanish())
    authors!(crps, "Author")
    timestamps!(crps, "Time")
    @test isequal(TextAnalysis.titles(crps), ["Document", "Document"])
    @test isequal(languages(crps), [Languages.Spanish(), Languages.Spanish()])
    @test isequal(authors(crps), ["Author", "Author"])
    @test isequal(timestamps(crps), ["Time", "Time"])
    titles!(crps, ["Untitled Document", "Untitled Document"])
    languages!(crps, [Languages.English(), Languages.English()])
    authors!(crps, ["Unknown Author", "Unknown Author"])
    timestamps!(crps, ["Unknown Time", "Unknown Time"])
    @test isequal(TextAnalysis.titles(crps), ["Untitled Document", "Untitled Document"])
    @test isequal(languages(crps), [Languages.English(), Languages.English()])
    @test isequal(authors(crps), ["Unknown Author", "Unknown Author"])
    @test isequal(timestamps(crps), ["Unknown Time", "Unknown Time"])
end
