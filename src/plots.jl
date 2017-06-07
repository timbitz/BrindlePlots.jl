

plot(layer(x=xtop, y=ytop, Geom.path, arc_theme(0.66)),
     layer(x=xleft, y=yleft, Geom.path, arc_theme(0.125),
    layer(x=xright, y=yright, Geom.path, arc_theme(0.125),
                   layer(x=xex1, y=yex1, Geom.polygon(fill=true), polygon_theme),
                   layer(x=xex2, y=yex2, Geom.polygon(fill=true), polygon_theme),
                   layer(x=xex3, y=yex3, Geom.polygon(fill=true), polygon_theme),
                   Coord.cartesian( ymin=0.0, ymax=4.0, xmin=0.0, xmax=5.0), default_theme)
