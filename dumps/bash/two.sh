#!/bin/bash

ulimit -v 8000000
clear

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
bash=$dumps/bash
logs=$dumsp/logs
csv=$dumps/csv
out=$dumps/out
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs

mode=wo
lang=en

cd $perl
perl WikiReports.pl -m $mode -l $lang -i $csv/csv_$mode/ -o $out/out_$mode
rsync -av  $out/out_$mode/EN/* $htdocs/wikivoyage/EN/
