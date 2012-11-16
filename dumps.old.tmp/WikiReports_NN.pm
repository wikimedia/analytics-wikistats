#!/usr/bin/perl

# please specify all accented characters as html codes
# like &agrave; or $#224;
# do not edit with unicode editor, I will have to replace all unicode

# see for a list of codes
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_NN
{
$out_thousands_separator = "&nbsp;" ;
$out_decimal_separator   = "," ;

$out_statistics   = "Wikipedia-statistikk" ;
$out_charts       = "Wikipedia-diagram" ;
$out_btn_tables   = "Tabellar" ;
$out_btn_table    = "Tabell" ;
$out_btn_charts   = "Diagram" ;

$out_wikipedia       = "Wikipedia" ;
$out_wikipedias      = "Wikipediaar" ;
$out_wikipedians     = "wikipedians" ; # new

$out_wiktionary      = "Wikiordboka" ;
$out_wiktionaries    = "Wikiordb&oslash;ker" ;
$out_wiktionarians   = "wiktionarians" ; # new

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

$out_comparisons  = "Samanlikning" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generert den " ;
$out_sqlfiles     = "fr&aring; SQL-dump fr&aring; " ;
$out_version      = "Script version:" ;
$out_author       = "Author" ;
$out_mail         = "Mail" ;
$out_site         = "Webside" ;
$out_home         = "Nytt val" ;
$out_sitemap      = "Oversyn";
$out_rendered     = "Diagram rendra med " ;
$out_generated2   = "Annan statistikk:" ;
$out_easytimeline = "EasyTimeline-grafar" ;
$out_categories   = "Oversyn over kategoriar" ;
$out_index        = "Andre språk" ; # "other languages"
$out_complete     = "Detaljert" ; # "detailed"
$out_concise      = "Kompakt" ;
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "Kb" ;
$out_bytes        = "b" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Dato" ;
$out_year         = "&aring;r" ;
$out_month        = "m&aring;nad" ;
$out_mean         = "Snitt" ;
$out_growth       = "Vekst" ;
$out_total        = "Total" ;
$out_bars         = "S&oslash;yler" ;
$out_words        = "ord" ;
$out_zoom         = "Zoom" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " (halv-)automatisk konvertering er utf&oslash;rt." ;

$out_phaseIII     = "Berre wikipediaar som k&oslash;yrer <a href='http://www.mediawiki.org'>MediaWiki</a>-programvare er tekne med." ;

$out_svg_viewer   = "For &aring; sj&aring; innhaldet av denne sida treng du ein " .
                    "SVG-lesar, t.d. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (gratis)" ;
$out_rendering    = "Rendrar.... Gjer vel og vent" ;

$out_sort_order   = "Wikipediaane er sortert etter talet på interne kryssreferansar (minus omdirigeringar)<br/>" .
                    "Dette gjev eit betre mål på arbeidsmengda enn talet på artiklar eller storleiken på databasen:<br/>" .
                    "Somme wikipediaar inneheld svært mange korte artiklar med lite innhald,<br/>" .
                    "eller mange automatisk genererte artiklar, medan somme Wikipediaar har få, men lange og gode artiklar.<br/>" .
                    "Databasestorleik avhengar m.a. av teiknsett; unikode-bokstavteikn tek større plass enn ASCII-teikn,<br/>" .
                    "medan til dømes kinesiske databasar berre brukar eitt teikn pr. ord.<br/>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "snitt-tal over viste m&aring;nader" ;
$out_growth_1     = "snittvekst per m&aring;nad i viste m&aring;nader" ;
$out_formula      = "formel" ;
$out_value        = "verdi" ;
$out_monthes      = "m&aring;nader" ;
$out_skip_values  = "(Wikipediaar med mindre enn 10 er uteletne)" ;

$out_history      = "Merk: Tala for dei f&oslash;rste m&aring;nadene er for sm&aring;. " .
                    "Tidleg revisjonshistorikk er ikkje alltid tilgjengeleg." ;

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

$out_tbl1_intro   = "[[2]] nyleg aktive wikipedantar, " .
                    "sortert etter talet p&aring; bidrag:" ;
$out_tbl1_intro2  = "berre artikkelredigeringar tel, ikkje diskusjonar m.v." ;
$out_tbl1_intro3  = "&Delta; = endring i plassering siste 30 dagar" ;

$out_tbl1_hdr1    = "Brukar" ;
$out_tbl1_hdr2    = "Bidrag" ;
$out_tbl1_hdr3    = "F&oslash;rste bidrag" ;
$out_tbl1_hdr4    = "Siste bidrag" ;
$out_tbl1_hdr5    = "dato" ;
$out_tbl1_hdr6    = "dagar<br/>sidan" ;
$out_tbl1_hdr7    = "total" ;
$out_tbl1_hdr8    = "siste<br/>30 dagar" ;
$out_tbl1_hdr9    = "plassering" ;
$out_tbl1_hdr10   = "no" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Artiklar" ;
$out_tbl1_hdr13   = "Anna" ;

$out_tbl2_intro  = "[[3]] for tida inaktive wikipedantar, " .
                   "sortert etter talet p&aring; bidrag:" ;

$out_tbl3_intro   = "Vekst i talet på aktive wikipedantar, og aktivitetsniv&aring;" ;

$out_tbl3_hdr1a   = "Wikipedantar" ;
$out_tbl3_hdr1e   = "Artiklar" ;
$out_tbl3_hdr1l   = "Database" ;
$out_tbl3_hdr1o   = "Peikarar" ;
$out_tbl3_hdr1t   = "Snitt pr. dag" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registrerte&nbsp;brukarar)" ;
$out_tbl3_hdr1e2  = "(omdirigeringar uteletne)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "nye" ;
$out_tbl3_hdr2c   = "bidrag" ;
$out_tbl3_hdr2e   = "tal" ;
$out_tbl3_hdr2f   = "nye<br/>pr.&nbsp;dag" ;
$out_tbl3_hdr2h   = "snitt" ;
$out_tbl3_hdr2j   = "st&oslash;rre&nbsp;enn" ;
$out_tbl3_hdr2l   = "bidrag" ;
$out_tbl3_hdr2m   = "storleik" ;
$out_tbl3_hdr2n   = "ord" ;
$out_tbl3_hdr2o   = "internt" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "bilete" ;
$out_tbl3_hdr2r   = "eksterne" ;
$out_tbl3_hdr2s   = "omdirig-<BR/>eringar" ;
$out_tbl3_hdr2t   = "side-<br/>treff" ;
$out_tbl3_hdr2u   = "vitjarar" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "offisielt" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "bidrag" ;
$out_tbl3_hdr3i   = "byte" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonyme bidragsytarar, sortert etter talet p&aring; bidrag" ;
$out_table6_footer = "Til saman %d bidrag har kome fr&aring; anonyme bidragsytarar, av totalt %d bidrag (%.0f\%)" ;

