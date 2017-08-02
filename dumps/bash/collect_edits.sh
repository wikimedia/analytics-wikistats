#!/bin/sh

ulimit -v 1000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
csv=$dumps/csv
input=/mnt/data/xmldatadumps/public/nlwikivoyage/20170301/nlwikivoyage-20170301-stub-meta-history.xml.gz
log=$csv/StatisticsLogCollectEdits.txt 
cd $perl
# perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wo -w nlwikivoyage -d $input -c | grep "Wikipedia,Template namespace" > wp_en_edits_template_namespace.txt
# perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wo -w zhwikivoyage -d $input 

  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wn -w fiwikinews -r $csv/csv_wn/StatisticsLogRunTime.csv -s 
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

 perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wx -w wikidatawiki -r $csv/csv_wx/StatisticsLogRunTime.csv -s >> $log
exit

date > $log
dblist="/a/wikistats_git/dumps/dblists/wikibooks.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wb -w $wiki -r $csv/csv_wb/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/wikinews.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wn -w $wiki -r $csv/csv_wn/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/wikiquote.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wq -w $wiki -r $csv/csv_wq/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/wikisource.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p ws -w $wiki -r $csv/csv_ws/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/wikiversity.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wv -w $wiki -r $csv/csv_wv/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/wikivoyage.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wo -w $wiki -r $csv/csv_wo/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/wiktionary.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wk -w $wiki -r $csv/csv_wk/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/wikipedia.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wp -w $wiki -r $csv/csv_wp/StatisticsLogRunTime.csv -s >> $log
done < $dblist 

dblist="/a/wikistats_git/dumps/dblists/special.dblist" 
while read wiki ; do  
  perl WikiCountsCollectEdits.pl -i $csv -o $csv -p wx -w $wiki -r $csv/csv_wx/StatisticsLogRunTime.csv -s >> $log
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

date >> $log 
echo "ready" >> $log
