using Documenter, WebDAV

makedocs(;
         modules=[WebDAV],
         format=Documenter.HTML(),
         pages=[
             "index.md",
         ],
         repo="https://github.com/Alexander-Barth/WebDAV.jl/blob/{commit}{path}#L{line}",
         sitename="WebDAV",
         authors="Alexander Barth",
)

deploydocs(;
    repo="github.com/Alexander-Barth/WebDAV.jl",
)