$out_tbl5_intro   = "Vitjarstatistikk (basert p&aring; <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>-utputt ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definisjonar</font></a>, " .
                    "<a href=''><font color='#000088'>diagram</font></a>)" ;
$out_tbl5_hdr1a   = "Snitt pr. dag" ;
$out_tbl5_hdr1e   = "Totalt pr. m&aring;nad" ;
$out_tbl5_hdr2a   = "Treff" ;
$out_tbl5_hdr2b   = "Filer" ;
$out_tbl5_hdr2c   = "Sider" ;
$out_tbl5_hdr2d   = "Vitjarar" ;
$out_tbl5_hdr2e   = "Unike adresserom" ;
$out_tbl5_hdr2f   = "KByte" ;
$out_tbl5_hdr2g   = "Vitjarar" ;
$out_tbl5_hdr2h   = "Sider" ;
$out_tbl5_hdr2i   = "Filer" ;
$out_tbl5_hdr2j   = "Treff" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Wikipedantar med minst 10 bidrag",
"Auke i wikipedantar med minst 10 bidrag",
"Wikipedantar med 5 eller fleire bidrag denne m&aring;naden",
"Wikipedantar med 100 eller fleire bidrag denne m&aring;naden",
"Artiklar som inneheld minst &eacute;in intern kryssreferanse",
"Artiklar som inneheld minst &eacute;in intern kryssreferanse og 200 teikn med brødtekst,<br/>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;wikikodar, html-kodar, skjult tekst og overskrifter ikkje medrekna<br/>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(andre kolonner brukar den offisielle teljem&aring;ten)",
"Nye artiklar pr. dag den siste m&aring;naden",
"Revisjonar pr. artikkel, i snitt",
"Storleiken p&aring; kvar artikkel, i snitt",
"Artiklar som har minst 0,5 Kb lesbar tekst (sj&aring; F)",
"Artiklar som har minst 2,0 Kb lesbar tekst (sj&aring; F)",
"Bidrag siste m&aring;nad (inkl. omdirigeringar)",
"Alle artiklar samanlagt",
"Sum ord (omdirigeringar, html/wiki-kodar og skjult tekst ikkje medrekna)",
"Sum interne kryssreferansar (omdirigeringar, spirer og peikarlister ikkje medrekna)",
"Sum peikarar til wikipediaar p&aring; andre spr&aring;k",
"Sum bilete",
"Sum peikarar til verdsveven",
"Sum omdirigeringar",
"Treff pr. dag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definisjon</font></a>, basert p&aring; <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>-utputt)",
"Vitjande pr. dag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definisjon</font></a>, basert p&aring; <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>-utputt)",
"Data for siste m&aring;nader"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedantar med 5 eller fleire bidrag p&aring; ei veke",
"Wikipedantar med 25 eller fleire bidrag p&aring; ei veke"
) ;

