"""
Return all possible ngrams generated from sequence of items, as an Array{String,1}
# Example

>>>seq=["To","be","or","not"]
>>>a = everygram(seq,min_len = 1, max_len = -1)
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
   
"""
function everygram(seq; min_len::Int=1, max_len::Int=-1)
     ngram = []
    if max_len == -1
        max_len = length(seq)
    end
    for n in range(min_len, stop =max_len)
       temp = keys(TextAnalysis.ngramize(TextAnalysis.Languages.English(),seq,n))
       ngram = append!(ngram,temp)
   end
   return(ngram)
end

"""
   padding _ngram is used to pad both left and right of sentence and out putting ngrmas
   
   It also pad the original input Array of string 
# Example Usage
>>>example = ["1","2","3","4","5"]
      
>>> example = ["1","2","3","4","5"]
>>> padding_ngram(example ,2 , pad_left=true,pad_right =true)
    5-element Array{String,1}:
 "1"
 "2"
 "3"
 "4"
 "5"
"""
function padding_ngram(word,n =1 ;pad_left=false,pad_right=false ,left_pad_symbol="<s>", right_pad_symbol ="</s>")
    local seq
    seq = word
    if pad_left == true
        prepend!(seq, [left_pad_symbol])
    end 
    if pad_right == true
        push!(seq, right_pad_symbol)
    end
   return keys(TextAnalysis.ngramize(TextAnalysis.Languages.English(),seq,n))
end
