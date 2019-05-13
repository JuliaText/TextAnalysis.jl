import Languages.name

"""
    title(doc)

Returns the title metadata for `doc`
"""
title(d::AbstractDocument) = d.metadata.title

"""
    language(doc)

Returns the language metadata for `doc`
"""
language(d::AbstractDocument) = d.metadata.language

"""
    author(doc)

Returns the author metadata for `doc`
"""
author(d::AbstractDocument) = d.metadata.author

"""
    timestamp(doc)

Returns the timestamp metadata for `doc`
"""
timestamp(d::AbstractDocument) = d.metadata.timestamp


"""
    title!(doc, str)

Sets the title of `doc` to `str`
"""
function title!(d::AbstractDocument, nv::AbstractString)
    d.metadata.title = nv
end

"""
    language!(doc, lang)

Sets the language of `doc` to `lang`.

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
    author!(doc, authr)

Sets the `author` metadata of doc to `authr`
"""
function author!(d::AbstractDocument, nv::AbstractString)
    d.metadata.author = nv
end

"""
    author!(doc, timestmp)

Sets the `timestamp` metadata of doc to `timestmp`
"""
function timestamp!(d::AbstractDocument, nv::AbstractString)
    d.metadata.timestamp = nv
end


"""
    titles(crps)

Return the titles for each document in `crps`
"""
titles(c::Corpus) = map(d -> title(d), documents(c))

"""
    languages(crps)

Return the languages for each document in `crps`
"""
languages(c::Corpus) = map(d -> language(d), documents(c))

"""
    authors(crps)

Return the authors for each document in `crps`
"""
authors(c::Corpus) = map(d -> author(d), documents(c))

"""
    timestamps(crps)

Return the timestamps for each document in `crps`
"""
timestamps(c::Corpus) = map(d -> timestamp(d), documents(c))

titles!(c::Corpus, nv::AbstractString) = title!.(documents(c), nv)
languages!(c::Corpus, nv::T) where {T <: Language} = language!.(documents(c), Ref(nv)) #Ref to force scalar broadcast
authors!(c::Corpus, nv::AbstractString) = author!.(documents(c), Ref(nv))
timestamps!(c::Corpus, nv::AbstractString) = timestamp!.(documents(c), Ref(nv))

"""
    titles!(crps, ::Vector{String})
    titles!(crps, str)

Updates the titles of the documents in `crps` to the strings in the input vector.

See also: [`title!`](@ref), [`titles`](@ref)
"""
function titles!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        title!(d, nvs[i])
    end
end

"""
    languages!(crps, langs)
    languages!(crps, lang)

Updates the languages of the documents in `crps` to `langs`, respectively.
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

Sets the authors of the documents in `crps` to the `athrs`, respectively.
"""
function authors!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        author!(d, nvs[i])
    end
end

"""
    timestamps!(crps, times)
    timestamps!(crps, time)

Sets the timestamps of the documents in `crps` to the timestamps in `times`, respectively .
"""
function timestamps!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        timestamp!(d, nvs[i])
    end
end
