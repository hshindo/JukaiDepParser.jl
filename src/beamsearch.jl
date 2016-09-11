immutable Node{T}
    state::T
    score::Float64
    prev::Node{T}

    (::Type{Node}){T}(state::T) = new{T}(state, 0.0)
    (::Type{Node}){T}(state::T, score, prev) = new{T}(state, score, prev)
end

lessthan{T}(x::Node{T}, y::Node{T}) = x.score > y.score

"""
* next(state::T) -> T[], Int
* scorefun: (state::T) -> Float64
"""
function aaa{T}(beamsize::Int, initstate::T, target::Vector{Int})
    k = 1
    while k <= length(chart)
        beam = chart[k]
        length(beam) > beamsize && sort!(beam, lt=lessthan)
        for i = 1:beamsize
            prev = beam[i]
            nexts = next(prev)
            t = nexts[k]
            for s in nexts
                push!(chart[l], Node(st,0.0,prev))
            end
        end
    end
end

function beamsearch{T}(beamsize::Int, initstate::T, scorefun)
    chart = Vector{Node{T}}[]
    push!(chart, [Node(initstate,0.0)])
    k = 1
    while k <= length(chart)
        beam = chart[k]
        length(beam) > beamsize && sort!(beam, lt=lessthan)
        for i = 1:beamsize
            i > length(beam) && break
            prev = beam[i]
            for (st::T,l::Int) in next(prev,k)
                while l > length(chart)
                    push!(chart, Node{T}[])
                end
                push!(chart[l], Node(st,0.0,prev))
            end
        end
        k += 1
    end
    sort!(chart[end], lt=lessthan)
    chart
end

function seq{T}(node::Node{T})
    nodes = Node{T}[]
    n = node
    while true
        unshift!(nodes, n)
        isdefined(n, :prev) || break
        n = n.prev
    end
    unshift!(nodes, n)
    nodes
end

"""
* y: correct
* z: predicted
"""
function early(y::Node{T}, z::Node{T})

end

function maxviolation!{T}(y::Node{T}, z::Node{T})
    maxyz, maxv = (y,z), -1.0
    while true
        v = z.score - y.score
        if v > maxv
            maxv = v
            maxyz = (y,z)
        end
        isdefined(y, :prev) || break
        y = y.prev
        z = z.prev
    end
end

function max_violation!{T}(gold::T, pred::T, train_gold, train_pred)
    goldseq, predseq = to_seq(gold), to_seq(pred)
    maxk, maxv = 1, 0.0
    for k = 1:length(goldseq)
        v = predseq[k].score - goldseq[k].score
        if k == 1 || v >= maxv
            maxk = k
            maxv = v
        end
    end
    for k = 2:maxk
        train_gold(goldseq[k])
        train_pred(predseq[k])
    end
end
