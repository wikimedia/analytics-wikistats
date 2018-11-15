#!/bin/bash
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
out=$dumps/out
htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/

clear 

# only when run from ../bash folder in home folder, choose accompanying perl folder
# cd ../perl is tricky, when running bash from anywhere else)  
bashpath="${PWD}"
# echo $bashpath
if [[ "$bashpath" == *ezachte* ]] ; then
  perl=/home/ezachte/wikistats/dumps/perl # tests
  echo run from test perl folder "$perl"
fi

# -y = collect editor counts for one project
# -z = collect editor counts for all projects
# reporting step generates 

cd $perl

for w in wb wk wn wo wp wq ws wv wx 
do 
  perl WikiCounts.pl -i $csv/csv_$w -o $csv/csv_$w/ -y ;
done;

perl WikiCounts.pl -i $csv/csv_wp -o $csv/csv_wp/ -z ;

perl WikiReports.pl -m wm -l en -i $csv/csv_wp -o $out/out_wp

## publish renamed version:
#  rsync -av $out/out_wp/EN/TablesWikimediaAllProjects.htm $htdocs/EN

## publish draft version:
rsync -av $out/out_wp/EN/TablesWikimediaAllProjects.htm $htdocs/EN/draft


