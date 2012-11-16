#!/bin/sh
ulimit -v 8000000

perl=/a/wikistats/scripts/perl
dumps=/mnt/data/xmldatadumps/public
csv=/a/wikistats/csv
out=/a/wikistats/out
php=/a/mediawiki/core/languages

cd $perl

clear

# trace=-r # trace resources
force=-f
bz2=-b # comment for default: 7z
# edits=-e
# reverts=-u 1
date=today

perl $perl/WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps/strategywiki/latest  -o $csv/csv_wx/ -l strategywiki  -d $date -s $php ;
perl $perl/WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps/usabilitywiki/latest -o $csv/csv_wx/ -l usabilitywiki -d $date -s $php ;
perl $perl/WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps/outreachwiki/latest  -o $csv/csv_wx/ -l outreachwiki  -d $date -s $php ;

perl $perl/WikiReports.pl -m wx -l en -i $csv/csv_wx/ -o $out/out_wx
