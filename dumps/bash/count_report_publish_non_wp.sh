#!/bin/sh

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
bash=$dumps/bash
log=$dumps/logs/log_count_report_publish_non_wp.txt

cd $bash

while [ 1 = 1 ]
do
ls -l
echo "\n\n======================================\n" >> $log
echo Job resumed at $(date +"%d/%m/%y %H:%M") UTC >> $log

./count.sh wb        | tee -a $log | cat
./report.sh wb 10 | tee -a $log | cat

./count.sh wk        | tee -a $log | cat
./report.sh wk 10 | tee -a $log | cat

./count.sh wn        | tee -a $log | cat
./report.sh wn 10 | tee -a $log | cat

./count.sh wq        | tee -a $log | cat
./report.sh wq 10 | tee -a $log | cat

./count.sh ws        | tee -a $log | cat
./report.sh ws 10 | tee -a $log | cat

./count.sh wv        | tee -a $log | cat
./report.sh wv 10 | tee -a $log | cat

./count.sh wx        | tee -a $log | cat
./report.sh wx 10 | tee -a $log | cat

echo "\n\n" >> $log
echo Job suspended for 24 hours at $(date +"%d/%m/%y %H:%M") UTC >> $log

sleep 24h
done

