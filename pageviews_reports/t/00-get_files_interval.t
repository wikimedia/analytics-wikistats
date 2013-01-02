#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use PageViews::Model;
use Data::Dumper;
use Test::More qw/no_plan/;

my $prefix    = "sampled-1000.log-";
my $logs_path = "data";

sub padding{
  $_[0]<10 ? "0$_[0]" : $_[0];
};

`rm ./data/$prefix*.gz`;
for my $m(1..12){
  for my $d(1..31){
    my $date=sprintf("$logs_path/$prefix"."2012%s%s.gz",padding($m),padding($d));
    `touch $date`;
  };
};


my $m = PageViews::Model->new();

my @f = $m->get_files_in_interval({
          logs_prefix => $prefix,
          logs_path   => $logs_path,
          start => {
            year  => 2012,
            month => 1,
          },
          end   => {
            year  => 2012,
            month => 1,
          },
        });

my @e = (
        'data/sampled-1000.log-20120101.gz',
        'data/sampled-1000.log-20120102.gz',
        'data/sampled-1000.log-20120103.gz',
        'data/sampled-1000.log-20120104.gz',
        'data/sampled-1000.log-20120105.gz',
        'data/sampled-1000.log-20120106.gz',
        'data/sampled-1000.log-20120107.gz',
        'data/sampled-1000.log-20120108.gz',
        'data/sampled-1000.log-20120109.gz',
        'data/sampled-1000.log-20120110.gz',
        'data/sampled-1000.log-20120111.gz',
        'data/sampled-1000.log-20120112.gz',
        'data/sampled-1000.log-20120113.gz',
        'data/sampled-1000.log-20120114.gz',
        'data/sampled-1000.log-20120115.gz',
        'data/sampled-1000.log-20120116.gz',
        'data/sampled-1000.log-20120117.gz',
        'data/sampled-1000.log-20120118.gz',
        'data/sampled-1000.log-20120119.gz',
        'data/sampled-1000.log-20120120.gz',
        'data/sampled-1000.log-20120121.gz',
        'data/sampled-1000.log-20120122.gz',
        'data/sampled-1000.log-20120123.gz',
        'data/sampled-1000.log-20120124.gz',
        'data/sampled-1000.log-20120125.gz',
        'data/sampled-1000.log-20120126.gz',
        'data/sampled-1000.log-20120127.gz',
        'data/sampled-1000.log-20120128.gz',
        'data/sampled-1000.log-20120129.gz',
        'data/sampled-1000.log-20120130.gz',
        'data/sampled-1000.log-20120131.gz',
        'data/sampled-1000.log-20120201.gz'
        );

my $matched = 0;
for my $i (0..$#f) {
  $matched += $e[$i] eq $f[$i];
};

ok($matched == @e,"All files expected were found in output of get_files_in_interval() ");

