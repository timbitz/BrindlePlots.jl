#!/usr/bin/env julia

function check_and_install( pkg; clone=false, checkout=false )
   print( STDERR, "Checking $pkg ... " )
   pkgname = clone ? basename(pkg) |> x->split(x, ".jl.git", keep=false)[1] |> string : pkg
   try
      ver = Pkg.installed(pkgname)
      if !clone && ver == nothing
         error()
      end
      println( STDERR, "Found version $ver" )
   catch
      println( STDERR, "Trying to install $pkg ..." )
      if clone
         Pkg.clone(pkg)
      else
         Pkg.add(pkg)
      end
      if checkout
         Pkg.checkout(pkg)
      end
   end
end

adds = [ "Gadfly",
         "Libz",
         "Cairo" ]

tic()
Pkg.update()
map( check_and_install, adds )

println( STDERR, "INFO: Loading and precompiling... " )

using Gadfly
using Compose
using Cairo
using DataStructures
using BufferedStreams
using Libz
using Measures

const dir = abspath( splitdir(@__FILE__)[1] )
push!( LOAD_PATH, dir * "/src" )
using BrindlePlots
toc()
