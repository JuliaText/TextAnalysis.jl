Base.show(io::IO, d::AbstractDocument) = print(io, "A $(typeof(d))")
Base.show(io::IO, crps::Corpus) = print(io, "A Corpus")
Base.show(io::IO, dtm::DocumentTermMatrix) = print(io, "A DocumentTermMatrix")

function Base.summary(d::AbstractDocument)
    o = ""
    o *= "A $(typeof(d))\n"
    o *= " * Language: $(language(d))\n"
    o *= " * Title: $(title(d))\n"
    o *= " * Author: $(author(d))\n"
    o *= " * Timestamp: $(timestamp(d))\n"

    if typeof(d) ∈ [TokenDocument, NGramDocument]
        o *= " * Snippet: ***SAMPLE TEXT NOT AVAILABLE***"
    else
        sample_text = replace(text(d)[1:min(50, length(text(d)))], r"\s+" => " ")
        o *= " * Snippet: $(sample_text)"
    end
    return o
end

function Base.summary(crps::Corpus)
    n = length(crps.documents)
    n_s = sum(map(d -> typeof(d) == StringDocument, crps.documents))
    n_f = sum(map(d -> typeof(d) == FileDocument, crps.documents))
    n_t = sum(map(d -> typeof(d) == TokenDocument, crps.documents))
    n_ng = sum(map(d -> typeof(d) == NGramDocument, crps.documents))
    o = ""
    o *= "A Corpus with $n documents:\n"
    o *= " * $n_s StringDocument's\n"
    o *= " * $n_f FileDocument's\n"
    o *= " * $n_t TokenDocument's\n"
    o *= " * $n_ng NGramDocument's\n\n"
    o *= "Corpus's lexicon contains $(lexicon_size(crps)) tokens\n"
    o *= "Corpus's index contains $(index_size(crps)) tokens"
    return o
end

function Base.summary(dtm::DocumentTermMatrix)
    n, p = size(dtm.dtm)
    @sprintf "A %dx%d DocumentTermMatrix" n p
end

repl_show(io::IO, d::AbstractDocument) = print(io, summary(d))
repl_show(io::IO, crps::Corpus) = print(io, summary(crps))
repl_show(io::IO, dtm::DocumentTermMatrix) = print(io, summary(dtm))
