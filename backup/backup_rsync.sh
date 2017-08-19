#!/bin/sh

backup_local=/home/ezachte/wikistats_backup
backup_remote=thorium.eqiad.wmnet::srv/wikistats/backup/

echo "rsync local=$backup_local remote=$backup_remote"

cd $backup_local

rsync -av * $backup_remote --exclude=squids*zip | tee rsync_log.txt | cat

#rsync -av --exclude="*Tmp*" --exclude="*Temp*" --exclude="*Log.txt" --exclude="*Errors.txt" thorium.eqiad.wmnet::srv/wikistats/backup/stat1005/wikistats_git/dumps/csv




