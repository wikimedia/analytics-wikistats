#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

ulimit -v 8000000
clear

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
bash=$dumps/bash

$log=$dumps/logs/WikiCountsLogConcise.txt
cd $bash
 
while [ 1 = 1 ]
do 	

echo "\n\n======================================\n" >> $log
echo Job resumed at $(date +"%d/%m/%y %H:%M") UTC >> $log

# Sep 2011: step publish.sh obsolete, rsync now done in report.sh 

./sort_dblists.sh

#./count.sh     wp
#./report_en.sh wp 10 
## ./publish.sh wp en 10 

#./count.sh wb
#./report_en.sh wb 10
## ./publish.sh wb en 10

#./count.sh wk
#./report_en.sh wk 10
## ./publish.sh wk en 10

#./count.sh wn
#./report_en.sh wn 10
## ./publish.sh wn en 10

#./count.sh wq
#./report_en.sh wq 10
## ./publish.sh wq en 10

#./count.sh ws
#./report_en.sh ws 10
## ./publish.sh ws en 10

./count.sh wv
#./report_en.sh wv 10
# ./publish.sh  wv en 10

#./count.sh wx
#./report_en.sh wx 10
## ./publish.sh wx en 10

#./merge_editors.sh
#./report_en.sh wp 10 

#./report_regions.sh

echo "\n\n" >> $log
echo Job suspended for 8 hours at $(date +"%d/%m/%y %H:%M") UTC >> $log

sleep 8h
done 
