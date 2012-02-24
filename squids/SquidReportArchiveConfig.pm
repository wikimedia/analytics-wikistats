#!/usr/bin/perl

  $cfg_liblocation = "/home/ezachte/lib" ;

  $cfg_path_in_production  = "/a/ezachte" ;
  $cfg_path_out_production = "/a/ezachte" ;
# $cfg_path_in_test        = "W:/# Out Locke" ;      # Erik
# $cfg_path_out_test       = "W:/# Out Test/Locke" ; # Erik
  $cfg_path_in_test        = "/srv/erik/" ;          # André
  $cfg_path_out_test       = "/srv/erik/" ;          # André

# set default arguments for test on local machine
# $cfg_default_argv = "-m 2011-07" ;   # monthly report
# $cfg_default_argv = "-w" ;           # refresh country info from Wikipedia (population etc)
# $cfg_default_argv = "-c" ;           # country/regional reports
  $cfg_default_argv = "-c -q 2011Q4" ; # country/regional reports based on data for one quarter only
