#!/bin/bash
ulimit -v 400000

cd /home/ezachte

dir_text="/a/wikistats_git/mediacounts/"
archive_remote=$1
archive_local=$2
dir_tmp=$3
file=$4
data_unsorted=$4 # e.g. mediacounts.2015-01-01.v00.tsv
# rsync -av -ipv4 $archive_local/$base.csv.zip $archive_remote

echo "archive_remote: $archive_remote"
echo "archive_local: $archive_local"
echo "dir_temp: $dir_tmp"
echo "file: $file ->"

# strip extensions
base=$(basename -s ".tsv.bz2" $file)
echo "base: $base"

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

cd $dir_tmp
rm -f *.bz2
rm -f *.csv
rm -f *.tsv

# commented out during tests for speed (and can be dropped entirely when direct access)
echo "fetch $base.tsv"
cp "$archive_remote/$file" .
bunzip2 -f $file
echo "fetched"
echo
ls -l 

# column=2 # test
# echo "sort -t $'\t' -k${column}nr $data_unsorted | head -n 1000 | sed 's/,/%2C/g' | sed 's/\t/,/g' >> ${data_sorted}_top_1000.csv" # test

# if [ 1 -eq 0 ]; then

echo phase: all file extensions
echo
data_unsorted=$base.tsv
echo read  $data_unsorted
echo
for column in `seq -f "%02g" 2 25`;
do
  if [ $column == 6 ] ||  [ $column == 7 ] ||  [ $column == 15 ] ||  [ $column == 16 ] ||  [ $column == 21 ] ||  [ $column == 22 ] ; then
  continue 
  fi 
  
  data_sorted_partial=$base.sorted_key$column.csv
 
  echo write $data_sorted_partial

  echo "file: $data_unsorted - sorted by column $column - top 1000 results"  >  $data_sorted_partial
  cat $dir_text/top1000-headers.txt                                          >> $data_sorted_partial
  sort -t $'\t' -k${column}nr $data_unsorted | head -n 1000 | sed 's/\t/,/g' >> $data_sorted_partial
  cat $dir_text/top1000-footers.txt                                          >> $data_sorted_partial
done

# fi

ext="ogg"
echo
echo phase: extension $ext only
echo 

data_unsorted=$file
echo read  $data_unsorted
echo
grep "\.$ext" $base.tsv > $data_unsorted

for column in `seq -f "%02g" 17 20`; # -f redundant in this case, just a reminder
do
  data_sorted_partial=$base.sorted_key$column.$ext.csv
  
  echo write $data_sorted_partial
  echo "file: $data_unsorted - sorted by column $column - ext $ext only - top 1000 results"  \
                                                                             >  $data_sorted_partial
  cat $dir_text/top1000-headers.txt                                          >> $data_sorted_partial
  sort -t $'\t' -k${column}nr $data_unsorted | head -n 1000 | sed 's/\t/,/g' >> $data_sorted_partial
  cat $dir_text/top1000-footers.txt                                          >> $data_sorted_partial
done

echo

zipfile=$(basename -s ".tsv.bz2" $file).csv.zip
zipfile=$(sed 's|mediacounts|mediacounts.top1000|g' <<< $zipfile)

echo "zip -> $archive_local/$zipfile"
rm "$archive_local/$zipfile" 
zip "$archive_local/$zipfile" $base*.csv
echo
ls -l
rm -f *.csv
rm -f *.tsv
rm -f *.bz2
# echo $dir_tmp contains:
# ls -l $dir_tmp
echo
echo $archive_local contains:
ls -l $archive_local

