#!/usr/bin/perl

# please specify all accented characters as utf-8 or
# as html codes like &agrave; or $#224;
# see for a list of html codes see
# http://evolt.org/article/ala/17/21234/


sub SetLiterals_BR
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Stadego&ugrave Wikipedia" ;
$out_charts       = "Grafiko&ugrave Wikipedia" ;
$out_btn_tables   = "Taolenno&ugrave" ;
$out_btn_table    = "Taolenn" ;
$out_btn_charts   = "Grafiko&ugrave" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipediao&ugrave" ;
$out_wikipedians   = "wikipedourien" ;

$out_wiktionary   = "Wikeriadur" ;
$out_wiktionaries = "Wikeriadurio&ugrave" ;
$out_wiktionarians   = "wikeriadurourien" ;

$out_wikibook        = "Wikilevr" ;
$out_wikibooks       = "Wikilevrio&ugrave" ;
$out_wikibookies     = "Aozerien Wikilevrio&ugrave" ;

$out_wikiquote       = "Wikiarroud" ;
$out_wikiquotes      = "Wikiarroudo&ugrave" ;
$out_wikiquotarians  = "Wikiarrouderien" ;

$out_wikinews        = "Wikikelo&ugrave" ;
$out_wikinewssites   = "Lec'hienno&ugrave Wikikelo&ugrave" ;
$out_wikireporters   = "Wikikazetennerien" ;

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Wikispisial" ;
$out_wikispecials    = "Lec'hienno&ugrave Wikispisial" ;
$out_wikispecialists = "Aozerien" ;

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "Lec'hienno&ugrave Wikimedia" ;

$out_comparisons  = "Ke&ntilde;veriadenno&ugrave" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "En domani foran ema&ntilde; an holl roadenno&ugrave ha skeudenno&ugrave a gaver war ar bajenn-ma&ntilde;." ;
$out_generated    = "Savet d'an " ;
$out_sqlfiles     = "adal restro&ugrave SQL eus an " ;
$out_version      = "Stumm ar skript:" ;
$out_author       = "Aozer" ;
$out_mail         = "Postel" ;
$out_site         = "Lec'hienn genrouedad" ;
$out_home         = "Degemer" ;
$out_sitemap      = "Tres al lec'hienn";
$out_rendered     = "grafiko&ugrave taolet gant " ;
$out_generated2   = "Savet ivez:" ;
$out_easytimeline = "Meneger ar grafigo&ugrave EasyTimeline dre Wikipedia" ;
$out_categories   = "Sell war ar rummdo&ugrave dre Wikipedia" ;
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Stadego&ugrave evit " ;
$out_stats_per    = "Stadego&ugrave evit " ;

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "Kb" ;
$out_bytes        = "b" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Deiziad" ;
$out_year         = "Bloaz" ;
$out_month        = "Miz" ;
$out_mean         = "Keidenn" ;
$out_growth       = "Kresk" ;
$out_total        = "Hollad" ;
$out_bars         = "Barrenn&ugrave" ;
$out_words        = "Gerio&ugrave" ;
$out_zoom         = "Zoum" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "nevez" ;
$out_all          = "An holl" ; #  (people)
$out_all2         = "An holl" ; #  (things)

$out_conversions1 = "" ;
$out_conversions2 = "Amdroadurio&#249; (dam)emgefre zo bet lakaet e pleustr." ;

$out_phaseIII     = "N'eus bet pledet nemet gant ar Wikipediao&ugrave a dro war meziant <a href='http://www.mediawiki.org'>MediaWiki</a>." ;

$out_svg_viewer   = "Ret eo deoc'h kaout ur " .
                    "gweler SVG, evel <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "evit MS Explorer Win/Mac (digoust) evit gwelet ar pajenno&ugrave-ma&ntilde;" ;
$out_rendering    = "O renta&#241;.... Gortozit mar plij" ;

