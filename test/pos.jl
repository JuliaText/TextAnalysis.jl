using WordTokenizers

@testset "POS" begin
    pos = POS_Tagger()

    @testset "Basic" begin
        str = "The very first major corpus of English for computer analysis was the Brown Corpus."
        @test pos(str) ==  ["DT", "RB", "JJ", "JJ", "NN", "IN", "JJ", "IN", "NN", "NN", "VBD", "DT", "NNP", "NNP", "."]

        str = "If the Irish win the World Cup this year, it will be their 3rd time in a row."
        @test pos(str) == ["IN", "DT", "NNP", "VBP", "DT", "NNP", "NNP", "DT", "NN", ",", "PRP", "MD", "VB", "PRP\$", "CD", "JJ", "NN", "IN", "DT", "NN", "."]
    end

    @testset "Unknown Unicode characters" begin
        # Making sure that the pos model handles for unknown unicode characters
        str = "आ β⬰ 5¥ "
        @test length(pos(str)) == length(WordTokenizers.tokenize(str))

        str = "You owe John Doe 5¥."
        @test pos(str) ==  ["PRP", "VBP", "NNP", "NNP", "CD", "NNP", "."]
    end

    @testset "Documents and Corpus" begin
        pos = POS_Tagger()

        text1 = "A little too small"
        text2 = "Here Foo Bar, please have some chocolate."

        sd = StringDocument(text1)
        td = TokenDocument(text2)

        tags = pos(sd)
        @test length(tags) == length(WordTokenizers.split_sentences(text1))
        @test length(tags[1]) == length(WordTokenizers.tokenize(text1))
        uniq1 = unique(vcat(tags...))
        @test "RB" ∈ uniq1
        @test "JJ" ∈ uniq1


        tags = pos(td)
        @test length(tags) == length(WordTokenizers.split_sentences(text2))
        @test length(tags[1]) == length(WordTokenizers.tokenize(text2))
        @test findall( x -> x == "NNP", vcat(tags...)) == [2, 3]

        crps = Corpus([sd, td])
        tags = pos(crps)

        @test length(tags) == length(crps.documents)
        @test tags[1] == pos(crps.documents[1])
        @test tags[2] == pos(crps.documents[2])
    end
end
