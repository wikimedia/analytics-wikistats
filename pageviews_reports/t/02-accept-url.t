#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use lib "./lib";
use PageViews::Model::Sequential;
use Data::Dumper;

my $re_str = PageViews::Model::Sequential::build_accepted_url_regex1();
my $re = qr/$re_str/;

my $u1 = "http://en.m.wikipedia.org/wiki/Mr.T";
my $u2 = "http://de.m.wikibooks.org/w/index.php/Mr.T";
my $u3 = "http://ja.m.wikinews.org/w/api.php?action=mobileview";
my $u4 = "http://ja.m.wikinews.org/w/api.php?action=view";


my @c1 = $u1 =~ $re;
my @c2 = $u2 =~ $re;
my @c3 = $u3 =~ $re;
my @c4 = $u4 =~ $re;

ok(@c1==5,"u1 test has 5 captures");
ok(@c2==5,"u2 test has 5 captures");
ok(@c3==5,"u3 test has 5 captures");
ok(@c4==5,"u4 test has 5 captures");

#print Dumper \@c3;




