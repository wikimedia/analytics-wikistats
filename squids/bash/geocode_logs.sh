#!/bin/bash
OUTPUT_DIR=/a/squid/archive/sampled-geocoded

mkdir -p $OUTPUT_DIR

for file_path in /a/squid/archive/sampled/sampled-*.gz
  do

echo "Started  processing $file_path"
file_name=`basename $file_path`
# add geocoded inside filename
geocoded_file_name=$(echo $file_name | sed -e 's/.gz/'.geocode.gz'/')
zcat $file_path |  ./udp-filter -g -b country | gzip > $OUTPUT_DIR/$geocoded_file_name
echo "Finished processing $file_path"

done

