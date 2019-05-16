using TextAnalysis: AveragePerceptron

@testset "Average Perceptron Tagger" begin
    tagger = PerceptronTagger(false)

    @test typeof(tagger.classes) == Set{Any}
    @test length(tagger.classes) == 0
    @test typeof(tagger.model) == AveragePerceptron

    train(tagger, [[("today","NN"),("is","VBZ"),("good","JJ"),("day","NN")]])
    @test length(keys(tagger.model.weights)) == 51
    @test tagger.classes == tagger.model.classes == Set(["JJ", "VBZ", "NN"])
end

##Uncomment these when pretrained Model file is present in the directory

# @testset "Average Perceptron Tagger (pretrained)" begin
#     tagger = PerceptronTagger(true)
#
#     @test typeof(tagger.classes) == Set{Any}
#     @test length(tagger.classes) == 75
#     @test typeof(tagger.model) == AveragePerceptron
# end
