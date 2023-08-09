using Documenter
using MySecDoc

makedocs(
    sitename = "MySecDoc",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [MySecDoc],
    pages = ["index.md", 
    "other.md"]
)

deploydocs(
    repo = "github.com/lmaillere/MySecDoc.jl.git",
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
