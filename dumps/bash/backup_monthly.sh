#!/bin/sh

backup=/a/wikistats/backup
analytics=/a/wikistats/analytics
scripts=/a/wikistats/scripts
csv=/a/wikistats/csv
projectcounts=/a/dammit.lt/projectcounts
dammit=/a/dammit.lt

dt=$(date +[%Y-%m-%d][%H:%M])

cd $csv/zip_all
zip $backup/csv_full_$dt.zip *.zip

rsync -av $backup/* stat1001.wikimedia.org::a/wikistats/backup/
