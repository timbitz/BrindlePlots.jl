
default_colors( n::Int ) = [Scale.color_continuous().f(p) for p in linspace(0, 1, x)]

arc_theme( psi::Float64, color=default_colors(6)[1] ) = Theme(default_color=color, line_width=Measures.Length{:mm,Float64}( psi * 1.5 ))
polygon_theme = Theme(default_color=colorant"gray75", discrete_highlight_color=x->colorant"black")
default_theme = Theme(default_color=colorant"black")

