#!/bin/sh
echo not migrated yet to new server -> abort
exit

ulimit -v 8000000

wikistats=/a/wikistats_git
log=$wikistats/dumps/logs/log_count_report_publish_concise_wp.txt

while [ 1 = 1 ]
do 	

echo "\n\n======================================\n" >> $log
echo Job resumed at $(date +"%d/%m/%y %H:%M") UTC >> $log

./sort_dblists.sh

echo Job step 'count.sh' >> $log
./count.sh wp
echo Job step 'merge_editors.sh' >> $log
./merge_editors.sh
echo Job step 'report.sh' >> $log
./report.sh wp 10 
echo Job step 'report_regions.sh' >> $log
./report_regions.sh

# ./publish.sh wp en 10  # step publish.sh obsolete, rsync now done in report.sh (keep one instance for reference)

echo "\n\n" >> $log
echo Job suspended for 24 hours at $(date +"%d/%m/%y %H:%M") UTC >> $log

sleep 24

done

