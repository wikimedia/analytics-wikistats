#!/bin/bash

output=/a/dammit.lt/pagecounts/merged
dataset1001=/srv/dumps/pagecounts-ez/merged/

echo Publish new files 
echo "rsync -arv --include=*.bz2 $output/* $dataset1001"
      rsync -arv --include=*.bz2 $output/* $dataset1001
