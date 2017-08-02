#!/bin/bash

ulimit -v 8000000

function generate 
{
  code=$1
  edits=$2
  path=$3
  perl WikiCountsStateOfTheWiki.pl -p $code -e $edits -i $csv/csv_$code -r $csv/csv_wp -o $csv/csv_$code 
  rsync -av $csv/csv_$code/StateOfTheWiki*_$edits.csv $htdocs/$path
  rsync -av $csv/csv_$code/StateOfTheWiki*_$edits.csv $htdocs/wikimedia/editors
  cp $csv/csv_$code/StateOfTheWiki*_$edits.csv $csv/csv_mw
}

function concatenate
{
  # copy header from first file + data from all files to one file
  edits=$1
  cat         $csv/csv_wp/StateOfTheWikiOverviewWikipedia_$edits.csv   >   $csv/csv_mw/StateOfTheWikiOverview_$edits.csv 
  tail -n +12 $csv/csv_wb/StateOfTheWikiOverviewWikibooks_$edits.csv   >>  $csv/csv_mw/StateOfTheWikiOverview_$edits.csv
  tail -n +12 $csv/csv_wk/StateOfTheWikiOverviewWiktionary_$edits.csv  >>  $csv/csv_mw/StateOfTheWikiOverview_$edits.csv
  tail -n +12 $csv/csv_wn/StateOfTheWikiOverviewWikinews_$edits.csv    >>  $csv/csv_mw/StateOfTheWikiOverview_$edits.csv
  tail -n +12 $csv/csv_wo/StateOfTheWikiOverviewWikivoyage_$edits.csv  >>  $csv/csv_mw/StateOfTheWikiOverview_$edits.csv
  tail -n +12 $csv/csv_wq/StateOfTheWikiOverviewWikiquote_$edits.csv   >>  $csv/csv_mw/StateOfTheWikiOverview_$edits.csv
  tail -n +12 $csv/csv_ws/StateOfTheWikiOverviewWikisource_$edits.csv  >>  $csv/csv_mw/StateOfTheWikiOverview_$edits.csv
  tail -n +12 $csv/csv_wv/StateOfTheWikiOverviewWikiversity_$edits.csv >>  $csv/csv_mw/StateOfTheWikiOverview_$edits.csv

  rsync -av $csv/csv_mw/StateOfTheWiki*_$edits.csv $htdocs/wikimedia/editors
}  

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
log=$dumps/logs/count_wikis_by_size_by_growth.log
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $perl

date >> $log

generate wp 5 EN
generate wb 5 wikibooks/EN
generate wk 5 wiktionary/EN
generate wn 5 wikinews/EN
generate wq 5 wikiquote/EN
generate wo 5 wikivoyage/EN
generate ws 5 wikisource/EN
generate wv 5 wikiversity/EN

generate wp 100 EN
generate wb 100 wikibooks/EN
generate wk 100 wiktionary/EN
generate wn 100 wikinews/EN
generate wq 100 wikiquote/EN
generate wo 100 wikivoyage/EN
generate ws 100 wikisource/EN
generate wv 100 wikiversity/EN

concatenate 5
concatenate 100

cd $csv/csv_mw
zip StateOfTheWiki.zip StateOfTheWiki*.csv
rsync -av $csv/csv_mw/StateOfTheWiki.zip $htdocs/wikimedia/editors
rm StateOfTheWiki*.csv

echo "All done"


