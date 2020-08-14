## loading model for pre-training i.e. we will not be loading pretrained weights from bson
using Flux
const config = Dict(
  "hidden_act"                   => gelu,
  "embedding"                    => 128,
  "num_hidden_layers"            => 12,
  "inner_group_num"              => 1,
  "num_hidden_groups"            => 1,
  "attention_probs_dropout_prob" => 0,
  "hidden_size"                  => 768,
  "max_position_embeddings"      => 512,
  "hidden_dropout_prob"          => 0,
  "type_vocab_size"              => 2,
  "vocab_size"                   => 30000, #albert use same size of vocab file
  "num_attention_heads"          => 12,
  "intermediate_size"            => 3072,
)

#creating albert model like pretrain struct
#you can define the albert model in the way you like and wrap it with TransformerModel

function create_albert(emb=config["embedding"], size=config["hidden_size"], head=config["num_attention_heads"], ps=config["intermediate_size"], layer= config["num_hidden_layers"], inner_group=config["inner_group_num"], no_hidden_group=config["num_hidden_groups"]; act=Flux.gelu, pdrop =config["hidden_dropout_prob"], attn_pdrop = config["attention_probs_dropout_prob"],vocab_size=config["vocab_size"], type_vocab_size=config["type_vocab_size"], max_position_embeddings= config["max_position_embeddings"]
                       )
    albert = albert_transformer(
        emb,
        size,
        head,
        ps,
        layer,
        inner_group,
        no_hidden_group
    )
#Dict to hold Token type Embedding 
#for Embed refer transformers

  tok_emb = Embed(
    emb,
    vocab_size
  )

  seg_emb = Embed(
    emb,
    type_vocab_size
  )

  posi_emb = PositionEmbedding(
    emb,
    max_position_embeddings;
    trainable = true
  )

  emb_post = Positionwise(
    LayerNorm(
      emb
    ),
        Dropout(
            pdrop
        )
  )

  pooler = Dense(
    size,
    size,
    tanh
  )

  masklm = (
    transform = Chain(
      Dense(
        emb,
        size,
        act
      ),
      LayerNorm(
        emb
      )
    ),
    output_bias = param(randn(
      Float32,
      vocab_size
    ))
  )

  nextsentence = Chain(
    Dense(
      size,
      2
    ),
    logsoftmax
  )

  emb = CompositeEmbedding(tok = tok_emb, pe = posi_emb, segment = seg_emb, postprocessor = emb_post)


  clf = (pooler = pooler, masklm = masklm, nextsentence = nextsentence)

  TransformerModel(emb, albert, clf)
end
