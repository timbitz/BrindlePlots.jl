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
   colon  = split( str, ':' )
   ints   = split( string(colon[2]), '-' )
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

