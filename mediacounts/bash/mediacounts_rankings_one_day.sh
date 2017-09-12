#!/bin/bash -x
ulimit -v 400000

# rsync -av -ipv4 $archive_local/$base.csv.zip $archive_remote

# strip extensions
base=$(basename -s ".tsv.bz2" $4) # $4 is file to be parsed, e.g. mediacounts.2015-01-01.v00.tsv

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

logfile=$wikistats_data/mediacounts/logs/rankings_one_day/log_rankings_one_day_$base.txt
exec 1> $logfile 2>&1 # send stdout/stderr to file

{ set +x; } 2>/dev/null ; echo -e "\n=== Arguments for bash file ===" ; set -x

archive_remote=$1
archive_local=$2
dir_tmp=$3
file=$4

dir_text=$wikistats/mediacounts/

{ set +x; } 2>/dev/null ; echo -e "\n=== Check if directories exist ===" ; set -x

# commented until folder is directly accessible
if [ ! -d "$archive_remote" ]; then
  echo "archive_remote '$archive_remote' not found! abort"
  exit
fi
if [ ! -d "$archive_local" ]; then
  echo "archive_local '$archive_local' not found! abort"
  exit
fi
if [ ! -d "$dir_tmp" ]; then
  echo "dir_tmp '$dir_tmp' not found! abort"
  exit
fi
# commented until folder is directly accessible
if [ ! -f "$archive_remote/$file" ]; then
  echo "data_unsorted '$archive_remote/$file' not found! abort"
  exit
fi

{ set +x; } 2>/dev/null ; echo -e "\n=== Remove files from earlier run ===" ; set -x

cd $dir_tmp
ls -l
rm -f *.bz2
rm -f *.csv
rm -f *.tsv

{ set +x; } 2>/dev/null ; echo -e "\n=== Download file from remote server and unpack ===" ; set -x

# commented out during tests for speed (and can be dropped entirely when direct access)
cp "$archive_remote/$file" .
bunzip2 -f $file
data_unsorted=$base.tsv # e.g. mediacounts.2015-01-01.v00.tsv
ls -l 

# if [ 1 -eq 0 ]; then  # quickly disable this section, during tests

{ set +x; } 2>/dev/null ; echo -e "\n=== Read $data_unsorted, sort and copy 1000 lines (2x) for columns 2-25 except (6,7,15,16,21,22) ==" ; set -x

set +x
for column in `seq -f "%02g" 2 25`;
do
  if [ $column == 6 ] ||  [ $column == 7 ] ||  [ $column == 15 ] ||  [ $column == 16 ] ||  [ $column == 21 ] ||  [ $column == 22 ] ; then
  continue 
  fi 

  set -x  
  data_sorted_partial=$base.sorted_key$column.csv
  echo -e "file: $data_unsorted - sorted by column $column - top 1000 results\n"  >  $data_sorted_partial
  cat $dir_text/top1000-headers.txt                                               >> $data_sorted_partial
  sort -t $'\t' -k${column}nr $data_unsorted | head -n 1000 | sed 's/\t/,/g'      >> $data_sorted_partial
  cat $dir_text/top1000-footers.txt                                               >> $data_sorted_partial
  set +x
done
set -x

# fi

{ set +x; } 2>/dev/null ; echo -e "\n=== Do again for columns 17-20, now for ogg extension only ==" ; set -x

ext="ogg"

data_unsorted=$file
grep "\.$ext" $base.tsv > $data_unsorted

set +x
for column in `seq -f "%02g" 17 20`; # -f redundant in this case, just a reminder
do
  set -x
  data_sorted_partial=$base.sorted_key$column.$ext.csv
  echo -e "\nfile: $data_unsorted - sorted by column $column - ext $ext only - top 1000 results"  \
                                                                                  >  $data_sorted_partial
  cat $dir_text/top1000-headers.txt                                               >> $data_sorted_partial
  sort -t $'\t' -k${column}nr $data_unsorted | head -n 1000 | sed 's/\t/,/g'      >> $data_sorted_partial
  cat $dir_text/top1000-footers.txt                                               >> $data_sorted_partial
  set +x
done
set -x

{ set +x; } 2>/dev/null ; echo -e "\n=== Create zipfile for all newly created csv files ===" ; set -x

zipfile=$(basename -s ".tsv.bz2" $file).csv.zip
zipfile=$(sed 's|mediacounts|mediacounts.top1000|g' <<< $zipfile)

rm "$archive_local/$zipfile" 
zip -q "$archive_local/$zipfile" $base*.csv
echo

{ set +x; } 2>/dev/null ; echo -e "\n=== Remove temoporary files ===" ; set -x

ls -l
rm -f *.csv
rm -f *.tsv
rm -f *.bz2

# echo -e "\n$dir_tmp contains:"
# ls -l $dir_tmp

# echo -e "\n$archive_local contains:"
# ls -l $archive_local

