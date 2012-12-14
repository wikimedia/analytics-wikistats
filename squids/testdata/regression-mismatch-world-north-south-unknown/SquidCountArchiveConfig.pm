#!/usr/bin/perl
require 't/CommonConfig.pm';

$__DATA_BASE             = "$__CODE_BASE/testdata/regression-mismatch-world-north-south-unknown";
#no tracing
$trace_on_exit            = $false;
$trace_on_exit_verbose    = $false;
$trace_on_exit_concise    = $false;

$cfg_liblocation          = "$__CODE_BASE/perl" ;
$squids                   = "$__CODE_BASE" ;

$cfg_path_root_production = "$__DATA_BASE/csv" ;
$cfg_dir_in_production    = "$__DATA_BASE" ;

$cfg_logname              = "sampled-1000.log" ;
