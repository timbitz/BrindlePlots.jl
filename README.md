# BrindlePlots.jl 
[![Build Status](https://travis-ci.com/timbitz/BrindlePlots.jl.svg?token=R7mZheNGhsReQ7hn2gdf&branch=master)](https://travis-ci.com/timbitz/BrindlePlots.jl)

Visualization package for Whippet.jl

Clone and run dependencies.jl executable, then run `julia bin/brindle-plot.jl`

The basic usage requires a `.diff.gz` file from whippet-delta.jl (filtered for the significant events you want to plot) as well as all the `.psi.gz` files you gave to `whippet-delta.jl` in the first place to be supplied to `brindle-plot.jl` as `-a` and `-b` options similarly.
