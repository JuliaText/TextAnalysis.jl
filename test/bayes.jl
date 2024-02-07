@testset "Bayes" begin
    m = NaiveBayesClassifier([:spam, :ham])
    TextAnalysis.fit!(m, "this is ham", :ham)
    TextAnalysis.fit!(m, "this is spam", :spam)
    r = TextAnalysis.predict(m, "is this spam?")
    @test r[:spam] > r[:ham]

    @test_throws AssertionError TextAnalysis.fit!(m, "this is spam", :non_spam)

    n = NaiveBayesClassifier([:spam, :ham])
    TextAnalysis.fit!(n, StringDocument("this is ham"), :ham)
    TextAnalysis.fit!(n, StringDocument("this is spam"), :spam)
    p = TextAnalysis.predict(n, TokenDocument("is this spam?"))
    @test p[:spam] > p[:ham]
    @test p[:spam] == r[:spam]
end
