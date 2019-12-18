using BSON, Tracker

const NER_Char_UNK = '¿'
const NER_Word_UNK = "<UNK>"

struct NERmodel{M}
    model::M
end

load_model_dicts(filepath) = load_model_dicts(filepath, true)

function load_model_dicts(filepath, remove_tag_prefix)
    labels = BSON.load(joinpath(filepath, "labels.bson"))[:labels]
    chars_idx = BSON.load(joinpath(filepath, "char_to_embed_idx.bson"))[:get_char_index]
    words_idx = BSON.load(joinpath(filepath, "word_to_embed_idx.bson"))[:get_word_index]

    remove_tag_prefix || return [labels...], chars_idx, words_idx

    return remove_ner_label_prefix.([labels...]), chars_idx, words_idx
end

NERTagger() = NERTagger(datadep"NER Model Dicts", datadep"NER Model Weights")

function NERTagger(dicts_path, weights_path)
    labels, chars_idx, words_idx = load_model_dicts(dicts_path)
    model = BiLSTM_CNN_CRF_Model(labels, chars_idx, words_idx, chars_idx[NER_Char_UNK], words_idx[NER_Word_UNK], weights_path)
    NERmodel(model)
end

function (a::NERmodel)(tokens::Array{String,1})
    input_oh = [onehotinput(a.model, token) for token in tokens]
    return (a.model)(input_oh)
end

function (a::NERmodel)(sentence::AbstractString)
    a(WordTokenizers.tokenize(sentence))
end

function (a::NERmodel)(doc::AbstractDocument)
    return vcat(a.(WordTokenizers.split_sentences(text(doc))))
end

function (a::NERmodel)(ngd::NGramDocument)
    throw("Sequence Labelling not possible for NGramsDocument")
end

function (a::NERmodel)(crps::Corpus)
    return a.(crps.documents)
end

function remove_ner_label_prefix(str)
    str == "O" && return str
    str = str[3:end]
end
