#!/bin/sh

ulimit -v 100000

wikistats=/a/wikistats_git
perl=$wikistats/dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$wikistats/dumps/csv
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

clear

cd $csv/csv_mw
cp StatisticsContentNamespacesExtraNamespaces.csv StatisticsContentNamespacesExtraNamespaces.bak

cd $perl
perl WikiCountsScanNamespacesWithContent.pl -c $csv

cd $csv/csv_mw
grep "project" StatisticsContentNamespaces.csv >  StatisticsContentNamespacesExtraNamespaces.csv # first line with headers
grep "0|"      StatisticsContentNamespaces.csv >> StatisticsContentNamespacesExtraNamespaces.csv

date >> StatisticsContentNamespacesExtraNamespacesDiff.csv
diff StatisticsContentNamespacesExtraNamespaces.csv StatisticsContentNamespacesExtraNamespaces.bak >> StatisticsContentNamespacesExtraNamespacesDiff.csv

rsync -av StatisticsContentNamespacesExtraNamespaces.csv $htdocs/wikimedia/misc


