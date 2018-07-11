#!/bin/bash
# script migrated to stat1005

# publish wikistats dump_based reports, destination 'draft' sends report to ../draft/.. location for manual vetting

destination='draft'
if [ "$1" == 'final' ] 
then
  destination='final'
fi

echo destination:$destination

wikistats=$WIKISTATS_SCRIPTS
cd $wikistats/dumps/bash

./report.sh wb $destination
./report.sh wk $destination
./report.sh wn $destination
./report.sh wo $destination
./report.sh wq $destination
./report.sh ws $destination
./report.sh wv $destination
./report.sh wx $destination
./report.sh wp $destination
./report_regions.sh wp $destination

# zip and copy csv files and html output to folder /srv/dumps/wikistats_1
# that folder is rsynced hourly to http://dumps.wikimedia.org/other/wikistats_1
cd $wikistats/backup
./zip_all.sh
