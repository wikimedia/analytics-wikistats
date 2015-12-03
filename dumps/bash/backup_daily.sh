#!/bin/sh

dt=$(date +[%Y-%m-%d][%H:%M])

wikistats=/home/ezachte/wikistats
remote=stat1001.eqiad.wmnet::srv/wikistats/backup/

cd $wikistats
zipfile=wikistats_scripts_dumps_$dt.zip
zip /a/wikistats_git/backup/$zipfile dumps/perl/*.pl dumps/perl/*.pm dumps/bash/*.sh
cd /a/wikistats_git/backup 
rsync -av $zipfile $remote 

cd $wikistats
zipfile=wikistats_scripts_dammit_$dt.zip
zip /a/wikistats_git/backup/$zipfile dammit.lt/perl/*.pl dammit.lt/perl/*.pm dammit.lt/bash/*.sh
cd /a/wikistats_git/backup 
rsync -av $zipfile $remote 

zip=StatisticsMonthly-$dt.zip

echo Build $zip
zip -r $zip /a/wikistats_git/dumps/csv/*/StatisticsMonthly.csv

echo Publish
echo "rsync -av $zip stat1001.eqiad.wmnet::srv/wikistats/backup/StatisticsMonthly.csv"
rsync -av $zip stat1001.eqiad.wmnet::srv/wikistats/backup/StatisticsMonthly.csv

cd /a/wikistats_git/dumps/csv
rsync -av * stat1001.eqiad.wmnet::srv/wikistats/backup/stat1002/a/wikistats_git/dumps/csv




