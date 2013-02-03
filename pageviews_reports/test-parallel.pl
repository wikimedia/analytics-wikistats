#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use lib "../squids/t/";
use PageViews::ParallelModel;
use PageViews::View;
use PageViews::Generate1;
use Generate::Squid;
use JSON::XS;
use CommonConfig;
use Data::Dumper;
use Carp;

our $__CODE_BASE;
our $__DATA_BASE        = "$__CODE_BASE/../pageviews_reports/data";
my  $LOG_PREFIX         = "sampled-1000.log-";
my  $REPORT_OUTPUT_PATH = "/tmp/pageview_reports/";

`
mkdir -p $REPORT_OUTPUT_PATH
mkdir -p $REPORT_OUTPUT_PATH/map
rm    -f $REPORT_OUTPUT_PATH/map/*.json
rm    -f $REPORT_OUTPUT_PATH/map/*.err
`;

# overall_count_delta is the percentage by which counts increased/decreased
# over the previous month
my $config = [
  {
    month => "2012-10",
    explicit_country_counts => {
      en                    => 400 ,
      fr                    => 100 ,
      de                    => 30  ,
      "invalid-language123" => 100 ,
      bot                   => 200 ,
    },
  },
  {
    month => "2012-11",
    overall_count_delta => 0.24,
  },
  {
    month => "2012-12",
    overall_count_delta => 0.30,
  },
  {
    month => "2013-01",
    overall_count_delta => -0.1,
  },
  {
    month => "2013-02",
    explicit_country_deltas => {
      en => -0.3 ,
      de => +0.2 ,
      fr => -0.02,
    },
  },
];

my $g = PageViews::Generate1->new({
      config     => $config,
    __DATA_BASE  => $__DATA_BASE,
      LOG_PREFIX => $LOG_PREFIX,
});
$g->generate();

my $m = PageViews::ParallelModel->new();
$m->process_files({
    logs_path    => $__DATA_BASE,
    logs_prefix  => $LOG_PREFIX,
    max_children => 3,
    children_output_path => "$REPORT_OUTPUT_PATH"."map",
    start       => {
      year  => 2012,
      month => 10,
    },
    end         => {
      year  => 2013,
      month => 2,
    },
});

my $d = $m->get_data();
open my $json_fh,">$REPORT_OUTPUT_PATH"."out.json";
print   $json_fh JSON::XS->new
                         ->pretty(1)
                         ->canonical(1)
                         ->encode($d);
close   $json_fh;
#warn Dumper $d;
#warn Dumper $m->get_files_in_interval();
#exit 0;

my $v = PageViews::View->new($d);
$v->render({ output_path => $REPORT_OUTPUT_PATH });
