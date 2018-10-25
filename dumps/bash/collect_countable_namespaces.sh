#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

yyyymmdd=$(date +"%Y_%m_%d")

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

logfile=$wikistats_data/dumps/logs/namespaces/log_namespaces_$yyyymmdd.txt
exec 1> $logfile 2>&1 # send stdout/stderr to file

date
export http_proxy=http://webproxy.eqiad.wmnet:8080 # Jan 2015 see https://wikitech.wikimedia.org/wiki/Http_proxy
export https_proxy=http://webproxy.eqiad.wmnet:8080

perl=$wikistats/dumps/perl 
csv=$wikistats_data/dumps/csv
dblists=$wikistats/dumps/dblists/master%20copy # to be fixed: folder has space in name, here as %20
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

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


