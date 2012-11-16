#!/usr/bin/perl

sub SetLiterals_RO # replace by language code
{
$out_statistics   = "Statistici Wikipedia" ;
$out_charts       = "Grafice Wikipedia" ;
$out_btn_tables   = "Tabele" ;
$out_btn_table    = "Tabel" ; # new singular OK ?
$out_btn_charts   = "Grafice" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipedii" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary   = "Wik&#355;ionar" ;  # new
$out_wiktionaries = "Wik&#355;ionari" ; # new OK ?
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

$out_comparisons  = "Compara&#355;ii" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generat pe " ;
$out_sqlfiles     = "De la filele de SQL dump de pe " ;
$out_version      = "Versiune de script:" ;
$out_author       = "Autor" ;
$out_mail         = "E-mail" ;
$out_site         = "Website" ;
$out_home         = "Acas&#259;" ;
$out_sitemap      = "Hart&#259; site";
$out_rendered     = "Charts rendered with " ; #new
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "Index to EasyTimeline charts per Wikipedia" ; # new
$out_categories   = "Category Overview per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "Kb" ;
$out_bytes        = "b" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Data" ;
$out_year         = "an" ;
$out_month        = "lun&#259;" ;
$out_mean         = "Medie" ;
$out_growth       = "Cre&#351;tere" ;
$out_total        = "Total" ;
$out_bars         = "Bare" ;
$out_zoom         = "Zoom" ; # new
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " convert&#259;ri (semi-)automate au fost aplicate." ;

$out_phaseIII     = "Numai Wikipediile care folosesc software-ul  <a href='http://www.mediawiki.org'>MediaWiki</a> sunt incluse." ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free)" ; # new
$out_rendering    = "Rendering.... Please wait" ; # new

$out_sort_order   = "Wikipediile &#238;n diferite limbi sunt organizate dup&#259;num&#259;rul de leg&#259;turi interne (f&#259;r&#259; pagini de redirectare)<br>" .
                    "Modul acesta pare cel mai cinstit pentru a compara efortul total, nu num&#259;rul actual de articole<br>" .
                    "Num&#259;rul de articole nu este at&#226;t de important dat fiind faptul ca multe Wikipedii con&#355;in articole foarte scurte,<br>" .
                    "iar altele con&#355;in mai pu&#355;ine articole, dar care sunt mai lungi &#351;i mai de calitate.<br>" .
                    "M&#259;rimea bazei de date depinde de sistemul de codificare (caracterele Unicode ocup&#259; mai mul&#355;i octe&#355;i) &#351;i <br>" .
                    "pe c&#226;t con&#355;inut poate fi reprezentat de un caracter (e.g. caracterele chinezesti reprezinta cuvinte &#238;ntregi).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "num&#259;rul mediu &#238;n lunile ar&#259;tate" ;
$out_growth_1     = "cre&#351;terea lunar&#259; medie &#238;n lunile ar&#259;tate" ;
$out_formula      = "formula" ;
$out_value        = "valoare" ;
$out_monthes      = "luni" ;
$out_skip_values  = "(Wikipedii cu valori < 10 nu sunt aratate)" ;

$out_history      = "Note: figurile pentru primele luni sunt prea joase. " .
                    "Istoria de revisii nu a fost &#238;ntotdeauna prezervat&#259; &#238;n primele luni." ;

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

$out_tbl1_intro   = "[[2]] Wikipedieni recent activi, " .
                    "ordona&#355;i dup&#259; num&#259;rul de contribu&#355;ii:" ;
$out_tbl1_intro2  = "only article edits are counted, not edits on discussion pages, etc" ; # new
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "Utilizator" ;
$out_tbl1_hdr2    = "Edit&#259;ri" ;
$out_tbl1_hdr3    = "Primul edit" ;
$out_tbl1_hdr4    = "Ultimul edit" ;
$out_tbl1_hdr5    = "data" ;
$out_tbl1_hdr6    = "acu c&#226;te<br>zile" ;
$out_tbl1_hdr7    = "total" ; # new
$out_tbl1_hdr8    = "last<br>30 days" ; # new
$out_tbl1_hdr9    = "rank" ; # new
$out_tbl1_hdr10   = "now" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Articole" ; # new
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "[[3]] Wikipedieni recent absen&#355;i, " .
                   "ordona&#355;i dup&#259; num&#259;rul de contribu&#355;ii:" ;

$out_tbl3_intro   = "Crestere &#238;n numarul de utilizatori &#238;nregistra&#355;i activi &#351;i activit&#259;&#355;ile lor" ;

