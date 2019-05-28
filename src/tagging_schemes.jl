# Ref:
# https://en.wikipedia.org/wiki/Inside%E2%80%93outside%E2%80%93beginning_(tagging)
# https://chameleonmetadata.com/Education/NLP-3/ref_nlp_encoding_schemes_list.php

# Tagging schemes for NER - BIO = BIO1, BIO2, BIOES / BILOU

abstract type tag_scheme end

struct BIO1 <: tag_scheme end # BIO
struct BIO2 <: tag_scheme end
struct BIOES <: tag_scheme end

const available_schemes = ["BIO1", "BIO2", "BIOES"]

"""
    tag_scheme(tags) => str::String

Identify tagging scheme and raise error for an invalid tagging scheme.
"""
function tag_scheme(tags)
    tag_scheme(tags, BIO1()) && return "BIO1"
    tag_scheme(tags, BIO2()) && return "BIO2"
    tag_scheme(tags, BIOES()) && return "BIOES"
end

function tag_scheme(tags, scheme::String)
    return tag_scheme(tags, eval(Symbol(scheme))())
end

# Validate the tagging scheme. Return false for invalid
function tag_scheme(tags, scheme::BIO1)
    return true
end

function tag_scheme(tags, scheme::BIO2)
    return true
end

function tag_scheme(tags, scheme::BIOES)
    return true
end

"""
    convert_tag_scheme(tags, current_scheme, new_scheme)
    convert_tag_scheme(tags, new_scheme)

Convert `tags` from `current_scheme` to `new_scheme`.

Delimiter between prefix and tag type is assumed to be `-`.
List of tagging schemes currently supported-
 * BIO1 (BIO)
 * BIO2
 * BIOES
"""
function tag_scheme!(tags, new_scheme::String)
    new_scheme = uppercase(new_scheme))
    length(tags) == 0 && return
    current_scheme = tag_scheme(tags)
    new_scheme ∈ available_schemes || error("Invalid tagging scheme")

    current_scheme == new_scheme && return
    tag_scheme!(tags, current_scheme, new_scheme)
end

function tag_scheme!(tags, current_scheme::String, new_scheme::String)
    current_scheme = uppercase(current_scheme))
    new_scheme = uppercase(new_scheme))
    (length(tags) == 0 || !tag_scheme(tags, current_scheme)) && return
    current_scheme != new_scheme || return
    if new_scheme ∉ available_schemes || !tag_scheme(tags, current_scheme)
        error("Invalid tagging scheme")
    end

    current_scheme = eval(Symbol(current_scheme))
    new_scheme = eval(Symbol(new_scheme))

    tag_scheme!(tags, current_scheme, new_scheme)
end



function tag_scheme!(tags, current_scheme::BIO1, new_scheme::BIO2)
    tag_scheme(tags, current_scheme) || error("Wrong Tagging scheme ")

    # If I: If prev not of same type then change to 'B'.
    # If O: Then same. Also change this to String if it is a char.
    # If B: Then same.
end

function tag_scheme!(tags, current_scheme::BIO1, new_scheme::BIOES)
    tag_scheme!(tag_scheme!(tags, BIO1(), BIO2()), BIO2(), BIOES())
end

function tag_scheme!(tags, current_scheme::BIO2, new_scheme::BIO1)
    # If I: If prev not of same type then change to 'B'.
    # If O: Then same. Also change this to String if it is a char.
    # If B: Then same.
end

function tag_scheme!(tags, current_scheme::BIO2, new_scheme::BIOES)
end

function tag_scheme!(tags, current_scheme::BIOES, new_scheme::BIO1)
    tag_scheme!(tag_scheme!(tags, BIOES(), BIO2()), BIO2(), BIO1())
end

function tag_scheme!(tags, current_scheme::BIOES, new_scheme::BIO2)
end
