#!/bin/sh

htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

echo "Publish Wikipedias Per Region"
rsync -av /a/out/out_wp/EN_* $htdocs 
  

