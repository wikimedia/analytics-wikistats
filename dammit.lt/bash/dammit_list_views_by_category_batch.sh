#!/bin/bash
ulimit -v 2000000

# collect newewest projectcounts files (hourly page view stats per wiki), add to tar, and publish

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt

yyyy_mm=2013-01
threshold=20
depth=9

#                                  wiki               category                          yyyy_mm    threshold      abbr    depth        
#./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Museum'                          $yyyy_mm   $threshold     'wp:nl' $depth
#./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Nederlands_politicus'            $yyyy_mm   $threshold     'wp:nl' $depth
#./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Politicus'                       $yyyy_mm   $threshold     'wp:nl' $depth
#./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Schilderkunst_van_de_20e_eeuw'   $yyyy_mm   $threshold     'wp:nl' $depth
#./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museum'                          $yyyy_mm   $threshold     'wp:en' $depth
#./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Painters_by_nationality'         $yyyy_mm   $threshold     'wp:en' $depth
./dammit_list_views_by_category.sh 'en.wikipedia.org' 'English_painters'                $yyyy_mm   $threshold     'wp:en' $depth
#./dammit_list_views_by_category.sh 'en.wikipedia.org' 'French_painters'                 $yyyy_mm   $threshold     'wp:en' $depth
#./dammit_list_views_by_category.sh 'en.wikipedia.org' 'German_painters'                 $yyyy_mm   $threshold     'wp:en' $depth
#./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Italian_painters'                $yyyy_mm   $threshold     'wp:en' $depth
#./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Politiker_\(Deutschland\)'      $yyyy_mm   $threshold     'wp:de' $depth
