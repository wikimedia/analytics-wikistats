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

projectcounts=/a/dammit.lt/projectcounts
scripts=/home/ezachte/wikistats/ 

dt=$(date +[%Y-%m-%d][%H:%M])

$bash/zip_all.sh # all = all projects ../dumps/csv/csv_* and ..dumps/out/out_*

cd /home/ezachte
echo "tar --no-recursion -c -f $backup/home_$dt.tar * .*"
tar --no-recursion -c -f $backup/home_$dt.tar * .*

cd $out/zip_all
echo "zip $backup/out_all_english_$dt.zip out*.zip"
zip $backup/out_all_english_$dt.zip out*.zip

cd $analytics
echo "tar cvzf $backup/analytics_$dt.tar.gz *"
tar cvzf $backup/analytics_$dt.tar.gz *

cd $scripts
echo "zip -r $backup/scripts_wikistats_$dt.zip . -i *.sh *.pl *.pm *.lib *.dblist read*"
zip -r       $backup/scripts_wikistats_$dt.zip . -i *.sh *.pl *.pm *.lib *.dblist read*
echo "zip -r $backup/scripts_wikistats_$dt.zip animations/* portal/* mediacounts/* progress/* reportcard/* viz_gallery/*"
zip -r       $backup/scripts_wikistats_$dt.zip animations/* portal/* mediacounts/* progress/* reportcard/* viz_gallery/*

cd $csv/zip_all
echo "zip $backup/csv_main_$dt.zip *_main.zip"
zip $backup/csv_main_$dt.zip *_main.zip

cd $out/zip_all
echo "zip $backup/out_main_$dt.zip out*.zip"
zip $backup/out_main_$dt.zip out*.zip

cd $projectcounts
echo "zip $backup/projectcounts_dammit_$dt.zip /a/dammit.lt/projectcounts/*"
zip $backup/projectcounts_dammit_$dt.zip /a/dammit.lt/projectcounts/*

cd /a/dammit.lt
echo "zip -r $backup/scripts_dammit_$dt.zip * -i *.sh *.p*"
zip       -r $backup/scripts_dammit_$dt.zip * -i *.sh *.p*

echo "rsync -av $backup/* stat1001.eqiad.wmnet::srv/wikistats/backup/"
rsync -av $backup/* stat1001.eqiad.wmnet::srv/wikistats/backup/



