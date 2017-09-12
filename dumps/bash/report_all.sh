#!/bin/bash

destination="draft"
if [ "$1" == "final" ] 
then
  destination='final'
fi

echo destination:$destination

#wikistats=/a/wikistats_git
wikistats=/home/ezachte/wikistats
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
