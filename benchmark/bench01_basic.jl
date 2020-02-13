module BenchBasic
using BenchmarkTools
using BudAutomata: LevenshteinAutomaton, build_dfa

suite = BenchmarkGroup()

lev = LevenshteinAutomaton("woof", 1)
suite["woof_1"] = @benchmarkable build_dfa($lev)

lev = LevenshteinAutomaton("woof", 2)
suite["woof_2"] = @benchmarkable build_dfa($lev)

lev = LevenshteinAutomaton("banana", 1)
suite["banana_1"] = @benchmarkable build_dfa($lev)

end # module

BenchBasic.suite
