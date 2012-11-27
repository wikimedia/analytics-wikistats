#!/usr/bin/perl

sub SetLiterals_DA
{
$out_statistics      = "Wikipedia Statistik" ;
$out_charts          = "Wikipedia Diagrammer" ;
$out_btn_tables      = "Tabeller" ;
$out_btn_table       = "Tabell" ; # new singular OK ?
$out_btn_charts      = "Diagrammer" ;

$out_wikipedia       = "Wikipedia" ;
$out_wikipedias      = "Wikipediaer" ;
$out_wikipedians     = "wikipedians" ; # new

$out_wiktionary      = "Wikiordborg" ;
$out_wiktionaries    = "Wikiordborger" ; # plural ??
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

$out_comparisons     = "Sammenligninger" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Genereret " ;
$out_sqlfiles     = "med et SQL dump fra " ;
$out_version      = "Script version:" ;
$out_author       = "Forfatter" ;
$out_mail         = "Mail" ;
$out_site         = "Webside" ;
$out_home         = "Hjem" ;
$out_sitemap      = "Indholdsfortegnelse";
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

$out_date         = "Dato" ;
$out_year         = "&aring;r" ;
$out_month        = "m&aring;ned" ;
$out_mean         = "Gennemsnit" ;
$out_growth       = "V&aelig;kst" ;
$out_total        = "Total" ;
$out_bars         = "S&oslash;jler" ;
$out_words        = "ord" ;
$out_zoom         = "Zoom" ; # new
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "Der er blevet lavet " ;
$out_conversions2 = " (halv-)automatiske konverteringer." ;

$out_phaseIII     = "Kun Wikipediaer der k&oslash;rer p&aring; <a href='http://www.mediawiki.org'>MediaWiki</a> software er medtaget." ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free)" ; # new
$out_rendering    = "Rendering.... Please wait" ; # new

$out_sort_order   = "Wikipediaerne er sorteret efter antallet af interne links (excl. omdirigeringer)<br>" .
                    "Dette forekommer at v&aelig;re en mere retf&aelig;rdig m&aring;de at sammenligne p&aring; end " .
                    "antallet af artikler eller st&oslash;rrelsen af databasen:<br>" .
                    "Antallet af artikler er ikke altid nogen god m&aring;lestok, fordi nogle Wikipediaer indeholder ".
                    "mange korte artikler,<br>" .
                    "eller endda automatisk genererede artikler, mens andre ".
                    "Wikipediaer indeholder f&aelig;rre men meget l&aelig;ngere artikler.<br>" .
                    "Database st&oslash;rrelsen afh&aelig;nger af hvilken bogstavkodning man bruger ".
                    "(unicode bogstaver bruger adskillige bytes hver) og <br>" .
                    "p&aring; hvor meget mening man kan putte ind i et enkelt tegn (kinesiske tegn er hele ord).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "gennemsnitlig opt&aelig;lling over de viste m&aring;neder" ;
$out_growth_1     = "gennemsnitlig m&aring;nedlig v&aelig;kst over de viste m&aring;neder" ;
$out_formula      = "formel" ;
$out_value        = "v&aelig;rdi" ;
$out_monthes      = "m&aring;neder" ;
$out_skip_values  = "(Wikipediaer med v&aelig;rdier < 10 er udeladt)" ;

$out_history      = "Note: tallene for de f&oslash;rste m&aring;neder er for lave. " .
                    "Atiklernes historie blev ikke altid gemt i den f&oslash;rste tid." ;

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

$out_tbl1_intro   = "[[2]] wikipedianere der har v&aelig;ret aktive for nylig, " .
                    "sorteret efter antallet af redigeringer:" ;
$out_tbl1_intro2  = "Only article edits are counted, not edits on discussion pages, etc" ; # new
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "Bruger" ;
$out_tbl1_hdr2    = "Redigeringer" ;
$out_tbl1_hdr3    = "F&oslash;rste redigering" ;
$out_tbl1_hdr4    = "Sidste redigering" ;
$out_tbl1_hdr5    = "dato" ;
$out_tbl1_hdr6    = "antal dage<br>siden" ;
$out_tbl1_hdr7    = "total" ; # new
$out_tbl1_hdr8    = "last<br>30 days" ; # new
$out_tbl1_hdr9    = "rank" ; # new
$out_tbl1_hdr10   = "now" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Artikler" ; # new
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "[[3]] wikipedianere der ikke l&aelig;ngere er aktive, " .
                   "sorteret efter antallet af redigeringer:" ;

