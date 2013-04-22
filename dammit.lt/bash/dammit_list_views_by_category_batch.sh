#!/bin/bash
ulimit -v 2000000

# collect newewest projectcounts files (hourly page view stats per wiki), add to tar, and publish

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt

yyyy_mm=2013-03
threshold=20
depth=9

# url encode: http://meyerweb.com/eric/tools/dencoder/

#                                   wiki               category                           yyyy_mm    threshold      abbr    depth        

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Terrorist_incidents_in_the_United_States_by_year' 2013-03    20   'wp-en' $depth
 ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Terrorism' 2013-03    20   'wp-en' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Nederlands_politicus'             2013-01    20             'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Nederlands_politicus'             2013-02    20             'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Nederlands_politicus'             2013-03    20             'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Politiker_(Deutschland)'          2013-01    75             'wp-de' $depth 
# ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Politiker_(Deutschland)'          2013-02    75             'wp-de' $depth 
# ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Politiker_(Deutschland)'          2013-03    75             'wp-de' $depth 

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'American_politicians'             2013-01    500            'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'American_politicians'             2013-02    500            'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'American_politicians'             2013-03    500            'wp-en' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'British_politicians'              2013-01    75             'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'British_politicians'              2013-02    75             'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'British_politicians'              2013-03    75             'wp-en' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Indian_politicians'               2013-01    50             'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Indian_politicians'               2013-02    50             'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Indian_politicians'               2013-03    50             'wp-en' $depth

# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_España'              2013-01    50             'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_España'              2013-02    50             'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_España'              2013-03    50             'wp-es' $depth

# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_México'              2013-01    50             'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_México'              2013-02    50             'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Políticos_de_México'              2013-03    50             'wp-es' $depth

# ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Personnalité_politique_française' 2013-01   50             'wp-fr' $depth
# ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Personnalité_politique_française' 2013-02   50             'wp-fr' $depth
# ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Personnalité_politique_française' 2013-03    50             'wp-fr' $depth

# ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Politikus_Indonesia'              2013-01    50             'wp-id' $depth
# ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Politikus_Indonesia'              2013-02    50             'wp-id' $depth
# ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Politikus_Indonesia'              2013-03    50             'wp-id' $depth

# ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Politici_italiani'                2013-01    50             'wp-it' $depth
# ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Politici_italiani'                2013-02    50             'wp-it' $depth
# ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Politici_italiani'                2013-03    50             'wp-it' $depth

# ./dammit_list_views_by_category.sh 'ja.wikipedia.org' '%E6%97%A5%E6%9C%AC%E3%81%AE%E6%94%BF%E6%B2%BB%E5%AE%B6' 2013-01 50  'wp-ja' $depth
# ./dammit_list_views_by_category.sh 'ja.wikipedia.org' '%E6%97%A5%E6%9C%AC%E3%81%AE%E6%94%BF%E6%B2%BB%E5%AE%B6' 2013-02 50  'wp-ja' $depth
# ./dammit_list_views_by_category.sh 'ja.wikipedia.org' '%E6%97%A5%E6%9C%AC%E3%81%AE%E6%94%BF%E6%B2%BB%E5%AE%B6' 2013-03 50  'wp-ja' $depth

# ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Polscy_politycy'                  2013-01    50             'wp-pl' $depth
# ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Polscy_politycy'                  2013-02    50             'wp-pl' $depth
# ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Polscy_politycy'                  2013-03    50             'wp-pl' $depth

# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_de_Portugal'            2013-01    50             'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_de_Portugal'            2013-02    50             'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_de_Portugal'            2013-03    50             'wp-pt' $depth

# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_do_Brasil'              2013-01    50             'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_do_Brasil'              2013-02    50             'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Políticos_do_Brasil'              2013-03    50             'wp-pt' $depth

# ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Svenska_politiker'                2013-01    50             'wp-sv' $depth
# ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Svenska_politiker'                2013-02    50             'wp-sv' $depth
# ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Svenska_politiker'                2013-03    50             'wp-sv' $depth

