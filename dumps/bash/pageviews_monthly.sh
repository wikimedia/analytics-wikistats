#!/bin/sh

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
# perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$dumps/out
report=$dumps/logs/log_pageviews_monthly.txt
projectcounts=/a/dammit.lt/projectcounts
# projectcounts=/home/ezachte/test/projectcounts  # tests
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

echo "**************************" | tee -a $report | cat
echo "Start pageviews_monthly.sh" | tee -a $report | cat
echo "**************************" | tee -a $report | cat

list=WhiteListWikis.csv
cd $csv

# step 0: collect list of valid projects/languages 
cat csv_wb/$list csv_wk/$list csv_wn/$list csv_wo/$list csv_wp/$list csv_wq/$list  csv_ws/$list csv_wv/$list csv_wx/$list > $projectcounts/$list

# step 1: data collecting 

# Main steps in WikiCountsSummarizeProjectCounts.pl:

# LogArguments 
# ParseArguments 
# SetComparisonPeriods 
# InitProjectNames 
# ScanWhiteList 
# ScanTarFiles  
# FindMissingFiles 
# CountPageViews 
# AdjustForMissingFilesAndUndercountedMonths 
# WriteCsvFilesPerPeriod ($no_normalize)        (-> files X)               
# WriteCsvHtmlFilesPopularWikis ($no_normalize) (-> files Y) 
# normalize counts to 30 day months
# WriteCsvFilesPerPeriod ($normalize)           (-> files X)
# WriteCsvHtmlFilesPopularWikis ($normalize)    (-> files Y)


# Input:
# $projectcounts/WhiteListWikis.csv          <- list of valid projects/languages, based on dumps found, see step 0 (perl sub ScanWhiteList)
# $projectcounts/projectcounts-[yyyy].tar    <- sanitized and tarred version of hourly views per wiki, since 2008  (perl sub ScanTarFiles)
#                                            source: webstatscollector
#                                            updated daily by /a/wikistats_git/dammit.lt/bash/dammit_sync.sh
#                                            from /mnt/data/xmldatadumps/public/other/pagecounts-raw/yyyy/yyyy-mm/projectcounts*
#
#                                            for some months with big data loss, due to server overload, projectcounts files have been repaired,
#                                              inferring amount of loss from gaps between sequence numbers
#                                            also some date ranges are skipped on purpose, because data are known to be unreliable/incomplete,
#                                              missing data will be compensated in AdjustforMissingFilesAndUndercountedMonths

# Output: (*) 
# X: $csv/csv_wp/analytics_in_page_views.csv                         -> <- intermediate file, read back in immediately after generation
# X: $csv/csv_wp/analytics_chk_page_views_totals_normalized.csv
# X: $csv/csv_[project]/PageViewsPer[$period][All][Normalized].csv 
#    $period=[Hour/Day/Week/Weekday/Month]                           -> used for ad hoc analysis, not in regular reports, except monthly version,
#                                                                        daily job /a/wikistats_git/dumps/bash/pageviews_monthly.sh updates all reports
#                                                                        listed at http://stats.wikimedia.org/EN/TablesPageViewsSitemap.htm from 
#                                                                        ../PageViewsPerMonth[All][Normalized].csv

# Y: $csv/csv_wp/PageViewsPerMonthPopularWikis[Normalized].csv       -> old Report Card, 36 months history for largest wikis and projects
# Y: $csv/csv_wp/wikilytics_in_pageviews.csv                         -> new Report Card, copy from previous file, for name consistency
#                                                                         contains series of monthly page views since July 2008 (mobile since June 2010)  
#                                                                         series are: combined / non-mobile / mobile for 25 most visited wikis, 
#                                                                         followed by similar series with totals on project level (Wikipedia, Wiktionary, etc)
   
