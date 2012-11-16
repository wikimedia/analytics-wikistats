#!/usr/bin/perl

sub SetLiterals_NL
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics    = "Wikipedia Statistieken" ;
$out_charts        = "Wikipedia Grafieken" ;
$out_btn_tables    = "Tabellen" ;
$out_btn_table     = "Tabel" ;
$out_btn_charts    = "Grafieken" ;

$out_wikipedia     = "Wikipedia" ;
$out_wikipedias    = "Wikipedia's" ;
$out_wikipedians   = "wikipedianen" ;

$out_wiktionary    = "Wiktionary" ;
$out_wiktionaries  = "Wiktionaries" ;
$out_wiktionarians = "wiktionairs" ;

$out_wikibook        = "Wikibook" ;  # new
$out_wikibooks       = "Wikibooks" ; # new
$out_wikibookies     = "Wikibook authors" ; # new

$out_wikiquote       = "Wikiquote" ;  # new
$out_wikiquotes      = "Wikiquotes" ; # new
$out_wikiquotarians  = "Wikiquotarians" ; # new

$out_wikinews        = "Wikinews" ;  # new
$out_wikinewssites   = "Wikinews sites" ; # new
$out_wikireporters   = "Wikireporters" ; # new

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Wikispecial" ;  # new
$out_wikispecials    = "Wikispecial sites" ; # new
$out_wikispecialists = "Authors" ; # new

$out_wikimedia       = "Wikimedia" ;       # new
$out_wikimedia_sites = "Wikimedia sites" ; # new

$out_comparisons   = "Vergelijkingen" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Achter elke categorie staat het aantal artikelen dat tot deze categorie behoort" ; # new
$out_follow_links           = "Tip: volg links met Shift+Muisclick. Dit voorkomt dat deze pagina opnieuw gedownload moet worden" ; # new
$out_categories_templates   = "Categorie aanduidigen die via een sjabloon toegevoegd zijn worden <b>nog niet</b> verwerkt." ; # new
$out_categories_redirects   = "Dit overzicht kan ook categorie&euml;n bevatten die alleen bij 'redirect' pagina's voorkomen." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Gegenereerd op " ;
$out_sqlfiles     = "uit de SQL-dumpfiles van " ;
$out_version      = "Script versie:" ;
$out_author       = "Auteur" ;
$out_mail         = "Mail" ;
$out_site         = "Website" ;
$out_home         = "Home" ;
$out_sitemap      = "Sitemap";
$out_rendered     = "Grafieken gegenereerd met " ;
$out_generated2   = "Ook gegenereerd:" ;       # new
$out_easytimeline = "EasyTimeline grafieken per Wikipedia" ; # new
$out_categories   = "Categorie-overzicht per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "Kb" ;
$out_bytes        = "b" ;

$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Datum" ;
$out_year         = "jaar" ;
$out_month        = "maand" ;
$out_mean         = "Gemiddeld" ;
$out_growth       = "Groei" ;
$out_total        = "Totaal" ;
$out_bars         = "Staven" ;
$out_zoom         = "Zoom" ; # new
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "Er zijn " ;
$out_conversions2 = " (semi-)automatische conversies uitgevoerd." ;

$out_phaseIII     = "Alleen Wikipedia's die met <a href='http://www.mediawiki.org'>MediaWiki</a> software draaien worden getoond." ;

$out_svg_viewer   = "Om de grafieken op deze pagina te kunnen bekijken heeft u een " .
                    "'SVG viewer' nodig.<br>Voor MS Explorer Win/Mac kunt de <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> installeren.<br>" .
                    "Bij Firefox 1.5 en hoger wordt SVG standaard ondersteund" ; # new
$out_rendering    = "Rendering.... Please wait" ; # new

