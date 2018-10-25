#! /bin/bash -x
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

yyyymmdd=$(date +"%Y_%m_%d")

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

logfile=$wikistats_data/dumps/logs/collect_edits/log_collect_edits_$yyyymmdd.txt
exec 1> $logfile 2>&1 # send stdout/stderr to file

dumps=$wikistats/dumps
perl=$wikistats/dumps/perl
csv=$wikistats_data/dumps/csv
dblists=$wikistats_data/dumps/dblists

input=/mnt/data/xmldatadumps/public/dewiki/20171001/dewiki-20171001-stub-meta-history.xml.gz

cd $perl
# perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wo -w nlwikivoyage -d $input -c | grep "Wikipedia,Template namespace" > wp_en_edits_template_namespace.txt
 perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wp -w dewiki -d $input 

# perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wp -w dewiki -r $csv/csv_wp/StatisticsLogRunTime.csv -s 
echo "ready"
exit

rm $csv/csv_wb/EditsTimestampsTitlesAll.csv
rm $csv/csv_wk/EditsTimestampsTitlesAll.csv
rm $csv/csv_wn/EditsTimestampsTitlesAll.csv
rm $csv/csv_wo/EditsTimestampsTitlesAll.csv
rm $csv/csv_wp/EditsTimestampsTitlesAll.csv
rm $csv/csv_wq/EditsTimestampsTitlesAll.csv
rm $csv/csv_ws/EditsTimestampsTitlesAll.csv
rm $csv/csv_wv/EditsTimestampsTitlesAll.csv
rm $csv/csv_wx/EditsTimestampsTitlesAll.csv

exit

 perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wx -w wikidatawiki -r $csv/csv_wx/StatisticsLogRunTime.csv -s 
exit

date 
dblist="$dblists/wikibooks.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wb -w $wiki -r $csv/csv_wb/StatisticsLogRunTime.csv -s 
done < $dblist 

dblist="$dblists/wikinews.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wn -w $wiki -r $csv/csv_wn/StatisticsLogRunTime.csv -s
done < $dblist 

dblist="$dblists/wikiquote.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wq -w $wiki -r $csv/csv_wq/StatisticsLogRunTime.csv -s
done < $dblist 

dblist="$dblists/wikisource.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p ws -w $wiki -r $csv/csv_ws/StatisticsLogRunTime.csv -s
done < $dblist 

dblist="$dblists/wikiversity.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wv -w $wiki -r $csv/csv_wv/StatisticsLogRunTime.csv -s
done < $dblist 

dblist="$dblists/wikivoyage.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wo -w $wiki -r $csv/csv_wo/StatisticsLogRunTime.csv -s
done < $dblist 

dblist="$dblists/wiktionary.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wk -w $wiki -r $csv/csv_wk/StatisticsLogRunTime.csv -s
done < $dblist 

dblist="$dblists/wikipedia.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wp -w $wiki -r $csv/csv_wp/StatisticsLogRunTime.csv -s
done < $dblist 

dblist="$dblists/special.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wx -w $wiki -r $csv/csv_wx/StatisticsLogRunTime.csv -s
done < $dblist

date
cat $csv/csv_wb/EditsTimestampsTitles*.csv >  $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_wk/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_wn/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_wo/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_wp/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_wq/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_ws/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_wv/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date
cat $csv/csv_wx/EditsTimestampsTitles*.csv >> $csv/csv_mw/EditsTimestampsTitlesAll.csv
ls -l $csv/csv_mw/EditsTimestampsTitlesAll.csv
date

date  
echo "ready" 
