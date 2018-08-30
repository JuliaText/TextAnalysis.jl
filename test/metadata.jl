
@testset "Metadata" begin

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    sd = StringDocument(sample_text1)

    # Single document metadata getters
    @test isequal(name(sd), "Unnamed Document")
    @test isequal(language(sd), Languages.English())
    @test isequal(author(sd), "Unknown Author")
    @test isequal(timestamp(sd), "Unknown Time")

    # Single document metadata setters
    name!(sd, "Document")
    language!(sd, Languages.German())
    author!(sd, "Author")
    timestamp!(sd, "Time")
    @test isequal(name(sd), "Document")
    @test isequal(language(sd), Languages.German())
    @test isequal(author(sd), "Author")
    @test isequal(timestamp(sd), "Time")
end
