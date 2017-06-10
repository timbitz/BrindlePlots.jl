
# Code in this file should format multiple plots into a single output format type. 

function make_plots( delta::BufIn, tables::Vector{DataFrame}, samples::Vector{String}, filename::String )
   header = readline( delta )
   for l in eachline( delta )
      spl = split( l, '\t' )
      geneid  = String(spl[1])
      nodestr = String(spl[2])
      node    = parse(Int, nodestr)
      eventlayers,chr,xmin,xmax = draw_events( tables, samples, geneid, node )
      labelspace = (xmax-xmin)*0.3 + xmax
      set_plot_size(length(tables))
      eventplot = plot(eventlayers, Guide.xlabel(chr), Guide.ylabel(""), Guide.yticks(ticks=nothing), 
                       default_theme(), Coord.cartesian(xmin=xmin, xmax=labelspace, ymin=0, ymax=length(samples)+1),
                       Guide.title("Local Splicing Event (LSE) Graphs"))
      gellayers,agarose = draw_insilico_gel( tables, samples, geneid, node )
      gelplot   = plot(gellayers, Coord.cartesian(ymin=DEFAULT_MAXDIST*-1 - 3, ymax=5, xmin=-0.75, xmax=length(samples)+0.5), 
                       default_theme(), Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
                       Guide.xlabel(""), Guide.ylabel(""), Guide.colorkey("PSI"),
                       Guide.title("$(round(agarose,2))% Agarose Gel"))
      gelgrid   = length(samples) > 2 ? vstack(gelplot, Compose.context()) : gelplot
      draw( PDF("$geneid\_$nodestr\_$(basename(filename)).pdf", plot_dimensions( length(tables) )...), 
            hstack(eventplot, gelgrid) )
   end
   true
end