$out_sort_order   = "De Wikipedia's staan op volgorde van aantal interne links (excl. redirects).<br>" .
                    "Dit lijkt een betere criterium om de geleverde inspanning per Wikipedia te vergelijken " .
                    "dan de offici&euml;le telling (aantal artikelen met minstens 1 link) of de omvang van de database: " .
                    "Het aantal artikelen per Wikipedia is slecht te vergelijken omdat sommige Wp's " .
                    "zeer veel korte pagina's bevatten (zo bevat de Deense Wp b.v. " .
                    "8500 woordenboek lemma's van gemiddeld drie woorden) en " .
                    "heeft de Engelse Wp zo'n 30,000 automatisch gegeneerde 'artikelen' die voor elk stadje " .
                    "in de VS tonen hoe de bevolking naar ras en leeftijd e.d.opgedeeld is." .
                    "Ook de omvang van de database per Wikipedia geeft geen goede vergelijking: " .
                    "sommige Wikipedia's werken met unicode, waardoor een teken daar meerdere bytes inneemt. " .
                    "Daar staat weer tegenover dat sommige talen met &eacute;&eacute;n teken veel meer uit kunnen drukken " .
                    "(zo is in het Chinees elk karakter een heel woord)." ;
$out_not_included = "Not included" ; #new

$out_average_1    = "gemiddelde over getoonde maanden" ;
$out_growth_1     = "gemiddelde groei over getoonde maanden" ;
$out_formula      = "formule" ;
$out_value        = "waarde" ;
$out_monthes      = "maanden" ;
$out_skip_values  = "(wordt niet getoond voor Wikipedia's met waarden lager dan 10)" ;

$out_history      = "N.B.: de tellingen voor de eerste maanden zijn te laag.<br>" .
                    "Oude versies van een artikel werden in het begin niet altijd bewaard." ;

$out_unique_users = "Unieke gebruikers" ;
$out_archived     = "Gearchiveerd" ;
$out_reg          = "Geregistreerd" ;
$out_unreg        = "Anoniem" ;

$out_reg_users_edited = "gereg. gebruikers bewerkten" ; # new
$out_reg_user_edited  = "gereg. gebruiker bewerkte" ;  # new

$out_index        = "Index" ;    # new
$out_complete     = "Complete" ; # new
$out_concise      = "Concise" ;  # new

$out_categories_complete = "Complete" ; # new
$out_categories_concise  = "Concise" ;  # new
$out_categories_main     = "Main" ;     # new
$out_category_trees      = "Wikipedia Categorie&euml;n" ; # new
$out_category_tree       = "Wikipedia Categorie&euml;n" ; # new

$out_license      = "All data and images on this page are in the public domain." ; # new

$out_tbl1_intro   = "[[2]] recent actieve wikipedianen, " .
                       "gerangschikt naar aantal bijdragen" ;
$out_tbl1_intro2  = "alleen bijdragen aan artikelen zijn geteld, niet aan discussiepagina's e.d." ;
$out_tbl1_intro3  = "&Delta; = gestegen/gedaald in 30 dagen" ; # new

$out_tbl1_hdr1    = "Gebruiker" ;
$out_tbl1_hdr2    = "Bewerkingen" ;
$out_tbl1_hdr3    = "Eerste bewerking" ;
$out_tbl1_hdr4    = "Laatste bewerking" ;
$out_tbl1_hdr5    = "datum" ;
$out_tbl1_hdr6    = "dagen<br>terug" ;
$out_tbl1_hdr7    = "totaal" ; # new
$out_tbl1_hdr8    = "laatste<br>30 dagen" ; # new
$out_tbl1_hdr9    = "plaats" ; # new
$out_tbl1_hdr10   = "nu" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Artikelen" ; # new
$out_tbl1_hdr13   = "Overig" ; # new

$out_tbl2_intro   = "[[3]] recent niet actieve wikipedianen, " .
                       "gerangschikt naar aantal bijdragen" ;

$out_tbl3_intro   = "Groei in aantal actieve wikipedianen en activiteit" ;

