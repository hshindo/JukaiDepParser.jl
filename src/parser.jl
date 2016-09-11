export Parser

type Parser
    worddict::IdDict{String}
    catdict::IdDict{String}
    model
end

function Parser()
    worddict = IdDict{String}()
    catdict = IdDict{String}()
    Parser(worddict, catdict, nothing)
end

function train(p::Parser)
    trainconll = CoNLL.read("C:/Users/hshindo/Dropbox/tagging/wsj_22-24.conll", 2, 5, 7)
    traindata::Vector{State} = map(trainconll) do sent
        map(sent) do x
            form0 = replace(x[1], r"[0-9]", '0') |> lowercase
            form = push!(p.worddict, form0)
            cat = push!(p.catdict, x[2])
            head = parse(Int, x[3])
            Token(form, cat, head)
        end
    end

    for epoch = 1:10
        for i = 1:length(traindata)
            map(x -> beamsearch(1, x), traindata)
        end
    end
end
