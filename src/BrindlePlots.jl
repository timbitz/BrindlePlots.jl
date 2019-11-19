__precompile__()

module BrindlePlots

using BufferedStreams
using CSV
using Compose
using DataFrames
using Distributions
using Gadfly
using GZip
using IntervalTrees
using Libz
using Measures

import Measures
import Gadfly

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
