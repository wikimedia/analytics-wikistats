#!/bin/sh
ulimit -v 1000000
#wikistats=/a/wikistats_git
wikistats=/srv/stat1002-a/wikistats_git
dumps=$wikistats/dumps

perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests

out=$dumps/out
dammit=/a/dammit.lt
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs

cd $perl
perl WikiCountsJobProgress.pl -i $dumps -d $dammit -o $out -u $wikistats -p $perl

echo "rsync -av $out/out_wm/WikiCountsJobProgress*.html $htdocs"

rsync -av $out/out_wm/WikiCountsJobProgress*.html $htdocs

