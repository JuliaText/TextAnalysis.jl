using WordTokenizers, TextAnalysis, Test

@testset "NER" begin
    ner = NERTagger()

    @testset "Basic" begin
        str = "Mr. Foo Bar works in Google, California."
        @test ner(str) == ["O", "PER", "PER", "O", "O", "ORG", "O", "LOC", "O"]

        str = "If the Irish win the World Cup this year, it will be their 3rd time in a row."
        @test ner(str) == [ "O", "O", "MISC", "O", "O", "MISC", "MISC", "O", "O", "O", "O", "O", "O", "O", "O", "O", "O", "O", "O", "O", "O"]
    end

    @testset "Unknown Unicode characters" begin
        # Making sure that the NER model handles for unknown unicode characters
        str = "आ β⬰ 5¥ "
        @test length(ner(str)) == length(WordTokenizers.tokenize(str))

        str = "You owe John Doe 5¥."
        @test ner(str) ==  [ "O", "O", "PER", "PER", "O", "O", "O"]
    end

    @testset "Documents and Corpus" begin
        text1 = "We aRE vErY ClOSE tO ThE HEaDQuarTeRS."
        text2 = "The World Health Organization (WHO) is a specialized agency of the United Nations that is concerned with international public health."

        sd = StringDocument(text1)
        td = TokenDocument(text2)

        tags = ner(sd)
        @test length(tags) == length(WordTokenizers.split_sentences(text1))
        @test length(tags[1]) == length(WordTokenizers.tokenize(text1))
        @test unique(vcat(tags...)) == ["O"]

        tags = ner(td)
        @test length(tags) == length(WordTokenizers.split_sentences(text2))
        @test length(tags[1]) == length(WordTokenizers.tokenize(text2))
        u =  unique(vcat(tags...))
        @test "O" ∈ u && "ORG" ∈ u

        crps = Corpus([sd, td])
        tags = ner(crps)

        @test length(tags) == length(crps.documents)
        @test tags[1] == ner(crps.documents[1])
        @test tags[2] == ner(crps.documents[2])
    end
end
