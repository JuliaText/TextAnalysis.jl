using TextAnalysis: AveragePerceptron

@testset "Average Perceptron Tagger" begin
    tagger = PerceptronTagger(false)

    @testset "Basic" begin
        @test typeof(tagger.classes) == Set{Any}
        @test length(tagger.classes) == 0
        @test typeof(tagger.model) == AveragePerceptron

        fit!(tagger, [[("today","NN"),("is","VBZ"),("good","JJ"),("day","NN")]])
        @test length(keys(tagger.model.weights)) == 51
        @test tagger.classes == tagger.model.classes == Set(["JJ", "VBZ", "NN"])
    end

    @testset "Average Perceptron Tagger (pretrained)" begin
        tagger = PerceptronTagger(true)

        @test typeof(tagger.classes) == Set{Any}
        @test length(tagger.classes) == 75
        @test typeof(tagger.model) == AveragePerceptron
    end

    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")


    @testset "Tagging over sentences and documents" begin
        tagger = PerceptronTagger(true)
        text = "This is a text"
        @test tagger(text) == predict(tagger, text)

        sd = StringDocument(text)
        @test length(predict(tagger, text)) == 4
        @test length(predict(tagger, sd)) == 4

        text2 = read(sample_file, String)
        fd = FileDocument(sample_file)
        @test length(predict(tagger, fd)) == length(predict(tagger, text2))

        td = TokenDocument(text)
        @test length(predict(tagger, td)) == 4
    end
end
