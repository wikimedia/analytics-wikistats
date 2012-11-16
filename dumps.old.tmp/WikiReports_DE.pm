#!/usr/bin/perl

sub SetLiterals_DE
{
$out_statistics      = "Wikipedia-Statistik" ;
$out_charts          = "Wikipedia-Diagramme" ;
$out_btn_tables      = "Tabellen" ;
$out_btn_table       = "Tabell" ; # new singular OK ?
$out_btn_charts      = "Diagramme" ;

$out_wikipedia       = "Wikipedia" ;
$out_wikipedias      = "Wikipedias" ;
$out_wikipedians     = "Wikipedianer" ; # new

$out_wiktionary      = "Wikiw&ouml;rterbuch" ;
$out_wiktionaries    = "Wikiw&ouml;rterb&uuml;cher" ;
$out_wiktionarians   = "Wikiw&ouml;rterbuch-Autoren" ; # new

$out_wikibook        = "Wikibook" ;  # new
$out_wikibooks       = "Wikibooks" ; # new
$out_wikibookies     = "Wikibook-Autoren" ; # new

$out_wikiquote       = "Wikiquote" ;  # new
$out_wikiquotes      = "Wikiquotes" ; # new
$out_wikiquotarians  = "Wikiquotarier" ; # new

$out_wikinews        = "Wikinews" ;  # new
$out_wikinewssites   = "Wikinews Artikel" ; # new
$out_wikireporters   = "Wikireporter" ; # new

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Wikispecial" ;  # new
$out_wikispecials    = "Wikispecial-Seiten" ; # new
$out_wikispecialists = "Autoren" ; # new

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "Wikimedia-Seiten" ; # new

$out_comparisons     = "Vergleiche" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Erzeugt am  " ;
$out_version      = "Version des Skripts:" ;
$out_author       = "Autor" ;
$out_mail         = "Mail" ;
$out_site         = "Website" ;
$out_home         = "Home" ;
$out_sitemap      = "Sitemap";
$out_rendered     = "Diagramme gerendert durch " ; #new
$out_generated2   = "Auch generiert:" ;       # new
$out_easytimeline = "&Uuml;bersicht der EasyTimelines der Wikipedias" ; # new
$out_categories   = "Kategorien&uuml;bersicht der Wikipedias" ; # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "GB" ;
$out_megabytes    = "MB" ;
$out_kilobytes    = "kB" ;
$out_bytes        = "B" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Datum" ;
$out_year         = "Jahr" ;
$out_month        = "Monat" ;
$out_mean         = "Durchsch." ;
$out_growth       = "Zunahme" ;
$out_total        = "Gesamt" ;
$out_bars         = "S&auml;ulen" ;
$out_zoom         = "Zoom" ; # new
$out_scripts      = "Scripts" ; # new

$out_new          = "neu" ; # new
$out_all          = "alle" ; # new  (people)
$out_all2         = "alle" ; # new  (things)

$out_sqlfiles     = "aus dem SQL-Dump vom " ;

$out_conversions1 = "Es wurden " ;
$out_conversions2 = " (semi-)automatische Umwandlungen durchgef&uuml;hrt." ;

$out_history      = "Hinweis: Die Zahlen f&uuml;r die ersten Monate sind zu niedrig.<br>" .
                    "Ein Gro&szlig;teil der Versions-Geschichten bis Sommer 2002 ging leider verloren." ;

$out_unique_users = "Unique users" ; # new
$out_archived     = "Archived" ; # new
$out_reg          = "Reg." ;   # new (Reg. = Registered)
$out_unreg        = "Unreg." ; # new (Unreg. = Unregistered)

$out_reg_users_edited = "reg. users edited" ; # new
$out_reg_user_edited  = "reg. user edited" ;  # new

$out_phaseIII     = "Nur Wikipedias mit <a href='http://www.mediawiki.org'>MediaWiki</a> werden aufgef&uuml;hrt." ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "für MS Explorer Win/Mac (gratis)" ; # new
$out_rendering    = "Am rendern.... Bitte warten" ; # new

$out_sort_order   = "Wikipedias sind nach der Anzahl ihrer internen Links (exkl. Redirects) geordnet.<br>" .
                    "Dies scheint ein besseres Kriterium zu sein als die Anzahl der Artikel oder die Gesamtgr&ouml;&szlig;e aller Artikel:<br>" .
                    "Die Anzahl der Artikel ist nicht so bedeutend, weil manche Wikipedias nur sehr kurze Artikel haben,<br>" .
                    "oder eben viele automatisch generierte Artikel; andere Wikipedias dagegen haben weniger aber viele l&auml;ngere Artikel.<br>" .
                    "Die Datenbankgr&ouml;&szlig;e wird auch durch das Zeichencode-System beeinflusst (Unicode-Zeichen brauchen mehrere Bytes) und <br>" .
                    "durch die Ausdruckskraft einer Schrift (bspw. ist jedes chinesische Zeichen ein ganzes Wort).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "durschschnittliche Zahlen f&uuml;r gezeigte Monate" ;
$out_growth_1     = "durschschnittliche Zunahme pro Monat f&uuml;r gezeigte Monate" ;
$out_formula      = "Formel" ;
$out_value        = "Wert" ;
$out_monthes      = "Monate" ;
$out_skip_values  = "(Wikipedias mit Werten unter 10 werden nicht erfasst)" ;

$out_index        = "Index" ;    # new
$out_complete     = "Complete" ; # new
$out_concise      = "Concise" ;  # new

$out_categories_complete = "Complete" ; # new
$out_categories_concise  = "Concise" ;  # new
$out_categories_main     = "Main" ;     # new
$out_category_trees      = "Wikipedia Category Overviews" ; # new
$out_category_tree       = "Wikipedia Category Overview" ;  # new
$out_botactivity  = "Bot activity" ;     # new

$out_license      = "All data and images on this page are in the public domain." ; # new

$out_tbl1_intro   = "Die [[2]] derzeit aktivsten Wikipedianer, " .
                    "geordnet nach der Anzahl ihrer Beitr&auml;ge:" ;
$out_tbl1_intro2  = "Nur Artikelbearbeitungen und keine Diskussionsseiten usw. werden gez&auml;hlt." ; # new
$out_tbl1_intro3  = "&Delta; = Rang&auml;nderung in den letzten 30 Tagen" ; # new

$out_tbl1_hdr1    = "Benutzer" ;
$out_tbl1_hdr2    = "Bearbeitungen" ;
$out_tbl1_hdr3    = "Erster Beitrag" ;
$out_tbl1_hdr4    = "Letzter Beitrag" ;
$out_tbl1_hdr5    = "Datum" ;
$out_tbl1_hdr6    = "Tage" ;
$out_tbl1_hdr7    = "Total" ; # new
$out_tbl1_hdr8    = "letzte<br>30 Tage" ; # new
$out_tbl1_hdr9    = "Rang" ; # new
$out_tbl1_hdr10   = "Jetzt" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Artikel" ; # new
$out_tbl1_hdr13   = "Anderes" ; # new

$out_tbl2_intro   = "[[3]] derzeit abwesende Wikipedianer " .
                    "geordnet nach der Anzahl ihrer Beitr&auml;ge" ;

$out_tbl3_intro   = "Wachstum der registrierten Benutzer und Beitr&auml;ge" ;

$out_tbl3_hdr1a   = "Wikipedianer" ;
$out_tbl3_hdr1e   = "Artikel" ;
$out_tbl3_hdr1l   = "Datenbank" ;
$out_tbl3_hdr1o   = "Links" ;
$out_tbl3_hdr1t   = "T&auml;gliche Nutzung" ;

$out_tbl3_hdr1a2  = "(registrierte Benutzer)" ;
$out_tbl3_hdr1e2  = "(ohne Redirects)" ;

$out_tbl3_hdr2a   = "jemals<br>aktiv" ;
$out_tbl3_hdr2b   = "neu" ;
$out_tbl3_hdr2c   = "Beitr&auml;ge" ;
$out_tbl3_hdr2e   = "Anzahl" ;
$out_tbl3_hdr2f   = "Zunahme<br>pro&nbsp;Tag" ;
$out_tbl3_hdr2h   = "Durchschnitt" ;
$out_tbl3_hdr2j   = "gr&ouml;&szlig;er&nbsp;als" ;
$out_tbl3_hdr2l   = "Bearbei-<br>tungen" ;
$out_tbl3_hdr2m   = "Gr&ouml;&szlig;e" ;
$out_tbl3_hdr2n   = "W&ouml;rter" ;
$out_tbl3_hdr2o   = "intern" ;
$out_tbl3_hdr2p   = "andere<br>WPs" ;
$out_tbl3_hdr2q   = "Bild" ;
$out_tbl3_hdr2r   = "Weblinks" ;
$out_tbl3_hdr2s   = "Redirects" ;
$out_tbl3_hdr2t   = "Seiten-<br>Anfragen" ;
$out_tbl3_hdr2u   = "Besuche" ;
$out_tbl3_hdr2s2  = "Projekte" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "offiziell" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;sp" ;
$out_tbl3_hdr3h   = "Bearb." ;
$out_tbl3_hdr3i   = "Bytes" ;
$out_tbl3_hdr3j   = "0,5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonyme Beitr&auml;ge, sortiert nach der Anzahl der Bearbeitungen" ; # new
$out_table6_footer = "Total wurden %d Bearbeitungen durch anonyme User durchgef&uuml;hrt (Total: %d Bearbeitungen, d. h. %.0f\% durch anonyme User)" ; # new

$out_tbl5_intro   = "Besucherstatistiken (basierend auf <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>Definitionen</font></a>, " .
                    "<a href=''><font color='#000088'>Diagramm</font></a>)" ;
$out_tbl5_hdr1a   = "T&auml;glicher Durchschnitt" ; # if this is too long use "t&auml;gliches Mittel"
$out_tbl5_hdr1e   = "Gesamter Monat" ;
$out_tbl5_hdr2a   = "Hits" ;
$out_tbl5_hdr2b   = "Dateien" ;
$out_tbl5_hdr2c   = "Seiten" ;
$out_tbl5_hdr2d   = "Besuche" ;
$out_tbl5_hdr2e   = "Sites" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "Besuche" ;
$out_tbl5_hdr2h   = "Seiten" ;
$out_tbl5_hdr2i   = "Dateien" ;
$out_tbl5_hdr2j   = "Hits" ;

$out_tbl7_intro   = "Anzahl Datenbankeintr&auml;ge pro Namensraum / Kategorisierte Artikel<p>" .
                    "<small>1) Kategorien, welche durch Vorlagen eingebunden wurden, werden nicht gez&auml;hlt.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Kategorisierte<br>Artikel <sup>1</sup>" ; # new

$out_tbl8_intro = "Verteilung der Artikeledits aller Wikipediner."  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Artikel", "Benutzer", "Projekt", "Bild", "MediaWiki", "Vorlage", "Hilfe", "Kategorie") ; #new

@out_tbl3_legend  = (
"Wikipedianer mit insgesamt mehr als 10 Beitr&auml;gen",
"Zunahme im letzten Monat von Wikipedianern mit insgesamt mehr als 10 Beitr&auml;gen",
"Benutzer mit mindestens 5 Beitr&auml;gen innerhalb des letzten Monats",
"Benutzer mit mindestens 100 Beitr&auml;gen innerhalb des letzten Monats",
"Artikel, die mindestens einen Link enthalten",
"Artikel, die mindestens einen Link enthalten und mindestens 200 Zeichen lesbaren Text umfassen,<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;also ohne Wiki- und HTML-Tags, 'versteckte' Links usw.<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Die &uuml;brigen Spalten basieren auf den offiziellen Definitionen.)",
"Neue Artikel innerhalb des letzten Monats",
"Durchschnittliche Anzahl von Bearbeitungen pro Artikel",
"Durchschnittliche Artikelgr&ouml;&szlig;e in Bytes",
"Anteil von Artikeln mit mehr als 0,5 Kb lesbarem Text (siehe F)",
"Anteil von Artikeln mit mehr als 2 Kb lesbarem Text (siehe F)",
"Bearbeitungen im letzten Monat (mit Redirects und Beitr&auml;gen von unregistrierten Benutzern)",
"Gesamtgr&ouml;&szlig;e aller Artikel (mit Redirects)",
"Gesamtanzahl aller W&ouml;rter (ohne Redirects, Wiki- und HTML-Tags und 'versteckte' Links)",
"Gesamtanzahl aller internen Links (ohne Redirects, 'Stubs' und 'Linklisten')",
"Gesamtanzahl aller Links zu anderen Wikipedias",
"Gesamtanzahl aller Links zu Bildern",
"Gesamtanzahl aller Links zu anderen Websites",
"Gesamtanzahl aller Redirects",
"Seitenanfragen pro Tag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'>" .
    "<font color='#000088'>Definition</font></a>, :" .
    "basierend auf <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Besuche pro Tag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'>" .
    "<font color='#000088'>Definition</font></a>, " .
    "basierend auf <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"&Uuml;bersicht f&uuml;r die letzten Monate"
)  ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Benutzer mit mindestens 5 Beitr&auml;gen innerhalb eine Woche",
"Benutzer mit mindestens 25 Beitr&auml;gen innerhalb eine Woche",
) ;