$out_tbl3_intro   = "V&aelig;ksten i antallet af aktive registrerede brugere og deres aktivitet" ;

$out_tbl3_hdr1a   = "Wikipedianere" ;
$out_tbl3_hdr1e   = "Artikler" ;
$out_tbl3_hdr1l   = "Database" ;
$out_tbl3_hdr1o   = "Links" ;
$out_tbl3_hdr1t   = "Daglig brug" ;

# use &nbsp; (non breaking space) in stead of normal spaces in following
# headers; this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registrerede brugere)" ;
$out_tbl3_hdr1e2  = "(excl. omdirigeringer)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "nye" ;
$out_tbl3_hdr2c   = "redigeringer" ;
$out_tbl3_hdr2e   = "antal" ;
$out_tbl3_hdr2f   = "nye<br>pr&nbsp;dag" ;
$out_tbl3_hdr2h   = "gennemsnit" ;
$out_tbl3_hdr2j   = "st&oslash;rre&nbsp;end" ;
$out_tbl3_hdr2l   = "redigeringer" ;
$out_tbl3_hdr2m   = "st&oslash;rrelse" ;
$out_tbl3_hdr2n   = "ord" ;
$out_tbl3_hdr2o   = "interne" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "billeder" ;
$out_tbl3_hdr2r   = "eksterne" ;
$out_tbl3_hdr2s   = "omdirigeringer" ;
$out_tbl3_hdr2t   = "side<br>forsp&oslash;rgsler" ;
$out_tbl3_hdr2u   = "bes&oslash;g" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "officielt" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;bo" ;
$out_tbl3_hdr3h   = "redigeringer" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonymous users, ordered by number of contributions" ; # new
$out_table6_footer = "Alltogether %d edits were made by anonymous users, out of a total of %d edits (%.0f\%)" ; # new

# please tranlate 'Visitor statistics' 'definitions'
$out_tbl5_intro   = "Bes&oslash;gsstatistik (baseret p&aring; <a href='http://www.mrunix.net/webalizer/'>" .
                    "<font color='#000088'>Webalizer</font></a> output ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'>" .
                    "<font color='#000088'>definitioner</font></a>, " .
                    "<a href=''><font color='#000088'>diagram</font></a>)" ;
$out_tbl5_hdr1a   = "Dagligt gennemsnit" ;
$out_tbl5_hdr1e   = "Sammenlagt pr. m&acirc;ned" ;
$out_tbl5_hdr2a   = "Foresp&oslash;rgsler" ;
$out_tbl5_hdr2b   = "Filer" ;
$out_tbl5_hdr2c   = "Sider" ;
$out_tbl5_hdr2d   = "Bes&oslash;g" ;
$out_tbl5_hdr2e   = "Steder" ;
$out_tbl5_hdr2f   = "Kb" ;
$out_tbl5_hdr2g   = "Bes&oslash;g" ;
$out_tbl5_hdr2h   = "Sider" ;
$out_tbl5_hdr2i   = "Filer" ;
$out_tbl5_hdr2j   = "Foresp&oslash;rgsler" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Wikipedianere der har lavet mindst 10 redigeringer siden de ankom",
"V&aelig;kst i antallet af Wikipedianere der har lavet mindst 10 redigeringer siden de ankom",
"Wikipedianere der har lavet mindst 5 redigeringer i den sidste m&aring;ned",
"Wikipedianere der har lavet mindst 100 redigeringer i den sidste m&aring;ned",
"Artikler der indeholder mindst et internt link",
"Artikler der indeholder mindst et internt link og 200 bogstaver l&aelig;sbar tekst, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fratrukket wiki- og html koder, gemte links, osv.; " .
   "overskrifter t&aelig;ller heller ikke med<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(de andre s&oslash;jler er baseret p&aring; den " .
   "officielle t&aelig;llemetode)",
