#!/bin/sh

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
out=$dumps/out
report=$dumps/logs/log_pageviews_monthly.txt
projectcounts=/a/dammit.lt/projectcounts
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

echo "**************************" | tee -a $report | cat
echo "Start pageviews_monthly.sh" | tee -a $report | cat
echo "**************************" | tee -a $report | cat

list=WhiteListWikis.csv
cd $csv
cat csv_wb/$list csv_wk/$list csv_wn/$list csv_wp/$list csv_wq/$list  csv_ws/$list csv_wv/$list csv_wx/$list > /a/dammit.lt/projectcounts/$list

perl $perl/WikiCountsSummarizeProjectCounts.pl -i $projectcounts -o $csv -w $projectcounts | tee -a $report | cat
#exit

# -l = language (en:English)
# -m = mode (wb:wikibooks, wk:wiktionary, wn:wikinews, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, wx:wikispecial=commons,meta,..)
# -i = input folder
# -o = output folder
# -n = normalized (all months -> 30 days)
# -r = region

# -v n = views non-mobile

date | tee -a $report | cat

cd $perl

perl WikiReports.pl -v n -m wb -l en -i $csv/csv_wb/ -o $out/out_wb -n | tee -a $report | cat
perl WikiReports.pl -v n -m wb -l en -i $csv/csv_wb/ -o $out/out_wb    | tee -a $report | cat
perl WikiReports.pl -v n -m wk -l en -i $csv/csv_wk/ -o $out/out_wk -n | tee -a $report | cat
perl WikiReports.pl -v n -m wk -l en -i $csv/csv_wk/ -o $out/out_wk    | tee -a $report | cat
perl WikiReports.pl -v n -m wn -l en -i $csv/csv_wn/ -o $out/out_wn -n | tee -a $report | cat
perl WikiReports.pl -v n -m wn -l en -i $csv/csv_wn/ -o $out/out_wn    | tee -a $report | cat
perl WikiReports.pl -v n -m wq -l en -i $csv/csv_wq/ -o $out/out_wq -n | tee -a $report | cat
perl WikiReports.pl -v n -m wq -l en -i $csv/csv_wq/ -o $out/out_wq    | tee -a $report | cat
perl WikiReports.pl -v n -m ws -l en -i $csv/csv_ws/ -o $out/out_ws -n | tee -a $report | cat
perl WikiReports.pl -v n -m ws -l en -i $csv/csv_ws/ -o $out/out_ws    | tee -a $report | cat
perl WikiReports.pl -v n -m wv -l en -i $csv/csv_wv/ -o $out/out_wv -n | tee -a $report | cat
perl WikiReports.pl -v n -m wv -l en -i $csv/csv_wv/ -o $out/out_wv    | tee -a $report | cat
perl WikiReports.pl -v n -m wx -l en -i $csv/csv_wx/ -o $out/out_wx -n | tee -a $report | cat
perl WikiReports.pl -v n -m wx -l en -i $csv/csv_wx/ -o $out/out_wx    | tee -a $report | cat
perl WikiReports.pl -v n -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n | tee -a $report | cat 
perl WikiReports.pl -v n -m wp -l en -i $csv/csv_wp/ -o $out/out_wp    | tee -a $report | cat

# -v m = views mobile
perl WikiReports.pl -v m -m wb -l en -i $csv/csv_wb/ -o $out/out_wb -n | tee -a $report | cat
perl WikiReports.pl -v m -m wb -l en -i $csv/csv_wb/ -o $out/out_wb    | tee -a $report | cat
perl WikiReports.pl -v m -m wk -l en -i $csv/csv_wk/ -o $out/out_wk -n | tee -a $report | cat
perl WikiReports.pl -v m -m wk -l en -i $csv/csv_wk/ -o $out/out_wk    | tee -a $report | cat
perl WikiReports.pl -v m -m wn -l en -i $csv/csv_wn/ -o $out/out_wn -n | tee -a $report | cat
perl WikiReports.pl -v m -m wn -l en -i $csv/csv_wn/ -o $out/out_wn    | tee -a $report | cat
perl WikiReports.pl -v m -m wq -l en -i $csv/csv_wq/ -o $out/out_wq -n | tee -a $report | cat
perl WikiReports.pl -v m -m wq -l en -i $csv/csv_wq/ -o $out/out_wq    | tee -a $report | cat
perl WikiReports.pl -v m -m ws -l en -i $csv/csv_ws/ -o $out/out_ws -n | tee -a $report | cat
perl WikiReports.pl -v m -m ws -l en -i $csv/csv_ws/ -o $out/out_ws    | tee -a $report | cat
perl WikiReports.pl -v m -m wv -l en -i $csv/csv_wv/ -o $out/out_wv -n | tee -a $report | cat
perl WikiReports.pl -v m -m wv -l en -i $csv/csv_wv/ -o $out/out_wv    | tee -a $report | cat
perl WikiReports.pl -v m -m wx -l en -i $csv/csv_wx/ -o $out/out_wx -n | tee -a $report | cat
perl WikiReports.pl -v m -m wx -l en -i $csv/csv_wx/ -o $out/out_wx    | tee -a $report | cat
perl WikiReports.pl -v m -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n | tee -a $report | cat 
perl WikiReports.pl -v m -m wp -l en -i $csv/csv_wp/ -o $out/out_wp    | tee -a $report | cat 

