#!/bin/sh

backup=/a/wikistats/backup
analytics=/a/wikistats/analytics
scripts=/a/wikistats/scripts
bash=/a/wikistats/scripts/bash
csv=/a/wikistats/csv
out=/a/wikistats/out
projectcounts=/a/dammit.lt/projectcounts
dammit=/a/dammit.lt

dt=$(date +[%Y-%m-%d][%H:%M])

$bash/zip_out.sh wb
$bash/zip_out.sh wk
$bash/zip_out.sh wn
$bash/zip_out.sh wp
$bash/zip_out.sh wq
$bash/zip_out.sh ws
$bash/zip_out.sh wv
$bash/zip_out.sh wx
$bash/zip_out.sh wm

cd $out/zip_all
zip $backup/out_all_english_$dt.zip out*.zip

cd /home/ezachte
tar --no-recursion -c -f $backup/home_$dt.tar * .*

cd $analytics
tar cvzf $backup/analytics_$dt.tar.gz *

cd $scripts
zip -r $backup/scripts_wikistats_$dt.zip bash/*.sh perl/*.p* lib/*

cd $csv/zip_all
zip $backup/csv_main_$dt.zip *_main.zip

cd $out/zip_all
zip $backup/out_main_$dt.zip out*.zip

cd $projectcounts
zip $backup/projectcounts_dammit_$dt.zip projectcounts*.tar

cd $dammit
zip $backup/scripts_dammit_$dt.zip *.sh *.p*

rsync -av $backup/* stat1001.wikimedia.org::a/wikistats/backup/



