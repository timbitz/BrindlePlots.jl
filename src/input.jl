#=  
  This should have a type for a gene, which is parsed from file,
    stores every node, and all the paths from .psi.gz files
=#

parse_complexity{S <: AbstractString}( c::S ) = split( c, COMPLEX_CHAR, keep=false )[1] |> x->parse(Int,x)

# OR we serialize whippet data for BrindlePlots.jl?
type WhippetNode
   incpaths::Vector{IntSet}
   excpaths::Vector{IntSet}
   first::Int #boundary nodes
   last::Int
end

type WhippetGene
   nodes::Vector{WhippetNode}
end

