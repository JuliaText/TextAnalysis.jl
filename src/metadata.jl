import Languages.name

"""
    title(doc)

Return the title metadata for `doc`.
"""
title(d::AbstractDocument) = d.metadata.title

"""
    language(doc)

Return the language metadata for `doc`.
"""
language(d::AbstractDocument) = d.metadata.language

"""
    author(doc)

Return the author metadata for `doc`.
"""
author(d::AbstractDocument) = d.metadata.author

"""
    timestamp(doc)

Return the timestamp metadata for `doc`.
"""
timestamp(d::AbstractDocument) = d.metadata.timestamp


"""
    title!(doc, str)

Set the title of `doc` to `str`.
"""
function title!(d::AbstractDocument, nv::AbstractString)
    d.metadata.title = nv
end

"""
    language!(doc, lang)

Set the language of `doc` to `lang`.

# Example
```julia-repl
julia> d = StringDocument("String Document 1")

julia> language!(d, Languages.Spanish())

julia> d.metadata.language
Languages.Spanish()
```
"""
function language!(d::AbstractDocument, nv::T) where T <: Language
    d.metadata.language = nv
end

"""
    author!(doc, author)

Set the author metadata of doc to `author`.
"""
function author!(d::AbstractDocument, nv::AbstractString)
    d.metadata.author = nv
end

"""
    author!(doc, timestamp)

Set the timestamp metadata of doc to `timestamp`.
"""
function timestamp!(d::AbstractDocument, nv::AbstractString)
    d.metadata.timestamp = nv
end


"""
    titles(crps)

Return the titles for each document in `crps`.
"""
titles(c::Corpus) = map(d -> title(d), documents(c))

"""
    languages(crps)

Return the languages for each document in `crps`.
"""
languages(c::Corpus) = map(d -> language(d), documents(c))

"""
    authors(crps)

Return the authors for each document in `crps`.
"""
authors(c::Corpus) = map(d -> author(d), documents(c))

"""
    timestamps(crps)

Return the timestamps for each document in `crps`.
"""
timestamps(c::Corpus) = map(d -> timestamp(d), documents(c))

titles!(c::Corpus, nv::AbstractString) = title!.(documents(c), nv)
languages!(c::Corpus, nv::T) where {T <: Language} = language!.(documents(c), Ref(nv)) #Ref to force scalar broadcast
authors!(c::Corpus, nv::AbstractString) = author!.(documents(c), Ref(nv))
timestamps!(c::Corpus, nv::AbstractString) = timestamp!.(documents(c), Ref(nv))

"""
    titles!(crps, vec::Vector{String})
    titles!(crps, str::String)

Update titles of the documents in a Corpus.

If the input is a String, set the same title for all documents. If the input is a vector, set title of `i`th document to corresponding `i`th element in the vector `vec`. In the latter case, the number of documents must equal the length of vector.

See also: [`title!`](@ref), [`titles`](@ref)
"""
function titles!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        title!(d, nvs[i])
    end
end

"""
    languages!(crps, langs::Vector{T}) where T <: Language
    languages!(crps, lang::T) where T <: Language

Update languages of documents in a Corpus.

If the input is a Vector, then language of the `i`th document is set to the `i`th element in the vector, respectively. However, the number of documents must equal the length of vector.

See also: [`language!`](@ref), [`languages`](@ref)
"""
function languages!(c::Corpus, nvs::Vector{T}) where T <: Language
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        language!(d, nvs[i])
    end
end

"""
    authors!(crps, athrs)
    authors!(crps, athr)

Set the authors of the documents in `crps` to the `athrs`, respectively.
"""
function authors!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        author!(d, nvs[i])
    end
end

"""
    timestamps!(crps, times::Vector{String})
    timestamps!(crps, time::AbstractString)

Set the timestamps of the documents in `crps` to the timestamps in `times`, respectively.
"""
function timestamps!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        timestamp!(d, nvs[i])
    end
end
