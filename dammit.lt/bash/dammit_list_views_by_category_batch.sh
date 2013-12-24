#!/bin/bash
ulimit -v 2000000

# collect newewest projectcounts files (hourly page view stats per wiki), add to tar, and publish

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt

yyyy_mm=2013-10
threshold=20
depth=9

# url encode: http://meyerweb.com/eric/tools/dencoder/

#                                   wiki               category                           yyyy_mm    threshold      abbr    depth        
#./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Arzneistoff'                      2013-01     20             'wp-de' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Determinants_of_health'           2013-07     20             'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Health'                           2013-07     20             'wp-en' $depth
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Arzneistoff'                      $yyyy_mm    20             'wp-de' $depth

 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Africa'                           $yyyy_mm    20             'wp-en' $depth
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Afrique'                          $yyyy_mm    20             'wp-fr' $depth
 ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Africa'                           $yyyy_mm    20             'wp-it' $depth
 ./dammit_list_views_by_category.sh 'sw.wikipedia.org' 'Afrika'                           $yyyy_mm    20             'wp-sw' $depth
 ./dammit_list_views_by_category.sh 'af.wikipedia.org' 'Afrika'                           $yyyy_mm    20             'wp-af' $depth

 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Terrorist_incidents_in_the_United_States_by_year' $yyyy_mm    20   'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Terrorism' $yyyy_mm    20   'wp-en' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Nederlands_politicus'             $yyyy_mm    20             'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'da.wikipedia.org' 'Politikere_fra_Danmark'           $yyyy_mm    75             'wp-da' $depth 
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Politiker_(Deutschland)'          $yyyy_mm    75             'wp-de' $depth 
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'American_politicians'             $yyyy_mm    500            'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'British_politicians'              $yyyy_mm    75             'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Indian_politicians'               $yyyy_mm    50             'wp-en' $depth
 ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_España'              $yyyy_mm    50             'wp-es' $depth
 ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_México'              $yyyy_mm    50             'wp-es' $depth
 ./dammit_list_views_by_category.sh 'fi.wikipedia.org' 'Suomalaiset_poliitikot'           $yyyy_mm    50             'wp-fi' $depth
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Personnalité_politique_française' $yyyy_mm    50             'wp-fr' $depth
 ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Politikus_Indonesia'              $yyyy_mm    50             'wp-id' $depth
 ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Politici_italiani'                $yyyy_mm    50             'wp-it' $depth
#./dammit_list_views_by_category.sh 'ja.wikipedia.org' '%E6%97%A5%E6%9C%AC%E3%81%AE%E6%94%BF%E6%B2%BB%E5%AE%B6' $yyyy_mm 50  'wp-ja' $depth
 ./dammit_list_views_by_category.sh 'nn.wikipedia.org' 'Norske_politikarar'               $yyyy_mm    75             'wp-nn' $depth 
 ./dammit_list_views_by_category.sh 'no.wikipedia.org' 'Norske_politikere'                $yyyy_mm    75             'wp-no' $depth 
 ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Polscy_politycy'                  $yyyy_mm    50             'wp-pl' $depth
 ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_de_Portugal'            $yyyy_mm    50             'wp-pt' $depth
 ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_do_Brasil'              $yyyy_mm    50             'wp-pt' $depth
 ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Svenska_politiker'                $yyyy_mm    50             'wp-sv' $depth
