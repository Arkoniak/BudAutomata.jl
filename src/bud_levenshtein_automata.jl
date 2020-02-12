##############################################################################
# This implementation is based on https://github.com/julesjacobs/levenshtein
# and related blog post of Jules Jacobs
# http://julesjacobs.github.io/2015/06/17/disqus-levenshtein-simple-and-fast.html
struct String32{N} <: AbstractString
    s::NTuple{N, Char}
end

function String32(s::S) where {S <: AbstractString}
    return String32(Tuple(s))
end

String32(s::String32) = s

Base.:length(s32::String32) = length(s32.s)
Base.:(==)(s1::String32, s2::String32) = s1.s == s2.s

function Base.:iterate(s32::String32, state::Integer = 1)
    state > length(s32.s) && return nothing
    return (s32.s[state], state + 1)
end

Base.:ncodeunits(s32::String32) = length(s32)
Base.:isvalid(s::String32, i::Integer) = true
Base.:getindex(s32::String32, i::Integer) = s32.s[i]

"""
    LevenshteinAutomaton(term::String, n::Int)

Construct automaton for given `term` and distance `n`.
"""
struct LevenshteinAutomaton
    term::String32
    n::Int
end

"""
    start

Returns the start state.
"""
start(LA) = MVector{length(LA.term) + 1}(collect(0:length(LA.term)))

"""
    step

Returns the next state given a `state` and a character `c`.
"""
function step(LA, state, c)
    new_state = similar(state)
    new_state[1] = state[1] + 1
    for i in 1:length(state) - 1
        cost = LA.term[i] == c ? 0 : 1
        new_state[i + 1] = min(new_state[i] + 1, state[i] + cost, state[i + 1] + 1)
    end

    # operation of making finite space
    for i in 1:length(new_state)
        new_state[i] = new_state[i] <= LA.n+1 ? new_state[i] : LA.n+1
    end
    return new_state
end

"""
    is_match

Tells us whether a state is matching
"""
is_match(LA, state) = state[end] <= LA.n

"""
    can_match

tells us whether a `state` can become matching if we input more characters.
`can_match` is used to prune the search tree.

```julia
automaton = LevenshteinAutomaton("bannana", 1)

state0 = start(automaton)
state1 = step(automaton, state0, 'w')
can_amtch(automaton, state1) # `true`, 'w' can match "bannana" with distance 1
state2 = step(automaton, state1, 'o')
can_match(automaton, state2) # `false`, "wo" can't match "bannana" with distance 1
```
"""
can_match(LA, state) = minimum(state) <= LA.n

"""
    transitions

Computes the letters to try
"""
function transitions(LA, state)
    Set(c for (i, c) in enumerate(LA.term) if state[i] <= LA.n)
end

"""
    explore

Generates graph of all possible states and transitions. This graph can be later converted
to DFA.
"""
function explore!(LA, state = start(LA), states = Dict{MVector{length(state)}, Int}(),
        matching = Int[], vtrans = Tuple{Int, Int, Char}[])
    haskey(states, state) && return states[state], states, matching, vtrans
    i = length(states)
    states[state] = i + 1
    is_match(LA, state) && push!(matching, i)
    for c in union(transitions(LA, state), Set(['*']))
        newstate = step(LA, state, c)
        j, _, _, _ = explore!(LA, newstate, states, matching, vtrans)
        push!(vtrans, (i, j, c))
    end

    return i, states, matching, vtrans
end
