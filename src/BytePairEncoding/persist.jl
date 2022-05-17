function load_bpe(
    path_rules::AbstractString;
    startsym="⋅",
    endsym=nothing,
    unksym="[UNK]"
    )
    bpe = BytePairEncoder(String[], startsym=startsym, endsym=endsym, unksym=unksym)
    load_symbols_and_rules!(bpe, path_rules)
    bpe
end

function load_symbols_and_rules!(bpe::BytePairEncoder{T}, filepath::AbstractString) where T
    open(filepath, "r") do file
        for line in eachline(file)
            tokens = split(line, " ")
            if length(tokens) == 1
                push!(bpe.symbols, tokens[1])
            else
                push!(bpe.rules, (tokens[1], tokens[2]))
            end
        end
    end 
end

function save_bpe(bpe::BytePairEncoder{T}, filepath::AbstractString, ) where T
    open(filepath, "w") do file
        for symbol in bpe.symbols
            println(file, "$symbol")
        end
        for pair in bpe.rules
            println(file, "$(pair[1]) $(pair[2])")
        end
    end
end

