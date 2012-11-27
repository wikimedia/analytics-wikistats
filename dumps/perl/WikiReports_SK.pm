#!/usr/bin/perl

sub SetLiterals_SK
{
$out_statistics      = "&#352;tatistiky Wikipédie" ;
$out_charts          = "Grafy Wikipédie" ;
$out_btn_tables      = "Tabu&#318;ky" ;
$out_btn_table       = "Tabu&#318;ka" ;
$out_btn_charts      = "Grafy" ;

$out_wikipedia       = "Wikipédia" ;
$out_wikipedias      = "Wikipédie" ;
$out_wikipedians     = "wikipediáni" ;

$out_wiktionary      = "Wikislovník" ;
$out_wiktionaries    = "Wikislovníky" ;
$out_wiktionarians   = "wikislovníkari" ;

$out_wikibook        = "Wikiknihy" ;  # new
$out_wikibooks       = "Projekty Wikiknihy" ; # new
$out_wikibookies     = "Autori wikikníh" ; # new

$out_wikiquote       = "Wikicitáty" ;  # new
$out_wikiquotes      = "Projekty Wikicitáty" ; # new
$out_wikiquotarians  = "Zberatelia wikicitátov" ; # new

$out_wikinews        = "Wikinews" ;  # new
$out_wikinewssites   = "Projekty Wikinews" ; # new
$out_wikireporters   = "Wikireportéri" ; # new

$out_wikisources     = "Wikizdroj" ;  # new
$out_wikisourcesites = "Wikizdroje" ; # new
$out_wikilibrarians  = "Wikiknihovníci" ; # new

$out_wikispecial     = "&#352;peciálne wiki" ;  # new
$out_wikispecials    = "&#352;peciálne projekty wiki" ; # new
$out_wikispecialists = "Autori" ; # new

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "Projekty Wikimedia" ;

$out_comparisons     = "Porovnania" ;

$out_creation_history = "História vytvorených" ; # new
$out_accomplishments  = "Dosiahnuté" ; # new
$out_created          = "Vytvorené" ; # new
$average_increase     = "Priemerný mesa&#269;ný nárast" ; # new

$out_license      = "V&#353;etky dáta a obrázky na tejto stránke sú v public domain." ;
$out_generated    = "Vytvorené: " ;
$out_sqlfiles     = "z SQL dump súborov " ;
$out_version      = "Verzia skriptu:" ;
$out_author       = "Autor" ;
$out_mail         = "Email" ;
$out_site         = "Webová lokalita" ;
$out_home         = "Domov" ;
$out_sitemap      = "Mapa stránky";
$out_rendered     = "Grafy sú vykreslené pomocou " ;
$out_generated2   = "Tie&#382; vytvorené:" ;       # new
$out_easytimeline = "Grafy EasyTimeline" ; ; # new # Index to
$out_categories   = "Preh&#318;ad kategórií" ; # new # per Wikipedia
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "&#352;tatistika pre " ; # new
$out_stats_per    = "&#352;tatistika pre " ; # new
$out_documentation = "Dokumentácia: pozri <a href='http://meta.wikipedia.org/wiki/Wikistats'>Meta</a>" ; #new
$out_scripts      = "Skripty" ;

$out_gigabytes    = "GB" ;
$out_megabytes    = "MB" ;
$out_kilobytes    = "kB" ;
$out_bytes        = "B" ;
$out_million      = "M" ;
$out_thousand     = "k" ;

$out_date         = "Dátum" ;
$out_year         = "rok" ;
$out_month        = "mesiac" ;
$out_week         = "tý&#382;de&#328;" ;
$out_mean         = "Stred" ;
$out_growth       = "Rast" ;
$out_total        = "Celkom" ;
$out_bars         = "St&#314;pce" ;
$out_zoom         = "Priblí&#382;enie" ;

$out_new          = "nové" ; # new
$out_all          = "v&#353;etci" ; # new  (people)
$out_all2         = "v&#353;etky" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " pou&#382;itá (semi-)automatická konverzia." ;

$out_phaseIII     = "Sú zahrnuté iba Wikipédie be&#382;iace na softvéri <a href='http://www.mediawiki.org'>MediaWiki</a>." ;

$out_svg_viewer   = "Na zobrazovanie obsahu tejto stránky budete potrebova&#357; " .
                    "prehliada&#269; SVG, napr. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "pre MS Explorer Win/Mac (zadarmo)" ;

$out_rendering    = "Vykres&#318;ujem.... Prosím, &#269;akajte" ;

$out_sort_order   = "Wikipédie sú zoradené pod&#318;a interných odkazov (bez presmerovaní)<br>" .
                    "Zdá sa, &#382;e je to férovej&#353;ie pre porovnanie celkovej snahy na rozdiel od po&#269;tu &#269;lánkov alebo ve&#318;kosti databázy:<br>" .
                    "Po&#269;et &#269;lánkov nie je taký významným, ke&#271; uvá&#382;ime, &#382;e Wikipédie obsahujú preva&#382;ne krátke &#269;lánky<br>" .
                    "alebo dokonca automaticky generované &#269;lánky, kým iné Wikipédie obsahujú omnoho dlh&#353;ie &#269;lánky, v&#353;etky písané rukou.<br>" .
                    "Ve&#318;kos&#357; databázy závisí na pou&#382;itom kódovaní (znaky Unicode zaberajú nieko&#318;ko bajtov) a <br>" .
                    "na tom, aký význam reprezentuje jeden znak (napr. &#268;ínske znaky sú celé slová).<br>" ;

$out_comparison   = "Tu sú zahrnuté Wikipédie obsahujúce {xxx} alebo viac &#269;lánkov" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "priemerný po&#269;et za uvedené mesiace" ;
$out_growth_1     = "priemerný mesa&#269;ný nárast za uvedené mesiace" ;
$out_formula      = "vzorec" ;
$out_value        = "hodnota" ;
$out_monthes      = "mesiace" ;
$out_skip_values  = "(Wikipédie s hodnotou < 10 sú presko&#269;ené)" ;

$out_history      = "Pozn.: &#269;ísla pre prvý mesiac sú príli&#382; nízke. " .
                    "História revízií sa v za&#269;iatkoch nie v&#382;dy uchovávala." ;

$out_tbl1_intro   = "[[2]] nedávno aktívnych wikipediánov, " .
                    "zoradených pod&#318;a príspevkov" ;
$out_tbl1_intro2  = "po&#269;ítajú sa iba úpravy v &#269;lánkoch, nie úpravy na diskusných stránkach at&#271;" ;
$out_tbl1_intro3  = "&Delta; = zmena pozície v posledných 30 d&#328;och" ; # new

$out_tbl1_hdr1    = "Pou&#382;ívate&#318;" ;
$out_tbl1_hdr2    = "Úpravy" ;
$out_tbl1_hdr3    = "Prvá úprava" ;
$out_tbl1_hdr4    = "Posledná úprava" ;
$out_tbl1_hdr5    = "dátum" ;
$out_tbl1_hdr6    = "dní<br>dozadu" ;
$out_tbl1_hdr7    = "celkom" ; # new
$out_tbl1_hdr8    = "posl.<br>30 dní" ; # new
$out_tbl1_hdr9    = "pozícia" ; # new
$out_tbl1_hdr10   = "teraz" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "&#268;lánky" ; # new
$out_tbl1_hdr13   = "Iné" ; # new

$out_tbl2_intro  = "[[3]] nedávno absentujúcich wikipediánov, " .
                   "zoradených pod&#318;a po&#269;tu príspevkov" ;

$out_tbl3_intro   = "Nárast v po&#269;te registrovaných aktívnych wikipediánov a ich aktivity" ;

$out_tbl3_hdr1a   = "Wikipediáni" ;
$out_tbl3_hdr1e   = "&#268;lánky" ;
$out_tbl3_hdr1l   = "Databáza" ;
$out_tbl3_hdr1o   = "Linky" ;
$out_tbl3_hdr1t   = "Denné pou&#382;itie" ;

# use &nbsp; (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registrovaných pou&#382;ívate&#318;ov)" ;
$out_tbl3_hdr1e2  = "(bez presmerovaní)" ;

$out_tbl3_hdr2a   = "celkom" ;
$out_tbl3_hdr2b   = "nových" ;
$out_tbl3_hdr2c   = "úprav" ;
$out_tbl3_hdr2e   = "po&#269;et" ;
$out_tbl3_hdr2f   = "nových<br>za&nbsp;de&#328;" ;
$out_tbl3_hdr2h   = "stred" ;
$out_tbl3_hdr2j   = "vä&#269;&#353;í&nbsp;ako" ;
$out_tbl3_hdr2l   = "úprav" ;
$out_tbl3_hdr2m   = "ve&#318;kos&#357;" ;
$out_tbl3_hdr2n   = "slová" ;
$out_tbl3_hdr2o   = "interné" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "obrázok" ;
$out_tbl3_hdr2r   = "externé" ;
$out_tbl3_hdr2s   = "presmerovania" ;
$out_tbl3_hdr2t   = "vy&#382;iadané<br>stránky" ;
$out_tbl3_hdr2u   = "náv&#353;tev" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficiálne" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "úprav" ;
$out_tbl3_hdr3i   = "bajtov" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonymných pou&#382;ívate&#318;ov " .
                   "zoradených pod&#318;a po&#269;tu príspevkov" ;
$out_table6_footer = "Spolu %d úprav od anonymných pou&#382;ívate&#318;ov z celkového po&#269;tu %d úprav (%.0f\%)" ;

$out_tbl5_intro   = "&#352;tatistika náv&#353;tevnosti (na základe výstupu <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizera</font></a>; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definície</font></a>, " .
                    "<a href=''><font color='#000088'>graf</font></a>)" ;
$out_tbl5_hdr1a   = "denný priemer" ;
$out_tbl5_hdr1e   = "mesa&#269;ný sumár" ;
$out_tbl5_hdr2a   = "na&#269;ítaní" ;
$out_tbl5_hdr2b   = "súborov" ;
$out_tbl5_hdr2c   = "stránok" ;
$out_tbl5_hdr2d   = "náv&#353;tev" ;
$out_tbl5_hdr2e   = "stránok" ;
$out_tbl5_hdr2f   = "kilobajtov" ;
$out_tbl5_hdr2g   = "náv&#353;tev" ;
$out_tbl5_hdr2h   = "stránok" ;
$out_tbl5_hdr2i   = "súborov" ;
$out_tbl5_hdr2j   = "na&#269;ítaní" ;

$out_tbl7_intro   = "Záznamov v databáze na menný priestor / Kategorizované &#269;lánky<p>" .
                    "<small>1) kategórie vlo&#382;ené pomocou &#353;ablóny nie sú detekované.</small>" ; # new
$out_tbl7_hdr_ns  = "Menný priestor" ; # new
$out_tbl7_hdr_ca  = "Kategorizované<br>&#269;lánky <sup>1</sup>" ; # new

$out_tbl8_intro   = "Rozdelenie &#269;lánkov pod&#318;a wikipediánov"  ; # new

$out_tbl9_intro   = "[[5]] na&#269;astej&#353;ie upravovaných &#269;lánkov (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ;

@out_tbl3_legend  = (
"Wikipediáni, ktorí upravovali aspo&#328; 10 krát odkedy pri&#353;li",
"Nárast po&#269;tu wikipediánov, ktorí upravovali aspo&#328; 10 krát odkedy pri&#353;li",
"Wikipediáni, ktorí prispeli 5 krát alebo viac v tomto mesiaci",
"ktorí prispeli 100 krát a viac v tomto mesiaci",
"&#268;lánky obsahujúce aspo&#328; jeden interný odkaz",
"&#268;lánky obsahujúce aspo&#328; jeden interný odkaz a 200 znakov &#269;itate&#318;ného textu, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bez wiki- a html kódov, skrytých odkazov at&#271;.; nepo&#269;ítajú sa ani hlavi&#269;ky<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(ostatné st&#314;pce sú zalo&#382;ené na oficiálnych metódach s&#269;ítania)",
"Naových &#269;lánkov za de&#328; v tomto mesiaci",
"Stredný po&#269;et revízií na &#269;lánok",
"Stredná ve&#318;kos&#357; &#269;lánku v bajtoch",
"Percento &#269;lánkov s aspo&#328; 0.5 Kb &#269;itate&#318;ného textu (pozri F)",
"Percento &#269;lánkov s aspo&#328; 2 Kb &#269;itate&#318;ného textu (pozri F)",
"Úprav za posledný mesiac (vrátane presmerovaní, vrátane neregistrovaných prispievate&#318;ov)",
"Celková ve&#318;kos&#357; v&#353;etkých &#269;lánkov (vrátane presmerovaní)",
"Celkový po&#269;et slov (bez presmerovaní, html/wiki kódov a skrytých odkazov)",
"Celkový po&#269;et interných odkazoc (bez presmerovaní, výhonkov a zoznamov odkazov)",
"Celkový po&#269;et odkazov na iné Wikipédie",
"Celkový po&#269;et zobrazených obrázkov",
"Celkový po&#269;et odkazov na iné lokality",
"Celkový po&#269;et presmerovaní",
"Vy&#382;iadaných stránok za de&#328; (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, pod&#318;a výstupu <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizera</font></a>)",
"Náv&#353;tev za de&#328; (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, pod&#318;a výstupu <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizera</font></a>)",
"Dáta za posledný mesiac"
) ;

$out_webalizer_note = "Pozn.: Dáta Webalizera nie sú neustále dostupné. Nízke hodnoty v decembri 2003 sú výsledkom ve&#318;kého výpadku serverov." ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipediáni, ktorí prispeli 5 alebo viac krát za tý&#382;de&#328;",
"Wikipediáni, ktorí prispeli 25 alebo viac krát za tý&#382;de&#328;"
) ;

$out_legend_daily_edits = "Úprav za de&#328; (vrátane presmerovaní, vrátane neregistrovaných prispievate&#318;ov)" ;
$out_report_description_daily_edits = "Úprav za de&#328;" ;
$out_report_description_edits       = "Úprav za mesiac/de&#328;" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Prispievatelia",
"Noví wikipediáni",
"Aktívni wikipediáni",
"Ve&#318;mi aktívni wikipediáni",
"Po&#269;et &#269;lánkov (oficiálny)",
"Po&#269;et &#269;lánkov (alternatívny)",
"Nových &#269;lánkov za de&#328;",
"Úprav na &#269;lánok",
"Najtov na &#269;lánok",
"&#268;lánkov nad 0.5 Kb",
"&#268;lánkov nad 2 Kb",
"Úprav za mesiac",
"Ve&#318;kos&#357; databázy",
"Slov",
"Interných odkazov",
"Odkazov na iné Wikipédie",
"Obrázkov",
"Externých odkazov",
"Presmerovaní",
"Vy&#382;iadaných stránok za de&#328;",
"Náv&#353;tev za de&#328;",
"Preh&#318;ad"
) ;

}
1;
