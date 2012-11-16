#!/usr/bin/perl
#
# $Id: WikiReports_SL.pl,v 1.3 2005/04/03 21:24:25 roman Exp $
# $Source: /home/roman/wiki/RCS/WikiReports_SL.pl,v $
#
# please specify all accented characters as html codes
# like &agrave; or $#224;
# do not edit with unicode editor, I will have to replace all unicode

# see for a list of codes
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_SL
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Statistika Wikipedije" ;
$out_charts       = "Grafi Wikipedije" ;
$out_btn_tables   = "Preglednice" ;
$out_btn_table    = "Preglednica" ;
$out_btn_charts   = "Grafikoni" ;

$out_wikipedia    = "Wikipedija" ;
$out_wikipedias   = "Wikipedije" ;
$out_wikipedians   = "wikipedisti" ;

$out_wiktionary   = "Wikcionar" ;
$out_wiktionaries = "Wikcionarji" ;
$out_wiktionarians   = "wikcionarji" ;

$out_wikibook        = "Wikiknjiga" ;
$out_wikibooks       = "Wikiknjige" ;
$out_wikibookies     = "avtorji Wikiknjig" ;

$out_wikiquote       = "Wikicitat" ;
$out_wikiquotes      = "Wikicitati" ;
$out_wikiquotarians  = "pisci Wikicitatov" ;

$out_wikinews        = "Wikinovice" ;
$out_wikinewssites   = "strani z Wikinovicami" ;
$out_wikireporters   = "Wikinovinarji" ;

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Wikiposebno" ;
$out_wikispecials    = "strani o Wikiposebnem" ;
$out_wikispecialists = "Avtorji" ;

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "strani Wikimedia" ;

$out_comparisons  = "Primerjave" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generirano dne " ;
$out_sqlfiles     = "z izpisov datotek SQL od " ;
$out_version      = "Razli&#269;ica skripta:" ;
$out_author       = "Avtor" ;
$out_mail         = "Po&#353;ta" ;
$out_site         = "Spletna stran" ;
$out_home         = "Doma&#269;a stran" ;
$out_sitemap      = "Zemljevid strani";
$out_rendered     = "Grafikoni upodobljeni z " ;
$out_generated2   = "Generirano tudi:" ;
$out_easytimeline = "Indeks grafikonov EasyTimeline na Wikipedijo" ;
$out_categories   = "Pregled kategorij na Wikipedijo" ;
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
$out_year         = "leto" ;
$out_month        = "mesec" ;
$out_mean         = "Povpre&#269;je" ;
$out_growth       = "Rast" ;
$out_total        = "Skupaj" ;
$out_bars         = "Stolpci" ;
$out_words        = "besede" ;
$out_zoom         = "Pove&#269;ava" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "novo" ;
$out_all          = "vsi" ;
$out_all2         = "vse" ;

$out_conversions1 = "" ;
$out_conversions2 = " uporabljanih (pol-)avtomati&#269;nih pretvorb." ;

$out_phaseIII     = "Vklju&#269;ene so le Wikipedije, ki te&#269;ejo na programju " .
                    "<a href='http://www.mediawiki.org'>MediaWiki</a>." ;

$out_svg_viewer   = "Za gledanje vsebine te strani boste potrebovali " .
                    "pregledovalnik SVG, npr. <a " .
                    "href='http://www.adobe.com/svg/viewer/install/'>Adobe " .
                    "SVG Viewer</a> za MS Explorer Win/Mac (zastonj)" ;
$out_rendering    = "Upodabljam.... Prosim po&#269;akajte" ;

