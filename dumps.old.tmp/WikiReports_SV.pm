#!/usr/bin/perl

sub SetLiterals_SV
{
$out_statistics   = "Wikipedia-statistik" ;
$out_charts       = "Wikipedia-diagram" ;
$out_btn_tables   = "Tabeller" ;
$out_btn_tables   = "Tabell" ;
$out_btn_charts   = "Diagram" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipedior" ;
$out_wikipedians   = "wikipedianer" ;

$out_wiktionary   = "Wiktionary" ;
$out_wiktionaries = "Wiktionaries" ;
$out_wiktionarians   = "wiktionarianer" ;

$out_wikibook        = "Wikibok" ;
$out_wikibooks       = "Wikib&ouml;cker" ;
$out_wikibookies     = "Wikiboks f&ouml;rfattare" ;

$out_wikiquote       = "Wikiquote" ;
$out_wikiquotes      = "Wikiquotes" ;
$out_wikiquotarians  = "Wikiquotarians" ;

$out_wikinews        = "Wikinews" ;
$out_wikinewssites   = "Wikinews sites" ;
$out_wikireporters   = "Wikireporters" ;

$out_wikisources     = "Wikisource" ;
$out_wikisourcesites = "Wikisources" ;
$out_wikilibrarians  = "Wikilibrarians" ;

$out_wikispecial     = "Wikispecial" ;
$out_wikispecials    = "Wikispecial sites" ;
$out_wikispecialists = "Authors" ;

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "Wikimedia sites" ;

$out_comparisons  = "J&auml;mf&ouml;relser" ;

$out_creation_history = "Creation history" ;
$out_accomplishments  = "Accomplishments" ;
$out_created          = "Created" ;
$average_increase     = "Average increase per month" ;

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "Alla bilder och data på denna sida &auml;r Public Domain." ;
$out_generated    = "Sammanst&auml;lld " ;
$out_sqlfiles     = "ur SQL-dumpfilerna fr&acirc;n " ;
$out_version      = "Script-version:" ;
$out_author       = "F&ouml;rfattare" ;
$out_mail         = "Mail" ;
$out_site         = "Webbplats" ;
$out_home         = "Home" ;
$out_sitemap      = "&Ouml;versikt";
$out_rendered     = "Graferna &auml;r ritade med hj&auml;lp av" ;
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "Index f&ouml;r EasyTimeline grafer per Wikipedia" ;
$out_categories   = "Kategori sammanfattning per Wikipedia" ;
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistik f&ouml;r " ;
$out_stats_per    = "Statistik per " ;

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "Kb" ;
$out_bytes        = "b" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Datum" ;
$out_year         = "&acirc;r" ;
$out_month        = "m&acirc;nad" ;
$out_mean         = "Medelv&auml;rde" ;
$out_growth       = "&Ouml;kning" ;
$out_total        = "Totalt" ;
$out_bars         = "Staplar" ;
$out_zoom         = "Zoom" ;
$out_scripts      = "Skript" ;

$out_new          = "ny" ;
$out_all          = "alla" ; # not sure  (people)
$out_all2         = "alla" ; # not sure (things)

$out_phaseIII     = "Bara Wikipedior som k&ouml;rs på <a href='http://www.mediawiki.org'>MediaWiki</a> programvarn &auml;r med." ;

$out_svg_viewer   = "F&ouml;r att kunna se denna sidas innehåll beh&ouml;ver du en SVG visare" .
                    "till exempel <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "f&ouml;r MS Explorer Win/Mac (fri), eller <a href='http://en-us.www.mozilla.com/en-US/firefox/'>Firefox version 2.0" ;
$out_rendering    = "Ritar graf, detta kommer ta ett tag" ;

$out_conversions1 = "" ;
$out_conversions2 = " (halv-)automatiskt omvandlade." ;

$out_sort_order   = "Wikipediorna &auml;r sorterade efter antal interna l&auml;nkar (exkl. redirects) " .
                    "Detta ger en r&auml;ttvisare j&auml;mf&ouml;relse av den sammanlagda anstr&auml;ngningen &auml;n antal artiklar " .
                    "eller databasstorleken: Antalet artiklar s&auml;ger inte s&acirc; mycket eftersom " .
                    "en del Wikipedior huvudsakligen inneh&acirc;ller korta artiklar eller till " .
                    "och med m&acirc;nga automatiskt skapade artiklar, medan andra Wikipedior har f&auml;rre " .
                    "men mycket l&auml;ngre artiklar, som alla skrivits f&ouml;r hand. " .
                    "Databasstorleken beror p&acirc; kodningssystemet (Unicode-tecken tar flera " .
                    "bytes) och p&acirc; hur mening som ryms i ett tecken " .
                    "(exempelvis motsvarar ju kinesiska tecken hela ord)." ;
$out_not_included = "Not included" ; #new

$out_average_1    = "genomsnittligt antal f&ouml;r de angivna m&acirc;naderna" ;
$out_growth_1     = "genomsnittlig m&acirc;natlig &ouml;kning f&ouml;r de angivna m&acirc;naderna" ;
$out_formula      = "formel" ;
$out_value        = "v&auml;rde" ;
$out_monthes      = "m&acirc;nader" ;
$out_skip_values  = "(Wikipedior med v&auml;rden < 10 har ej tagits med)" ;

$out_history      = "M&auml;rk: siffrorna f&ouml;r de &auml;ldsta m&acirc;naderna &auml;r f&ouml;r l&acirc;ga. " .
                    "Versionshistoriken bevarades inte alltid i projektets inledning." ;

$out_unique_users = "Unique users" ; # new
$out_archived     = "Archived" ; # new
$out_reg          = "Reg." ;   # new (Reg. = Registered)
$out_unreg        = "Unreg." ; # new (Unreg. = Unregistered)

$out_reg_users_edited = "reg. users edited" ; # new
$out_reg_user_edited  = "reg. user edited" ;  # new

$out_index        = "Index" ;    # new
$out_complete     = "Complete" ; # new
$out_concise      = "Concise" ;  # new

$out_categories_complete = "Complete" ; # new
$out_categories_concise  = "Concise" ;  # new
$out_categories_main     = "Main" ;     # new
$out_category_trees      = "Wikipedia Category Overviews" ; # new
$out_category_tree       = "Wikipedia Category Overview" ;  # new

$out_license      = "All data and images on this page are in the public domain." ; # new

$out_tbl1_intro   = "[[2]] nyligen aktiva wikipedianer, " .
                    "sorterade efter antal bidrag:" ;
$out_tbl1_intro2  = "bara artikel &auml;ndringar r&auml;knas, inte dikussionssidor" ;
$out_tbl1_intro3  = "&Delta; = &auml;ndring de senaste 30 dagarna." ;

$out_tbl1_hdr1    = "Anv&auml;ndare" ;
$out_tbl1_hdr2    = "Redigeringar" ;
$out_tbl1_hdr3    = "F&ouml;rsta redigering" ;
$out_tbl1_hdr4    = "Senaste redigering" ;
$out_tbl1_hdr5    = "datum" ;
$out_tbl1_hdr6    = "hur l&auml;nge<br>sedan" ;
$out_tbl1_hdr7    = "total" ;
$out_tbl1_hdr8    = "senaste<br>30 dagarna" ;
$out_tbl1_hdr9    = "rank" ;
$out_tbl1_hdr10   = "just nu" ;
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Artiklar" ;
$out_tbl1_hdr13   = "Annat" ;

$out_tbl2_intro  = "[[3]] nyligen fr&acirc;nvarande wikipedianer, " .
                   "sorterade efter antal bidrag:" ;

$out_tbl3_intro   = "&Ouml;kning i antalet aktiva wikipedianer och deras aktivitet" ;

$out_tbl3_hdr1a   = "Wikipedianer" ;
$out_tbl3_hdr1e   = "Artiklar" ;
$out_tbl3_hdr1l   = "Databas" ;
$out_tbl3_hdr1o   = "L&auml;nkar" ;
$out_tbl3_hdr1t   = "Dagligt anv&auml;ndade" ;

# use &nbsp; (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registrerade anv&auml;ndare)" ;
$out_tbl3_hdr1e2  = "(exkl. redirects)" ;

$out_tbl3_hdr2a   = "totalt" ; # "total<br>&nbsp;" ;
$out_tbl3_hdr2b   = "nya" ;
$out_tbl3_hdr2c   = "redigeringar" ;
$out_tbl3_hdr2e   = "antal" ;
$out_tbl3_hdr2f   = "nya<br>per&nbsp;dag" ;
$out_tbl3_hdr2h   = "medeltal" ;
$out_tbl3_hdr2j   = "st&ouml;rre&nbsp;&auml;n" ;
$out_tbl3_hdr2l   = "redigeringar" ;
$out_tbl3_hdr2m   = "storlek" ;
$out_tbl3_hdr2n   = "ord" ;
$out_tbl3_hdr2o   = "interna" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "bilder" ;
$out_tbl3_hdr2r   = "externa" ;
$out_tbl3_hdr2s   = "redirects" ;
$out_tbl3_hdr2t   = "sid<br>h&auml;mtningar" ;
$out_tbl3_hdr2u   = "bes&ouml;k" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "officiella" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;tkn" ;
$out_tbl3_hdr3h   = "redigeringar" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonymous users, ordered by number of contributions" ; # new
$out_table6_footer = "Alltogether %d edits were made by anonymous users, out of a total of %d edits (%.0f\%)" ; # new

$out_tbl5_intro   = "Visitor statistics (based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definitions</font></a>, " .
                    "<a href=''><font color='#000088'>chart</font></a>)" ; #new
$out_tbl5_hdr1a   = "Daily Average" ; # new
$out_tbl5_hdr1e   = "Monthly Totals" ; # new
$out_tbl5_hdr2a   = "Tr&auml;ffar" ;
$out_tbl5_hdr2b   = "Filer" ;
$out_tbl5_hdr2c   = "Sidor" ;
$out_tbl5_hdr2d   = "Bes&ouml;k" ;
$out_tbl5_hdr2e   = "Sites" ;
$out_tbl5_hdr2f   = "KByte" ;
$out_tbl5_hdr2g   = "Bes&ouml;k" ;
$out_tbl5_hdr2h   = "Sidor" ;
$out_tbl5_hdr2i   = "Filer" ;
$out_tbl5_hdr2j   = "Tr&auml;ffar" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ;
@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Wikipedianer som gjort minst 10 redigeringar sedan de b&ouml;rjade",
"&ouml;kning i antalet wikipedianer som gjort minst 10 redigeringar sedan de b&ouml;rjade",
"Wikipedianer som l&auml;mnat minst 5 bidrag den senaste m&acirc;naden",   # upd past -> this
"Wikipedianer som l&auml;mnat minst 100 bidrag den senaste m&acirc;naden",   # upd past -> this
"Artiklar som inneh&acirc;ller minst en intern l&auml;nk",
"Artiklar som inneh&acirc;ller minst en intern l&auml;nk och 200 tecken l&auml;sbar text, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;undantagandes wiki- och html-koder, dolda l&auml;nkar, etc.; &auml;ven rubriker &auml;r undantagna<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(&ouml;vriga spalter baseras p&acirc; det officiella antalet artiklar)",
"Nya artiklar per dag den senaste m&acirc;naden",   # upd past -> this
"Genomsnittligt antal versioner per artikel",
"Artiklarnas genomsnittliga storlek i bytes",
"Procentuell andel av artiklarna som with at least 0.5 Kb readable text (see F)", # upd
"Procentuell andel av artiklarna som with at least 2 Kb readable text (see F)",
"Redigeringar den senaste m&acirc;naden (inkl. redirects, inkl. oregistrerade bidragsl&auml;mnare)",
"Artiklarnas sammanlagda storlek (inkl. redirects)",
"Total number of words (excl. redirects, html/wiki codes and hidden links)", # new
"Totalt antal interna l&auml;nkar (exkl. redirects, stubbar och l&auml;nklistor)",
"Totalt antal l&auml;nkar till andra Wikipedior",
"Totalt antal visade bilder",
"Totalt antal l&auml;nkar till andra webbplatser",
"Totalt antal omdirgigeringar",
# new ->
"Page requests per day (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
# new ->
"Visits per day (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Uppgifter f&ouml;r de senaste m&acirc;naderna"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedianer som l&auml;mnat minst 5 bidrag den senaste .. (week)",   # upd past -> this
"Wikipedianer som l&auml;mnat minst 25 bidrag den senaste .. (week)",   # upd past -> this
) ;

