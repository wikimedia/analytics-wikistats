#!/usr/bin/perl

#no debugging
$trace_on_exit          = $false;
$trace_on_exit_verbose  = $false;
$trace_on_exit_concise  = $false;


# Code Configuration
#$wikistats = "/a/wikistats_git" ;
#$squids = "$wikistats/squids" ;
#$cfg_liblocation = "$squids/perl" ;

#$cfg_liblocation       = "/a/wikistats_git/squids/perl" ;
#$squids                = "/a/wikistats_git/squids" ;
$cfg_liblocation       = "/home/spetrea/wikistats/wikistats/squids/perl" ;
$squids                = "/home/spetrea/wikistats/wikistats/squids" ;



# Data configuration
$cfg_path_root_production = "$squids/csv_editors" ; 
if( ! -d $cfg_path_root_production ) {
	print "!!!!!!!!! path $cfg_path_root_production doesn't exist";
	exit(-1);
};
$cfg_path_root_test       = "w:/! perl/squids/archive/test" ;  # Erik

$cfg_dir_in_production = "/a/squid/archive/edits-geocoded" ;
$cfg_dir_in_test = "?" ; # Erik

$cfg_logname = "edits.log" ;
  
$cfg_default_argv = "-d 2011/10/16-2011/10/16" ; #set default arguments for test on local machine

$cfg_file_test = "w:/! Perl/Squids/Archive/sampled-1000.log-20111016.txt" ; # Erik
$cfg_test_maxlines = 4000000 ;

