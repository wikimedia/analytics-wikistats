#!/bin/bash -x

# find days since 2015 for which mediacounts rankings do not exist yet
# for each such day invoke mediacounts_rankings_one_day.sh to add ~20 files, one for each column

yyyymmdd=$(date +"%Y_%m_%d")

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

logfile=$wikistats_data/mediacounts/logs/rankings_add_days/log_mediacounts_rankings_add_days_$yyyymmdd.txt

exec 1> $logfile 2>&1 # send stdout/stderr to file

ulimit -v 40000000

archive_local=$wikistats_data/mediacounts
archive_remote=/mnt/hdfs/wmf/data/archive/mediacounts
bash=$wikistats/mediacounts/bash

cd $bash

#zipfile="mediacounts.top1000.2015-12-31.v00.csv.zip" 
#year=2015
#echo "hdfs dfs -put -f $archive_local/daily/$year/$zipfile hdfs:///wmf/data/archive/mediacounts/daily/$year"
#hdfs dfs -put -f $archive_local/daily/$year/$zipfile hdfs:///wmf/data/archive/mediacounts/daily/$year

set +x 
echo -e "\n=== Create local directory for year which exists only at remote server ===\n" 

year_prev=2015
year_now=2015

for year in `seq 2015 2035`;
do
  if [ -d "$archive_remote/daily/$year" ]; then  # remote dir is created by another process (not Wikistats)
    echo -e "=== Remote dir found: $archive_remote/daily/$year ==="  

    if [ ! -d "$archive_local/daily/$year" ]; then
      echo "=== Local dir not found: $archive_remote/daily/$year ===" 
      mkdir "$archive_local/daily/$year"
      
      if [ ! -d "$archive_local/daily/$year" ]; then
        echo "=== Local dir creation failed: $archive_remote/daily/$year! Abort ===" 
        exit 
      fi
    fi
    year_prev=$year_now
    year_now=$year
  fi
done

echo -e "\n=== Year now $year_now, previous year $year_prev ===" 
echo -e "\n=== Create zipfile(s), one per day, with rankings, and upload to hdfs ===" ;

shopt -s nullglob # http://www.cyberciti.biz/faq/bash-loop-over-file/

for year in `seq $year_prev $year_now`; # for 2015 both contain same year
do
  echo -e "Scan folder '$archive_remote/daily/$year' for files to process\n"

  cd "$archive_remote/daily/$year/"

  for file in mediacounts*.tsv.bz2
  do
    if [ -f $file ] ; then

      zipfile=$(basename -s ".tsv.bz2" $file).csv.zip
      zipfile=$(sed 's|mediacounts|mediacounts.top1000|g' <<< $zipfile)

      if [ ! -f "$archive_local/daily/$year/$zipfile" ]; then

        echo -e "\n==========================================================================="
        echo -e "Found $file, but not $zipfile -> process $file\n"
        echo -e "Prep files for one day via 'mediacounts_rankings_one_day.sh'\n" 

        set -x
        $bash/mediacounts_rankings_one_day.sh "$archive_remote/daily/$year" \
                                              "$archive_local/daily/$year"  \
                                              "$archive_local/tmp" \
                                              $file 

        hdfs dfs -put -f $archive_local/daily/$year/$zipfile hdfs:///wmf/data/archive/mediacounts/daily/$year
        set +x

     fi
    fi 
  done
done

hdfs dfs -ls -R /wmf/data/archive/mediacounts/daily | grep top1000 > $wikistats_data/mediacounts/data_in_hdfs.txt  
