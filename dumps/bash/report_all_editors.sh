#!/bin/bash

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$dumps/out
htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/

cd $perl
 perl WikiReports.pl -m wm -l en -i $csv/csv_wp/ -o $out/out_wp

## first rename reports (on special run only):
#  mv $out/out_wp/EN/TablesWikimediaAllProjects.htm $out/out_wp/EN/TablesWikimediaAllProjectsExceptCommons.htm
#  mv $out/out_wp/EN/TablesWikimediaAllProjects_AllMonths.htm $out/out_wp/EN/TablesWikimediaAllProjectsExceptWikidata_AllMonths.htm

## publish draft/live version:
# rsync -av $out/out_wp/EN/TablesWikimediaAllProjects*.htm $htdocs/EN/ipvb6c
  rsync -av $out/out_wp/EN/TablesWikimediaAllProjects*.htm $htdocs/EN/draft
#  rsync -av $out/out_wp/EN/TablesWikimediaAllProjects*.htm $htdocs/EN


