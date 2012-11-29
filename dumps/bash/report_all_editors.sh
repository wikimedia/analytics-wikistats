#!/bin/bash

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
out=$dumps/out
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

cd $perl
perl WikiReports.pl -m wm -l en -i $csv/csv_wp/ -o $out/out_wp
rsync -av $out/out_wp/EN/TablesWikimediaAllProjects* $htdocs/EN

