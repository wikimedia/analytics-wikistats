#!/usr/bin/perl

# please specify all accented characters as html codes
# like &agrave; or $#224;
# do not edit with unicode editor, I will have to replace all unicode

# see for a list of codes
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_WA
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Sitatistikes Wikipedia" ;
$out_charts       = "Grafikes Wikipedia" ;
$out_btn_tables   = "T&aring;vleas" ;
$out_btn_table    = "T&aring;vlea" ;
$out_btn_charts   = "Grafikes" ;

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

$out_comparisons  = "Compar&aring;jhons" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Fwait li " ;
$out_sqlfiles     = "a p&aring;rti des fitch&icirc;s SQL do " ;
$out_version      = "Mod&ecirc;ye do scripe:" ;
$out_author       = "Oteur" ;
$out_mail         = "Emile" ;
$out_site         = "Waibe" ;
$out_home         = "P&aring;dje m&aring;jhon" ;
$out_sitemap      = "Mwaisse p&aring;dje";
$out_rendered     = "Grafikes dessin&eacute;s avou " ;
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "Index to EasyTimeline charts per Wikipedia" ; # new
$out_categories   = "Category Overview per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "Go" ;
$out_megabytes    = "Mo" ;
$out_kilobytes    = "Ko" ;
$out_bytes        = "o" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Date" ;
$out_year         = "an&ecirc;ye" ;
$out_month        = "moes" ;
$out_mean         = "Moyene" ;
$out_growth       = "Crexhaedje" ;
$out_total        = "Tot&aring;" ;
$out_bars         = "B&aring;res" ;
$out_words        = "mots" ;
$out_zoom         = "Zoum" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " kiviersaedjes (semi-)otomatikes ont st&icirc; fwaits." ;

$out_phaseIII     = "Seulmint les Wikipedias eployant <a href='http://www.mediawiki.org'>MediaWiki</a> sont cont&ecirc;yes." ;

$out_svg_viewer   = "Po vey les im&aring;djes di cisse p&aring;dje ci vos dvoz eploy&icirc; on " .
                    "h&aring;yneu SVG, eg: li <a href='http://www.adobe.com/svg/viewer/install/'>h&aring;yneu SVG d'&nbsp;Adobe</a> " .
                    "si vos eploy&icirc;z l'&nbsp;betchteu MS-Explorer po Win/Mac" ;
$out_rendering    = "Dessinaedje des grafikes.... T&aring;rdj&icirc;z ene miete s'&nbsp;i vs plait" ;

$out_sort_order   = "Les Wikipedias sont rel&icirc;s d'&nbsp;apr&egrave;s l'&nbsp;nombe di dvintrins loy&eacute;ns (fo&ucirc; redjiblaedjes)<br>" .
                    "&Ccedil;oula est motoit ene manire pus djusse di comparer les efoirts po f&eacute; viker on wikipedia ki d'&nbsp;conter li nombe d'&nbsp;&aring;rtikes ou l'&nbsp;grandeu del b&aring;ze di dn&ecirc;yes:<br>" .
                    "Li nombe d'&nbsp;artikes n'&nbsp;est n&eacute;n foirt significatif, ca des Wikipedias k'&nbsp;i gn a ont copurade des &aring;rtikes courts,<br>" .
                    "ou minme br&aring;mint d'&nbsp;&aring;rtikes fwaits otomaticmint, dismetant ki ds &ocirc;tes Wikipedias ont moens d'&nbsp;&aring;rtikes, mins b&eacute;n pus longous eyet scr&icirc;ts al mwin.<br>" .
                    "Li grandeu del b&aring;ze di dn&ecirc;yes depind do sistinme d'&nbsp;ec&ocirc;daedje (les caracteres unic&ocirc;de prind&egrave;t sacwants octets) eyet <br>" .
                    "del cwantit&eacute; d'&nbsp;inform&aring;cion dins on caractere (metans, les caracteres chinw&egrave;s pol&egrave;t rprezinter des mots etirs).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "nombe moy&eacute;n po les moes h&aring;yn&eacute;s" ;
