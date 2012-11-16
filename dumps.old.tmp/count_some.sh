#!/bin/sh
ulimit -v 8000000
 
./sort_dblists.sh
./count_wb.sh
./count_wk.sh
./count_wn.sh
./count_wq.sh
./count_ws.sh
./count_wv.sh
./count_wx.sh
./count_wp.sh
