#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use PageViews::Model::Sequential;
use Data::Dumper;
use Test::More qw/no_plan/;
use Time::Piece;

my $test_config = {
  "model"                => "sequential",
  "max-children"         => 8,
  "input-path"           => "/tmp/pageviews-reports-test-02",
  "children-output-path" => "/tmp/pageviews-reports-test-02/map",
  "output-path"          => "/tmp/pageviews-reports-test-02",
  "output-formats"       => ["web"],
  "logs-prefix"          => "sampled-1000.log-",
  "start"    => {
    "year"   => 2012,
    "month"  => 1
  },
  "end"      => {
    "year"   => 2012,
    "month"  => 1
  }
};

my $logs_path = $test_config->{"input-path" };
my $prefix    = $test_config->{"logs-prefix"};

#######################
# Create dummy logs
# for 2012
#######################
`mkdir -p $logs_path`;
`rm $logs_path/$prefix*.gz`;
for my $m(1..12){
  for my $d(1..31){
    my $M    = sprintf("%02d",$m);
    my $D    = sprintf("%02d",$d);
    my $logfile = sprintf("$logs_path/$prefix"."2012%s%s.gz",$M,$D);
    `touch $logfile 2>/dev/null`;
  };
};

my $m = PageViews::Model::Sequential->new();

my @f = $m->get_files_in_interval($test_config);

my $e_iter = Time::Piece->strptime("2012-01-01","%Y-%m-%d");
my $e_end  = Time::Piece->strptime("2012-02-02","%Y-%m-%d");
my @e = ();

my  $ONE_DAY = $PageViews::Model::Sequential::ONE_DAY;
while($e_iter < $e_end) {
  my $t = $e_iter->ymd("");
  my $p = $test_config->{logs_prefix};
  push @e,"$logs_path/$prefix$t.gz";
  $e_iter += $ONE_DAY;
};


ok(@e == (1+Time::Piece->strptime("2012-01-01","%Y-%m-%d")->month_last_day),
   "All files expected were found in output of get_files_in_interval() ");

