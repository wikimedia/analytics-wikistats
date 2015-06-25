#!/bin/bash
ulimit -v 20000

echo legacy script, used mostly for copying data to development env (paths are obsoloete) 
exit

cd /a/ezachte 
#target=/mnt/data/xmldatadumps/public/other/pagecounts-ez/squids
target=/mnt/htdocs/reportcard/staff/squids
yyyymm=2012-03
#tar --exclude='SquidDataBinaries.*' -cvf - $yyyymm/*/public/*.csv|bzip2 > csv.bz2
tar --exclude='SquidDataBinaries.*' --exclude='SquidDataBanners.*' -cvf - $yyyymm/*/public/*.csv|bzip2 > $target/squids-public-$yyyymm.csv.bz2
