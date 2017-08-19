#!/bin/sh

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")

crontab -l > /home/ezachte/crontab.backup
crontab -l > /home/ezachte/wikistats_backup/crontab/crontab_backup_$yyyymmdd

cp /home/ezachte/.bash_aliases /home/ezachte/wikistats_backup/sysfiles/.bash_aliases_$yyyymm
