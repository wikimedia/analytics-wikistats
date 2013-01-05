#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use lib "../squids/t/";
use PageViews::Model;
use PageViews::View;
use Data::Dumper;
use Carp;

# 
# TODO: Add code to parse commandline parameters to
#       select the period on which you want the report done
#
#       Add commandline parameter for path to output data
#

our $__DATA_BASE        = "data";
my  $LOG_PREFIX         = "sampled-1000.log-";
my  $REPORT_OUTPUT_PATH = "/tmp/pageview_reports/";

`mkdir -p $REPORT_OUTPUT_PATH`;

my $m = PageViews::Model->new();
$m->process_files({
    logs_path => $__DATA_BASE,
});

my $d = $m->get_data();
my $v = PageViews::View->new($d);
$v->render({ output_path => $REPORT_OUTPUT_PATH });
