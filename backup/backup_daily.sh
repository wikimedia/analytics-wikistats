#!/bin/sh

dt=$(date +[%Y-%m-%d][%H:%M])

wikistats=/home/ezachte/wikistats
remote=thorium.eqiad.wmnet::wikistats/backup/

cd $wikistats
zipfile=wikistats_scripts_dumps_$dt.zip
zip /a/wikistats_git/backup/$zipfile dumps/perl/*.pl dumps/perl/*.pm dumps/bash/*.sh
cd /a/wikistats_git/backup 
ls -l $zipfile
echo "rsync -av $zipfile $remote" 
rsync -av $zipfile $remote 

cd $wikistats
zipfile=wikistats_scripts_dammit_$dt.zip
zip /a/wikistats_git/backup/$zipfile dammit.lt/perl/*.pl dammit.lt/perl/*.pm dammit.lt/bash/*.sh
cd /a/wikistats_git/backup 
ls -l $zipfile
echo "rsync -av $zipfile $remote" 
rsync -av $zipfile $remote 

zip=StatisticsMonthly-$dt.zip
echo Build $zip
ls -l
zip -r $zip /a/wikistats_git/dumps/csv/*/StatisticsMonthly.csv
ls -l $zip

echo Publish
echo "rsync -av $zip thorium.eqiad.wmnet::wikistats/backup/StatisticsMonthly.csv"
rsync -av $zip thorium.eqiad.wmnet::wikistats/backup/StatisticsMonthly.csv

cd /a/wikistats_git/dumps/csv
echo "rsync -av * thorium.eqiad.wmnet::wikistats/backup/stat1005/a/wikistats_git/dumps/csv"
rsync -av --exclude="*Tmp*" --exclude="*Temp*" --exclude="*Log.txt" --exclude="*Errors.txt" thorium.eqiad.wmnet::wikistats/backup/stat1005/wikistats_git/dumps/csv




