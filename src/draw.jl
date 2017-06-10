
const POLYWIDTH = 0.1
const ARCWIDTH  = 1.0
const ARCHEIGHT = 0.4
const BANDWIDTH = 0.4
const BANDTHICK = 2.0

const ALPHABET  = [convert(Char, x) for x in 65:90]

function make_arc( xmin, xmax, ymin, ymax, upright::Bool=true )
    seq = 0:0.01:pi
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

function draw_event( df::DataFrame, node::Int, sample::String, curi=0, colornum=2 )
   layers = Vector{Gadfly.Layer}()
   draw_event!( layers, df, node, sample, curi, colornum )
   layers
end

function draw_event!( layers::Vector{Gadfly.Layer}, event::BrindleEvent, node::Int, 
                      sample::String, curi=0, colornum=2 )
   cols = default_colors( colornum )
   const edgeset = event.edgeset
   const nodes   = event.nodeset.map

   # draw exons
   for n in keys(nodes)
      const cnode = nodes[n]
      xset,yset = make_box( cnode.first, cnode.last, curi )
      alphacols  = default_colors( colornum, cnode.psi )

      push!( layers, layer(x=xset, y=yset, Geom.polygon(fill=true), polygon_theme(alphacols[curi]))[1] )
      if cnode.psi < 1.0
         push!( layers, layer(x=[median(cnode.first:cnode.last)], 
                              y=[curi], label=[string(cnode.psi)], 
                              Geom.label(position=:centered))[1] )
      end
   end

   # draw junctions
   range = length(event.nodeset.range)
   for edge in edgeset.edges
      (haskey(nodes, edge.first) && haskey(nodes, edge.last)) || continue
      first = event.strand ? nodes[edge.first].last : nodes[edge.last].last
      last  = event.strand ? nodes[edge.last].first : nodes[edge.first].first
      height = (last - first) / range
      upright = (edge.first + 1 == edge.last)

      xarc,yarc = make_arc( first, last, curi, upright, height * ARCHEIGHT )
      push!( layers, layer(x=xarc, y=yarc, Geom.path, arc_theme(edge.value / edgeset.maxvalue, cols[curi]))[1] )
      push!( layers, layer(x=[median(xarc)], y=[(upright ? maximum(yarc)-0.1 : minimum(yarc)+0.115)],
                           label=[string(edge.value)], Geom.label(position=:centered))[1] )

   end
   labelpos = event.nodeset.range.stop + range*0.025
   lonode,hinode = first(edgeset.nodes),last(edgeset.nodes)
   strand = event.strand ? "+" : "-"
   metalab = "Nodes: $lonode-$hinode, $(event.complexity), $(string(event.entropy))"

   push!( layers, layer(x=[labelpos], y=[curi+0.1], label=["($(ALPHABET[curi])) $sample"], 
                        Geom.label(position=:right), default_theme())[1] )
   push!( layers, layer(x=[labelpos], y=[curi-0.05], label=[metalab], 
                        Geom.label(position=:right), default_theme())[1] ) 
end

function draw_metadata!( layers::Vector{Gadfly.Layer}, geneid::String, coord::String, 
                         node::Int, xpos, ypos::Float64 )
   meta = "Gene: $geneid\tNode: $node\nLSE Range: $coord"
   push!( layers, layer(x=[xpos], y=[ypos], label=[meta], Geom.label(position=:right), default_theme())[1] )
end

function draw_events( tables::Vector{DataFrame}, samples::Vector{String}, geneid::String, node::Int )
   tabs = reverse(tables)
   sams = reverse(samples)
   colnum = 2 > length(tabs) ? 2 : length(tabs)
   layers = Vector{Gadfly.Layer}()
   xmin,xmax = Inf,-Inf
   chr,strand = "",""
   for i in 1:length(tabs)
      event = BrindleEvent( tabs[i][tabs[i][:,:Gene] .== geneid,:], node )
      draw_event!( layers, event, node, sams[i], i, colnum )
      coord = event.nodeset.range
      xmin = coord.start < xmin ? coord.start : xmin
      xmax = coord.stop  > xmax ? coord.stop  : xmax
      chr,strand = event.chr,event.strand ? "+" : "-"
   end
   region = "$chr:$xmin-$xmax:$strand"
   draw_metadata!( layers, geneid, region, node, xmin, length(tabs) + 0.6 )
   layers, Guide.xlabel(convert(String, chr))
end

function draw_ladder_labels!( layers::Vector{Gadfly.Layer}, agarose::Float64,
                              lengths::Vector{Int}=LADDER_100BP_LENGTH )
   positions = map( x->migration_distance(x, agarose)*-1, lengths )
   push!( layers, layer(x=[-0.45 for i in 1:length(positions)], y=positions,
                        label=map(string, lengths), Geom.label(position=:left))[1] )
end

function draw_lane_labels!( layers::Vector{Gadfly.Layer}, totalnum::Int )
   push!( layers, layer(x=[i for i in 1:totalnum],
                        y=[DEFAULT_MAXDIST*-1 - 2 for x in 1:totalnum],
                        label=["($(ALPHABET[i]))" for i in 1:totalnum],
                        Geom.label(position=:centered))[1] )
                        
end

function draw_insilico_lane!( layers::Vector{Gadfly.Layer}, agarose::Float64, center::Int=0,
                              lengths::Vector{Int}=LADDER_100BP_LENGTH, 
                              psi::Vector{Float64}=LADDER_100BP_NORMAL,
                              bandwidth=BANDWIDTH )
   positions = map( x->migration_distance(x, agarose)*-1, lengths )
   len       = length(positions)
   colors    = default_colors( 100, 1.0 )
   for i in 1:length(positions)
      color = colors[ Int(ceil(psi[i]*100)) ]
      push!( layers, layer(x=[center-bandwidth], y=[positions[i]],
                           xend=[center+bandwidth], yend=[positions[i]],
                           Geom.segment, gelband_theme(lengths[i], agarose, psi[i], color))[1] )
   end
end

function draw_insilico_lane!( layers::Vector{Gadfly.Layer}, paths::Vector{BrindlePath}, 
                              agarose::Float64, center::Int, bandwidth=BANDWIDTH )
   lengths   = map( x->x.length, paths )
   psi       = map( x->x.psi,    paths )
   draw_insilico_lane!( layers, agarose, center, lengths, psi, bandwidth )
end

function draw_insilico_gel( tabs::Vector{DataFrame}, samples::Vector{String}, geneid::String, node::Int )
   layers  = Vector{Gadfly.Layer}()
   colnum  = 2 > length(tabs) ? 2 : length(tabs)
   paths   = Vector{BrindlePathVec}()
   for i in 1:length(tabs)
      df = tabs[i][tabs[i][:,:Gene] .== geneid,:]
      event = BrindleEvent( df, node )
      pathvec = BrindlePathVec()
      incpath = df[df[:,:Node] .== node,:Inc_Paths][1]
      !isna(incpath) && push!( pathvec, event, incpath )
      excpath = df[df[:,:Node] .== node,:Exc_Paths][1]
      !isna(excpath) && push!( pathvec, event, excpath )
      push!( paths, pathvec )
   end
   agarose = optimal_gel_concentration( paths )
   draw_insilico_lane!( layers, agarose )
   for i in 1:length(paths)
      draw_insilico_lane!( layers, paths[i], agarose, i )
   end
   draw_ladder_labels!( layers, agarose )
   layers, agarose
end