$out_sort_order   = "Urzhiet eo ar Wikipediao&ugrave dre an niver a liammo&ugrave diabarzh (an adkaso&ugrave er-maez)<br>" .
                    "Seblantout a ra an dra-se beza&ntilde; un diazez onestoc&#146;h da ge&ntilde;veria&ntilde; ar strivo&ugrave dre vras kentoc&#146;h eget an niver a bennado&ugrave er bank titouro&ugrave:<br>" .
                    "N'eo ket ken heverk pledi&ntilde; gant an niver a bennado&ugrave rak Wikipediao&ugrave zo zo pennado&ugrave berr enno dreist-holl,<br>" .
                    "pe kalz pennado&ugrave savet en un doare emgefre zoken, tra ma'z eus nebeutoc&#146;h a bennado&ugrave e Wikipediao&ugrave all met kalz hiroc&#146;h int ha skridaozet-tout.<br>" .
                    "Diouzh ar mod da goda&ntilde; eo ment ar bank titouro&ugrave (an arouezenno&ugrave Unicode zo lies oktet enno) ha <br>" .
                    "diouzh an niver a stlenno&#249; a c&#146;hall un arouezenn ezteurel (da sk. e talv un arouezenn sinaek evit ur ger klok).<br>" ;

$out_webalizer_note = "Notenn: n'haller ket atav kaout roadenno&ugrave Web talvoudus. Sifro&#249; izel Kerzu 2003 zo da veza&#241; displeget dre c&#146;hwitadnno&ugrave bras ar servijer." ;
$out_not_included = "Not included" ; #new

$out_average_1    = "konto&#249; keitat war ar mizio&ugrave war ziskouez" ;
$out_growth_1     = "kresk miziek keitat war ar mizio&ugrave war ziskouez" ;
$out_formula      = "formulenn" ;
$out_value        = "danvez" ;
$out_monthes      = "miziou&ugrave" ;
$out_skip_values  = "(Wikipediao&ugrave danvez enno < 10 er-maez)" ;

$out_history      = "Notenn : re izel eo ar sifro&ugrave evit ar miz kenta&ntilde;. " .
                    "istor ar reizhadenno&ugrave n'eo ket bet dalc&#146;het mat atav er mareo&ugrave kenta&ntilde;." ;

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

$out_tbl1_intro   = "[[2]] Wikipedourien oberiant nevez zo, " .
                    "urzhiet dre an niver a zegasadenno&ugrave :" ;
$out_tbl1_intro2  = "ne gonter nemet ar pennado&ugrave kemmet, ket ar c&#146;hemmo&ugrave degaset d'ar pajenno&ugrave kaozeal, hag all" ;
$out_tbl1_intro3  = "&Delta; = kemm renk war 30 devezh" ;

$out_tbl1_hdr1    = "Implijer" ;
$out_tbl1_hdr2    = "Kemmo&#249;" ;
$out_tbl1_hdr3    = "Kemm kenta&#241;" ;
$out_tbl1_hdr4    = "Kemm diwezha&#241;" ;
$out_tbl1_hdr5    = "deizad" ;
$out_tbl1_hdr6    = "devezh<br>zo" ;
$out_tbl1_hdr7    = "hollad" ;
$out_tbl1_hdr8    = "30 devezh<br>diwezha&ntilde;" ;
$out_tbl1_hdr9    = "renk" ;
$out_tbl1_hdr10   = "brema&#241;" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Pennado&ugrave" ;
$out_tbl1_hdr13   = "Trao&ugrave all" ;

$out_tbl2_intro  = "[[3]] Wikipedourien ezvezant nevez zo, " .
                   "urzhiet dre an niver a zegasadenno&ugrave:" ;

$out_tbl3_intro   = "Kresk war ar Wikipedourien oberiant enrollet hag o degasadenno&ugrave" ;

$out_tbl3_hdr1a   = "Wikipedourien" ;
$out_tbl3_hdr1e   = "Pennado&ugrave" ;
$out_tbl3_hdr1l   = "Bank titouro&#249;" ;
$out_tbl3_hdr1o   = "Liammo&ugrave" ;
$out_tbl3_hdr1t   = "Implij dre zevezh" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(implijerien enrollet)" ;
$out_tbl3_hdr1e2  = "(nemet an adkaso&ugrave)" ;

