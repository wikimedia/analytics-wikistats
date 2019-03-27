#!/bin/sh

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")
yyyy=$(date +"%Y")

#log_file="/home/ezachte/wikistats_backup/logs/log_backup_scripts_$yyyymmdd.txt"
#exec >> $log_file 2>&1 # send stdout/stderr to file

wikistats=$WIKISTATS_SCRIPTS
wikistats_backup=$WIKISTATS_BACKUP

# remove only daily zip after 30 days, not monthly

find ${wikistats}_backup/scripts/backup/bash_????_??_??.zip     -mtime 30 -type f -delete 
find ${wikistats}_backup/scripts/dumps/bash_????_??_??.zip      -mtime 30 -type f -delete 
find ${wikistats}_backup/scripts/dammit.lt/bash_????_??_??.zip  -mtime 30 -type f -delete 
find ${wikistats}_backup/scripts/dammit.lt/perl_????_??_??.zip  -mtime 30 -type f -delete 
find ${wikistats}_backup/scripts/dumps/perl_????_??_??.zip      -mtime 30 -type f -delete
find ${wikistats}_backup/scripts/squids/bash_????_??_??.zip     -mtime 30 -type f -delete 
find ${wikistats}_backup/scripts/squids/perl_????_??_??.zip     -mtime 30 -type f -delete
find ${wikistats}_backup/scripts/progress/perl_????_??_??.zip   -mtime 30 -type f -delete

# new zips, often daily and mostly monthly, sometimes yearly

cd $wikistats/analytics/bash
zip -rT $wikistats_backup/scripts/analytics/bash_$yyyy.zip   * -x *out  

cd $wikistats/analytics/perl
zip -rT $wikistats_backup/scripts/analytics/perl_$yyyy.zip   *  

cd $wikistats/animations
zip -rT $wikistats_backup/animations/animations_$yyyymm.zip  * -x *out  # keep # misc = scripts (js) and other files (e.g. images)

cd $wikistats/dammit.lt/bash
zip -rT $wikistats_backup/scripts/dammit.lt/bash_$yyyy.zip  * -x *out

cd $wikistats/dammit.lt/perl
zip -rT $wikistats_backup/scripts/dammit.lt/perl_$yyyy.zip  * 

cd $wikistats/image_sets/bash
zip -rT $wikistats_backup/scripts/image_sets/bash_$yyyy.zip  * -x *out

cd $wikistats/image_sets/perl
zip -rT $wikistats_backup/scripts/image_sets/perl_$yyyy.zip  * 

cd $wikistats/lib
zip -rT $wikistats_backup/scripts/lib/perl_$yyyymm.zip       * 

cd $wikistats/mail-lists/bash
zip -rT $wikistats_backup/scripts/mail-lists/bash_$yyyymmdd.zip   * -x *out # remove after 30 days  
zip -rT $wikistats_backup/scripts/mail-lists/bash_$yyyymm.zip     * -x *out # keep 

cd $wikistats/mail-lists/perl
zip -rT $wikistats_backup/scripts/mail-lists/perl_$yyyymmdd.zip   *         # remove after 30 days 
zip -rT $wikistats_backup/scripts/mail-lists/perl_$yyyymm.zip     *         # keep

cd $wikistats/mediacounts/bash
zip -rT $wikistats_backup/scripts/mediacounts/bash_$yyyymmdd.zip   * -x *out # remove after 30 days  
zip -rT $wikistats_backup/scripts/mediacounts/bash_$yyyymm.zip     * -x *out # keep 

cd $wikistats/backups/bash
zip -rT $wikistats_backup/scripts/backup/bash_$yyyymmdd.zip  * -x *out  # remove after 30 days
zip -rT $wikistats_backup/scripts/backup/bash_$yyyymm.zip    * -x *out  # keep

cd $wikistats/dumps/bash
zip -rT $wikistats_backup/scripts/dumps/bash_$yyyymmdd.zip   * -x *out  # remove after 30 days
zip -rT $wikistats_backup/scripts/dumps/bash_$yyyymm.zip     * -x *out  # keep

cd $wikistats/dumps/perl
zip -rT $wikistats_backup/scripts/dumps/perl_$yyyymmdd.zip   *          # remove after 30 days 
zip -rT $wikistats_backup/scripts/dumps/perl_$yyyymm.zip     *          # keep

cd $wikistats/dumps/progress
zip -rT $wikistats_backup/scripts/progress/perl_$yyyymmdd.zip   *          # remove after 30 days 
zip -rT $wikistats_backup/scripts/progress/perl_$yyyymm.zip     *          # keep

cd $wikistats/dumps/dblists
zip -rT $wikistats_backup/scripts/dumps/dblists_$yyyymm.zip  *          # keep

cd $wikistats/squids/bash
zip -rT $wikistats_backup/scripts/squids/bash_$yyyymmdd.zip  * -x *out  # remove after 30 days
zip -rT $wikistats_backup/scripts/squids/bash_$yyyymm.zip    * -x *out  # keep

cd $wikistats/squids/perl
zip -rT $wikistats_backup/scripts/squids/perl_$yyyymmdd.zip  *          # remove after 30 days 
zip -rT $wikistats_backup/scripts/squids/perl_$yyyymm.zip    *          # keep

# rsync -av $backup/*.zip  thorium.eqiad.wmnet::wikistats/backup/
