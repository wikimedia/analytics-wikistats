#!/bin/sh

htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

echo "Publish Wikipedias Per Region"
rsync -av /a/out/out_wp/EN_* $htdocs 
  

