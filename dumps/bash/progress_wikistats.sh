#!/bin/sh -x
ulimit -v 1000000

# generate progress reports (public, extended, synopsis) for processing dumps
# publish at 
# https://stats.wikimedia.org/WikiCountsJobProgress.html         # public version, linked from Wikistats index.html
# https://stats.wikimedia.org/WikiCountsJobProgressCurrent.html  # extended version for daily monitoring by staff
# https://stats.wikimedia.org/WikiCountsJobProgressSynopsis.html # super concise version, can be viewed on mobile (experimental) 
 
wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA
perl=$wikistats/dumps/perl
out=$wikistats_data/dumps/out
dumps=$wikistats_data/dumps
dammit=$wikistats_data/dammit
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs

cd $perl
perl WikiCountsJobProgress.pl -i $dumps -d $dammit -o $out -u $wikistats -p $perl
rsync -av $out/out_wm/WikiCountsJobProgress*.html $htdocs

