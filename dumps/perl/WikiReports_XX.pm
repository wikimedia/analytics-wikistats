#!/usr/bin/perl

# please specify all accented characters as utf-8 or
# as html codes like &agrave; or $#224;
# see for a list of html codes see
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_XX # replace by language code
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Wikipedia Statistics" ;
$out_charts       = "Wikipedia Charts" ;
$out_btn_tables   = "Tables" ;
$out_btn_table    = "Table" ;
$out_btn_charts   = "Charts" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipedias" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary   = "Wiktionary" ;
$out_wiktionaries = "Wiktionaries" ;
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

$out_comparisons  = "Comparisons" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generated on " ;
$out_sqlfiles     = "from the SQL dump files of " ;
$out_version      = "Script version:" ;
$out_author       = "Author" ;
$out_mail         = "Mail" ;
$out_site         = "Website" ;
$out_home         = "Home" ;
$out_sitemap      = "Sitemap";
$out_rendered     = "Charts rendered with " ;
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "Index to EasyTimeline charts per Wikipedia" ; # new
$out_categories   = "Category Overview per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "GB" ;
$out_megabytes    = "MB" ;
$out_kilobytes    = "kB" ;
$out_bytes        = "B" ;
$out_million      = "M" ;
$out_thousand     = "k" ;

$out_date         = "Date" ;
$out_year         = "year" ;
$out_month        = "month" ;
$out_mean         = "Mean" ;
$out_growth       = "Growth" ;
$out_total        = "Total" ;
$out_bars         = "Bars" ;
$out_words        = "words" ;
$out_zoom         = "Zoom" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " (semi-)automatic conversions have been applied." ;

$out_phaseIII     = "Only Wikipedia's that run on <a href='http://www.mediawiki.org'>MediaWiki</a> software are included." ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free)" ;
$out_rendering    = "Rendering.... Please wait" ;

$out_sort_order   = "Wikipedias are ordered by number of internal links (excl. redirects)<br>" .
                    "This seems a fairer base for comparing the total effort than either number of articles or database size:<br>" .
                    "Number of articles is not so meaningful given the fact that some Wikipedias contain mainly short articles,<br>" .
                    "or even many automatically generated articles, while other Wikipedias contain less but much longer articles, all handwritten.<br>" .
                    "Database size depends on coding system (unicode characters take several bytes) and <br>" .
                    "on how much meaning can be conveyed by one character (e.g. Chinese characters are whole words).<br>" ;

$out_webalizer_note = "Note: Webalizer data are not consistently available. Low figures for Dec 2003 are result of major server outage." ;
$out_not_included = "Not included" ; #new

$out_average_1    = "average counts over shown monthes" ;
$out_growth_1     = "average monthly growth over shown monthes" ;
$out_formula      = "formula" ;
$out_value        = "value" ;
$out_monthes      = "monthes" ;
$out_skip_values  = "(Wikipedia's with value(s) < 10 are skipped)" ;

$out_history      = "Note: figures for first monthes are too low. " .
                    "Revision history was not always preserved in early days." ;

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

$out_tbl1_intro   = "[[2]] recently active wikipedians, " .
                    "ordered by number of contributions:" ;
$out_tbl1_intro2  = "only article edits are counted, not edits on discussion pages, etc" ;
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ;

$out_tbl1_hdr1    = "User" ;
$out_tbl1_hdr2    = "Edits" ;
$out_tbl1_hdr3    = "First edit" ;
$out_tbl1_hdr4    = "Last edit" ;
$out_tbl1_hdr5    = "date" ;
$out_tbl1_hdr6    = "days<br>ago" ;
$out_tbl1_hdr7    = "total" ;
$out_tbl1_hdr8    = "last<br>30 days" ;
$out_tbl1_hdr9    = "rank" ;
$out_tbl1_hdr10   = "now" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Articles" ;
$out_tbl1_hdr13   = "Other" ;

$out_tbl2_intro  = "[[3]] recently absent wikipedians, " .
                   "ordered by number of contributions:" ;

$out_tbl3_intro   = "Growth in number of registered active wikipedians and their activity" ;

