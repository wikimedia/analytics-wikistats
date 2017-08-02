#!/bin/bash

cd /mnt/data/xmldatadumps/public/
#find -maxdepth 1 -path './*wiki' -type d -exec bash -c "ls '{}'/latest/*pages-articles.xml.bz2" \; >> /home/ezachte/extlinks_wp_langs.csv
#find -maxdepth 1 -path './*wiki' -type d -exec bash -c "bunzip2 -c '{}'/latest/*pages-articles.xml.bz2|grep -o \"\[http\" |wc -l " \; >> /home/ezachte/extlinks_wp.csv
#find -maxdepth 1 -path './*wiki' -type d -exec bash -c "zgrep -o \( '{}'/latest/*ext*sql.gz | wc -l " \; > /home/ezachte/extlinks_wp2.csv
find -maxdepth 1 -path './wikidatawiki' -type d -exec bash -c "zgrep -o \( '{}'/latest/*ext*sql.gz | wc -l " \; 
