#!/usr/bin/perl

$cfg_liblocation = "/a/squid/stats/scripts" ;

$cfg_path_root_production = "/home/user/wikistats/wikistats/prod/stats/csv" ; 
`mkdir -p $cfg_path_root_production`;
$cfg_path_root_test       = "/home/user/wikistats/wikistats/test/csv";

$cfg_dir_in_production = "/a/squid/archive/sampled" ;
$cfg_dir_in_test = "/home/user/wikistats/wikistats";

$cfg_logname = "sampled-1000.log" ;

# set default arguments for test on local machine
#$cfg_default_argv = "-d 2011/10/16-2011/10/16" ;

$cfg_file_test = "/home/user/wikistats/wikistats/test/sampled-1000.log-20120701.txt";
$cfg_test_maxlines = 4000000 ;

