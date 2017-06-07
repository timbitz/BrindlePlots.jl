
arc_theme( psi::Float64 ) = Theme(default_color=colorant"black", line_width=Measures.Length{:mm,Float64}( psi * 1.5 ))
polygon_theme = Theme(default_color=colorant"gray75", discrete_highlight_color=x->colorant"black")
default_theme = Theme(default_color=colorant"black")

plot(layer(x=xtop, y=ytop, Geom.path, arc_theme(0.66)),
                   layer(x=xleft, y=yleft, Geom.path),
                   layer(x=xright, y=yright, Geom.path),
                   layer(x=xex1, y=yex1, Geom.polygon(fill=true), polygon_theme),
                   layer(x=xex2, y=yex2, Geom.polygon(fill=true), polygon_theme),
                   layer(x=xex3, y=yex3, Geom.polygon(fill=true), polygon_theme),
                   Coord.cartesian( ymin=0.0, ymax=4.0, xmin=0.0, xmax=5.0), default_theme)