# Y: $csv/csv_wp/PageViewsMoversShakersPopularWikis[Normalized]_yyyy_mm.html (**) 
#                                                                    -> old Report Card, html code included directly into table 'movers and shakers' (M&S) 
#                                                                       see e.g. http://stats.wikimedia.org/reportcard/RC_2012_02_detailed.html#fragment-26 


# ad processing subs
# sub FindMissingFiles: find out for which days/hours input is missing (to recalc monthly totals in next step)
# sub CountPageViews: aggregate hourly counts into daily/weekly/weekday/monthly counts and report anomalies
# sub AdjustForMissingFilesAndUndercountedMonths: recalc monthly totals by extrapolating from incomplete counts

# *  = some csv files which contain input for all projects have historically been stored in csv/csv_wp (some day move these to csv/csv_mw)
# ** = yep not csv really, despite folder name csv_.. ;)

perl $perl/WikiCountsSummarizeProjectCounts.pl -i $projectcounts -o $csv -w $projectcounts | tee -a $report | cat
# exit # tests only 

# -l = language (en:English)
# -m = mode (wb:wikibooks, wk:wiktionary, wn:wikinews, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, wx:wikispecial=commons,meta,..)
# -i = input folder
# -o = output folder
# -n = normalized (all months -> 30 days)
# -r = region

# -v n = views non-mobile

date | tee -a $report | cat

cd $perl

# step 2a: report per project, non mobile site (arg '-v n' = views non-mobile)
perl WikiReports.pl -v n -m wb -l en -i $csv/csv_wb/ -o $out/out_wb -n | tee -a $report | cat
perl WikiReports.pl -v n -m wb -l en -i $csv/csv_wb/ -o $out/out_wb    | tee -a $report | cat
perl WikiReports.pl -v n -m wk -l en -i $csv/csv_wk/ -o $out/out_wk -n | tee -a $report | cat
perl WikiReports.pl -v n -m wk -l en -i $csv/csv_wk/ -o $out/out_wk    | tee -a $report | cat
perl WikiReports.pl -v n -m wn -l en -i $csv/csv_wn/ -o $out/out_wn -n | tee -a $report | cat
perl WikiReports.pl -v n -m wn -l en -i $csv/csv_wn/ -o $out/out_wn    | tee -a $report | cat
perl WikiReports.pl -v n -m wo -l en -i $csv/csv_wo/ -o $out/out_wo -n | tee -a $report | cat
perl WikiReports.pl -v n -m wo -l en -i $csv/csv_wo/ -o $out/out_wo    | tee -a $report | cat
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

# step 2b: report per project, mobile site (arg '-v m' = views mobile)
perl WikiReports.pl -v m -m wb -l en -i $csv/csv_wb/ -o $out/out_wb -n | tee -a $report | cat
perl WikiReports.pl -v m -m wb -l en -i $csv/csv_wb/ -o $out/out_wb    | tee -a $report | cat
perl WikiReports.pl -v m -m wk -l en -i $csv/csv_wk/ -o $out/out_wk -n | tee -a $report | cat
perl WikiReports.pl -v m -m wk -l en -i $csv/csv_wk/ -o $out/out_wk    | tee -a $report | cat
perl WikiReports.pl -v m -m wn -l en -i $csv/csv_wn/ -o $out/out_wn -n | tee -a $report | cat
perl WikiReports.pl -v m -m wn -l en -i $csv/csv_wn/ -o $out/out_wn    | tee -a $report | cat
perl WikiReports.pl -v m -m wo -l en -i $csv/csv_wo/ -o $out/out_wo -n | tee -a $report | cat
perl WikiReports.pl -v m -m wo -l en -i $csv/csv_wo/ -o $out/out_wo    | tee -a $report | cat
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

