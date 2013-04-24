#!/bin/bash
crontab  -l | { cat; echo  "31 6 24 * * user . /home/user/.bashrc; /bin/bash /home/user/wikistats/wikistats/pageviews_reports/cron-script.sh"; } | crontab -
