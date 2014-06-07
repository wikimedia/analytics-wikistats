#!/bin/sh

wikistats=/a/wikistats_git

backup=$wikistats/backup
analytics=$wikistats/analytics
dammit=$wikistats/dammit.lt
dumps=$wikistats/dumps

perl=$dumps/perl
bash=$dumps/bash
csv=$dumps/csv
out=$dumps/out

dt=$(date +[%Y-%m-%d][%H:%M])
zip=StatisticsMonthly-$dt.zip

zip -r $zip /a/wikistats_git/dumps/csv/*/StatisticsMonthly.csv

rsync -av $zip stat1001.wikimedia.org::a/wikistats/backup/StatisticsMonthly.csv




