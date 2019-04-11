
@testset "Bayes" begin

m=NaiveBayesClassifier([:spam, :ham])
TextAnalysis.fit!(m, "this is ham", :ham);
TextAnalysis.fit!(m, "this is spam", :spam);
r = TextAnalysis.predict(m, "is this spam?")
@test r[:spam] > r[:ham]

end