$out_tbl3_hdr1a   = "Wikipedieni" ;
$out_tbl3_hdr1e   = "Articole" ;
$out_tbl3_hdr1l   = "Baza de date" ;
$out_tbl3_hdr1o   = "Legaturi" ;
$out_tbl3_hdr1t   = "Folosin&#355;&#259; zilnic&#259;" ;

# use &nbsp; (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(utilizatori &#238;nregistrati)" ;
$out_tbl3_hdr1e2  = "(nu incluz&#226;nd pagini de redirectare)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "noi" ;
$out_tbl3_hdr2c   = "edit&#259;ri" ;
$out_tbl3_hdr2e   = "num&#259;r" ;
$out_tbl3_hdr2f   = "noi<br>pe&nbsp;zi" ;
$out_tbl3_hdr2h   = "media" ;
$out_tbl3_hdr2j   = "mai&nbsp;mari&nbsp;de" ;
$out_tbl3_hdr2l   = "edit&#259;ri" ;
$out_tbl3_hdr2m   = "total" ;
$out_tbl3_hdr2n   = "cuvinte" ;
$out_tbl3_hdr2o   = "interne" ;
$out_tbl3_hdr2p   = "&#238;ntre-wiki" ;
$out_tbl3_hdr2q   = "imagini" ;
$out_tbl3_hdr2r   = "externe" ;
$out_tbl3_hdr2s   = "redirect&#259;ri" ;
$out_tbl3_hdr2t   = "cereri<br>de pagin&#259;" ;
$out_tbl3_hdr2u   = "vizite" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficial" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "edit&#259;ri" ;
$out_tbl3_hdr3i   = "octe&#355;i" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonymous users, ordered by number of contributions" ; # new
$out_table6_footer = "Alltogether %d edits were made by anonymous users, out of a total of %d edits (%.0f\%)" ; # new

$out_tbl5_intro   = "Vizitatori (statistice bazate pe <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>" .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>defini&#355;ii</font></a>, " .
                    "<a href=''><font color='#000088'>grafice</font></a>)" ;
$out_tbl5_hdr1a   = "Media pe zi" ;
$out_tbl5_hdr1e   = "Total lunar" ;
$out_tbl5_hdr2a   = "&#206;nregistr&#259;ri" ;
$out_tbl5_hdr2b   = "File" ;
$out_tbl5_hdr2c   = "Pagini" ;
$out_tbl5_hdr2d   = "Vizite" ;
$out_tbl5_hdr2e   = "Site-uri" ;
$out_tbl5_hdr2f   = "Kilobytes" ;
$out_tbl5_hdr2g   = "Vizite" ;
$out_tbl5_hdr2h   = "Pagini" ;
$out_tbl5_hdr2i   = "File" ;
$out_tbl5_hdr2j   = "&#206;nregistr&#259;ri" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Wikipedieni care au editat cel putin de 10 ori de c&#226;nd au venit",
"Cre&#351;tere &#238;n Wikipedieni care au editat cel putin de 10 ori de c&#226;nd au venit",
"Wikipedieni care au contribuit de 5 ori sau mai mult &#238;n luna asta",
"Wikipedieni care au contribuit de 100 de ori sau mai mult &#238;n luna asta",
"Articole care con&#355;in cel pu&#355;in o leg&#259;tur&#259; intern&#259;",
"Articole care con&#355;in cel pu&#355;in o leg&#259;tur&#259; intern&#259; &#351;i 200 de caractere de text citibil, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ne lu&#226;nd &#238;n considerare coduri HTML si wiki, leg&#259;turi ascunse, etc.<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(alte r&#226;nduri a tabelului sunt bazate pe num&#259;rul de articole oficial)",
"Articole noi pe zi &#238;n luna aceasta",
"Num&#259;rul mediu de reviziuni pe articol",
"M&#259;rimea medie a articolelor (&#238;n octe&#355;i)",
"Percentage of articles with at least 0.5 Kb readable text (see F)", # not translated
"Percentage of articles with at least 2 Kb readable text (see F)",   # not translated
"Edit&#259;ri &#238;n ultima lun&#259;, incluz&#226;nd redirect&#259;ri &#351;i edit&#259;ri de utilizatori ne&#238;nregistra&#355;i",
"M&#259;rimea combinat&#259; a tuturor alticolelor, incluz&#226;nd redirectari",
"Num&#259;rul total de cuvinte (excluz&#226;nd redirect&#259;ri, cod HTML &#351;i wiki, &#351;i leg&#259;turi ascunse)",
"Num&#259;rul total de leg&#259;turi interne, excluz&#226;nd redirect&#259;ri, cioturi &#351;i liste de leg&#259;turi",
"Num&#259;rul total de leg&#259;turi la Wikipedii &#238;n alte limbi",
"Num&#259;rul total de imagini prezentate",
"Num&#259;rul total a leg&#259;turilor externe",
"Num&#259;rul total de redirect&#259;ri",
"Cereri de pagin&#259; pe zi (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>defini&#355;ii</font></a>, bazat pe <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Vizite pe zi (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>defini&#355;ii</font></a>, bazat pe <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Data pentru ultimele luni"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedieni care au contribuit de 5 ori sau mai mult &#238;n .. (week) asta",
"Wikipedieni care au contribuit de 25 de ori sau mai mult &#238;n .. (week) asta",
) ;


