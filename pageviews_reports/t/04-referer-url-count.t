#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use lib "./lib";
use PageViews::Model::Sequential;
use Data::Dumper;

# For mobile pageviews a pageview is counted when the title/domain of the url differs
# from the title/domain of the referer.
#
# This test will test exactly that for the process_line($self,$line) method with a
# positive and a negative test.


ok(1);