#./dammit_list_views_by_category.sh 'ru.wikipedia.org' '%D0%9F%D0%BE%D0%BB%D0%B8%D1%82%D0%B8%D0%BA%D0%B8_%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B8'                $yyyy_mm   50             'wp-ru' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuurkunde'                      $yyyy_mm   $threshold     'wp-nl' 4
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Politicus'                        $yyyy_mm   $threshold     'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Schilderkunst_van_de_20e_eeuw'    $yyyy_mm   $threshold     'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Painters_by_nationality'          $yyyy_mm   $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'English_painters'                 $yyyy_mm   $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'French_painters'                  $yyyy_mm   $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'German_painters'                  $yyyy_mm   $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Italian_painters'                 $yyyy_mm   $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Wikipedia_GLAM'                   $yyyy_mm    $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'wikimediafoundation.org' 'English'                   $yyyy_mm    $threshold     'wm-wmf' $depth
#./dammit_list_views_by_category.sh 'commons.wikimedia.org' 'Commons'                     $yyyy_mm    $threshold     'wm-commons' $depth
 ./dammit_list_views_by_category.sh 'www.wikidata.org' 'Wikidata'                         $yyyy_mm    $threshold     'wm-wikidata' $depth
 ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'GLAM'                           $yyyy_mm    $threshold     'wm-meta' $depth
 ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'Meta-Wiki'                      $yyyy_mm    $threshold     'wm-meta' $depth
 ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'GLAM'                       $yyyy_mm    $threshold     'wm-outreach' $depth
 ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Bookshelf_Project'          $yyyy_mm    $threshold     'wm-outreach' $depth
 ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Education'                  $yyyy_mm    $threshold     'wm-outreach' $depth
 ./dammit_list_views_by_category.sh 'da.wikipedia.org' 'Museer_i_Danmark'                 $yyyy_mm    $threshold     'wp-da' $depth
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Museum_in_Deutschland'            $yyyy_mm    $threshold     'wp-de' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_Australia'             $yyyy_mm    $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_Kingdom'    $yyyy_mm    $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_States'     $yyyy_mm    $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_India'                 $yyyy_mm    $threshold     'wp-en' $depth
 ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_España'                 $yyyy_mm    $threshold     'wp-es' $depth
 ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_México'                 $yyyy_mm    $threshold     'wp-es' $depth
 ./dammit_list_views_by_category.sh 'fi.wikipedia.org' 'Suomen_museot'                    $yyyy_mm    $threshold     'wp-fi' $depth
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Musée_en_France'                  $yyyy_mm    $threshold     'wp-fr' $depth
 ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Museum_di_Indonesia'              $yyyy_mm    $threshold     'wp-id' $depth
 ./dammit_list_views_by_category.sh 'it.wikipedia.org' "Musei_d'Italia"                   $yyyy_mm    $threshold     'wp-it' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Museum_in_België'                 $yyyy_mm    $threshold     'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Museum_in_Nederland'              $yyyy_mm    $threshold     'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Culturele_organisatie'            $yyyy_mm    $threshold     'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'nn.wikipedia.org' 'Museum_i_Noreg'                   $yyyy_mm    $threshold     'wp-nn' $depth
 ./dammit_list_views_by_category.sh 'no.wikipedia.org' 'Museer_i_Norge'                   $yyyy_mm    $threshold     'wp-no' $depth
 ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Muzea_w_Polsce'                   $yyyy_mm    $threshold     'wp-pl' $depth
 ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Brasil'                 $yyyy_mm    $threshold     'wp-pt' $depth
 ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Portugal'               $yyyy_mm    $threshold     'wp-pt' $depth
 ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Museer_i_Sverige'                 $yyyy_mm    $threshold     'wp-sv' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Cultuur'                          $yyyy_mm   $threshold      'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Geschiedenis'                     $yyyy_mm   $threshold      'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Heelal'                           $yyyy_mm   $threshold      'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Lijsten'                          $yyyy_mm   $threshold      'wp-nl' $depth 
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Lists'                            $yyyy_mm   $threshold      'wp-en' $depth 
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Liste'                            $yyyy_mm   $threshold      'wp-de' $depth 
 ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Liste'                            $yyyy_mm   $threshold      'wp-fr' $depth 
 ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Liste'                            $yyyy_mm   $threshold      'wp-it' $depth 
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Mens_en_maatschappij'             $yyyy_mm   $threshold      'wp-nl' $depth 
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuur'                           $yyyy_mm   $threshold      'wp-nl' $depth 
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Persoon'                          $yyyy_mm   $threshold      'wp-nl' $depth 
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Techniek'                         $yyyy_mm   $threshold      'wp-nl' $depth 
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Wetenschap'                       $yyyy_mm   $threshold      'wp-nl' $depth 
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Leiden'                           $yyyy_mm   $threshold      'wp-en' $depth
 ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Leiden_(Stadt)'                   $yyyy_mm   $threshold      'wp-de' $depth
 ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Leiden'                           $yyyy_mm   $threshold      'wp-nl' $depth
 ./dammit_list_views_by_category.sh 'commons.wikipedia.org' 'Leiden'                      $yyyy_mm   $threshold      'wm-commons' $depth

