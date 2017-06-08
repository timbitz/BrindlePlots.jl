
default_colors( n::Int ) = [Scale.color_continuous().f(p) for p in linspace(0, 1, n)]

const DEFAULT_COLOR = default_colors(6)[1]

arc_theme( psi::Float64, color=DEFAULT_COLOR ) = Theme(default_color=color, line_width=Measures.Length{:mm,Float64}( psi * ARCWIDTH ))
polygon_theme( color=DEFAULT_COLOR ) = Theme(default_color=color, discrete_highlight_color=x->colorant"black")
default_theme = Theme(default_color=colorant"black")


