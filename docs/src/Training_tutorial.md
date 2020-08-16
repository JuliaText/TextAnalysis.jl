
## ALBERT Fine tuning Tutorial
In this tutorial, we will be going through usage of SOTA transformers. We will be using ALBERT transformer model for this tutorial. You can check this link to understand more about [ALBERT](https://arxiv.org/abs/1909.11942)

Get IPYNB [here](https://github.com/tejasvaidhyadev/ALBERT.jl/blob/master/docs/Training_fine-tunning_%20tutorial.ipynb)

We are going to use the following library for our tutorial
- TextAnlaysis.ALBERT
- WordTokenizer 
- Transformers and Flux 



```julia
using TextAnalysis
using TextAnalysis.ALBERT # it is where our model reside
```

lets checkout the model version avaliable in PretrainedTransformer


```julia
subtypes(ALBERT.PretrainedTransformer)
```




    2-element Array{Any,1}:
     TextAnalysis.ALBERT.ALBERT_V1
     TextAnalysis.ALBERT.ALBERT_V2



To check different size model 


```julia
model_version( TextAnalysis.ALBERT.ALBERT_V1)
```




    4-element Array{String,1}:
     "albert_base_v1"
     "albert_large_v1"
     "albert_xlarge_v1"
     "albert_xxlarge_v1"



Before moving forward let us look at the following basic steps involved in using any transformer,

 ### For preprocessing
- Tokenize the input data and other input details such as Attention Mask for BERT to not ignore the attention on padded sequences.
- Convert tokens to input ID sequences.
- Pad the IDs to a fixed length.

### For modelling
- Load the model and feed in the input ID sequence (Do it batch wise suitably based on the memory available).
- Get the output of the last hidden layer
- Last hidden layer has the sequence representation embedding at 1th index
- These embeddings can be used as the inputs for different machine learning or deep learning models.


`WordTokenizer` will handle the Preprocessing part
and `TextAnlaysis` will handle Modelling


```julia
transformer = ALBERT.from_pretrained( "albert_base_v2") #here we are using version 1 i.e base
```

    This program has requested access to the data dependency albert_base_v2.
    which is not currently installed. It can be installed automatically, and you will not see this message again.
    
    albert-weights BSON file converted from official weigths-file by google research .
    Website: https://github.com/google-research/albert
    Author: Google Research
    Licence: Apache License 2.0
    albert base version2 of size ~46 MB download.


​    
    Do you want to download the dataset from https://drive.google.com/uc?export=download&id=19llahJFvgjQNQ9pzES2XF0R9JdYwuuTk to "/home/iamtejas/.julia/datadeps/albert_base_v2"?
    [y/n]
    stdin> 
    Do you want to download the dataset from https://drive.google.com/uc?export=download&id=19llahJFvgjQNQ9pzES2XF0R9JdYwuuTk to "/home/iamtejas/.julia/datadeps/albert_base_v2"?
    [y/n]
    stdin> y


    ┌ Info: Downloading
    │   source = https://doc-0k-3g-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/mclfg9m1jrs6lb467a4gk0jrph10oocv/1597362075000/15884229709856900679/*/19llahJFvgjQNQ9pzES2XF0R9JdYwuuTk?e=download
    │   dest = /home/iamtejas/.julia/datadeps/albert_base_v2/albert_base_v2.bson
    │   progress = NaN
    │   time_taken = 5.0 s
    │   time_remaining = NaN s
    │   average_speed = 6.711 MiB/s
    │   downloaded = 33.562 MiB
    │   remaining = ∞ B
    │   total = ∞ B
    └ @ HTTP /home/iamtejas/.julia/packages/HTTP/BOJmV/src/download.jl:119
    ┌ Info: Downloading
    │   source = https://doc-0k-3g-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/mclfg9m1jrs6lb467a4gk0jrph10oocv/1597362075000/15884229709856900679/*/19llahJFvgjQNQ9pzES2XF0R9JdYwuuTk?e=download
    │   dest = /home/iamtejas/.julia/datadeps/albert_base_v2/albert_base_v2.bson
    │   progress = NaN
    │   time_taken = 6.6 s
    │   time_remaining = NaN s
    │   average_speed = 6.959 MiB/s
    │   downloaded = 45.903 MiB
    │   remaining = ∞ B
    │   total = ∞ B
    └ @ HTTP /home/iamtejas/.julia/packages/HTTP/BOJmV/src/download.jl:119





    TransformerModel{TextAnalysis.ALBERT.albert_transformer}(
      embed = CompositeEmbedding(tok = Embed(128), segment = Embed(128), pe = PositionEmbedding(128, max_len=512), postprocessor = Positionwise(LayerNorm(128), Dropout(0))),
      transformers = albert(layers=12, head=12, head_size=64, pwffn_size=3072, size=768),
      classifier = 
        (
          pooler => Dense(768, 768, tanh)
          masklm => (
            transform => Chain(Dense(768, 128, gelu), LayerNorm(128))
            output_bias => Array{Float32,1}
          )
          nextsentence => Chain(Dense(768, 2), logsoftmax)
        )
    )



Tokenizer


```julia
using WordTokenizers
```

To get more detail on tokenizer refer the following [blog](https://tejasvaidhyadev.github.io/blog/Hey-Albert) 


```julia
spm = load(ALBERT_V1,1) #because we are using base-version1 
```




    WordTokenizers.SentencePieceModel(Dict("▁shots" => (-11.2373, 7281),"▁ordered" => (-9.84973, 1906),"▁doubtful" => (-12.7799, 22569),"▁glancing" => (-11.6676, 10426),"▁disrespect" => (-13.13, 26682),"▁without" => (-8.34227, 367),"▁pol" => (-10.7694, 4828),"chem" => (-12.3713, 17661),"▁1947," => (-11.7544, 11199),"▁kw" => (-10.4402, 3511)…), 2)



we will use DataLoader avaliable in [`Transformers`](https://github.com/chengchingwen/Transformers.jl)

using QNLI Dataseet


```julia
using Transformers.Datasets
using Transformers.Datasets.GLUE
using Transformers.Basic
task = GLUE.QNLI()
datas = dataset(Train, task)
```

    This program has requested access to the data dependency GLUE-QNLI.
    which is not currently installed. It can be installed automatically, and you will not see this message again.
    
    Question NLI (SQuAD2.0 / QNLI) task (GLUE version)


​    
    Do you want to download the dataset from https://firebasestorage.googleapis.com/v0/b/mtl-sentence-representations.appspot.com/o/data%2FQNLIv2.zip?alt=media&token=6fdcf570-0fc5-4631-8456-9505272d1601 to "/home/iamtejas/.julia/datadeps/GLUE-QNLI"?
    [y/n]
    stdin> 
    Do you want to download the dataset from https://firebasestorage.googleapis.com/v0/b/mtl-sentence-representations.appspot.com/o/data%2FQNLIv2.zip?alt=media&token=6fdcf570-0fc5-4631-8456-9505272d1601 to "/home/iamtejas/.julia/datadeps/GLUE-QNLI"?
    [y/n]
    stdin> y


    ┌ Info: Downloading
    │   source = https://firebasestorage.googleapis.com/v0/b/mtl-sentence-representations.appspot.com/o/data%2FQNLIv2.zip?alt=media&token=6fdcf570-0fc5-4631-8456-9505272d1601
    │   dest = /home/iamtejas/.julia/datadeps/GLUE-QNLI/data%2FQNLIv2.zip?alt=media&token=6fdcf570-0fc5-4631-8456-9505272d1601
    │   progress = 1.0
    │   time_taken = 1.86 s
    │   time_remaining = 0.0 s
    │   average_speed = 5.458 MiB/s
    │   downloaded = 10.135 MiB
    │   remaining = 0 bytes
    │   total = 10.135 MiB
    └ @ HTTP /home/iamtejas/.julia/packages/HTTP/BOJmV/src/download.jl:119


    Archive:  QNLIv2.zip
       creating: /home/iamtejas/.julia/datadeps/GLUE-QNLI/QNLI/
      inflating: /home/iamtejas/.julia/datadeps/GLUE-QNLI/QNLI/dev.tsv  
      inflating: /home/iamtejas/.julia/datadeps/GLUE-QNLI/QNLI/test.tsv  
      inflating: /home/iamtejas/.julia/datadeps/GLUE-QNLI/QNLI/train.tsv  



**Output** 

    (Channel{String}(sz_max:0,sz_curr:1), Channel{String}(sz_max:0,sz_curr:0), Channel{String}(sz_max:0,sz_curr:0))


```julia
using Flux: onehotbatch
labels = get_labels(task)
```

**Output** 


    ("entailment", "not_entailment")



Basic Preprocessing function 


```julia
makesentence(s1, s2) = ["[CLS]"; s1; "[SEP]"; s2; "[SEP]"]
function preprocess(training_batch)
ids =[]
sent = []
for i in 1:length(training_batch[1])
    sent1 = tokenizer(spm,training_batch[1][i])
    sent2 = tokenizer(spm,training_batch[2][i])
    id = makesentence(sent1,sent2)
    push!(sent, id)
    push!(ids,ids_from_tokens(spm,id))
end
    #print(sent)
    mask = getmask(convert(Array{Array{String,1},1}, sent)) #better API underprogress

E = Flux.batchseq(ids,1)
E = Flux.stack(E,1)
length(E) #output embedding matrix
segment = fill!(similar(E), 1)
    for (i, sent) ∈ enumerate(sent)
      j = findfirst(isequal("[SEP]"), sent)
      if j !== nothing
        @view(segment[j+1:end, i]) .= 2
      end
end
data = (tok = E,segment = segment)
labels = get_labels(task)
label = onehotbatch(training_batch[3], labels)
return(data,label,mask)
end
```

**Output** 


    preprocess (generic function with 1 method)



lets Define loss function


```julia
using Flux
using Flux: gradient
import Flux.Optimise: update!

clf = Flux.Chain(
    Flux.Dropout(0.1),
    Flux.Dense(768, length(labels)), Flux.logsoftmax
)
transformer = gpu(
  Basic.set_classifier(transformer, 
    (
      pooler = transformer.classifier.pooler,
      clf = clf
    )
  )
)
@show transformer

#define the loss
function loss(data, label, mask=nothing)
    e = (transformer.embed(data))
    t = (transformer.transformers(e))
    l = logcrossentropy(label,
         clf(
            transformer.classifier.pooler(
                t[:,1,:]
            )
        )
    )
    return l
end
```

    transformer = TransformerModel{TextAnalysis.ALBERT.albert_transformer}(
      embed = CompositeEmbedding(tok = Embed(128), segment = Embed(128), pe = PositionEmbedding(128, max_len=512), postprocessor = Positionwise(LayerNorm(128), Dropout(0))),
      transformers = albert(layers=12, head=12, head_size=64, pwffn_size=3072, size=768),
      classifier = 
        (
          pooler => Dense(768, 768, tanh)
          clf => Chain(Dropout(0.1), Dense(768, 2), logsoftmax)
        )
    )



**Output** 

    loss (generic function with 2 methods)


```julia
using Flux
using Flux: gradient
import Flux.Optimise: update!

using CuArrays

data_batch = get_batch(datas, 2)
data_batch, label_batch, mask =(preprocess(data_batch))
for i ∈ 1:20 # iteration of 20 cycles over same data to see convergence 
#data_batch = get_batch(datas, 2)
#data_batch, label_batch, mask = preprocess(data_batch)
l= loss(data_batch, label_batch, mask)
ps = params(transformer)
opt = ADAM(1e-4)
@show l
  grad = gradient(()-> loss(data_batch, label_batch, mask), ps)
  update!(opt, ps, grad)
end
```
**Output** 

    l = 0.28236875f0
    l = 0.01652541f0
    l = 0.0030576359f0
    l = 0.0005550342f0
    l = 0.00016245738f0
    l = 1.984803f-5
    l = 0.0002791701f0
    l = 1.1324875f-6
    l = 1.3232057f-5
    l = 0.2661536f0
    l = 1.1324871f-6
    l = -0.0f0
    l = -0.0f0
    l = -0.0f0
    l = -0.0f0
    l = -0.0f0
    l = -0.0f0
    l = -0.0f0
    l = -0.0f0
    l = -0.0f0