$out_tbl3_hdr2a   = "hollad" ;
$out_tbl3_hdr2b   = "nevez" ;
$out_tbl3_hdr2c   = "kemmo&ugrave" ;
$out_tbl3_hdr2e   = "kont" ;
$out_tbl3_hdr2f   = "nevez<br>dre&nbsp;zevezh" ;
$out_tbl3_hdr2h   = "talvoud" ;
$out_tbl3_hdr2j   = "brasoc&#146;h&nbsp;eget" ;
$out_tbl3_hdr2l   = "kemmo&ugrave" ;
$out_tbl3_hdr2m   = "ment" ;
$out_tbl3_hdr2n   = "gerio&ugrave" ;
$out_tbl3_hdr2o   = "diabarzh" ;
$out_tbl3_hdr2p   = "etrewiki" ;
$out_tbl3_hdr2q   = "skeudenn" ;
$out_tbl3_hdr2r   = "diavaez" ;
$out_tbl3_hdr2s   = "adkaso&ugrave" ;
$out_tbl3_hdr2t   = "pajenno&ugrave<br>goulennet" ;
$out_tbl3_hdr2u   = "gweladenno&ugrave" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "ofisiel" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "kemmo&ugrave" ;
$out_tbl3_hdr3i   = "bito&#249;" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] implijerien dianav, urzhiet dre an niver a zegasadenno&ugrave" ;
$out_table6_footer = "An holl a-gevret e oa bet degaset %d kemm gant implijerien dianav war un hollad a %d kemm (%.0EUS\%)" ;

$out_tbl5_intro   = "stadego&#249; ar weladennerien (diazezet war roadenno&ugrave un <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>dielfenner Web</font></a> ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>termenadurio&ugrave</font></a>, " .
                    "<a href=''><font color='#000088'>grafik</font></a>)" ;
$out_tbl5_hdr1a   = "Keidenn dre zevezh" ;
$out_tbl5_hdr1e   = "Hollado&ugrave miziek" ;
$out_tbl5_hdr2a   = "Tizhadenno&ugrave" ;
$out_tbl5_hdr2b   = "Restro&ugrave" ;
$out_tbl5_hdr2c   = "Pajenno&ugrave" ;
$out_tbl5_hdr2d   = "Gweladenno&ugrave" ;
$out_tbl5_hdr2e   = "Lec&#146;hienno&ugrave" ;
$out_tbl5_hdr2f   = "Kbit" ;
$out_tbl5_hdr2g   = "Gweladenno&ugrave" ;
$out_tbl5_hdr2h   = "Pajenno&ugrave" ;
$out_tbl5_hdr2i   = "Restro&ugrave" ;
$out_tbl5_hdr2j   = "Tizhadenno&ugrave" ;

$out_tbl7_intro   = "Enrolladenno&ugrave ar bank titouro&ugrave dre rumm-pajenno&ugrave / Pennado&ugrave rummet<p>" .
                    "<small>1) N'eo ket bet kemeret e kont ar rummado&ugrave enlakaet dre patrom&ugrave.</small>" ;
$out_tbl7_hdr_ns  = "Rumm-pajenno&ugrave" ;
$out_tbl7_hdr_ca  = "Pennado&ugrave<br>rummet <sup>1</sup>" ;

$out_tbl8_intro = "Dasparzh ar c&#146;hemmo&ugrave er pennado&ugrave dre wikipedourien"  ;

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Pennad", "Implijer", "Raktres", "Skeudenn", "MediaWiki", "Patrom", "Skoazell", "Rummad") ;

