#!/bin/bash
ulimit -v 4000000

rsync -avr  /a/wikistats_git/squids/csv/*     --exclude=private stat1.wikimedia.org:/a/backup_stat1002/wikistats_git/squids/csv
rsync -avr  /a/wikistats_git/squids/reports/* --exclude=private stat1.wikimedia.org:/a/backup_stat1002/wikistats_git/squids/reports
rsync -avr  /a/wikistats_git/squids/bash/*                      stat1.wikimedia.org:/a/backup_stat1002/wikistats_git/squids/bash
rsync -avr  /a/wikistats_git/squids/perl/*                      stat1.wikimedia.org:/a/backup_stat1002/wikistats_git/squids/perl