$out_tbl3_hdr1a   = "Wikipedians" ;
$out_tbl3_hdr1e   = "Articles" ;
$out_tbl3_hdr1l   = "Database" ;
$out_tbl3_hdr1o   = "Links" ;
$out_tbl3_hdr1t   = "Daily Usage" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registered users)" ;
$out_tbl3_hdr1e2  = "(excl. redirects)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "new" ;
$out_tbl3_hdr2c   = "edits" ;
$out_tbl3_hdr2e   = "count" ;
$out_tbl3_hdr2f   = "new<br>per&nbsp;day" ;
$out_tbl3_hdr2h   = "mean" ;
$out_tbl3_hdr2j   = "larger&nbsp;than" ;
$out_tbl3_hdr2l   = "edits" ;
$out_tbl3_hdr2m   = "size" ;
$out_tbl3_hdr2n   = "words" ;
$out_tbl3_hdr2o   = "internal" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "image" ;
$out_tbl3_hdr2r   = "external" ;
$out_tbl3_hdr2s   = "redirects" ;
$out_tbl3_hdr2t   = "page<br>requests" ;
$out_tbl3_hdr2u   = "visits" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "official" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "edits" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonymous users, ordered by number of contributions" ;
$out_table6_footer = "Alltogether %d edits were made by anonymous users, out of a total of %d edits (%.0f\%)" ;

$out_tbl5_intro   = "Visitor statistics (based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definitions</font></a>, " .
                    "<a href=''><font color='#000088'>chart</font></a>)" ;
$out_tbl5_hdr1a   = "Daily Average" ;
$out_tbl5_hdr1e   = "Monthly Totals" ;
$out_tbl5_hdr2a   = "Hits" ;
$out_tbl5_hdr2b   = "Files" ;
$out_tbl5_hdr2c   = "Pages" ;
$out_tbl5_hdr2d   = "Visits" ;
$out_tbl5_hdr2e   = "Sites" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "Visits" ;
$out_tbl5_hdr2h   = "Pages" ;
$out_tbl5_hdr2i   = "Files" ;
$out_tbl5_hdr2j   = "Hits" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ;

@out_tbl3_legend  = (
"Wikipedians who edited at least 10 times since they arrived",
"Increase in wikipedians who edited at least 10 times since they arrived",
"Wikipedians who contributed 5 times or more in this month",
"Wikipedians who contributed 100 times or more in this month",
"Articles that contain at least one internal link",
"Articles that contain at least one internal link and 200 characters readable text, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;disregarding wiki- and html codes, hidden links, etc.; also headers do not count<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(other columns are based on the official count method)",
"New articles per day in past month",
"Mean number of revisions per article",
"Mean size of article in bytes",
"Percentage of articles with at least 0.5 Kb readable text (see F)",
"Percentage of articles with at least 2 Kb readable text (see F)",
"Edits in past month (incl. redirects, incl. unregistered contributors)",
"Combined size of all articles (incl. redirects)",
"Total number of words (excl. redirects, html/wiki codes and hidden links)",
"Total number of internal links (excl. redirects, stubs and link lists)",
"Total number of links to other Wikipedias",
"Total number of images presented",
"Total number of links to other sites",
"Total number of redirects",
"Page requests per day (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Visits per day (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Data for last months"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedians who contributed 5 times or more in a week",
"Wikipedians who contributed 25 times or more in a week"
) ;

$out_legend_daily_edits = "Edits per day (incl. redirects, incl. unregistered contributors)" ;
$out_report_description_daily_edits = "Edits per day" ;
$out_report_description_edits       = "Edits per month/day" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Contributors",
"New wikipedians",
"Active wikipedians",
"Very active wikipedians",
"Article count (official)",
"Article count (alternate)",
"New articles per day",
"Edits per article",
"Bytes per article",
"Articles over 0.5 Kb",
"Articles over 2 Kb",
"Edits per month",
"Database size",
"Words",
"Internal links",
"Links to other Wikipedias",
"Images",
"Weblinks",
"Redirects",
"Page requests per day",
"Visits per day",
"Overview"
) ;

# if you don't know all translation please mark untranslated ones