@out_tbl3_legend  = (
"Wikipedourien degaset 10 kemm ganto da nebeuta&ntilde; abaoe m'int degouezhet",
"Kresk er wikipedourien degaset 10 kemm ganto pe muioc&#146;h abaoe m'int degouezhet",
"Kresk er wikipedourien degaset 5 kemm ganto pe muioc&#146;h er miz-ma&ntilde;",
"Wikipedourien degaset 100 kemm ganto pe muioc&#146;h er miz-ma&ntilde;",
"Pennado&ugrave enno ul liamm diabarzh da nebeuta&ntilde;",
"Pennado&ugrave enno ul liamm diabarzh ha 200 arouezenn skrid da lenn da nebeuta&ntilde;, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;lakaet er-maez ar c&#146;hodo&ugrave wiki- ha html, al liammo&ugrave kuzh, hag all; an talbenno&ugrave kennebeut ne gontont ket<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(banno&ugrave all zo diazezet war an doare konta&#241; ofisiel)",
"Pennado&ugrave nevez dre zevezh er miz tremenet",
"Niver a reizhadenno&ugrave keitat dre bennad",
"Ment keitat ar pennado&ugrave e bito&ugrave",
"Dregantad a bennado&ugrave enno 0.5 Kb skrid da lenn da nebeuta&ntilde; (gwelet F)",
"Dregantad a bennado&ugrave enno 2 Kb skrid da lenn da nebeuta&ntilde; (gwelet F)",
"Kemmo&#249; er miz temen (adkaso&ugrave e-barzh, kenlabourerien dianav e-barzh)",
"Ment strollet an holl bennado&ugrave (adkaso&ugrave e-barzh)",
"Niver hollek a c&#146;herio&ugrave (adkaso&ugrave, kodo&ugrave html/wiki ha liammo&ugrave kuzh er-maez)",
"Niver hollek a liammo&ugrave diabarzh (adkaso&ugrave, pennkefio&ugrave ha rollo&ugrave liammo&ugrave er-maez)",
"Niver hollek a liammo&ugrave war-du Wikipediao&ugrave all",
"Niver hollek a skeudenno&ugrave kinniget",
"Niver hollek a liammo&ugrave war-du lec&#146;hienno&ugrave all",
"Niver hollek a adkaso&ugrave",
"Pajenno&ugrave goulennet bemdez (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>termenadur</font></a>, diazezet war roadenno&ugrave un <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>dielfenner Web</font></a>)",
"Gweladenno&ugrave dre zevezh (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>termenadur</font></a>, diazezet war roadenno&#249; un <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>dielfenner Web</font></a>)",
"Roadenno&ugrave evit ar mizio&ugrave diwezha&ntilde;"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedourien a gemer perzh 5 gwech ar sizhun pe muioc&#146;h",
"Wikipedourien a gemer perzh 25 gwech ar sizhun pe muioc&#146;h"
) ;

$out_legend_daily_edits = "Kemmo&ugrave dre zevezh (adkaso&ugrave ha kenlabourerien dienroll kontet e-barzh)" ;
$out_report_description_daily_edits = "Skridaozadenno&ugrave dre zevezh" ;
$out_report_description_edits       = "Skridaozadenno&ugrave dre viz/devezh" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Kenlabourerien",
"Wikipedourien nevez",
"Wikipedourien oberiant",
"Wikipedourien oberiant-kena&ntilde;",
"Kont ar pennado&ugrave (ofisiel)",
"Kont ar pennado&ugrave (doare all)",
"Pennado&ugrave nevez bemdez",
"Skridaozadenno&ugrave dre bennad",
"Bito&ugrave dre bennad",
"Pennado&ugrave a-us da 0.5 Kb",
"Pennado&ugrave a-us da 2 Kb",
"skridaozadenno&ugrave dre viz",
"Ment ar bank titouro&ugrave",
"Gerio&ugrave",
"Liammo&ugrave diabarzh",
"Liammo&ugrave war-du Wikipediao&ugrave all",
"Skeudenno&ugrave",
"Liammo&ugrave Web",
"Adkaso&ugrave",
"Pajenno&ugrave goulennet bemdez",
"Gweladenno&ugrave dre zevezh",
"Tro-sell"
) ;

# if you don't know all translation please mark untranslated ones

