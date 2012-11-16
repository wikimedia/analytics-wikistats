#!/bin/sh

root=/home/ezachte/wikistats
out=/a/out
htdocs=/mnt/htdocs
report=/home/ezachte/wikistats/report_pageviews_monthly.txt


echo "**************************" >> $report
echo "Start pageviews_monthly.sh" >> $report
echo "**************************" >> $report

cd $root
perl $root/WikiCountsSummarizeProjectCounts.pl -i /a/dammit.lt/projectcounts -o /a/wikistats # >> $report
#exit

# -l = language (en:English)
# -m = mode (wb:wikibooks, wk:wiktionary, wn:wikinews, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, wx:wikispecial=commons,meta,..)
# -i = input folder
# -o = output folder
# -n = normalized (all months -> 30 days)
# -r = region

# -v n = views non-mobile
cd $root
date >> $report
perl $root/WikiReports.pl -v n -m wb -l en -i /a/wikistats/csv_wb/ -o $out/out_wb -n >> $report
perl $root/WikiReports.pl -v n -m wb -l en -i /a/wikistats/csv_wb/ -o $out/out_wb    >> $report
date >> $report
perl $root/WikiReports.pl -v n -m wk -l en -i /a/wikistats/csv_wk/ -o $out/out_wk -n >> $report
perl $root/WikiReports.pl -v n -m wk -l en -i /a/wikistats/csv_wk/ -o $out/out_wk    >> $report
perl $root/WikiReports.pl -v n -m wn -l en -i /a/wikistats/csv_wn/ -o $out/out_wn -n >> $report
perl $root/WikiReports.pl -v n -m wn -l en -i /a/wikistats/csv_wn/ -o $out/out_wn    >> $report
perl $root/WikiReports.pl -v n -m wq -l en -i /a/wikistats/csv_wq/ -o $out/out_wq -n >> $report
perl $root/WikiReports.pl -v n -m wq -l en -i /a/wikistats/csv_wq/ -o $out/out_wq    >> $report
perl $root/WikiReports.pl -v n -m ws -l en -i /a/wikistats/csv_ws/ -o $out/out_ws -n >> $report
perl $root/WikiReports.pl -v n -m ws -l en -i /a/wikistats/csv_ws/ -o $out/out_ws    >> $report
perl $root/WikiReports.pl -v n -m wv -l en -i /a/wikistats/csv_wv/ -o $out/out_wv -n >> $report
perl $root/WikiReports.pl -v n -m wv -l en -i /a/wikistats/csv_wv/ -o $out/out_wv    >> $report
perl $root/WikiReports.pl -v n -m wx -l en -i /a/wikistats/csv_wx/ -o $out/out_wx -n >> $report
perl $root/WikiReports.pl -v n -m wx -l en -i /a/wikistats/csv_wx/ -o $out/out_wx    >> $report
perl $root/WikiReports.pl -v n -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp -n >> $report 
perl $root/WikiReports.pl -v n -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp    >> $report