$out_legend_daily_edits = "Bidrag pr. dag (inkl. omdirigeringar, inkl. uregistrerte bidragsytarar)" ;
$out_report_description_daily_edits = "Bidrag pr. dag" ;
$out_report_description_edits       = "Redigeringar pr. m&aring;nad/dag" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Bidragsytarar",
"Nye wikipedantar",
"Aktive wikipedantar",
"S&aelig;rs aktive wikipedantar",
"Offisielt artikkeltal",
"Alternativt artikkeltal",
"Nye artiklar pr. dag",
"Redigeringar pr. artikkel",
"Byte pr. artikkel",
"Artiklar over 0,5 Kb",
"Artiklar over 2,0 Kb",
"Redigeringar pr. m&aring;nad",
"Databasestorleik",
"Ord",
"Kryssreferansar internt i nynorsk-wikipediaen",
"Kryssreferansar til andre spr&aring;k",
"Bilete",
"Peikarar til verdsveven",
"Omdirigeringar",
"Aksessar pr. dag",
"Vitjande pr. dag",
"Oversyn"
) ;

# if you don't know all translation please mark untranslated ones

$out_languages {"aa"} = "afar" ;
$out_languages {"ab"} = "abkhasisk" ;
$out_languages {"af"} = "afrikaans" ;
$out_languages {"als"} = "sveitsartysk" ;
$out_languages {"am"} = "amharisk" ;
$out_languages {"an"} = "aragonesisk" ;
$out_languages {"ar"} = "arabisk" ;
$out_languages {"as"} = "assamesisk" ;
$out_languages {"ast"} = "asturisk" ;
$out_languages {"ay"} = "aymara" ;
$out_languages {"az"} = "aserbajdsjansk" ;
$out_languages {"ba"} = "basjkirsk" ;
$out_languages {"be"} = "kviterussisk" ;
$out_languages {"bg"} = "bulgarsk" ;
$out_languages {"bh"} = "bihari" ;
$out_languages {"bi"} = "bislama" ;
$out_languages {"bn"} = "bengali" ;
$out_languages {"bo"} = "tibetansk" ;
$out_languages {"br"} = "bretonsk" ;
$out_languages {"bs"} = "bosnisk" ;
$out_languages {"bug"} = "buginesisk" ;
$out_languages {"ca"} = "katalansk" ;
$out_languages {"co"} = "korsikansk" ;
$out_languages {"cs"} = "tsjekkisk" ;
$out_languages {"cy"} = "kymrisk" ;
$out_languages {"da"} = "dansk" ;
$out_languages {"de"} = "tysk" ;
$out_languages {"dz"} = "dzongkha" ;
$out_languages {"el"} = "gresk" ;
$out_languages {"en"} = "engelsk" ;
$out_languages {"eo"} = "esperanto" ;
$out_languages {"es"} = "spansk" ;
$out_languages {"et"} = "estisk" ;
$out_languages {"eu"} = "baskisk" ;
$out_languages {"fa"} = "farsi" ;
$out_languages {"fi"} = "finsk" ;
$out_languages {"fj"} = "fijiansk" ;
$out_languages {"fo"} = "f&aeligr&oslash;ysk" ;
$out_languages {"fr"} = "fransk" ;
$out_languages {"fy"} = "frisisk" ;
$out_languages {"ga"} = "irsk" ;
$out_languages {"gay"} = "gayo" ;
$out_languages {"gd"} = "skotsk-g&aelig;lisk" ;
$out_languages {"gl"} = "galisisk" ;
$out_languages {"gn"} = "guarani" ;
$out_languages {"gu"} = "gujarati" ;
$out_languages {"gv"} = "manx" ;
$out_languages {"ha"} = "hausa" ;
$out_languages {"he"} = "hebraisk" ;
$out_languages {"hi"} = "hindi" ;
$out_languages {"hr"} = "kroatisk" ;
$out_languages {"hu"} = "ungarsk" ;
$out_languages {"hy"} = "armensk" ;
$out_languages {"ia"} = "interlingua" ;
$out_languages {"iba"} = "iban" ;
$out_languages {"id"} = "indonesisk" ;
$out_languages {"ik"} = "inupiak" ;
$out_languages {"io"} = "ido" ;
$out_languages {"is"} = "islandsk" ;
$out_languages {"it"} = "italiensk" ;
$out_languages {"iu"} = "inuittisk" ;
$out_languages {"ja"} = "japansk" ;
$out_languages {"jv"} = "javanesisk" ;
$out_languages {"ka"} = "georgisk" ;
$out_languages {"kaw"} = "kawi" ;
$out_languages {"kk"} = "kasakhisk" ;
$out_languages {"kl"} = "gr&oslash;nlandsk" ;
$out_languages {"km"} = "kambodsjansk" ;
$out_languages {"kn"} = "kannada" ;
$out_languages {"ko"} = "koreansk" ;
$out_languages {"ks"} = "kasjmiri" ;
$out_languages {"ku"} = "kurdisk" ;
$out_languages {"ky"} = "kirgisisk" ;
$out_languages {"la"} = "latin" ;
$out_languages {"li"} = "limburgisk" ;
$out_languages {"ln"} = "lingala" ;
$out_languages {"lo"} = "laotisk" ;
$out_languages {"ls"} = "latino sine flexione" ;
$out_languages {"lt"} = "litauisk" ;
$out_languages {"lv"} = "latvisk" ;
$out_languages {"mad"} = "madurisk" ;
$out_languages {"mak"} = "makasar" ;
$out_languages {"mg"} = "gassisk" ;
$out_languages {"mi"} = "maori" ;
$out_languages {"mk"} = "makedonsk" ;
$out_languages {"ml"} = "malayalam" ;
$out_languages {"mn"} = "mongolsk" ;
$out_languages {"mo"} = "moldovsk" ;
$out_languages {"mr"} = "marathi" ;
$out_languages {"ms"} = "malayisk" ;
$out_languages {"my"} = "myanmarsk" ;
$out_languages {"na"} = "naurisk" ;
$out_languages {"nah"} = "nahuatl" ;
$out_languages {"nb"} = "bokm&aring;l" ;
$out_languages {"nds"} = "plattysk" ;
$out_languages {"ne"} = "gurkhali" ;
$out_languages {"nl"} = "nederlandsk" ;
$out_languages {"no"} = "norsk" ;
$out_languages {"nn"} = "nynorsk" ;
$out_languages {"oc"} = "proven&ccedil;alsk" ;
$out_languages {"om"} = "oromo" ;
$out_languages {"or"} = "oriya" ;
$out_languages {"pa"} = "panjabi" ;
$out_languages {"pl"} = "polsk" ;
$out_languages {"ps"} = "pashto" ;
$out_languages {"pt"} = "portugisisk" ;
$out_languages {"qu"} = "quechua" ;
$out_languages {"rm"} = "Retoromansk" ;
$out_languages {"rn"} = "kirundi" ;
$out_languages {"ro"} = "rumensk" ;
$out_languages {"ru"} = "russisk" ;
$out_languages {"rw"} = "rwandisk" ;
$out_languages {"sa"} = "sanskrit" ;
$out_languages {"sd"} = "sindi" ;
$out_languages {"sg"} = "sangro" ;
$out_languages {"sh"} = "serbokroatisk" ;
$out_languages {"si"} = "singhalesisk" ;
$out_languages {"simple"} = "Simple&nbsp;English" ;
$out_languages {"sk"} = "slovakisk" ;
$out_languages {"sl"} = "slovensk" ;
$out_languages {"sm"} = "samoansk" ;
$out_languages {"sn"} = "shona" ;
$out_languages {"sq"} = "albansk" ;
$out_languages {"sr"} = "serbisk" ;
$out_languages {"ss"} = "swazi" ;
$out_languages {"st"} = "sesotho" ;
$out_languages {"su"} = "sudansk" ;
$out_languages {"sv"} = "svensk" ;
$out_languages {"sw"} = "swahili" ;
$out_languages {"ta"} = "tamil" ;
$out_languages {"te"} = "telugu" ;
$out_languages {"tg"} = "tadsjikisk" ;
$out_languages {"th"} = "thai" ;
$out_languages {"ti"} = "tigrinja" ;
$out_languages {"tk"} = "turkmensk" ;
$out_languages {"tl"} = "tagalog" ;
$out_languages {"tn"} = "setswana" ;
$out_languages {"to"} = "tongansk" ;
$out_languages {"tr"} = "tyrkisk" ;
$out_languages {"ts"} = "tsonga" ;
$out_languages {"tt"} = "tatarisk" ;
$out_languages {"tw"} = "twi" ;
$out_languages {"ug"} = "uigurisk" ;
$out_languages {"uk"} = "ukrainsk" ;
$out_languages {"ur"} = "urdu" ;
$out_languages {"uz"} = "usbekisk" ;
$out_languages {"vi"} = "vietnamesisk" ;
$out_languages {"vo"} = "volapyk" ;
$out_languages {"wa"} = "valonsk" ;
$out_languages {"wo"} = "wolof" ;
$out_languages {"yi"} = "jiddisch" ;
$out_languages {"yo"} = "joruba" ;
$out_languages {"za"} = "zhuang" ;
$out_languages {"zh"} = "kinesisk" ;
$out_languages {"zu"} = "zulu" ;
$out_languages {"zz"} = "alle&nbsp;spr&aring;k" ;
}

# end of file marker, do not remove:
1;

