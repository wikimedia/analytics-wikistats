#!/bin/sh
ulimit -v 8000000
 
while [ 1 = 1 ]
do 	

echo "\n\n======================================\n" >> WikiCountsLogConcise.txt
echo Job resumed at $(date +"%d/%m/%y %H:%M") UTC >> WikiCountsLogConcise.txt

./sort_dblists.sh

./count_wb.sh
./report_en.sh wb 10
#./publish.sh   wb en 10

./count_wk.sh
./report_en.sh wk 10
#./publish.sh   wk en 10

./count_wn.sh
./report_en.sh wn 10
#./publish.sh   wn en 10

./count_wq.sh
./report_en.sh wq 10
#./publish.sh   wq en 10

./count_ws.sh
./report_en.sh ws 10
#./publish.sh   ws en 10

./count_wv.sh
./report_en.sh wv 10
#./publish.sh   wv en 10

./count_wx.sh
./report_en.sh wx 10
#./publish.sh   wx en 10

./count_wp.sh
./report_en.sh wp 10 
#./publish.sh   wp en 10 

echo "\n\n" >> WikiCountsLogConcise.txt
echo Job suspended for 8 hours at $(date +"%d/%m/%y %H:%M") UTC >> WikiCountsLogConcise.txt

sleep 8h
done 
