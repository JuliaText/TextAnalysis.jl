# ALBERT 

An upgrade to BERT that advances the state-of-the-art performance on 12 NLP tasks

The success of ALBERT demonstrates the importance of identifying the aspects of a model that give rise to powerful contextual representations. By focusing improvement efforts on these aspects of the model architecture, it is possible to greatly improve both the model efficiency and performance on a wide range of NLP tasks

The package can be used by NLP researchers and educators , Practitioners and engineers

## Usage

The package can be used with the help of other packages:

- WordTokenizers for Tokenization (Statistical Tokenizer)

- DataSets and other basic functionality

  Bert uses Sentencepiece unigram model for Tokenization

## Preprocessing 

ALBERT just like any BERT families takes specific formate of input embeddings

The model uses 2 types of indices or ids to generate or load token type embedding, segment embedding and position embeddings and also optional attention masks ( to avoid performing attention on padding token indices. Mask values selected in `[0, 1]`: `1` for tokens that are NOT MASKED, `0` for MASKED tokens)

```julia
julia> sample1 = "God is Great! I won a lottery."
julia> sample2 = "If all their conversations in the three months he had been coming to the diner were put together, it was doubtful that they would make a respectable paragraph."
julia> sample3 = "She had the job she had planned for the last three years."
julia> sample = [sample1,sample2,sample3]
julia> using WordTokenizers
julia> spm = load(ALBERT_v1)
WordTokenizers.SentencePieceModel(Dict("▁shots" => (-11.2373, 7281),"▁ordered" => (-9.84973, 1906),"▁doubtful" => (-12.7799, 22569),"▁glancing" => (-11.6676, 10426),"▁disrespect" => (-13.13, 26682),"▁without" => (-8.34227, 367),"▁pol" => (-10.7694, 4828),"chem" => (-12.3713, 17661),"▁1947," => (-11.7544, 11199),"▁kw" => (-10.4402, 3511)…), 2)

julia> s1 = ids_from_tokens(spm, tokenizer(spm,sample[1]))
julia> s2 = ids_from_tokens(spm, tokenizer(spm,sample[2]))
julia> s3 = ids_from_tokens(spm, tokenizer(spm,sample[3]))
julia> E = Flux.batchseq([s1,s2,s3],1)
julia> E = Flux.stack(E,1)
   32×3 Array{Int64,2}:
   14     14    14
    2      2     2
 5649    411   439
    ⋮         
    1  22740     1
    1  20600     1
    1     10     1

julia> seg_indices = ones(Int, size(E)...)
  32×3 Array{Int64,2}:
 1  1  1
 1  1  1
 1  1  1
 ⋮     
 1  1  1
 1  1  1
 1  1  1
```
**NOTE:** 
Special tokens are:
```julia
ids tokens 
1 = <pad>	
2 = <unk>	
3 = [CLS]	
4 = [SEP]	
5 = [MASK]	
```

## TextAnalysis.ALBERT.albert_transformer (ALBERT layer)

It is just another flux layer implemented on top of Transformers.jl

```julia
    albert_transformer(emb::Int,size::Int, head::Int, ps::Int, layer::Int, inner_group::Int, no_hidden_group::Int; 
act = gelu, pdrop = 0.1, attn_pdrop = 0.1)
```
The A lite Bidirectional Encoder Representations from Transformer(ALBERT) model.
​    
```Julia
(altrans::albert_transformer)(x::T, mask=nothing; all::Bool=false) where T
```

eval the albert layer on input `x`. If length `mask` is given (in shape (1, seq_len, batch_size)), mask the attention with `getmask(mask, mask)`. Moreover, set `all` to `true` to get all
outputs of each transformer layer.
```julia
Arguments:

emb  : Dimensionality of vocabulary embeddings
size  : Dimensionality of the encoder layers and the pooler layer
head  : Number of attention heads for each attention layer in the Transformer encoder
ps  : The dimensionality of the “intermediate” (i.e., feed-forward) layer in the 
Transformer encoder.   
layer  : Number of hidden layers in the Transformer encoder
inner_group  : The number of inner repetition of attention and ffn.
no_hidden_group : Number of groups for the hidden layers, parameters in the same group are shared
act  : The non-linear activation function (function or string) in the encoder and pooler. If string, “gelu”, “relu”, “swish” and “gelu_new” are supported
pdrop  :  The dropout probability for all fully connected layers in the embeddings, encoder, and pooler
attn_pdrop  :  The dropout ratio for the attention probabilities.
```

