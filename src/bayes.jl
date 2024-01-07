using WordTokenizers

export NaiveBayesClassifier

simpleTokenise(s) = WordTokenizers.tokenize(lowercase(replace(s, "."=>"")))

"""
$(TYPEDSIGNATURES)

Create a dict that maps elements in input array to their frequencies.
"""
function frequencies(xs::AbstractVector{T})::Dict{T,Int} where {T<:Any}
    frequencies = Dict{eltype(xs),Int}()
    for x in xs
        frequencies[x] = get(frequencies, x, 0) + 1
    end
    return frequencies
end

"""
$(TYPEDSIGNATURES)

Compute an Array, mapping the value corresponding to elements of `dict` to the input `AbstractDict`.
"""
function features(fs::AbstractDict, dict::AbstractVector)::Vector{Int}
    bag = Vector{Int}(undef, size(dict))
    for i = eachindex(dict)
        bag[i] = get(fs, dict[i], 0)
    end
    return bag
end

features(s::AbstractString, dict) = features(frequencies(simpleTokenise(s)), dict)

Features{T<:Integer} = AbstractVector{T}

mutable struct NaiveBayesClassifier{T}
    dict::Vector{String}
    classes::Vector{T}
    weights::Matrix{Int}
end

"""
    NaiveBayesClassifier([dict, ]classes)

A Naive Bayes Classifier for classifying documents.

It takes two arguments:
* `classes`: An array of possible classes that the concerned data could belong to.
* `dict`:(Optional Argument) An Array of possible tokens (words). This is automatically updated if a new token is detected in the Step 2) or 3)

# Example
```julia-repl
julia> using TextAnalysis: NaiveBayesClassifier, fit!, predict

julia> m = NaiveBayesClassifier([:spam, :non_spam])
NaiveBayesClassifier{Symbol}(String[], [:spam, :non_spam], Matrix{Int64}(undef, 0, 2))

julia> fit!(m, "this is spam", :spam)
NaiveBayesClassifier{Symbol}(["this", "is", "spam"], [:spam, :non_spam], [2 1; 2 1; 2 1])

julia> fit!(m, "this is not spam", :non_spam)
NaiveBayesClassifier{Symbol}(["this", "is", "spam", "not"], [:spam, :non_spam], [2 2; 2 2; 2 2; 1 2])

julia> predict(m, "is this a spam")
Dict{Symbol, Float64} with 2 entries:
  :spam     => 0.59883
  :non_spam => 0.40117
```
"""
NaiveBayesClassifier(dict, classes) =
    NaiveBayesClassifier(dict, classes,
             ones(Int, length(dict), length(classes)))

NaiveBayesClassifier(classes) = NaiveBayesClassifier(String[], classes)

probabilities(c::NaiveBayesClassifier) = c.weights ./ sum(c.weights, dims = 1)

"""
    extend!(model::NaiveBayesClassifier, dictElement)

Add the dictElement to dictionary of the Classifier `model`.
"""
function extend!(c::NaiveBayesClassifier, dictElement)
    push!(c.dict, dictElement)
    c.weights = vcat(c.weights, ones(Int, length(c.classes))')
    return c
end

"""
    fit!(model::NaiveBayesClassifier, str, class)
    fit!(model::NaiveBayesClassifier, ::Features, class)
    fit!(model::NaiveBayesClassifier, ::StringDocument, class)

Fit the weights for the model on the input data.
"""
function fit!(c::NaiveBayesClassifier, x::Features, class)
    n = findfirst(==(class), c.classes)
    c.weights[:, n] .+= x
    return c
end

function fit!(c::NaiveBayesClassifier, sd::AbstractDocument, class)
    fs = frequencies(tokens(sd))
    for k in keys(fs)
        k in c.dict || extend!(c, k)
    end
    fit!(c, features(fs, c.dict), class)
end

fit!(c::NaiveBayesClassifier, s::String, class) = fit!(c, StringDocument(s), class)

"""
    predict(::NaiveBayesClassifier, str)
    predict(::NaiveBayesClassifier, ::Features)
    predict(::NaiveBayesClassifier, ::StringDocument)

Predict probabilities for each class on the input Features or String.
"""
function predict(c::NaiveBayesClassifier, x::Features)
    ps = prod(probabilities(c) .^ x, dims = 1)
    ps ./= sum(ps)
    Dict(c.classes[i] => ps[i] for i = 1:length(c.classes))
end

predict(c::NaiveBayesClassifier, s::String) =
    predict(c, features(s, c.dict))

predict(c::NaiveBayesClassifier, sd::AbstractDocument) = predict(c, features(frequencies(tokens(sd)), c.dict))