$out_growth_1     = "crexhaedje moy&eacute;n par moes po les moes h&aring;yn&eacute;s" ;
$out_formula      = "formule" ;
$out_value        = "valixhance" ;
$out_monthes      = "moes" ;
$out_skip_values  = "(Les Wikipedias avou ene valixhance < 10 sont-st ignor&eacute;s)" ;

$out_history      = "Note: les valixhances po les tot prum&icirc;s moes pol&egrave;t esse trop ptites. " .
                    "A ciste epoke la, l'&nbsp;istwere des candjmints n'&nbsp;esteut n&eacute;n tofer w&aring;rd&ecirc;ye." ;

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

$out_tbl1_intro   = "[[2]] contribouweus actifs dierinnmint, " .
                    "rel&icirc;s pa nombe di contribouwaedjes:" ;
$out_tbl1_intro2  = "(seulmint les candjmints d'&nbsp;&aring;rtikes sont cont&eacute;s, n&eacute;n les candjmints des p&aring;djes di copene, evnd.)" ;
$out_tbl1_intro3  = "&Delta; = candjmint dins l'&nbsp;&ocirc;re dins les 30 dierins djo&ucirc;s" ;

$out_tbl1_hdr1    = "Uzeu" ;
$out_tbl1_hdr2    = "Contribouwaedjes" ;
$out_tbl1_hdr3    = "Prum&icirc; contribouwaedje" ;
$out_tbl1_hdr4    = "Dierin contribouwaedje" ;
$out_tbl1_hdr5    = "date" ;
$out_tbl1_hdr6    = "djo&ucirc;s" ;
$out_tbl1_hdr7    = "tot&aring;" ;
$out_tbl1_hdr8    = "30 dier.<br>djo&ucirc;s" ;
$out_tbl1_hdr9    = "&ocirc;re" ;
$out_tbl1_hdr10   = "asteure" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "&Aring;rtikes" ;
$out_tbl1_hdr13   = "&Ocirc;tes" ;

$out_tbl2_intro  = "[[3]] contribouweus ki n'&nbsp;sont n&eacute;n la dierinnmint, " .
                    "rel&icirc;s pa nombe di contribouwaedjes:" ;

$out_tbl3_intro   = "Crexhaedje do nombe di contribouweus actifs edj&icirc;str&eacute;s eyet leu-z acitivit&eacute;" ;

$out_tbl3_hdr1a   = "Wikipedyins" ;
$out_tbl3_hdr1e   = "&Aring;rtikes" ;
$out_tbl3_hdr1l   = "B&aring;ze di dn&ecirc;yes" ;
$out_tbl3_hdr1o   = "Loy&eacute;ns" ;
$out_tbl3_hdr1t   = "Eployaedjes par djo&ucirc;" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = " (uzeus&nbsp;dj&icirc;str&eacute;s)" ;
$out_tbl3_hdr1e2  = " (fo&ucirc; redjiblaedjes)" ;

$out_tbl3_hdr2a   = "tot&aring;" ;
$out_tbl3_hdr2b   = "noveas" ;
$out_tbl3_hdr2c   = "candjmints" ;
$out_tbl3_hdr2e   = "nombe" ;
$out_tbl3_hdr2f   = "noveas<br>par djo&ucirc;" ;
$out_tbl3_hdr2h   = "moyene" ;
$out_tbl3_hdr2j   = "pus grand ki" ;
$out_tbl3_hdr2l   = "candj." ;
$out_tbl3_hdr2m   = "grandeu" ;
$out_tbl3_hdr2n   = "mots" ;
$out_tbl3_hdr2o   = "divin." ;
$out_tbl3_hdr2p   = "eterwiki" ;
$out_tbl3_hdr2q   = "im&aring;djes" ;
$out_tbl3_hdr2r   = "difo&ucirc;." ;
$out_tbl3_hdr2s   = "redjibl." ;
$out_tbl3_hdr2t   = "dimandes<br>di p&aring;djes" ;
$out_tbl3_hdr2u   = "vizites" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficir" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;car." ;
$out_tbl3_hdr3h   = "candj." ;
$out_tbl3_hdr3i   = "octets" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Ko" ;
$out_tbl3_hdr3k   = "2&nbsp;Ko" ;

