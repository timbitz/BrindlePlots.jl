#=  
  This should have a type for a gene, which is parsed from file,
    stores every node, and all the paths from .psi.gz files
=#

parse_complexity{S <: AbstractString}( c::S ) = split( c, COMPLEX_CHAR, keep=false )[1] |> x->parse(Int,x)
parse_float_omit_text{S <: AbstractString}( str::S, header::String ) = str != "NA" && str != header ? parse(Float64, str) : 0.0


function open_stream( filename )
   fopen = open( filename, "r" )
   if isgzipped( filename )
      stream = ZlibInflateInputStream( fopen, reset_on_end=true )
   else
      stream = BufferedStreams.BufferedInputStream( fopen )
   end
   stream
end

function open_streams( files::Vector{String} )
   buf = Vector{BufferedStreams.BufferedInputStream}(length(files))
   for i in 1:length(files)
      buf[i] = open_stream( files[i] )
   end
   buf
end


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

