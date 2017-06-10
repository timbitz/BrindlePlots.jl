
const DEFAULT_TIME    = 30.0
const DEFAULT_VOLTAGE = 20.0

const ONEHUNDREDBP_PLUS = [(1500, 0.15),
                           (1000, 0.2),
                           (900, 0.12),
                           (800, 0.11),
                           (700, 0.07),
                           (600, 0.08),
                           (500, 0.15),
                           (400, 0.05),
                           (300, 0.03),
                           (200, 0.02),
                           (100, 0.02)]

function optimal_gel_concentration{ N <: Number}( size::N )
   percentage  = reverse(collect(0.5:0.05:3))
   optimalsize = [(2000 / x ^ 3) for x in percentage]
   first = searchsortedfirst( optimalsize, size )
   last = first+1
   index = size - optimalsize[first] > optimalsize[last] - size ? last : first
   percentage[index]
end

function optimal_gel_concentration{ N <: Number}( lower::N, upper::N )
   percentage  = reverse(collect(0.5:0.05:3))
   optimalsize = [(2000 / x ^ 3) for x in percentage]
   first = searchsortedfirst( optimalsize, lower )
   last  = searchsortedlast(  optimalsize, upper )
   median(percentage[last]:0.1:percentage[first])
end

function gamma_cdf( x, t, k=1 )
    b = 1.0 / t
    x *= k
    c = 0.0
    for i in 0:k
        c += (exp(-b * x) * (b * x) ^ i) / factorial(i)
    end
    c
end

function migration_distance( size::Int, percent::Float64, 
                             time=DEFAULT_TIME, voltage=DEFAULT_VOLTAGE, 
                             maxdistance=0.25*time*voltage )
   shape   = (2000 / (percent ^ 3))/20
   gamma_cdf( size/20, shape ) * maxdistance
end