$out_sort_order   = "Wikipedije so urejene po &#353;tevilu notranjih povezav (brez " .
                    "preumeritev).<br>" .
                    "To se je zdela bolj po&#353;tena osnova za primerjavo celotnega " .
                    "napora kot bodisi &#353;tevilo &#269;lankov ali pa velikost zbirke " .
                    "podatkov:<br>" .
                    "&#353;tevilo &#269;lankov ni tako pomembno, glede na to, da " .
                    "nekatere Wikipedije vsebujejo ve&#269;inoma kratke &#269;lanke,<br>" .
                    "ali celo mnogo samodejno generiranih &#269;lankov, medtem ko " .
                    "druge Wikipedije vsebujejo manj &#269;lankov, vendar so ti " .
                    "dalj&#353;i in vsi ro&#269;no napisani.<br>" .
                    "Velikost zbirke podatkov je odvisna od kodiranja znakov " .
                    "(znaki v unicode zasedejo ve&#269; zlogov) in <br>" .
                    "od pomena, ki ga sporo&#269;i en znak (npr. kitajski znaki so " .
                    "cele besede).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "povpre&#269;no &#353;tevilo prek prikazanih mesecev" ;
$out_growth_1     = "povpre&#269;na mese&#269;na rast prek prikazanih mesecev" ;
$out_formula      = "formula" ;
$out_value        = "vrednost" ;
$out_monthes      = "meseci" ;
$out_skip_values  = "(Wikipedije z vrednostmi < 10 so presko&#269;ene)" ;

$out_history      = "Opomba: &#353;tevilke za prve mesece so premajhne. " .
                    "Zgodovina razli&#269;ic se v davnih &#269;asih ni vedno ohranila." ;

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

$out_tbl1_intro   = "[[2]] trenutno dejavnih wikipedistov, " .
                    "urejenih po &#353;tevilu prispevkov:" ;
$out_tbl1_intro2  = "&#353;teta so le urejanja &#269;lankov, ne pogovornih strani itd." ;
$out_tbl1_intro3  = "&Delta; = sprememba uvrstitve v 30. dneh" ;

$out_tbl1_hdr1    = "Uporabnik" ;
$out_tbl1_hdr2    = "Urejanj" ;
$out_tbl1_hdr3    = "Prvo urejanje" ;
$out_tbl1_hdr4    = "Zadnje urejanje" ;
$out_tbl1_hdr5    = "datum" ;
$out_tbl1_hdr6    = "pred<br>dnevi" ;
$out_tbl1_hdr7    = "skupaj" ;
$out_tbl1_hdr8    = "zadnjih<br>30 dni" ;
$out_tbl1_hdr9    = "mesto" ;
$out_tbl1_hdr10   = "zdaj" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "&#268;lanki" ;
$out_tbl1_hdr13   = "Drugo" ;

$out_tbl2_intro  = "[[3]] trenutno odsotnih wikipedistov, " .
                    "urejenih po &#353;tevilu prispevkov:" ;

$out_tbl3_intro   = "Rast &#353;tevila vpisanih dejavnih wikipedistov in njihove " .
                    "dejavnosti" ;

$out_tbl3_hdr1a   = "Wikipedisti" ;
$out_tbl3_hdr1e   = "&#268;lanki" ;
$out_tbl3_hdr1l   = "Zbirka podatkov" ;
$out_tbl3_hdr1o   = "Povezave" ;
$out_tbl3_hdr1t   = "Dnevna raba" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registrirani uporabniki)" ;
$out_tbl3_hdr1e2  = "(brez preusmeritev)" ;

$out_tbl3_hdr2a   = "skupaj" ;
$out_tbl3_hdr2b   = "novih" ;
$out_tbl3_hdr2c   = "urejanj" ;
$out_tbl3_hdr2e   = "&#353;tevec" ;
$out_tbl3_hdr2f   = "novih<br>na&nbsp;dan" ;
$out_tbl3_hdr2h   = "srednjih" ;
$out_tbl3_hdr2j   = "ve&#269;jih&nbsp;kot" ;
$out_tbl3_hdr2l   = "urejanj" ;
$out_tbl3_hdr2m   = "velikost" ;
$out_tbl3_hdr2n   = "besed" ;
$out_tbl3_hdr2o   = "notranjih" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "slik" ;
$out_tbl3_hdr2r   = "zunanjih" ;
$out_tbl3_hdr2s   = "preusmeritev" ;
$out_tbl3_hdr2t   = "zahtevkov<br>strani" ;
$out_tbl3_hdr2u   = "obiskov" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "uradnih" ;
$out_tbl3_hdr3f   = ">&nbsp;200 zn." ;
$out_tbl3_hdr3h   = "urejanj" ;
$out_tbl3_hdr3i   = "zlogov" ;
$out_tbl3_hdr3j   = "0,5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonimnih uporabnikov, urejenih po &#353;tevilu prispevkov" ;
$out_table6_footer = "Skupaj so anonimni uporabniki prispevali %d urejanj " .
                     "od skupaj %d urejanj (%.0f\%)" ;

