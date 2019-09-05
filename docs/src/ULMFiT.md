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

## Layers

There are some custom layers added for this model to work properly. All of them are described below, go though all of them to have a better understanding of the model.

### Weight-Dropped LSTM (WeightDroppedLSTM)

This is basically a modification to the original LSTM layer. The layer uses [DropConnect](http://yann.lecun.com/exdb/publis/pdf/wan-icml-13.pdf) with [Variational-dropping](https://arxiv.org/abs/1506.02557) concepts. In which, the hidden-to-hidden weights and input-to-hidden weights can be dropped randomly for given probability. That means, the layer uses the same drop mask for all timesteps and to do this, the layer saves the masks. To change the mask `reset_masks!` function should be used.

```julia
# maskWi and maskWh are drop masks for Wi and Wh weights
julia> fieldnames(WeightDroppedLSTMCell)
(:Wi, :Wh, :b, :h, :c, :p, :maskWi, :maskWh, :active)

# To deine a layer with 4 input size and 5 output size and 0.3 dropping probability
julia> wd = WeightDroppedLSTM(4, 5, 0.3);

# Pass
julia> x = rand(4);
julia> h = wd(x)
Tracked 5-element Array{Float64,1}:
  0.06149460838123775
 -0.06028818475111407
  0.07400426274491535
 -0.20671647527394219
 -0.00678279380721769

# To reset_masks!
julia> reset_masks!(wd)
```

### Averaged-SGD LSTM (AWD_LSTM)

This is a regular LSTM layer with Variational DropConnect and weights averaging functionality (while training). This layer comes out to be efficient for Language modelling tasks (refer [this](https://arxiv.org/pdf/1708.02182.pdf)). It used the `WeightDroppedLSTM` layer discussed above for DropConnect property. It averages the weights on subsequent iteration after trigger iteration. The layer needs a trigger iteration number to use its averaging functionality. To set the trigger `set_trigger!` function can be used and `reset_masks!` can be used for resetting drop masks for DropConnect.

```julia
# `accum` field is used to store the sum of weights for every iteration after trigger
# to get average of the weights for every subsequent iteration
julia> fieldnames(AWD_LSTM)
(:layer, :T, :accum)

julia> awd = AWD_LSTM(3, 4, 0.5)

# Setting trigger iteration
julia> set_trigger!(1000, awd)
julia> awd.T
1000

# Pass
julia> x = rand(3)
julia> h = awd(x)
Tracked 4-element Array{Float64,1}:
 -0.0751824486756288
 -0.3061227967356536
 -0.030079860137667995
 -0.09833401074779546

 # Resetting drop masks
 julia> awd.layer.cell.maskWi
 16×3 Array{Float32,2}:
 0.0  2.0  2.0
 2.0  2.0  2.0
 0.0  2.0  0.0
 0.0  0.0  2.0
 0.0  0.0  2.0
 2.0  2.0  2.0
 2.0  2.0  2.0
 0.0  2.0  2.0
 0.0  2.0  0.0
 2.0  0.0  2.0
 0.0  0.0  2.0
 0.0  2.0  2.0
 2.0  0.0  2.0
 0.0  2.0  0.0
 0.0  2.0  0.0
 2.0  0.0  2.0

 julia> reset_masks!(awd)
 julia> awd.layer.cell.maskWi
 16×3 Array{Float32,2}:
 0.0  2.0  0.0
 0.0  0.0  0.0
 2.0  0.0  0.0
 0.0  2.0  0.0
 2.0  2.0  0.0
 2.0  2.0  2.0
 2.0  2.0  0.0
 2.0  2.0  0.0
 2.0  2.0  2.0
 0.0  0.0  2.0
 2.0  0.0  0.0
 2.0  2.0  2.0
 2.0  2.0  2.0
 0.0  0.0  2.0
 0.0  2.0  0.0
 0.0  0.0  2.0
```

### Variational-DropOut (VarDrop)

This layer applis Variational-DropOut, which is, using same dropout mask till it is not specified to change or till a pass is over. This dropout is useful for recurrent layers since these layers perform better if same mask is used for all time-steps (pass) instead of using different for every timestep. [Refer [this](https://arxiv.org/pdf/1506.02557.pdf) paper for more details]. This layer saves the masks after generation till it is not specified to change. To change the mask use `reset_masks!` function.

```julia
julia> vd = VarDrop(0.5)
VarDrop{Float64}(0.5, Array{Float32}(0,0), true, true)

# No mask generation will nothing is passed
julia> vd.mask
0×0 Array{Float32,2}

julia> x = rand(4,5)
4×5 Array{Float64,2}:
 0.480531  0.556341   0.228134  0.439411    0.137296
 0.541459  0.118603   0.448941  0.568478    0.0440091
 0.491735  0.55232    0.857768  0.729287    0.842753
 0.33523   0.0378036  0.491757  0.00710462  0.374096

 julia> x = vd(x)
 4×5 Array{Float64,2}:
 0.961062  1.11268    0.0       0.0        0.274592
 1.08292   0.0        0.897881  0.0        0.0880182
 0.98347   0.0        0.0       1.45857    1.68551
 0.67046   0.0756071  0.983514  0.0142092  0.0

 julia> vd.mask
 4×5 Array{Float64,2}:
 2.0  2.0  0.0  0.0  2.0
 2.0  0.0  2.0  0.0  2.0
 2.0  0.0  0.0  2.0  2.0
 2.0  2.0  2.0  2.0  0.0
```

### Dropped Embeddings (DroppedEmbeddings)

This layer is an embedding layer which can work in two ways either to give embeddings Vectors for the given indices of words in vocabulary or can be used to get probability distribution for all the words of vocabulary with softmax layer, which is also called as weight-tying. Here, it can be used to tie weights of the embedding layer and the last softmax layer. In addition to this, it also dropped embeddings for words randomly for given probability of dropping, in other words, it puts whole embedding vector of randomly selects to vector of zeros. Here, the mask used for the dropping posses variational property, that is, it cannot be changed till it is not specified to change or generate a new drop mask. `reset_masks!` should be used to reset the mask.

```julia
julia> fieldnames(DroppedEmbeddings)
(:emb, :p, :mask, :active)

julia> de = DroppedEmbeddings(5, 2, 0.3)

# Pass
julia> x = [4,2,1]
julia> embeddings = de(x)
Tracked 2×3 LinearAlgebra.Transpose{Float32,Array{Float32,2}}:
 0.86327    0.537614  -0.0
 0.152131  -0.541008  -0.0

 julia> de.mask
 5-element Array{Float32,1}:
 0.0
 1.4285715
 1.4285715
 1.4285715
 1.4285715

 # reset mask
 julia> reset_masks!(de)
 julia> de.mask
 5-element Array{Float32,1}:
 0.0
 1.4285715
 1.4285715
 0.0
 1.4285715
```

### Concat-Pooled Dense layer

This is a simple modification to the original `Dense` layer for recurrent networks. This layer should come after last RNN layer in the network. It takes the `Vector` of outputs of the RNN layers at all timesteps and then performs max and mean pooling to those outputs, then concatenates these outputs with the last output of the RNN layers and passes this concatenation result to the a `Dense` layer within.

```julia
# The first argument is the length of the output Vector of the preceding RNN layer to this layer. Also, by default if uses identity activation, it can be changed by giving desired activaiton as the third argument
julia> pd = PooledDense(4, 3)

# Pass
julia> X = [rand(4), rand(4), rand(4)]
julia> pd(X)
Tracked 3×1 Array{Float64,2}:
 -2.2106991143006036
 -0.9560163708455404
 -0.4770649645417375
```
