using Documenter, BudAutomata

makedocs(;
    modules=[BudAutomata],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/Arkoniak/BudAutomata.jl/blob/{commit}{path}#L{line}",
    sitename="BudAutomata.jl",
    authors="Andrey Oskin",
    assets=String[],
)

deploydocs(;
    repo="github.com/Arkoniak/BudAutomata.jl",
)
