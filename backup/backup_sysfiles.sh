#!/bin/sh

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")

log_file="/home/ezachte/wikistats_backup/logs/log_backup_sysfiles_$yyyymm.txt"
exec >> $log_file 2>&1 # send stdout/stderr to file

# remove daily backups older than 30 days (but keep monthly backups)
find /home/ezachte/wikistats_backup/crontab_backup_????_??_??         -mtime +30 -type f -delete
find /home/ezachte/wikistats_backup/sysfiles/.bash_aliases_????_??_?? -mtime +30 -type f -delete

crontab -l > /home/ezachte/crontab.backup
# daily file, will be deleted after 30 days
crontab -l > /home/ezachte/wikistats_backup/crontab/crontab_backup_$yyyymmdd
# monthly file, overwritten daily till end of month, keep
crontab -l > /home/ezachte/wikistats_backup/crontab/crontab_backup_$yyyymm

# daily file, will be deleted after 30 days
cp /home/ezachte/.bash_aliases /home/ezachte/wikistats_backup/sysfiles/.bash_aliases_$yyyymmdd
# monthly file, overwritten daily till end of month, keep
cp /home/ezachte/.bash_aliases /home/ezachte/wikistats_backup/sysfiles/.bash_aliases_$yyyymm
