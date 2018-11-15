#!/bin/bash
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$dumps/out
htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/

clear 

cd $perl

perl WikiCountsPageHistorySizes.pl 
