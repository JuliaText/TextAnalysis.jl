using DataStructures
using Random
using BSON
using DataDeps

export fit!, predict

register(DataDep("POS Perceptron Tagger Weights",
    """
    The trained weights for the average Perceptron Tagger on Part of Speech Tagging task.
    """,
    "https://github.com/JuliaText/TextAnalysis.jl/raw/2467ae2f379490af9ba1b181ce25f1a415a4be4d/src/pretrainedMod.bson",
    "3305c8ee73d9de6d653d6a6e4eaf83dc5031114aaebe621b1625f11d7810a5f4",
    post_fetch_method = function(fn)
        file = readdir(".")[1]
        println(readdir("."))
        mv(file, "POSWeights.bson")
    end
))

"""
This file contains the Average Perceptron model and Perceptron Tagger
which was original implemented by Matthew Honnibal.

The model learns by basic perceptron algorithm
but after all iterations weights are being averaged

AVERAGE PERCEPTRON MODEL

This struct contains the actual Average Perceptron Model
"""
mutable struct AveragePerceptron
    classes :: Set
    weights :: Dict
    _totals :: DefaultDict
    _tstamps :: DefaultDict
    i :: Int64
    START :: Array

    function AveragePerceptron()
        new(Set(), Dict(), DefaultDict(0), DefaultDict(0), 1, ["-START-", "-START2-"])
    end
end

"""
Predicting the class using current weights by doing Dot-product of features
and weights and return the scores
"""
function predict(self::AveragePerceptron, features)
    scores = DefaultDict(0.0)
    for (feature, value) in features
        if feature ∉ keys(self.weights)
            continue
        end
        weights = self.weights[feature]
        for (label, weight) in weights
            scores[label] += value * weight
        end
    end
    function custmax(scores)
        a = [scores[class] for class in self.classes]
        zipped = collect(zip(a, self.classes))
        currmax = zipped[1]
        for i=2:(length(zipped))
            currmax = max(currmax, zipped[i])
        end
        return currmax[2]
    end
    return custmax(scores)
end

"""
Applying the perceptron learning algorithm
Increment the truth weights and decrementing the guess weights,
if the guess is wrong
"""
function update(self::AveragePerceptron, truth, guess, features)
    function upd_feat(c, f, w, v)
        param = (f, c)
        n_iters_at_this_weight = self.i - self._tstamps[param]
        self._totals[param] += n_iters_at_this_weight * w
        self.weights[f][c] = w + v
        self._tstamps[param] = self.i
    end

    self.i += 1
    if truth === guess
        return nothing
    end
    for (f, value) in features
        if f in keys(self.weights)
            weights = self.weights[f]
        else
            self.weights[f] = Dict()
            weights = Dict()
        end
        upd_feat(truth, f, get(weights, truth, 0.0), 1.0)
        upd_feat(guess, f, get(weights, guess, 0.0), -1.0)
    end
    return nothing
end

"""
Averaging the weights over all time stamps
"""
function average_weights(self::AveragePerceptron)
    function newRound(fl, in)
        temp = fl*(10^in)
        return (float(round(temp))/(10^in))
    end
    for (feature , weights) in self.weights
        new_feat_weights = Dict()
        for (clas, weight) in weights
            param = (feature, clas)
            total = self._totals[param]
            total += (self.i - self._tstamps[param])*weight
            averaged = newRound(total/float(self.i-1), 3)
            if averaged != nothing
                new_feat_weights[clas] = averaged
            end
        self.weights[feature] = new_feat_weights
        end
    end
    return nothing
end

"""
# PERCEPTRON TAGGER

This struct contains the POS tagger "PerceptronTagger" which uses model in "AveragePerceptron"
In this training can be done and weights can be saved
Or a pretrain weights can be used (which are trained on same features)
and train more or can be used to predict

## To train:

```julia
julia> tagger = PerceptronTagger(false)

julia> fit!(tagger, [[("today","NN"),("is","VBZ"),("good","JJ"),("day","NN")]])
```

## To load pretrain model:

```julia
julia> tagger = PerceptronTagger(true)
```

## To predict tag:

```julia
julia> predict(tagger, ["today", "is"])
```
"""
mutable struct PerceptronTagger
    model :: AveragePerceptron
    tagdict :: Dict
    classes :: Set
    START :: Array
    END :: Array
    _sentences

        PerceptronTagger() = new(AveragePerceptron(), Dict(), Set(), ["-START-", "-START2-"], ["-END-", "-END2-"], [])
end

function PerceptronTagger(load::Bool)
    self = PerceptronTagger()

    # If load is true then a pretrain model will be import from location
    if load
        location = joinpath(datadep"POS Perceptron Tagger Weights", "POSWeights.bson")
        pretrained = BSON.load(location)
        self.model.weights = pretrained[:weights]
        self.tagdict = pretrained[:tagdict]
        self.classes = self.model.classes = Set(pretrained[:classes])
        println("loaded successfully")
    end

    return self
end

"""
makes a dictionary for single-tag words
params : sentences - an array of tuples which contains word and correspinding tag
"""
function makeTagDict(self::PerceptronTagger, sentences)
    counts = DefaultDict(()->DefaultDict(0))
    for sentence in sentences
        append!(self._sentences, sentences)
        for (word, tag) in sentence
            counts[word][tag] += 1
            push!(self.classes, tag)
        end
    end
    freq_thresh = 20
    ambiguity_thresh = 0.97
    for (word, tag_freqs) in counts
        mode, tag = findmax(collect(values(tag_freqs))); tag = collect(keys(tag_freqs))[tag]
        n = sum(values(tag_freqs))
        if (n >= freq_thresh) && ((mode/n) >= ambiguity_thresh)
            self.tagdict[word] = tag
        end
    end
