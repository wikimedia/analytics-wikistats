#!/bin/sh

cd /a/wikistats/
rm zip_all/csv_$1.zip
rm zip_all/bz2_$1.zip
cd csv_$1
rm csv*.zip
zip csv_$1.zip *.csv
zip bz2_$1.zip *.bz2
cp csv_$1.zip ../zip_all
cp bz2_$1.zip ../zip_all
cd .. 
