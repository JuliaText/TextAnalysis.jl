## Preface

This manual is designed to get you started doing text analysis in Julia.
It assumes that you already familiar with the basic methods of text analysis.

## Installation

The TextAnalysis package can be installed using Julia's package manager:

    Pkg.add("TextAnalysis")

## Loading

In all of the examples that follow, we'll assume that you have the
TextAnalysis package fully loaded. This means that we think you've
implicitly typed

    using TextAnalysis

before every snippet of code.

## TextModels

The [TextModels](https://github.com/JuliaText/TextModels.jl) package enhances this library with the addition of practical neural network based models. Some of that code used to live in this package, but was moved to simplify installation and dependencies. 