# step 2c: report per project, mobile+non-mobile site (arg '-v c' = views mobile/non-mobile combined)
perl WikiReports.pl -v c -m wb -l en -i $csv/csv_wb/ -o $out/out_wb -n | tee -a $report | cat
perl WikiReports.pl -v c -m wb -l en -i $csv/csv_wb/ -o $out/out_wb    | tee -a $report | cat
perl WikiReports.pl -v c -m wk -l en -i $csv/csv_wk/ -o $out/out_wk -n | tee -a $report | cat
perl WikiReports.pl -v c -m wk -l en -i $csv/csv_wk/ -o $out/out_wk    | tee -a $report | cat
perl WikiReports.pl -v c -m wn -l en -i $csv/csv_wn/ -o $out/out_wn -n | tee -a $report | cat
perl WikiReports.pl -v c -m wn -l en -i $csv/csv_wn/ -o $out/out_wn    | tee -a $report | cat
perl WikiReports.pl -v c -m wo -l en -i $csv/csv_wo/ -o $out/out_wo -n | tee -a $report | cat
perl WikiReports.pl -v c -m wo -l en -i $csv/csv_wo/ -o $out/out_wo    | tee -a $report | cat
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

# step 2d: report per region for Wikipedia only, 
# raw/normalized (with/without arg '-n') 
# non-mobile site/mobile site/combined (arg '-v n/m/c')
for region in africa asia america europe india oceania artificial 
do
  perl WikiReports.pl -v n -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n  -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v n -m wp -l en -i $csv/csv_wp/ -o $out/out_wp     -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v m -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n  -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v m -m wp -l en -i $csv/csv_wp/ -o $out/out_wp     -r $region | tee -a $report | cat ;
  perl WikiReports.pl -v c -m wp -l en -i $csv/csv_wp/ -o $out/out_wp -n  -r $region | tee -a $report | cat ; 
  perl WikiReports.pl -v c -m wp -l en -i $csv/csv_wp/ -o $out/out_wp     -r $region | tee -a $report | cat ;
done;


# step 3a: publish regional reports 
for region in Africa Asia America Europe India Oceania Artificial 
do	
  echo "rsync -av $out/out_wp/EN_$region/TablesPageViewsMonthly*.htm  $htdocs/EN_$region" | tee -a $report | cat
        rsync -av $out/out_wp/EN_$region/TablesPageViewsMonthly*.htm  $htdocs/EN_$region  | tee -a $report | cat 
done;

ls -l    $out/*/EN/TablesPageViewsMonthly.htm                               | tee -a $report | cat

# step 3b: publish per project reports 
echo "rsync -av $out/out_wb/EN/TablesPageViewsMonthly*.htm  $htdocs/wikibooks/EN"   | tee -a $report | cat
      rsync -av $out/out_wb/EN/TablesPageViewsMonthly*.htm  $htdocs/wikibooks/EN    | tee -a $report | cat
echo "rsync -av $out/out_wk/EN/TablesPageViewsMonthly*.htm  $htdocs/wiktionary/EN"  | tee -a $report | cat
      rsync -av $out/out_wk/EN/TablesPageViewsMonthly*.htm  $htdocs/wiktionary/EN   | tee -a $report | cat
echo "rsync -av $out/out_wn/EN/TablesPageViewsMonthly*.htm  $htdocs/wikinews/EN"    | tee -a $report | cat
      rsync -av $out/out_wn/EN/TablesPageViewsMonthly*.htm  $htdocs/wikinews/EN     | tee -a $report | cat
echo "rsync -av $out/out_wo/EN/TablesPageViewsMonthly*.htm  $htdocs/wikivoyage/EN"  | tee -a $report | cat
      rsync -av $out/out_wo/EN/TablesPageViewsMonthly*.htm  $htdocs/wikivoyage/EN   | tee -a $report | cat
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

# step 3c: zip and publish raw daily counts
cd $csv/csv_wp
zip PageViewsPerDayAll.csv.zip PageViewsPerDayAll.csv | tee -a  $report | cat
rsync -av PageViewsPerDayAll.csv.zip $htdocs/archive/ | tee -a  $report | cat

echo "Ready" | tee -a $report | cat
date | tee -a $report | cat
