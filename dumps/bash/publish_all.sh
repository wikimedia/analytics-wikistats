#!/bin/sh

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
bash=$dumps/bash
bash=/home/ezachte/wikistats/dumps/bash # tests

cd $bash

./report.sh wb final
./report.sh wk final
./report.sh wn final
./report.sh wo final
# ./report.sh wp final
./report.sh wq final
./report.sh ws final
./report.sh wv final
./report.sh wx final
