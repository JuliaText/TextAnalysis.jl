@testset "Metadata" begin
    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"

    sd1 = StringDocument(sample_text1)
    sd2 = StringDocument(sample_text2)
    crps = Corpus([sd1, sd2])

    # Single document metadata getters
    @test isequal(name(sd1), "Unnamed Document")
    @test isequal(language(sd1), Languages.English())
    @test isequal(author(sd1), "Unknown Author")
    @test isequal(timestamp(sd1), "Unknown Time")
    @test isequal(id(sd1), "Unknown ID")
    @test isequal(publisher(sd1), "Unknown Publisher")
    @test isequal(published_year(sd1), "Unknown Publishing Year")
    @test isequal(edition_year(sd1), "Unknown Edition Year")
    @test isequal(documenttype(sd1), "Unknown Type")

    # Single document metadata setters
    name!(sd1, "Document")
    language!(sd1, Languages.German())
    author!(sd1, "Author")
    timestamp!(sd1, "Time")
    id!(sd1, "ID")
    publisher!(sd1, "Publisher")
    published_year!(sd1, "Publishing Year")
    edition_year!(sd1, "Edition Year")
    documenttype!(sd1, "Type")

    @test isequal(name(sd1), "Document")
    @test isequal(language(sd1), Languages.German())
    @test isequal(author(sd1), "Author")
    @test isequal(timestamp(sd1), "Time")
    @test isequal(id(sd1), "ID")
    @test isequal(publisher(sd1), "Publisher")
    @test isequal(published_year(sd1), "Publishing Year")
    @test isequal(edition_year(sd1), "Edition Year")
    @test isequal(documenttype(sd1), "Type")

    # Metadata getters for an entire corpus
    @test isequal(TextAnalysis.names(crps), ["Document", "Unnamed Document"])
    @test isequal(languages(crps), [Languages.German(), Languages.English()])
    @test isequal(authors(crps), ["Author", "Unknown Author"])
    @test isequal(timestamps(crps), ["Time", "Unknown Time"])
    @test isequal(ids(crps), ["ID", "Unknown ID"])
    @test isequal(publishers(crps), ["Publisher", "Unknown Publisher"])
    @test isequal(published_years(crps), ["Publishing Year", "Unknown Publishing Year"])
    @test isequal(edition_years(crps), ["Edition Year", "Unknown Edition Year"])
    @test isequal(documenttypes(crps), ["Type", "Unknown Type"])

    # Metadata setters for an entire corpus
    names!(crps, "Document")
    languages!(crps, Languages.Spanish())
    authors!(crps, "Author")
    timestamps!(crps, "Time")
    ids!(crps, "ID")
    publishers!(crps, "Publisher")
    published_years!(crps, "Publishing Year")
    edition_years!(crps, "Edition Year")
    documenttypes!(crps, "Type")
    @test isequal(TextAnalysis.names(crps), ["Document", "Document"])
    @test isequal(languages(crps), [Languages.Spanish(), Languages.Spanish()])
    @test isequal(authors(crps), ["Author", "Author"])
    @test isequal(timestamps(crps), ["Time", "Time"])
    @test isequal(ids(crps), ["ID", "ID"])
    @test isequal(publishers(crps), ["Publisher", "Publisher"])
    @test isequal(published_years(crps), ["Publishing Year", "Publishing Year"])
    @test isequal(edition_years(crps), ["Edition Year", "Edition Year"])
    @test isequal(documenttypes(crps), ["Type", "Type"])

    names!(crps, ["Unnamed Document", "Unnamed Document"])
    languages!(crps, [Languages.English(), Languages.English()])
    authors!(crps, ["Unknown Author", "Unknown Author"])
    timestamps!(crps, ["Unknown Time", "Unknown Time"])
    ids!(crps, ["Unknown ID", "Unknown ID"])
    publishers!(crps, ["Unknown Publisher", "Unknown Publisher"])
    published_years!(crps, ["Unknown Publishing Year", "Unknown Publishing Year"])
    edition_years!(crps, ["Unknown Edition Year", "Unknown Edition Year"])
    documenttypes!(crps, ["Unknown Type", "Unknown Type"])
    @test isequal(TextAnalysis.names(crps), ["Unnamed Document", "Unnamed Document"])
    @test isequal(languages(crps), [Languages.English(), Languages.English()])
    @test isequal(authors(crps), ["Unknown Author", "Unknown Author"])
    @test isequal(timestamps(crps), ["Unknown Time", "Unknown Time"])
    @test isequal(ids(crps), ["Unknown ID", "Unknown ID"])
    @test isequal(publishers(crps), ["Unknown Publisher", "Unknown Publisher"])
    @test isequal(published_years(crps), ["Unknown Publishing Year", "Unknown Publishing Year"])
    @test isequal(edition_years(crps), ["Unknown Edition Year", "Unknown Edition Year"])
    @test isequal(documenttypes(crps), ["Unknown Type", "Unknown Type"])
end
