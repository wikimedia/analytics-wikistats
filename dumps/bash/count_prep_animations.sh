#!/bin/sh
# prep input files of form AnimationProjectsGrowthInitWp.js for animation on project growth 
# http://stats.wikimedia.org/wikimedia/animations/growth/AnimationProjectsGrowthWp.html

ulimit -v 8000000
clear

wikistats=/a/wikistats_git
dumps=$wikistats/dumps       
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$wikistats/animations/growth
htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $perl

#for project in wb wk wn wo wp wq ws wv wx 
#do perl WikiReports.pl -a -i $csv/csv_$project -o $out -m $project -l en
#done

rsync -a $out/EN/* $htdocs/wikimedia/animations/growth 
