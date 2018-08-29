
@testset "Metadata" begin

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    sd = StringDocument(sample_text1)

    @test isequal(name(sd), "Unnamed Document")
    @test isequal(language(sd), Languages.English())
    @test isequal(author(sd), "Unknown Author")
    @test isequal(timestamp(sd), "Unknown Time")

    language!(sd, Languages.German())
    @test isequal(language(sd), Languages.German())
end