$out_languages {"aa"} = "Afar" ;
$out_languages {"ab"} = "Abkhazian" ;
$out_languages {"af"} = "Afrikaans" ;
$out_languages {"ak"} = "Akana" ;
$out_languages {"als"} = "Elsatian" ;
$out_languages {"am"} = "Amharic" ;
$out_languages {"an"} = "Aragonese" ;
$out_languages {"ang"} = "Anglo-Saxon" ;
$out_languages {"ar"} = "Arabic" ;
$out_languages {"as"} = "Assamese" ;
$out_languages {"ast"} = "Asturian" ;
$out_languages {"av"} = "Avienan" ;
$out_languages {"ay"} = "Aymara" ;
$out_languages {"az"} = "Azerbaijani" ;
$out_languages {"ba"} = "Bashkir" ;
$out_languages {"be"} = "Belarussian" ;
$out_languages {"bg"} = "Bulgarian" ;
$out_languages {"bh"} = "Bihari" ;
$out_languages {"bi"} = "Bislama" ;
$out_languages {"bn"} = "Bengali" ;
$out_languages {"bo"} = "Tibetan" ;
$out_languages {"br"} = "Breton" ;
$out_languages {"bs"} = "Bosnian" ;
$out_languages {"bug"} = "Buginese" ;
$out_languages {"ca"} = "Catalan" ;
$out_languages {"ch"} = "Chamoru" ;
$out_languages {"cho"} = "Chotaw" ;
$out_languages {"co"} = "Corsican" ;
$out_languages {"cr"} = "Cree" ;
$out_languages {"cs"} = "Czech" ;
$out_languages {"cy"} = "Welsh" ;
$out_languages {"da"} = "Danish" ;
$out_languages {"de"} = "German" ;
$out_languages {"dv"} = "Divehi" ;
$out_languages {"dz"} = "Dzongkha" ;
$out_languages {"ee"} = "Ewe" ;
$out_languages {"el"} = "Greek" ;
$out_languages {"en"} = "English" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Spanish" ;
$out_languages {"et"} = "Estonian" ;
$out_languages {"eu"} = "Basque" ;
$out_languages {"fa"} = "Persian" ;
$out_languages {"fi"} = "Finnish" ;
$out_languages {"fj"} = "Fijian" ;
$out_languages {"fo"} = "Faeroese" ;
$out_languages {"fr"} = "French" ;
$out_languages {"fy"} = "Frisian" ;
$out_languages {"ga"} = "Irish" ;
$out_languages {"gay"} = "Gayo" ;
$out_languages {"gd"} = "Scottish Gaelic" ;
$out_languages {"gl"} = "Galego" ;
$out_languages {"gn"} = "Guarani" ;
$out_languages {"got"} = "Gothic" ;
$out_languages {"gu"} = "Gujarati" ;
$out_languages {"gv"} = "Manx Gaelic" ;
$out_languages {"ha"} = "Hausa" ;
$out_languages {"haw"} = "Hawaiian" ;
$out_languages {"he"} = "Hebrew" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Croatian" ;
$out_languages {"ht"} = "Haitian" ;
$out_languages {"hu"} = "Hungarian" ;
$out_languages {"hy"} = "Armenian" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"iba"} = "Iban" ;
$out_languages {"id"} = "Indonesian" ;
$out_languages {"ik"} = "Inupiak" ;
$out_languages {"io"} = "Ido" ;
$out_languages {"is"} = "Icelandic" ;
$out_languages {"it"} = "Italian" ;
$out_languages {"iu"} = "Inuktitut" ;
$out_languages {"ja"} = "Japanese" ;
$out_languages {"jv"} = "Javanese" ;
$out_languages {"ka"} = "Georgian" ;
$out_languages {"kaw"} = "Kawi" ;
$out_languages {"kk"} = "Kazakh" ;
$out_languages {"kl"} = "Greenlandic" ;
$out_languages {"km"} = "Cambodian" ;
$out_languages {"kn"} = "Kannada" ;
$out_languages {"ko"} = "Korean" ;
$out_languages {"ks"} = "Kashmiri" ;
$out_languages {"ku"} = "Kurdish" ;
$out_languages {"ky"} = "Kirghiz" ;
$out_languages {"la"} = "Latin" ;
$out_languages {"lb"} = "Letzeburgesch" ;
$out_languages {"li"} = "Limburguish" ;
$out_languages {"ln"} = "Lingala" ;
$out_languages {"lo"} = "Laotian" ;
$out_languages {"ls"} = "Latino Sine Flexione" ;
$out_languages {"lt"} = "Lithuanian" ;
$out_languages {"lv"} = "Latvian" ;
$out_languages {"mad"} = "Madurese" ;
$out_languages {"mak"} = "Makasar" ;
$out_languages {"mg"} = "Malagasy" ;
$out_languages {"mi"} = "Maori" ;
$out_languages {"mk"} = "Macedonian" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"mn"} = "Mongolian" ;
$out_languages {"mo"} = "Moldavian" ;
$out_languages {"mr"} = "Marathi" ;
$out_languages {"ms"} = "Malay" ;
$out_languages {"mt"} = "Maltese" ;
$out_languages {"mus"} = "Muskogee" ;
$out_languages {"my"} = "Burmese" ;
$out_languages {"na"} = "Nauru" ;
$out_languages {"nah"} = "Nahuatl" ;
$out_languages {"nds"} = "Low Saxon" ;
$out_languages {"ne"} = "Nepali" ;
$out_languages {"nl"} = "Dutch" ;
$out_languages {"nn"} = "Norwegian (Nynorsk)" ;
$out_languages {"no"} = "Norwegian" ;
$out_languages {"nv"} = "Navayo" ;
$out_languages {"oc"} = "Occitan" ;
$out_languages {"om"} = "Oromo" ;
$out_languages {"or"} = "Oriya" ;
$out_languages {"pa"} = "Punjabi" ;
$out_languages {"pl"} = "Polish" ;
$out_languages {"ps"} = "Pashto" ;
$out_languages {"pt"} = "Portuguese" ;
$out_languages {"qu"} = "Quechua" ;
$out_languages {"rm"} = "Rhaeto-Romance" ;
$out_languages {"rn"} = "Kirundi" ;
$out_languages {"ro"} = "Romanian" ;
$out_languages {"roa_rup"} = "Aromanian" ;
$out_languages {"ru"} = "Russian" ;
$out_languages {"rw"} = "Kinyarwanda" ;
$out_languages {"sa"} = "Sanskrit" ;
$out_languages {"sc"} = "Sardinian" ;
$out_languages {"scn"} = "Sicilian" ;
$out_languages {"sd"} = "Sindhi" ;
$out_languages {"se"} = "Northern Sami" ;
$out_languages {"sg"} = "Sangro" ;
$out_languages {"sh"} = "Serbo-Croatian" ;
$out_languages {"si"} = "Singhalese" ;
$out_languages {"simple"} = "Simple&nbsp;English" ;
$out_languages {"sk"} = "Slovak" ;
$out_languages {"sl"} = "Slovene" ;
$out_languages {"sm"} = "Samoan" ;
$out_languages {"sn"} = "Shona" ;
$out_languages {"so"} = "Somalian" ;
$out_languages {"sq"} = "Albanian" ;
$out_languages {"sr"} = "Serbian" ;
$out_languages {"ss"} = "Siswati" ;
$out_languages {"st"} = "Seshoto" ;
$out_languages {"su"} = "Sundanese" ;
$out_languages {"sv"} = "Swedish" ;
$out_languages {"sw"} = "Swahili" ;
$out_languages {"ta"} = "Tamil" ;
$out_languages {"te"} = "Telugu" ;
$out_languages {"tg"} = "Tajik" ;
$out_languages {"th"} = "Thai" ;
$out_languages {"ti"} = "Tigrinya" ;
$out_languages {"tk"} = "Turkmen" ;
$out_languages {"tl"} = "Tagalog" ;
$out_languages {"tn"} = "Setswana" ;
$out_languages {"to"} = "Tonga" ;
$out_languages {"tr"} = "Turkish" ;
$out_languages {"ts"} = "Tsonga" ;
$out_languages {"tt"} = "Tatar" ;
$out_languages {"tw"} = "Twi" ;
$out_languages {"ty"} = "Tahitian" ;
$out_languages {"ug"} = "Uighur" ;
$out_languages {"uk"} = "Ukrainian" ;
$out_languages {"ur"} = "Urdu" ;
$out_languages {"uz"} = "Uzbek" ;
$out_languages {"vi"} = "Vietnamese" ;
$out_languages {"vo"} = "Volap&uuml;k" ;
$out_languages {"wa"} = "Walloon" ;
$out_languages {"wo"} = "Wolof" ;
$out_languages {"yi"} = "Yiddish" ;
$out_languages {"yo"} = "Yoruba" ;
$out_languages {"za"} = "Zhuang" ;
$out_languages {"zh"} = "Chinese" ;
$out_languages {"zh_min_nan"} = "Minnan" ;
$out_languages {"zu"} = "Zulu" ;
$out_languages {"zz"} = "All&nbsp;languages" ;
}

my @weekdays_en = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

my @months_en   = qw (January February March April May June July
                      August September October November December);

my @months_en   = qw (Jan Feb Mar Apr May Jun Jul
                      Aug Sep Oct Nov Dec);

# please also give example of whole date
# different languages use different styles like :

# August 18, 2003
# 18 augustus 2003

# end of file marker, do not remove:
1;

