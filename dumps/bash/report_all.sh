#!/bin/sh

wikistats=/a/wikistats_git
cd $wikistats/dumps/bash

./report.sh wx final
./report.sh wb final
./report.sh wk final
./report.sh wn final
./report.sh wq final
./report.sh ws final
./report.sh wv final
./report_regions.sh wp final
./report.sh wp final
