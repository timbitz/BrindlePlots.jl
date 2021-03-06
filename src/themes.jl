
default_colors( n::Int ) = [Scale.color_continuous().f(p) for p in range(0, stop=1, length=n)]
function default_colors( n::Int, opacity::Float64 )
    map(c->(t = convert(Gadfly.RGBA, c); return Gadfly.RGBA(t.r, t.g, t.b, opacity)), default_colors(n))
end
greyscale_colors( n::Int ) = range(colorant"lightgrey", stop=colorant"black", length=n)

global const DEFAULT_COLOR = default_colors(6)[1]

plot_dimensions( n::Int ) = Measures.Length{:mm,Float64}( 10*(22 + n*1.5) ), Measures.Length{:mm,Float64}( 10*(max(5 + n*3.5, 10)) )
eventplot_dimensions( n::Int ) = 16cm, Measures.Length{:mm,Float64}( 10*(5 + n*3.5) )
gelplot_dimensions( n::Int ) = Measures.Length{:mm,Float64}( 10*(4 + n*1.5) ), 10cm
set_plot_size( n::Int ) = set_default_plot_size( plot_dimensions( n )... )

arc_theme( psi::Float64, color=DEFAULT_COLOR ) = Theme(default_color=color, line_width=Measures.Length{:mm,Float64}( psi * ARCWIDTH ))
polygon_theme( color=DEFAULT_COLOR ) = Theme(default_color=color,
                                             discrete_highlight_color=x->colorant"grey",
                                             lowlight_color=rgba->rgba) # avoid default_lowlight_color warning in Gadfly@1.0.1
gelband_theme( size::Int, agarose::Float64, psi::Float64, color=DEFAULT_COLOR ) = Theme(default_color=color, line_width=Measures.Length{:mm,Float64}( migration_proportion( size, agarose )*BANDTHICK / 3 + psi*BANDTHICK / 1.5 ))
default_theme( color=colorant"black" ) = Theme(default_color=color)
