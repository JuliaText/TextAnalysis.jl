"""
    stemmer_for_document(doc)

Search for an appropriate stemmer based on the language of the document.
"""
function stemmer_for_document(d::AbstractDocument)
    Stemmer(lowercase(Languages.english_name(language(d))))
end

"""
    stem!(doc)
    stem!(crps)

Stems the document or documents in `crps` with a suitable stemmer.

Stemming cannot be done for `FileDocument` and Corpus made of these type of documents.
"""
function stem!(d::AbstractDocument)
    stemmer = stemmer_for_document(d)
    stem!(stemmer, d)
    Snowball.release(stemmer)
end

stem!(stemmer::Stemmer, d::FileDocument) = error("FileDocument cannot be modified")

function stem!(stemmer::Stemmer, d::StringDocument)
    d.text = stem_all(stemmer, d.text)
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
            count = get(d.ngrams, new_token, 0)
            d.ngrams[new_token] = count + d.ngrams[token]
            delete!(d.ngrams, token)
        end
    end
end

"""
    stem!(crps::Corpus)

Stem an entire corpus. Assumes all documents in the corpus have the same language (picked from the first)
"""
function stem!(crps::Corpus)
    stemmer = stemmer_for_document(crps.documents[1])
    for doc in crps
        stem!(stemmer, doc)
    end
    Snowball.release(stemmer)
end
