
# Code in this file should format multiple plots into a single output format type.

function make_plots( delta::BufIn, tables::Vector{DataFrame}, samples::Vector{String}, filename::String, backend=SVGJS, ext="js.svg" )
   header = readline( delta )
   for l in eachline( delta )
      spl = split( l, '\t' )
      geneid  = String(spl[1])
      nodestr = String(spl[2])
      node    = parse(Int, nodestr)
      eventlayers,chr,xmin,xmax = draw_events( tables, samples, geneid, node )
      labelspace = (xmax-xmin)*0.3 + xmax
      #set_plot_size(length(tables))
      eventplot = plot(eventlayers, Guide.xlabel(chr), Guide.ylabel(""), Guide.yticks(ticks=nothing),
                       default_theme(), Coord.cartesian(xmin=xmin, xmax=labelspace, ymin=0, ymax=length(samples)+1),
                       Guide.title("Local Splicing Event (LSE) Graphs"))
      gellayers,agarose = draw_insilico_gel( tables, samples, geneid, node )
      # ColorKey(title)` is deprecated, use `ColorKey(title=title)
      gelplot   = plot(gellayers, Coord.cartesian(ymin=DEFAULT_MAXDIST*-1 - 3, ymax=5, xmin=-1, xmax=length(samples)+0.5),
                       default_theme(), Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
                       Guide.xlabel(""), Guide.ylabel(""), Guide.colorkey(title="PSI"),
                       Guide.title("$(round(agarose, digits=2))% Agarose Gel"))
      grid      = hstack(compose(context(0, 0, eventplot_dimensions(length(tables))...), render(eventplot)),
                         compose(context(0, 0, gelplot_dimensions(length(tables))...), render(gelplot)))
      draw( backend("$(geneid)_$(nodestr)_$(basename(filename)).$(ext)", plot_dimensions( length(tables) )...), grid )
   end
   true
end
