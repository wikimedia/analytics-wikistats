#!/bin/bash

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
# perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$dumps/out
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

cd $perl
perl WikiReports.pl -m wm -l en -i $csv/csv_wp/ -o $out/out_wp

## publish renamed version:
#  rsync -av $out/out_wp/EN/TablesWikimediaAllProjects.htm $htdocs/EN

## publish draft version:
   rsync -av $out/out_wp/EN/TablesWikimediaAllProjects.htm $htdocs/EN/draft

## publish renamed version:
#  mv $out/out_wp/EN/TablesWikimediaAllProjects.htm $out/out_wp/EN/TablesWikimediaAllProjectsNoWikivoyage.htm
#  rsync -av $out/out_wp/EN/TablesWikimediaAllProjectsNoWikivoyage.htm $htdocs/EN/draft

