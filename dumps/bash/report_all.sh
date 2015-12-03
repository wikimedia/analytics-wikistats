#!/bin/sh

#wikistats=/a/wikistats_git
wikistats=/home/ezachte/wikistats
cd $wikistats/dumps/bash

./report.sh wb final
./report.sh wk final
./report.sh wn final
./report.sh wo final
./report.sh wq final
./report.sh ws final
./report.sh wv final
./report.sh wx final
./report.sh wp final
./report_regions.sh wp final
