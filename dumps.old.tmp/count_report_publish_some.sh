#!/bin/sh
ulimit -v 8000000
 
while [ 1 = 1 ]
do 	

echo "\n\n======================================\n" >> WikiCountsLogConcise.txt
echo Job resumed at $(date +"%d/%m/%y %H:%M") UTC >> WikiCountsLogConcise.txt

./sort_dblists.sh

./count_wb.sh
./report_en.sh wb

./count_wk.sh
./report_en.sh wk

./count_wn.sh
./report_en.sh wn

./count_wq.sh
./report_en.sh wq

./count_ws.sh
./report_en.sh ws

./count_wv.sh
./report_en.sh wv

./count_wx.sh
./report_en.sh wx

echo "\n\n" >> WikiCountsLogConcise.txt
echo Job suspended for 24 hours at $(date +"%d/%m/%y %H:%M") UTC >> WikiCountsLogConcise.txt

sleep 24h
done 
