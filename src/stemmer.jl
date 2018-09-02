#const libstemmer = joinpath(dirname(@__FILE__),"..","deps","usr","lib", "libstemmer."*Libdl.dlext)
#@BinDeps.load_dependencies [:libstemmer=>:libstemmer]

##
# character encodings supported by libstemmer
const UTF_8         = "UTF_8"
const ISO_8859_1    = "ISO_8859_1"
const CP850         = "CP850"
const KOI8_R        = "KOI8_R"

##
# lists the stemmer algorithms loaded
function stemmer_types()
    cptr = ccall((:sb_stemmer_list, libstemmer), Ptr{Ptr{UInt8}}, ())
    (C_NULL == cptr) && error("error getting stemmer types")

    stypes = AbstractString[]
    i = 1
    while true
        name_ptr = unsafe_load(cptr, i)
        (C_NULL == name_ptr) && break
        push!(stypes, unsafe_string(name_ptr))
        i += 1
    end
    stypes
end

mutable struct Stemmer
    cptr::Ptr{Void}
    alg::String
    enc::String

    function Stemmer(stemmer_type, charenc=UTF_8)
        cptr = ccall((:sb_stemmer_new, libstemmer),
                    Ptr{Void},
                    (Ptr{UInt8}, Ptr{UInt8}),
                    String(stemmer_type), String(charenc))

        if cptr == C_NULL
            if charenc == UTF_8
                error("stemmer '$(stemmer_type)' is not available")
            else
                error("stemmer '$(stemmer_type)' is not available for encoding '$(charenc)'")
            end
        end

        stm = new(cptr, stemmer_type, charenc)
        finalizer(stm, release)
        stm
    end
end

show(io::IO, stm::Stemmer) = println(io, "Stemmer algorithm:$(stm.alg) encoding:$(stm.enc)")

function release(stm::Stemmer)
    (C_NULL == stm.cptr) && return
    ccall((:sb_stemmer_delete, libstemmer), Void, (Ptr{Void},), stm.cptr)
    stm.cptr = C_NULL
    nothing
end

function stem(stemmer::Stemmer, bstr::AbstractString)
    sres = ccall((:sb_stemmer_stem, libstemmer),
                Ptr{UInt8},
                (Ptr{UInt8}, Ptr{UInt8}, Cint),
                stemmer.cptr, bstr, sizeof(bstr))
    (C_NULL == sres) && error("error in stemming")
    slen = ccall((:sb_stemmer_length, libstemmer), Cint, (Ptr{Void},), stemmer.cptr)
    bytes = unsafe_wrap(Array, sres, Int(slen), false)
    String(copy(bytes))
end


function stem_all(stemmer::Stemmer, lang::S, sentence::AbstractString) where S <: Language
    tokens = TextAnalysis.tokenize(lang, sentence)
    stemmed = stem(stemmer, tokens)
    join(stemmed, ' ')
end

function stem(stemmer::Stemmer, words::Array)
    l::Int = length(words)
    ret = Array{String}(l)
    for idx in 1:l
        ret[idx] = stem(stemmer, words[idx])
    end
    ret
end

function stemmer_for_document(d::AbstractDocument)
    Stemmer(lowercase(name(language(d))))
end

function stem!(d::AbstractDocument)
    stemmer = stemmer_for_document(d)
    stem!(stemmer, d)
    release(stemmer)
end

stem!(stemmer::Stemmer, d::FileDocument) = error("FileDocument cannot be modified")

function stem!(stemmer::Stemmer, d::StringDocument)
    stemmer = stemmer_for_document(d)
    d.text = stem_all(stemmer, language(d), d.text)
    nothing
end

function stem!(stemmer::Stemmer, d::TokenDocument)
    d.tokens = stem(stemmer, d.tokens)
    nothing
end

function stem!(stemmer::Stemmer, d::NGramDocument)
    for token in keys(d.ngrams)
        new_token = stem(stemmer, token)
        if new_token != token
            if haskey(d.ngrams, new_token)
                d.ngrams[new_token] = d.ngrams[new_token] + d.ngrams[token]
            else
                d.ngrams[new_token] = d.ngrams[token]
            end
            delete!(d.ngrams, token)
        end
    end
end

function stem!(crps::Corpus)
    stemmer = stemmer_for_document(crps.documents[1])
    for doc in crps
        stem!(stemmer, doc)
    end
    release(stemmer)
end
