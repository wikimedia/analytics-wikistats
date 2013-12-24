#!/bin/bash

output=/a/dammit.lt/pagecounts/merged
dataset2=dataset2.wikimedia.org::pagecounts-ez/merged/

echo Publish new files 
echo "rsync -arv --include=*.bz2 $output/* $dataset2"
      rsync -arv --include=*.bz2 $output/* $dataset2
