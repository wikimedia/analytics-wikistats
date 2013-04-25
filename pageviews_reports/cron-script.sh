#!/bin/bash
#env
#set -x
USER=`whoami`;
#echo $USER >> /tmp/cronlog_1
eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib);
export PATH=$PATH:$HOME/local/bin;
#unpigz --help 2>> /tmp/cronlog_1
#env > $HOME/cronenv;
WIKISTATS_DIR=/a/wikistats_git
MOBILE_PAGEVIEWS_DIR=$WIKISTATS_DIR/pageviews_reports;
/usr/bin/env perl -V  > /tmp/cperlver;
/bin/date            >> /tmp/cperlver;
/usr/bin/env perl -I$MOBILE_PAGEVIEWS_DIR/lib            \
                    $MOBILE_PAGEVIEWS_DIR/pageviews.pl   \
                    $MOBILE_PAGEVIEWS_DIR/conf/stat1-full-cron.json 2>&1 >/tmp/cperlerr;
cp /tmp/pageviews-full-cron/PageViewsPerMonthAll.csv \
   $WIKISTATS_DIR/dumps/csv/csv_sp/ ;
