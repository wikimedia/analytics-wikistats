#!/bin/bash 

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $wikistats/dumps/perl

perl WikiReportD3Participation.pl

cd $wikistats_data/dumps/html

 ls -l

# rsync -av d3_participation_w*.txt $htdocs/wikimedia/participation
# rsync -av d3_participation_w*.csv $htdocs/wikimedia/participation

mv d3_participation_wp.js d3_participation_wp9.js
rsync -av d3_participation_wp9.js $htdocs/wikimedia/participation

