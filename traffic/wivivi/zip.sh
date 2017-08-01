#! /bin/bash
DATE=$(date +"%Y_%m_%d_%H_%M")
echo $DATE
zip datamaps.zip * -x *zip
cp datamaps.zip /srv/stats.wikimedia.org/htdocs/wikimedia/animations/pageviews/zips/datamaps_$DATE.zip

