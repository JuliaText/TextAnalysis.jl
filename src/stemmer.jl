const _libsb = joinpath(Pkg.dir(),"TextAnalysis","deps","usr","lib", "libstemmer."*BinDeps.shlib_ext)
#@BinDeps.load_dependencies [:libstemmer=>:_libsb]

##
# character encodings supported by libstemmer
const UTF_8         = "UTF_8"
const ISO_8859_1    = "ISO_8859_1"
const CP850         = "CP850"
const KOI8_R        = "KOI8_R"

##
# lists the stemmer algorithms loaded
function stemmer_types()
    cptr = ccall((:sb_stemmer_list, _libsb), Ptr{Ptr{UInt8}}, ())
    (C_NULL == cptr) && error("error getting stemmer types")

    stypes = AbstractString[]
    i = 1
    while true
        name_ptr = unsafe_load(cptr, i)
        (C_NULL == name_ptr) && break
        push!(stypes, bytestring(name_ptr))
        i += 1
    end
    stypes
end

type Stemmer
    cptr::Ptr{Void}
    alg::AbstractString
    enc::AbstractString

    function Stemmer(stemmer_type::AbstractString, charenc::AbstractString=UTF_8)
        cptr = ccall((:sb_stemmer_new, _libsb),
                    Ptr{Void},
                    (Ptr{UInt8}, Ptr{UInt8}),
                    bytestring(stemmer_type), bytestring(charenc))

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
    ccall((:sb_stemmer_delete, _libsb), Void, (Ptr{Void},), stm.cptr)
    stm.cptr = C_NULL
    nothing
end

stem(stemmer::Stemmer, word::AbstractString) = stem(stemmer, bytestring(word))
function stem(stemmer::Stemmer, bstr::ByteString)
    sres = ccall((:sb_stemmer_stem, _libsb),
                Ptr{UInt8},
                (Ptr{UInt8}, Ptr{UInt8}, Cint),
                stemmer.cptr, bstr, length(bstr))
    (C_NULL == sres) && error("error in stemming")
    slen = ccall((:sb_stemmer_length, _libsb), Cint, (Ptr{Void},), stemmer.cptr)
    bytes = pointer_to_array(sres, @compat(Int(slen)), false)
    bytestring(bytes)
end

function stem(stemmer::Stemmer, word::SubString{ByteString})
    sres = ccall((:sb_stemmer_stem, _libsb),
                Ptr{UInt8},
                (Ptr{UInt8}, Ptr{UInt8}, Cint),
                stemmer.cptr, pointer(word.string.data)+word.offset, word.endof)
    (C_NULL == sres) && error("error in stemming")
    slen = ccall((:sb_stemmer_length, _libsb), Cint, (Ptr{Void},), stemmer.cptr)
    bytes = pointer_to_array(sres, @compat(Int(slen)), false)
    bytestring(bytes)
end

function stem_all{S <: Language}(stemmer::Stemmer, lang::Type{S}, sentence::AbstractString)
    tokens = TextAnalysis.tokenize(lang, sentence)
    stemmed = stem(stemmer, tokens)
    join(stemmed, ' ')
end

function stem(stemmer::Stemmer, words::Array)
    const l::Int = length(words)
    ret = Array(AbstractString, l)
    for idx in 1:l
        ret[idx] = stem(stemmer, words[idx])
    end
    ret
end

function stemmer_for_document(d::AbstractDocument)
    Stemmer(name(language(d)))
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
