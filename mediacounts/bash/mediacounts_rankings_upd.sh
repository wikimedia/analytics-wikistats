#!/bin/bash
ulimit -v 40000000

wikistats="/a/wikistats_git"
archive_local="$wikistats/mediacounts"
archive_remote="/mnt/hdfs/wmf/data/archive/mediacounts"
bash="/home/ezachte/wikistats/mediacounts/bash"

cd $bash

year_prev=2015
year_now=2015

for year in `seq 2015 2035`;
do
  if [ -d "$archive_remote/daily/$year" ]; then
    echo "$archive_remote/daily/$year"
    if [ ! -d "$archive_local/daily/$year" ]; then
      echo "Create local dir $archive_local/daily/$year"
      mkdir "$archive_local/daily/$year"
      
      if [ ! -d "$archive_local/daily/$year" ]; then
        echo "Creation of local dir $archive_local/daily/$year failed! Abort"
        exit 
      fi
    fi
    year_prev=$year_now
    year_now=$year
  fi
done

echo Year now $year_now, previous year $year_prev

shopt -s nullglob # http://www.cyberciti.biz/faq/bash-loop-over-file/

for year in `seq $year_prev $year_now`; # for 2015 both contain same year
do
  echo "Scan folder '$archive_remote/daily/$year' for files to process"
  echo

  cd "$archive_remote/daily/$year/"

  for file in mediacounts*.tsv.bz2
  do
    if [ -f $file ] ; then
     echo "Found $file"
      zipfile=$(basename -s ".tsv.bz2" $file).csv.zip
      zipfile=$(sed 's|mediacounts|mediacounts.top1000|g' <<< $zipfile)
      if [ ! -f "$archive_local/daily/$year/$zipfile" ]; then
        echo
        echo =========================================================================
        echo "Not found $zipfile -> process $file"
        echo
        echo mediacounts_rankings_upd.sh -> mediacounts_rankings.sh 
        echo
        $bash/mediacounts_rankings.sh "$archive_remote/daily/$year" \
                                      "$archive_local/daily/$year"  \
                                      "$archive_local/tmp" \
                                      $file 
        echo publish $zipfile
        echo "hdfs dfs -put -f $archive_local/daily/2015/$zipfile hdfs:///wmf/data/archive/mediacounts/daily/2015"
        hdfs dfs -put -f $archive_local/daily/2015/$zipfile hdfs:///wmf/data/archive/mediacounts/daily/2015
     fi
    fi 
  done
done  
  
exit


