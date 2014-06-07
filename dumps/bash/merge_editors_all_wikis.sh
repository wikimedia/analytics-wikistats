#!/bin/bash
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
csv=$dumps/csv
out=$dumps/csv/csv_mw
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

clear 
cd $perl ;

# -c input directory (csv files)
# -o output files: [..].tsv and [..]ByUser.tsv   
# -p projects log file
date > EditsPerUserMonthNamespaceAllWikisMeta.txt
perl WikiCountsMergeMonthlyEditsAllWikis.pl -c $csv -o $out/EditsPerUserMonthNamespaceAllWikis.tsv -p $out/EditsPerUserMonthNamespaceAllWikisProjects.csv | tee $out/EditsPerUserMonthNamespaceAllWikisMeta.txt | cat

cd $out

zip EditsPerUserMonthNamespaceAllWikis.zip EditsPerUserMonthNamespaceAllWikis.tsv EditsPerUserMonthNamespaceAllWikisProjects.csv 

echo "File sizes:"                                  >> EditsPerUserMonthNamespaceAllWikisMeta.txt
ls -h -l EditsPerUserMonthNamespaceAllWikis.tsv     >> EditsPerUserMonthNamespaceAllWikisMeta.txt
ls -h -l EditsPerUserMonthNamespaceAllWikis.zip     >> EditsPerUserMonthNamespaceAllWikisMeta.txt
head -n 1000 EditsPerUserMonthNamespaceAllWikis.tsv >  EditsPerUserMonthNamespaceAllWikisSample.tsv 

zip EditsPerUserMonthNamespaceAllWikisPreview.zip EditsPerUserMonthNamespaceAllWikisProjects.csv EditsPerUserMonthNamespaceAllWikisSample.tsv EditsPerUserMonthNamespaceAllWikisMeta.txt

sort -t\t EditsPerUserMonthNamespaceAllWikis2.tsv > EditsPerUserMonthNamespaceAllWikisSortedByUser.tsv
# rm EditsPerUserMonthNamespaceAllWikisByUser.tsv 
exit
cd $perl

perl WikiCountsFindMigrationPatterns.pl -c $out 

