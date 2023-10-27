# Classifier

Text Analysis currently offers a Naive Bayes Classifier for text classification.

To load the Naive Bayes Classifier, use the following command -

    using TextAnalysis: NaiveBayesClassifier, fit!, predict

## Basic Usage

Its usage can be done in the following 3 steps.

1- Create an instance of the Naive Bayes Classifier model -
```@docs
NaiveBayesClassifier
```

2- Fitting the model weights on input -
```@docs
fit!
```
3- Predicting for the input case -
```@docs
predict
```

## Example

```@repl
using TextAnalysis
m = NaiveBayesClassifier([:legal, :financial])
fit!(m, "this is financial doc", :financial)
fit!(m, "this is legal doc", :legal)
predict(m, "this should be predicted as a legal document")
```
