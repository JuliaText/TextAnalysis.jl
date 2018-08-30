
@testset "Tokenizer" begin

    sample_text = "this is some sample text"

    tkns = TextAnalysis.tokenize(
        Languages.English(),
        sample_text
    )

    @test isequal(
        tkns,
        String["this", "is", "some", "sample", "text"]
    )
end
