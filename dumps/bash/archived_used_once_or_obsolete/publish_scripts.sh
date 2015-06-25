#!/bin/sh

htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/
perl=/a/wikistats/scripts/perl

cd $perl

echo "Zip scripts"
#rm WikiCounts.zip
#rm WikiReports.zip
#rm scripts.zip

#zip WikiCounts.zip  WikiCounts*.pl  WikiCounts*.pm 
#zip WikiReports.zip WikiReports*.pl WikiReports*.pm
#zip scripts.zip WikiCounts.zip WikiReports.zip

echo "Publish scripts"
rsync -av scripts.zip $htdocs
