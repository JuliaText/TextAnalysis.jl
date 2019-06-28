@testset "Tagging_Schemes" begin
    @testset "BIO1 and BIO2" begin
        tags_BIO1 = ["I-LOC", "O", "I-PER", "B-MISC", "I-MISC", "I-ORG"]
        tags_BIO2 = ["B-LOC", "O", "B-PER", "B-MISC", "I-MISC", "B-ORG"]

        output_tags = deepcopy(tags_BIO1)
        tag_scheme!(tags_BIO1, "BIO1", "BIO2")
        @test tags_BIO1 == tags_BIO2

        tag_scheme!(tags_BIO1, "BIO2", "BIO1")
        @test tags_BIO1 == output_tags
    end

    @testset "BIO1 and BIOES" begin
        tags_BIO1 = ["I-LOC", "O", "I-PER", "B-MISC", "I-MISC", "B-PER",
                                                        "I-PER", "I-PER"]
        tags_BIOES = ["S-LOC", "O", "S-PER", "B-MISC", "E-MISC", "B-PER",
                                                        "I-PER", "E-PER"]

        output_tags = deepcopy(tags_BIO1)
        tag_scheme!(tags_BIO1, "BIO1", "BIOES")
        @test tags_BIO1 == tags_BIOES

        tag_scheme!(tags_BIO1, "BIOES", "BIO1")
        @test tags_BIO1 == output_tags
    end

    @testset "BIO2 and BIOES" begin
        tags_BIO2 = ["B-LOC", "O", "B-PER", "B-MISC", "I-MISC", "B-PER",
                                                        "I-PER", "I-PER"]
        tags_BIOES = ["S-LOC", "O", "S-PER", "B-MISC", "E-MISC", "B-PER",
                                                        "I-PER", "E-PER"]

        output_tags = deepcopy(tags_BIO2)
        tag_scheme!(tags_BIO2, "BIO2", "BIOES")
        @test tags_BIO2 == tags_BIOES

        tag_scheme!(tags_BIO2, "BIOES", "BIO2")
        @test tags_BIO2 == output_tags
    end
end
