#!/usr/bin/perl

# please specify all accented characters as utf-8 or
# as html codes like &agrave; or $#224;
# see for a list of html codes see
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_HU
{
$out_thousands_separator = "&nbsp;" ;
$out_decimal_separator   = "," ;

$out_statistics   = "Wikipédia statisztikák" ;
$out_charts       = "Wikipedia diagramok" ;
$out_btn_tables   = "Táblázatok" ;
$out_btn_table    = "Tablázat" ;
$out_btn_charts   = "Diagramok" ;

$out_wikipedia    = "Wikipédia" ;
$out_wikipedias   = "Wikipédiák" ;
$out_wikipedians   = "wikipédisták" ;

$out_wiktionary   = "Wikiszótár" ;
$out_wiktionaries = "Wikiszótárak" ;
$out_wiktionarians   = "wikiszótárnokok" ;

$out_wikibook        = "Wikikönyv" ;
$out_wikibooks       = "Wikikönyvek" ;
$out_wikibookies     = "Wikikönyvel&#337;k" ;

$out_wikiquote       = "Wikidézet" ;
$out_wikiquotes      = "Wikidézetek" ;
$out_wikiquotarians  = "Wikidéz&#337;k" ;

$out_wikinews        = "Wikihírek" ;
$out_wikinewssites   = "Wikihíroldalak" ;
$out_wikireporters   = "Wikiriporterek" ;

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Wikispecial" ;
$out_wikispecials    = "Wikispecial oldalak" ;
$out_wikispecialists = "Szerz&#337;k" ;

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "Wikimedia oldalak" ;

$out_comparisons  = "Összehasonlítások" ;

$out_creation_history = "Létrehozás ideje" ;
$out_accomplishments  = "Teljesítmény" ;
$out_created          = "Létrehozva" ;
$average_increase     = "Átlagos növekedés havonta" ;

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "Az oldalon található minden adat és kép közkincs." ;
$out_generated    = "Létrehozás dátuma: " ;
$out_sqlfiles     = "SQL dump fájlok dátuma: " ;
$out_version      = "Script verziószáma:" ;
$out_author       = "Szerz&#337;" ;
$out_mail         = "Mail" ;
$out_site         = "Honlap" ;
$out_home         = "Kezd&#337;lap" ;
$out_sitemap      = "Oldaltérkép";
$out_rendered     = "A diagramokat generálta: " ;
$out_generated2   = "További statisztikák:" ;
$out_easytimeline = "EasyTimeline táblák Wikipédiánként" ;
$out_categories   = "Kategóriák Wikipédiánként" ;
#couldnt translate last two because of different word order
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "GB" ;
$out_megabytes    = "MB" ;
$out_kilobytes    = "kB" ;
$out_bytes        = "B" ;
$out_million      = "M" ;
$out_thousand     = "k" ;

$out_date         = "Dátum" ;
$out_year         = "év" ;
$out_month        = "hónap" ;
$out_mean         = "Átlag" ;
$out_growth       = "Növekedés" ;
$out_total        = "Összesen" ;
$out_bars         = "Oszlopok" ;
$out_words        = "szavak száma" ;
$out_zoom         = "Nagyítás" ;
$out_scripts      = "Szkriptek" ;

$out_new          = "új" ;
$out_all          = "összes" ;
$out_all2         = "összes" ;

$out_conversions1 = "" ;
$out_conversions2 = " (fél-)automatikus konverzió alkalmazva." ;

$out_phaseIII     = "Az oldal csak a <a href='http://www.mediawiki.org'>MediaWiki</a> szoftverrel m&#369;köd&#337; Wikipédiákat tartalmazza." ;

$out_svg_viewer   = "Az oldal megtekintéséhez szükséged lesz egy " .
                    "SVG megjelenít&#337;re. MS Explorerre Win/Mac alatt ilyen az (ingyenes) <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a>" ;
$out_rendering    = "Megjelenítés folyamatban...." ;


$out_sort_order   = "A Wikipédiák a bels&#337; (nem redirekt) linkek száma alapján vannak rendezve<br>" .
                    "Ez igazságosabb összehasonlítási alapnak t&#369;nik, mint a cikkek száma vagy az adatbázis mérete:<br>" .
                    "A cikkek száma nem sokat jelent, mert egyes Wikipédiák f&#337;leg rövid cikkeket tartalmaznak,<br>" .
                    "vagy tele vannak automatikusan generált cikkekkel, más Wikipédiák pedig kevesebb, de hosszabb, kézzel írt cikkb&#337;l állnak.<br>" .
                    "Az adatbázis mérete függ a kódolástól (a unicode karakterek több helyet foglalnak),<br>" .
                    "és attól, mennyi jelentést hordoz egy karakter (a kínai karakterek például teljes szavak).<br>" ;

$out_webalizer_note = "Figyelem: a Webalizer adatok nem mindig elérhet&#337;ek. A 2003. decemberi alacsony számokat egy szerverkiesés okozta." ;
$out_not_included = "Not included" ; #new

$out_average_1    = "átlagos érték a mutatott hónapokban" ;
$out_growth_1     = "átlagos havi növekedés a mutatott hónapokban" ;
$out_formula      = "képlet" ;
$out_value        = "eredmény" ;
$out_monthes      = "hónap" ;
$out_skip_values  = "(nem szerepelnek azok a Wikipédiák, amiknél az érték 10-nél kisebb)" ;

$out_history      = "  Figyelem: az alsó pár hónapra adott értékek túl alacsonyak. " .
                    "A korai napokban a laptörténet nem mindig &#337;rz&#337;dött meg." ;

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

$out_tbl1_intro   = "[[2]], a közelmúltban aktív wikipédista " .
                    "a szerkesztéseik száma szerint rendezve" ;
$out_tbl1_intro2  = "csak a szócikkszerkesztések számítanak, vitalapok stb. nem" ;
$out_tbl1_intro3  = "&Delta; = változás a rangsorban 30 nap alatt" ;

$out_tbl1_hdr1    = "Felhasználó" ;
$out_tbl1_hdr2    = "Szerkesztés" ;
$out_tbl1_hdr3    = "Els&#337; szerkesztés" ;
$out_tbl1_hdr4    = "Utolsó szerkesztés" ;
$out_tbl1_hdr5    = "dátum" ;
$out_tbl1_hdr6    = "nappal<br>ezel&#337;tt" ;
$out_tbl1_hdr7    = "összesen" ;
$out_tbl1_hdr8    = "utolsó<br>30 napon" ;
$out_tbl1_hdr9    = "helyezés" ;
$out_tbl1_hdr10   = "most" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Szócikkek" ;
$out_tbl1_hdr13   = "Egyéb" ;

$out_tbl2_intro  = "[[3]], a közelmúltban távollev&#337; wikipédista, " .
                   "a szerkesztéseik száma szerint rendezve" ;

$out_tbl3_intro   = "A regisztrált, aktív wikipédisták számának növekedése, és tevékenységük" ;

$out_tbl3_hdr1a   = "Wikipédisták" ;
$out_tbl3_hdr1e   = "Szócikkek" ;
$out_tbl3_hdr1l   = "Adatbázis" ;
$out_tbl3_hdr1o   = "Linkek" ;
$out_tbl3_hdr1t   = "Napi használat" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(regisztrált&nbsp;felhasználók)" ;
$out_tbl3_hdr1e2  = "(redirekteket&nbsp;kivéve)" ;

$out_tbl3_hdr2a   = "összesen" ;
$out_tbl3_hdr2b   = "új" ;
$out_tbl3_hdr2c   = "szerkesztései" ;
$out_tbl3_hdr2e   = "összesen" ;
$out_tbl3_hdr2f   = "új<br>naponta" ;
$out_tbl3_hdr2h   = "átlagosan" ;
$out_tbl3_hdr2j   = "nagyobb&nbsp;mint" ;
$out_tbl3_hdr2l   = "szerkesztés" ;
$out_tbl3_hdr2m   = "méret" ;
$out_tbl3_hdr2n   = "szó" ;
$out_tbl3_hdr2o   = "bels&#337;" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "kép" ;
$out_tbl3_hdr2r   = "küls&#337;" ;
$out_tbl3_hdr2s   = "redirekt" ;
$out_tbl3_hdr2t   = "oldal<br>lekérés" ;
$out_tbl3_hdr2u   = "látogatás" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "hivatalos" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;bet&#369;" ;
$out_tbl3_hdr3h   = "szerkesztés" ;
$out_tbl3_hdr3i   = "bájt" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonim felhasználó, a szerkesztéseik száma szerint rendezve" ;
$out_table6_footer = "Összesen %d anonim szerkesztés, összesen %d szerkesztésb&#337;l (%.0f\%)" ;

$out_tbl5_intro   = "Látogatottsági statisztikák (a <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> alapján; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definíciók</font></a>, " .
                    "<a href=''><font color='#000088'>diagram</font></a>)" ;
$out_tbl5_hdr1a   = "Napi átlag" ;
$out_tbl5_hdr1e   = "Havi összesítés" ;
$out_tbl5_hdr2a   = "Találatok (hit)" ;
$out_tbl5_hdr2b   = "Fájlok" ;
$out_tbl5_hdr2c   = "Lapok (page)" ;
$out_tbl5_hdr2d   = "Látogatások" ;
$out_tbl5_hdr2e   = "Oldalak (site)" ;
$out_tbl5_hdr2f   = "Kilobájtok" ;
$out_tbl5_hdr2g   = "Látogatások" ;
$out_tbl5_hdr2h   = "Lapok (page)" ;
$out_tbl5_hdr2i   = "Fájlok" ;
$out_tbl5_hdr2j   = "Találatok (hit)" ;

$out_tbl7_intro   = "Adatbázisrekordok névterenként / Kategorizált cikkek<p>" .
                    "<small>1) A sablon segítségével beillesztett kategóriák nincsenek beleszámolva.</small>" ;
$out_tbl7_hdr_ns  = "Névtér" ;
$out_tbl7_hdr_ca  = "Kategorizált<br>cikkek <sup>1</sup>" ;

$out_tbl8_intro = "Szócikk-szerkesztések megoszlása a wikipédisták között"  ;

$out_tbl9_intro   = "A [[5]] legtöbbet szerkesztett szócikk (> 25 szerkesztés)"  ;

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Szócikk", "User", "Wikipédia", "Kép", "MediaWiki", "Sablon", "Segítség", "Kategória") ;

@out_tbl3_legend  = (
"Wikipédisták, akiknek legalább 10 szerkesztésük van",
"Azon wikipédisták számának a növekedése, akiknek legalább 10 szerkesztésük van",
"Wikipédisták, akiknek legalább 5 szerkesztésük van ebben a hónapban",
"Wikipédisták, akiknek legalább 100 szerkesztésük van ebben a hónapban",
"Szócikkek, amikben legalább egy bels&#337; link van",
"Szócikkek, amikben legalább egy bels&#337; link és 200 karakternyi olvasható szöveg van, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a wiki- és html kódok, rejtett linkek, felzetek stb. nem számítanak bele<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(a többi oszlop a hivatalos számlálási módszeren alapul)",
"Egy napra es&#337; új szóikkek száma az elmúlt hónapban",
"A cikkenkénti változatok átlagos száma",
"Átlagos cikkméret bájtban",
"Legalább 0.5 Kb olvasható szöveget (lásd F) tartalmazó szócikkek száma",
"Legalább 2 Kb olvasható szöveget (lásd F) tartalmazó szócikkek száma",
"Szerkesztések száma az elm&#337;lt hónapban (mozgatásokat és anonim szerkeszt&#337;ket is beleértve)",
"Az összes szócikk együttes mérete (a redirekteket is beleértve)",
"Szavak száma (redirekteket, html/wiki kódot és rejtett linkeket nem számítva)",
"Bels&#337; linkek száma (redirekteket, csonkokat és linklistákat nem számítva)",
"Más Wikipédiákba mutató linkek együttes száma",
"Képek száma",
"Más oldalakra (site) vezet&#337; linkek száma",
"Redirektek száma",
"Lapletöltések napi száma (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definíció</font></a> a <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> szerint)",
"Látogatások napi száma (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definíció</font></a> a <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> szerint)",
"Az utóbbi hónapok adatai"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipédisták, akiknek egy hét alatt 5 vagy több szerkesztése volt",
"Wikipédisták, akiknek egy hét alatt 25 vagy több szerkesztése volt"
) ;

$out_legend_daily_edits = "Szerkesztések napi bontásban (redirekteket és anonim szerkesztéseket beleszámítva)" ;
$out_report_description_daily_edits = "Szerkesztések napi bontásban" ;
$out_report_description_edits       = "Szerkesztések havi/napi bontásban" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Résztvev&#337;k",
"Új wikipédisták",
"Aktív wikipédisták",
"Nagyon aktív wikipédisták",
"Szócikkek száma (hivatalos)",
"Szócikkek száma (alternatív)",
"Új szócikk/nap",
"Szerkesztés/szócikk",
"Bájt/szócikk",
"0.5 Kb-nál nagyobb cikkek",
"2 Kb-nál nagyobb cikkek",
"Szerkesztés/hó",
"Adatbázisméret",
"Szavak száma",
"Bels&#337; linkek",
"Linkek más Wikipédiákra",
"Képek",
"Weblinkek",
"Redirektek",
"Oldallekérés/nap",
"Látogatás/nap",
"Áttekintés"
) ;