$out_legend_daily_edits = "Bearbeitungen pro Tag (mit Redirects und Beitr&auml;gen von unregistrierten Benutzern)" ;
$out_report_description_daily_edits    = "Bearbeitungen pro Tag" ;
$out_report_description_edits          = "Bearbeitungen pro Monat/Tag" ;
$out_report_description_current_status = "Gegenwärtiger Status" ;

@out_report_descriptions = (
"Wikipedianer",
"Neue Wikipedianer",
"Aktive Wikipedianer",
"Sehr aktive Wikipedianer",
"Anzahl Artikel (offiziell)",
"Anzahl Artikel (alternativ)",
"Neue Artikel pro Tag",
"Bearbeitungen pro Artikel",
"Bytes pro Artikel",
"Artikel gr&ouml;&szlig;er als 0,5 Kb",
"Artikel gr&ouml;&szlig;er als 2 Kb",
"Bearbeitungen im letzten Monat",
"Gesamtgr&ouml;&szlig;e aller Artikel",
"W&ouml;rter",
"Interne Links",
"Links zu anderen Wikipedias",
"Bilder",
"Weblinks",
"Redirects",
"Seitenanfragen pro Tag",
"Besuche pro Tag",
"&Uuml;bersicht"
) ;


# overrule defaults (set at WikiCount.pl)
$out_languages {"als"} = "Alemannisch" ;
$out_languages {"am"} = "Amharisch" ;
$out_languages {"ang"} = "Angels&auml;chsisch" ;
$out_languages {"ar"} = "Arabisch" ;
$out_languages {"arc"} = "Aramäisch" ;
$out_languages {"as"} = "Assamese" ;
$out_languages {"ast"} = "Asturisch" ;
$out_languages {"az"} = "Aserbaidschanisch" ;
$out_languages {"ba"} = "Baschkirisch" ;
$out_languages {"bar"} = "Bairisch" ;
$out_languages {"be"} = "Weissrussisch" ;
$out_languages {"bg"} = "Bulgarisch" ;
$out_languages {"bo"} = "Tibetisch" ;
$out_languages {"br"} = "Bretonisch" ;
$out_languages {"bs"} = "Bosnisch" ;
$out_languages {"ca"} = "Katalanisch" ;
$out_languages {"co"} = "Korsisch" ;
$out_languages {"cs"} = "Tschechisch" ;
$out_languages {"csb"} = "Kaschubisch" ;
$out_languages {"da"} = "D&auml;nisch" ;
$out_languages {"de"} = "Deutsch" ;
$out_languages {"el"} = "Griechisch" ;
$out_languages {"en"} = "English" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Spanisch" ;
$out_languages {"et"} = "Estnisch" ;
$out_languages {"eu"} = "Baskisch" ;
$out_languages {"fa"} = "Persisch" ;
$out_languages {"fi"} = "Finnisch" ;
$out_languages {"fr"} = "Franz&ouml;sisch" ;
$out_languages {"fy"} = "Friesisch" ;
$out_languages {"ga"} = "Irisch" ;
$out_languages {"gl"} = "Galizisch" ;
$out_languages {"got"} = "Gotisch" ;
$out_languages {"haw"} = "Hawaiianisch" ;
$out_languages {"he"} = "Hebr&auml;isch" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Kroatisch" ;
$out_languages {"ht"} = "Haitisch" ;
$out_languages {"hu"} = "Ungarisch" ;
$out_languages {"hy"} = "Armenisch" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"id"} = "Indonesisch" ;
$out_languages {"is"} = "Isl&auml;ndisch" ;
$out_languages {"it"} = "Italienisch" ;
$out_languages {"ja"} = "Japanisch" ;
$out_languages {"jv"} = "Javanisch" ;
$out_languages {"ka"} = "Georgisch" ;
$out_languages {"kk"} = "Kasachisch" ;
$out_languages {"kl"} = "Gr&ouml;nl&auml;ndisch" ;
$out_languages {"km"} = "Kambodschanisch" ;
$out_languages {"ko"} = "Koreanisch" ;
$out_languages {"ksh"} = "Ripuarisch" ;
$out_languages {"ku"} = "Kurdisch" ;
$out_languages {"ky"} = "Kirgisisch" ;
$out_languages {"la"} = "Latein" ;
$out_languages {"lad"} = "Ladinisch" ;
$out_languages {"lb"} = "Luxemburgisch" ;
$out_languages {"li"} = "Limburgerisch" ;
$out_languages {"lij"} = "Ligurisch" ;
$out_languages {"lmo"} = "Lombardisch" ;
$out_languages {"lo"} = "Laotisch" ;
$out_languages {"lt"} = "Litauisch" ;
$out_languages {"lv"} = "Lettisch" ;
$out_languages {"mk"} = "Mazedonisch" ;
$out_languages {"mn"} = "Mongolisch" ;
$out_languages {"mo"} = "Moldawisch" ;
$out_languages {"ms"} = "Malaiisch" ;
$out_languages {"mt"} = "Maltesisch" ;
$out_languages {"nap"} = "Neapolitanisch" ;
$out_languages {"nds"} = "Nieders&auml;chsisch" ;
$out_languages {"nds-nl"} = "Nieders&auml;chsisch (NL)" ;
$out_languages {"nds_nl"} = "Nieders&auml;chsisch (NL)" ;
$out_languages {"ne"} = "Nepalisch" ;
$out_languages {"nl"} = "Niederl&auml;ndisch" ;
$out_languages {"nn"} = "Norwegisch (Nynorsk)" ;
$out_languages {"no"} = "Norwegisch" ;
$out_languages {"oc"} = "Okzitanisch" ;
$out_languages {"os"} = "Ossetisch" ;
$out_languages {"pl"} = "Polnisch" ;
$out_languages {"pms"} = "Piemontesisch" ;
$out_languages {"pt"} = "Portugiesisch" ;
$out_languages {"rm"} = "R&auml;toromanisch" ;
$out_languages {"ro"} = "Rum&auml;nisch" ;
$out_languages {"ru"} = "Russisch" ;
$out_languages {"ru_sib"} = "Sibirisch" ;
$out_languages {"sa"} = "Sanskrit" ;
$out_languages {"sc"} = "Sardisch" ;
$out_languages {"scn"} = "Sizilianisch" ;
$out_languages {"sco"} = "Schottisch" ;
$out_languages {"sh"} = "Serbokroatisch" ;
$out_languages {"simple"} = "Vereinfachtes&nbsp;Englisch" ;
$out_languages {"sk"} = "Slowakisch" ;
$out_languages {"sl"} = "Slowenisch" ;
$out_languages {"sq"} = "Albanisch" ;
$out_languages {"sr"} = "Serbisch" ;
$out_languages {"sv"} = "Schwedisch" ;
$out_languages {"ta"} = "Tamilisch" ;
$out_languages {"th"} = "Thail&auml;ndisch" ;
$out_languages {"tk"} = "Turkmenisch" ;
$out_languages {"tlh"} = "Klingonisch" ;
$out_languages {"tr"} = "T&uuml;rkisch" ;
$out_languages {"ug"} = "Uigurisch" ;
$out_languages {"uk"} = "Ukrainisch" ;
$out_languages {"uz"} = "Usbekisch" ;
$out_languages {"vi"} = "Vietnamesisch" ;
$out_languages {"wa"} = "Wallonisch" ;
$out_languages {"xal"} = "Kalmückisch" ;
$out_languages {"yi"} = "Yiddisch" ;
$out_languages {"zh"} = "Chinesisch" ;
$out_languages {"zh_classical"} = "Klassisches&nbsp;Chinesisch" ;
$out_languages {"zh_min_nan"} = "Minnan" ;
$out_languages {"zh_yue"} = "Kantonesisch" ;
$out_languages {"zu"} = "Zulu" ;
$out_languages {"zz"} = "Alle&nbsp;Sprachen" ;
}

1;

