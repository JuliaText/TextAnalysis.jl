using BSON, Tracker

const POS_Char_UNK = '¿'
const POS_Word_UNK = "<UNK>"

struct PoSModel{M}
    model::M
end

POS_Tagger() = POS_Tagger(datadep"POS Model Dicts", datadep"POS Model Weights")

function POS_Tagger(dicts_path, weights_path)
    labels, chars_idx, words_idx = load_model_dicts(dicts_path, false)
    model = BiLSTM_CNN_CRF_Model(labels, chars_idx, words_idx, chars_idx[POS_Char_UNK], words_idx[POS_Word_UNK], weights_path)
    PoSModel(model)
end

function (a::PoSModel)(tokens::Array{String,1})
    input_oh = [onehotinput(a.model, token) for token in tokens]
    return (a.model)(input_oh)
end

function (a::PoSModel)(sentence::AbstractString)
    a(WordTokenizers.tokenize(sentence))
end

function (a::PoSModel)(doc::AbstractDocument)
    return vcat(a.(WordTokenizers.split_sentences(text(doc))))
end

function (a::PoSModel)(ngd::NGramDocument)
    throw("Sequence Labelling not possible for NGramsDocument")
end

function (a::PoSModel)(crps::Corpus)
    return a.(crps.documents)
end
