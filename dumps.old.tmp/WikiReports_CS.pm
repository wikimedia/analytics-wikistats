#!/usr/bin/perl

# please specify all accented characters as utf-8 or
# as html codes like &agrave; or $#224;
# see for a list of html codes see
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_CS
{
$out_thousands_separator = "&nbsp;" ;
$out_decimal_separator   = "," ;

$out_statistics   = "Statistiky Wikipedie" ;
$out_charts       = "Grafy Wikipedie" ;
$out_btn_tables   = "Tabulky" ;
$out_btn_table    = "Tabulka" ;
$out_btn_charts   = "Grafy" ;

$out_wikipedia    = "Wikipedie" ;
$out_wikipedias   = "Wikipedie" ;
$out_wikipedians   = "wikipedisté" ;

$out_wiktionary   = "Wikislovník" ;
$out_wiktionaries = "Wikislovníku" ;
$out_wiktionarians   = "u&#382;ivatelé Wikislovníku" ;

$out_wikibook        = "Wikiknihy" ;
$out_wikibooks       = "Wikiknihy" ;
$out_wikibookies     = "u&#382;ivatelé Wikiknih" ;

$out_wikiquote       = "Wikicitáty" ;
$out_wikiquotes      = "Wikicitáty" ;
$out_wikiquotarians  = "u&#382;ivatelé wikicitát&#367;" ;

$out_wikinews        = "Wikinews" ;
$out_wikinewssites   = "Wikinews" ;
$out_wikireporters   = "Wikireporté&#345;i" ;

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Wikispecial" ;
$out_wikispecials    = "Wikispecials" ;
$out_wikispecialists = "Auto&#345;i" ;

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "Servery Wikimedia" ;

$out_comparisons  = "Porovnání" ;

$out_creation_history = "Chronologie zakládání" ;
$out_accomplishments  = "Výsledky" ;
$out_created          = "Vytvo&#345;eno" ;
$average_increase     = "Pr&#367;m&#283;rný r&#367;st za m&#283;síc" ;

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "V&#353;echna data a obrázky na této stránce jsou volné dílo (public domain)." ;
$out_generated    = "Vygenerováno: " ;
$out_sqlfiles     = "ze soubor&#367; SQL dumpu vytvo&#345;eného: " ;
$out_version      = "Verze skriptu:" ;
$out_author       = "Autor" ;
$out_mail         = "E-mail" ;
$out_site         = "Web" ;
$out_home         = "Home" ;
$out_sitemap      = "Mapa serveru";
$out_rendered     = "Grafy vykresleny pomocí " ;
$out_generated2   = "Také vygenerováno:" ;
$out_easytimeline = "Seznam graf&#367; EasyTimeline podle Wikipedie" ;
$out_categories   = "P&#345;ehled kategorií podle Wikipedie" ;
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistiky pro" ;
$out_stats_per    = "Statistiky podle " ;

$out_gigabytes    = "GB" ;
$out_megabytes    = "MB" ;
$out_kilobytes    = "kB" ;
$out_bytes        = "B" ;
$out_million      = "M" ;
$out_thousand     = "k" ;

$out_date         = "Datum" ;
$out_year         = "rok" ;
$out_month        = "m&#283;síc" ;
$out_mean         = "St&#345;ední hodnota" ;
$out_growth       = "R&#367;st" ;
$out_total        = "Celkem" ;
$out_bars         = "Pruh&#367;" ;
$out_words        = "Slova" ;
$out_zoom         = "p&#345;iblí&#382;ení" ;
$out_scripts      = "Skripty" ;

$out_new          = "nové" ;
$out_all          = "v&#353;ichni" ;
$out_all2         = "v&#353;echny" ;

$out_conversions1 = "" ;
$out_conversions2 = " byla pou&#382;ita (polo-)automatická konverze." ;

$out_phaseIII     = "Jsou zahrnuty pouze Wikipedii, které b&#283;&#382;í na softwaru <a href='http://www.mediawiki.org'>MediaWiki</a>." ;

$out_svg_viewer   = "Abyste mohli prohlí&#382;et obsah této stránky pot&#345;ebujete" .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "pro MS Explorer Win/Mac" ;
$out_rendering    = "Probíhá vykreslování.... &#268;ekejte, prosím" ;

$out_sort_order   = "Wikipedie jsou se&#345;azeny podle po&#269;tu interních odkaz&#367; (vyjma p&#345;esm&#283;rování)<br>" .
                    "Toto je nejspí&#353;e spravedliv&#283;j&#353;í srovnání ne&#382; celkový po&#269;et &#269;lánk&#367; &#269;i velikost databáze:<br>" .
                    "Po&#269;et &#269;lánk&#367; není tak vypovídající, proto&#382;e n&#283;které Wikipedie obsahují mnoho krátkých &#269;lánk&#367;,<br>" .
                    "a dokonce automaticky vytvá&#345;ené &#269;lánky, zatímco jiné Wikipedie mají sice mén&#283; &#269;lánk&#367;, ale dlouhé a poctiv&#283; psané.<br>" .
                    "Velikost databáze závisí na kódování (znaky v unicode mohou mít n&#283;kolik bajt&#367;) a <br>" .
                    "na mno&#382;ství informací, které jeden znak p&#345;edává (nap&#345;. &#269;ínský znak m&#367;&#382;e být celé slovo).<br>" ;

$out_webalizer_note = "Poznámka: Generovaná data nejsou konzistentní. Nízké hodnoty v prosinci Dec 2003 jsou výsledkem vá&#382;ných výpadk&#367; serveru." ;
$out_not_included = "Not included" ; #new

$out_average_1    = "pr&#367;m&#283;rné hodnoty b&#283;hem zobrazených m&#283;síc&#367;" ;
$out_growth_1     = "pr&#367;m&#283;rný m&#283;sí&#269;ní r&#367;st b&#283;hem zobrazených m&#283;síc&#367;" ;
$out_formula      = "vzorec" ;
$out_value        = "hodnota" ;
$out_monthes      = "m&#283;síce" ;
$out_skip_values  = "(Wikipedie s hodnotou < 10 jsou vynechány)" ;

$out_history      = "Poznámka: Hodnoty pro první m&#283;síce jsou p&#345;íli&#353; nízké. " .
                    "Historie verzí nebyla v po&#269;átcích v&#382;dy uchována." ;

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

$out_tbl1_intro   = "[[2]] nedávno aktivních wikipedist&#367;, " .
                    "se&#345;azeno podle po&#269;tu editací:" ;
$out_tbl1_intro2  = "jsou po&#269;ítány pouze editace v &#269;láncích, nikoliv na diskuzních stránkách, apod." ;
$out_tbl1_intro3  = "&Delta; = zm&#283;na po&#345;adí za 30 dní" ;

$out_tbl1_hdr1    = "U&#382;ivatel" ;
$out_tbl1_hdr2    = "Editace" ;
$out_tbl1_hdr3    = "První editace" ;
$out_tbl1_hdr4    = "Poslední editace" ;
$out_tbl1_hdr5    = "datum" ;
$out_tbl1_hdr6    = "uplynulých<br>dn&#367;" ;
$out_tbl1_hdr7    = "celkem" ;
$out_tbl1_hdr8    = "posledních<br>30 dn&#367;" ;
$out_tbl1_hdr9    = "po&#345;adí" ;
$out_tbl1_hdr10   = "te&#271;" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "&#268;lánky" ;
$out_tbl1_hdr13   = "Ostatní" ;

$out_tbl2_intro  = "[[3]] poslední dobou neaktivních wikipedist&#367;, " .
                   "se&#345;azeno podle po&#269;tu editací:" ;

$out_tbl3_intro   = "R&#367;st po&#269;tu registrovaných aktivních wikipedist&#367; a jejich aktivita" ;

$out_tbl3_hdr1a   = "Wikipedisté" ;
$out_tbl3_hdr1e   = "&#268;lánky" ;
$out_tbl3_hdr1l   = "Databáze" ;
$out_tbl3_hdr1o   = "Odkazy" ;
$out_tbl3_hdr1t   = "Denní náv&#353;t&#283;vnost" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registrovaní u&#382;ivatelé)" ;
$out_tbl3_hdr1e2  = "(vyjma p&#345;esm&#283;rování)" ;

$out_tbl3_hdr2a   = "celkem" ;
$out_tbl3_hdr2b   = "noví" ;
$out_tbl3_hdr2c   = "editace" ;
$out_tbl3_hdr2e   = "po&#269;et" ;
$out_tbl3_hdr2f   = "nové<br>za&nbsp;den" ;
$out_tbl3_hdr2h   = "pr&#367;m&#283;rn&#283;" ;
$out_tbl3_hdr2j   = "více&nbsp;ne&#382;" ;
$out_tbl3_hdr2l   = "editace" ;
$out_tbl3_hdr2m   = "velikost" ;
$out_tbl3_hdr2n   = "slova" ;
$out_tbl3_hdr2o   = "vnit&#345;ní" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "soubory" ;
$out_tbl3_hdr2r   = "externí" ;
$out_tbl3_hdr2s   = "p&#345;esm&#283;rování" ;
$out_tbl3_hdr2t   = "dotaz&#367;<br>na&nbsp;stránky" ;
$out_tbl3_hdr2u   = "náv&#353;t&#283;v" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficiální" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;z." ;
$out_tbl3_hdr3h   = "editací" ;
$out_tbl3_hdr3i   = "bajt&#367;" ;
$out_tbl3_hdr3j   = "0,5&nbsp;kB" ;
$out_tbl3_hdr3k   = "2&nbsp;kB" ;

$out_tbl6_intro  = "[[4]] anonymních u&#382;ivatel&#367;, se&#345;azeno podle po&#269;tu editací" ;
$out_table6_footer = "Celkem %d editací ud&#283;lali anonymní u&#382;ivatel&#367;, z celkového po&#269;tu %d editací (%.0f\%)" ;

$out_tbl5_intro   = "Statistika náv&#353;t&#283;v (zalo&#382;ena na výstupu programu <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definice</font></a>, " .
                    "<a href=''><font color='#000088'>graf</font></a>)" ;
$out_tbl5_hdr1a   = "Denní pr&#367;m&#283;r" ;
$out_tbl5_hdr1e   = "Celkem za m&#283;síc" ;
$out_tbl5_hdr2a   = "Po&#382;adavk&#367;" ;
$out_tbl5_hdr2b   = "Soubor&#367;" ;
$out_tbl5_hdr2c   = "Stránek" ;
$out_tbl5_hdr2d   = "Náv&#353;t&#283;v" ;
$out_tbl5_hdr2e   = "Stanic" ;
$out_tbl5_hdr2f   = "Kilobajt&#367;" ;
$out_tbl5_hdr2g   = "Náv&#353;t&#283;v" ;
$out_tbl5_hdr2h   = "Stránek" ;
$out_tbl5_hdr2i   = "Soubor&#367;" ;
$out_tbl5_hdr2j   = "Po&#382;adavk&#367;" ;

$out_tbl7_intro   = "Záznamy v databázi podle jmenného prostoru / Kategorizované &#269;lánky<p>" .
                    "<small>1) Kategorie vkládané p&#345;es &#353;ablonu nejsou rozpoznány.</small>" ;
$out_tbl7_hdr_ns  = "Jmenný prostor" ;
$out_tbl7_hdr_ca  = "Kategorizované<br>&#269;lánky <sup>1</sup>" ;

$out_tbl8_intro = "Rozlo&#382;ení editací &#269;lánk&#367; na wikipedisty"  ;

$out_tbl9_intro   = "[[5]] nejvíce editovaných &#269;lánk&#367; (> 25 editací)"  ;

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("&#268;lánek", "U&#382;ivatel", "Projekt", "Soubor", "MediaWiki", "&#352;ablona", "Nápov&#283;da", "Kategorie") ;

@out_tbl3_legend  = (
"Wikipedisté, kte&#345;í editovali alespo&#328; 10krát od svého p&#345;íchodu",
"Nár&#367;st wikipedist&#367;, kte&#345;í editovali alespo&#328; 10krát od svého p&#345;íchodu",
"Wikipedisté kte&#345;í editovali 5 a více krát v tomto m&#283;síci",
"Wikipedisté, kte&#345;í editovali 100 a více krát v tomto m&#283;síci",
"&#268;lánky, které obsahují alespo&#328; jeden interní odkaz",
"&#268;lánky, které obsahují alesp&#328; jeden interní odkaz a 200 znak&#367; &#269;itelného textu, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;nezapo&#269;ítávají se wiki- a html kódy, skryté odkazy, apod.; také hlavi&#269;ky se nepo&#269;ítají<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(jiné sloupce pou&#382;ívají pro po&#269;ítání &#269;lánk&#367; oficiální metodu)",
"Nové &#269;lánky za den v uplynulém m&#283;síci",
"Pr&#367;m&#283;rný po&#269;et editací na &#269;lánek",
"Pr&#367;m&#283;rná velikost &#269;lánku v bajtech",
"Procento &#269;lánk&#367; s alespo&#328; 0,5 kB &#269;itelného textu (viz F)",
"Procento &#269;lánk&#367; s alespo&#328; 2 kB &#269;itelného textu (viz F)",
"Po&#269;et editací v m&#283;síci (v&#269;etn&#283; p&#345;esm&#283;rování a neregistrovaných u&#382;ivatel&#367;)",
"Celková velikost v&#353;ech &#269;lánk&#367; (v&#269;etn&#283; p&#345;esm&#283;rování)",
"Celkový po&#269;et slov (vyjma p&#345;esm&#283;rování, wiki/html kódy a skryté odkazy)",
"Celkový po&#269;et interních odkaz&#367; (vyjma p&#345;esm&#283;rování, pahýl&#367; a seznam&#367;)",
"Celkový po&#269;et odkaz&#367; na jiné Wikipedie",
"Celkový po&#269;et p&#345;ítomných soubor&#367;",
"Celkový po&#269;et externích odkaz&#367;",
"Celkový po&#269;et p&#345;esm&#283;rování",
"Dotaz&#367; na stránky za den (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, zalo&#382;eno na výstupu programu <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Náv&#353;t&#283;v za den (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definice</font></a>, zalo&#382;eno na výstupu programu <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Data za poslední m&#283;síce"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedisté, kte&#345;í editovali 5 a více krát v týdnu",
"Wikipedisté, kte&#345;í editovali 25 a více krát v týdnu"
) ;

$out_legend_daily_edits = "Editací za den (v&#269;etn&#283; p&#345;esm&#283;rování a neregistrovaných u&#382;ivatel&#367;)" ;
$out_report_description_daily_edits = "Editací za den" ;
$out_report_description_edits       = "Editací za m&#283;síc/den" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"P&#345;isp&#283;vatelé",
"Noví wikipedisté",
"Aktivní wikipedisté",
"Velmi aktivní wikipedisté",
"Po&#269;et &#269;lánk&#367; (oficiáln&#283;)",
"Po&#269;et &#269;lánk&#367; (alternativn&#283;)",
"Nové &#269;lánky za den",
"Editací na &#269;lánek",
"Bajt&#367; na &#269;lánek",
"&#268;lánky v&#283;t&#353;í ne&#382; 0,5 kB",
"&#268;lánky v&#283;t&#353;í 2 kB",
"Editace za m&#283;síc",
"Velikost databáze",
"Slova",
"Interní odkazy",
"Odkazy na jiné Wikipedie",
"Soubory",
"Externí odkazy",
"P&#345;esm&#283;rování",
"Dotaz&#367; na stránky za den",
"Náv&#353;t&#283;v za den",
"P&#345;ehled"
) ;