end

"""
This function is used to normalize the given word
params : word - String
"""
function normalize(word)
    word = string(word)
    if occursin("-", word) && (word[1] != "-")
        return "!HYPHEN"
    elseif occursin(r"^[\d]{4}$", word)
        return "!YEAR"
    elseif occursin(r"^[\d]$", string(word[1]))
        return "!DIGITS"
    else
        return lowercase(word)
    end
end

"""
Converting the token into a feature representation, implemented as Dict
If the features change, a new model should be trained

# Arguments:

- `i` - index of word(or token) in sentence
- `word` - token
- `context` - array of tokens with starting and ending specifiers
- `prev` == "-START-" prev2 == "-START2-" - Start specifiers
"""
function getFeatures(self::PerceptronTagger, i, word, context, prev, prev2)
    function add(sep, name, args...)
        str = name
        for arg in args
            str *= sep * arg
        end
        if str in keys(features)
            features[str] += 1
        else
            features[str] = 1
        end
        return nothing
    end
    i += length(self.START)
    features = OrderedDict()
    add(" ", "bias")
    if length(word) >= 3
        add(" ", "i suffix", word[end-2:end])
    else
        add(" ", "i suffix", word)
    end
    add(" ", "i pref1", word[1])
    add(" ", "i-1 tag", prev)
    add(" ", "i-2 tag", prev2)
    add(" ", "i tag+i-2 tag", prev, prev2)
    add(" ", "i word", context[i])
    add(" ", "i-1 tag+i word", prev, context[i])
    add(" ", "i-1 word", context[i-1])
    if length(context[i-1]) >= 3
        add(" ", "i-1 suffix", context[i-1][end-2:end])
    else
        add(" ", "i-1 suffix", context[i-1])
    end
    add(" ", "i-2 word", context[i-2])
    add(" ", "i+1 word", context[i+1])
    if length(context[i+1]) >= 3
        add(" ", "i+1 suffix", context[i+1][end-2:end])
    else
        add(" ", "i+1 suffix", context[i+1])
    end
    add(" ", "i+2 word", context[i+2])
    return features
end

"""
    predict(::PerceptronTagger, tokens)
    predict(::PerceptronTagger, sentence)

Used for predicting the tags for given sentence or array of tokens
"""
function predict(self::PerceptronTagger, tokens::Vector{String})
    prev, prev2 = self.START
    output = []

    context = vcat(self.START, [normalize(word) for word in tokens], self.END)
    for (i, word) in enumerate(tokens)
        tag = get(self.tagdict, word, nothing)
        if tag === nothing
            features = getFeatures(self, i, word, context, prev, prev2)
            tag = predict(self.model, features)
        end
        push!(output, (word, tag))
        prev2 = prev
        prev = tag
    end
    return output
end

function (tagger::PerceptronTagger)(input)
    predict(tagger, input)
end

predict(tagger::PerceptronTagger, sentence::String) =
        predict(tagger, tokenize(Languages.English(), sentence))
predict(tagger::PerceptronTagger, sd::StringDocument) =
        predict(tagger, text(sd))
predict(tagger::PerceptronTagger, fd::FileDocument) =
        predict(tagger, text(fd))
predict(tagger::PerceptronTagger, td::TokenDocument) =
        predict(tagger, tokens(td))
function predict(tagger::PerceptronTagger, ngd::NGramDocument)
    @warn "POS tagging for NGramDocument not available."
end



"""
    fit!(::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, save_loc::String, nr_iter::Integer)

Used for training a new model or can be used for training
an existing model by using pretrained weigths and classes

Contains main training loop for number of epochs.
After training weights, tagdict and classes are stored in the specified location.

# Arguments:
- `::PerceptronTagger` : Input PerceptronTagger model
- `sentences::Vector{Vector{Tuple{String, String}}}` : Array of the all token seqeunces with target POS tag
- `save_loc::String` : To specify the saving location
- `nr_iter::Integer` : Total number of training iterations for given sentences(or number of epochs)
"""
function fit!(self::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, save_loc::String, nr_iter::Integer)
    self._sentences = []
    makeTagDict(self, sentences)
    self.model.classes = self.classes
    for iter=1:nr_iter
        c = 0; n = 0;
        for sentence in self._sentences
            words, tags = [x[1] for x in sentence], [x[2] for x in sentence]
            prev, prev2 = self.START
            context = vcat(self.START, [normalize(w) for w in words], self.END)
            for (i, word) in enumerate(words)
                guess = get(self.tagdict, word, nothing)
                if guess == nothing
                    feats = getFeatures(self, i, word, context, prev, prev2)
                    guess = predict(self.model, feats)
                    update(self.model, tags[i], guess, feats)
                end
                prev2 = prev
                prev = guess
                c += (guess == tags[i])
                n += 1
            end
        end
        shuffle(self._sentences)
        println("iteration : $iter")
    end
    self._sentences = nothing
    average_weights(self.model)

    if save_loc != ""
        bson(save_loc, weights = self.model.weights, tagdict = self.tagdict, classes = collect(self.classes))
    end
end

fit!(self::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, nr_iter::Integer) = fit!(self::PerceptronTagger, sentences, "", nr_iter)
fit!(self::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}, save_loc::String) = fit!(self::PerceptronTagger, sentences, save_loc, 5)
fit!(self::PerceptronTagger, sentences::Vector{Vector{Tuple{String, String}}}) = fit!(self::PerceptronTagger, sentences, "", 5)
