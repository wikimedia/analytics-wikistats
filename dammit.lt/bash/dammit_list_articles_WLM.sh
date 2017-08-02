#!/bin/sh

# Q&D hack to retrieve uploaders to Wiki Loves Monuments
# use ./dammit_list_views_by_category.sh to get list of images within category 'Images_from_Wiki_Loves_Monuments_2016' 
# use Q&D DammitScanPages.pl to collect username and url of image 
wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dammit.lt/perl # tests
bash=$wikistats/dammit.lt/bash
out=$dumps/out
projectcounts=/a/dammit.lt/projectcounts
projectviews=/a/dammit.lt/projectviews
log=$projectviews/log_projectviews.txt
csv_in=$dumps/csv
csv_out=$projectviews/csv
meta=$csv_in/csv_mw/MetaLanguages.csv
date_switch="201609"
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $bash
# ./dammit_list_views_by_category.sh 'commons.wikimedia.org' 'Images_from_Wiki_Loves_Monuments_2016' 2016-09 1 'wm-commons' 2

cd $perl
perl DammitScanPages.pl

cd /a/dammit.lt/pagecounts/categorized/data/wm-commons/2016-09/Images_from_Wiki_Loves_Monuments_2016
rsync -arv -ipv4 WLM_uploaders.html thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs
