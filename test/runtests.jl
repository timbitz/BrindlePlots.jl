
using Base.Test
using BufferedStreams
using Libz
using DataFrames
using Measures
using Cairo
using Compose
using Gadfly

include("../src/types.jl")
include("../src/input.jl")
include("../src/themes.jl")
include("../src/draw.jl")
include("../src/plots.jl")

@testset "Basic Single Plot" begin
   delta = BufferedInputStream(IOBuffer("Gene\tNode\tBlank\nENSG00000117448.13_2\t10\tblank\n"))
   samples = ["test.psi.gz", "test2.psi.gz"]
   tabs = load_tables( samples )
   @test make_plots( delta, tabs, samples, "testplot" ) == true 
end
