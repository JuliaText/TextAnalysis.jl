using DataStructures

"""
$(TYPEDSIGNATURES)

counter is used to make conditional distribution, which is used by score functions to 
calculate conditional frequency distribution
"""
function counter2(data, min::Integer, max::Integer)
    data = everygram(data, min_len=min, max_len=max)
    data = split.(data)
    temp_lm = DefaultDict{SubString{String},Accumulator{String,Int64}}(counter(SubString{String}))
    for i in eachindex(data)
        history, word = data[i][begin:end-1], data[i][end]
        temp_lm[join(history, " ")][word] += 1
    end
    return temp_lm
end
