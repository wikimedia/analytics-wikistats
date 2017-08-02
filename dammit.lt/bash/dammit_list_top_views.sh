#!/bin/bash
ulimit -v 200000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
perl=/home/ezachte/wikistats/dammit.lt/perl # tests
logs=$dammit/logs 
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs


input=/a/dammit.lt/pagecounts/merged 
reports=/a/dammit.lt/pagecounts/reports 
temp=/a/dammit.lt/pagecounts/temp

cd $perl

months=1 # last n months

echo Generate monthly reports from dammit.lt monthly consolidated pagecounts files 
echo
#perl DammitReportPageRequests.pl -m $months -i $input -o $reports -t $temp
rsync -arv $reports/* $htdocs/wikimedia/pagecounts/reports