$out_tbl6_intro  = "[[4]] uzeus anonimes, rel&icirc;s pa nombe di contribouwaedjes" ;
$out_table6_footer = "Tot eshonne, i gn a yeu %d candjmints d'&nbsp;fwaits pa des uzeus anonimes, so on tot&aring; di %d candjmints (%.0f\%)" ;

$out_tbl5_intro   = "Sitatistikes des viziteus (d'&nbsp;apr&egrave;s l'&nbsp;rexhowe di <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definixhas</font></a>, " .
                    "<a href=''><font color='#000088'>grafike</font></a>)" ;
$out_tbl5_hdr1a   = "Moyene par djo&ucirc;" ;
$out_tbl5_hdr1e   = "Tot&aring;s par moes" ;
$out_tbl5_hdr2a   = "Adjond." ;
$out_tbl5_hdr2b   = "Fitch&icirc;s" ;
$out_tbl5_hdr2c   = "P&aring;djes" ;
$out_tbl5_hdr2d   = "Vizites" ;
$out_tbl5_hdr2e   = "Sites" ;
$out_tbl5_hdr2f   = "Koctets" ;
$out_tbl5_hdr2g   = "Vizites" ;
$out_tbl5_hdr2h   = "P&aring;djes" ;
$out_tbl5_hdr2i   = "Fitch&icirc;s" ;
$out_tbl5_hdr2j   = "Adjond." ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Wikipedyins k'&nbsp;ont fwait pol moens 10 candjmints dispoy k'&nbsp;il ont-st ariv&eacute;",
"Acrexhaedje do nombe di wikipedyins k'&nbsp;ont fwait pol moens 10 candjmints dispoy k'&nbsp;il ont-st ariv&eacute;",
"Wikipedyins k'&nbsp;ont contribouw&eacute; pol moens 5 c&ocirc;ps sol moes di dvant",
"Wikipedyins k'&nbsp;ont contribouw&eacute; pol moens 100 c&ocirc;ps sol moes di dvant",
"&Aring;rtikes avou pol moens on dvintrin loy&eacute;n",
"&Aring;rtikes avou pol moens on dvintrin loy&eacute;n eyet 200 caracteres di tecse l&eacute;jh&aring;ve, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fo&ucirc; des c&ocirc;des wiki ou HTML, des loy&eacute;ns catch&icirc;s, eyet des tiestires<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(les &ocirc;t&egrave;s colones sont b&aring;z&ecirc;yes sol contaedje oficir)",
"Noveas &aring;rtikes par djo&ucirc; sol moes",
"Nombe moy&eacute;n des candjmints par &aring;rtike",
"Grandeu moyene des &aring;rtikes, en octets",
"&Aring;cintaedje d'&nbsp;&aring;rtikes di pus di 0.5&nbsp;Ko di tecse l&eacute;jh&aring;ve (rl a: F)",
"&Aring;cintaedje d'&nbsp;&aring;rtikes di pus di 2&nbsp;Ko di tecse l&eacute;jh&aring;ve (rl a: F)",
"Candjmints sol moes (tot contant les redjiblaedjes eyet les contribouwaedjes anonimes)",
"Grandeu tot&aring;le di tos les &aring;rtikes (les redjiblaedjes avou)",
"Nombe tot&aring; d'&nbsp;mots (fo&ucirc; des redjiblaedjes, do c&ocirc;de wiki ou HTML et des loy&eacute;ns catch&icirc;s)",
"Nombe tot&aring; d'&nbsp;divintrins loy&eacute;ns (fo&ucirc; des redjiblaedjes, des &laquo;stubs&raquo; eyet des djiv&ecirc;yes di loy&eacute;ns)",
"Nombe tot&aring; d'&nbsp;loy&eacute;ns vi&egrave; ds &ocirc;tes Wikipedias",
"Nombe tot&aring; d'&nbsp;im&aring;djes h&aring;yn&ecirc;yes ez&egrave;s &aring;rtikes",
"Nombe tot&aring; d'&nbsp;difo&ucirc;trinn&egrave;s h&aring;rd&ecirc;yes",
"Nombe tot&aring; d'&nbsp;redjiblaedjes",
"Dimandes di p&aring;djes par djo&ucirc; (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definixha</font></a>, b&aring;z&ecirc;yes        sol rexhowe di <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Vizites par djo&ucirc; (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definixha</font></a>, b&aring;z&ecirc;yes sol rexhowe di <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Din&ecirc;yes po les dierins moes"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedyins k'&nbsp;ont contribouw&eacute; pol moens 5 c&ocirc;ps sol samwinne",
"Wikipedyins k'&nbsp;ont contribouw&eacute; pol moens 25 c&ocirc;ps sol samwinne",
) ;

