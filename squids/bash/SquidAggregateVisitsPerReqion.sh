#! /bin/bash

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
perl=/home/ezachte/wikistats/squids/perl/ # temp

meta=$csv_sampled/meta # for bots views and edits use these 'meta' files (lookup for country/region codes)

cd $perl 
perl SquidCountryAggregate.pl 


