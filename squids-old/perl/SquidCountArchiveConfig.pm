#!/usr/bin/perl

$wikistats = "/a/wikistats_git" ;
$squids = "$wikistats/squids" ;

$cfg_liblocation = "$squids/perl" ;

$cfg_path_root_production = "$squids/csv" ; 
$cfg_path_root_test       = "w:/! perl/squids/archive/test" ;  # Erik

$cfg_dir_in_production = "/a/squid/archive/sampled-geocoded" ;
$cfg_dir_in_test = "?" ; # Erik

$cfg_logname = "sampled-1000.log" ;
  
$cfg_default_argv = "-d 2011/10/16-2011/10/16" ; #set default arguments for test on local machine

$cfg_file_test = "w:/! Perl/Squids/Archive/sampled-1000.log-20111016.txt" ; # Erik
$cfg_test_maxlines = 4000000 ;

