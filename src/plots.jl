
# Code in this file should format multiple plots into a single output format type. 

function make_plots( delta::BufIn, tables::Vector{DataFrame}, samples::Vector{String}, filename::String )
   header = readline( delta )
   for l in eachline( delta )
      spl = split( l, '\t' )
      geneid  = String(spl[1])
      nodestr = String(spl[2])
      xlab, layers = draw_events( tables, samples, geneid, parse(Int, nodestr) )
      set_plot_size(length(tables))
      toplot = plot(layers, xlab, Guide.ylabel(""), Guide.yticks(label=false), default_theme())
      draw(PDF("$geneid\_$nodestr\_$(basename(filename)).pdf", plot_dimensions( length(tables) )...), toplot)
   end
end
