#  Statistical Language Model 

**TextAnalysis** provide following different Language Models 

- **MLE** - Base Ngram model.
- **Lidstone** - Base Ngram model with Lidstone smoothing.
- **Laplace** - Base Ngram language model with Laplace smoothing.
- **WittenBellInterpolated** - Interpolated Version of witten-Bell algorithm.
- **KneserNeyInterpolated** - Interpolated  version of Kneser -Ney smoothing.

## APIs

To use the API, we first *Instantiate* desired model and then load it with train set

```julia
MLE(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
Lidstone(word::Vector{T}, gamma:: Float64, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
Laplace(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
WittenBellInterpolated(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
KneserNeyInterpolated(word::Vector{T}, discount:: Float64=0.1, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
(lm::<Languagemodel>)(text, min::Integer, max::Integer)
```
Arguments:

 * `word` : Array of  strings to store vocabulary.

 * `unk_cutoff`: Tokens with counts greater than or equal to the cutoff value will be considered part of the vocabulary.

 * `unk_label`: token for unknown labels 

 *  `gamma`: smoothing argument gamma 

 * `discount`:  discounting factor for `KneserNeyInterpolated`

   for more information see docstrings of vocabulary

```julia
julia> voc = ["my","name","is","salman","khan","and","he","is","shahrukh","Khan"]

julia> train = ["khan","is","my","good", "friend","and","He","is","my","brother"]
# voc and train are used to train vocabulary and model respectively

julia> model = MLE(voc)
MLE(Vocabulary(Dict("khan"=>1,"name"=>1,"<unk>"=>1,"salman"=>1,"is"=>2,"Khan"=>1,"my"=>1,"he"=>1,"shahrukh"=>1,"and"=>1…), 1, "<unk>", ["my", "name", "is", "salman", "khan", "and", "he", "is", "shahrukh", "Khan", "<unk>"]))

julia> print(voc)
11-element Array{String,1}:
 "my"
 "name"
 "is"
 "salman"
 "khan" 
 "and" 
 "he" 
 "is"
 "shahrukh"
 "Khan"
 "<unk>"

# you can see "<unk>" token is added to voc 
julia> fit = model(train,2,2) #considering only bigrams

julia> unmaskedscore = score(model, fit, "is" ,"<unk>") #score output P(word | context) without replacing context word with "<unk>"
0.3333333333333333

julia> masked_score = maskedscore(model,fit,"is","alien")
0.3333333333333333
#as expected maskedscore is equivalent to unmaskedscore with context replaced with "<unk>"

```

!!! note

    When you call `MLE(voc)` for the first time, It will update your vocabulary set as well. 

## Evaluation Method

### `score` 

used to evaluate the probability of word given context (*P(word | context)*)

```@docs
score
```

Arguments:

1. `m` : Instance of `Langmodel` struct.
2. `temp_lm`: output of function call of instance of `Langmodel`.
3. `word`: string of word 
4. `context`: context of given word

- In case of `Lidstone` and `Laplace` it apply smoothing and, 

- In Interpolated language model, provide `Kneserney` and `WittenBell` smoothing 

### `maskedscore` 
```@docs
maskedscore
```

### `logscore`
```@docs
logscore
```


### `entropy`

```@docs
entropy
```

### `perplexity`
```@docs
perplexity
```

##  Preprocessing

 For Preprocessing following functions:
```@docs
everygram
padding_ngram
```

## Vocabulary 

Struct to store Language models vocabulary

checking membership and filters items by comparing their counts to a cutoff value

It also Adds a special "unknown" tokens which unseen words are mapped to

```@repl
using TextAnalysis
words = ["a", "c", "-", "d", "c", "a", "b", "r", "a", "c", "d"]
vocabulary = Vocabulary(words, 2) 

# lookup a sequence or words in the vocabulary

word = ["a", "-", "d", "c", "a"]

lookup(vocabulary ,word)
```
