#!/bin/sh
ulimit -v 8000000
 
./sort_dblists.sh
./count.sh wb
./count.sh wk
./count.sh wn
./count.sh wq
./count.sh ws
./count.sh wv
./count.sh wx
./count.sh wp
