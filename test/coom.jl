@testset "COOM (Co-occurence Matrix)" begin
    doc_raw = StringDocument("This is a document. It has two sentences.")
    prepare!(doc_raw, strip_punctuation | strip_whitespace | strip_case)
    doc = text(doc_raw)
    sd = StringDocument(doc)
    td = TokenDocument(doc)
    nd = NGramDocument(doc)
    crps = Corpus([sd, td])
    T = Float16
    # Results for window = 5, all terms in document used
    # expected_result_C is the expected matrix for the normalized and default mode case.
    expected_result_C = [ # for window == 5
        0.0 2.0 1.0 2/3 0.5 0.4 0.0 0.0
        2.0 0.0 2.0 1.0 2/3 0.5 0.4 0.0
        1.0 2.0 0.0 2.0 1.0 2/3 0.5 0.4
        2/3 1.0 2.0 0.0 2.0 1.0 2/3 0.5
        0.5 2/3 1.0 2.0 0.0 2.0 1.0 2/3
        0.4 0.5 2/3 1.0 2.0 0.0 2.0 1.0
        0.0 0.4 0.5 2/3 1.0 2.0 0.0 2.0
        0.0 0.0 0.4 0.5 2/3 1.0 2.0 0.0]

    # expected_result_D is the expected matrix for the normalized and directional mode case.
    expected_result_D = [ # for window == 5
        0.0 1.0 0.5 1/3 0.25 0.2 0.0 0.0
        1.0 0.0 1.0 0.5 1/3 0.25 0.2 0.0
        0.5 1.0 0.0 1.0 0.5 1/3 0.25 0.2
        1/3 0.5 1.0 0.0 1.0 0.5 1/3 0.25
        0.25 1/3 0.5 1.0 0.0 1.0 0.5 1/3
        0.2 0.25 1/3 0.5 1.0 0.0 1.0 0.5
        0.0 0.2 0.25 1/3 0.5 1.0 0.0 1.0
        0.0 0.0 0.2 0.25 1/3 0.5 1.0 0.0]
    # Verify untyped constructor
    terms = tokens(td)
    for d in [sd, td, crps]
        C = TextAnalysis.CooMatrix(d, terms)
        D = TextAnalysis.CooMatrix(d, terms, mode=:directional)
        if !(d isa Corpus)
            @test TextAnalysis.coom(C) == expected_result_C
            @test TextAnalysis.coom(D) == expected_result_D
        else
            @test TextAnalysis.coom(C) == length(crps) * expected_result_C
            @test TextAnalysis.coom(D) == length(crps) * expected_result_D
        end
    end
    @test_throws ErrorException TextAnalysis.CooMatrix(nd)

    # Verify typed constructor
    terms = tokens(td)
    for d in [sd, td, crps]
        C = TextAnalysis.CooMatrix{T}(d, terms)
        D = TextAnalysis.CooMatrix{T}(d, terms, mode=:directional)
        @test C isa TextAnalysis.CooMatrix{T}
        if !(d isa Corpus)
            @test TextAnalysis.coom(C) == T.(expected_result_C)
            @test TextAnalysis.coom(D) == T.(expected_result_D)
        else
            @test TextAnalysis.coom(C) == length(crps) * T.(expected_result_C)
            @test TextAnalysis.coom(D) == length(crps) * T.(expected_result_D)
        end
    end
    @test_throws ErrorException TextAnalysis.CooMatrix{T}(nd)

    # Results for window = 1, custom terms
    terms = ["this", "document", "it"]
    expected_result_C = [0.0 0.0 0.0; # document
        0.0 0.0 2.0; # it
        0.0 2.0 0.0] # this

    expected_result_D = [0.0 0.0 0.0; # document
        0.0 0.0 1.0; # it
        0.0 1.0 0.0] # this

    # Verify untyped constructor
    for d in [sd, td, crps]
        C = TextAnalysis.CooMatrix(d, terms, window=1)
        D = TextAnalysis.CooMatrix(d, terms, window=1, mode=:directional)
        if !(d isa Corpus)
            @test TextAnalysis.coom(C) == T.(expected_result_C)
            @test TextAnalysis.coom(D) == T.(expected_result_D)
        else
            @test TextAnalysis.coom(C) == length(crps) * T.(expected_result_C)
            @test TextAnalysis.coom(D) == length(crps) * T.(expected_result_D)
        end
    end
    @test_throws ErrorException TextAnalysis.CooMatrix(nd)

    # Verify typed constructor
    for d in [sd, td, crps]
        C = TextAnalysis.CooMatrix{T}(d, terms, window=1)
        D = TextAnalysis.CooMatrix{T}(d, terms, window=1, mode=:directional)
        @test C isa TextAnalysis.CooMatrix{T}
        if !(d isa Corpus)
            @test TextAnalysis.coom(C) == T.(expected_result_C)
            @test TextAnalysis.coom(D) == T.(expected_result_D)
        else
            @test TextAnalysis.coom(C) == length(crps) * T.(expected_result_C)
            @test TextAnalysis.coom(D) == length(crps) * T.(expected_result_D)
        end
    end
    @test_throws ErrorException TextAnalysis.CooMatrix{T}(nd)
end