## Converted Tensorflow Checkpoints 

Pre-trained tensorflow checkpoint file by [google-research](https://github.com/google-research/ALBERT) to the Julia desired pre-trained model format(i.e. BSON) :

**Version-1 of ALBERT models**
- [Base](https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz) from [[link](https://storage.googleapis.com/albert_models/albert_base_v1.tar.gz)]
- [Large](https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz) from [[link](https://storage.googleapis.com/albert_models/albert_large_v1.tar.gz)]
- [Xlarge](https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz) from [[link](https://storage.googleapis.com/albert_models/albert_xlarge_v1.tar.gz)]
- [Xxlarge](https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz) from [[link](https://storage.googleapis.com/albert_models/albert_xxlarge_v1.tar.gz)]

**Version-2 of ALBERT models**
- [Base](https://drive.google.com/drive/u/1/folders/1DlX_WZacsjt6O8EDaawKJ-x4RWP46Xj-) 
- [Large](https://drive.google.com/drive/u/1/folders/1DlX_WZacsjt6O8EDaawKJ-x4RWP46Xj-) 
- [Xlarge](https://drive.google.com/drive/u/1/folders/1DlX_WZacsjt6O8EDaawKJ-x4RWP46Xj-)
- [Xxlarge](https://drive.google.com/drive/u/1/folders/1DlX_WZacsjt6O8EDaawKJ-x4RWP46Xj-) 

conversion code can be found [here](https://gist.github.com/tejasvaidhyadev/6c10bdda1f60c3e42472d356ecf3721a)

## Pretrained models

The following model version of albert are available :

```julia
julia> model_version(TextAnalysis.ALBERT.ALBERT_V1)
4-element Array{String,1}:
 "albert_base_v1"
 "albert_large_v1"
 "albert_xlarge_v1"
 "albert_xxlarge_v1"

julia> model_version(TextAnalysis.ALBERT.ALBERT_V2)
4-element Array{String,1}:
 "albert_base_v2"
 "albert_large_v2"
 "albert_xlarge_v2"
 "albert_xxlarge_v2"
```

To load any of the above models 

```julia
julia> ALBERT.from_pretrained("albert_base_v1")
TransformerModel{TextAnalysis.ALBERT.albert_transformer}(
  embed = CompositeEmbedding(tok = Embed(128), segment = Embed(128), pe = PositionEmbedding(128, max_len=512), postprocessor = Positionwise(LayerNorm(128), Dropout(0.1))),
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
```

## Fine-tuning 

To fine-tune albert on any of the downstream task , we need to replace classifier head from TransformerModel structure

```julia
julia> using Flux
julia> using Transformers.Basic
# lets say we are finetuing on sentence classification 
julia> clf = Flux.Chain(
       Flux.Dropout(0.1),
       Flux.Dense(768, 2), Flux.logsoftmax,)
Chain(Dropout(0.1), Dense(768, 2), logsoftmax)

julia>Basic.set_classifier(model, 
      ( pooler = transformers.classifier.pooler,
        clf = clf ))

Basic.set_classifier(model, (pooler = transformers.classifier.pooler,clf = clf))
TransformerModel{TextAnalysis.ALBERT.albert_transformer}(
  embed = CompositeEmbedding(tok = Embed(128), segment = Embed(128), pe = PositionEmbedding(128, max_len=512), postprocessor = Positionwise(LayerNorm(128), Dropout(0.1))),
  transformers = albert(layers=12, head=12, head_size=64, pwffn_size=3072, size=768),
  classifier = 
    (
      pooler => Dense(768, 768, tanh)
      clf => Chain(Dropout(0.1), Dense(768, 2), logsoftmax)
    )
)
```

