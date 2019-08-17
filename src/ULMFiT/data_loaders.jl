"""
Default Data Loaders for ULMFiT training for Sentiment Analysis
 - WikiText-103 corpus is to pre-train the Language model
 - IMDB movie review dataset - unsup data is used for fine-tuning Language Mode for Sentiment Analysis
 - IMDB movie review dataset - labelled data is used for training classifier for Sentiment Analysis
"""
# using CorpusLoaders
using Random

# WikiText-103 corpus loader
cd(@__DIR__)
include("WikiText-103")

# this custom preprocessing is based on the observation on the IMDB dataset
# these preprocessings will significantly reduce the "_unk_" (UNKNOWN) tokens in the corpus
function imdb_preprocess(text::AbstractString)
    ## Edit here if any preprocessing step is needed ##
    function put(en, symbol)
        l = length(en)
        (l == 1) && return en
        for i=1:l-1
            insert!(en, i*2, string(symbol))
        end
        return en
    end
    function split_word(word, symbol)
        length(word) == 1 && return [word]
        return split(word, symbol)
    end
    text = collect(text)
    deleteat!(text, findall(x -> !isvalid(x), text))
    text = join(text)
    text = replace(text, "<br /><br />" => '\n')
    text = replace(text, "<br />" => '\n')
    tokens = intern.(lowercase.(tokenize(text)))
    for symbol in [',', '.', '-', '/', "'s"]
        tokens = split_word.(tokens, symbol)
        temp = []
        for token in tokens
            try
                append!(temp, put(token, symbol))
            catch
                append!(temp, token)
            end
        end
        tokens = temp
    end
    deleteat!(tokens, findall(x -> isequal(x, "")||isequal(x, " "), tokens))
    return tokens
end

# Loads WikiText-103 corpus and output a Channel to give a mini-batch at each call
function load_wikitext_103(batchsize::Integer, bptt::Integer)
    corpuspath = joinpath(datadep"WikiText-103", "wiki.valid.tokens")
    corpus = read(open(corpuspath, "r"), String)
    corpus = intern.(tokenize(corpus))
    return Channel(x -> generator(x, corpus; batchsize = batchsize, bptt = bptt));
end

# IMDB Data loaders for Sentiment Analysis specifically
# IMDB data loader for fine-tuning Language Model
function imdb_fine_tune_data(batchsize::Integer, bptt::Integer, num_examples::Integer=50000)
    imdb_dataset = IMDB("train_unsup")
    dataset = []
    for path in imdb_dataset.filepaths   #extract data from the files in directory and put into channel
        open(path) do fileio
            cur_text = read(fileio, String)
            append!(dataset, imdb_preprocess(cur_text))
        end #open
    end #for
    return Channel(x -> generator(x, dataset; batchsize=batchsize, bptt=bptt))
end

# IMDB data loader for training classifier
function imdb_classifier_data(batchsize::Integer)
    filepaths = IMDB("train_neg").filepaths
    append!(filepaths, IMDB("train_pos").filepaths)
    [shuffle!(filepaths) for _=1:10]
    Channel(csize=1) do docs
        n_batches = Int(floor(length(filepaths)/batchsize))
        put!(docs, n_batches)
        for i=1:n_batches
            X, Y = [], []
            for j=1:batchsize
                path = filepaths[(i-1)*batchsize+j]
                open(path) do fileio
                    cur_text = read(fileio, String)
                    tokens = imdb_preprocess(cur_text)
                    push!(X, tokens)
                    push!(Y, Float32((parse(Int32, split(path, '_')[2][1:end-4]))/10))
                end #open
            end#for
            X = pre_pad_sequences(X, "_pad_")
            put!(docs, [Flux.batch(X[k][j] for k=1:batchsize) for j=1:length(X[1])])
            put!(docs, Y[:, :])
        end #for
    end #channel
end
