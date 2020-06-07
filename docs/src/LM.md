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
<MLE>(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
Lidstone(word::Vector{T}, gamma:: Float64, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
Laplace(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
WittenBellInterpolated(word::Vector{T}, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
KneserNeyInterpolated(word::Vector{T}, discount:: Float64=0.1, unk_cutoff=1, unk_label="<unk>") where { T <: AbstractString}
        
(lm::<Languagemodel>)(text, min::Integer, max::Integer)
```
Arguments:

 * `word` : Array of  strings to store vocabulary.

 * `unk_cutoff`: Tokens with counts greater than or equal to the cutoff value will be considered part of the vocabulary.

 * `unk_label`: token for unkown labels 

 *  `gamma`: smoothing arugment gamma 

 * `discount`:  discounting factor for `KneserNeyInterpolated`

   for more information see docstrings of vocabulary

```julia
julia> voc = ["my","name","is","salman","khan","and","he","is","shahrukh","Khan"]

julia>train = ["khan","is","my","good", "friend","and","He","is","my","brother"]
# voc and train are used to train vocabulary and model respectively

julia> model = MLE(voc)
MLE(Vocabulary(Dict("khan"=>1,"name"=>1,"<unk>"=>1,"salman"=>1,"is"=>2,"Khan"=>1,"my"=>1,"he"=>1,"shahrukh"=>1,"and"=>1…), 1, "<unk
        >", ["my", "name", "is", "salman", "khan", "and", "he", "is", "shahrukh", "Khan", "<unk>"]))
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

- `score` 

    used to evaluate probablity of word given context (*P(word | context)*)

   ```julia
	score(m::gammamodel, temp_lm::DefaultDict, word::AbstractString, context::AbstractString)
   ```

​	In case of Lidstone and Laplace it apply smoothing and, 

​	In Interpolated language model, provide Kneserney and WittenBell smoothing  

- `maskedscore` 

  It is used to evaluate *score* with masks out of vocabulary words

  The arguments are the same as for score

- `logscore` 

  Evaluate the log score of this word in this context.

  The arguments are the same as for score and maskedscore

- `entropy`
	```julia
  entropy(m::Langmodel,lm::DefaultDict,text_ngram::word::Vector{T}) where { T <: AbstractString}
	```

  Calculate cross-entropy of model for given evaluation text.

  Input text must be Array of ngram of same lengths

- `perplexity`  

  Calculates the perplexity of the given text.

  This is simply 2 ** cross-entropy(`entropy`) for the text, so the arguments are the same as `entropy`.

##  Preprocessing

 For Preprocessing following functions:

1. `everygram`: Return all possible ngrams generated from sequence of items, as an Array{String,1}

   ```julia
   julia> seq = ["To","be","or","not"]
   julia> a = everygram(seq,min_len=1, max_len=-1)
    10-element Array{Any,1}:
     "or"          
     "not"         
     "To"          
     "be"                  
     "or not" 
     "be or"       
     "be or not"   
     "To be or"    
     "To be or not"
   ```

2. `padding_ngrams`: padding _ngram is used to pad both left and right of sentence and out putting ngrmas of order n

   It also pad the original input Array of string 

   ```julia
   julia> example = ["1","2","3","4","5"]
         
   julia> example = ["1","2","3","4","5"]
   julia> padding_ngrams(example,2,pad_left=true,pad_right=true)
    6-element Array{Any,1}:
     "<s> 1" 
     "1 2"   
     "2 3"   
     "3 4"   
     "4 5"   
     "5 </s>"
   ```
## Vocabulary 

Struct to store Language models vocabulary

checking membership and filters items by comparing their counts to a cutoff value

It also Adds a special "unkown" tokens which unseen words are mapped to

```julia
julia> words = ["a", "c", "-", "d", "c", "a", "b", "r", "a", "c", "d"]
julia> vocabulary = Vocabulary(words, 2) 
  Vocabulary(Dict("<unk>"=>1,"c"=>3,"a"=>3,"d"=>2), 2, "<unk>") 

# lookup a sequence or words in the vocabulary
julia> word = ["a", "-", "d", "c", "a"]

julia> lookup(vocabulary ,word)
 5-element Array{Any,1}:
  "a"    
  "<unk>"
  "d"    
  "c"    
  "a"
```
