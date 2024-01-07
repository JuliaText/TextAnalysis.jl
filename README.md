# TextAnalysis

A Julia package for working with text.

[![CI](https://github.com/juliatext/TextAnalysis.jl/workflows/CI/badge.svg?event=push&branch=master)](https://github.com/JuliaText/TextAnalysis.jl/actions?query=workflow%3ACI)
[![version](https://juliahub.com/docs/TextAnalysis/version.svg)](https://juliahub.com/ui/Packages/General/TextAnalysis/)
[![docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.juliahub.com/TextAnalysis/) 

## Introduction

TextAnalysis provides support for standard tools and models for working with textual data and natural languages in the Julia language. 

- **Documentation** :  [Documentation for stable released version](https://docs.juliahub.com/TextAnalysis)
- **License** : [MIT License](https://github.com/JuliaText/TextAnalysis.jl/blob/master/LICENSE.md)

## Features

* Container type for *Document* and *Corpus*
* DocumentTermMatrix and TF/IDF
* LSA/LDA
* Vocabulary and statistical Language Model
* Co-occurrence matrix
* NaiveBayes classifier
* ROUGE evaluation metrics

This package also incorporates features from the [Languages](https://juliahub.com/ui/Packages/Languages/w1H1r) and [WordTokenizers](https://juliahub.com/ui/Packages/WordTokenizers/wKkKC) packages within the [JuliaText](https://github.com/JuliaText) ecosystem. 

## TextModels

The [TextModels](https://github.com/JuliaText/TextModels.jl) package enhances this library with the addition of practical neural network based models. Some of that code used to live in this package, but was moved to simplify installation and reduce the number of dependencies. 

## Installation

```julia
pkg> add TextAnalysis
```

## Contributing and Reporting Bugs

Contributions, in the form of bug-reports, pull requests, additional documentation are encouraged. They can be made to the Github repository.

**All contributions and communications should abide by the [Julia Community Standards](https://julialang.org/community/standards/).**

## Support

Feel free to ask for help on the [Julia Discourse forum](https://discourse.julialang.org/), or in the `#natural-language` channel on [julia-slack](https://julialang.slack.com). (Which you can [join here](https://julialang.org/slack/)). Or, [select what do you like here](https://julialang.org/community/). You can also raise issues in this repository to request new features and/or improvements to the documentation and codebase.