# -v c = views mobile + non mobile (combined)
perl WikiReports.pl -v c -m wb -l en -i $csv/csv_wb/ -o $out/out_wb -n | tee -a $report | cat
perl WikiReports.pl -v c -m wb -l en -i $csv/csv_wb/ -o $out/out_wb    | tee -a $report | cat
perl WikiReports.pl -v c -m wk -l en -i $csv/csv_wk/ -o $out/out_wk -n | tee -a $report | cat
perl WikiReports.pl -v c -m wk -l en -i $csv/csv_wk/ -o $out/out_wk    | tee -a $report | cat
perl WikiReports.pl -v c -m wn -l en -i $csv/csv_wn/ -o $out/out_wn -n | tee -a $report | cat
perl WikiReports.pl -v c -m wn -l en -i $csv/csv_wn/ -o $out/out_wn    | tee -a $report | cat
perl WikiReports.pl -v c -m wq -l en -i $csv/csv_wq/ -o $out/out_wq -n | tee -a $report | cat
perl WikiReports.pl -v c -m wq -l en -i $csv/csv_wq/ -o $out/out_wq    | tee -a $report | cat
perl WikiReports.pl -v c -m ws -l en -i $csv/csv_ws/ -o $out/out_ws -n | tee -a $report | cat
perl WikiReports.pl -v c -m ws -l en -i $csv/csv_ws/ -o $out/out_ws    | tee -a $report | cat
perl WikiReports.pl -v c -m wv -l en -i $csv/csv_wv/ -o $out/out_wv -n | tee -a $report | cat
perl WikiReports.pl -v c -m wv -l en -i $csv/csv_wv/ -o $out/out_wv    | tee -a $report | cat
perl WikiReports.pl -v c -m wx -l en -i $csv/csv_wx/ -o $out/out_wx -n | tee -a $report | cat
perl WikiReports.pl -v c -m wx -l en -i $csv/csv_wx/ -o $out/out_wx    | tee -a $report | cat
perl WikiReports.pl -v c -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n | tee -a $report | cat 
perl WikiReports.pl -v c -m wp -l en -i $csv/csv_wp/ -o $out/out_wp    | tee -a $report | cat 

for region in africa asia america europe india oceania artificial 
do
  perl WikiReports.pl -v n -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n  -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v n -m wp -l en -i $csv/csv_wp/ -o $out/out_wp     -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v m -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n  -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v m -m wp -l en -i $csv/csv_wp/ -o $out/out_wp     -r $region | tee -a $report | cat ;
  perl WikiReports.pl -v c -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n  -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v c -m wp -l en -i $csv/csv_wp/ -o $out/out_wp     -r $region | tee -a $report | cat ;
done;


for region in Africa Asia America Europe India Oceania Artificial 
do	
  echo "rsync -av $out/out_wp/EN_$region/TablesPageViewsMonthly*.htm  $htdocs/EN_$region" | tee -a $report | cat
        rsync -av $out/out_wp/EN_$region/TablesPageViewsMonthly*.htm  $htdocs/EN_$region  | tee -a $report | cat 
done;

ls -l    $out/*/EN/TablesPageViewsMonthly.htm                               | tee -a $report | cat

echo "rsync -av $out/out_wb/EN/TablesPageViewsMonthly*.htm  $htdocs/wikibooks/EN"   | tee -a $report | cat
      rsync -av $out/out_wb/EN/TablesPageViewsMonthly*.htm  $htdocs/wikibooks/EN    | tee -a $report | cat
echo "rsync -av $out/out_wk/EN/TablesPageViewsMonthly*.htm  $htdocs/wiktionary/EN"  | tee -a $report | cat
      rsync -av $out/out_wk/EN/TablesPageViewsMonthly*.htm  $htdocs/wiktionary/EN   | tee -a $report | cat
echo "rsync -av $out/out_wn/EN/TablesPageViewsMonthly*.htm  $htdocs/wikinews/EN"    | tee -a $report | cat
      rsync -av $out/out_wn/EN/TablesPageViewsMonthly*.htm  $htdocs/wikinews/EN     | tee -a $report | cat
echo "rsync -av $out/out_wp/EN/TablesPageViewsMonthly*.htm  $htdocs/EN"             | tee -a $report | cat
      rsync -av $out/out_wp/EN/TablesPageViewsMonthly*.htm  $htdocs/EN              | tee -a $report | cat
echo "rsync -av $out/out_wq/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiquote/EN"   | tee -a $report | cat
      rsync -av $out/out_wq/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiquote/EN    | tee -a $report | cat
echo "rsync -av $out/out_ws/EN/TablesPageViewsMonthly*.htm  $htdocs/wikisource/EN"  | tee -a $report | cat
      rsync -av $out/out_ws/EN/TablesPageViewsMonthly*.htm  $htdocs/wikisource/EN   | tee -a $report | cat
echo "rsync -av $out/out_wv/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiversity/EN" | tee -a $report | cat
      rsync -av $out/out_wv/EN/TablesPageViewsMonthly*.htm  $htdocs/wikiversity/EN  | tee -a $report | cat
echo "rsync -av $out/out_wx/EN/TablesPageViewsMonthly*.htm  $htdocs/wikispecial/EN" | tee -a $report | cat
      rsync -av $out/out_wx/EN/TablesPageViewsMonthly*.htm  $htdocs/wikispecial/EN  | tee -a $report | cat

# still needed to publish this file, if yes, zip local and rsync 
cd $csv/csv_wp
zip PageViewsPerDayAll.csv.zip PageViewsPerDayAll.csv | tee -a  $report | cat
rsync -av PageViewsPerDayAll.csv.zip $htdocs/archive/ | tee -a  $report | cat

echo "Ready" | tee -a $report | cat
date | tee -a $report | cat
