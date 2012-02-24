#!/usr/bin/perl

  $liblocation = "/home/ezachte/lib" ;

# $path_in_local  = "W:/# Out Locke" ;      # Erik
# $path_out_local = "W:/# Out Test/Locke" ; # Erik

  $path_in  = "/srv/erik/" ;                # André
  $path_out = "/srv/erik/" ;                # André

# set defaults for tests on local machine
# $default_argv = "-m 2011-07" ;   # monthly report
# $default_argv = "-w" ;           # refresh country info from Wikipedia (population etc)
# $default_argv = "-c" ;           # country/regional reports
  $default_argv = "-c -q 2011Q4" ; # country/regional reports based on data for one quarter only