$out_tbl5_intro   = "Statistika obiska (temelji na izhodu orodja <a " .
                    "href='http://www.mrunix.net/webalizer/'><font " .
                    "color='#000088'>Webalizer</font></a>; <a " .
                    "href='http://www.mrunix.net/webalizer/webalizer_help.html'>" .
                    "<font color='#000088'>definicije</font></a>, " .
                    "<a href=''><font color='#000088'>graf</font></a>)" ;
$out_tbl5_hdr1a   = "Dnevno povpre&#269;je" ;
$out_tbl5_hdr1e   = "Mese&#269;ni se&#353;tevek" ;
$out_tbl5_hdr2a   = "Zadetki" ;
$out_tbl5_hdr2b   = "Datoteke" ;
$out_tbl5_hdr2c   = "Strani" ;
$out_tbl5_hdr2d   = "Obiski" ;
$out_tbl5_hdr2e   = "Mesta" ;
$out_tbl5_hdr2f   = "Kzlogi" ;
$out_tbl5_hdr2g   = "Obiskov" ;
$out_tbl5_hdr2h   = "Strani" ;
$out_tbl5_hdr2i   = "Datotek" ;
$out_tbl5_hdr2j   = "Zadetkov" ;

$out_tbl7_intro   = "Zapisov  v zbirki podatkov na imenski prostor / Kategorizirani &#269;lanki<p>" .
                    "<small>1) Kategorije, ki so vstavljene s predlogo, niso zaznane.</small>" ;
$out_tbl7_hdr_ns  = "Imenski prostor" ;
$out_tbl7_hdr_ca  = "Kategorizirani<br>&#269;lanki <sup>1</sup>" ;

$out_tbl8_intro   = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("&#268;lanek", "Uporabnik", "Projekt", "Slika", "MediaWiki", "Template", "Help", "Category") ;

@out_tbl3_legend  = (
"Wikipedisti, ki so urejali vsaj 10-krat odkar so prispeli",
"Pove&#269;anje wikipedistov, ki so urejali vsaj 10-krat odkar so prispeli",
"Wikipedisti, ki so ta mesec prispevali 5-krat ali ve&#269;krat",
"Wikipedisti, ki so ta mesec prispevali 100-krat ali ve&#269;krat",
"&#268;lanki, ki vsebujejo vsaj eno notranjo povezavo",
"&#268;lanki, ki vsebujejo vsaj eno notranjo povezavo in 200 znakov " .
   "berljivega besedila, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;brez kod wiki- in html, skritih " .
   "povezav, itd.; glave prav tako ne &#353;tejejo<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(drugi stolpci temeljijo na uradni " .
   "metodi &#353;tetja)",
"Novi &#269;lanki na dan v preteklem mesecu",
"Srednja vrednost revizij na &#269;lanek",
"Srednja velikost &#269;lanka v zlogih",
"Odstotek &#269;lankov z vsaj 0,5 Kb berljivega besedila (glej F)",
"Odstotek &#269;lankov z vsaj 2 Kb berljivega besedila (glej F)",
"Urejanj v preteklem mesecu (s preusmeritvami in neprijavljenimi " .
   "pisci prispevkov)",
"Skupna velikost vseh &#269;lankov (vklju&#269;no s preusmeritvami)",
"Skupno &#353;tevilo besed (brez preusmeritev, kod html/wiki in skritih povezav)",
"Skupno &#353;tevilo notranjih povezav (brez preusmeritev, &#353;krbin in " .
   "seznamov povezav)",
"Skupno &#353;tevilo povezav na druge Wikipedije",
"Skupno &#353;tevilo prikazanih slik",
"Skupno &#353;tevilo povezav na druga mesta",
"Skupno &#353;tevilo preusmeritev",
"Zahtevkov strani na dan (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definicija</font></a>, temelje&#269;a na izhodu orodja <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Obiskov na dan (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definicija</font></a>, temelje&#269;a na izhodu orodja <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Data for last months"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedisti, ki so prispevali 5-krat ali ve&#269;krat v tednu",
"Wikipedisti, ki so prispevali 25-krat ali ve&#269;krat v tednu"
) ;

