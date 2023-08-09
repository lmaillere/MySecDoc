# Documentation creation with Julia

## static local documentation

inspired by [this tutorial]([Automated Documentation | Julia Tutorial](https://www.matecdev.com/posts/julia-documentation.html)).

- generate a dummy local project under the current repository from Julia REPL:

```julia
] generate MyFirstDoc
```

generates a module `MyFirstDoc` with a `Project.toml` file and a `src` subdirectory containing `MyFirstDoc.jl` which defines a function `greet()` printing `"Hello World!"`

- add some `Docstring` (help) in `MyFirstDoc.jl` (e.g. in VScode):

```julia
"This is a dummy module to illustrate documentation creation"
module MyFirstDoc

"""
    greet() 

prints "Hello World!" in julia REPL
"""
greet() = print("Hello World!")

end # module MyFirstDoc
```

- now, we will generate the documentation architecture from `Documenter.jl`. to do so we need to activate the module `MyFirstDoc`, and use it. From the same Julia REPL than above:

```julia
] activate MyFirstDoc
using MyFirstDoc
```

- from there, the REPL help works:

```julia
?MyFirstDoc
?MyFirstDoc.greet()
```

- the module needs to be in `development` mode to use the documentation architecture generator from `Documenter.jl`. Exit Julia REPL and restart:

```julia
] develop MyFirstDoc
using MyFirstDoc
```

REPL help works as before.

- now we generate the documentation architecture with `DocumenterTools` package.

```julia
using DocumenterTools
DocumenterTools.generate(MyFirstDoc)
```

this generates a `docs` subfolder in the module containing the following basic architecture files for documentation generation:

```julia
.gitignore
src/index.md
make.jl
mkdocs.yml
Project.toml
```

the `make.jl` file should be OK at this step (as other files). We only have to update `src/index.md` which is very basic at this stage. We modify the title and add the reference to the `Docstring` items defined in `MyFirstDoc.jl`. `src/index.md` is updated as:

```
# This is MyFirstDoc.jl Documentation

Documentation for MyFirstDoc.jl

```@docs
MyFirstDoc
MyFirstDoc.greet()
\```
```

- Finally we generate the documentation from the terminal in `MyFirstDoc/docs` directory:

```bash
julia make.jl
```

an html documentation page is built under `MyFirstDoc/docs/build/index.html`  and works fine.

- while pushing the whole module on github, it seems one cannot access this file through github-pages because it is under a subdirectory of `docs` which cannot be directly accessed with regular github-pages publications. 

`Documenter.jl` has a specific way of handling publication on github pages through a specific branch. Let's try it!

## github-pages documentation

- we re-initiate a correct architecture as above for `MySecDoc` module and follow roughly [`Documenters.jl` documentation]([Guide · Documenter.jl](https://documenter.juliadocs.org/dev/man/guide/)).

- This introduces the use of `@contents` and `@index`, and multipage documentation support.

- pay attention to "pretty url" feature which is not fine with local browsing (and so not fine for Documentation development). adding:

```julia
format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"),
```

as an option of the basic `makedocs` in `docs/make.jl` does the trick and should inherit the required link properties when put on github action. At least it is ok for local build of the documentation. (Edit: it works well on github-pages too)

- to publish through github-pages and github actions, first add a `.gitignore` file in the root of the module with:

```
docs/build/
```

- then add after the `makedocs()` in the `docs/make.jl` file:

```julia
deploydocs(
    repo = "github.com/LOGIN/MODULENAME.jl.git",
)
```

- and commit/push the directory to github



- the penultimate trick is to setup a github action workflow to generate the documentation on github server. to do so :
  
  - go to "Settings > Pages" on the github repository of the module
  
  - under "Build and development" choose "Github Actions" in the dropdown menu
  
  - add a custom worflow: a basic file proposal pops up, erase everything and paste

```yml
name: Documentation

on:
  push:
    branches:
      - main # update to match your development branch (master, main, dev, trunk, ...)
    tags: '*'
  pull_request:

jobs:
  build:
    permissions:
      contents: write
      statuses: write
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: julia-actions/setup-julia@v1
        with:
          version: '1.6'
      - name: Install dependencies
        run: julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
      - name: Build and deploy
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # If authenticating with GitHub Actions token
          DOCUMENTER_KEY: ${{ secrets.DOCUMENTER_KEY }} # If authenticating with SSH deploy key
        run: julia --project=docs/ docs/make.jl
```

save as `documentation.yml` in `.github/workflows` (which is the default location). From what I understand, the script will install julia on a virtual machine, and basically run `julia make.jl` to regenerate the documentation online in a separate branch named "gh-pages"

- wait for the script to complete (see in "Actions" on the repository github page)

- go back to "Settings > Pages" and publish the documentation through github pages  from branch `gh-pages` and root `/` .

- the magic with this is that any time you push to github, the scripts will fire and the Documentation will be automatically regenerated by github action and github pages!



An example of this setup can be found at this repository: [GitHub - lmaillere/MySecDoc](https://github.com/lmaillere/MySecDoc).


