using DataStructures
import DataStructures.Accumulator
import DataStructures.DefaultDict
import DataStructures.counter

"""
    counter is used to make conditional distribution, which is used by score functions to 
    calculate conditonal frequency distribution
"""
function counter2(data, min::Integer, max::Integer)
    data = everygram(data, min_len=min, max_len=max)
    data = split.(data)
    temp_lm = DefaultDict{SubString{String}, Accumulator{String,Int64}}(counter(SubString{String}))
    for i in 1:length(data)
        history,word = data[i][1:end-1], data[i][end]
        temp_lm[join(history, " ")][word] += 1
    end
    return temp_lm
end

