
# Code in this file should format multiple plots into a single output format type. 

function make_plots( delta::BufIn, tables::Vector{DataFrame}, samples::Vector{String}, filename::String )
   header = readline( delta )
   for l in eachline( delta )
      spl = split( l, '\t' )
      geneid  = String(spl[1])
      nodestr = String(spl[2])
      node    = parse(Int, nodestr)
      eventlayers,xlab = draw_events( tables, samples, geneid, node )
      set_plot_size(length(tables))
      eventplot = plot(eventlayers, xlab, Guide.ylabel(""), Guide.yticks(ticks=nothing), 
                       default_theme(), 
                       Guide.title("Local Splicing Event (LSE) Graphs"))
      gellayers,agarose = draw_insilico_gel( tables, samples, geneid, node )
      gelplot   = plot(gellayers, Coord.cartesian(ymin=DEFAULT_MAXDIST*-1, ymax=5, xmin=-0.75, xmax=length(samples)+0.5), 
                       default_theme(), Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
                       Guide.xlabel(""), Guide.ylabel(""),
                       Guide.title("$(round(agarose,2))% Agarose Gel"))
      draw( PDF("$geneid\_$nodestr\_$(basename(filename)).pdf", plot_dimensions( length(tables) )...), 
            hstack(eventplot, gelplot) )
   end
   true
end
