#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

# daily run of wikistats for staff wikis
# no longer active

ulimit -v 8000000

yyyymmdd=$(date +"%Y_%m_%d")

dumps_public=/mnt/data/xmldatadumps/public
php=/srv/mediawiki/core/languages

logs=$wikistats_data/dumps/logs/wmf_wikis
logfile_job=$logs/report_counts_wmf_wikis_$yyyymmdd.txt

exec 1> $logfile_job 2>&1 # send stdout/stderr to file

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

perl=$wikistats/dumps/perl
csv=$wikistats_data/dumps/csv
out=$wikistats_data/dumps/out

mkdir -p $logs

cd $perl

# comment runtime option to omit it
# trace=-r # trace resources
force=-f # update even if dump already had been processed
bz2=-b # comment for default: 7z
# edits=-e
# reverts=-u 1
date=today

{ set +x; } 2>/dev/null ; echo "\n=== Collect counts for trategy, usability and outreach wikis ===" ; set -x

perl WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps_public/strategywiki/latest  -o $csv/csv_wx/ -l strategywiki  -d $date -s $php ;
perl WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps_public/usabilitywiki/latest -o $csv/csv_wx/ -l usabilitywiki -d $date -s $php ;
perl WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps_public/outreachwiki/latest  -o $csv/csv_wx/ -l outreachwiki  -d $date -s $php ;

{ set +x; } 2>/dev/null ; echo "\n=== Generate reports ===" ; set -x

perl WikiReports.pl -m wx -l en -i $csv/csv_wx/ -o $out/out_wx
