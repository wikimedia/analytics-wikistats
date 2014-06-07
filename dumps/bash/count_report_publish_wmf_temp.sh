#!/bin/sh
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
out=$dumps/out
php=/a/mediawiki/core/languages
dumps_public=/mnt/data/xmldatadumps/public

cd $perl

clear

# trace=-r # trace resources
force=-f
bz2=-b # comment for default: 7z
# edits=-e
# reverts=-u 1
date=today

perl $perl/WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps_public/strategywiki/latest  -o $csv/csv_wx/ -l strategywiki  -d $date -s $php ;
perl $perl/WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps_public/usabilitywiki/latest -o $csv/csv_wx/ -l usabilitywiki -d $date -s $php ;
perl $perl/WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps_public/outreachwiki/latest  -o $csv/csv_wx/ -l outreachwiki  -d $date -s $php ;

perl $perl/WikiReports.pl -m wx -l en -i $csv/csv_wx/ -o $out/out_wx
