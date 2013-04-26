#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

eval { 
  require Regexp::Assemble; 
  require Net::Patricia; 
};

if($@) {
  plan skip_all => "Regexp::Assemble and Net::Patricia not found";
} else {
  plan no_plan => 0;
};

use lib "./lib";
require PageViews::BotDetector;

my $b = PageViews::BotDetector->new;
$b->load_ip_ranges();
$b->load_useragent_regex();

is($b->match_ip("64.233.160.0"),"Google","Positive Google bot test1");
ok(!defined($b->match_ip("11.22.33.44")),"Negative bot test1");
ok(!defined($b->match_ip("corrupted_data")),"Negative bot test2");

#$v = $b->match_ip("74.125.40.255");
#$v = $b->match_ip("209.191.64.255");
#$v = $b->match_ip("2600:1007:b01f:e411:0:a:821c:8101");
#warn $b->{ua_regex};

