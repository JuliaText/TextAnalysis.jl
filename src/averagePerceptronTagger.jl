using DataStructures
using Random
using BSON

"""AVERAGE PERCEPTRON MODEL"""

"""
This module contains the Average Perceptron model
which was original implemented by Matthew Honnibal.

The model learns by basic perceptron algorithm
but after all iterations weights are being averaged
"""
mutable struct AveragePerceptron
    classes :: Set
    weights :: Dict
    _totals :: DefaultDict
    _tstamps :: DefaultDict
    i :: Int64
    START :: Array

    predict :: Function
    update :: Function
    average_weights :: Function

    function AveragePerceptron()
        self = new()

        self.classes = Set()
        self.weights = Dict()
        self._totals = DefaultDict(0)
        self._tstamps = DefaultDict(0)
        self.i = 1
        self.START = ["-START-", "-START2-"]

        self.predict = function (features)
            """Predicting the class using current weights by doing Dot-product of features
            and weights and return the scores"""

            scores = DefaultDict(0.0)
            for (feature, value) in features
                if feature ∉ keys(self.weights)
                    continue
                end
                weights = self.weights[feature]
                for (label, weight) in weights
                    scores[label] += value*weight
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
        self.update = function (truth, guess, features)
            """Applying the perceptron learning algorithm
            Increment the truth weights and decrementing the guess weights
            if the guess is wrong"""

            function upd_feat(c, f, w, v)
                param = (f, c)
                n_iters_at_this_weight = self.i - self._tstamps[param]
                self._totals[param] += n_iters_at_this_weight*w
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
        self.average_weights = function ()
            """Averaging the weights over all time stamps"""

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
        return self
    end
end

"""PERCEPTRON TAGGER"""

"""
This struct contains the actual "PerceptronTagger" which uses model in "AveragePerceptron"
In this training can be done and weights can be saved
Or a pretrain weights can be used (which are trained on same features)
and train more or can be used to predict

To train:
tagger = PerceptronTagger()
tagger.train([[("today","NN"),("is","VBZ"),("good","JJ"),("day","NN")]])

To predict tag:
tagger.tag(["today", "is"])

To load pretrained model:
tagger = PerceptronTagger(true)
"""
mutable struct PerceptronTagger
    model :: AveragePerceptron
    tagdict :: Dict
    classes :: Set
    START :: Array
    END :: Array
    _sentences

    train :: Function
    tag :: Function
    makeTagDict :: Function
    normalize :: Function
    getFeatures :: Function

    function PerceptronTagger(load = false)
        self = new()

        self.model = AveragePerceptron()
        self.tagdict = Dict()
        self.classes = Set()
        self.START = ["-START-", "-START2-"]
        self.END = ["-END-", "-END2-"]
        self._sentences = []

        self.makeTagDict = function (sentences)
            """makes a dictionary for single-tag words
            params : sentences - an array of tuples which contains word and correspinding tag"""

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

        self.normalize = function (word)
            """This function is used to normalize the given word
            params : word - String"""

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

        self.getFeatures = function (i, word, context, prev, prev2)
            """Converting the token into a feature representation, implemented as Dict
            If the features change, a new model should be trained
            params:
            i - index of word(or token) in sentence
            word - token
            context - array of tokens with starting and ending specifiers
            prev == "-START-" prev2 == "-START2-" - Start specifiers"""

            function add(sep, name, args...)
                str = name
                for arg in args
                    str *= sep*arg
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

        self.tag = function (tokens)
            """Used for predicting the tags for given tokens
            tokens - array of tokens"""

            prev, prev2 = self.START
            output = []

            context = vcat(self.START, [self.normalize(word) for word in tokens], self.END)
            for (i, word) in enumerate(tokens)
                tag = get(self.tagdict, word, nothing)
                if tag == nothing
                    features = self.getFeatures(i, word, context, prev, prev2)
                    tag = self.model.predict(features)
                end
                push!(output, (word, tag))
                prev2 = prev
                prev = tag
            end
            return output
        end

        self.train = function (sentences, save_loc=nothing, nr_iter=5)
            """Used for training a new model or can be used for training
            an existing model by using pretrained weigths and classes

            Contains main training loop for number of epochs.
            After training weights, tagdict and classes are stored in the specified location.

            params:
            sentences - array of the all sentences
            save_loc - to specify the saving location
            nr_iter - total number of training iterations for given sentences(or number of epochs)"""

            self._sentences = []
            self.makeTagDict(sentences)
            self.model.classes = self.classes
            for iter=1:nr_iter
                c = 0; n = 0;
                for sentence in self._sentences
                    words, tags = [x[1] for x in sentence], [x[2] for x in sentence]
                    prev, prev2 = self.START
                    context = vcat(self.START, [self.normalize(w) for w in words], self.END)
                    for (i, word) in enumerate(words)
                        guess = get(self.tagdict, word, nothing)
                        if guess == nothing
                            feats = self.getFeatures(i, word, context, prev, prev2)
                            guess = self.model.predict(feats)
                            self.model.update(tags[i], guess, feats)
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
            self.model.average_weights()


            if save_loc != nothing
                bson(save_loc, weights = self.model.weigths, tagdict = self.tagdict, classes = self.classes)
            end
        end

        """If load is true then a pretrain model will be import from location"""
        if load
            println("Enter file location to load pretrain values:")
            location = readline()
            self.model.weights = BSON.load(location)[:weights]
            self.tagdict = load(location)[:tagdict]
            self.classes = self.model.classes = load(location)[:classes]
        end

        return self
    end
end
