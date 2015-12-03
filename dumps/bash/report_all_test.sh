#!/bin/sh

#wikistats=/a/wikistats_git
wikistats=/home/ezachte/wikistats
cd $wikistats/dumps/bash
# with 'final' means test run -> ../draft/..
# ./report.sh wp 
./report.sh wb
./report.sh wk
./report.sh wn
./report.sh wo
./report.sh wp
./report.sh wq
./report.sh ws
./report.sh wv
./report.sh wx
# ./report_regions.sh wp final
