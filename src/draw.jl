
const POLYWIDTH = 0.25
const ARCWIDTH  = 1.0

function make_arc( xmin, xmax, ymin, ymax, upright::Bool=true )
    seq = 0:0.0001:pi
    xseq = seq ./ pi
    xseq = xseq .* (xmax - xmin)
    xseq = xseq .+ xmin
    seq = upright ? seq : seq .- pi
    yseq = sin(seq) .* (ymax - ymin)
    yseq = yseq .+ ymin
    xseq, yseq
end

make_arc( left::Int, right::Int, number::Int=1, upright::Bool=true ) = upright ? 
                                        make_arc( left, right, number + POLYWIDTH, number + (POLYWIDTH + ARCWIDTH) ) :
                                        make_arc( left, right, number - POLYWIDTH, number - (POLYWIDTH + ARCWIDTH) )

make_box( xmin, xmax, ymin, ymax ) = [xmin, xmin, xmax, xmax], [ymin, ymax, ymax, ymin] 
make_box( first::Int, last::Int; number::Int=1) = make_box( first, last, number + POLYWIDTH, number - POLYWIDTH )

immutable BrindleNode
   first::Int
   last::Int
end

immutable BrindleEdge
   first::Int
   last::Int
   value::Float64
end

type BrindleEdgeSet
   edges::Vector{BrindleEdge}
   nodes::IntSet
   maxvalue::Float64
end

function Base.parse{S <: AbstractString}(::Type{BrindleEdge}, str::S )
   colon = split( string(str), ':' )
   ints  = split( string(colon[1]), '-' )
   first = parse(Int, string(ints[1]))
   last  = parse(Int, string(ints[2]))
   value = parse(Float64, string(colon[2]))
   BrindleEdge(first, last, value)
end

function Base.parse{S <: AbstractString}(::Type{BrindleEdgeSet}, str::S )
   edgestr = split( string(str), ',' )
   edges = Vector{BrindleEdge}()
   nodes = IntSet()
   maxval = 0.0
   for s in edgestr
      be = parse(BrindleEdge, str)
      push!( edges, be )
      push!( nodes, be.first )
      push!( nodes, be.last  )
      maxval = be.value > maxval ? be.value : maxval
   end
   BrindleEdgeSet( edges, nodes, maxval )
end

function draw_event( df::DataFrame, node::Int, midline=0, color=DEFAULT_COLOR )
   layers = Vector{Gadfly.Layer}()
   draw_event!( layers, df, geneid, node, midline, color )
   layers
end

function draw_event!( layers::Vector{Gadfly.Layer}(), 
                      df::DataFrame, node::Int, midline=0, color=DEFAULT_COLOR )
   edgeset = parse(BrindleEdgeSet, df[(df[:,:Node] .== node),:Edges])
   nodes = Dict{Int,BrindleNode}()
   for n in edgeset.nodes
      nodes[n] = parse(BrindleNode, string(df[(df[:,:Node] .== node),:Coord]))
   end
   for edge in edgeset.edges
      first = nodes[edge.first].last
      last  = nodes[edge.last].first
      xarc,yarc = make_arc( first, last, midline, edge.first + 1 == edge.last )
      push!( layers, layer(x=xarc, y=yarc, Geom.path, arc_theme(edge.value / edgeset.maxvalue, color)) )
   end
   for node in values(nodes)
      xset,yset = make_box( node.first, node.last, midline )
      push!( layers, layer(x=xset, y=yset, Geom.polygon(fill=true), polygon_theme(color)) )
   end
end

function draw_events( tabs::Vector{DataFrame}, geneid::String, node::Int )
   cols = default_colors( length(tabs) )
   layers = Vector{Gadfly.Layer}()
   for i in 1:length(tabs)
      draw_event!( layers, df, geneid, node, i, cols[i] )
   end
   layers
end
