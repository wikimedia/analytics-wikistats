#!/bin/sh
ulimit -v 8000000

clear
set=wx
# force=-f
edits_only=-e
dumps=/mnt/dumps/xmldatadumps

for x in `cat ./dblists/special.dblist` 
#for x in "commonswiki" 
do perl WikiCounts.pl $force $edits_only -m $set -i $dumps/public/$x -o /a/wikistats/csv_$set/ -l $x -d auto -s /mnt/php/languages ;
done;

./zip_csv.sh $set