$out_legend_daily_edits = "Candjmints par djo&ucirc; (redjiblaedjes eyet uzeus anonimes avou)" ;
$out_report_description_daily_edits = "Candjmints par djo&ucirc;" ;
$out_report_description_edits       = "Candjmints par moes/djo&ucirc;" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Contribouweus",
"Noveas wikipedyins",
"Wikipedyins actifs",
"Wikipedyins foirt actifs",
"Nombe d'&nbsp;&aring;rtikes (oficir)", #(contaedje oficir)
"Nombe d'&nbsp;&aring;rtikes (alternatif)", #(contaedje alternatif)
"Noveas &aring;rtikes par djo&ucirc;",
"Candjmints par &aring;rtike",
"Octets par &aring;rtike",
"&Aring;rtikes di pus di 0.5&nbsp;Ko",
"&Aring;rtikes di pus di 2&nbsp;Ko",
"Candjmints par moes",
"Grandeu del b&aring;ze di dn&ecirc;yes",
"Mots",
"Divintrins loy&eacute;ns",
"Loy&eacute;ns vi&egrave; ds &ocirc;tes Wikipedias",
"Im&aring;djes",
"Difo&ucirc;trinn&egrave;s h&aring;rd&ecirc;yes",
"Redjiblaedjes",
"Dimandes di p&aring;djes par djo&ucirc;",
"Vizites par djo&ucirc;",
"Inform&aring;cion djener&aring;le"
) ;

