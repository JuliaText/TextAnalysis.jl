using BSON
using WordTokenizers

spm = WordTokenizers.load(ALBERT_V1)
tok = ids_from_tokens(spm, spm("i love the julia language"))
segment = [1,1,1,1,1]

@testset "Transformers Model" begin
    @testset "albert_transformer" begin
        albert_transformer = TextAnalysis.ALBERT.albert_transformer(100,512,8,512,8,1,1)
        @test typeof(albert_transformer.linear) == Flux.Dense{typeof(identity),Array{Float32,2},Array{Float32,1}}
        @test albert_transformer.no_group == 1 
        @test albert_transformer.no_hid == 8
        @test albert_transformer.no_inner == 1
        x = randn(Float32, 100, 5, 2)
        x1 = x[:,:,1]
        @test size(albert_transformer(x)) == (512, 5, 2)
        @test size(albert_transformer(x1)) == (512, 5)
    end
    @testset "AL Group" begin
        ALBERT_Layer = TextAnalysis.ALBERT.ALGroup(300, 10, 400, 2, 1)
        @test length(ALBERT_Layer.ts) == 1 #unique layer
        @test size(ALBERT_Layer.ts[1](randn(Float32,300,5,2))) == (300, 5, 2)    
    end
end
@testset "pretraining" begin
    pretraining_transformer = TextAnalysis.ALBERT.create_albert()
    input_embedding = pretraining_transformer.embed(tok=tok, segment = segment)#getting embedding
    @test size(input_embedding) == (128,5)
    output = pretraining_transformer.transformers(input_embedding) #forward pass
    @test size(output) == (768,5)
    @test typeof(pretraining_transformer.classifier.pooler) == Flux.Dense{typeof(tanh),Array{Float32,2},Array{Float32,1}}
end
@testset "preprocess" begin
    sentences = [["i love julia language"],["It is as fast as C"]]
    preprocessed = TextAnalysis.ALBERT.preprocess_albert(sentences, spm)
    @test typeof(preprocessed[1].segment) == Array{Int64,2}
    @test typeof(preprocessed[1].tok) == Array{Int64,2}
    @test size(preprocessed[1].segment) == (16,1)
    @test size(preprocessed[2]) == (1, 16, 1) #masks for attention
end
