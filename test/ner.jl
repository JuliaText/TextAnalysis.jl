using WordTokenizers

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
end
