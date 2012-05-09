#!/usr/bin/perl

  $developer = "engels" ;
  $cfg_liblocation = "/a/squid/stats/dev_$developer/scripts" ;

  $cfg_path_root_production = "/a/squid/stats/dev_$developer/csv" ; 
  $cfg_path_root_test       = "w:/! perl/squids/archive/test" ;  # Erik

  $cfg_dir_in_production = "/a/squid/archive/sampled" ;
  $cfg_dir_in_test = "?" ; # Erik

  $cfg_logname = "sampled-1000.log" ;
  
# set default arguments for test on local machine
  $cfg_default_argv = "-d 2012/04/01-2012/04/30" ;

  $cfg_file_test = "w:/! Perl/Squids/Archive/sampled-1000.log-20111016.txt" ; # Erik
  $cfg_test_maxlines = 4000000 ;

