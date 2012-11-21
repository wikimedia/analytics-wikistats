#!/bin/sh

wikistats=/a/wikistats_git
cd $wikistats/dumps/bash

./report_regions.sh wp
# ./report.sh wp
./report.sh wb
./report.sh wk
./report.sh wn
./report.sh wq
./report.sh ws
./report.sh wv
./report.sh wx
