
@testset "LDA" begin

    doc1 = "a a a sample text text"
    doc2 = "another example example text text"

    crps = Corpus(Any[StringDocument(doc1), StringDocument(doc2)])

    update_lexicon!(crps)

    dtm = DocumentTermMatrix(crps)
    ϕ, θ = lda(dtm, 2, 25, 0.1, 0.1)
    @test ϕ isa SparseMatrixCSC
    @test θ isa Matrix{Float64}
    @test all(sum(θ, dims=1) .≈ 1)
end