$out_tbl3_hdr1a   = "Wikipedianen" ;
$out_tbl3_hdr1e   = "Artikelen" ;
$out_tbl3_hdr1l   = "Database" ;
$out_tbl3_hdr1o   = "Links" ;
$out_tbl3_hdr1t   = "Bezoek per dag" ;

$out_tbl3_hdr1a2  = "(geregistreerde gebruikers)" ;
$out_tbl3_hdr1e2  = "(excl. redirects)" ;

$out_tbl3_hdr2a   = "ooit<br>actief" ;
$out_tbl3_hdr2b   = "nieuwe<br>'leden'" ;
$out_tbl3_hdr2c   = "bewerkingen" ;
$out_tbl3_hdr2e   = "aantal" ;
$out_tbl3_hdr2f   = "nieuw<br>per&nbsp;dag" ;
$out_tbl3_hdr2h   = "gemiddeld" ;
$out_tbl3_hdr2j   = "groter dan" ;
$out_tbl3_hdr2l   = "edit<br>acties" ;
$out_tbl3_hdr2m   = "totale<br>omvang" ;
$out_tbl3_hdr2n   = "woorden" ;
$out_tbl3_hdr2o   = "intern" ;
$out_tbl3_hdr2p   = "andere<br>talen" ;
$out_tbl3_hdr2q   = "beeld" ;
$out_tbl3_hdr2r   = "extern" ;
$out_tbl3_hdr2s   = "redirects" ;
$out_tbl3_hdr2t   = "pagina<br>aanvragen" ;
$out_tbl3_hdr2u   = "bezoekers" ;
$out_tbl3_hdr2s2  = "projecten" ; 

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "offici&euml;el" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;tk" ;
$out_tbl3_hdr3h   = "bewerkingen" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonieme gebruikers, gerangschikt naar aantal bewerkingen" ; # new
$out_table6_footer = "%d bewerkingen zijn afkomstig van anonieme gebruikers, uit een totaal van %d bewerkingen (%.0f\%)" ; # new

$out_tbl5_intro   = "Bezoekersstatistieken (gebaseerd op <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definities</font></a>, " .
                    "<a href=''><font color='#000088'>grafiek</font></a>)" ;
$out_tbl5_hdr1a   = "Per dag gemiddeld" ;
$out_tbl5_hdr1e   = "Totaal per maand" ;
$out_tbl5_hdr2a   = "Hits" ;
$out_tbl5_hdr2b   = "Bestanden" ;
$out_tbl5_hdr2c   = "Pagina's" ;
$out_tbl5_hdr2d   = "Bezoekers" ;
$out_tbl5_hdr2e   = "Sites" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "Bezoekers" ;
$out_tbl5_hdr2h   = "Pagina's" ;
$out_tbl5_hdr2i   = "Bestanden" ;
$out_tbl5_hdr2j   = "Hits" ;

$out_tbl7_intro   = "Database records per namespace / Gecategoriseerde artikelen<p>" .
                    "<small>1) Categorie&euml;n die via een sjabloon zijn toegevoegd worden niet gedetecteerd.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Gecategoriseerde<br>artikelen <sup>1</sup>" ;

$out_tbl8_intro   = "Verdeling van aantal bewerkingen over aantal wikipedianen"  ;

$out_tbl9_intro   = "[[5]] meest bewerkte artikelen (> 25 bewerkingen)"  ;

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Artikel", "Gebruiker", "Project", "Afbeelding", "MediaWiki", "Sjabloon", "Help", "Categorie") ;

