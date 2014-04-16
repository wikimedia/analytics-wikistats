#!/usr/bin/perl

#no debugging
$trace_on_exit          = $false;
$trace_on_exit_verbose  = $false;
$trace_on_exit_concise  = $false;

# Code configuration
#$wikistats             = "/home/spetrea/wikistats/wikistats" ;
#$cfg_liblocation       = "/a/wikistats_git/squids/perl" ;
#$squids                = "/a/wikistats_git/squids" ;
$cfg_liblocation       = "/home/spetrea/wikistats/wikistats/squids/perl" ;
$squids                = "/home/spetrea/wikistats/wikistats/squids" ;



# Data configuration

$cfg_path_csv          = "$squids/csv_editors" ;
$cfg_path_reports      = "$squids/reports_editors" ;
$cfg_path_log          = "$squids/logs_editors" ;

$cfg_path_csv_test     = "W:/# Out Locke" ;      # Erik
$cfg_path_reports_test = "W:/# Out Test/Locke" ; # Erik
$cfg_path_log_test     = "W:/# Out Test/Locke" ; # Erik
# $cfg_path_csv_test     = "/srv/erik/" ;          # André
# $cfg_path_reports_test = "/srv/erik/" ;          # André
# $cfg_path_log_test     = "/srv/erik/" ;          # André

# set default arguments for test on local machine
$cfg_default_argv = "-m 2011-08" ;   # monthly report
