#=  
  This should have a type for a gene, which is parsed from file,
    stores every node, and all the paths from .psi.gz files
=#

const BufIn = BufferedStreams.BufferedInputStream

fixpath( str::String ) = abspath( expanduser( str ) )

function isgzipped( filename::String )
   restr = "\.gz\$"
   re = Base.match(Regex(restr), filename)
   return re == nothing ? false : true
end

function open_stream( filename )
   fopen = open( filename, "r" )
   if isgzipped( filename )
      stream = ZlibInflateInputStream( fopen, reset_on_end=true )
   else
      stream = BufIn( fopen )
   end
   stream
end

function open_streams( files::Vector{String} )
   buf = Vector{BufIn}(length(files))
   for i in 1:length(files)
      buf[i] = open_stream( files[i] )
   end
   buf
end

function load_tables( files::Vector{String} )
   tabs = Vector{DataFrame}(length(files))
   for i in 1:length(files)
      tabs[i] = readtable( files[i], separator='\t', header=true )
   end
   tabs
end


