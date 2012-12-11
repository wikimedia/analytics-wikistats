#!/usr/bin/perl
require 't/CommonConfig.pm';

$__DATA_BASE             = "$__CODE_BASE/testdata/regression-sample";
#no tracing
$trace_on_exit          = $false;
$trace_on_exit_verbose  = $false;
$trace_on_exit_concise  = $false;

# Code configuration
$cfg_liblocation       = "$__CODE_BASE/perl" ;
$squids                = "$__CODE_BASE" ;


# Data configuration

$cfg_path_csv          = "$__DATA_BASE/csv" ;
$cfg_path_reports      = "$__DATA_BASE/reports" ;
$cfg_path_log          = "$__DATA_BASE/logs" ;

$cfg_default_argv = "-m 2011-08" ;   # monthly report
