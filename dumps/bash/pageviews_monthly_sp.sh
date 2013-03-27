#!/bin/sh

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
# perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$dumps/out
report=$dumps/logs/log_pageviews_monthly_sp.txt
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

# -l = language (en:English)
# -m = mode (wb:wikibooks, wk:wiktionary, wn:wikinews, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, wx:wikispecial=commons,meta,..)
# -i = input folder
# -o = output folder
# -n = normalized (all months -> 30 days)
# -r = region

# -v n = views non-mobile

cd $perl

# step 2b: report per project, mobile site (arg '-v m' = views mobile)
perl WikiReports.pl -v m -m wp -l en -i $csv/csv_sp/ -o $out/out_sp -n | tee -a $report | cat
perl WikiReports.pl -v m -m wp -l en -i $csv/csv_sp/ -o $out/out_sp    | tee -a $report | cat

rsync -av $out/out_sp/EN/TablesPageViewsMonthlyMobile.htm          $htdocs/EN/draft/TablesPageViewsMonthlyMobilePetrea.htm   
rsync -av $out/out_sp/EN/TablesPageViewsMonthlyOriginalMobile.htm  $htdocs/EN/draft/TablesPageViewsMonthlyOriginalMobilePetrea.htm    

