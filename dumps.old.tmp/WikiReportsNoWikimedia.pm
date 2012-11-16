#!/usr/bin/perl

sub SettingsNoWikimedia
{
  &Log ("Apply settings for non WikiMedia environment.\n") ;

  $registration_enforced = $true ;
  $category_index        = $false ;

  $out_urls      {"nl"} = "https://www.railpedia.nl" ;
  $out_languages {"nl"} = "https://www.railpedia.nl" ;

  $out_urls      {"qo"} = "http://wiqopedia.klm.com" ;
  $out_languages {"qo"} = "http://wiqopedia.klm.com" ;

# WikiCities
# $base_nowikimedia     = "http://???.wikicities.com/wiki/" ; # this needs parametrisation ?
  $base_nowikimedia     = "https://www.railpedia.nl/index.php?title=" ;
  $base_nowikimedia     = "http://wiqopedia.klm.com/index.php?title=" ;
  $out_wikipage = "/index.php?title=" ;

# WikiCities
# $siteadmin   = "Wikicities site administrator " ;
# $mailaddress = "jasonr@bomis.com" ;
# $mailnotice  = "Jason Richey" ;
# $mail        = "<a href='mailto:$mailaddress' title='contact us'>$mailnotice</a>" ;

  $siteadmin   = "Railpedia site administrator " ;
  $mailaddress = "" ;
  $mailnotice  = "" ;
  $mail        = "" ; # do not show mail address

  $siteadmin   = "Wiqopedia site administrator " ;
  $mailaddress = "" ;
  $mailnotice  = "" ;
  $mail        = "" ; # do not show mail address

# parameters for PNG/SVG plots

# WikiCities
# $plot_start        = "11/01/2004" ; # mm/dd/yyyy
# $plot_legend_width = 2.0 ; # inches, test to determine best value
# Railpedia
  $plot_start        = "07/01/2006" ; # mm/dd/yyyy
  $plot_legend_width = 1.0 ; # inches, test to determine best value

  # determine presentation order of sites on comparison pages based on column..
  # if you change to another column, don't forget to edit $out_sort_order (see below)

  # most columns can yield misleading results (there is no perfects solution)
  # should a site with many low quality stub entries be sorted on top?
  # should a site with lots of edits one year ago, but few recently, still be sorted on top
  # raw database size does not tell everything about commitment of editors

# $sort_column =  0 ; # total of contributors (10+ edits)
# $sort_column =  4 ; # article counts
# $sort_column = 11 ; # higest number of edits in any month
  $sort_column = 12 ; # database size
# $sort_column = 13 ; # word count in all articles combined
# $sort_column = 14 ; # internal link count (Wikipedia uses this)
# $sort_column = 19 ; # page requests per day (assumes webalizer input is available)
# $sort_column = 20 ; # visitors per day      (assumes webalizer input is available)

  # crossref determines links on Sitemap.htm to other language versions
  # you can specify a subset of languages defined in WikiReports.pl, which is
  # $crossref = "ast,ca,da,de,en,eo,es,fr,he,it,ja,nl,pl,pt,ro,ru,sl,sv,wa,zh" ;
  $crossref = "" ;
}

