#!/bin/bash
ulimit -v 2000000

# to be run monthly

# each line produces two reports in http://stats.wikimedia.org/wikimedia/pageviews/categorized/
# - a subtree of the category scheme for  certain wiki, starting from a specified top category
#   e.g. http://stats.wikimedia.org/wikimedia/pageviews/categorized/wp-en/2014-05/categories_wp-en_cat_Lists_2014-05.html
# - a list of all pages belonging to that subtree, and their monthly page views 
#   e.g. http://stats.wikimedia.org/wikimedia/pageviews/categorized/wp-en/2014-05/pageviews_wp-en_cat_Lists_2014-05.html

# see also: http://stats.wikimedia.org/cgi-bin/search_portal.pl?search=page+views+category+hierarchy

# arguments:
# - target wiki
# - top category (use underscores for spaces)
# - yyyy_mm: month to be reported
# - threshold: only list pages with at least this number of page views
# - top folder: : reports will appear under http://stats.wikimedia.org/wikimedia/pageviews/categorized/[yyyy_mm] 
# - depth: to follow subcategories up to this depth 

# prune category tree as follows: add lines to file exclude.csv, in order to not include certain subcategories, 
# in order to speed up pruning start by collecting only small subtree (e.g. depth 5), prune and rerun with more depth
# see also: dammit_list_views_by_category_blacklist.sh 

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt

yyyy_mm=2015-01
threshold=20
depth=12

# ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                $yyyy_mm    $threshold     'wp-de' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     $yyyy_mm    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          $yyyy_mm    $threshold     'wp-fr' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              $yyyy_mm    $threshold     'wp-nl' $depth

# exit

 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-01'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-02'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-03'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-04'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-05'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-06'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-07'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-08'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-09'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-10'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-11'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2012-12'   20             'wp-en' 12

 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-01'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-02'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-03'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-04'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-05'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-06'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-07'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-08'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-09'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-10'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-11'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2013-12'   20             'wp-en' 12

 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-01'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-02'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-03'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-04'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-05'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-06'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-07'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-08'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-09'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-10'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-11'   20             'wp-en' 12
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'World_War_II'                     '2014-12'   20             'wp-en' 12
 

 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-01'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-02'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-03'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-04'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-05'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-06'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-07'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-08'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-09'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-10'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-11'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2012-12'   20             'wp-nl' 12

 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-01'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-02'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-03'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-04'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-05'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-06'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-07'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-08'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-09'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-10'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-11'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2013-12'   20             'wp-nl' 12

 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-01'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-02'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-03'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-04'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-05'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-06'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-07'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-08'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-09'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-10'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-11'   20             'wp-nl' 12
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Tweede_Wereldoorlog'              '2014-12'   20             'wp-nl' 12

exit

 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-01'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-02'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-03'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-04'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-05'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-06'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-07'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-08'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-09'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-10'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-11'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2012-12'   20             'wp-de' 12

 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-01'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-02'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-03'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-04'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-05'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-06'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-07'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-08'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-09'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-10'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-11'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2013-12'   20             'wp-de' 12

 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-01'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-02'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-03'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-04'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-05'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-06'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-07'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-08'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-09'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-10'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-11'   20             'wp-de' 12
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Zweiter_Weltkrieg'                '2014-12'   20             'wp-de' 12

exit

 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-01'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-02'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-03'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-04'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-05'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-06'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-07'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-08'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-09'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-10'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-11'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2012-12'   20             'wp-fr' 12

 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-01'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-02'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-03'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-04'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-05'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-06'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-07'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-08'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-09'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-10'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-11'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2013-12'   20             'wp-fr' 12

 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-01'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-02'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-03'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-04'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-05'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-06'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-07'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-08'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-09'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-10'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-11'   20             'wp-fr' 12
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Seconde_Guerre_mondiale'          '2014-12'   20             'wp-fr' 12

