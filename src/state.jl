const Shift = 1
const ReduceL = 2
const ReduceR = 3

type State
    tokens::Vector{Token}
    step::Int
    top::Int
    l::State
    r::Int
    lc::State
    rc::State

    State() = new()
    State(tokens) = new(tokens, 1, 1, State(), 2, State(), State())
    State(tokens, step, top, l, r, lc, rc) = new(tokens, step, top, l, r, lc, rc)
end

left(s::State) = isdefined(s, :tokens) ? s.l : nothing

Base.isvalid(s::State) = isdefined(s, :tokens)
Base.done(s::State) = s.step >= length(s.tokens) * 2
Base.length(s::State) = s.step

function Base.next(st::State, act::Int)
    if act == Shift
        State(st.tokens, st.step+1, st.r, st, st.r+1, State(), State())
    elseif act == ReduceL
        State(st.tokens, st.step+1, st.top, st.l.l, st.r, st.l, st.rc)
    elseif act == ReduceR
        State(st.tokens, st.step+1, st.l.top, st.l.l, st.r, st.l.lc, st)
    else
        throw("Invalid action: $(act)")
    end
end

function Base.next(st::State)
    tokens = st.tokens
    nexts = Tuple{State,Int}[]
    if tokens[1].head < 0
        st.r <= length(st.tokens) && push!(nexts, next(st,Shift))
        isvalid(st.l) && push!(nexts, next(st,ReduceL), next(st,ReduceR))
        nexts
    else
        if isvalid(st.l)
            s0, s1 = tokens[st.top], tokens[st.l.top]
            if s1.head == st.top
                act = ReduceL
            elseif s0.head == st.l.top
                reducable = all(i -> tokens[i].head != st.top, st.r:length(tokens))
                act = reducable ? ReduceR : Shift
            elseif st.r <= length(tokens)
                act = Shift
            else
                throw("Invalid")
            end
        else
            act = Shift
        end
        [next(st,act)]
    end
end
