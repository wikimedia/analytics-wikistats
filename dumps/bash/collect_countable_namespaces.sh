#!/bin/sh

ulimit -v 100000

wikistats=/a/wikistats_git
perl=$wikistats/dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$wikistats/dumps/csv
dblists=$wikistats/dumps/dblists/master%20copy # to be fixed: folder has space in name, here as %20
htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

clear

cd $csv/csv_mw
cp StatisticsContentNamespacesExtraNamespaces.csv StatisticsContentNamespacesExtraNamespaces.bak

cd $perl
perl WikiCountsScanNamespacesWithContent.pl -c $csv -l $dblists

cd $csv/csv_mw
grep "project" StatisticsContentNamespaces.csv >  StatisticsContentNamespacesExtraNamespaces.csv # first line with headers
grep "0|"      StatisticsContentNamespaces.csv >> StatisticsContentNamespacesExtraNamespaces.csv

date >> StatisticsContentNamespacesExtraNamespacesDiff.csv
diff StatisticsContentNamespacesExtraNamespaces.csv StatisticsContentNamespacesExtraNamespaces.bak >> StatisticsContentNamespacesExtraNamespacesDiff.csv

rsync -av StatisticsContentNamespacesExtraNamespaces.csv $htdocs/wikimedia/misc


