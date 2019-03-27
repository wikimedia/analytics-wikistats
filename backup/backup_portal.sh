#!/bin/sh

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")

log_file="/home/ezachte/wikistats_backup/logs/log_backup_portal_$yyyymm.txt"
exec >> $log_file 2>&1 # send stdout/stderr to file

wikistats=$WIKISTATS_SCRIPTS
wikistats_backup=$WIKISTATS_BACKUP

cd $wikistats/portal
zip -rT $wikistats_backup/portal/portal_$yyyymm.zip * 

cd $wikistats/viz_gallery
zip -rT $wikistats_backup/viz_gallery/viz_gallery_$yyyymm.zip * 

# rsync -av $backup/*.zip  thorium.eqiad.wmnet::wikistats/backup/
