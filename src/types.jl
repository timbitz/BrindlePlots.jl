
immutable BrindleNode
   chr::String
   first::Int
   last::Int
   psi::Float64
   kind::String
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
   complexity::String
   entropy::Float64
end

immutable BrindlePath
   path::IntSet
   length::Int
   psi::Float64
end

const BrindlePathVec = Vector{BrindlePath}

function Base.parse{S <: AbstractString}(::Type{IntSet}, str::S )
   is = IntSet()
   spl = split( str, '-' )
   for s in spl
      i = parse(Int, String(s))
      push!( is, i )
   end
   is
end

function Base.parse(::Type{BrindleNode}, str::String, psi::Float64, kind::String)
   colon  = split( str, ':' )
   ints   = split( string(colon[2]), '-' )
   BrindleNode( string(colon[1]), parse(Int, string(ints[1])), parse(Int, string(ints[2])), psi, kind )
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
      be = parse(BrindleEdge, String(s))
      push!( edges, be )
      push!( nodes, be.first )
      push!( nodes, be.last  )
      maxval = be.value > maxval ? be.value : maxval
   end
   BrindleEdgeSet( edges, nodes, maxval )
end

function BrindleEvent( genedf::DataFrame, node::Int )
   edgeset     = parse(BrindleEdgeSet, genedf[(genedf[:,:Node] .== node),:Edges][1])
   nodes       = Dict{Int,BrindleNode}()
   nodearray   = collect( edgeset.nodes )
   lower,upper = Inf,-Inf
   chr,strand  = "",true
   
   for n in nodearray
      (length(genedf[(genedf[:,:Node] .== n),:Coord]) == 0) && continue
      psi      = genedf[(genedf[:,:Node] .== n),:Psi][1]
      strand   = genedf[(genedf[:,:Node] .== n),:Strand][1] == "+" ? true : false
      kind     = genedf[(genedf[:,:Node] .== n),:Type][1]
      cnode    = parse(BrindleNode, genedf[(genedf[:,:Node] .== n),:Coord][1], 
                       isna(psi) ? 1.0 : psi, 
                       isna(kind) ? "NA" : kind)
      chr      = cnode.chr
      nodes[n] = cnode
      lower = lower > cnode.first ? cnode.first : lower
      upper = upper < cnode.last  ? cnode.last  : upper
      #push_adjacent_ts_te!( nodearray, genedf, n, kind )
   end
   comp = genedf[(genedf[:,:Node] .== node),:Complexity][1]
   entr = genedf[(genedf[:,:Node] .== node),:Entropy][1]
   nodeset = BrindleNodeSet( nodes, lower:upper )

   BrindleEvent( edgeset, nodeset, chr, strand, comp, entr )
end

function Base.push!( paths::Vector{BrindlePath}, event::BrindleEvent, str::String )
   spl = split( str, ',' )
   for s in spl
      path,psistr = split( s, ':' )
      is = parse(IntSet, path)
      psi = parse(Float64, String(psistr))
      length = 0
      for i in is
         if haskey(event.nodeset.map, i)
            node = event.nodeset.map[i]
            length += node.last - node.first + 1
         end
      end
      push!( paths, BrindlePath(is, length, psi) )
   end
end

boundary_nodes( paths::Vector{BrindlePath} ) = minimum( [first(x.path) for x in paths] ), maximum( [last(x.path) for x in paths] )

function Base.union( v::Vector{IntSet} )
   res = IntSet()
   for i in v
     res = union( res, i )
   end
   res
end
