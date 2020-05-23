using DataStructures
import DataStructures.Accumulator
import DataStructures.DefaultDict
import DataStructures.counter

function normalize(accum)
    #sum all counts
    s = float(sum(accum))
    #tuple of string with each count divided by sum
    [(history,float(sum(count))/s) for (history,count) in accum]
end

function counter1(data, min::Integer, max::Integer,norm::Function;gamma = nothing)
    data = (everygram(data,min_len = min, max_len =max ))
    data = split.(data)
    temp_lm = DefaultDict{SubString{String}, Accumulator{String,Int64}}(counter(SubString{String}))
    for i in 1:length(data)
        history,word = data[i][1:end-1], data[i][end]
        temp_lm[join(history, " ")][word] += 1
    end
  #return Dict from iterated temp_lm with normalized histories
  Dict(histories => norm(word,gamma) for (histories,word) in temp_lm)
    #return temp_lm
end

function normalize(accum,gamma)
  #sum all counts
  s = float(sum(accum))
  #tuple of string with each count divided by sum
  [(word,float(sum(count))/s) for (word,count) in accum]
end
function lid_norm(accum,gamma)
      s = float(sum(accum)+(gamma)*length(accum)) 
      [(word,float(count + gamma)/s) for (word,count) in accum]

end
