#!/bin/sh
ulimit -v 8000000

clear
set=wp
trace=-r # trace resources
dumps=/mnt/dumps/xmldatadumps

# force=-f
# bz2=-b # comment for default: 7z
# reverts=-u 1 # uncomment to collect revert history only
# edits_only=-e 

#for x in `cat ./dblists/wikipedia.dblist` 
for x in enwiki 
do perl WikiCounts.pl $trace $force $reverts $edits_only $bz2 -m $set -i $dumps/public/$x -o /a/wikistats/csv_$set/ -l $x -d auto -s /mnt/php/languages ;
done;

#./zip_csv.sh $set
