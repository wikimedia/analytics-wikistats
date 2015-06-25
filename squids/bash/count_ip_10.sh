#!/bin/bash
ulimit -v 40000000

wikistats="/a/wikistats_git"
bash="/home/ezachte/wikistats/squids/bash"

cd $bash

log=ip_10_ratio-new.txt
echo '' > $log
for yyyy in `seq 2013 2015`;
do
  for mm in `seq -f "%02g" 1 12`;
  do
  # file="/a/squid/archive/sampled/sampled-1000.tsv.log-${yyyy}${mm}01.gz"
    file="/a/log/webrequest/archive/sampled/sampled-1000.tsv.log-${yyyy}${mm}01.gz"
      echo $file  
    # echo $file >> $log 
      if [ -f $file ]; then
      # echo $file >> $log 
        zcat $file | cut -f 5 | cut -c 1-3 | grep -P "1\d\." | sort | uniq -c | sed "s/^ */${yyyy}-${mm},/" | sed 's/ /,/g' >> $log
      fi
  done
done
