@testset "Sentiment" begin
    m = SentimentAnalyzer()

    d = StringDocument("a very nice thing that everyone likes")

    @test m(d) > 0.5

    d = StringDocument("a horrible thing that everyone hates")

    @test m(d) < 0.5

    # testing default behaviour of handle_unknown
    d = StringDocument("some sense and some nonSense")

    @test m(d) < 0.5

    # testing behaviour of words which are present in dictionary but do not have embedding assigned
    d = StringDocument("some sense and some duh")

    @test m(d) < 0.5

    # testing user given handle_unknown function
    d = Document("a Horrible thing that Everyone Hates")
   
    @test m(d, (x) -> [lowercase(x)]) < 0.5

    # Make it throw an error when unknown word encountered
    d = Document("some sense and some Hectic")
   
    @test_throws ErrorException m(d, (x) -> error("OOV word $x encountered"))

end