# ./dammit_list_views_by_category.sh 'ru.wikipedia.org' '%D0%9F%D0%BE%D0%BB%D0%B8%D1%82%D0%B8%D0%BA%D0%B8_%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B8'                2013-01   50             'wp-ru' $depth
# ./dammit_list_views_by_category.sh 'ru.wikipedia.org' '%D0%9F%D0%BE%D0%BB%D0%B8%D1%82%D0%B8%D0%BA%D0%B8_%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B8'                2013-02   50             'wp-ru' $depth
# ./dammit_list_views_by_category.sh 'ru.wikipedia.org' '%D0%9F%D0%BE%D0%BB%D0%B8%D1%82%D0%B8%D0%BA%D0%B8_%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B8'                2013-03   50             'wp-ru' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuurkunde'                      2013-01   $threshold     'wp-nl' 4
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuurkunde'                      2013-02   $threshold     'wp-nl' 4
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuurkunde'                      2013-03   $threshold     'wp-nl' 4

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Museum'                           $yyyy_mm   $threshold     'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Politicus'                        $yyyy_mm   $threshold     'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Schilderkunst_van_de_20e_eeuw'    $yyyy_mm   $threshold     'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museum'                           $yyyy_mm   $threshold     'wp-en' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Painters_by_nationality'          $yyyy_mm   $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'English_painters'                 $yyyy_mm   $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'French_painters'                  $yyyy_mm   $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'German_painters'                  $yyyy_mm   $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Italian_painters'                 $yyyy_mm   $threshold     'wp-en' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Wikipedia_GLAM'                   2013-01    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Wikipedia_GLAM'                   2013-02    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Wikipedia_GLAM'                   2013-03    $threshold     'wp-en' $depth

# ./dammit_list_views_by_category.sh 'wikimediafoundation.org' 'English'                   2013-01    $threshold     'wm-wmf' $depth
# ./dammit_list_views_by_category.sh 'wikimediafoundation.org' 'English'                   2013-02    $threshold     'wm-wmf' $depth
# ./dammit_list_views_by_category.sh 'wikimediafoundation.org' 'English'                   2013-03    $threshold     'wm-wmf' $depth

# ./dammit_list_views_by_category.sh 'commons.wikimedia.org' 'Commons'                     2013-01    $threshold     'wm-commons' $depth
# ./dammit_list_views_by_category.sh 'commons.wikimedia.org' 'Commons'                     2013-02    $threshold     'wm-commons' $depth
# ./dammit_list_views_by_category.sh 'commons.wikimedia.org' 'Commons'                     2013-03    $threshold     'wm-commons' $depth

# ./dammit_list_views_by_category.sh 'www.wikidata.org' 'Wikidata'                         2013-01    $threshold     'wm-wikidata' $depth
# ./dammit_list_views_by_category.sh 'www.wikidata.org' 'Wikidata'                         2013-02    $threshold     'wm-wikidata' $depth
# ./dammit_list_views_by_category.sh 'www.wikidata.org' 'Wikidata'                         2013-03    $threshold     'wm-wikidata' $depth

# ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'GLAM'                           2013-01    $threshold     'wm-meta' $depth
# ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'GLAM'                           2013-02    $threshold     'wm-meta' $depth
# ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'GLAM'                           2013-03    $threshold     'wm-meta' $depth

# ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'Meta-Wiki'                      2013-01    $threshold     'wm-meta' $depth
# ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'Meta-Wiki'                      2013-02    $threshold     'wm-meta' $depth
# ./dammit_list_views_by_category.sh 'meta.wikimedia.org' 'Meta-Wiki'                      2013-03    $threshold     'wm-meta' $depth

# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'GLAM'                       2013-01    $threshold     'wm-outreach' $depth
# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'GLAM'                       2013-02    $threshold     'wm-outreach' $depth
# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'GLAM'                       2013-03    $threshold     'wm-outreach' $depth

# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Bookshelf_Project'          2013-01    $threshold     'wm-outreach' $depth
# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Bookshelf_Project'          2013-02    $threshold     'wm-outreach' $depth
# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Bookshelf_Project'          2013-03    $threshold     'wm-outreach' $depth

# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Education'                  2013-01    $threshold     'wm-outreach' $depth
# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Education'                  2013-02    $threshold     'wm-outreach' $depth
# ./dammit_list_views_by_category.sh 'outreach.wikimedia.org' 'Education'                  2013-03    $threshold     'wm-outreach' $depth

# ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Museum_in_Deutschland'            2013-01    $threshold     'wp-de' $depth
# ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Museum_in_Deutschland'            2013-02    $threshold     'wp-de' $depth
# ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Museum_in_Deutschland'            2013-03    $threshold     'wp-de' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_Australia'             2013-01    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_Australia'             2013-02    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_Australia'             2013-03    $threshold     'wp-en' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_Kingdom'    2013-01    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_Kingdom'    2013-02    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_Kingdom'    2013-03    $threshold     'wp-en' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_States'     2013-01    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_States'     2013-02    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_the_United_States'     2013-03    $threshold     'wp-en' $depth

# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_India'                 2013-01    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_India'                 2013-02    $threshold     'wp-en' $depth
# ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Museums_in_India'                 2013-03    $threshold     'wp-en' $depth

# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_España'                 2013-01    $threshold     'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_España'                 2013-02    $threshold     'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_España'                 2013-03    $threshold     'wp-es' $depth
  
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_México'                 2013-01    $threshold     'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_México'                 2013-02    $threshold     'wp-es' $depth
# ./dammit_list_views_by_category.sh 'es.wikipedia.org' 'Museos_de_México'                 2013-03    $threshold     'wp-es' $depth
  
# ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Musée_en_France'                  2013-01    $threshold     'wp-fr' $depth
# ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Musée_en_France'                  2013-02    $threshold     'wp-fr' $depth
# ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Musée_en_France'                  2013-03    $threshold     'wp-fr' $depth
  
# ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Museum_di_Indonesia'              2013-01    $threshold     'wp-id' $depth
# ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Museum_di_Indonesia'              2013-02    $threshold     'wp-id' $depth
# ./dammit_list_views_by_category.sh 'id.wikipedia.org' 'Museum_di_Indonesia'              2013-03    $threshold     'wp-id' $depth

# ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Musei_d%27Italia'                 2013-01    $threshold     'wp-it' $depth
# ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Musei_d%27Italia'                 2013-02    $threshold     'wp-it' $depth
# ./dammit_list_views_by_category.sh 'it.wikipedia.org' 'Musei_d%27Italia'                 2013-03    $threshold     'wp-it' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Culturele_organisatie'            2013-01    $threshold     'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Culturele_organisatie'            2013-02    $threshold     'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Culturele_organisatie'            2013-03    $threshold     'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Muzea_w_Polsce'                   2013-01    $threshold     'wp-pl' $depth
# ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Muzea_w_Polsce'                   2013-02    $threshold     'wp-pl' $depth
# ./dammit_list_views_by_category.sh 'pl.wikipedia.org' 'Muzea_w_Polsce'                   2013-03    $threshold     'wp-pl' $depth

# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Brasil'                 2013-03    $threshold     'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Brasil'                 2013-03    $threshold     'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Brasil'                 2013-03    $threshold     'wp-pt' $depth

# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Portugal'               2013-01    $threshold     'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Portugal'               2013-02    $threshold     'wp-pt' $depth
# ./dammit_list_views_by_category.sh 'pt.wikipedia.org' 'Museus_de_Portugal'               2013-03    $threshold     'wp-pt' $depth

# ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Museer_i_Sverige'                 2013-01    $threshold     'wp-sv' $depth
# ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Museer_i_Sverige'                 2013-02    $threshold     'wp-sv' $depth
# ./dammit_list_views_by_category.sh 'sv.wikipedia.org' 'Museer_i_Sverige'                 2013-03    $threshold     'wp-sv' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Cultuur'                          2013-01   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Cultuur'                          2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Cultuur'                          2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Geschiedenis'                     2013-01   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Geschiedenis'                     2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Geschiedenis'                     2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Heelal'                           2013-01   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Heelal'                           2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Heelal'                           2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Lijsten'                          2013-01   $threshold      'wp-nl' $depth 
#  ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Lijsten'                          2013-02   $threshold      'wp-nl' $depth
#  ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Lijsten'                          2013-03   $threshold      'wp-nl' $depth

#  ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Lists'                            2013-01   $threshold      'wp-en' $depth 
#  ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Lists'                            2013-02   $threshold      'wp-en' $depth
#  ./dammit_list_views_by_category.sh 'en.wikipedia.org' 'Lists'                            2013-03   $threshold      'wp-en' $depth

#  ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Liste'                            2013-01   $threshold      'wp-de' $depth 
#  ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Liste'                            2013-02   $threshold      'wp-de' $depth
#  ./dammit_list_views_by_category.sh 'de.wikipedia.org' 'Liste'                            2013-03   $threshold      'wp-de' $depth

#  ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Liste'                            2013-01   $threshold      'wp-fr' $depth 
#  ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Liste'                            2013-02   $threshold      'wp-fr' $depth
#  ./dammit_list_views_by_category.sh 'fr.wikipedia.org' 'Liste'                            2013-03   $threshold      'wp-fr' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Mens_en_maatschappij'             2013-01   $threshold      'wp-nl' $depth 
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Mens_en_maatschappij'             2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Mens_en_maatschappij'             2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuur'                           2013-01   $threshold      'wp-nl' $depth 
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuur'                           2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Natuur'                           2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Persoon'                          2013-01   $threshold      'wp-nl' $depth 
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Persoon'                          2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Persoon'                          2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Techniek'                         2013-01   $threshold      'wp-nl' $depth 
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Techniek'                         2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Techniek'                         2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Wetenschap'                       2013-01   $threshold      'wp-nl' $depth 
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Wetenschap'                       2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Wetenschap'                       2013-03   $threshold      'wp-nl' $depth

# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Wikipedia'                        2013-01   $threshold      'wp-nl' $depth 
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Wikipedia'                        2013-02   $threshold      'wp-nl' $depth
# ./dammit_list_views_by_category.sh 'nl.wikipedia.org' 'Wikipedia'                        2013-03   $threshold      'wp-nl' $depth

