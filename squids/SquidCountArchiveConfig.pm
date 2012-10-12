#!/usr/bin/perl

  $cfg_liblocation = "/a/wikistat_git/scripts/" ;

  $cfg_path_root_production = "/a/squid/stats_editors/csv" ; 
#  $cfg_path_root_test       = "w:/! perl/squids/archive/test" ;  # Erik

  $cfg_dir_in_production = "/a/squid/archive/edits" ;
#  $cfg_dir_in_test = "?" ; # Erik

  $cfg_logname = "edits.log" ;
  
# set default arguments for test on local machine
  $cfg_default_argv = "-d 2011/10/16-2011/10/16" ;

  $cfg_file_test = "w:/! Perl/Squids/Archive/sampled-1000.log-20111016.txt" ; # Erik
  $cfg_test_maxlines = 4000000 ;