$out_languages {"aa"} = "Afar" ;        # co a f&eacute;
$out_languages {"ab"} = "Abxhaze" ;
$out_languages {"af"} = "Afrikaans" ;
$out_languages {"als"} = "Elsacyin" ;
$out_languages {"am"} = "Amarike" ;
$out_languages {"an"} = "Aragon&egrave;s" ;
$out_languages {"ar"} = "Arabe" ;
$out_languages {"as"} = "Assam&egrave;s" ;
$out_languages {"ast"} = "Asturyin" ;
$out_languages {"ay"} = "Aymara" ;        # co a f&eacute;
$out_languages {"az"} = "Azerbaydjan&egrave;s" ;
$out_languages {"ba"} = "Bashkir" ;
$out_languages {"be"} = "Bielor&ucirc;sse" ;
$out_languages {"bg"} = "Bulg&aring;re" ;
$out_languages {"bh"} = "Bihari" ;        # co a f&eacute;
$out_languages {"bi"} = "Bislama" ;        # co a f&eacute;
$out_languages {"bn"} = "Bengali" ;
$out_languages {"bo"} = "Tibetin" ;
$out_languages {"br"} = "Burton" ;
$out_languages {"bs"} = "Bosnyin" ;
$out_languages {"bug"} = "Buguin&egrave;s" ;
$out_languages {"ca"} = "Catalan" ;
$out_languages {"co"} = "Corse" ;
$out_languages {"cs"} = "Tcheke" ;
$out_languages {"csb"} = "Cachoube" ;
$out_languages {"cy"} = "Wal&egrave;s" ;
$out_languages {"da"} = "Daenw&egrave;s" ;
$out_languages {"de"} = "Almand" ;
$out_languages {"dz"} = "Boutan&egrave;s" ;
$out_languages {"el"} = "Grek" ;
$out_languages {"en"} = "Ingl&egrave;s" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Espagnol" ;
$out_languages {"et"} = "Estonyin" ;
$out_languages {"eu"} = "Basse" ;
$out_languages {"fa"} = "Farsi" ;
$out_languages {"fi"} = "Finw&egrave;s" ;
$out_languages {"fj"} = "Fidjyin" ;
$out_languages {"fo"} = "Faerow&egrave;s" ;
$out_languages {"fr"} = "Franc&egrave;s" ;
$out_languages {"fy"} = "Frizon" ;
$out_languages {"ga"} = "Irland&egrave;s" ;
$out_languages {"gay"} = "Gayo" ;        # co a f&eacute;
$out_languages {"gd"} = "Gayelike esc&ocirc;ss&egrave;s" ;
$out_languages {"gl"} = "Galicyin" ;
$out_languages {"gn"} = "Gwarani" ;
$out_languages {"gu"} = "Goudjarati" ;
$out_languages {"gv"} = "Gayelike di l'&nbsp;Iye di Man" ;
$out_languages {"ha"} = "Hawsa" ;
$out_languages {"he"} = "Ebreu" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Crow&aring;te" ;
$out_languages {"hu"} = "Hongrw&egrave;s" ;
$out_languages {"hy"} = "&Aring;rmenyin" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"iba"} = "Iban" ;        # co a f&eacute;
$out_languages {"id"} = "Indonezyin" ;
$out_languages {"ik"} = "Inyupiak" ;
$out_languages {"io"} = "Ido" ;
$out_languages {"is"} = "Izland&egrave;s" ;
$out_languages {"it"} = "It&aring;lyin" ;
$out_languages {"iu"} = "Inuktitut" ;
$out_languages {"ja"} = "Djapon&egrave;s" ;
$out_languages {"jv"} = "Djavan&egrave;s" ;
$out_languages {"ka"} = "Djeyordjyin" ;
$out_languages {"kaw"} = "Kawi" ;
$out_languages {"kk"} = "Kazaxh" ;
$out_languages {"kl"} = "Groenland&egrave;s" ;
$out_languages {"km"} = "Xhmer" ;
$out_languages {"kn"} = "Kannada" ;
$out_languages {"ko"} = "Cor&ecirc;yin" ;
$out_languages {"ks"} = "Kashmiri" ;
$out_languages {"ku"} = "Kurde" ;
$out_languages {"kw"} = "Kornike" ;
$out_languages {"ky"} = "Kirguize" ;
$out_languages {"la"} = "Lat&eacute;n" ;
$out_languages {"li"} = "Limbordjw&egrave;s" ;
$out_languages {"ln"} = "Lingala" ;
$out_languages {"lo"} = "Lawocyin" ;
$out_languages {"ls"} = "Lat&eacute;no sins flecsions" ;
$out_languages {"lt"} = "Litwanyin" ;
$out_languages {"lv"} = "Letonyin" ;
$out_languages {"mad"} = "Madurese" ;        # co a f&eacute;
$out_languages {"mak"} = "Makasar" ;        # co a f&eacute;
$out_languages {"mg"} = "Malgache" ;
$out_languages {"mi"} = "Mawori" ;
$out_languages {"mk"} = "Macedonyin" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"mn"} = "Mongol" ;
$out_languages {"mo"} = "Mold&aring;ve" ;
$out_languages {"mr"} = "Marati" ;
$out_languages {"ms"} = "Malay" ;
$out_languages {"my"} = "Birman" ;
$out_languages {"na"} = "Nawour&egrave;s" ;
$out_languages {"nah"} = "Nahuatl" ;        # co a f&eacute;
$out_languages {"nds"} = "Bas Sacson" ;
$out_languages {"ne"} = "Nepal&egrave;s" ;
$out_languages {"nl"} = "Neyerland&egrave;s" ;
$out_languages {"nn"} = "Norvedjyin (Nynorsk)" ;
$out_languages {"no"} = "Norvedjyin" ;
$out_languages {"oc"} = "Occitan" ;
$out_languages {"om"} = "Oromo" ;
$out_languages {"or"} = "Oriya" ;
$out_languages {"pa"} = "Pundjabi" ;
$out_languages {"pl"} = "Polon&egrave;s" ;
$out_languages {"ps"} = "Pashto" ;
$out_languages {"pt"} = "Portugu&egrave;s" ;
$out_languages {"qu"} = "Ketchwa" ;
$out_languages {"rm"} = "Romantche" ;
$out_languages {"rn"} = "Kiroundi" ;
$out_languages {"ro"} = "Roumin" ;
$out_languages {"ru"} = "R&ucirc;sse" ;
$out_languages {"rw"} = "Kiniarwanda" ;
$out_languages {"sa"} = "Sanscrit" ;
$out_languages {"sd"} = "Sindi" ;
$out_languages {"sg"} = "Sangro" ;
$out_languages {"sh"} = "Serbo-Crow&aring;te" ;
$out_languages {"si"} = "Singhal&egrave;s" ;
$out_languages {"simple"} = "Ingl&egrave;s&nbsp;simpe" ;
$out_languages {"sk"} = "Eslovake" ;
$out_languages {"sl"} = "Eslovene" ;
$out_languages {"sm"} = "Samowan" ;
$out_languages {"sn"} = "Shona" ;
$out_languages {"sq"} = "Alban&egrave;s" ;
$out_languages {"sr"} = "Serbe" ;
$out_languages {"ss"} = "Siswati" ;
$out_languages {"st"} = "Sessoto" ;
$out_languages {"su"} = "Sundanese" ;
$out_languages {"sv"} = "Suwedw&egrave;s" ;
$out_languages {"sw"} = "Suwahili" ;
$out_languages {"ta"} = "Tamoul" ;
$out_languages {"te"} = "Telougou" ;
$out_languages {"tg"} = "Tadjik" ;
$out_languages {"th"} = "Tayland&egrave;s" ;
$out_languages {"ti"} = "Tigrinya" ;
$out_languages {"tk"} = "Turcmene" ;
$out_languages {"tl"} = "Filipin" ;
$out_languages {"tn"} = "Setswana" ;
$out_languages {"to"} = "Tongyin" ;
$out_languages {"tr"} = "Turk" ;
$out_languages {"ts"} = "Tsonga" ;
$out_languages {"tt"} = "Tat&aring;r" ;
$out_languages {"tw"} = "Twi" ;
$out_languages {"ug"} = "Ouygour" ;
$out_languages {"uk"} = "Oucrinn&egrave;s" ;
$out_languages {"ur"} = "Ourdou" ;
$out_languages {"uz"} = "Ouzbeke" ;
$out_languages {"vi"} = "Vietnamyin" ;
$out_languages {"vo"} = "Volap&uuml;k" ;
$out_languages {"wa"} = "Walon" ;
$out_languages {"wo"} = "Wolof" ;
$out_languages {"yi"} = "Yidish" ;
$out_languages {"yo"} = "Yorouba" ;
$out_languages {"za"} = "Zhuang" ;        # co a f&eacute;
$out_languages {"zh"} = "Chinw&egrave;s" ;
$out_languages {"zu"} = "Zoulou" ;
$out_languages {"zz"} = "Tos&nbsp;les&nbsp;lingaedjes" ;
}

