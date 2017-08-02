#!/bin/bash
ulimit -v 2000000

wiki=$1
category=$2
yyyy_mm=$3
threshold=$4
abbr=$5
depth=$6

echo Run report for wiki \'$wiki\', category \'$category\' , yyyy_mm \'$yyyy_mm\', threshold \'$threshold\', abbr \'$abbr\', depth \'$depth\'

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
perl=/home/ezachte/wikistats/dammit.lt/perl # tests
work=/a/dammit.lt/pagecounts/categorized
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/
data=$work/data
publish=$work/publish

#views=/mnt/data/xmldatadumps/public/other/pagecounts-ez/merged/pagecounts-$yyyy_mm-views-ge-5.bz2
#views=/a/dammit.lt/pagecounts/merged/pagecounts-$yyyy_mm-views-ge-5.bz2
views=/a/dammit.lt/pagecounts/merged/pagecounts-$yyyy_mm-views-ge-5-totals.bz2
views_filtered=$category/scan_categories_views_per_article.csv
titles=$category/scan_categories_found_articles.csv
html_pageviews=pageviews_${abbr}_cat_${category}_${yyyy_mm}.html
html_categories=categories_${abbr}_cat_${category}_${yyyy_mm}.html

cd $perl

mkdir  $work/data/$abbr
mkdir  $work/data/$abbr/$yyyy_mm
mkdir  $work/publish/$abbr
mkdir  $work/publish/$abbr/$yyyy_mm

perl DammitScanCategories.pl -o $work/data/$abbr/$yyyy_mm -h $work/publish/$abbr/$yyyy_mm/$html_categories -d $depth -c $category -w $wiki -x $work/data/exclude.csv
perl DammitFilterMonthlyPageViews.pl -o $work/data/$abbr/$yyyy_mm/$views_filtered -t $work/data/$abbr/$yyyy_mm/$titles -v $views
perl DammitReportPageViewsByCategory.pl -i $work/data/$abbr/$yyyy_mm/$views_filtered -o $work/publish/$abbr/$yyyy_mm/$html_pageviews -v $threshold -a $abbr -m $yyyy_mm

echo Publish result
rsync -a -r $publish/$abbr $htdocs/wikimedia/pageviews/categorized
