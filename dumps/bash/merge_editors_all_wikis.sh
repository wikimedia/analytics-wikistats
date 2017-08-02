#!/bin/bash
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
csv=$dumps/csv
out=$dumps/csv/csv_mw
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

clear 
cd $out 

echo "sort by user (alpha), project (alpha), language (alpha), month (alpha), namespace (numeric, low to high)"  
sort -t $'\t' -k 1,1 -k 4,4 -k 5,5 -k 3,3 -k 6n,6 EditsPerUserMonthNamespaceAllWikisSortedByUserByPeriod.tsv > EditsPerUserMonthNamespaceAllWikisSortedByUserByWikiByPeriod.tsv
exit
# -c input directory (csv files)
# -o output files: [..].tsv and [..]ByUser.tsv   
# -p projects log file
date > EditsPerUserMonthNamespaceAllWikisMeta.txt
perl $perl/WikiCountsMergeMonthlyEditsAllWikis.pl\
           -1 \
           -c $csv \
           -o $out/EditsPerUserMonthNamespaceAllWikis~1.tsv \
           -p $out/EditsPerUserMonthNamespaceAllWikisProjects.csv \
          | tee $out/EditsPerUserMonthNamespaceAllWikisMeta.txt | cat
echo "sort by user (alpha), project (alpha), language (alpha), userid (high to low)" 
sort -t $'\t' -k 1,1 -k 4,4 -k 5,5 -k 2nr,2 EditsPerUserMonthNamespaceAllWikis~1.tsv > EditsPerUserMonthNamespaceAllWikis~2.tsv

# fix editor names with user id zero (patch phase triggered by -f)
perl $perl/WikiCountsMergeMonthlyEditsAllWikis.pl \
           -2 \
           -f $out/EditsPerUserMonthNamespaceAllWikis~2.tsv \
           -o $out/EditsPerUserMonthNamespaceAllWikis~3.tsv \
           | tee -a $out/EditsPerUserMonthNamespaceAllWikisMeta.txt | cat

echo "sort by user (alpha), project (alpha), language (alpha), month (alpha), namespace (numeric, low to high)"  
sort -t $'\t' -k 1,1 -k 4,4 -k 5,5 -k 3,3 -k 6n,6 EditsPerUserMonthNamespaceAllWikis~3.tsv > EditsPerUserMonthNamespaceAllWikisSortedByUser.tsv
echo "sort by user (alpha), month (alpha), project (alpha), language (alpha), namespace (numeric, low to high)"  
sort -t $'\t' -k 1,1 -k 3,3 -k 4,4 -k 5,5 -k 6n,6 EditsPerUserMonthNamespaceAllWikis~3.tsv > EditsPerUserMonthNamespaceAllWikis~4.tsv

# fix editor names with user id zero (patch phase triggered by -f)
perl $perl/WikiCountsMergeMonthlyEditsAllWikis.pl \
           -3 \
           -f $out/EditsPerUserMonthNamespaceAllWikis~4.tsv \
           -o $out/EditsPerUserMonthNamespaceAllWikisSortedByUserByPeriod.tsv \
           | tee -a $out/EditsPerUserMonthNamespaceAllWikisMeta.txt | cat

echo "sort by user (alpha), project (alpha), language (alpha), month (alpha), namespace (numeric, low to high)"  
sort -t $'\t' -k 1,1 -k 4,4 -k 5,5 -k 3,3 -k 6n,6 EditsPerUserMonthNamespaceAllWikisSortedByUserByPeriod.tsv > EditsPerUserMonthNamespaceAllWikisSortedByUserByWikiByPeriod.tsv

zip EditsPerUserMonthNamespaceAllWikis.zip EditsPerUserMonthNamespaceAllWikisSortedByUser.tsv EditsPerUserMonthNamespaceAllWikisProjects.csv 

echo "File sizes:"                                               >> EditsPerUserMonthNamespaceAllWikisMeta.txt
ls -h -l EditsPerUserMonthNamespaceAllWikisSortedByUser.tsv      >> EditsPerUserMonthNamespaceAllWikisMeta.txt
ls -h -l EditsPerUserMonthNamespaceAllWikis.zip                  >> EditsPerUserMonthNamespaceAllWikisMeta.txt
head -n 1000 EditsPerUserMonthNamespaceAllWikisSortedByUser.tsv  >  EditsPerUserMonthNamespaceAllWikisSample.tsv

zip EditsPerUserMonthNamespaceAllWikisPreview.zip \
    EditsPerUserMonthNamespaceAllWikisProjects.csv \
    EditsPerUserMonthNamespaceAllWikisSample.tsv \
    EditsPerUserMonthNamespaceAllWikisMeta.txt

# rm EditsPerUserMonthNamespaceAllWikis~*.tsv 
exit

$perl/perl WikiCountsFindMigrationPatterns.pl -c $out 

