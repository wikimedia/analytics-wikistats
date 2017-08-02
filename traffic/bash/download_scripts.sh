cd /home/ezachte/wikistats/traffic/wivivi/zips
rm datamaps.zip
wget stats.wikimedia.org/wikimedia/animations/pageviews/datamaps.zip 
DATE=$(date +"%Y_%m_%d_%H_%M")
mv datamaps.zip datamaps_$DATE.zip
