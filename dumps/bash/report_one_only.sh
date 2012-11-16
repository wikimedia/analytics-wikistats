#!/bin/bash

ulimit -v 8000000
clear

perl=/a/wikistats/scripts/perl
bash=a/wikistats/scripts/bash
logs=/a/wikistats/logs
csv=/a/wikistats/csv
out=/a/wikistats/out
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

mode=wx
lang=en

cd $perl
perl WikiReports.pl -m $mode -l $lang -i $csv/csv_$mode/ -o $out/out_$mode 


