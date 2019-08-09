# Named Entity Recognition

The API provided is a pretrained model for tagging Named Entities.
The current model support 4 types of Named Entities -

- `PER`: Person
- `LOC`: Location
- `ORG`: Organisation
- `MISC`: Miscellaneous
- `O`: Not a Named Entity

To use the API, we first load the model weights into an instance of tagger.
The function also accepts the path of model_weights and model_dicts (for character and word embeddings)

    NERTagger()
    NERTagger(dicts_path, weights_path)

```julia
julia> ner = NERTagger()
```
!!! note
    When you call `NERTagger()` for the first time, the package will request permission for download the `Model_dicts` and `Model_weights`. Upon downloading, these are store locally and managed by `DataDeps`. So, on subsequent uses the weights will not need to be downloaded again.

Once we create an instance, we can call it to tag a sentence or a sequence of tokens.

    (ner::NERTagger)(sentence::String)
    (ner::NERTagger)(tokens::Array{String, 1})

```julia
julia> sentence = "This package is maintained by John Doe."
"This package is maintained by John Doe."

julia> tags = ner(sentence)
8-element Array{String,1}:
 "O"
 "O"
 "O"
 "O"
 "O"
 "PER"
 "PER"
 "O"

```

The API tokenizes the input sentences via the default tokenizer provided by `WordTokenizers`, this currently being set to the multilingual `TokTok Tokenizer.`

```
julia> using WordTokenizers

julia> collect(zip(WordTokenizers.tokenize(sentence), tags))
8-element Array{Tuple{String,String},1}:
 ("This", "O")
 ("package", "O")
 ("is", "O")
 ("maintained", "O")
 ("by", "O")
 ("John", "PER")
 ("Doe", "PER")
 (".", "O")

```

For tagging a multisentence text or document, once can use `split_sentences` from `WordTokenizers.jl` package and run the ner model on each.

```julia
julia> sentences = "Rabinov is winding up his term as ambassador. He will be replaced by Eliahu Ben-Elissar, a former Israeli envoy to Egypt and right-wing Likud party politiian." # Sentence taken from CoNLL 2003 Dataset

julia> splitted_sents = WordTokenizers.split_sentences(sentences)

julia> tag_sequences = ner.(splitted_sents)
2-element Array{Array{String,1},1}:
 ["PER", "O", "O", "O", "O", "O", "O", "O", "O"]
 ["O", "O", "O", "O", "O", "PER", "PER", "O", "O", "O", "MISC", "O", "O", "LOC", "O", "O", "ORG", "ORG", "O", "O"]

julia> zipped = [collect(zip(tag_sequences[i], WordTokenizers.tokenize(splitted_sents[i]))) for i in eachindex(splitted_sents)]

julia> zipped[1]
9-element Array{Tuple{String,String},1}:
 ("PER", "Rabinov")
 ("O", "is")
 ("O", "winding")
 ("O", "up")
 ("O", "his")
 ("O", "term")
 ("O", "as")
 ("O", "ambassador")
 ("O", ".")

julia> zipped[2]
20-element Array{Tuple{String,String},1}:
 ("O", "He")
 ("O", "will")
 ("O", "be")
 ("O", "replaced")
 ("O", "by")
 ("PER", "Eliahu")
 ("PER", "Ben-Elissar")
 ("O", ",")
 ("O", "a")
 ("O", "former")
 ("MISC", "Israeli")
 ("O", "envoy")
 ("O", "to")
 ("LOC", "Egypt")
 ("O", "and")
 ("O", "right-wing")
 ("ORG", "Likud")
 ("ORG", "party")
 ("O", "politiian")
 ("O", ".")
```
