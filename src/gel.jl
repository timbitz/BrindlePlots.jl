
const DEFAULT_TIME    = 30.0
const DEFAULT_VOLTAGE = 20.0
const DEFAULT_MAXDIST = 0.25*DEFAULT_TIME*DEFAULT_VOLTAGE

const LADDER_100BP_TUPLE =[(1500, 0.15),
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

const LADDER_100BP_LENGTH = map( x->x[1], LADDER_100BP_TUPLE )
const LADDER_100BP_PSI    = map( x->x[2], LADDER_100BP_TUPLE )
const LADDER_100BP_NORMAL = LADDER_100BP_PSI / maximum(LADDER_100BP_PSI)

function optimal_gel_concentration{ N <: Number}( size::N )
   percentage  = reverse(collect(0.5:0.05:3))
   optimalsize = [(2000 / x ^ 3) for x in percentage]
   first = searchsortedfirst( optimalsize, size )
   last = first+1
   index = size - optimalsize[first] > optimalsize[last] - size ? last : first
   index in 1:length(optimalsize) ? percentage[index] : 1.5
end

function optimal_gel_concentration{ N <: Number}( lower::N, upper::N )
   percentage  = reverse(collect(0.5:0.05:3))
   optimalsize = [(2000 / x ^ 3) for x in percentage]
   first = searchsortedfirst( optimalsize, lower )
   last  = searchsortedlast(  optimalsize, upper )
   first < last ? median(percentage[last]:0.1:percentage[first]) : 1.5
end

function optimal_gel_concentration( paths::Vector{BrindlePathVec} )
   agarose = 0.0
   for p in paths
      lengths = map( x->x.length, p )
      lower = minimum( lengths )
      upper = maximum( lengths )
      agarose = max( optimal_gel_concentration( lower, upper ), agarose )
   end
   agarose
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

function migration_proportion( size::Int, agarose::Float64 )
   shape   = (2000 / (agarose ^ 3))/20
   gamma_cdf( size/20, shape )
end

function migration_distance( size::Int, agarose::Float64, 
                             time=DEFAULT_TIME, voltage=DEFAULT_VOLTAGE, 
                             maxdistance=DEFAULT_MAXDIST )
   migration_proportion( size, agarose ) * maxdistance
end


