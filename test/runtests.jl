
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

tabs = load_tables( ["test.psi.gz", "test2.psi.gz"] )
layers = draw_events( tabs, "ENSG00000117448.13_2", 10 )
plot(layers)
