# Classifier

Text Analysis currently offers a Naive Bayes Classifier for text classification.

To load the Naive Bayes Classifier, use the following command -

    using TextAnalysis: NaiveBayesClassifier, fit!, predict

## Basic Usage

Its usage can be done in the following 3 steps.

1- Create an instance of the Naive Bayes Classifier model -

    model = NaiveBayesClassifier(dict, classes)


It takes two arguments-

* `classes`: An array of possible classes that the concerned data could belong to.
* `dict`:(Optional Argument) An Array of possible tokens (words). This is automatically updated if a new token is detected in the Step 2) or 3)


2- Fitting the model weights on input -

    fit!(model, str, class)

3- Predicting for the input case -

    predict(model, str)

## Example

```julia
julia> m = NaiveBayesClassifier([:legal, :financial])
NaiveBayesClassifier{Symbol}(String[], Symbol[:legal, :financial], Array{Int64}(0,2))
```

```julia
julia> fit!(m, "this is financial doc", :financial)
NaiveBayesClassifier{Symbol}(["financial", "this", "is", "doc"], Symbol[:legal, :financial], [1 2; 1 2; 1 2; 1 2])

julia> fit!(m, "this is legal doc", :legal)
NaiveBayesClassifier{Symbol}(["financial", "this", "is", "doc", "legal"], Symbol[:legal, :financial], [1 2; 2 2; … ; 2 2; 2 1])
```

```julia
julia> predict(m, "this should be predicted as a legal document")
Dict{Symbol,Float64} with 2 entries:
  :legal     => 0.666667
  :financial => 0.333333
```