"Nye artikler pr dag i den sidste m&aring;ned",
"Gennemsnitligt antal redigeringer pr artikel",
"Gennemsnitlig st&oslash;rrelse af artikler i bytes",
"Procentdel af artikler der er st&oslash;rre end 0.5 Kb l&aelig;sbar tekst (ref F)",
"Procentdel af artikler der er st&oslash;rre end 2 Kb l&aelig;sbar tekst (ref F)",
"Redigeringer i den sidste m&aring;ned (inkl. omdirigeringer, inkl. uregistrerede brugere)",
"Samlet st&oslash;rrelse af alle artikler (inkl. omdirigeringer)",
"Totalt antal af ordene (excl. omdirigeringer, wiki- og html koder, gemte links)",
"Totalt antal af interne links (excl. omdirigeringer, sm&aring; artikler og lister af links)",
"Totalt antal af links til andre Wikipediaer",
"Totalt antal af viste billeder",
"Totalt antal af links til andre websider",
"Totalt antal af omdirigeringer",
"Foresp&oslash;rgsler pr dag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'>" .
    "<font color='#000088'>definition</font></a>, " .
    "baseret p&aring; <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)", #new
"Bes&oslash;g pr dag (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'>" .
    "<font color='#000088'>definition</font></a>, " .
    "based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)", # new
"Data for seneste m&aring;neder"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedianere der har lavet mindst 5 redigeringer i den sidste .. (week)", # new
"Wikipedianere der har lavet mindst 25 redigeringer i den sidste .. (week)", # new
) ;

$out_legend_daily_edits = "Redigeringer pr dag (inkl. omdirigeringer, inkl. uregistrerede brugere)" ;
$out_report_description_daily_edits = "Redigeringer pr dag" ;
$out_report_description_edits       = "Redigeringer pr m&aring;ned/dag" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Brugere",
"Nye wikipedianere",
"Aktive wikipedianere",
"Meget aktive wikipedianere",
"Antal artikler (officiel)",
"Antal artikler (alternativ)",
"Nye artikler pr dag",
"Redigeringer pr artikel",
"Bytes pr artikel",
"Artikler over 0.5 Kb",
"Artikler over 2 Kb",
"Redigeringer pr m&aring;ned",
"Database st&oslash;rrelse",
"Ordene",
"Interne links",
"Links til andre Wikipediaer",
"Billeder",
"Weblinks",
"Omdirigeringer",
"Foresp&oslash;rgsler pr dag",
"Bes&oslash;g  pr dag",
"Oversigt"
) ;

# the full list is in WikiReports.pl
# this selection is for translators only
$out_languages {"ar"} = "Arabisk" ;
$out_languages {"bs"} = "Bosnisk" ;
$out_languages {"my"} = "Burmesisk" ;
$out_languages {"zh"} = "Kinesisk" ;
$out_languages {"hr"} = "Kroatisk" ;
$out_languages {"cs"} = "Tjekkisk" ;
$out_languages {"da"} = "Dansk" ;
$out_languages {"nl"} = "Hollandsk" ;
$out_languages {"en"} = "Engelsk" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"et"} = "Estisk" ;
$out_languages {"fi"} = "Finsk" ;
$out_languages {"fr"} = "Fransk" ;
$out_languages {"fy"} = "Frisisk" ;
$out_languages {"ka"} = "Georgisk" ;
$out_languages {"de"} = "Tysk" ;
$out_languages {"el"} = "Gr&aelig;sk" ;
$out_languages {"hi"} = "Hindu" ;
$out_languages {"he"} = "Hebraisk" ;
$out_languages {"hu"} = "Ungarsk" ;
$out_languages {"id"} = "Indonesisk" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"ga"} = "Irsk" ;
$out_languages {"it"} = "Italiensk" ;
$out_languages {"ja"} = "Japansk" ;
$out_languages {"ko"} = "Koreansk" ;
$out_languages {"la"} = "Latin" ;
$out_languages {"lt"} = "Litauisk" ;
$out_languages {"ms"} = "Malaysisk" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"nn"} = "Norsk (Nynorsk)" ;
$out_languages {"no"} = "Norsk" ;
$out_languages {"fa"} = "Persisk" ;
$out_languages {"pl"} = "Polsk" ;
$out_languages {"pt"} = "Portugisisk" ;
$out_languages {"ro"} = "Rumansk" ;
$out_languages {"ru"} = "Russisk" ;
$out_languages {"sr"} = "Serbisk" ;
$out_languages {"sh"} = "Serbokroatisk" ;
$out_languages {"es"} = "Spansk" ;
$out_languages {"sv"} = "Svensk" ;
$out_languages {"th"} = "Thailandsk" ;
$out_languages {"tr"} = "Tyrkisk" ;
$out_languages {"zz"} = "Alle&nbsp;sprog" ;
}

1;


