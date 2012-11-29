#!/bin/bash

while getopts "d" optname
  do
    case "$optname" in
      "s")
        echo "Geocoding sampled archives ..."
        OUTPUT_DIR=/a/squid/archive/sampled-geocoded/
        INPUT_DIR=/a/squid/archive/sampled/
        ;;
      "e")
        echo "Geocoding editors archives ..."
        OUTPUT_DIR=/a/squid/archive/edits-geocoded/
        INPUT_DIR=/a/squid/archive/edits/
        ;;
      "?")
        echo "Option not recognized $OPTARG"
        echo "Please specify either 's' for regular sampled files or 'e' for editor archives"
        ;;
      ":")
        echo "Argument missing for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while option processing"
        ;;
    esac
  done


mkdir -p $OUTPUT_DIR

for file_path in $INPUT_DIR*.gz
	do
	echo "Started  processing $file_path"
	file_name=`basename $file_path`
	# add geocoded inside filename
	geocoded_file_name=$(echo $file_name | sed -e 's/.gz/'.geocode.gz'/')
	zcat $file_path |  ./udp-filter -g -b country | gzip > $OUTPUT_DIR/$geocoded_file_name
	echo "Finished processing $file_path"

done
