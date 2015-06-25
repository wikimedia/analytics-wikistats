#!/bin/bash

# script adapted from Stefan's for one time only converting of input files 
# keep for reuse ?

INPUT_DIR=""
OUTPUT_DIR=""
while getopts "se" optname
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

for file_path in $INPUT_DIR*tsv*201409*
	do
	echo "Started  processing $file_path"
	file_name=`basename $file_path`
	# add geocoded inside filename
	# geocoded_file_name=$(echo $file_name | sed -e 's/.gz/'.geocode.gz'/') # obsolete? has not been used for ../sampled-geocoded right now
	geocoded_file_name=$file_name
	if [ ! -f $OUTPUT_DIR/$geocoded_file_name ]
	then	
		echo "zcat $file_path | sed 's/\t/ /g' | udp-filter -g -b country | gzip > $OUTPUT_DIR/$geocoded_file_name"
		zcat $file_path |  sed 's/\t/ /g' | udp-filter -g -b country | gzip > $OUTPUT_DIR/$geocoded_file_name
		echo "Finished processing $file_path"
	fi	

done
