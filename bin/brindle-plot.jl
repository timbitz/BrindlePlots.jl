#!/usr/bin/env julia
# Tim Sterne-Weiler 2017

const dir = abspath( splitdir(@__FILE__)[1] )
const ver = chomp(readline(open(dir * "/VERSION")))

tic()
println( STDERR, "BrindlePlots $ver loading and compiling... " )

using ArgParse
using Glob
using Gadfly

push!( LOAD_PATH, dir * "/../src" )
using BrindlePlots

function parse_cmd()
  s = ArgParseSettings()
  # TODO finish options...
  @add_arg_table s begin
    "--a", "-a"
      help     = "Replicates for Set A -- Could be: pattern to glob.psi (common-filename-segment [*.psi*]), or comma delimited list of filenames. ie. (-a sample_a) would work for sample_a-rep1.psi.gz,sample_a-rep2.psi.gz,..."
      arg_type = String
      required = true
    "--b", "-b"
      help     = "Replicates for Set B -- Same rules as for (-a) [this is not required if you just want to plot a set of files using -a]"
      arg_type = String
      default  = ""
    "--delta"
      help     = "`.diff.gz` file output from whippet-delta.jl filtered for events of interest (all events in this file will be plotted)"
      arg_type = String
      required = true
    "--out", "-o"
      help     = "Core file name to send .pdf output to!"
      arg_type = String
      default  = fixpath( "./output" )
    "--directory", "-d"
      help     = "Directory to search for file patterns or list in -a and -b"
      arg_type = String
      default  = "."
    "--backend"
      help     = "Graphics backend to use, options: ('pdf','svg','svgjs','ps','tex')"
      arg_type = String
      default  = "pdf"
  end
  return parse_args(s)
end

function retrievefilelist( pattern::String, dir::String )
   list = Vector{String}()
   if search(pattern, ',') > 0
      tmp = split( pattern, ',', keep=false )
   else
      tmp = glob( "*" * pattern * "*.psi*", dir )
   end
   # now clean the return
   for file in tmp
      push!( list, string(file) )
   end
   list
end

function parse_backend( str::String )
   backends = Dict("pdf" => PDF,
                   "svg" => SVG,
                   "svgjs" => SVGJS,
                   "ps" => PS,
                   "tex" => PGF)
   if haskey(backends, str)
      return str == "svgjs" ? "svg" : str,backends[str]
   else
      println(STDERR, "WARNING: Incorrect value $str supplied to --backend, using PDF instead!")
      return "pdf",PDF
   end
end

function main()
   args  = parse_cmd()
   println(STDERR, " $( round( toq(), 6 ) ) seconds" )
   dir   = fixpath( args["directory"] )
   ext,backend = parse_backend( args["backend"] )
   lista = retrievefilelist( args["a"], dir )
   full  = lista
   if args["b"] != ""
      # This is for Brock to compare sample sets.
      listb = retrievefilelist( args["b"], dir )
      full  = [lista; listb]
   end
   if length(full) <= 0
      error("Unable to match files! n_files_matched == $(length(lista))!")
   end
   tables = load_tables( full )
   delta  = open_stream( args["delta"] )
   make_plots( delta, tables, full, fixpath(args["out"]), backend, ext )
   close(delta)

   println(STDERR, "BrindlePlots $ver done." )
end

main()
