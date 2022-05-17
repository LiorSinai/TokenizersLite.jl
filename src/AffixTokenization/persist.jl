function load_affix_tokenizer(path::AbstractString)
    tokenizer = AffixTokenizer()
    open(path, "r") do file
        for line in eachline(file)
            if startswith(line, '-')
                push!(tokenizer.suffixes, line[2:end])
            elseif endswith(line, '-')
                push!(tokenizer.prefixes, line[1:end-1])
            else
                push!(tokenizer.vocab, line)
            end
        end
    end
    tokenizer
end

