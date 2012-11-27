#!/bin/sh
ulimit -v 1000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
out=$dumps/out
dammit=/a/dammit.lt
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs

cd $perl
perl WikiCountsJobProgress.pl -i $dumps -d $dammit -o $out -u $wikistats -p $perl

rsync -av $out/out_wm/WikiCountsJobProgress*.html $htdocs

