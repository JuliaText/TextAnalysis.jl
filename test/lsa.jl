using LinearAlgebra

@testset "lsa" begin
    crps = Corpus([StringDocument("this is a string document"), TokenDocument("this is a token document")])
    F1 = lsa(crps)

    update_lexicon!(crps)
    m = DocumentTermMatrix(crps)

    # lsa on crps
    @test typeof(F1) <: LinearAlgebra.SVD
    @test F1.U * LinearAlgebra.Diagonal(F1.S) * F1.Vt == Matrix(tf_idf(m))

    # lsa on dtm
    F2 = lsa(m)
    @test typeof(F2) <: LinearAlgebra.SVD
    @test F2.U * LinearAlgebra.Diagonal(F2.S) * F2.Vt == Matrix(tf_idf(m))


    @test F1 == F2
end
