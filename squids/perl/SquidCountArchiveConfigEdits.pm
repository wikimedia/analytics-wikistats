#!/usr/bin/perl

# no debugging
$trace_on_exit          = $false;
$trace_on_exit_verbose  = $false;
$trace_on_exit_concise  = $false;

$cfg_sample_rate = 1 ;
#$cfg_sample_rate = 1000 ;

$wikistats = "/a/wikistats_git" ;
$squids = "$wikistats/squids" ;

$cfg_liblocation = "$squids/perl" ;
$cfg_liblocation = "/home/ezachte/wikistats/squids-scripts-2012-10/perl" ;

$cfg_path_root_production = "$squids/csv_edits" ; 
$cfg_path_root_test       = "w:/! perl/squids/archive/test" ;  # Erik

#$cfg_dir_in_production = "/a/squid/archive/edits" ; # old
$cfg_dir_in_production = "/a/log/webrequest/archive/edits" ; # new
#$cfg_dir_in_production = "/a/squid/archive/sampled" ;
$cfg_dir_in_test = "?" ; # Erik

$cfg_logname = "edits.tsv.log" ; # log file name changed from 2013-04-04
#$cfg_logname = "edits.tab.log" ;
#$cfg_logname = "edits.log" ;
  
$cfg_default_argv = "-d 2013/07/01-2013/07/01" ; #set default arguments for test on local machine

$cfg_file_test = "w:/! Perl/Squids/Archive/edits...?.txt" ; # Erik
$cfg_test_maxlines = 4000000 ;