# if you don't know all translation please mark untranslated ones

$out_languages {"aa"} = "afar&#353;tina" ;
$out_languages {"ab"} = "abchaz&#353;tina" ;
$out_languages {"af"} = "afrikán&#353;tina" ;
$out_languages {"ak"} = "akan&#353;tina" ;
$out_languages {"als"} = "alsas&#353;tina" ;
$out_languages {"am"} = "amhar&#353;tina" ;
$out_languages {"an"} = "aragon&#353;tina" ;
$out_languages {"ang"} = "anglosa&#353;tina" ;
$out_languages {"ar"} = "arab&#353;tina" ;
$out_languages {"as"} = "ásám&#353;tina" ;
$out_languages {"ast"} = "astur&#353;tina" ;
$out_languages {"av"} = "avar&#353;tina" ;
$out_languages {"ay"} = "ajmar&#353;tina" ;
$out_languages {"az"} = "ázebájd&#382;án&#353;tina" ;
$out_languages {"ba"} = "ba&#353;kir&#353;tina" ;
$out_languages {"be"} = "b&#283;loru&#353;tina" ;
$out_languages {"bg"} = "bulhar&#353;tina" ;
$out_languages {"bh"} = "bihár&#353;tina" ;
$out_languages {"bi"} = "bislam&#353;tina" ;
$out_languages {"bn"} = "bengál&#353;tina" ;
$out_languages {"bo"} = "tibet&#353;tina" ;
$out_languages {"br"} = "breton&#353;tina" ;
$out_languages {"bs"} = "bosen&#353;tina" ;
$out_languages {"bug"} = "bugi&#353;tina" ;
$out_languages {"ca"} = "katalán&#353;tina" ;
$out_languages {"ch"} = "&#269;amor&#353;tina" ;
$out_languages {"cho"} = "choctaw&#353;tina" ;
$out_languages {"co"} = "korsi&#269;tina" ;
$out_languages {"cr"} = "krí" ;
$out_languages {"cs"} = "&#269;e&#353;tina" ;
$out_languages {"cy"} = "vel&#353;tina" ;
$out_languages {"da"} = "dán&#353;tina" ;
$out_languages {"de"} = "n&#283;m&#269;ina" ;
$out_languages {"dv"} = "divehi" ;
$out_languages {"dz"} = "dzongkha" ;
$out_languages {"ee"} = "ewe" ;
$out_languages {"el"} = "&#345;e&#269;tina" ;
$out_languages {"en"} = "angli&#269;tina" ;
$out_languages {"eo"} = "esperanto" ;
$out_languages {"es"} = "&#353;pan&#283;l&#353;tina" ;
$out_languages {"et"} = "eston&#353;tina" ;
$out_languages {"eu"} = "baski&#269;tina" ;
$out_languages {"fa"} = "per&#353;tina" ;
$out_languages {"fi"} = "fin&#353;tina" ;
$out_languages {"fj"} = "fid&#382;ij&#353;tina" ;
$out_languages {"fo"} = "faer&#353;tina" ;
$out_languages {"fr"} = "francouz&#353;tina" ;
$out_languages {"fy"} = "frí&#353;tina" ;
$out_languages {"ga"} = "ir&#353;tina" ;
$out_languages {"gay"} = "gayo" ;
$out_languages {"gd"} = "skot&#353;tina" ;
$out_languages {"gl"} = "galicij&#353;tina" ;
$out_languages {"gn"} = "guaraní" ;
$out_languages {"got"} = "gót&#353;tina" ;
$out_languages {"gu"} = "gud&#382;arád&#353;tina" ;
$out_languages {"gv"} = "man&#353;tina" ;
$out_languages {"ha"} = "hausa" ;
$out_languages {"haw"} = "havaj&#353;tina" ;
$out_languages {"he"} = "hebrej&#353;tina" ;
$out_languages {"hi"} = "hind&#353;tina" ;
$out_languages {"hr"} = "chorvat&#353;tina" ;
$out_languages {"ht"} = "hait&#353;tina" ;
$out_languages {"hu"} = "ma&#271;ar&#353;tina" ;
$out_languages {"hy"} = "armén&#353;tina" ;
$out_languages {"ia"} = "interlingua" ;
$out_languages {"iba"} = "iban" ;
$out_languages {"id"} = "indoné&#353;tina" ;
$out_languages {"ik"} = "inupiak" ;
$out_languages {"io"} = "ido" ;
$out_languages {"is"} = "islan&#353;tina" ;
$out_languages {"it"} = "ital&#353;tina" ;
$out_languages {"iu"} = "inuktitut" ;
$out_languages {"ja"} = "japon&#353;tina" ;
$out_languages {"jv"} = "javán&#353;tina" ;
$out_languages {"ka"} = "gruzín&#353;tina" ;
$out_languages {"kaw"} = "kawi" ;
$out_languages {"kk"} = "kaza&#353;tina" ;
$out_languages {"kl"} = "grón&#353;tina" ;
$out_languages {"km"} = "kambod&#382;&#353;tina" ;
$out_languages {"kn"} = "kannad&#353;tina" ;
$out_languages {"ko"} = "korej&#353;tina" ;
$out_languages {"ks"} = "ka&#353;mír&#353;tina" ;
$out_languages {"ku"} = "kurd&#353;tina" ;
$out_languages {"ky"} = "kyrgyz&#353;tina" ;
$out_languages {"la"} = "latina" ;
$out_languages {"lb"} = "lucembur&#353;tina" ;
$out_languages {"li"} = "limbur&#353;tina" ;
$out_languages {"ln"} = "lingala" ;
$out_languages {"lo"} = "lao&#353;tina" ;
$out_languages {"ls"} = "Latino Sine Flexione" ;
$out_languages {"lt"} = "litev&#353;tina" ;
$out_languages {"lv"} = "loty&#353;&#353;tina" ;
$out_languages {"mad"} = "madur&#353;tina" ;
$out_languages {"mak"} = "makasar&#353;tina" ;
$out_languages {"mg"} = "malga&#353;&#353;tina" ;
$out_languages {"mi"} = "maor&#353;tina" ;
$out_languages {"mk"} = "makedon&#353;tina" ;
$out_languages {"ml"} = "malajálam&#353;tina" ;
$out_languages {"mn"} = "mongol&#353;tina" ;
$out_languages {"mo"} = "moldav&#353;tina" ;
$out_languages {"mr"} = "maráth&#353;tina" ;
$out_languages {"ms"} = "malaj&#353;tina" ;
$out_languages {"mt"} = "malt&#353;tina" ;
$out_languages {"mus"} = "krík" ;
$out_languages {"my"} = "barm&#353;tina" ;
$out_languages {"na"} = "nauru&#353;tina" ;
$out_languages {"nah"} = "nahuatl" ;
$out_languages {"nds"} = "dolnosa&#353;tina" ;
$out_languages {"ne"} = "nepál&#353;tina" ;
$out_languages {"nl"} = "nizozem&#353;tina" ;
$out_languages {"nn"} = "nor&#353;tina (Nynorsk)" ;
$out_languages {"no"} = "nor&#353;tina" ;
$out_languages {"nv"} = "navaho" ;
$out_languages {"oc"} = "okcitán&#353;tina" ;
$out_languages {"om"} = "oromo" ;
$out_languages {"or"} = "orij&#353;tina" ;
$out_languages {"pa"} = "pand&#382;áb&#353;tina" ;
$out_languages {"pl"} = "pol&#353;tina" ;
$out_languages {"ps"} = "pa&#353;tun&#353;tina" ;
$out_languages {"pt"} = "portugal&#353;tina" ;
$out_languages {"qu"} = "ke&#269;ua" ;
$out_languages {"rm"} = "retoromán&#353;tina" ;
$out_languages {"rn"} = "rund&#353;tina" ;
$out_languages {"ro"} = "rumun&#353;tina" ;
$out_languages {"roa_rup"} = "arumun&#353;tina" ;
$out_languages {"ru"} = "ru&#353;tina" ;
$out_languages {"rw"} = "kinyarwanda" ;
$out_languages {"sa"} = "sanskrt" ;
$out_languages {"sc"} = "sardin&#353;tina" ;
$out_languages {"scn"} = "sicil&#353;tina" ;
$out_languages {"sd"} = "sindh&#353;tina" ;
$out_languages {"se"} = "lapon&#353;tina" ;
$out_languages {"sg"} = "sango&#353;tina" ;
$out_languages {"sh"} = "srbochorvat&#353;tina" ;
$out_languages {"si"} = "sinhal&#353;tina" ;
$out_languages {"simple"} = "zjednodu&#353;ená&nbsp;angli&#269;tina" ;
$out_languages {"sk"} = "sloven&#353;tina" ;
$out_languages {"sl"} = "slovin&#353;tina" ;
$out_languages {"sm"} = "samoj&#353;tina" ;
$out_languages {"sn"} = "&#353;on&#353;tina" ;
$out_languages {"so"} = "somál&#353;tina" ;
$out_languages {"sq"} = "albán&#353;tina" ;
$out_languages {"sr"} = "srb&#353;tina" ;
$out_languages {"ss"} = "siswati" ;
$out_languages {"st"} = "jihosot&#353;tina" ;
$out_languages {"su"} = "sundán&#353;tina" ;
$out_languages {"sv"} = "&#353;véd&#353;tina" ;
$out_languages {"sw"} = "svahil&#353;tina" ;
$out_languages {"ta"} = "tamil&#353;tina" ;
$out_languages {"te"} = "telug&#353;tina" ;
$out_languages {"tg"} = "tád&#382;i&#269;tina" ;
$out_languages {"th"} = "thaj&#353;tina" ;
$out_languages {"ti"} = "tigri&#328;&#328;a" ;
$out_languages {"tk"} = "turkmen&#353;tina" ;
$out_languages {"tl"} = "tagal&#353;tina" ;
$out_languages {"tn"} = "&#269;wana" ;
$out_languages {"to"} = "tongán&#353;tina" ;
$out_languages {"tr"} = "ture&#269;tina" ;
$out_languages {"ts"} = "tsonga" ;
$out_languages {"tt"} = "tatar&#353;tina" ;
$out_languages {"tw"} = "&#357;wi&#353;tina" ;
$out_languages {"ty"} = "tahit&#353;tina" ;
$out_languages {"ug"} = "ujgur&#353;tina" ;
$out_languages {"uk"} = "ukrajin&#353;tina" ;
$out_languages {"ur"} = "urd&#353;tina" ;
$out_languages {"uz"} = "uzbe&#269;tina" ;
$out_languages {"vi"} = "vietnam&#353;tina" ;
$out_languages {"vo"} = "volapük" ;
$out_languages {"wa"} = "valon&#353;tina" ;
$out_languages {"wo"} = "wolof" ;
$out_languages {"yi"} = "jidi&#353;" ;
$out_languages {"yo"} = "jorub&#353;tina" ;
$out_languages {"za"} = "zhuang" ;
$out_languages {"zh"} = "&#269;ín&#353;tina" ;
$out_languages {"zh_min_nan"} = "minnan" ;
$out_languages {"zu"} = "zulu" ;
$out_languages {"zz"} = "V&#353;echny&nbsp;jazyky" ;
}

# please also give example of whole date
# different languages use different styles like :

# 13. dubna 2003
# 18. 8. 2003

# end of file marker, do not remove:
1;
