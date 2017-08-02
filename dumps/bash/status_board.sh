#!/bin/sh

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$dumps/out
report=$dumps/logs/log_pageviews_monthly.txt
projectcounts=/a/dammit.lt/projectcounts
# projectcounts=/home/ezachte/test/projectcounts  # tests
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $perl

perl WikiReportsStatusBoard.pl

cp $csv/csv_wp/PageViewsPerDay-SB-Trend.csv $wikistats/tmp/pv-trend.csv
rsync -av $wikistats/tmp/pv-trend.csv $htdocs/wikimedia/status 
cp $csv/csv_wp/PageViewsPerDay-SB-Recent.csv $wikistats/tmp/pv-recent.csv
rsync -av $wikistats/tmp/pv-recent.csv $htdocs/wikimedia/status 
