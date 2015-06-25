#!/bin/sh

dt=$(date +[%Y-%m-%d][%H:%M])
zip=StatisticsMonthly-$dt.zip

echo Build $zip
zip -r $zip /a/wikistats_git/dumps/csv/*/StatisticsMonthly.csv

echo Publish
echo "rsync -av $zip stat1001.eqiad.wmnet::srv/wikistats/backup/StatisticsMonthly.csv"
rsync -av $zip stat1001.eqiad.wmnet::srv/wikistats/backup/StatisticsMonthly.csv

cd /a/wikistats_git/dumps/csv
rsync -av * stat1001.eqiad.wmnet::srv/wikistats/backup/stat1002/a/wikistats_git/dumps/csv




