#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
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

#our $__DATA_BASE        = "data";
our $__DATA_BASE        = "/home/user/wikidata";
my  $REPORT_OUTPUT_PATH = "/tmp/pageview_reports/";

`mkdir -p $REPORT_OUTPUT_PATH`;

my $m = PageViews::Model->new();
$m->process_files({
    logs_prefix => "sampled-1000.log-",
    logs_path   => $__DATA_BASE,
    start       => {
      year  => 2012,
      #month => 1,
      month => 11,
    },
    end         => {
      year  => 2012,
      #month => 12,
      month => 11,
    },
});

my $d = $m->get_data();
#print Dumper $d;
#exit 0;
my $v = PageViews::View->new($d);
$v->render({ 
    output_path => $REPORT_OUTPUT_PATH 
});
