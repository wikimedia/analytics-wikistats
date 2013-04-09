#!/bin/bash
ulimit -v 2000000

# collect newewest projectcounts files (hourly page view stats per wiki), add to tar, and publish

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
work=/home/ezachte/pageviews_by_category
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

# ==> search arguments
#category=Nederlands_kunstschilder
#category=Schilderkunst_van_de_20e_eeuw
#category=Politicus
#category=Nederlands_politicus
#category=Museum
#category=English_painters
#category=French_painters
#category=German_painters
#category=Italian_painters
#category=Painters_by_nationality
#category=Politiker_\(Deutschland\)
#depth=9
#wiki=nl.wikipedia.org
#wiki=en.wikipedia.org
# <== search arguments

views_filtered=$work/$category/scan_categories_views_per_article.csv
titles=$work/$category/scan_categories_found_articles.csv
views=/mnt/data/xmldatadumps/public/other/pagecounts-ez/merged/pagecounts-$yyyy_mm-views-ge-5.bz2
html=pageviews_${abbr}_cat_${category}_${yyyy_mm}.html

cd $perl

#perl DammitScanCategories.pl -o $work -d $depth -c $category -w $wiki

#perl DammitFilterMonthlyPageViews.pl -o $views_filtered -t $titles -v $views

mkdir  $work/$abbr
mkdir  $work/$abbr/$yyyy_mm
mkdir  $work/$abbr/$yyyy_mm/$category
perl DammitReportPageViewsByCategory.pl -i $views_filtered -o $work/$abbr/$yyyy_mm/$category/$html -v $threshold

echo Publish result.
rsync -a -r $work/$abbr          $htdocs/wikimedia/pagecounts/by_category/$abbr
