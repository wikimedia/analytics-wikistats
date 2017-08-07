#!/bin/sh

yyyymmdd=$(date +"%Y_%m_%d")

crontab -l > /home/ezachte/crontab.backup
crontab -l > /home/ezachte/wikistats_backup/crontab/crontab_backup_$yyyymmdd
