#!/bin/bash

wikistats=/a/wikistats_git
cd $wikistats/dumps/bash

./zip_csv.sh wb
./zip_csv.sh wk
./zip_csv.sh wn
./zip_csv.sh wo
./zip_csv.sh wp
./zip_csv.sh wq
./zip_csv.sh ws
./zip_csv.sh wv
./zip_csv.sh wx

./zip_out.sh wb
./zip_out.sh wk
./zip_out.sh wm
./zip_out.sh wn
./zip_out.sh wo
./zip_out.sh wp
./zip_out.sh wq
./zip_out.sh ws
./zip_out.sh wv
./zip_out.sh wx