# my @weekdays_wa = qw (dimegne londi m&aring;rdi mierkidi djudi v&eacute;nrdi semdi);
#
# my @months_wa   = qw (djanv&icirc; fevr&icirc; m&aring;ss avri may djun djulete
#                      awousse setimbe oct&ocirc;be n&ocirc;vimbe decimbe);
#
# my @months_wa   = qw (dja fev m&acirc;s avr may djn djl
#                      awo set oct n&ocirc;v dec);

#
# Dates in Walloon are "<daynumber> di <monthname> <year>"
# but the "di" may be "di" or "d' " (with a non-breaking space: "d'&nbsp;")
# depending on the daynumber and monthname.
# (di -> d' after a number ending in vowel, or before a monthname
# starting in vowel)
# Also, the 1st of the month is special.
#
# The rules are:
# if daynumber = 1;
#          then: date = "1&icirc; d'&nbsp;" . <monthname>
# if daynumber = 2,3,20,22,23;
#          then: date = <daynumber> . " d'&nbsp;" . <monthname>
# if monthnumber = 4,8,10;
#          then: date = <daynumber> . " d'&nbsp;" . <monthname>
# else
#         date = <daynumber> . " di "  . <monthname>
#
# Some examples:
# 18 d'&nbsp;awousse 2003
# 1&icirc; d'&nbsp;may 2003
# 15 di n&ocirc;vimbe 2004
# 23 d'&nbsp;n&ocirc;vimbe 2004
#

1;


