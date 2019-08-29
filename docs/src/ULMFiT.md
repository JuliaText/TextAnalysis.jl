# ULMFiT

This is the implementation of [Universal Language Model Fine-tuning for Text Classification](https://arxiv.org/pdf/1801.06146.pdf) paper released by the Jeremy Howard and Sebastian Ruder. The model can be used for several classification tasks in Natural Language Processing domain. The model follows the concept of [Transfer learning](https://en.wikipedia.org/wiki/Transfer_learning). Here, the model was trained to perform Sentiment Analysis task. The weights for that is also provided and also the weights for the Language model part of the ULMFiT is provided so that it can be used to fine-tune the model for different tasks.

## Data Loading and Preprocessing

Proper preprocessing is essential before start training ULMFiT. For pretraining step for Language model, a general-purpose corpus is needed, which here is WikiText-103 by default. Similarly, for fine-tuning Language Model and fine-tuning classifier we need a dataset for the specific task (example IMDB for Sentiment Analysis, large scale AG news and DBpedia ontology datasets for Topic classification etc). To load data for these steps, data loaders are needed to be defined. Since the data used to train for such a large model is large, so it is not recommended to load all the data at once, instead the data should be loaded in batches through concept of tasks (or coroutines) in Julia (Refer [this](https://docs.julialang.org/en/v1.0/manual/control-flow/#man-tasks-1) documentation for understanding tasks in Julia) using `Channels`. Basically, we need to create `Channel` which supply a mini-batch at every call. As example the functions used for preprocessing of the IMDB dataset used is given in the `data_loaders.jl` in ULMFiT directory. Also, for loading WikiText-103 dataset and IMDB dataset default functions are provided in same file.

Default data loaders are provided in the `data_loaders.jl`:

 * `load_wikitext_103`    : returns `Channel` which gives batches from WikiText-103 dataset
 * `imdb_fine_tune_data`  : returns `Channel` for loading fine-tuning data from IMDb movie review dataset
 * `imdb_classifier_data` : returns `Channel` for loading classification data from IMDB movie review dataset for binary sentiment analysis

 To make custom loaders, have a look into these functions. These will give clear idea of preparation of batches inside data loaders.

## Step 1 - Pre-training Language Model

In this step, Language Model will learn the general properties of the Language. To train the model we need a general domain corpus like WikiText-103. For training, a `generator` function is provided to create a `Channel` which will give mini-batch in every call. After pre-processing the corpus, the tokenized corpus is given as input to the generator function and the Channel can be created like so:
```julia
julia> loader = Channel(x -> generator(x, corpus; batchsize=4, bptt=10))
Channel{Any}(sz_max:0,sz_curr:1)

julia> max_batches = take!(loader) # this is the first call to the loader

# These are the subsequent calls in pairs for X and Y
julia> X = take!(Loaders)
 10-element Array{Array{Any,1},1}:
 ["senjō", ",", "indicated", "after"]   
 ["no", "he", ",", "two"]               
 ["valkyria", "sent", "\"", "games"]    
 ["3", "a", "i", ","]                   
 [":", "formal", "am", "making"]        
 ["<unk>", "demand", "to", "a"]         
 ["chronicles", "for", "some", "start"]
 ["(", "surrender", "extent", "against"]
 ["japanese", "of", "influenced", "the"]
 [":", "the", "by", "vancouver"]

julia> Y = take!(gen)
10-element Array{Array{Any,1},1}:
["no", "he", ",", "two"]                    
["valkyria", "sent", "\"", "games"]         
["3", "a", "i", ","]                        
[":", "formal", "am", "making"]             
["<unk>", "demand", "to", "a"]              
["chronicles", "for", "some", "start"]      
["(", "surrender", "extent", "against"]     
["japanese", "of", "influenced", "the"]     
[":", "the", "by", "vancouver"]             
["戦場のヴァルキュリア", "arsenal", "them", "canucks"]
```
Note that at the first call to this `Channel` the output will be maximum number of batches which it can give. Two calls to this `Channel` completed one batch, that is, it doesnot give `X` and `Y` both together in one call, two calls are needed, one first `X` is given out and in second `Y`. Also, to understand what are `batchsize` and `bptt`, refer this [blog](https://nextjournal.com/ComputerMaestro/jsoc19-practical-implementation-of-ulmfit-in-julia-2).

### Training Language Model:

File `pretrain_lm.jl` contains the whole implementation of the `LanguageModel`. To start training, first, create an instance of `LanguageModel` type, then use the below specified function with appropriate arguments.

```julia
julia> lm = LanguageModel()
```

It has several arguments to defined the internal structure of the `LanguageModel` instance:
[All are keyword arguments and optional]

 * `embedding_size`      : defines size of embeddings for embedding matrix in `DroppedEmbeddings` layer (default value is 400)
 * `hid_lstm_sz`         : defines size of hidden `AWD_LSTM` layer (default value is 1150)
 * `out_lstm_sz`         : defines size of output `AWD_LSTM` layer (default value is equal to `embedding_size`)
 * `embed_drop_prob`     : embedding dropout probability in `DroppedEmbeddings` (default value is 0.05)
 * `word_drop_prob`      : dropout probability to the input embeddings to first `AWD_LSTM` layer (default value is 0.4)
 * `hid_drop_prob`       : DropConnect probability to the hidden matrices of the each `AWD_LSTM` layer (default value is 0.5)
 * `layer_drop_prob`     : probability of the dropout layer between the `AWD_LSTM` layers (default value is 0.3)
 * `final_drop_prob`     : probability of the dropout layer after the last `AWD_LSTM` layer (default value is 0.3)


```julia
pretrain_lm!(lm::LanguageModel=LanguageModel(),
            data_loader::Channel=load_wikitext_103;
            base_lr=0.004,
            epochs::Integer=1,
            checkpoint_itvl::Integer=5000)
```

Positional Arguments:

 * `lm`               : instance of `LanguageModel struct`
 * `data_loader`      : this `Channel` is created to load the data from the general-domain corpus

Keyword Arguments:

 * `base_lr`          : learning rate for `ADAM` optimizers
 * `epochs`           : number of epochs
 * `checkpoint_itvl`  : Stands for Checkpoint interval, interval of number of iterations after which the model weights are saved to a specified BSON file

[All default values shown above]

To know the full implementation of the `LanguageModel`, `AWD_LSTM` layer and `DroppedEmbeddings` layer, refer [blog1](https://nextjournal.com/ComputerMaestro/jsoc19-practical-implementation-of-ulmfit-for-text-clasification) and [blog2](https://nextjournal.com/ComputerMaestro/jsoc19-practical-implementation-of-ulmfit-in-julia-2).

## Step 2 - Fine-tuning Language Model

In this step, the Language Model pretrained in the last step, will be fine-tuned on the target data of the downstream task (e.g. sentiment analysis). Again preprocess the text data from the dataset and create a `Channel` using the `generator` function. `fine_tune_lm.jl` contains all the functions related to fine-tuning of the Language model.

### Fine-tune Language model:

`fine_tune_lm!` function is used to fine-tune a Language Model:

```julia
fine_tune_lm!(lm::LanguageModel=load_lm(),
        data_loader::Channel=imdb_fine_tune_data,
        stlr_cut_frac::Float64=0.1,
        stlr_ratio::Float32=32,
        stlr_η_max::Float64=0.01;
        epochs::Integer=1,
        checkpoint_itvl::Integer=5000
)
```

Positional Arguments:

 * `lm`               : Instance of `LanguageModel struct`
 * `data_loader`      : `Channel` created to load mini-batches from target data

Keyword Arguments:

 * `stlr_cut_frac`    : In STLR, it is the fraction of iterations for which LR is increased
 * `stlr_ratio`       : In STLR, it specifies how much smaller is lowest LR from maximum LR
 * `stlr_η_max`       : In STLR, this is the maximum LR value
 * `epochs`           : It is simply the number of epochs for which the language model is to be fine-tuned
 * `checkpoint_itvl`  : Stands for Checkpoint interval, interval of number of iterations after which the model weights are saved to a specified BSON file

[All default values shown above]
By default the `fine_tune_lm!` function will load a pretrained model if a `LanguageModel` instance is not provided.

In fine-tuning step, some additional techniques are used to for training, namely, Discriminative fine-tuning and Slanted triangular learning rates (STLR). To know there implementation refer [this](https://nextjournal.com/ComputerMaestro/jsoc19-practical-implementation-of-ulmfit-in-julia-3) blog.

## Step 3 - Fine-tuning the classifier for downstream task

This is the final step of training ULMFiT model for a specifc task. Here, two linear blocks will be in addition with the Language model layers. These are `PooledDense` and `Dense`. To know more about them go through [this](https://nextjournal.com/ComputerMaestro/jsoc19-practical-implementation-of-ulmfit-in-julia-5) blog post.

### Fine-tune text classifier

Before start of training, it is required to make an instance of the `TextClassifier` type like so:

```julia
julia> classifier = TextClassifier()
```

Arguments:
[All are positional and optional arguments]

  * `lm`                   : Instance of `LanguageModel` [by default `LanguageModel()`]
  * `clsfr_out_sz`         : output `Dense` layer size of classifier [default value is 2]
  * `clsfr_hidden_sz`      : hidden `PooledDense` layer size of classifier [default value is 50]
  * `clsfr_hidden_drop`    : dropout probability for the `PooledDense` layer [hidden layer] of classifier [default value is 0.4]

To start training use `train_classifier!` function:

```julia
train_classifier!(classifier::TextClassifier=TextClassifier(),
        classes::Integer=1,
        data_loader::Channel=imdb_classifier_data,
        hidden_layer_size::Integer=50;
        stlr_cut_frac::Float64=0.1,
        stlr_ratio::Number=32,
        stlr_η_max::Float64=0.01,
        val_loader::Channel=nothing,
        cross_val_batches::Union{Colon, Integer}=:,
        epochs::Integer=1,
        checkpoint_itvl=5000
)
```

Positional Arguments:

 * `lm`               : Instance of `LanguageModel struct`
 * `classes`          : Size of output layer for classifier or number of classes for which the classifier is to be trained
 * `data_loader`     : `Channel` created to load mini-batches for classification
 * `hidden_layer_size`: Size of the hidden linear layer added for making classifier

Keyword Arguments:

 * `stlr_cut_frac`    : In STLR, it is the fraction of iterations for which LR is increased
 * `stlr_ratio`       : In STLR, it specifies how much smaller is lowest LR from maximum LR
 * `stlr_η_max`       : In STLR, this is the maximum LR value
 * `val_loader`       : `Channel` which will load the cross validation set as mini-batches same as `data_loader`
 * `cross_val_batches`: number of cross validation batches for the accuracy and loss will be printed
 * `epochs`           : It is simply the number of epochs for which the language model is to be fine-tuned
 * `checkpoint_itvl`  : Stands for Checkpoint interval, interval of number of iterations after which the model weights are saved to a specified BSON file

[All defaults values are shown above]
