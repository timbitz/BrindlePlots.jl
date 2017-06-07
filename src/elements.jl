
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

make_arc( left::Int, right::Int, number::Int=1, upright::Bool=true ) = upright ? 
                                        make_arc( left, right, number + POLYWIDTH, number + (POLYWIDTH + ARCWIDTH) ) :
                                        make_arc( left, right, number - POLYWIDTH, number - (POLYWIDTH + ARCWIDTH) )

make_box( xmin, xmax, ymin, ymax ) = [xmin, xmin, xmax, xmax], [ymin, ymax, ymax, ymin] 
make_box( first::Int, last::Int; number::Int=1) = make_box( first, last, number + POLYWIDTH, number - POLYWIDTH )


