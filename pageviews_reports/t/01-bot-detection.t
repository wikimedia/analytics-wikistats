#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use lib "./lib";
use PageViews::BotDetector;

my $b = PageViews::BotDetector->new;
my $v;
$b->load_ip_ranges();
$b->load_useragent_regex();
#$v = $b->match_ip("64.233.160.0");
#$v = $b->match_ip("74.125.40.255");
#$v = $b->match_ip("209.191.64.255");
warn $b->{ua_regex};

print "v=$v\n";