@out_tbl3_legend  = (
"Wikipedianen die ooit 10 of meer bewerkingen hebben uitgevoerd",
"Wikipedianen die in deze maand voor het eerst 10 bijdragen hadden geleverd",
"Wikipedianen die in de voorgaande maand 5 of meer bewerkingen hebben uitgevoerd",
"Wikipedianen die in de voorgaande maand 100 of meer bewerkingen hebben uitgevoerd",
"Artikelen die minstens &eacute;&eacute;n interne verwijzing bevatten",
"Artikelen die minstens &eacute;&eacute;n interne verwijzing en minstens 200 tekens leesbare tekst bevatten, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dus zonder wiki- en html opmaakcodes, verborgen links e.d.; ook koppen tellen niet mee.<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(overige kolommen zijn op offici&euml;le definitie gebaseerd)",
"Nieuwe artikelen per dag in voorgaande maand",
"Gemiddeld aantal bewerkingen per artikel",
"Gemiddelde omvang van artikel in bytes",
"Percentage artikelen dat meer dan 0,5 Kb leesbare tekst bevat (zie F)",
"Percentage artikelen dat meer dan 2 Kb leesbare tekst bevat (zie F)",
"Bewerkingen per maand (incl. redirects, incl. niet geregistreerde gebruikers)",
"Totale omvang van alle artikelen (incl. redirects)",
"Totaal aantal woorden (excl. redirects, wiki- en html opmaakcodes, verborgen links)",
"Totaal aantal interne verwijzingen (excl. redirects, stubs en linklijsten)",
"Totaal aantal links naar andere Wikipedia's",
"Totaal aantal links naar afbeeldingen",
"Totaal aantal externe links",
"Totaal aantal redirects",
"Opgevraagde pagina's per dag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definitie</font></a>, gebaseerd op <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Bezoekers per dag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definitie</font></a>, gebaseerd op <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Gegevens van laatste maanden"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedianen die in de voorgaande week 5 of meer bewerkingen hebben uitgevoerd",
"Wikipedianen die in de voorgaande week 25 of meer bewerkingen hebben uitgevoerd",
) ;

# overrule defaults (set at WikiCount.pl)
$out_languages {"bs"} = "Bosnisch" ;
$out_languages {"cs"} = "Tsjechisch" ;
$out_languages {"da"} = "Deens" ;
$out_languages {"de"} = "Duits" ;
$out_languages {"el"} = "Grieks" ;
$out_languages {"en"} = "Engels" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Spaans" ;
$out_languages {"fr"} = "Frans" ;
$out_languages {"hr"} = "Kroatisch" ;
$out_languages {"ja"} = "Japans" ;
$out_languages {"ko"} = "Koreaans" ;
$out_languages {"li"} = "Limburgs" ;
$out_languages {"ms"} = "Maleis" ;
$out_languages {"nl"} = "Nederlands" ;
$out_languages {"nn"} = "Nieuw-Noors" ;
$out_languages {"no"} = "Noors" ;
$out_languages {"os"} = "Ossetisch" ;
$out_languages {"pl"} = "Pools" ;
$out_languages {"sh"} = "Servo-Kroatisch" ;
$out_languages {"sr"} = "Servisch" ;
$out_languages {"sv"} = "Zweeds" ;
$out_languages {"tr"} = "Turks" ;
$out_languages {"zh"} = "Chinees" ;
$out_languages {"zz"} = "Alle&nbsp;talen" ;

$out_legend_daily_edits = "Bewerkingen per dag (incl. redirects, incl. niet geregistreerde gebruikers)" ;
$out_report_description_daily_edits    = "Bewerkingen per dag" ;
$out_report_description_edits          = "Bewerkingen per maand/dag" ;
$out_report_description_current_status = "Huidige status" ;

@out_report_descriptions = (
"Wikipedianen",
"Nieuwe wikipedianen",
"Actieve wikipedianen",
"Zeer actieve wikipedianen",
"Artikelen (offici&euml;el)",
"Artikelen (alternatief)",
"Nieuwe artikelen per dag",
"Bewerkingen per artikel",
"Bytes per artikel",
"Artikelen > 0.5 Kb",
"Artikelen > 2 Kb",
"Bewerkingen per maand",
"Databaseomvang",
"Woorden",
"Interne links",
"Links naar andere Wikipedia's",
"Links naar afbeeldingen",
"Weblinks",
"Redirects",
"Pagina's per dag",
"Bezoekers per dag",
"Overzicht"
) ;
}

1;

