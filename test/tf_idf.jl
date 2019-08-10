
@testset "TFIDF" begin

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
    correctweights =[0.5  0.0  0.0  1/6  1/3
                     0.0  0.2  0.4  0.0  0.4
                     0.0  0.0  0.0  0.0  0.0
                     0.0  1/3  0.0  0.0  2/3]

    myweights = tf(m)
    @test myweights == correctweights

    myweights = tf(dtm(m))
    @test myweights ≈ sparse(correctweights)
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = tf(dtm(m, :dense))
    @test isnan(sum(myweights)) == 0
    @test myweights ≈ correctweights
    @test typeof(myweights) <: Matrix

    myweights = float(dtm(m));
    tf!(myweights)
    @test myweights ≈ correctweights
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = float(dtm(m, :dense));
    tf!(myweights)
    @test myweights ≈ correctweights
    @test typeof(myweights) <: Matrix

    # Terms are in alphabetical ordering
    correctweights = [0.6931471805599453 0.0 0.0 0.23104906018664842 0.09589402415059362
	              0.0 0.13862943611198905 0.5545177444479562 0.0 0.11507282898071235
	              0.0 0.0 0.0 0.0 0.0
	              0.0 0.23104906018664842  0.0 0.0 0.19178804830118723]

    myweights = tf_idf(m)
    @test myweights ≈ correctweights

    myweights = tf_idf(dtm(m))
    @test myweights ≈ correctweights
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = tf_idf(dtm(m, :dense))
    @test isnan(sum(myweights)) == 0
    @test myweights ≈ correctweights
    @test typeof(myweights) <: Matrix

    myweights = float(dtm(m));
    tf_idf!(myweights)
    @test myweights ≈ correctweights
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = float(dtm(m, :dense));
    tf_idf!(myweights)
    @test myweights ≈ correctweights
    @test typeof(myweights) <: Matrix

    @testset "Okapi BM25" begin
        doc1 = "a a a sample text text"
        doc2 = "another example example text text"
        doc3 = ""
        doc4 = "another another text text text text"

        crps = Corpus(Any[StringDocument(doc1), StringDocument(doc2), StringDocument(doc3), StringDocument(doc4)])

        update_lexicon!(crps)
        m = DocumentTermMatrix(crps)

        max_tol = 1e-5
        approx_eq(m1::AbstractMatrix{T}, m2::AbstractMatrix{T}; tol=1e-6
                ) where T = begin
            t = all(abs.(m1-m2) .<= tol)
            return t
        end

        correctweights = [1.29959 0.0 0.0 1.89031 0.405067;
                          0.0 0.882404 1.54025 0.0 0.405067;
                          0.0 0.0 0.0 0.0 0.0;
                          0.0 1.40179 0.0 0.0 0.676646]

        myweights = bm_25(m)

        @test approx_eq(myweights, correctweights, tol=max_tol)

        myweights = bm_25(dtm(m))
        @test approx_eq(myweights, correctweights, tol=max_tol)
        @test typeof(myweights) <: SparseMatrixCSC

        myweights = bm_25(Matrix(dtm(m)))
        @test isnan(sum(myweights)) == 0
        @test approx_eq(myweights, correctweights, tol=max_tol)
        @test typeof(myweights) <: Matrix

        myweights = float(dtm(crps))
        myweights = bm_25(myweights)
        @test approx_eq(Float64.(myweights), correctweights, tol=max_tol)
        @test typeof(myweights) <: SparseMatrixCSC
        @test eltype(myweights) == typeof(1.0)

        myweights = float(Matrix(dtm(crps)));
        myweights = bm_25(myweights)
        @test approx_eq(Float64.(myweights), correctweights, tol=max_tol)
        @test typeof(myweights) <: Matrix
        @test eltype(myweights) == typeof(1.0)

        @test_throws MethodError bm_25!(DocumentTermMatrix(crps))
    end
end
