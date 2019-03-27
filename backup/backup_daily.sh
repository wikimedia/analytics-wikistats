#!/bin/sh

# script migrated to stat1007

dt=$(date +[%Y-%m-%d][%H:%M])

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA
wikistats_backup=$WIKISTATS_BACKUP
remote=thorium.eqiad.wmnet::wikistats/backup/

cd $wikistats/
zipfile=wikistats_scripts_dumps_$dt.zip
zip $wikistats_backup/dumps_scripts/$zipfile dumps/perl/*.pl dumps/perl/*.pm dumps/bash/*.sh
cd $wikistats_backup/dumps_scripts 
ls -l $zipfile
echo "rsync -av $zipfile $remote" 
#rsync -av $zipfile $remote 

cd $wikistats/
zipfile=wikistats_scripts_dammit_$dt.zip
zip $wikistats_backup/dammit_scripts/$zipfile dammit.lt/perl/*.pl dammit.lt/perl/*.pm dammit.lt/bash/*.sh
cd $wikistats_backup/dammit_scripts 
ls -l $zipfile
echo "rsync -av $zipfile $remote" 
#rsync -av $zipfile $remote 

cd $wikistats_data/dumps/csv
zipfile=StatisticsMonthly-$dt.zip
echo Build $zipfile
zip -r $wikistats_backup/dumps_statistics_monthly/$zipfile */StatisticsMonthly.csv
cd $wikistats_backup/dumps_statistics_monthly 
ls -l $zipfile

echo Publish
echo "rsync -av $zip thorium.eqiad.wmnet::wikistats/backup/StatisticsMonthly.csv"
#rsync -av $zip thorium.eqiad.wmnet::wikistats/backup/StatisticsMonthly.csv
exit

cd /a/wikistats_git/dumps/csv
echo "rsync -av * thorium.eqiad.wmnet::wikistats/backup/stat1005/a/wikistats_git/dumps/csv"
rsync -av --exclude="*Tmp*" --exclude="*Temp*" --exclude="*Log.txt" --exclude="*Errors.txt" thorium.eqiad.wmnet::wikistats/backup/stat1005/wikistats_git/dumps/csv




