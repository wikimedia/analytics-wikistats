#!/bin/bash

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
log=$dumps/logs/count_wikis_by_size_by_growth.log
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

cd $perl

date >> $log

code='wb' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/wikibooks/EN

code='wk' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/wiktionary/EN

code='wn' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/wikinews/EN

code='wp' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/EN

code='wq' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/wikiquote/EN

code='wo' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/wikivoyage/EN

code='ws' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/wikisource/EN

code='wv' ; 
perl WikiCountsStateOfTheWiki.pl -p $code -i $csv/csv_$code -o $csv/csv_$code >> $log
rsync -av $csv/csv_$code/StateOfTheWiki*.csv $htdocs/wikiversity/EN



