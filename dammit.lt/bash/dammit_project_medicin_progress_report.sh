#!/bin/bash
ulimit -v 2000000


yyyy_mm=$(date -d "1 month ago" +"%Y-%m") # [yyyy-mm] e.g. 2007-01 for specific month, default is previous month 

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
meta=/a/wikistats_git/dumps/csv/csv_mw/MetaLanguages.csv
perl=$dammit/perl
perl=/home/ezachte/wikistats/dammit.lt/perl # tests
work=/a/dammit.lt/pagecounts/categorized
htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

data=$work/data/wp-medicin/$yyyy_mm
publish=$work/publish

views=/a/dammit.lt/pagecounts/merged/pagecounts-$yyyy_mm-views-ge-5-totals.bz2
views_filtered=WikiProject_Medicine_Translation_task_force_RTT_views.csv
titles=WikiProject_Medicine_Translation_task_force_RTT_titles.csv

html_pageviews=WikiProject_Medicine_Translations_$yyyy_mm.html

#wget --no-check-certificate  --content-disposition -O /a/wikistats_git/dammit.lt/temp/WikiProject_Medicine_Translation_GoogleDoc.html "http://docs.google.com/a/wikimedia.org/spreadsheets/d/1cb80jUe-tObwbTo-o4hh2IpcQHSv1TAJh-8vuniNsCs/edit#gid=0&single=true&output=text"

cd /home/ezachte/wikistats/dammit.lt/perl
#perl DammitProjectMedicinCollectTitles.pl   -o $data/$titles # input via html request from Wikipedia
#perl DammitFilterMonthlyPageViews.pl        -o $data/$views_filtered -t $data/$titles -v $views
perl DammitProjectMedicinReportPageViews.pl -i $data/$views_filtered -o $publish/wp-medicin/$html_pageviews -l $meta -v 1 -a wp-medicin -m $yyyy_mm

echo Publish result
rsync -a -r $publish/wp-medicin $htdocs/wikimedia/pageviews/categorized

