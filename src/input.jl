#=
  This should have a type for a gene, which is parsed from file,
    stores every node, and all the paths from .psi.gz files
=#

BufIn = BufferedStreams.BufferedInputStream

fixpath( str::String ) = abspath( expanduser( str ) )

isgzipped( filename::String ) = splitext(filename)[2] == ".gz"

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
   tabs = Vector{DataFrame}(undef, length(files))
   for i in 1:length(files)
      if isgzipped(files[i])
         tabs[i] = GZip.open(files[i], "r") do gzio
            CSV.read(gzio, delim='\t', header=1)
         end
      else
         tabs[i] = CSV.read( files[i], delim='\t', header=1)
      end
   end
   tabs
end
