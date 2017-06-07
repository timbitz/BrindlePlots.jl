
const POLYWIDTH = 0.25
const ARCWIDTH  = 1.0

function make_arc( xmin, xmax, ymin, ymax, upright::Bool=true )
    seq = 0:0.0001:pi
    xseq = seq ./ pi
    xseq = xseq .* (xmax - xmin)
    xseq = xseq .+ xmin
    seq = upright ? seq : seq .- pi
    yseq = sin(seq) .* (ymax - ymin)
    yseq = yseq .+ ymin
    xseq, yseq
end

make_arc( left::Int, right::Int, number::Int=1 ) = mac_arc( left, right, number + POLYWIDTH, number + POLYWIDTH + ARCWIDTH )

make_box( xmin, xmax, ymin, ymax ) = [xmin, xmin, xmax, xmax], [ymin, ymax, ymax, ymin] 
make_box( first::Int, last::Int; number::Int=1) = make_box( first, last, number + POLYWIDTH, number - POLYWIDTH )

xtop, ytop     = make_arc( 1.0, 4.0, 1.5, 2.5 )
xleft, yleft   = make_arc( 1.0, 2.0, 0.5, 1.0, false )
xright, yright = make_arc( 3.0, 4.0, 0.5, 1.0, false )

xex1, yex1 = make_box( 0.0, 1.0, 0.5, 1.5 )
xex2, yex2 = make_box( 2.0, 3.0, 0.5, 1.5 )
xex3, yex3 = make_box( 4.0, 5.0, 0.5, 1.5 )

