
arc_theme( psi::Float64 ) = Theme(default_color=colorant"black", line_width=Measures.Length{:mm,Float64}( psi * 1.5 ))
polygon_theme = Theme(default_color=colorant"gray75", discrete_highlight_color=x->colorant"black")
default_theme = Theme(default_color=colorant"black")

