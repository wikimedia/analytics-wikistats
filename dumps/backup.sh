#!/bin/sh

dt=$(date +[%Y-%m-%d][%H:%M])

zip -r /a/backup/csv_$dt.zip /a/wikistats/csv_* -x \*.zip
echo $dt Backup /a/wikistats/csv_* >> /a/backup/backup.log 

zip -r /a/backup/perl_$dt.zip /home/ezachte/wikistats/*.p* 
echo $dt Backup /home/ezachte/wikistats/*.p* >> /a/backup/backup.log 
zip -r /a/backup/perl_$dt.zip /a/dammit.lt/*.p* 
echo $dt Backup /a/dammit.lt/*.p* >> /a/backup/backup.log 

zip -r /a/backup/bash_$dt.zip /home/ezachte/wikistats/*.sh 
echo $dt Backup /home/ezachte/wikistats/*.sh >> /a/backup/backup.log 
zip -r /a/backup/bash_$dt.zip /a/dammit.lt/*.sh 
echo $dt Backup /a/dammit.lt/*.sh >> /a/backup/backup.log 

#zip -r /a/backup/htdocs_$dt.zip /mnt/htdocs/*
#echo Backup /mnt/htdocs/* -> /a/backup/htdocs_$dt.zip 

cp /a/dammit.lt/projectcounts/*.tar /a/backup
