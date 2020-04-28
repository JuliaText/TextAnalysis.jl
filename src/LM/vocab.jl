""" General counter to used in vocabulary"""
mutable struct Counter
    value::Int
    #Counter(value) = (new(),value)
end

function counter(init = 0) 
    Counter(init)
end
function (count::Counter)()
    count.value = 1 +count.value
end

"""Stores language model vocabulary.
    Satisfies two common language modeling requirements for a vocabulary:
    - When checking membership and calculating its size, filters items
      by comparing their counts to a cutoff value.
    - Adds a special "unknown" token which unseen words are mapped to.
    
    >>> words = ['a', 'c', '-', 'd', 'c', 'a', 'b', 'r', 'a', 'c', 'd']
    >>> import Vocabulary
    >>> vocabulary = Vocabulary(words, 2) 
    Vocabulary(Dict("<unk>"=>1,"c"=>3,"a"=>3,"d"=>2), 2, "<unk>") 
    >>> vocabulary.vocab
        Dict{String,Int64} with 4 entries:
      "<unk>" => 1
      "c"     => 3
      "a"     => 3
      "d"     => 2
    Tokens with counts greater than or equal to the cutoff value will
    be considered part of the vocabulary.
    >>> vocabulary.vocab["c"]
    3
    >>> "c" in keys(vocabulary.vocab)
    true
    >>> vocabulary.vocab["d"]
    2
    >>> "d" in keys(vocabulary.vocab)
    true
    Tokens with frequency counts less than the cutoff value will be considered not
    part of the vocabulary even though their entries in the count dictionary are
    preserved.
    >>> "b" in keys(vocabulary.vocab)
    false
    >>> "<unk>" in keys(vocabulary.vocab)
    true
    We can look up words in a vocabulary using its `lookup` method.
    "Unseen" words (with counts less than cutoff) are looked up as the unknown label.
    If given one word (a string) as an input, this method will return a string.
    >>> lookup("a")
    'a'
    >>> word = ["a", "-", "d", "c", "a"]
    >>> lookup(vocabulary ,word)
     5-element Array{Any,1}:
     "a"    
     "<unk>"
     "d"    
     "c"    
     "a"

    If given a sequence, it will return an Array{Any,1} of the looked up words as shown above.
   
    It's possible to update the counts after the vocabulary has been created.
    >>> update(vocabulary,["b","c","c"])
    1
    >>> vocabulary.vocab["b"]
    1
    """
mutable struct Vocabulary
vocab::Dict{String,Int64}
unk_cutoff::Int
unk_label::String
allword::Array{String,1}
end
function Vocabulary(word,unk_cutoff =1 ,unk_label = "<unk>") 
    if unk_label in word
        #error("unk_label is in vocab")
    else
    word= push!(word,unk_label)
    end
    vocab = countmap(word)
    for value in vocab
        if value[2]<unk_cutoff && value[1] != unk_label
            delete!(vocab,value[1])
        end
    end
    Vocabulary(vocab,unk_cutoff,unk_label,word)
end

function update(vocab::Vocabulary, words)
    vocab.allword = append!(vocab.allword,words)
    vocab.vocab=addcounts!(vocab.vocab,words)
end

"""
lookup a sequence or words in the vocabulary

Return an Array of String
"""
function lookup(voc::Vocabulary,word)
    look = []
    for w in word
         if w in keys(voc.vocab)
            push!(look,w) 
         else 
            #return vocab.unk_label
            push!(look,voc.unk_label) 
        end
    end
    return look
end



