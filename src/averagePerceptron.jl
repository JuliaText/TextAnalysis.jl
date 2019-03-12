"""
This module contains the Average Perceptron model
which was original implemented by Matthew Honnibal.

The model learns by basic perceptron algorithm
but after all iterations weights are being averaged
"""
module AveragePerceptron
    using DelimitedFiles
    using DataStructures

    mutable struct initModel
            classes
            weights
            _totals
            _tstamps
            i
            START
        end

    self = initModel(OrderedSet(), Dict(), DefaultDict(0), DefaultDict(0), 1, ["-START-", "-START2-"])

    function predict(features)
        """Predicting the class using current weights by doing Dot-product of features
        and weights and return the scores"""
        global self
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

    function update(truth, guess, features)
        """Applying the perceptron learning algorithm
        Increment the truth weights and decrementing the guess weights
        if the guess is wrong"""
        global self
        function upd_feat(c, f, w, v)
            global self
            param = (f, c)
            n_iters_at_this_weight = self.i - self._tstamps[param]
            self._totals[param] += n_iters_at_this_weight*w
            self.weights[f][c] = w + v
            self._tstamps[param] = self.i
        end

        self.i += 1
        if truth == guess
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

    function average_weights()
        """Averaging the weights over all time stamps"""
        global self
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
end
