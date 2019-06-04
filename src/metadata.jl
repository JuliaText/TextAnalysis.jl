import Languages.name

"""
    title(doc)

Return the title metadata for `doc`.

See also: [`title!`](@ref), [`titles`](@ref), [`titles!`](@ref)
"""
title(d::AbstractDocument) = d.metadata.title

"""
    language(doc)

Return the language metadata for `doc`.

See also: [`language!`](@ref), [`languages`](@ref), [`languages!`](@ref)
"""
language(d::AbstractDocument) = d.metadata.language

"""
    author(doc)

Return the author metadata for `doc`.

See also: [`author!`](@ref), [`authors`](@ref), [`authors!`](@ref)
"""
author(d::AbstractDocument) = d.metadata.author

"""
    timestamp(doc)

Return the timestamp metadata for `doc`.

See also: [`timestamp!`](@ref), [`timestamps`](@ref), [`timestamps!`](@ref)
"""
timestamp(d::AbstractDocument) = d.metadata.timestamp


"""
    title!(doc, str)

Set the title of `doc` to `str`.

See also: [`title`](@ref), [`titles`](@ref), [`titles!`](@ref)
"""
function title!(d::AbstractDocument, nv::AbstractString)
    d.metadata.title = nv
end

"""
    language!(doc, lang::Language)

Set the language of `doc` to `lang`.

# Example
```julia-repl
julia> d = StringDocument("String Document 1")

julia> language!(d, Languages.Spanish())

julia> d.metadata.language
Languages.Spanish()
```

See also: [`language`](@ref), [`languages`](@ref), [`languages!`](@ref)
"""
function language!(d::AbstractDocument, nv::Language)
    d.metadata.language = nv
end

"""
    author!(doc, author)

Set the author metadata of doc to `author`.

See also: [`author`](@ref), [`authors`](@ref), [`authors!`](@ref)
"""
function author!(d::AbstractDocument, nv::AbstractString)
    d.metadata.author = nv
end

"""
    timestamp!(doc, timestamp::AbstractString)

Set the timestamp metadata of doc to `timestamp`.

See also: [`timestamp`](@ref), [`timestamps`](@ref), [`timestamps!`](@ref)
"""
function timestamp!(d::AbstractDocument, nv::AbstractString)
    d.metadata.timestamp = nv
end


"""
    titles(crps)

Return the titles for each document in `crps`.

See also: [`titles!`](@ref), [`title`](@ref), [`title!`](@ref)
"""
titles(c::Corpus) = map(d -> title(d), documents(c))

"""
    languages(crps)

Return the languages for each document in `crps`.

See also: [`languages!`](@ref), [`language`](@ref), [`language!`](@ref)
"""
languages(c::Corpus) = map(d -> language(d), documents(c))

"""
    authors(crps)

Return the authors for each document in `crps`.

See also: [`authors!`](@ref), [`author`](@ref), [`author!`](@ref)
"""
authors(c::Corpus) = map(d -> author(d), documents(c))

"""
    timestamps(crps)

Return the timestamps for each document in `crps`.

See also: [`timestamps!`](@ref), [`timestamp`](@ref), [`timestamp!`](@ref)
"""
timestamps(c::Corpus) = map(d -> timestamp(d), documents(c))

titles!(c::Corpus, nv::AbstractString) = title!.(documents(c), nv)
languages!(c::Corpus, nv::T) where {T <: Language} = language!.(documents(c), Ref(nv)) #Ref to force scalar broadcast
authors!(c::Corpus, nv::AbstractString) = author!.(documents(c), Ref(nv))
timestamps!(c::Corpus, nv::AbstractString) = timestamp!.(documents(c), Ref(nv))

"""
    titles!(crps, vec::Vector{String})
    titles!(crps, str)

Update titles of the documents in a Corpus.

If the input is a String, set the same title for all documents. If the input is a vector, set title of `i`th document to corresponding `i`th element in the vector `vec`. In the latter case, the number of documents must equal the length of vector.

See also: [`titles`](@ref), [`title!`](@ref), [`title`](@ref)
"""
function titles!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        title!(d, nvs[i])
    end
end

"""
    languages!(crps, langs::Vector{Language})
    languages!(crps, lang::Language)

Update languages of documents in a Corpus.

If the input is a Vector, then language of the `i`th document is set to the `i`th element in the vector, respectively. However, the number of documents must equal the length of vector.

See also: [`languages`](@ref), [`language!`](@ref), [`language`](@ref)
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

See also: [`authors`](@ref), [`author!`](@ref), [`author`](@ref)
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

See also: [`timestamps`](@ref), [`timestamp!`](@ref), [`timestamp`](@ref)
"""
function timestamps!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        timestamp!(d, nvs[i])
    end
end
