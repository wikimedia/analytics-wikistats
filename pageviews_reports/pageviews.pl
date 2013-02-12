#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use PageViews::ParallelModel;
use PageViews::Model;
use PageViews::View;
use Data::Dumper;
use JSON::XS;
use Carp;
use Getopt::Long;

my  $mode         = "sequential";
our $INPUT_PATH   = "/home/user/wikidata";
my  $OUTPUT_PATH  = "/tmp/pageview_reports";
my  $max_children = 4;

GetOptions(
  "mode=s"         => \$mode,
  "input-path=s"   => \$INPUT_PATH,
  "output-path=s"  => \$OUTPUT_PATH,
  "max-children=i" => \$max_children,
);

`
mkdir -p $OUTPUT_PATH
mkdir -p $OUTPUT_PATH/map
rm    -f $OUTPUT_PATH/map/*.json
rm    -f $OUTPUT_PATH/map/*.err
`;

confess "[ERROR] --mode is supposed to be parallel or sequential"
  unless $mode eq "sequential" || $mode eq "parallel";

confess "[ERROR] --input-path argument is not a valid path"
  unless -d $INPUT_PATH;

confess "[ERROR] --output-path argument is not a valid path"
  unless -d $OUTPUT_PATH;

confess "[ERROR] --max-children argument is not a valid integer"
  unless $max_children =~ /^\d+$/;

my $model;

if($mode eq "sequential") {
  $model = PageViews::Model->new();
} elsif($mode eq "parallel") {
  $model = PageViews::ParallelModel->new();
};

my $process_files_params = {
    logs_prefix => "sampled-1000.log-",
    logs_path   => $INPUT_PATH,
    start       => {
      year  => 2012,
      #month => 1,
      month => 8,
    },
    end         => {
      year  => 2012,
      #month => 12,
      month => 12,
    },
};

#
# USAGE example:
#
# ./pageviews.pl --input-path /a/squid/archive/sampled-geocoded --mode=parallel --max-children=9
#
#

if($mode eq "parallel") {
  $process_files_params->{children_output_path} = "$OUTPUT_PATH/map";
  $process_files_params->{max_children}         = $max_children;
};

$model->process_files($process_files_params);
my $d = $model->get_data();

open my $json_fh,">$OUTPUT_PATH/out.json";
print   $json_fh JSON::XS->new
                         ->pretty(1)
                         ->canonical(1)
                         ->encode($d);
close   $json_fh;

my $v = PageViews::View->new($d);
$v->render({ 
    output_path => $OUTPUT_PATH 
});
