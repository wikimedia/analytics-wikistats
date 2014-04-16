#!/bin/bash

#COUNT_PERIOD="2012/08/01-2012/08/31"
COUNT_PERIOD="2012/08/01-2012/08/01"
REPORT_PERIOD="2012-08"

#################################
# CLEANUP
#################################

cd     csv_basic; ls | grep -v blank | xargs rm -rf; cd ..;
cd    logs_basic; ls | grep -v blank | xargs rm -rf; cd ..;
cd reports_basic; ls | grep -v blank | xargs rm -rf; cd ..;
cd     csv_basic; ln -s ../csv/meta ; cd ..;

#################################
# RUNNING SquidCountArchive
#################################


perl -Iperl/ perl/SquidCountArchive.pl        \
     -r conf-basic/SquidCountArchiveConfig.pm \
     -d $COUNT_PERIOD                         \
     -p 2>&1 > basic-count.log;

#################################
# RUNNING SquidReportArchive
#################################

perl -Iperl perl/SquidReportArchive.pl         \
     -r conf-basic/SquidReportArchiveConfig.pm \
     -m $REPORT_PERIOD                         \
     -p 2>&1 > basic-report.log;

