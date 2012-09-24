#!/usr/bin/perl


my $base = "/home/user/wikistats/wikistats";
my $prod_base = "home/user/wikistats/wikistats/prod/stats/";

$cfg_liblocation       = "$base/scripts" ;

$cfg_path_csv          = "$base/csv" ;

$cfg_path_reports      = "$base/reports" ;
#`mkdir -p $cfg_path_reports`;

$cfg_path_log          = "$base/log" ;

$cfg_path_csv_test     = "$base/test/csv";
$cfg_path_reports_test = "$base/test/reports";
$cfg_path_log_test     = "$base/test/log";

# set default arguments for test on local machine
$cfg_default_argv = "-m 2012-07" ;   # monthly report
# $cfg_default_argv = "-w" ;           # refresh country info from Wikipedia (population etc)
# $cfg_default_argv = "-c" ;           # country/regional reports
# $cfg_default_argv = "-c -q 2011Q4" ; # country/regional reports based on data for one quarter only


