#!/bin/bash
#set -x
USER=`whoami`;
export PATH=$PATH:$HOME/local/bin;
WIKISTATS_DIR=/a/wikistats_git
OUTPUT_DIR=/tmp/pageviews-full-cron
MOBILE_PAGEVIEWS_DIR=$WIKISTATS_DIR/pageviews_reports
# Clean up mappers output from previous run
rm -f $OUTPUT_DIR/map/*;
/usr/bin/env perl -I$MOBILE_PAGEVIEWS_DIR/lib \
                    $MOBILE_PAGEVIEWS_DIR/bin/pageviews.pl   \
                    $MOBILE_PAGEVIEWS_DIR/conf/stat1-full-cron.json 2>&1 >/tmp/cperlerr2;
cp $OUTPUT_DIR/PageViewsPerMonthAll.csv \
   $WIKISTATS_DIR/dumps/csv/csv_sp/ ;

