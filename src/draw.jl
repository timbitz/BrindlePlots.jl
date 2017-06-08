
const POLYWIDTH = 0.1
const ARCWIDTH  = 1.0
const ARCHEIGHT = 0.5

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

make_arc( left::Int, right::Int, number::Int=1, upright::Bool=true, archeight::Float64=ARCHEIGHT ) = upright ? 
                                        make_arc( left, right, number + POLYWIDTH, number + (POLYWIDTH + archeight) ) :
                                        make_arc( left, right, number - POLYWIDTH, number - (POLYWIDTH + archeight) )

make_box( xmin, xmax, ymin, ymax ) = [xmin, xmin, xmax, xmax], [ymin, ymax, ymax, ymin] 
make_box( first::Int, last::Int, number::Int=1) = make_box( first, last, number + POLYWIDTH, number - POLYWIDTH )

immutable BrindleRegion
   chr::String
   first::Int
   last::Int
   strand::Char
end

Base.convert(::Type{String}, br::BrindleRegion) = br.chr * ":" * string(br.first) * "-" * string(br.last) * ":" * string(br.strand)

immutable BrindleNode
   chr::String
   first::Int
   last::Int
   psi::Float64
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

function Base.parse(::Type{BrindleNode}, str::String, psi::Float64)
   colon = split( str, ':' )
   ints  = split( string(colon[2]), '-' )
   BrindleNode( string(colon[1]), parse(Int, string(ints[1])), parse(Int, string(ints[2])), psi )
end

function Base.parse{S <: AbstractString}(::Type{BrindleEdge}, str::S )
   colon = split( string(str), ':' )
   ints  = split( string(colon[1]), '-' )
   first = parse(Int, string(ints[1]))
   last  = parse(Int, string(ints[2]))
   value = parse(Float64, string(colon[2]))
   BrindleEdge(first, last, value)
end

function Base.parse(::Type{BrindleEdgeSet}, str::String )
   edgestr = split( str, ',' )
   edges = Vector{BrindleEdge}()
   nodes = IntSet()
   maxval = 0.0
   for s in edgestr
      be = parse(BrindleEdge, s)
      push!( edges, be )
      push!( nodes, be.first )
      push!( nodes, be.last  )
      maxval = be.value > maxval ? be.value : maxval
   end
   BrindleEdgeSet( edges, nodes, maxval )
end

function draw_event( df::DataFrame, node::Int, sample::String, curi=0, colornum=2 )
   layers = Vector{Gadfly.Layer}()
   draw_event!( layers, df, node, sample, curi, colornum )
   layers
end

function draw_event!( layers::Vector{Gadfly.Layer},
                      df::DataFrame, node::Int, sample::String, curi=0, colornum=2 )
   cols = default_colors( colornum )
   edgeset = parse(BrindleEdgeSet, df[(df[:,:Node] .== node),:Edges][1])
   nodes = Dict{Int,BrindleNode}()
   lower,upper = Inf,-Inf
   chr = ""
   # draw exons
   for n in edgeset.nodes
      println(df[(df[:,:Node] .== n),:])
      psi = df[(df[:,:Node] .== n),:Psi][1]
      cnode = parse(BrindleNode, df[(df[:,:Node] .== n),:Coord][1], isna(psi) ? 1.0 : psi)
      chr = cnode.chr
      nodes[n] = cnode
      lower = lower > cnode.first ? cnode.first : lower
      upper = upper < cnode.last  ? cnode.last  : upper
      xset,yset = make_box( cnode.first, cnode.last, curi )
      alphacols  = default_colors( colornum, cnode.psi )
      push!( layers, layer(x=xset, y=yset, Geom.polygon(fill=true), polygon_theme(alphacols[curi]))[1] )
      if cnode.psi < 1.0
         push!( layers, layer(x=[median(cnode.first:cnode.last)], y=[curi], label=[string(cnode.psi)], Geom.label(position=:centered))[1] )
      end
   end
   # draw junctions
   range = upper - lower
   for edge in edgeset.edges
      first = nodes[edge.first].last
      last  = nodes[edge.last].first
      height = (last - first) / range
      upright = (edge.first + 1 == edge.last)
      xarc,yarc = make_arc( first, last, curi, upright, height * ARCHEIGHT )
      push!( layers, layer(x=xarc, y=yarc, Geom.path, arc_theme(edge.value / edgeset.maxvalue, cols[curi]))[1] )
      push!( layers, layer(x=[median(xarc)], y=[(upright ? maximum(yarc)-0.1 : minimum(yarc)+0.115)],
                           label=[string(edge.value)], Geom.label(position=:centered))[1] )
   end
   labelpos = upper + range*0.025
   lonode,hinode = first(edgeset.nodes),last(edgeset.nodes)
   comp = df[(df[:,:Node] .== node),:Complexity][1]
   entr = df[(df[:,:Node] .== node),:Entropy][1]
   strand = df[(df[:,:Node] .== node),:Strand][1]
   metalab = "Nodes: $lonode-$hinode, $comp, $(string(entr))"
   push!( layers, layer(x=[labelpos], y=[curi+0.1], label=[sample], Geom.label(position=:right), default_theme())[1] )
   push!( layers, layer(x=[labelpos], y=[curi-0.05], label=[metalab], Geom.label(position=:right), default_theme())[1] ) 
   BrindleRegion(chr, lower, upper, strand[1])
end

function draw_metadata!( layers::Vector{Gadfly.Layer}, geneid::String, node::Int, xpos, ypos::Float64 )
   meta = "Gene: $geneid\tNode: $node"
   push!( layers, layer(x=[xpos], y=[ypos], label=[meta], Geom.label(position=:right), default_theme())[1] )
end

function draw_events( tabs::Vector{DataFrame}, samples::Vector{String}, geneid::String, node::Int )
   reverse!(tabs)
   reverse!(samples)
   colnum = 2 > length(tabs) ? 2 : length(tabs)
   layers = Vector{Gadfly.Layer}()
   xmin,xmax = Inf,-Inf
   chr,strand = "",' '
   for i in 1:length(tabs)
      xregion = draw_event!( layers, tabs[i][tabs[i][:,:Gene] .== geneid,:], node, samples[i], i, colnum )
      xmin = xregion.first < xmin ? xregion.first : xmin
      xmax = xregion.last  > xmax ? xregion.last  : xmax
      chr,strand = xregion.chr,xregion.strand
   end
   draw_metadata!( layers, geneid, node, xmin, length(tabs) + 0.6 )
   Guide.xlabel(convert(String, BrindleRegion(chr,xmin,xmax,strand))), layers
end