$out_languages {"aa"} = "Afar" ;
$out_languages {"ab"} = "Abkhazeg" ;
$out_languages {"af"} = "Afrikaneg" ;
$out_languages {"ak"} = "Akana" ;
$out_languages {"als"} = "Elzaseg" ;
$out_languages {"am"} = "Amhareg" ;
$out_languages {"an"} = "Aragoneg" ;
$out_languages {"ang"} = "Anglosaksoneg" ;
$out_languages {"ar"} = "Arabeg" ;
$out_languages {"as"} = "Asameg" ;
$out_languages {"ast"} = "Asturianeg" ;
$out_languages {"av"} = "Avieneg" ;
$out_languages {"ay"} = "Aymara" ;
$out_languages {"az"} = "Azeri" ;
$out_languages {"ba"} = "Bachkir" ;
$out_languages {"be"} = "Belaruseg" ;
$out_languages {"bg"} = "Bulgareg" ;
$out_languages {"bh"} = "Bihari" ;
$out_languages {"bi"} = "Bislama" ;
$out_languages {"bn"} = "Bengaleg" ;
$out_languages {"bo"} = "Tibeteg" ;
$out_languages {"br"} = "Brezhoneg" ;
$out_languages {"bs"} = "Bosneg" ;
$out_languages {"bug"} = "Bugi" ;
$out_languages {"ca"} = "Katalaneg" ;
$out_languages {"ch"} = "Chamorru" ;
$out_languages {"cho"} = "Choktaw" ;
$out_languages {"co"} = "Korseg" ;
$out_languages {"cr"} = "Cree" ;
$out_languages {"cs"} = "Tchekeg" ;
$out_languages {"cy"} = "Kembraeg" ;
$out_languages {"da"} = "Daneg" ;
$out_languages {"de"} = "Alamaneg" ;
$out_languages {"dv"} = "Maldiveg" ;
$out_languages {"dz"} = "Dzongkha" ;
$out_languages {"ee"} = "Ewe" ;
$out_languages {"el"} = "Gresianeg" ;
$out_languages {"en"} = "Saozneg" ;
$out_languages {"eo"} = "Esperanteg" ;
$out_languages {"es"} = "Spagnoleg" ;
$out_languages {"et"} = "Estoneg" ;
$out_languages {"eu"} = "Euskareg" ;
$out_languages {"fa"} = "Farsi" ;
$out_languages {"fi"} = "Finneg" ;
$out_languages {"fj"} = "Fidjieg" ;
$out_languages {"fo"} = "Faeroeg" ;
$out_languages {"fr"} = "Galleg" ;
$out_languages {"fy"} = "Frizeg" ;
$out_languages {"ga"} = "Iwerzhoneg" ;
$out_languages {"gay"} = "Gayo" ;
$out_languages {"gd"} = "Gouezeleg Skos" ;
$out_languages {"gl"} = "Galizeg" ;
$out_languages {"gn"} = "Guarani" ;
$out_languages {"got"} = "Goteg" ;
$out_languages {"gu"} = "Goudjarati" ;
$out_languages {"gv"} = "Manaveg" ;
$out_languages {"ha"} = "Haousa" ;
$out_languages {"haw"} = "Hawaieg" ;
$out_languages {"he"} = "Hebraeg" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Kroateg" ;
$out_languages {"ht"} = "Kreoleg Haiti" ;
$out_languages {"hu"} = "Hungareg" ;
$out_languages {"hy"} = "Armenianeg" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"iba"} = "Iban" ;
$out_languages {"id"} = "Indonezeg" ;
$out_languages {"ik"} = "Inupiak" ;
$out_languages {"io"} = "Ido" ;
$out_languages {"is"} = "Islandeg" ;
$out_languages {"it"} = "Italianeg" ;
$out_languages {"iu"} = "Inuktitut" ;
$out_languages {"ja"} = "Japaneg" ;
$out_languages {"jv"} = "Javaneg" ;
$out_languages {"ka"} = "Jorjianeg" ;
$out_languages {"kaw"} = "Kawi" ;
$out_languages {"kk"} = "Kazak" ;
$out_languages {"kl"} = "Greunlandeg" ;
$out_languages {"km"} = "Khmer" ;
$out_languages {"kn"} = "Kannada" ;
$out_languages {"ko"} = "Koreaneg" ;
$out_languages {"ks"} = "Kashmiri" ;
$out_languages {"ku"} = "Kurdeg" ;
$out_languages {"ky"} = "Kirgiz" ;
$out_languages {"la"} = "Latin" ;
$out_languages {"lb"} = "Luksembourgeg" ;
$out_languages {"li"} = "Limbourgeg" ;
$out_languages {"ln"} = "Lingala" ;
$out_languages {"lo"} = "Laoseg" ;
$out_languages {"ls"} = "Latino Sine Flexione" ;
$out_languages {"lt"} = "Lituaneg" ;
$out_languages {"lv"} = "Latveg" ;
$out_languages {"mad"} = "Madoureg" ;
$out_languages {"mak"} = "Makasar" ;
$out_languages {"mg"} = "Malgacheg" ;
$out_languages {"mi"} = "Maori" ;
$out_languages {"mk"} = "Makedoneg" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"mn"} = "Mongoleg" ;
$out_languages {"mo"} = "Moldoveg" ;
$out_languages {"mr"} = "Marathi" ;
$out_languages {"ms"} = "Malayseg" ;
$out_languages {"mt"} = "Malteg" ;
$out_languages {"mus"} = "Muskogi" ;
$out_languages {"my"} = "Birmaneg" ;
$out_languages {"na"} = "Nauru" ;
$out_languages {"nah"} = "Nahuatl" ;
$out_languages {"nds"} = "Izelsaksoneg" ;
$out_languages {"ne"} = "Nepaleg" ;
$out_languages {"nl"} = "Nederlandeg" ;
$out_languages {"nn"} = "Norvegeg (Nynorsk)" ;
$out_languages {"no"} = "Norvegeg" ;
$out_languages {"nv"} = "Navaho" ;
$out_languages {"oc"} = "Okitaneg" ;
$out_languages {"om"} = "Oromo" ;
$out_languages {"or"} = "Oriya" ;
$out_languages {"pa"} = "Punjabeg" ;
$out_languages {"pl"} = "Poloneg" ;
$out_languages {"ps"} = "Pachto" ;
$out_languages {"pt"} = "Portugaleg" ;
$out_languages {"qu"} = "Kechuaeg" ;
$out_languages {"rm"} = "Roma&ntilde;cheg" ;
$out_languages {"rn"} = "Kirundi" ;
$out_languages {"ro"} = "Roumaneg" ;
$out_languages {"roa_rup"} = "Romanieg" ;
$out_languages {"ru"} = "Rusianeg" ;
$out_languages {"rw"} = "Kinyarwanda" ;
$out_languages {"sa"} = "Sanskriteg" ;
$out_languages {"sc"} = "Sardeg" ;
$out_languages {"scn"} = "Sikilianeg" ;
$out_languages {"sd"} = "Sindhi" ;
$out_languages {"se"} = "S&aacutemi an norzh" ;
$out_languages {"sg"} = "Sangro" ;
$out_languages {"sh"} = "Serb-kroateg" ;
$out_languages {"si"} = "Singhaleg" ;
$out_languages {"simple"} = "Saozneg&nbsp;eeun" ;
$out_languages {"sk"} = "Slovakeg" ;
$out_languages {"sl"} = "Sloveneg" ;
$out_languages {"sm"} = "Samoan" ;
$out_languages {"sn"} = "Shona" ;
$out_languages {"so"} = "Somali" ;
$out_languages {"sq"} = "Albaneg" ;
$out_languages {"sr"} = "Serbeg" ;
$out_languages {"ss"} = "Siswati" ;
$out_languages {"st"} = "Sotho ar Su" ;
$out_languages {"su"} = "Sundaneg" ;
$out_languages {"sv"} = "Svedeg" ;
$out_languages {"sw"} = "Swahili" ;
$out_languages {"ta"} = "Tamoul" ;
$out_languages {"te"} = "Telougou" ;
$out_languages {"tg"} = "Tadjik" ;
$out_languages {"th"} = "Thai" ;
$out_languages {"ti"} = "Tigrina" ;
$out_languages {"tk"} = "Turkmen" ;
$out_languages {"tl"} = "Tagalog" ;
$out_languages {"tn"} = "Tswana" ;
$out_languages {"to"} = "Tonga" ;
$out_languages {"tr"} = "Turkeg" ;
$out_languages {"ts"} = "Tsonga" ;
$out_languages {"tt"} = "Tatar" ;
$out_languages {"tw"} = "Twi" ;
$out_languages {"ty"} = "Tahitianeg" ;
$out_languages {"ug"} = "Ouigour" ;
$out_languages {"uk"} = "Ukraineg" ;
$out_languages {"ur"} = "Ourdu" ;
$out_languages {"uz"} = "Ouzbeg" ;
$out_languages {"vi"} = "Vietnameg" ;
$out_languages {"vo"} = "Volap&uuml;k" ;
$out_languages {"wa"} = "Walloneg" ;
$out_languages {"wo"} = "Wolof" ;
$out_languages {"yi"} = "Yiddish" ;
$out_languages {"yo"} = "Yorouba" ;
$out_languages {"za"} = "Zhuang" ;
$out_languages {"zh"} = "Sinaeg" ;
$out_languages {"zh_min_nan"} = "Minnan" ;
$out_languages {"zu"} = "Zouloueg" ;
$out_languages {"zz"} = "An&nbsp;holl&nbsp;yezho&ugrave" ;
}

# end of file marker, do not remove:
1;

