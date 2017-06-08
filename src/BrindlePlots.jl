#__precompile__()

module BrindlePlots

using Gadfly
using BufferedStreams
using Libz
using DataFrames

include("input.jl")
include("themes.jl")
include("draw.jl")

export BrindlePlot

end

