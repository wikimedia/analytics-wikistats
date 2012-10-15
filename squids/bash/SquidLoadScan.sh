#!/bin/bash
ulimit -v 4000000

# read all files on squid log aggregator with hourly counts for
# - number of events received per squid
# - average gap in sequence numbers (this should be 1000 idealy on a 1:1000 sampled log)
# write several aggregations of these data

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
csv=$squids/csv


cd $perl

nice perl SquidLoadScan.pl -i $csv -o $csv/load
