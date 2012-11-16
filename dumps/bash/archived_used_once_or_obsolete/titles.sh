#!/bin/sh
clear
#force=-f
m=wp
p=afwiki
dumps=/mnt/data/xmldatadumps

perl WikiStatsCollectArticleNames.pl -p $p -i $dumps/public/$p -o /home/ezachte/wikistats/titles
