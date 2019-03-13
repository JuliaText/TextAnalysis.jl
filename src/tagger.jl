"""
This contains the module "PerceptronTagger" which is uses model in AveragePerceptron
In this training can be done and weights can be saved
Or a pretrain weights can be used (which are trained on same features)
and train more or can be used to predict

DataStructures and Random are essential dependencies
BSON is needed when weights are to be saved

To train:
PerceptronTagger.train([[("today","NN"),("is","VBZ"),("good","JJ"),("day","NN")]])

To predict tag:
PerceptronTagger.test(["today", "is"])
"""

module PerceptronTagger()
    using DataStructures
    using BSON
    using Random

    include("averagePerceptron.jl")
    import .AveragePerceptron

    mutable struct init
        tagdict
        classes
        START
        END
        _sentences
    end

    # println("type "true" to load already trained weights :")
    self = init(Dict(), OrderedSet(), ["-START-", "-START2-"], ["-END-", "-END2-"], [])
    #
    # function loadModel(location)
    #     global self
    #     print(load)
    #     AveragePerceptron.self.weights = BSON.load(location)[:weights]
    #     self.tagdict = load(location)[:tagdict]
    #     self.classes = AveragePerceptron.self.classes = load(location)[:classes]
    # end
    #
    # if (loadm == "true" ? true : false)
    #     print("ok")
    #     loadModel("model.jld")
    # end

    function normalize(word)
        """This function is used to normalize the given word
        params : word - String"""
        global self
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

    function makeTagDict(sentences)
        """makes a dictionary for single-tag words
        params : sentences - an array of tuples which contains word and correspinding tag"""
        global self
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

    function getFeatures(i, word, context, prev, prev2)
        """Converting the token into a feature representation, implemented as Dict
        If the features change, a new model should be trained
        params:
        i - index of word(or token) in sentence
        word - token
        context - array of tokens with starting and ending specifiers
        prev == "-START-" prev2 == "-START2-" - Start specifiers"""
        global self
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

    function tag(tokens)
        """Used for predicting the tags for given tokens
        tokens - array of tokens"""
        global self
        prev, prev2 = self.START
        output = []

        context = vcat(self.START, [normalize(word) for word in tokens], self.END)
        for (i, word) in enumerate(tokens)
            tag = get(self.tagdict, word, nothing)
            if tag == nothing
                features = getFeatures(i, word, context, prev, prev2)
                tag = AveragePerceptron.predict(features)
            end
            push!(output, (word, tag))
            prev2 = prev
            prev = tag
        end
        println(output)
        return output
    end

    function train(sentences, save_loc=nothing, nr_iter=5)
        """Used for training a new model or can be used for training
        an existing model by using pretrained weigths and classes

        Contains main training loop for number of epochs.
        After training weights, tagdict and classes are stored in the specified location.

        params:
        sentences - array of the all sentences
        save_loc - to specify the saving location
        nr_iter - total number of training iterations for given sentences(or number of epochs)"""

        global self
        self._sentences = []
        makeTagDict(sentences)
        AveragePerceptron.self.classes = self.classes
        for iter=1:nr_iter
            c = 0; n = 0;
            for sentence in self._sentences
                words, tags = [x[1] for x in sentence], [x[2] for x in sentence]
                prev, prev2 = self.START
                context = vcat(self.START, [normalize(w) for w in words], self.END)
                for (i, word) in enumerate(words)
                    guess = get(self.tagdict, word, nothing)
                    if guess == nothing
                        feats = getFeatures(i, word, context, prev, prev2)
                        guess = AveragePerceptron.predict(feats)
                        AveragePerceptron.update(tags[i], guess, feats)
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
        AveragePerceptron.average_weights()

        if save_loc != nothing
            save(save_loc, weights = AveragePerceptron.self.weights, tagdict = self.tagdict, classes = self.classes)
        end
    end
end

# using DataFrames


##Getting data
# for i=1:size(en_train, 1)
#        global sentence, sentences,j,numSent, nonarray
#        if i ∈ nonarray continue end
#        if pos_tags[j, 1] === numSent
#        push!(sentence, (en_train[i, :after], pos_tags[j, :pos]))
#        elseif numSent != pos_tags[j ,1]
#        push!(sentences, sentence)
#        sentence = []
#        numSent = pos_tags[j, 1]
#        end
#        j += 1
#        end
# [[("progressive", "VB"),("rock", "VBN"),(",", "IN"),("art", "PRP\$"),("rock", "NNP"),(",", "NNP"),("pop", "NNS"),("musicians", "IN"),(".", "NNP"),
# ("Circa", "CC"),("Survive", "NNP"),("opened", "CC"),("for", "NNP"),("My", "NNP"),("Chemical", "VBZ"),("Romance's", "RB"),("two thousand seven", "RB")]]
