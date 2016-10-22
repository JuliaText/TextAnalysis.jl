module TestTFIDF
    using Base.Test
    using Languages
    using TextAnalysis

    doc1 = "a a a sample text text"
    doc2 = "another example example text text"
    doc3 = ""
    doc4 = "another another text text text text"

    # TODO: this should work!
    # crps = Corpus(map(StringDocument, [doc1 doc2 doc3 doc4]))

    crps = Corpus(Any[StringDocument(doc1), StringDocument(doc2), StringDocument(doc3), StringDocument(doc4)])    

    update_lexicon!(crps)
    m = DocumentTermMatrix(crps)

    # Terms are in alphabetical ordering
    correctweights = [0.6931471805599453 0.0 0.0 0.23104906018664842 0.09589402415059362
	              0.0 0.13862943611198905 0.5545177444479562 0.0 0.11507282898071235
	              0.0 0.0 0.0 0.0 0.0
	              0.0 0.23104906018664842  0.0 0.0 0.19178804830118723]

    myweights = tf_idf(m)
    @test_approx_eq myweights correctweights
                       
    myweights = tf_idf(dtm(m))
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = tf_idf(dtm(m, :dense))
    @test isnan(sum(myweights)) == 0
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: Matrix

    myweights = float(dtm(m));
    tf_idf!(myweights)
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = float(dtm(m, :dense));
    tf_idf!(myweights)
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: Matrix
end
