
@testset "DTM" begin
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    fd = FileDocument(sample_file)
    sd = StringDocument(text(fd))

    crps = Corpus(Any[fd, sd])

    m = DocumentTermMatrix(crps)
    dtm(m)
    dtm(m, :dense)

    update_lexicon!(crps)

    m = DocumentTermMatrix(crps)
    dtm(m)
    dtm(m, :dense)

    tf_idf(dtm(m, :dense))

    dtv(crps[1], lexicon(crps))

    hash_dtv(crps[1], TextHashFunction())
    hash_dtv(crps[1])

    dtm1 = dtm(crps)
    dtm1sp = sparse(dtm(crps))
    hash_dtm(crps)

    tdm(crps)
    hash_tdm(crps)

    # construct a DocumentTermMatrix from a crps and a custom terms vector
    terms = ["And", "notincrps"]
    m = DocumentTermMatrix(crps, terms)
    @test size(dtm(m), 1) == length(terms)
    @test terms == m.terms
    @test size(dtm(m), 2) == length(crps)

    # construct a DocumentTermMatrix from a crps and a custom lexicon
    lex = Dict("And" => 1, "notincrps" => 4)
    m = DocumentTermMatrix(crps, lex)
    @test size(dtm(m), 1) == length(keys(lex))
    @test size(dtm(m), 1) == length(m.terms)
    @test size(dtm(m), 2) == length(crps)

    # construct a DocumentTermMatrix from a dtm and terms vector
    terms = m.terms
    m2 = DocumentTermMatrix(dtm1, terms)
    @test m.column_indices == m2.column_indices
    m2 = DocumentTermMatrix(dtm1sp, terms)
    @test m.column_indices == m2.column_indices

    # test serialization and deserialization
    mktemp() do path, io
        serialize(io, m2)
        close(io)
        open(path, "r") do rio
            m3 = deserialize(rio)
            @test typeof(m2) == typeof(m3)
            @test m2.terms == m3.terms
            @test m2.dtm == m3.dtm
            @test m2.column_indices == m3.column_indices
        end
    end

    # test prune! and merge!
    crps1 = Corpus([StringDocument("one two three"), StringDocument("two three four")])
    crps2 = Corpus([StringDocument("two three four"), StringDocument("three four five")])
    update_lexicon!(crps1)
    update_lexicon!(crps2)
    dtm1 = DocumentTermMatrix(crps1)
    dtm2 = DocumentTermMatrix(crps2)

    prune!(dtm1, nothing; compact=false)
    @test length(dtm1.terms) == 4
    @test size(dtm1.dtm) == (2, 4)

    prune!(dtm1, [1]; compact=false)
    @test length(dtm1.terms) == 4
    @test size(dtm1.dtm) == (1, 4)

    dtm1 = DocumentTermMatrix(crps1)
    prune!(dtm1, [1]; compact=true)
    @test length(dtm1.terms) == 3
    @test size(dtm1.dtm) == (1, 3)

    dtm1 = DocumentTermMatrix(crps1)
    prune!(dtm1, [1]; compact=true, retain_terms=["one"])
    @test length(dtm1.terms) == 4
    @test size(dtm1.dtm) == (1, 4)

    merge!(dtm1, dtm2)
    @test size(dtm1.dtm) == (3, 5)
    @test sum(dtm1.dtm, dims=(1,)) == [1 3 0 3 2]
    @test dtm1.terms == ["five", "four", "one", "three", "two"]

    dtm2 = DocumentTermMatrix(crps2)
    dtm1.dtm = similar(dtm1.dtm, 0, dtm1.dtm.n)
    merge!(dtm1, dtm2)
    @test dtm1.terms == ["five", "four", "one", "three", "two"]
    @test size(dtm1.dtm) == (2, 5)
    @test sum(dtm1.dtm, dims=(1,)) == [1 2 0 2 1]

    dtm2 = DocumentTermMatrix(crps2)
    dtm1.dtm = similar(dtm1.dtm, 0, dtm1.dtm.n)
    merge!(dtm2, dtm1)
    @test dtm2.terms == ["five", "four", "three", "two"]
    @test size(dtm2.dtm) == (2, 4)
    @test sum(dtm2.dtm, dims=(1,)) == [1 2 2 1]
end
