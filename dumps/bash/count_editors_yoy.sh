#!/bin/bash

ulimit -v 1000000
clear

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
csv=$dumps/csv
htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/
dataset1001=dataset1001.wikimedia.org::pagecounts-ez/wikistats/

cd $perl
perl WikiReportsYearOverYear.pl # Q&D fix paths in perl scripts

zip $csv/csv_wb/csv_wb_active_editors.zip  $csv/csv_wb/ActiveEditorsPerWiki*.csv
zip $csv/csv_wk/csv_wk_active_editors.zip  $csv/csv_wk/ActiveEditorsPerWiki*.csv
zip $csv/csv_wn/csv_wn_active_editors.zip  $csv/csv_wn/ActiveEditorsPerWiki*.csv
zip $csv/csv_wo/csv_wo_active_editors.zip  $csv/csv_wo/ActiveEditorsPerWiki*.csv
zip $csv/csv_wp/csv_wp_active_editors.zip  $csv/csv_wp/ActiveEditorsPerWiki*.csv
zip $csv/csv_wq/csv_wq_active_editors.zip  $csv/csv_wq/ActiveEditorsPerWiki*.csv
zip $csv/csv_ws/csv_ws_active_editors.zip  $csv/csv_ws/ActiveEditorsPerWiki*.csv
zip $csv/csv_wv/csv_wv_active_editors.zip  $csv/csv_wv/ActiveEditorsPerWiki*.csv
zip $csv/csv_wx/csv_wx_active_editors.zip  $csv/csv_wx/ActiveEditorsPerWiki*.csv

rsync -arv -ipv4 --include=*.bz2 $csv/csv_wb/csv_wb_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_wk/csv_wk_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_wn/csv_wn_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_wo/csv_wo_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_wp/csv_wp_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_wq/csv_wq_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_ws/csv_ws_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_wv/csv_wv_active_editors.zip $dataset1001 
rsync -arv -ipv4 --include=*.bz2 $csv/csv_wx/csv_wx_active_editors.zip $dataset1001 

