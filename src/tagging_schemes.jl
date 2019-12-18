# Ref:
# https://en.wikipedia.org/wiki/Inside%E2%80%93outside%E2%80%93beginning_(tagging)
# https://chameleonmetadata.com/Education/NLP-3/ref_nlp_encoding_schemes_list.php

abstract type tag_scheme end

struct BIO1 <: tag_scheme end # BIO
struct BIO2 <: tag_scheme end
struct BIOES <: tag_scheme end

const available_schemes = ["BIO1", "BIO2", "BIOES"]

"""
    tag_scheme!(tags, current_scheme::String, new_scheme::String)

Convert `tags` from `current_scheme` to `new_scheme`.

List of tagging schemes currently supported-
 * BIO1 (BIO)
 * BIO2
 * BIOES

# Example
```julia-repl
julia> tags = ["I-LOC", "O", "I-PER", "B-MISC", "I-MISC", "B-PER", "I-PER", "I-PER"]

julia> tag_scheme!(tags, "BIO1", "BIOES")

julia> tags
8-element Array{String,1}:
 "S-LOC"
 "O"
 "S-PER"
 "B-MISC"
 "E-MISC"
 "B-PER"
 "I-PER"
 "E-PER"
```
"""
function tag_scheme!(tags, current_scheme::String, new_scheme::String)
    current_scheme = uppercase(current_scheme)
    new_scheme = uppercase(new_scheme)
    (length(tags) == 0 || current_scheme == new_scheme) && return

    if new_scheme ∉ available_schemes || current_scheme ∉ available_schemes
        error("Invalid tagging scheme")
    end

    current_scheme = eval(Symbol(current_scheme))()
    new_scheme = eval(Symbol(new_scheme))()

    tag_scheme!(tags, current_scheme, new_scheme)
end

function tag_scheme!(tags, current_scheme::BIO1, new_scheme::BIO2)
    for i in eachindex(tags)
        if tags[i] == 'O' || tags[i][1] == "O"
            tags[i] = "O"
            continue
        end
        (tags[i][1] == 'O' || tags[i][1] == 'B') && continue

        if tags[i][1] == 'I'
            if i == 1
                tags[i] = 'B' * tags[i][2:end]
            elseif tags[i - 1] == "O" || tags[i - 1][2:end] != tags[i][2:end]
                tags[i] = 'B' * tags[i][2:end]
            else
                continue
            end
        else
            error("Invalid tags")
        end
    end
end

function tag_scheme!(tags, current_scheme::BIO2, new_scheme::BIO1)
    for i in eachindex(tags)
        if tags[i] == 'O' || tags[i][1] == "O"
            tags[i] = "O"
            continue
        end
        (tags[i][1] == 'O' || tags[i][1] == 'I') && continue

        if tags[i][1] == 'B'
            if i == length(tags)
                tags[i] = 'I' * tags[i][2:end]
            elseif tags[i + 1] == "O" || tags[i + 1][2:end] != tags[i][2:end]
                tags[i] = 'I' * tags[i][2:end]
            else
                continue
            end
        else
            error("Invalid tags")
        end
    end
end

function tag_scheme!(tags, current_scheme::BIO2, new_scheme::BIOES)
    for i in eachindex(tags)
        if tags[i] == 'O' || tags[i][1] == 'O'
            tags[i] = "O"
            continue
        end

        if tags[i][1] == 'I' && (i == length(tags) ||
                                 tags[i+1][2:end] != tags[i][2:end])
            tags[i] = 'E' * tags[i][2:end]
        elseif tags[i][1] == 'B' && (i == length(tags) ||
                                 tags[i+1][2:end] != tags[i][2:end])
            tags[i] = 'S' * tags[i][2:end]
        else
            (tags[i][1] == 'I' || tags[i][1] == 'B') && continue
            error("Invalid tags")
        end
    end
end

function tag_scheme!(tags, current_scheme::BIOES, new_scheme::BIO2)
    for i in eachindex(tags)
        if tags[i] == 'O' || tags[i][1] == 'O'
            tags[i] = "O"
            continue
        end
        (tags[i][1] == 'B' || tags[i][1] == 'I') && continue

        if tags[i][1] == 'E'
            tags[i] = 'I' * tags[i][2:end]
        elseif tags[i][1] == 'S'
            tags[i] = 'B' * tags[i][2:end]
        else
            error("Invalid tags")
        end
    end
end

function tag_scheme!(tags, current_scheme::BIO1, new_scheme::BIOES)
    tag_scheme!(tags, BIO1(), BIO2())
    tag_scheme!(tags, BIO2(), BIOES())
end

function tag_scheme!(tags, current_scheme::BIOES, new_scheme::BIO1)
    tag_scheme!(tags, BIOES(), BIO2())
    tag_scheme!(tags, BIO2(), BIO1())
end
