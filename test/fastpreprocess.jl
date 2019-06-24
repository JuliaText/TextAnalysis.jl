@testset "Preprocessing" begin
    @testset "Words Removal" begin
        doc = StringDocument("this is a the sample text")
        fastpreprocess(doc, strip_articles)
        @test isequal(doc.text, "this is sample text")

        doc = Document("this is the sample text")
        fastpreprocess(doc, strip_definite_articles)
        @test isequal(doc.text, "this is sample text")

        doc = Document("this is a sample text")
        fastpreprocess(doc, strip_indefinite_articles)
        @test isequal(doc.text, "this is sample text")

        doc = Document("this is on sample text")
        fastpreprocess(doc, strip_prepositions)
        @test isequal(doc.text, "this is sample text")

        doc = Document("this is my sample text")
        fastpreprocess(doc, strip_pronouns)
        @test isequal(doc.text, "this is sample text")

        doc = Document("this is sample text")
        fastpreprocess(doc, strip_stopwords)
        @test isequal(strip(doc.text), "sample text")
    end

    # test Remove Corrupt UT8
    sd = StringDocument("abc")
    fastpreprocess(sd)
    @test sd.text == "abc"

    sd = StringDocument(String([0x43, 0xf0]))
    fastpreprocess(sd)
    @test sd.text == "C"
end
