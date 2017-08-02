#! /bin/bash
ulimit -v 1000000

zips=/home/ezachte/wikistats/image_sets/zips/
#data=/mnt/hdfs/wmf/data/archive/image_sets/contest_winners/WLM
#data=/mnt/data/xmldatadumps/public/other/image_sets/contest_winners/WLM 
#data=/mnt/data/xmldatadumps/public/other/media/contest_winners/WLM
dataset1001=dataset1001.wikimedia.org::media/contest_winners/WLM
cd $zips/WLM
echo "rsync -ipv4 -avv *.zip  $dataset1001"
      rsync -ipv4 -avv *.zip  $dataset1001
