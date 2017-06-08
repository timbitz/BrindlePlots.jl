
using Base.Test
using BufferedStreams
using Libz
using DataFrames
using Gadfly

include("../src/input.jl")
include("../src/themes.jl")
include("../src/draw.jl")

@testset "Basic Single Plot" begin
end

samples = ["test.psi.gz", "test2.psi.gz"]
tabs = load_tables( samples )
xlab, layers = draw_events( tabs, samples, "ENSG00000117448.13_2", 10 )
plot_size(2)
plot(layers, xlab, Guide.ylabel(""), Guide.yticks(label=false), default_theme())
