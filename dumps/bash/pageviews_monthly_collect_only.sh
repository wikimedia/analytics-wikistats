#!/bin/sh

root=/home/ezachte/wikistats
out=/a/out
report=/home/ezachte/wikistats/report.txt

echo "**************************" >> $report
echo "Start pageviews_monthly.sh" >> $report
echo "**************************" >> $report

cd $root
perl $root/WikiCountsSummarizeProjectCounts.pl -i /a/dammit.lt/projectcounts -o /a/wikistats #   >> $report


