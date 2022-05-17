using Printf
using Unicode

mutable struct Update
    value::Int
    target::Int
    interval::Float64
end

function(update::Update)(idx::Int)
    if (idx < update.value)
        return
    end
    print("\e[2K") # clear whole line
    print("\e[1G") # move cursor to column 1
    frac = min(floor(Int, idx / update.target * 100), 100)
    print(repeat("=", frac), repeat(" ", 100 - frac))
    @printf(" %.2f%% ... ", frac)
    increment = update.interval * update.target
    update.value = floor(Int, (floor(Int, idx/increment) + 1) * increment)
    update.value = min(update.value, update.target)
end

function load_word_counts(filepath)
    dict = Dict{String, Int}()
    open(filepath, "r") do file
        for line in eachline(file)
            word, count = split(line, " ")
            dict[word] = parse(Int, count)
        end
     end
    dict
end

function save_vocab(vocab::Dict, filepath::AbstractString)
    open(filepath, "w") do file
        for (word, value) in sort(collect(vocab), by=x->x[2], rev=true)
            println(file, "$word")
        end
    end
end

function load_vocab(filepath)
    vocab = String[]
    open(filepath, "r") do file
        for line in eachline(file)
            push!(vocab, line)
        end
    end
    vocab
end

function save_encodings(corpus::Dict, filepath::AbstractString)
    open(filepath, "w") do file 
        for (word, encoding) in sort(collect(corpus), by=x->x[1])
            println(file, "$word ", join(encoding.tokens, " "), " ", encoding.frequency)
        end
    end
end