# -v m = views mobile
perl $root/WikiReports.pl -v m -m wb -l en -i /a/wikistats/csv_wb/ -o $out/out_wb -n >> $report
perl $root/WikiReports.pl -v m -m wb -l en -i /a/wikistats/csv_wb/ -o $out/out_wb    >> $report
perl $root/WikiReports.pl -v m -m wk -l en -i /a/wikistats/csv_wk/ -o $out/out_wk -n >> $report
perl $root/WikiReports.pl -v m -m wk -l en -i /a/wikistats/csv_wk/ -o $out/out_wk    >> $report
perl $root/WikiReports.pl -v m -m wn -l en -i /a/wikistats/csv_wn/ -o $out/out_wn -n >> $report
perl $root/WikiReports.pl -v m -m wn -l en -i /a/wikistats/csv_wn/ -o $out/out_wn    >> $report
perl $root/WikiReports.pl -v m -m wq -l en -i /a/wikistats/csv_wq/ -o $out/out_wq -n >> $report
perl $root/WikiReports.pl -v m -m wq -l en -i /a/wikistats/csv_wq/ -o $out/out_wq    >> $report
perl $root/WikiReports.pl -v m -m ws -l en -i /a/wikistats/csv_ws/ -o $out/out_ws -n >> $report
perl $root/WikiReports.pl -v m -m ws -l en -i /a/wikistats/csv_ws/ -o $out/out_ws    >> $report
perl $root/WikiReports.pl -v m -m wv -l en -i /a/wikistats/csv_wv/ -o $out/out_wv -n >> $report
perl $root/WikiReports.pl -v m -m wv -l en -i /a/wikistats/csv_wv/ -o $out/out_wv    >> $report
perl $root/WikiReports.pl -v m -m wx -l en -i /a/wikistats/csv_wx/ -o $out/out_wx -n >> $report
perl $root/WikiReports.pl -v m -m wx -l en -i /a/wikistats/csv_wx/ -o $out/out_wx    >> $report
perl $root/WikiReports.pl -v m -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp -n >> $report 
perl $root/WikiReports.pl -v m -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp    >> $report 

for region in africa asia america europe india oceania artificial 
do
  perl $root/WikiReports.pl -v n -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp -n  -r $region >> $report ; 
  perl $root/WikiReports.pl -v n -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp     -r $region >> $report ; 
  perl $root/WikiReports.pl -v m -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp -n  -r $region >> $report ; 
  perl $root/WikiReports.pl -v m -m wp -l en -i /a/wikistats/csv_wp/ -o $out/out_wp     -r $region >> $report ;
done;

for region in Africa Asia America Europe India Oceania Artificial 
do	
  echo "cp $out/out_wp/EN_$region/TablesPageViewsMonthly*.htm  $htdocs/EN_$region" >> $report
        cp $out/out_wp/EN_$region/TablesPageViewsMonthly*.htm  $htdocs/EN_$region  >> $report 
done;

ls -l    $out/*/EN/TablesPageViewsMonthly.htm                               >> $report

echo "cp $out/out_wb/EN/TablesPageViewsMonthly*.htm  $htdocs/wikibooks/EN"   >> $report
      cp $out/out_wb/EN/TablesPageViewsMonthly*.htm  $htdocs/wikibooks/EN    >> $report
echo "cp $out/out_wk/EN/TablesPageViewsMonthly*.htm  $htdocs/wiktionary/EN"  >> $report
      cp $out/out_wk/EN/TablesPageViewsMonthly*.htm  $htdocs/wiktionary/EN   >> $report
echo "cp $out/out_wn/EN/TablesPageViewsMonthly*.htm  $htdocs/wikinews/EN"    >> $report
      cp $out/out_wn/EN/TablesPageViewsMonthly*.htm  $htdocs/wikinews/EN     >> $report
echo "cp $out/out_wp/EN/TablesPageViewsMonthly*.htm  $htdocs/EN"             >> $report
      cp $out/out_wp/EN/TablesPageViewsMonthly*.htm  $htdocs/EN              >> $report
echo "cp $out/out_wq/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiquote/EN"   >> $report
      cp $out/out_wq/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiquote/EN    >> $report
echo "cp $out/out_ws/EN/TablesPageViewsMonthly*.htm  $htdocs/wikisource/EN"  >> $report
      cp $out/out_ws/EN/TablesPageViewsMonthly*.htm  $htdocs/wikisource/EN   >> $report
echo "cp $out/out_wv/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiversity/EN" >> $report
      cp $out/out_wv/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiversity/EN  >> $report
echo "cp $out/out_wx/EN/TablesPageViewsMonthly*.htm  $htdocs/wikispecial/EN" >> $report
      cp $out/out_wx/EN/TablesPageViewsMonthly*.htm  $htdocs/wikispecial/EN  >> $report

cd /a/wikistats/csv_wp
zip /mnt/htdocs/archive/PageViewsPerDayAll.csv.zip PageViewsPerDayAll.csv 

echo "Ready" >> $report
date >> $report
