#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use lib "../squids/t/";
use PageViews::Model;
use PageViews::View;
use PageViews::Generate1;
use Generate::Squid;
use CommonConfig;
use Data::Dumper;
use Carp;

our $__CODE_BASE;
our $__DATA_BASE        = "$__CODE_BASE/../pageviews_reports/data";
my  $LOG_PREFIX         = "sampled-1000.log-";
my  $REPORT_OUTPUT_PATH = "/tmp/pageview_reports/";

`mkdir -p $REPORT_OUTPUT_PATH`;

# overall_count_delta is the percentage by which counts increased/decreased
# over the previous month
my $config = [
  {
    month => "2012-10",
    explicit_country_counts => {
      "US" => 400,
      "GB" => 300 ,
      "CA" => 100 ,
      "FR" => 100 ,
      "DE" => 100 ,
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
];

my $g = PageViews::Generate1->new({
      config     => $config,
    __DATA_BASE  => $__DATA_BASE,
      LOG_PREFIX => $LOG_PREFIX,
});
$g->generate();


my $m = PageViews::Model->new();
$m->process_files({
    logs_path => $__DATA_BASE,
});

#$Template::Directive::WHILE_MAX = 9999999;

my $d = $m->get_data();
warn "[DBG]".Dumper($d);

my $v = PageViews::View->new($d);

warn "[DBG] outpath => $REPORT_OUTPUT_PATH";
$v->render({ output_path => $REPORT_OUTPUT_PATH });