# lines ending with # are untranslated

$out_languages {"aa"} = "Afar" ; #
$out_languages {"ab"} = "Abkhazian" ; #
$out_languages {"af"} = "Afrikaans" ;
$out_languages {"ak"} = "Akana" ; #
$out_languages {"als"} = "elzászi" ; #
$out_languages {"am"} = "Amharic" ; #
$out_languages {"an"} = "Aragonese" ; #
$out_languages {"ang"} = "Anglo-Saxon" ; #
$out_languages {"ar"} = "arab" ;
$out_languages {"as"} = "Assamese" ; #
$out_languages {"ast"} = "asztúriai" ;
$out_languages {"av"} = "Avienan" ; #
$out_languages {"ay"} = "Aymara" ; #
$out_languages {"az"} = "Azerbaijani" ; #
$out_languages {"ba"} = "Bashkir" ; #
$out_languages {"be"} = "fehérorosz" ;
$out_languages {"bg"} = "bolgár" ;
$out_languages {"bh"} = "Bihari" ; #
$out_languages {"bi"} = "Bislama" ; #
$out_languages {"bn"} = "Bengali" ; #
$out_languages {"bo"} = "Tibetan" ; #
$out_languages {"br"} = "Breton" ; #
$out_languages {"bs"} = "bosnyák" ;
$out_languages {"bug"} = "Buginese" ; #
$out_languages {"ca"} = "katalán" ;
$out_languages {"ch"} = "Chamoru" ; #
$out_languages {"cho"} = "Chotaw" ; #
$out_languages {"co"} = "korzikai" ;
$out_languages {"cr"} = "Cree" ; #
$out_languages {"cs"} = "cseh" ;
$out_languages {"cy"} = "walesi" ;
$out_languages {"da"} = "dán" ;
$out_languages {"de"} = "német" ;
$out_languages {"dv"} = "Divehi" ; #
$out_languages {"dz"} = "Dzongkha" ; #
$out_languages {"ee"} = "Ewe" ; #
$out_languages {"el"} = "görög" ;
$out_languages {"en"} = "angol" ;
$out_languages {"eo"} = "eszperantó" ;
$out_languages {"es"} = "spanyol" ;
$out_languages {"et"} = "észt" ;
$out_languages {"eu"} = "baszk" ;
$out_languages {"fa"} = "perzsa" ;
$out_languages {"fi"} = "finn" ;
$out_languages {"fj"} = "Fijian" ; #
$out_languages {"fo"} = "Faeroese" ; #
$out_languages {"fr"} = "francia" ;
$out_languages {"fy"} = "fríz" ;
$out_languages {"ga"} = "ír" ;
$out_languages {"gay"} = "Gayo" ; #
$out_languages {"gd"} = "skót" ;
$out_languages {"gl"} = "gallego" ;
$out_languages {"gn"} = "Guarani" ; #
$out_languages {"got"} = "Gothic" ; #
$out_languages {"gu"} = "gudzsarati" ;
$out_languages {"gv"} = "Manx Gaelic" ; #
$out_languages {"ha"} = "Hausa" ; #
$out_languages {"haw"} = "Hawaiian" ; #
$out_languages {"he"} = "héber" ;
$out_languages {"hi"} = "hindi" ;
$out_languages {"hr"} = "horvát" ;
$out_languages {"ht"} = "Haitian" ; #
$out_languages {"hu"} = "magyar" ;
$out_languages {"hy"} = "Armenian" ; #
$out_languages {"ia"} = "interlingua" ;
$out_languages {"iba"} = "Iban" ; #
$out_languages {"id"} = "indonéz" ;
$out_languages {"ik"} = "Inupiak" ; #
$out_languages {"io"} = "ido" ;
$out_languages {"is"} = "izlandi" ;
$out_languages {"it"} = "olasz" ;
$out_languages {"iu"} = "Inuktitut" ; #
$out_languages {"ja"} = "japán" ;
$out_languages {"jv"} = "jávai" ;
$out_languages {"ka"} = "Georgian" ; #
$out_languages {"kaw"} = "Kawi" ; #
$out_languages {"kk"} = "Kazakh" ; #
$out_languages {"kl"} = "Greenlandic" ; #
$out_languages {"km"} = "Cambodian" ; #
$out_languages {"kn"} = "Kannada" ; #
$out_languages {"ko"} = "koreai" ;
$out_languages {"ks"} = "Kashmiri" ; #
$out_languages {"ku"} = "kurd" ;
$out_languages {"ky"} = "Kirghiz" ; #
$out_languages {"la"} = "latin" ;
$out_languages {"lb"} = "luxemburgi" ;
$out_languages {"li"} = "Limburguish" ; #
$out_languages {"ln"} = "Lingala" ; #
$out_languages {"lo"} = "Laotian" ; #
$out_languages {"ls"} = "Latino Sine Flexione" ; #
$out_languages {"lt"} = "litván" ;
$out_languages {"lv"} = "lett" ;
$out_languages {"mad"} = "Madurese" ; #
$out_languages {"mak"} = "Makasar" ; #
$out_languages {"mg"} = "Malagasy" ; #
$out_languages {"mi"} = "Maori" ; #
$out_languages {"mk"} = "Macedonian" ; #
$out_languages {"ml"} = "Malayalam" ; #
$out_languages {"mn"} = "Mongolian" ; #
$out_languages {"mo"} = "Moldavian" ; #
$out_languages {"mr"} = "Marathi" ; #
$out_languages {"ms"} = "maláj" ;
$out_languages {"mt"} = "Maltese" ; #
$out_languages {"mus"} = "Muskogee" ; #
$out_languages {"my"} = "Burmese" ; #
$out_languages {"na"} = "Nauru" ; #
$out_languages {"nah"} = "Nahuatl" ; #
$out_languages {"nds"} = "alsószász" ;
$out_languages {"ne"} = "Nepali" ; #
$out_languages {"nl"} = "holland" ;
$out_languages {"nn"} = "norvég (nynorsk)" ;
$out_languages {"no"} = "norvég" ;
$out_languages {"nv"} = "Navayo" ; #
$out_languages {"oc"} = "Occitan" ; #
$out_languages {"om"} = "Oromo" ; #
$out_languages {"or"} = "Oriya" ; #
$out_languages {"pa"} = "Punjabi" ; #
$out_languages {"pl"} = "lengyel" ;
$out_languages {"ps"} = "Pashto" ; #
$out_languages {"pt"} = "portugál" ;
$out_languages {"qu"} = "Quechua" ; #
$out_languages {"rm"} = "Rhaeto-Romance" ; #
$out_languages {"rn"} = "Kirundi" ; #
$out_languages {"ro"} = "román" ;
$out_languages {"roa_rup"} = "Aromanian" ; #
$out_languages {"ru"} = "orosz" ;
$out_languages {"rw"} = "Kinyarwanda" ; #
$out_languages {"sa"} = "szanszkrit" ;
$out_languages {"sc"} = "Sardinian" ; #
$out_languages {"scn"} = "Sicilian" ; #
$out_languages {"sd"} = "Sindhi" ; #
$out_languages {"se"} = "Northern Sami" ; #
$out_languages {"sg"} = "Sangro" ; #
$out_languages {"sh"} = "szerb-horvát" ;
$out_languages {"si"} = "Singhalese" ; #
$out_languages {"simple"} = "egyszer&#369;&nbsp;angol" ;
$out_languages {"sk"} = "szlovák" ;
$out_languages {"sl"} = "szlovén" ;
$out_languages {"sm"} = "Samoan" ; #
$out_languages {"sn"} = "Shona" ; #
$out_languages {"so"} = "Somalian" ; #
$out_languages {"sq"} = "albán" ;
$out_languages {"sr"} = "szerb" ;
$out_languages {"ss"} = "Siswati" ; #
$out_languages {"st"} = "Seshoto" ; #
$out_languages {"su"} = "Sundanese" ; #
$out_languages {"sv"} = "svéd" ;
$out_languages {"sw"} = "szuahéli" ;
$out_languages {"ta"} = "tamil" ;
$out_languages {"te"} = "Telugu" ; #
$out_languages {"tg"} = "Tajik" ; #
$out_languages {"th"} = "thai" ;
$out_languages {"ti"} = "Tigrinya" ; #
$out_languages {"tk"} = "Turkmen" ; #
$out_languages {"tl"} = "tagalog" ;
$out_languages {"tn"} = "Setswana" ; #
$out_languages {"to"} = "Tonga" ; #
$out_languages {"tr"} = "török" ;
$out_languages {"ts"} = "Tsonga" ; #
$out_languages {"tt"} = "tatár" ;
$out_languages {"tw"} = "Twi" ; #
$out_languages {"ty"} = "Tahitian" ; #
$out_languages {"ug"} = "ujgur" ;
$out_languages {"uk"} = "ukrán" ;
$out_languages {"ur"} = "urdu" ;
$out_languages {"uz"} = "üzbég" ;
$out_languages {"vi"} = "vietnami" ;
$out_languages {"vo"} = "volapük" ;
$out_languages {"wa"} = "vallon" ;
$out_languages {"wo"} = "Wolof" ; #
$out_languages {"yi"} = "jiddis" ;
$out_languages {"yo"} = "Yoruba" ; #
$out_languages {"za"} = "Zhuang" ; #
$out_languages {"zh"} = "kínai" ;
$out_languages {"zh_min_nan"} = "minnan" ;
$out_languages {"zu"} = "zulu" ;
$out_languages {"zz"} = "az&nbsp;összes&nbsp;nyelv" ;
}

# end of file marker, do not remove:
1;

