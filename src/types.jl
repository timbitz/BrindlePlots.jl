
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

type BrindleNodeSet
   map::Dict{Int,BrindleNode}
   range::UnitRange
end

immutable BrindleEvent
   edgeset::BrindleEdgeSet
   nodeset::BrindleNodeSet
   chr::String
   strand::Bool
end

type BrindlePath
   path::IntSet
   length::Int
   psi::Float64
end

function Base.parse(::Type{BrindleNode}, str::String, psi::Float64)
   colon  = split( str, ':' )
   ints   = split( string(colon[2]), '-' )
   BrindleNode( string(colon[1]), parse(Int, string(ints[1])), parse(Int, string(ints[2])), psi )
end

function Base.parse(::Type{BrindleEdge}, str::String )
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

function BrindleEvent( genedf::DataFrame, node::Int )
   edgeset = parse(BrindleEdgeSet, genedf[(genedf[:,:Node] .== node),:Edges][1])
   nodes = Dict{Int,BrindleNode}()
   lower,upper = Inf,-Inf
   chr,strand  = "",true

   # draw exons
   for n in edgeset.nodes
      (length(genedf[(genedf[:,:Node] .== n),:Coord]) == 0) && continue
      psi = genedf[(genedf[:,:Node] .== n),:Psi][1]
      strand = genedf[(genedf[:,:Node] .== n),:Strand][1] == "+" ? true : false
      cnode = parse(BrindleNode, genedf[(genedf[:,:Node] .== n),:Coord][1], isna(psi) ? 1.0 : psi)
      chr = cnode.chr
      nodes[n] = cnode
      lower = lower > cnode.first ? cnode.first : lower
      upper = upper < cnode.last  ? cnode.last  : upper
   end
   nodeset = BrindleNodeSet( nodes, lower:upper )

   BrindleEvent( edgeset, nodeset, chr, strand )
end

