__precompile__()

module BrindlePlots

using Compose
using Gadfly
using BufferedStreams
using Libz
using DataFrames
using Distributions
using Measures
using IntervalTrees

importall Measures
importall Gadfly

include("types.jl")
include("gel.jl")
include("input.jl")
include("themes.jl")
include("draw.jl")
include("plots.jl")

export make_plots,
       open_stream,
       load_tables,
       fixpath

end

