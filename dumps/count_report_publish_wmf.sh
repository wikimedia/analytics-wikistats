#!/bin/sh
ulimit -v 8000000

clear
cd /home/ezachte/wikistats

# COUNT

# trace=-r # trace resources
force=-f
bz2=-b # comment for default: 7z
# edits=-e
# reverts=-u 1
dumps=/mnt/dumps/xmldatadumps
date=today


perl ./WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps/public/strategywiki/latest -o /a/wikistats/csv_wx/ -l strategywiki   -d $date -s /mnt/php/languages ;
perl ./WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps/public/usabilitywiki/latest -o /a/wikistats/csv_wx/ -l usabilitywiki -d  $date -s /mnt/php/languages ;
perl ./WikiCounts.pl $edits $reverts $trace $force $bz2 -m wx -i $dumps/public/outreachwiki/latest -o /a/wikistats/csv_wx/ -l outreachwiki   -d $date -s /mnt/php/languages ;

./zip_csv.sh wx

# REPORT

perl ./WikiReports.pl -m wx -l en -i /a/wikistats/csv_wx/ -o /a/out/out_wx

./zip_out.sh wx

./publish.sh wx