$out_legend_daily_edits = "Edit&#259;ri pe zi (incluz&#226;nd redirect&#259;ri &#351;i edit&#259;ri de utilizatori ne&#238;nregistra&#355;i)" ;
$out_report_description_daily_edits = "Edit&#259;ri pe zi" ;
$out_report_description_edits       = "Edit&#259;ri pe lun&#259;/zi" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Contributori",
"Wikipedieni noi",
"Wikipedieni activi",
"Wikipedieni foarte activi",
"Num&#259;r de articole (oficial)",
"Num&#259;r de articole (alternativ)",
"Articole noi pe zi",
"Edit&#259;ri pe articol",
"Octe&#355;i pe articol",
"Articole peste 0.5 Kb",
"Articole peste 2 Kb",
"Edit&#259;ri pe lun&#259;",
"M&#259;rimea bazei de date",
"Cuvinte",
"Leg&#259;turi interne",
"Leg&#259;turi la Wikipedii",
"Imagini",
"Leg&#259;turi web (externe)",
"Redirect&#259;ri",
"Cereri de pagin&#259; pe zi",
"Vizite pe zi",
"Statistice generale"
) ;

# the full list is in WikiReports.pl
# this selection is for translators only
$out_languages {"ar"} = "Arab&#259;" ;
$out_languages {"bs"} = "Bosnian&#259;" ;
$out_languages {"my"} = "Burmez&#259;" ;
$out_languages {"zh"} = "Chinez&#259;" ;
$out_languages {"hr"} = "Croat&#259;" ;
$out_languages {"cs"} = "Ceh&#259;" ;
$out_languages {"da"} = "Danez&#259;" ;
$out_languages {"nl"} = "Olandez&#259;" ;
$out_languages {"en"} = "Englez&#259;" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"et"} = "Estonian&#259;" ;
$out_languages {"fi"} = "Finlandez&#259;" ;
$out_languages {"fr"} = "Francez&#259;" ;
$out_languages {"fy"} = "Frizian&#259;" ;
$out_languages {"ka"} = "Georgian&#259;" ;
$out_languages {"de"} = "German&#259;" ;
$out_languages {"el"} = "Greac&#259;" ;
$out_languages {"hi"} = "Hindus&#259;" ;
$out_languages {"he"} = "Ebraic&#259;" ;
$out_languages {"hu"} = "Maghiar&#259;" ;
$out_languages {"id"} = "Indonezian&#259;" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"ga"} = "Irlandez&#259;" ;
$out_languages {"it"} = "Italian&#259;" ;
$out_languages {"ja"} = "Japonez&#259;" ;
$out_languages {"ko"} = "Corean&#259;" ;
$out_languages {"la"} = "Latin&#259;" ;
$out_languages {"lt"} = "Lituanian&#259;" ;
$out_languages {"ms"} = "Malaiezian&#259;" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"nn"} = "Norvegian&#259; (Nynorsk)" ;
$out_languages {"no"} = "Norvegian&#259;" ;
$out_languages {"fa"} = "Persan&#259;" ;
$out_languages {"pl"} = "Polonez&#259;" ;
$out_languages {"pt"} = "Portughez&#259;" ;
$out_languages {"ro"} = "Rom&#226;n&#259;" ;
$out_languages {"ru"} = "Rus&#259;" ;
$out_languages {"sr"} = "S&#226;rb&#259;" ;
$out_languages {"sh"} = "S&#226;rbo-Croat&#259;" ;
$out_languages {"es"} = "Spaniol&#259;" ;
$out_languages {"sv"} = "Suedez&#259;" ;
$out_languages {"th"} = "Tailandez&#259;" ;
$out_languages {"tr"} = "Turc&#259;" ;
$out_languages {"zz"} = "Toate&nbsp;limbile" ;
}

1;
