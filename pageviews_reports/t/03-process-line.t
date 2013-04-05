#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use PageViews::Model::Sequential;
use Data::Dumper;

my $m=PageViews::Model::Sequential->new();
my $l1="cp1042.eqiad.wmnet 559968700 2012-12-13T16:06:31 0.028339386 0000:000:000:0000:000:0000:0000:0000 hit/200 5111 GET http://en.m.wikibooks.org/apple-touch-icon.png - text/html; charset=utf-8 - - Mozilla/5.0%20(Linux;%20Android%204.1.1;%20DROID%20RAZR%20HD%20Build/9.8.1Q_39)%20AppleWebKit/535.19%20(KHTML,%20like%20Gecko)%20Chrome/18.0.1025.166%20Mobile%20Safari/535.19";
my $l2="cp1042.eqiad.wmnet 559968700 2012-12-14T16:06:31 0.028339386 0000:000:000:0000:000:0000:0000:0000 hit/200 5111 GET http://en.m.wikibooks.org/apple-touch-icon.png - text/html; charset=utf-8 - - Mozilla/5.0%20(Linux;%20Android%204.1.1;%20DROID%20RAZR%20HD%20Build/9.8.1Q_39)%20AppleWebKit/535.19%20(KHTML,%20like%20Gecko)%20Chrome/18.0.1025.166%20Mobile%20Safari/535.19";

$m->process_line($l1);
$m->process_line($l2);

ok(1);
#print Dumper $m;


