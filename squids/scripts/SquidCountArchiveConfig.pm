#!/usr/bin/perl

  $cfg_liblocation = "/a/squid/stats/scripts" ;

  $cfg_path_root_production = "/a/squid/stats/csv" ; 
  $cfg_path_root_test       = "w:/! perl/squids/archive/test" ;  # Erik

  $cfg_dir_in_production = "/a/squid/archive/sampled" ;
  $cfg_dir_in_test = "?" ; # Erik

  $cfg_logname = "sampled-1000.log" ;
  
# set default arguments for test on local machine
  $cfg_default_argv = "-d 2011/10/16-2011/10/16" ;

  $cfg_file_test = "w:/! Perl/Squids/Archive/sampled-1000.log-20111016.txt" ; # Erik
  $cfg_test_maxlines = 4000000 ;

