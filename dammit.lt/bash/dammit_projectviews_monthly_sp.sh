#!/bin/sh

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
#perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
out=$dumps/out
report=$dumps/logs/log_pageviews_monthly_sp.txt
htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/

# -l = language (en:English)
# -m = mode (wb:wikibooks, wk:wiktionary, wn:wikinews, wp:wikipedia, wq:wikiquote, ws:wikisource, wv:wikiversity, wx:wikispecial=commons,meta,..)
# -i = input folder
# -o = output folder
# -n = normalized (all months -> 30 days)
# -r = region
# -v = views (n:non-mobile, m:mobile, c:combined)
# -q = input from sampled squids log

cp $csv/csv_wp/LanguageNames*.csv $csv/csv_sp # up to date language names from php sources and Wikipedia 

cd $perl

# step 2b: report per project, mobile site (arg '-v m' = views mobile)
perl WikiReports.pl -v m -m wp -l en -q -i $csv/csv_sp/ -o $out/out_sp -n | tee -a $report | cat
perl WikiReports.pl -v m -m wp -l en -q -i $csv/csv_sp/ -o $out/out_sp    | tee -a $report | cat

#################################################################
# Cross-reference => The file name in the destination of rsync 
# must be the same as the $file_html_new_mobile_pageviews inside
# SquidReportArchive.pl
#################################################################
#rsync -av $out/out_sp/EN/TablesPageViewsMonthlySquidsMobile.htm          $htdocs/wikimedia/squids/TablesPageViewsMonthlySquidsMobile.htm

##########################################
# Question => What is the Original file ?
# Why do we need it ?
##########################################
#rsync -av $out/out_sp/EN/TablesPageViewsMonthlySquidsOriginalMobile.htm  $htdocs/wikimedia/squids/TablesPageViewsMonthlySquidsOriginalMobile.htm

