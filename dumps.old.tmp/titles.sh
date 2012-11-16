#!/bin/sh
clear
#force=-f
m=wp
p=afwiki
dumps=/mnt/dumps/xmldatadumps

perl WikiStatsCollectArticleNames.pl -p $p -i $dumps/public/$p -o /home/ezachte/wikistats/titles
