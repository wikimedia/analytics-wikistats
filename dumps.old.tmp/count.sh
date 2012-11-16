#!/bin/sh
clear
force=-f
dumps=/mnt/dumps/xmldatadumps

perl WikiCounts.pl $force -m $1 -i $dumps/public/$2 -o /a/wikistats/csv_$1/ -l $2 -d auto -s /mnt/php/languages 