$out_legend_daily_edits = "Redigeringar per day (inkl. redirects, inkl. oregistrerade bidragsl&auml;mnare)" ; # new
$out_report_description_daily_edits = "Redigeringar per day" ;
$out_report_description_edits       = "Redigeringar per m&acirc;nad/dag" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Bidragsl&auml;mnare",
"Nya wikipedianer",
"Aktiva wikipedianer",
"Mycket aktiva wikipedianer",
"Antal artiklar (officiellt)",
"Antal artiklar (alternativt)",
"Nya artiklar per dag",
"Redigeringar per artikel",
"Bytes per artikel",
"Artiklar &ouml;ver 0.5 Kb",
"Artiklar &ouml;ver 2 Kb",
"Redigeringar per m&acirc;nad",
"Databasstorlek",
"ord",
"Interna l&auml;nkar",
"L&auml;nkar till andra Wikipedior",
"Bilder",
"Webbl&auml;nkar",
"Redirects",
"Sid h&auml;mtningar per dag",
"Bes&ouml;k per dag",
"&Ouml;versikt"
) ;

# the full list is in WikiReports.pl
# this selection is for translators only
$out_languages {"ar"} = "Arabiska" ;
$out_languages {"bs"} = "Bosniska" ;
$out_languages {"cs"} = "Tjeckiska" ;
$out_languages {"da"} = "Danska" ;
$out_languages {"de"} = "Tyska" ;
$out_languages {"el"} = "Grekiska" ;
$out_languages {"en"} = "Engelska" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Spanska" ;
$out_languages {"et"} = "Estniska" ;
$out_languages {"fa"} = "Persiska" ;
$out_languages {"fi"} = "Finska" ;
$out_languages {"fr"} = "Franska" ;
$out_languages {"fy"} = "Frisiska" ;
$out_languages {"ga"} = "Iriska" ;
$out_languages {"he"} = "Hebreiska" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Kroatiska" ;
$out_languages {"hu"} = "Ungerska" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"id"} = "Indonesiska" ;
$out_languages {"it"} = "Italienska" ;
$out_languages {"ja"} = "Japanska" ;
$out_languages {"ka"} = "Georgiska" ;
$out_languages {"ko"} = "Koreanska" ;
$out_languages {"la"} = "Latin" ;
$out_languages {"lt"} = "Litauiska" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"ms"} = "Malajiska" ;
$out_languages {"my"} = "Burmesiska" ;
$out_languages {"nl"} = "Holl&auml;ndska" ;
$out_languages {"nn"} = "Norska (Nynorsk)" ;
$out_languages {"no"} = "Norska" ;
$out_languages {"pl"} = "Polska" ;
$out_languages {"pt"} = "Portugisiska" ;
$out_languages {"ro"} = "Rum&auml;nska" ;
$out_languages {"ru"} = "Ryska" ;
$out_languages {"sr"} = "Serbiska" ;
$out_languages {"sh"} = "Serbokroatiska" ;
$out_languages {"sv"} = "Svenska" ;
$out_languages {"th"} = "Thai" ;
$out_languages {"tr"} = "Turkiska" ;
$out_languages {"zh"} = "Kinesiska" ;
$out_languages {"zz"} = "Alla&nbsp;spr&acirc;k" ;
}


1;

