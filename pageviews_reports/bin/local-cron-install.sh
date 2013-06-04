#!/bin/bash
# Since logs are written to disk on stat1's time at around 06:30
# we place this job at 07:20 to be sure the needed files are in place
USER=`whoami`
CRON_SCRIPT=/a/wikistats_git/pageviews_reports/bin/local-cron-script.sh
crontab  -l | { cat; echo  "22 * * * * $USER . /home/$USER/.bashrc; /bin/bash $CRON_SCRIPT"; } | crontab -