# non Wikimedia sites: reuse scheme for literal replacement introduced for wiktionaries
# if I would change the variable names to make them more general, I would have do it in 15 language files :)
sub SetLiterals_NoWikimedia
{
# $out_statistics      = "Wikicities Statistics" ;
# $out_charts          = "Wikicities Charts" ;
# $out_publication     = "Wikicities" ;
# $out_publications    = "Wikicities" ;
# $out_publishers      = "Wikicities" ;
# $out_wiktionary      = "Wikicities" ;
# $out_wiktionaries    = "Wikicities" ;
# $out_wiktionarians   = "wikicitizens" ;
# $out_wikimedia       = "Wikicities" ;
# $out_wikimedia_sites = "Wikicities" ;
# $out_history         = "" ;

# @out_tbl3_legend [15] = "Total number of links to projects in other languages" ;
# $out_reg_users_edited = "wikicitizen edited" ;
# $out_reg_user_edited  = "wikicitizen edited" ;
# $out_unique_users     = "Wikicitizens" ;
# $out_categories       = "Categories" ;

# $out_categories_complete  = "All categories" ;
# $out_categories_concise   = "Main categories" ;
# $out_categories_main      = "Top categories" ;
# $out_categories_redirects = "" ;
# $out_follow_links         = "" ;

# $out_languages {"zz"} = "All Wikicities" ;

# $out_no_wikimedia = "This script has been developed for <a href='http://www.wikimedia.org'>Wikimedia</a> and has been adapted for <a href='https://www.railpedia.nl'>Railpedia</a>." ;
# $out_sort_order = "Wikicities are ordered by database size" ;

  $out_statistics      = "Railpedia Statistieken" ;
  $out_charts          = "Railpedia Grafieken" ;
  $out_publication     = "Railpedia" ;
  $out_publications    = "Railpedia's" ;
  $out_publishers      = "Railpedianen" ;
  $out_wiktionary      = "Railpedia" ;
  $out_wiktionaries    = "Railpedia's" ;
  $out_wiktionarians   = "Railpedianen" ;
  $out_wikimedia       = "Railpedia" ;
  $out_wikimedia_sites = "Railpedia's" ;
  $out_history         = "" ;

  $out_statistics      = "Wiqopedia Statistics" ;
  $out_charts          = "Wiqopedia charts" ;
  $out_publication     = "Wiqopedia" ;
  $out_publications    = "Wiqopedia's" ;
  $out_publishers      = "Wiqopedians" ;
  $out_wiktionary      = "Wiqopedia" ;
  $out_wiktionaries    = "Wiqopeida's" ;
  $out_wiktionarians   = "Wiqopedians" ;
  $out_wikimedia       = "Wiqopedia" ;
  $out_wikimedia_sites = "Wiqopedia's" ;
  $out_history         = "" ;

  $out_tbl3_legend [15] = "Totaal aantal links naar Railpedia's in andere talen (nog niet actief)" ;
  $out_svg_viewer =~ s/grafieken/grafiek/ ; # singular for Railpedia: one chart per page
  $out_reg_users_edited = "railpedianen bewerkten" ;
  $out_reg_user_edited  = "railpediaan bewerkte" ;
  $out_unique_users     = "Railpedianen" ;
  $out_categories       = "Categorie&euml;n" ;

  $out_tbl3_legend [15] = "Total number of links to Wiqopedia's in other languages (not yet active)" ;
  $out_svg_viewer =~ s/grafieken/chart/ ; # singular for Railpedia: one chart per page
  $out_reg_users_edited = "wiqopedians edited" ;
  $out_reg_user_edited  = "wiqopedian edited" ;
  $out_unique_users     = "Wiqopedians" ;
  $out_categories       = "Categories" ;

  $out_categories_complete  = "Alle categorie&euml;n" ;
  $out_categories_concise   = "Voornaamste categorie&euml;n" ;
  $out_categories_main      = "Hoofdcategorie&euml;n" ;
  $out_categories_redirects = "" ;
  $out_follow_links         = "" ;

  $out_categories_complete  = "All categories" ;
  $out_categories_concise   = "Major categories" ;
  $out_categories_main      = "Main categories" ;
  $out_categories_redirects = "" ;
  $out_follow_links         = "" ;

  $out_languages {"zz"} = "Alle Railpedia's" ;
  $out_languages {"zz"} = "All Wiqopedia's" ;

  $out_no_wikimedia = "Deze statistieken zijn ontwikkeld voor <a href='http://www.wikimedia.org'>Wikimedia</a> en aangepast voor <a href='https://www.railpedia.nl'>Railpedia</a>." ;
  $out_no_wikimedia = "These statistics have been developed for <a href='http://www.wikimedia.org'>Wikimedia</a> and adapted for <a href='http://wiqopedia.klm.com'>Wiqopedia</a>." ;

  # don't forget to edit when you choose another sort column
  $out_sort_order = "Railpedia projects are ordered by database size" ;
  $out_sort_order = "Wiqopedia projects are ordered by database size" ;
}

sub UrlWebsite
{
  $prefix = shift ;
# return ("http://$prefix.wikicities.com") ;
# return ("https://www.railpedia.nl/index.php?title=Hoofdpagina") ;
  return ("http://wiqopedia.klm.com") ;
}

1;

