#!/usr/bin/perl

$wikistats = "/a/wikistats_git" ;
$squids = "$wikistats/squids" ;

$cfg_liblocation = "$squids/perl" ;
$cfg_liblocation = "/home/ezachte/wikistats/squids-scripts-2012-10/perl" ;

$cfg_sample_rate = 1000 ;

$cfg_path_root_production = "$squids/csv" ; 
$cfg_path_root_test       = "w:/! perl/squids/archive/test" ;  # Erik

$cfg_dir_in_production = "/a/squid/archive/sampled" ;
$cfg_dir_in_test = "?" ; # Erik

# $cfg_logname = "sampled-1000.tab.log" ;
$cfg_logname = "sampled-1000.tsv.log" ; # log file name changed from 2013-04-04
  
$cfg_default_argv = "-d 2011/10/16-2011/10/16" ; #set default arguments for test on local machine

$cfg_file_test = "w:/! Perl/Squids/Archive/sampled-1000.log-20111016.txt" ; # Erik
$cfg_test_maxlines = 4000000 ;

