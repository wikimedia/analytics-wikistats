#!/bin/sh
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
out=$dumps/out

clear
# -y = collect editor counts for one project
# -z = collect editor counts for all projects
# reporting step generates 

cd $perl

for w in wb wk wn wp wq ws wv wx 
do 
  perl WikiCounts.pl -i $csv/csv_$w -o $csv/csv_$w/ -y ;
done;

perl WikiCounts.pl -i $csv/csv_wp -o $csv/csv_wp/ -z ;

perl WikiReports.pl -m wm -l en -i $csv/csv_wp -o $out/out_wp

