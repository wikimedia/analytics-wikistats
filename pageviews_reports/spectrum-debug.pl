#!/usr/bin/env perl
use strict;
use warnings;
use Template;

my $tt = Template->new({
    INCLUDE_PATH => "./templates",
    OUTPUT_PATH  => "/tmp/pageview_reports/",
    DEBUG        => 1,
}); 
$tt->process(
    "color-spectrum-d3-debug.tt",
    {
      min_language_delta => -100, 
      max_language_delta => +1_600_001, 
    },
    "color-spectrum-d3-debug.html",
) || confess $tt->error();

