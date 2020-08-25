
## ALBERT
 The success of ALBERT demonstrates the importance of identifying the aspects of a model that give rise to powerful contextual representations. By focusing improvement efforts on these aspects of the model architecture, it is possible to greatly improve both the model efficiency and performance on a wide range of NLP tasks

Get the IPYNB - [here](https://github.com/tejasvaidhyadev/ALBERT.jl/blob/master/docs/Pretraining_Tutorial(ALBERT).ipynb)

## Pretraining
In this tutorial we are going to pre-train our albert model

Inspired by https://nextjournal.com/chengchingwen/jsoc-2019-blog3end-of-phase-two-bert-model-in-julia

## Julia- Flux ALBERT 
It very easy and similar to any of the other Flux layer for training 


```julia
using TextAnalysis
```

~ *ignore all the warning as TextAnalysis is checked out for developement*


```julia
using TextAnalysis.ALBERT # it is where our model reside
```

#### we are going to use DataDeps for handling download of pretrained model of ALBERT
- For now we are directly laoding 
- other pretrained Weights can be found [here](https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz)


```julia
using WordTokenizers
using Random
```

loading spm tokenizer for albert


```julia
spm = load(ALBERT_V1)
```

**Output**


    WordTokenizers.SentencePieceModel(Dict("▁shots" => (-11.2373, 7281),"▁ordered" => (-9.84973, 1906),"▁doubtful" => (-12.7799, 22569),"▁glancing" => (-11.6676, 10426),"▁disrespect" => (-13.13, 26682),"▁without" => (-8.34227, 367),"▁pol" => (-10.7694, 4828),"chem" => (-12.3713, 17661),"▁1947," => (-11.7544, 11199),"▁kw" => (-10.4402, 3511)…), 2)



`masksentence` - API to preprocess input text by appling mask for MLM task


```julia
function masksentence(words,
                      spm;
                      mask_token = "[MASK]",
                      mask_ratio = 0.15,
                      real_token_ratio = 0.1,
                      random_token_ratio = 0.1)

tokens = spm(words)
masked_idx = randsubseq(1:length(tokens), mask_ratio)

masked_tokens = copy(tokens)

  for idx ∈ masked_idx
    r = rand()
    if r <= random_token_ratio
      masked_tokens[idx] = rand(keys(spm.vocab_map))
    elseif r > real_token_ratio + random_token_ratio
      masked_tokens[idx] = mask_token
    end
  end

  return masked_tokens, tokens, masked_idx
end
```

**Output** 


    masksentence (generic function with 1 method)
Lets check the example 

```julia
masksentence("i love julia language",spm;
                      mask_token = "[MASK]",
                      mask_ratio = 0.15,
                      real_token_ratio = 0.1,
                      random_token_ratio = 0.1)
```

**Output** 


    (["▁i", "▁love", "▁julia", "▁language"], ["▁i", "▁love", "▁julia", "▁language"], Int64[])


We will be using Tokenizer from WordTokenizers

```julia
using Random
using WordTokenizers

albert_pretrain_task(sentences,
                       spm,
                       sentences_pool = sentences;
                       channel_size = 100,
                       kwargs...
                       )
API for pretraining

function albert_pretrain_task(sentences,
                       spm,
                       sentences_pool = sentences;
                       channel_size = 100,
                       kwargs...
                       )
  chn = Channel(channel_size)
  task = @async albert_pretrain_task(chn, sentences, wordpiece, sentences_pool; kwargs...)
  bind(chn, task)
  chn
end
```

**Output**


    albert_pretrain_task (generic function with 6 methods)


```julia
function albert_pretrain_task(chn::Channel,
                       sentences,
                       spm,
                       sentences_pool = sentences;
                       start_token = "[CLS]",
                       sep_token = "[SEP]",
                       mask_token = "[MASK]",
                       mask_ratio = 0.15,
                       real_token_ratio = 0.1,
                       random_token_ratio = 0.1,
                       whole_word_mask = false,
                       next_sentence_ratio = 0.5,
                       next_sentence = true,
                       return_real_sentence = false)

  foreach(enumerate(sentences)) do (i, sentence)
    sentenceA = masksentence(
      sentence,
      spm;
      mask_token = mask_token,
      mask_ratio = mask_ratio,
      real_token_ratio = real_token_ratio,
      random_token_ratio = random_token_ratio)
    sentenceB = masksentence(
        sentences[i+1],
        spm;
        mask_token = mask_token,
        mask_ratio = mask_ratio,
        real_token_ratio = real_token_ratio,
        random_token_ratio = random_token_ratio)

    if next_sentence
      if rand() <= next_sentence_ratio && i != length(sentences)
        isnext = true
      else
        temp = sentenceB
        sentenceB = sentenceA
        sentenceA = temp
        isnext = false
      end

      masked_sentence = _wrap_sentence(sentenceA[1],
                                       sentenceB[1];
                                       start_token = start_token,
                                       sep_token = sep_token)

      sentence = _wrap_sentence(sentenceA[2],
                                sentenceB[2];
                                start_token = start_token,
                                sep_token = sep_token) #implemented below

      mask_idx = _wrap_idx(sentenceA[3],
                           sentenceB[3],
                           length(sentenceA[1])) #implemented below
    else
      masked_sentence = _wrap_sentence(sentenceA[1];
                                       start_token = start_token,
                                       sep_token = sep_token)

      sentence = _wrap_sentence(sentenceA[2];
                                start_token = start_token,
                                sep_token = sep_token)

      mask_idx = _wrap_idx(sentenceA[3])
    end

    masked_token = sentence[mask_idx]

    if return_real_sentence
      if next_sentence
        put!(chn, (masked_sentence, mask_idx, masked_token, isnext, sentence))
      else
        put!(chn, (masked_sentence, mask_idx, masked_token, sentence))
      end
    else
      if next_sentence
        put!(chn, (masked_sentence, mask_idx, masked_token, isnext))
      else
        put!(chn, (masked_sentence, mask_idx, masked_token))
      end
    end
  end
end

```

**Output**


    albert_pretrain_task (generic function with 6 methods)
Some helper function

```julia
function _wrap_sentence(sentence1, sentence2...; start_token = "[CLS]", sep_token = "[SEP]")
  pushfirst!(sentence1, start_token)
  push!(sentence1, sep_token)
  map(s->push!(s, sep_token), sentence2)
  vcat(sentence1, sentence2...)
end

_wrap_idx(sentence1_idx, pre_len = 1) = sentence1_idx .+= pre_len
function _wrap_idx(sentence1_idx, sentence2_idx, len1)
  _wrap_idx(sentence1_idx)
  _wrap_idx(sentence2_idx, len1)
  vcat(sentence1_idx, sentence2_idx)
end
```

**Output**


    _wrap_idx (generic function with 3 methods)


```julia
function albert_pretrain_task(outchn::Channel,
                       datachn::Channel,
                       spm;
                       buffer_size = 100,
                       kwargs...
                       )
  task = @async begin
    buffer = Vector(undef, buffer_size)
    while isopen(datachn)
      i = 1
      eod = false
      while i <= buffer_size
        try
          sentence = take!(datachn)
          if isempty(sentence)
            continue
          else
            buffer[i] = sentence
            i+=1
          end
        catch e
          if isa(e, InvalidStateException) && e.state==:closed
            eod = true
            break
          else
            rethrow()
          end
        end
      end

      i -= 1

      if eod || i == buffer_size
        albert_pretrain_task(outchn, @view(buffer[1:(eod ? i - 1 : i)]), spm; kwargs...)
      end
    end
  end
  bind(outchn, task)
end

```

**Output** 


    albert_pretrain_task (generic function with 6 methods



```julia
function albert_pretrain_task(datachn::Channel,
                       spm;
                       buffer_size = 100,
                       channel_size = 100,
                       kwargs...
                       )
  outchn = Channel(channel_size)
  bert_pretrain_task(outchn, datachn, spm; buffer_size = buffer_size, kwargs...)
  outchn
end
```

**Output**


    albert_pretrain_task (generic function with 6 methods)


### Test Corpus

```julia
# one document from wiki dump, just for illustration
docs = """
Guy Fawkes (; 13 April 1570�罱�� 31 January 1606), also known as Guido Fawkes while fighting for the Spanish, was a member of a group of provincial English Catholics who planned the failed Gunpowder Plot of 1605. He was born and educated in York, England; his father died when Fawkes was eight years old, after which his mother married a recusant Catholic.

Fawkes converted to Catholicism and left for mainland Europe, where he fought for Catholic Spain in the Eighty Years' War against Protestant Dutch reformers in the Low Countries. He travelled to Spain to seek support for a Catholic rebellion in England without success. He later met Thomas Wintour, with whom he returned to England, and Wintour introduced him to Robert Catesby, who planned to assassinate and restore a Catholic monarch to the throne. The plotters leased an undercroft beneath the House of Lords, and Fawkes was placed in charge of the gunpowder which they stockpiled there. The authorities were prompted by an anonymous letter to search Westminster Palace during the early hours of 5 November, and they found Fawkes guarding the explosives. He was questioned and tortured over the next few days, and he finally confessed.

Immediately before his execution on 31 January, Fawkes fell from the scaffold where he was to be hanged and broke his neck, thus avoiding the agony of being hanged, drawn and quartered. He became synonymous with the Gunpowder Plot, the failure of which has been commemorated in Britain as Guy Fawkes Night since 5 November 1605, when his effigy is traditionally burned on a bonfire, commonly accompanied by fireworks.

Guy Fawkes was born in 1570 in Stonegate, York. He was the second of four children born to Edward Fawkes, a proctor and an advocate of the consistory court at York, and his wife, Edith. Guy's parents were regular communicants of the Church of England, as were his paternal grandparents; his grandmother, born Ellen Harrington, was the daughter of a prominent merchant, who served as Lord Mayor of York in 1536. Guy's mother's family were recusant Catholics, and his cousin, Richard Cowling, became a Jesuit priest. "Guy" was an uncommon name in England, but may have been popular in York on account of a local notable, Sir Guy Fairfax of Steeton.

The date of Fawkes's birth is unknown, but he was baptised in the church of St Michael le Belfrey on 16 April. As the customary gap between birth and baptism was three days, he was probably born about 13 April. In 1568, Edith had given birth to a daughter named Anne, but the child died aged about seven weeks, in November that year. She bore two more children after Guy: Anne (b. 1572), and Elizabeth (b. 1575). Both were married, in 1599 and 1594 respectively.

In 1579, when Guy was eight years old, his father died. His mother remarried several years later, to the Catholic Dionis Baynbrigge (or Denis Bainbridge) of Scotton, Harrogate. Fawkes may have become a Catholic through the Baynbrigge family's recusant tendencies, and also the Catholic branches of the Pulleyn and Percy families of Scotton, but also from his time at St. Peter's School in York. A governor of the school had spent about 20�懢ears in prison for recusancy, and its headmaster, John Pulleyn, came from a family of noted Yorkshire recusants, the Pulleyns of Blubberhouses. In her 1915 work "The Pulleynes of Yorkshire", author Catharine Pullein suggested that Fawkes's Catholic education came from his Harrington relatives, who were known for harbouring priests, one of whom later accompanied Fawkes to Flanders in 1592��1593. Fawkes's fellow students included John Wright and his brother Christopher (both later involved with Fawkes in the Gunpowder Plot) and Oswald Tesimond, Edward Oldcorne and Robert Middleton, who became priests (the latter executed in 1601).
"""
```

**Output**


    "Guy Fawkes (; 13 April 1570�罱�� 31 January 1606), also known as Guido Fawkes while fighting for the Spanish, was a member of a group of provincial English Catholics who planned the failed Gunpowder Plot of 1605. He was born and educated in York, England; his father died when Fawkes was eight years old, after which his mother married a recusant Catholic.\n\nFawkes converted to Catholicism and left for mainland Europe, where he fought for Catholic Spain in the Eighty Years' War against Protestant Dutch reformers in the Low Countries. He travelled to Spain to seek support for a Catholic rebellion in England without success. He later met Thomas Wintour, with whom he returned to England, and Wintour introduced him to Robert Catesby, who planned to assassinate and restore a Catholic monarch to the throne. The plotters leased an undercroft beneath the House of Lords, and Fawkes was placed in charge of the gunpowder which they stockpiled there. The authorities were prompted by an anonymous letter to search Westminster Palace during the early hours of 5 November, and they found Fawkes guarding the explosives. He was questioned and tortured over the next few days, and he finally confessed.\n\nImmediately before his execution on 31 January, Fawkes fell from the scaffold where he was to be hanged and broke his neck, thus avoiding the agony of being hanged, drawn and quartered. He became synonymous with the Gunpowder Plot, the failure of which has been commemorated in Britain as Guy Fawkes Night since 5 November 1605, when his effigy is traditionally burned on a bonfire, commonly accompanied by fireworks.\n\nGuy Fawkes was born in 1570 in Stonegate, York. He was the second of four children born to Edward Fawkes, a proctor and an advocate of the consistory court at York, and his wife, Edith. Guy's parents were regular communicants of the Church of England, as were his paternal grandparents; his grandmother, born Ellen Harrington, was the daughter of a prominent merchant, who served as Lord Mayor of York in 1536. Guy's mother's family were recusant Catholics, and his cousin, Richard Cowling, became a Jesuit priest. \"Guy\" was an uncommon name in England, but may have been popular in York on account of a local notable, Sir Guy Fairfax of Steeton.\n\nThe date of Fawkes's birth is unknown, but he was baptised in the church of St Michael le Belfrey on 16 April. As the customary gap between birth and baptism was three days, he was probably born about 13 April. In 1568, Edith had given birth to a daughter named Anne, but the child died aged about seven weeks, in November that year. She bore two more children after Guy: Anne (b. 1572), and Elizabeth (b. 1575). Both were married, in 1599 and 1594 respectively.\n\nIn 1579, when Guy was eight years old, his father died. His mother remarried several years later, to the Catholic Dionis Baynbrigge (or Denis Bainbridge) of Scotton, Harrogate. Fawkes may have become a Catholic through the Baynbrigge family's recusant tendencies, and also the Catholic branches of the Pulleyn and Percy families of Scotton, but also from his time at St. Peter's School in York. A governor of the school had spent about 20�懢ears in prison for recusancy, and its headmaster, John Pulleyn, came from a family of noted Yorkshire recusants, the Pulleyns of Blubberhouses. In her 1915 work \"The Pulleynes of Yorkshire\", author Catharine Pullein suggested that Fawkes's Catholic education came from his Harrington relatives, who were known for harbouring priests, one of whom later accompanied Fawkes to Flanders in 1592��1593. Fawkes's fellow students included John Wright and his brother Christopher (both later involved with Fawkes in the Gunpowder Plot) and Oswald Tesimond, Edward Oldcorne and Robert Middleton, who became priests (the latter executed in 1601).\n"


**Lets Pretrain the model**

```julia
using WordTokenizers

chn = Channel(3)

sentences = split_sentences(docs)
task = @async foreach(sentences) do sentence
  if !isempty(sentence)
    put!(chn, sentence)
  end
end
bind(chn, task)
```

**Output** 


    Channel{Any}(sz_max:3,sz_curr:3)


Lets check our `albert_pretrain_task`


```julia
using Transformers.Basic
using Transformers
```


```julia
datas = albert_pretrain_task(chn, spm)
batch = get_batch(datas ,1)
```

**Output**


    4-element Array{Array{T,1} where T,1}:
     [["[CLS]", "▁", "H", "[MASK]", "▁was", "[MASK]", "▁and", "▁tortured", "▁over", "▁the"  …  "▁found", "▁", "F", "aw", "kes", "▁guarding", "▁the", "[MASK]", ".", "[SEP]"]]
     [[4, 6, 14, 23, 24, 30, 41, 58, 61]]
     [["e", "▁questioned", ",", "he", "▁authorities", "▁letter", "▁during", "kes", "▁explosives"]]
     Bool[0]



Seems like it is working fine 


```julia
masked_sentence, mask_idx, masked_token, isnext = get_batch(datas, 1)
```

**Output** 


    4-element Array{Array{T,1} where T,1}:
     [["[CLS]", "▁", "H", "e", "▁was", "▁questioned", "▁and", "▁tortured", "▁over", "▁the"  …  "▁being", "▁hanged", ",", "▁drawn", "▁and", "▁qu", "arte", "red", ".", "[SEP]"]]
     [[9, 19, 25, 31, 38, 46, 55, 58]]
     [["▁over", ".", "ate", "▁31", "F", "▁he", ",", "▁the"]]
     Bool[1]



We will be using following libary as shown below


```julia
using TextAnalysis.ALBERT
using Transformers.Basic
vocab = keys(spm.vocab_map)
```

**Output** 


    Base.KeySet for a Dict{String,Tuple{Float64,Int64}} with 30000 entries. Keys:
      "▁shots"
      "▁ordered"
      "▁doubtful"
      "▁glancing"
      "▁disrespect"
      "▁without"
      "▁pol"
      "chem"
      "▁1947,"
      "▁kw"
      "▁calcutta"
      "mh"
      "▁rumors"
      "▁maharaja"
      "▁125"
      "▁xanth"
      "rha"
      "▁pound"
      "lunk"
      "▁spaniards"
      "▁ulcer"
      "henry"
      "228"
      "izes"
      "▁assist"
      ⋮



### lets define embedding layers
The Embed is similar to nn.model in pytorch and is already implemented in Transformers


```julia
emb = CompositeEmbedding(
  tok = Embed(300, length(vocab)),
  pe = PositionEmbedding(300, 512; trainable=false),
  seg = Embed(300, 2)
)

```

**Output**


```julia
CompositeEmbedding(tok = Embed(300), pe = PositionEmbedding(300), seg = Embed(300))
```


```julia
using Flux:onehotbatch
```

`TransformerModel` is structure to holding embedding, transformers and classifier 


```julia
albert = ALBERT.albert_transformer(300,300,12,512,3,1,1) # defining albert_trainformer 
masklm = Flux.Dense(300,300) # masklm classifier
nextsentence = Flux.Chain(Flux.Dense(300, 2), Flux.logsoftmax) # nextsentence classifiers

albert_model = TransformerModel(emb, albert, (mlm=masklm, ns = nextsentence)) #struture to hold everything
```

**Output**


    TransformerModel{TextAnalysis.ALBERT.albert_transformer}(
      embed = CompositeEmbedding(tok = Embed(300), pe = PositionEmbedding(300), seg = Embed(300)),
      transformers = albert(layers=3, head=12, head_size=25, pwffn_size=512, size=300),
      classifier = 
        (
          mlm => Dense(300, 300)
          ns => Chain(Dense(300, 2), logsoftmax)
        )
    )

or we can you use TextAnalysis.ALBERT.create_albert 

### Preprocess
`preprocess`- It will take care of proprocessing of text before moving it to model


```julia
function preprocess(training_batch)
    mask = getmask(training_batch[1])
    tok = [(ids_from_tokens(spm,i)) for i in training_batch[1]]
    tok = Flux.batchseq(tok,1)
    tok = Flux.stack(tok,1)
    segment = fill!(similar(tok), 1.0)
    length(tok) #output embedding matrix
     for (i, sentence) ∈ enumerate(training_batch[1])
    j = findfirst(isequal("[SEP]"), sentence)
    if j !== nothing
      @view(segment[j+1:end, i]) .= 2.0
    end
  end
    
    ind = vcat(
    map(enumerate(batch[2])) do (i, x)
     map(j->(j,i), x)
    end...)

  masklabel = onehotbatch(ids_from_tokens(spm , vcat(batch[3]...)), 1:length(spm.vocab_map))
  nextlabel = onehotbatch(batch[4], (true, false))
return (tok=tok, seg=segment), ind, masklabel, nextlabel, mask
end

function loss(data, ind, masklabel, nextlabel, mask = nothing)
  e = albert_model.embed(data)
  t = albert_model.transformers(e, mask)
  nextloss = Basic.logcrossentropy(
    nextlabel,
    albert_model.classifier.ns(
      t[:,1,:]
    )
  )
  mkloss = masklmloss(albert_model.embed.embeddings.tok, # embedding table for compute similarity
                      albert_model.classifier.mlm, # transform function on output embedding
                      t, # output embeddings
                      ind, # mask index
                      masklabel #masked token
                      )
  return nextloss + mkloss
end
    
ps = Flux.params(albert)
opt = Flux.ADAM(1e-4)
```

**Output**


    Flux.Optimise.ADAM(0.0001, (0.9, 0.999), IdDict{Any,Any}())


### Lets get the datas

```julia
datas = albert_pretrain_task(chn, spm)
```

**Output**


    Channel{Any}(sz_max:100,sz_curr:0)



lets analysis the loss by running 10 epochs


```julia
for i ∈ 1:10 # run 10 step for illustration
  batch = get_batch(datas, 2)
  batch === nothing && break # out of data
  data, ind, masklabel, nextlabel, mask = todevice(preprocess(batch))
  l = loss(data, ind, masklabel, nextlabel, mask)
  @show l
  grad = Flux.gradient(()->loss(data, ind, masklabel, nextlabel, mask), ps)
  Flux.update!(opt, ps, grad)
end
```

    l = 72.28404f0
    l = 73.165596f0
    l = 56.124104f0
    l = 50.31461f0
    l = 51.023262f0
    l = 49.547054f0
    l = 43.89146f0
    l = 38.276382f0
    l = 48.87205f0
    l = 33.408596f0


### Conclusion
As expected loss is converging for our model 