$out_legend_daily_edits = "Urejanj na dan (s preusmeritvami in neregistriranimi pisci)" ;
$out_report_description_daily_edits = "Urejanj na dan" ;
$out_report_description_edits       = "Urejanj na mesec/dan" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Pisci prispevkov",
"Novi wikipedisti",
"Aktivni wikipedisti",
"Zelo aktivni wikipedisti",
"&#353;tetje &#269;lankov (uradno)",
"&#353;tetje &#269;lankov (alternativno)",
"Novih &#269;lankov na dan",
"Urejanj na &#269;lanek",
"Zlogov na &#269;lanek",
"&#268;lankov prek 0,5 Kb",
"&#268;lankov prek 2 Kb",
"Urejanj na mesec",
"Velikost zbirke podatkov",
"Besed",
"Notranjih povezav",
"Povezav na druge Wikipedije",
"Slik",
"Spletnih povezav",
"Preusmeritev",
"Zahtevkov strani na dan",
"Obiskov na dan",
"Pregled"
) ;

# if you don't know all translation please mark untranslated ones
# OK, all upper-case are unknown to me

$out_languages {"aa"} = "afar&#353;&#269;ina" ;
$out_languages {"ab"} = "abha&#353;&#269;ina" ;
$out_languages {"af"} = "afrikans" ;
$out_languages {"als"} = "elza&#353;&#269;ina" ;
$out_languages {"am"} = "amhar&#353;&#269;ina" ;
$out_languages {"an"} = "aragon&#353;&#269;ina" ;
$out_languages {"ar"} = "arab&#353;&#269;ina" ;
$out_languages {"as"} = "asam&#353;&#269;ina" ;
$out_languages {"ast"} = "asturij&#353;&#269;ina" ;
$out_languages {"ay"} = "aimar&#353;&#269;ina" ;
$out_languages {"az"} = "azer&#353;&#269;ina" ;
$out_languages {"ba"} = "ba&#353;kir&#353;&#269;ina" ;
$out_languages {"be"} = "beloru&#353;&#269;ina" ;
$out_languages {"bg"} = "bolgar&#353;&#269;ina" ;
$out_languages {"bh"} = "bihar&#353;&#269;ina" ;
$out_languages {"bi"} = "bislama" ;
$out_languages {"bn"} = "bengal&#353;&#269;ina" ;
$out_languages {"bo"} = "tibetan&#353;&#269;ina" ;
$out_languages {"br"} = "breton&#353;&#269;ina" ;
$out_languages {"bs"} = "bo&#353;nja&#353;&#269;ina" ;
$out_languages {"bug"} = "bugin&#353;&#269;ina" ;
$out_languages {"ca"} = "katalon&#353;&#269;ina" ;
$out_languages {"co"} = "korzij&#353;&#269;ina" ;
$out_languages {"cs"} = "&#269;e&#353;&#269;ina" ;
$out_languages {"cy"} = "valon&#353;&#269;ina" ;
$out_languages {"da"} = "dan&#353;&#269;ina" ;
$out_languages {"de"} = "nem&#353;&#269;ina" ;
$out_languages {"dz"} = "dzongha" ;
$out_languages {"el"} = "gr&#353;&#269;ina" ;
$out_languages {"en"} = "angle&#353;&#269;ina" ;
$out_languages {"eo"} = "esperanto" ;
$out_languages {"es"} = "&#353;pan&#353;&#269;ina" ;
$out_languages {"et"} = "eston&#353;&#269;ina" ;
$out_languages {"eu"} = "baskov&#353;&#269;ina" ;
$out_languages {"fa"} = "farsi" ;
$out_languages {"fi"} = "fin&#353;&#269;ina" ;
$out_languages {"fj"} = "fid&#382;ij&#353;&#269;ina" ;
$out_languages {"fo"} = "fer&#353;&#269;ina" ;
$out_languages {"fr"} = "franco&#353;&#269;ina" ;
$out_languages {"fy"} = "frizij&#353;&#269;ina" ;
$out_languages {"ga"} = "ir&#353;&#269;ina" ;
$out_languages {"gay"} = "gaj&#353;&#269;ina" ;
$out_languages {"gd"} = "&#353;kotska gel&#353;&#269;ina" ;
$out_languages {"gl"} = "Galego" ;
$out_languages {"gn"} = "guran&#353;&#269;ina" ;
$out_languages {"gu"} = "gud&#382;arat&#353;&#269;ina" ;
$out_languages {"gv"} = "manska gel&#353;&#269;ina" ;
$out_languages {"ha"} = "hav&#353;&#269;ina" ;
$out_languages {"he"} = "hebrej&#353;&#269;ina" ;
$out_languages {"hi"} = "hindij&#353;&#269;ina" ;
$out_languages {"hr"} = "hrva&#353;&#269;ina" ;
$out_languages {"hu"} = "mad&#382;ar&#353;&#269;ina" ;
$out_languages {"hy"} = "armen&#353;&#269;ina" ;
$out_languages {"ia"} = "interlingua" ;
$out_languages {"iba"} = "iban&#353;&#269;ina" ;
$out_languages {"id"} = "indonezij&#353;&#269;ina" ;
$out_languages {"ik"} = "inupiak" ;
$out_languages {"io"} = "ido" ;
$out_languages {"is"} = "island&#353;&#269;ina" ;
$out_languages {"it"} = "italijan&#353;&#269;ina" ;
$out_languages {"iu"} = "inuktitut&#353;&#269;ina" ;
$out_languages {"ja"} = "japon&#353;&#269;ina" ;
$out_languages {"jv"} = "javan&#353;&#269;ina" ;
$out_languages {"ka"} = "gruzij&#353;&#269;ina" ;
$out_languages {"kaw"} = "kavi" ;
$out_languages {"kk"} = "kaza&#353;&#269;ina" ;
$out_languages {"kl"} = "grenland&#353;&#269;ina" ;
$out_languages {"km"} = "kambo&#353;&#269;ina" ;
$out_languages {"kn"} = "kannada" ;
$out_languages {"ko"} = "korej&#353;&#269;ina" ;
$out_languages {"ks"} = "ka&#353;mir&#353;&#269;ina" ;
$out_languages {"ku"} = "kurd&#353;&#269;ina" ;
$out_languages {"ky"} = "kirgi&#353;&#269;ina" ;
$out_languages {"la"} = "latin&#353;&#269;ina" ;
$out_languages {"li"} = "limbur&#353;&#269;ina" ;
$out_languages {"ln"} = "lingala" ;
$out_languages {"lo"} = "lao&#353;&#269;ina" ;
$out_languages {"ls"} = "latin&#353;&#269;ina brez pregibov" ;
$out_languages {"lt"} = "litvan&#353;&#269;ina" ;
$out_languages {"lv"} = "latvij&#353;&#269;ina" ;
$out_languages {"mad"} = "madur&#353;&#269;ina" ;
$out_languages {"mak"} = "makasar&#353;&#269;ina" ;
$out_languages {"mg"} = "malga&#353;&#269;ina" ;
$out_languages {"mi"} = "maor&#353;&#269;ina" ;
$out_languages {"mk"} = "makedon&#353;&#269;ina" ;
$out_languages {"ml"} = "malaj&#353;&#269;ina" ;
$out_languages {"mn"} = "mongol&#353;&#269;ina" ;
$out_languages {"mo"} = "moldav&#353;&#269;ina" ;
$out_languages {"mr"} = "marathi" ;
$out_languages {"ms"} = "malaj&#353;&#269;ina" ;
$out_languages {"my"} = "burman&#353;&#269;ina" ;
$out_languages {"na"} = "nauru" ;
$out_languages {"nah"} = "nahuatl" ;
$out_languages {"nds"} = "Low&nbsp;Saxon" ;
$out_languages {"ne"} = "nepal&#353;&#269;ina" ;
$out_languages {"nl"} = "nizozem&#353;&#269;ina" ;
$out_languages {"nn"} = "norve&#353;&#269;ina (nynorsk)" ;
$out_languages {"no"} = "norve&#353;&#269;ina" ;
$out_languages {"oc"} = "Occitan" ;
$out_languages {"om"} = "oromo" ;
$out_languages {"or"} = "Oriya" ;
$out_languages {"pa"} = "pund&#382;abi" ;
$out_languages {"pl"} = "polj&#353;&#269;ina" ;
$out_languages {"ps"} = "pa&#353;tun&#353;&#269;ina" ;
$out_languages {"pt"} = "portugal&#353;&#269;ina" ;
$out_languages {"qu"} = "Quechua" ;
$out_languages {"rm"} = "retoroman&#353;&#269;ina" ;
$out_languages {"rn"} = "kirundi" ;
$out_languages {"ro"} = "romun&#353;&#269;ina" ;
$out_languages {"ru"} = "ru&#353;&#269;ina" ;
$out_languages {"rw"} = "Kinyarwanda" ;
$out_languages {"sa"} = "sanskrt" ;
$out_languages {"sd"} = "Sindhi" ;
$out_languages {"sg"} = "Sangro" ;
$out_languages {"sh"} = "srbohrva&#353;&#269;ina" ;
$out_languages {"si"} = "singal&#353;&#269;ina" ;
$out_languages {"simple"} = "preprosta&nbsp;angle&#353;&#269;ina" ;
$out_languages {"sk"} = "slova&#353;&#269;ina" ;
$out_languages {"sl"} = "sloven&#353;&#269;ina" ;
$out_languages {"sm"} = "samoan&#353;&#269;ina" ;
$out_languages {"sn"} = "Shona" ;
$out_languages {"sq"} = "alban&#353;&#269;ina" ;
$out_languages {"sr"} = "srb&#353;&#269;ina" ;
$out_languages {"ss"} = "Siswati" ;
$out_languages {"st"} = "Seshoto" ;
$out_languages {"su"} = "sudan&#353;&#269;ina" ;
$out_languages {"sv"} = "&#353;ved&#353;&#269;ina" ;
$out_languages {"sw"} = "svahili" ;
$out_languages {"ta"} = "tamil&#353;&#269;ina" ;
$out_languages {"te"} = "telugu" ;
$out_languages {"tg"} = "tad&#382;i&#353;&#269;ina" ;
$out_languages {"th"} = "taj&#353;&#269;ina" ;
$out_languages {"ti"} = "Tigrinya" ;
$out_languages {"tk"} = "turkmen&#353;&#269;ina" ;
$out_languages {"tl"} = "tagalog" ;
$out_languages {"tn"} = "Setswana" ;
$out_languages {"to"} = "tonga" ;
$out_languages {"tr"} = "tur&#353;&#269;ina" ;
$out_languages {"ts"} = "tsonga" ;
$out_languages {"tt"} = "tatar&#353;&#269;ina" ;
$out_languages {"tw"} = "Twi" ;
$out_languages {"ug"} = "Uighur" ;
$out_languages {"uk"} = "ukrajin&#353;&#269;ina" ;
$out_languages {"ur"} = "urduj&#353;&#269;ina" ;
$out_languages {"uz"} = "uzbe&#353;&#269;ina" ;
$out_languages {"vi"} = "vietnam&#353;&#269;ina" ;
$out_languages {"vo"} = "volap&uuml;k" ;
$out_languages {"wa"} = "Walloon" ;
$out_languages {"wo"} = "Wolof" ;
$out_languages {"yi"} = "jidi&#353;" ;
$out_languages {"yo"} = "Yoruba" ;
$out_languages {"za"} = "zhuang" ;
$out_languages {"zh"} = "kitaj&#353;&#269;ina" ;
$out_languages {"zu"} = "zuluj&#353;&#269;ina" ;
$out_languages {"zz"} = "Vsi&nbsp;jeziki" ;
}

# end of file marker, do not remove:
1;
