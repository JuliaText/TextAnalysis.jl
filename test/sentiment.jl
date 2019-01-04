@testset "Sentiment" begin
    m = SentimentAnalyzer()

    d = StringDocument("a very nice thing that everyone likes")

    @test m(d) > 0.5

    d = StringDocument("a horrible thing that everyone hates")

    @test m(d) < 0.5
end
