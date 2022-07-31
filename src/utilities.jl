using Printf
using Unicode

mutable struct ProgressBar
    value::Int
    target::Int
    interval::Float64
end

clear_line(io::IO=stdout) = print(io, "\e[2K")
move_cursor_up_one_line(io::IO=stdout) = print(io, "\e[1G")

function(progress_bar::ProgressBar)(idx::Int)
    if (idx < progress_bar.value)
        return
    end
    clear_line()
    move_cursor_up_one_line()
    frac = min(floor(Int, idx / progress_bar.target * 100), 100)
    print(repeat("=", frac), repeat(" ", 100 - frac))
    @printf(" %.2f%% ... ", frac)
    increment = progress_bar.interval * progress_bar.target
    progress_bar.value = floor(Int, (floor(Int, idx/increment) + 1) * increment)
    progress_bar.value = min(progress_bar.value, progress_bar.target)
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



