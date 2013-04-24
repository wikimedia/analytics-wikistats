#!/bin/bash
# Since logs are written to disk on stat1's time at around 06:30
# we place this job at 07:20 to be sure the needed files are in place
crontab  -l | { cat; echo  "20 7 01 * * user . /home/user/.bashrc; /bin/bash /home/user/wikistats/wikistats/pageviews_reports/cron-script.sh"; } | crontab -
