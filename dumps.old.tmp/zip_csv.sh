#!/bin/bash

if [ "$1" == "" ] ; then
  echo "Project code missing! Specify as 1st argument one of wb,wk,wn,wp,wq,ws,wv,wx"
  exit
fi  

cd /a/wikistats/csv_$1

echo "rebuild /a/wikistats/zip_all/csv_$1.zip"
rm     /a/wikistats/zip_all/csv_$1.zip
zip -q /a/wikistats/zip_all/csv_$1.zip *.csv         -x Revert* EditsBreakdownPerUserPerMonth*XX*.csv

echo "rebuild /a/wikistats/zip_all/csv_$1_reverts.zip"
rm     /a/wikistats/zip_all/csv_$1_reverts.zip
zip -q /a/wikistats/zip_all/csv_$1_reverts.zip *.csv -i Revert*

echo "rebuild /a/wikistats/zip_all/bz2_$1.zip"
rm     /a/wikistats/zip_all/bz2_$1.zip
zip -q /a/wikistats/zip_all/bz2_$1.zip *.bz2

echo ""
echo "rsync -avv /a/wikistats/zip_all/csv_*.zip /mnt/dumps/xmldatadumps/public/other/pagecounts-ez/wikistats"
rsync -avv /a/wikistats/zip_all/csv_*.zip /mnt/dumps/xmldatadumps/public/other/pagecounts-ez/wikistats
