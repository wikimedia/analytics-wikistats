#!/bin/sh

cd /home/ezachte/wikistats/dumps/perl
# wget -O /home/ezachte/Staff_and_contractors.html http://wikimediafoundation.org/wiki/Staff_and_contractors

perl staff2opml.pl -i /home/ezachte/Staff_and_contractors.html -o /home/ezachte/Staff_and_contractor.opml
rsync -av /home/ezachte/Staff_and_contractor.opml thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/wikimedia
