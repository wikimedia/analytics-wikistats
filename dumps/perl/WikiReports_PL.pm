#!/usr/bin/perl

# please specify all accented characters as html codes
# like &agrave; or $#224;
# do not edit with unicode editor, I will have to replace all unicode

# see for a list of codes
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_PL # replace by language code
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Statystyki Wikipedii" ;
$out_charts       = "Wykresy Wikipedii" ;
$out_btn_tables   = "Tabele" ;
$out_btn_table    = "Tabela" ;
$out_btn_charts   = "Wykresy" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipedie" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary   = "Wikts&#322;ownik" ;
$out_wiktionaries = "Wikts&#322;owniki" ;
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

$out_comparisons  = "Por&oacute;wnania" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Wygenerowano " ;
$out_sqlfiles     = "z obraz&oacute;w bazy danych SQL z " ;
$out_version      = "Wersja skryptu:" ;
$out_author       = "Autor" ;
$out_mail         = "Mail" ;
$out_site         = "Strona WWW" ;
$out_home         = "G&#322;&oacute;wna" ;
$out_sitemap      = "Mapa strony";
$out_rendered     = "Wykresy wygenerowane z " ;
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
$out_year         = "rok" ;
$out_month        = "miesi&#261;c" ;
$out_mean         = "&#347;rednio" ;
$out_growth       = "Wzrost" ;
$out_total        = "Razem" ;
$out_bars         = "Paski" ;
$out_words        = "s&#322;owa" ;
$out_zoom         = "Zoom" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " zastosowano (p&oacute;&#322;)automatyczn&#261; konwersj&#281;." ;

$out_phaseIII     = "Uwzgl&#281;dniono tylko Wikipedie dzia&#322;aj&#261;ce z <a href='http://www.mediawiki.org'>MediaWiki</a> ." ;

$out_svg_viewer   = "Aby obejrze&#263; zawarto&#347;&#263; tej strony potrzebujesz " .
                    "przegl&#261;dark&#281; SVG, n.p. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "dla MS Explorer Win/Mac (bezp&#322;atna)" ;
$out_rendering    = "Przetwarzanie.... Prosz&#281; czeka&#263;" ;

$out_sort_order   = "Wikipedie zosta&#322;y uporz&#261;dkowane wed&#322;ug ilo&#347;ci wewn&#281;trznych link&oacute;w (poza przekierowaniami)<br>" .
                    "To wydaje si&#281; by&#263; lepsz&#261; baz&#261; do por&oacute;wnania wk&#322;adu pracy ni&#380; ilo&#347;&#263; artyku&#322;&oacute;w lub wielko&#347;&#263; bazy danych:<br>" .
                    "Ilo&#347;&#263; artyku&#322;&oacute;w nie jest tak wa&#380;na uwzgl&#281;dniaj&#261;c, &#380;e niekt&oacute;re Wikipedie zawieraj&#261; g&#322;&oacute;wnie kr&oacute;tkie artyku&#322;y,<br>" .
                    "lub nawet sporo automatycznie generowanych artyku&#322;&oacute;w, podczas gdy inne Wikipedie zawieraj&#261; mniej ale d&#322;u&#380;szych artyku&#322;;&oacute;w, r&#281;cznie napisanych.<br>" .
                    "Wielko&#347;&#263; bazy danych zale&#380;y od systemu kodowania (znaki Unicode zajmuj&#261; wi&#281;cej bajt&oacute;w) i <br>" .
                    "od znaczenia pojedynczego znaku (n.p. Chi&#324;skie znaki s&#261; ca&#322;ymi s&#322;owami).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "&#347;rednia ilo&#347;&#263; w danych miesi&#261;cach" ;
$out_growth_1     = "&#347;redni wzrost miesi&#281;czny w danych miesi&#261;cach" ;
$out_formula      = "formu&#322;a" ;
$out_value        = "warto&#347;&#263;" ;
$out_monthes      = "miesi&#261;ce" ;
$out_skip_values  = "(Pomini&#281;to Wikipedie o warto&#347;ci < 10)" ;

$out_history      = "Uwaga: rysunki dla pierwszych miesi&#281;cy s&#261; za ma&#322;e. " .
                    "Historia wcze&#347;niejszych zmian nie jest dost&#281;pna." ;

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

$out_tbl1_intro   = "[[2]] ostatnio aktywni wikipedy&#347;ci, " .
                    "uporz&#261;dkowane wed&#322;ug wielko&#347;ci wk&#322;adu:" ;
$out_tbl1_intro2  = "liczone s&#261; tylko edycje artyku&#322;&oacute;w, a nie edycje stron dyskusji, i.t.p." ;
$out_tbl1_intro3  = "&Delta; = zmiana pozycji w ostatnich 30 dniach" ;

$out_tbl1_hdr1    = "U&#380;ytkownik" ;
$out_tbl1_hdr2    = "Edycje" ;
$out_tbl1_hdr3    = "Pierwsza edycja" ;
$out_tbl1_hdr4    = "Ostatnia edycja" ;
$out_tbl1_hdr5    = "data" ;
$out_tbl1_hdr6    = "dni<br>temu" ;
$out_tbl1_hdr7    = "razem" ;
$out_tbl1_hdr8    = "ostatnie<br>30 dni" ;
$out_tbl1_hdr9    = "pozycja" ;
$out_tbl1_hdr10   = "teraz" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Artuku&#322;&oacute;w" ;
$out_tbl1_hdr13   = "inne" ;

$out_tbl2_intro  = "[[3]] ostatnio nieobecni wikipedy&#347;ci, " .
                   "uporz&#261;dkowane wed&#322;ug wielko&#347;ci wk&#322;adu:" ;

$out_tbl3_intro   = "Wzrost wed&#322;ug liczby zarejestrowanych aktywnych wikipedyst&oacute;w i ich aktywno&#347;ci" ;

$out_tbl3_hdr1a   = "Wikipedy&#347;ci" ;
$out_tbl3_hdr1e   = "Artyku&#322;y" ;
$out_tbl3_hdr1l   = "Baza danych" ;
$out_tbl3_hdr1o   = "Linki" ;
$out_tbl3_hdr1t   = "Dzienne U&#380;ycie" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(zarejestrowani&nbsp;u&#380;ytkownicy)" ;
$out_tbl3_hdr1e2  = "(bez&nbsp;przekierowa&#324;)" ;

$out_tbl3_hdr2a   = "razem" ;
$out_tbl3_hdr2b   = "nowi" ;
$out_tbl3_hdr2c   = "edycje" ;
$out_tbl3_hdr2e   = "ilo&#347;&#263;" ;
$out_tbl3_hdr2f   = "nowe<br>dziennie" ;
$out_tbl3_hdr2h   = "&#347;rednio" ;
$out_tbl3_hdr2j   = "wi&#281;ksze&nbsp;ni&#380;" ;
$out_tbl3_hdr2l   = "edycje" ;
$out_tbl3_hdr2m   = "wielko&#347;&#263;" ;
$out_tbl3_hdr2n   = "s&#322;owa" ;
$out_tbl3_hdr2o   = "wewn&#281;trzne" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "grafiki" ;
$out_tbl3_hdr2r   = "zewn&#281;trzne" ;
$out_tbl3_hdr2s   = "przekierowania" ;
$out_tbl3_hdr2t   = "&#380;&#261;dania<br>stron" ;
$out_tbl3_hdr2u   = "wizyty" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficjalne" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;zn." ;
$out_tbl3_hdr3h   = "edycje" ;
$out_tbl3_hdr3i   = "bajty" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonimowi u&#380;ytkownicy, uporz&#261;dkowani wed&#322;ug wielko&#347;ci wk&#322;adu" ;
$out_table6_footer = "Razem %d edycji dokonanych przez anonimowych u&#380;ytkownik&oacute;w, z og&oacute;lnej liczby %d edycji (%.0f\%)" ;

$out_tbl5_intro   = "Statystyki odwiedzaj&#261;cych (na podstawie <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definitions</font></a>, " .
                    "<a href=''><font color='#000088'>chart</font></a>)" ;
$out_tbl5_hdr1a   = "&#347;rednio dziennie" ;
$out_tbl5_hdr1e   = "Miesi&#281;cznie razem" ;
$out_tbl5_hdr2a   = "Trafiemia" ;
$out_tbl5_hdr2b   = "Pliki" ;
$out_tbl5_hdr2c   = "Strony" ;
$out_tbl5_hdr2d   = "Wizyty" ;
$out_tbl5_hdr2e   = "Miejsca" ;
$out_tbl5_hdr2f   = "KBajty" ;
$out_tbl5_hdr2g   = "Wizyty" ;
$out_tbl5_hdr2h   = "Strony" ;
$out_tbl5_hdr2i   = "Pliki" ;
$out_tbl5_hdr2j   = "Trafienia" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Wikipedy&#347;ci, kt&oacute;rzy dokonali co najmniej 10 edycji od czasu przybycia",
"Wzrost liczby wikipedyst&oacute;w, kt&oacute;rzy dokonali co najmniej 10 edycji od czasu przybycia",
"Wikipedy&#347;ci, kt&oacute;rzy wnie&#347;li sw&oacute;j wk&#322;ad 5 razy lub wi&#281;cej w tym miesi&#261;cu",
"Wikipedy&#347;ci, kt&oacute;rzy wnie&#347;li sw&oacute;j wk&#322;ad 100 razy lub wi&#281;cej w tym miesi&#261;cu",
"Artyku&#322;y, kt&oacute;re zawieraj&#261; co najmniej jeden wewn&#281;trzny link",
"Artyku&#322;y, kt&oacute;re zawieraj&#261; co najmniej jeden wewn&#281;trzny link i 200 znak&oacute;w czytelnego tekstu, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pomijaj&#261;c kody wiki i html, ukryte linki, etc.; tak&#380;e nag&#322;&oacute;wki nie s&#261; liczone<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(inne kolumny bazuj&#261; na oficjalnej liczbie artyku&#322;&oacute;w)",
"Nowe artyku&#322;y dziennie w poprzednim miesi&#261;cu",
"&#346;rednia liczba poprawek na artyku&#322;",
"&#346;rednia wielko&#347;&#263; artyku&#322;u w bajtach",
"Udzia&#322; procentowy artyku&#322;&oacute;w z co najmniej 0,5 kB czytelnego tekstu (zobacz F)",
"Udzia&#322; procentowy artyku&#322;&oacute;w z co najmniej 2 kB czytelnego tekstu (zobacz F)",
"Edycji w poprzednim miesi&#261;cu (w tym przekierowania i niezarejestrowani u&#380;ytkownicy)",
"&#321;&#261;czna wielko&#347;&#263; wszystkich artyku&#322;&oacute;w (w tym przekierowania)",
"Ca&#322;kowita ilo&#347;&#263; s&#322;&oacute;w (bez przekierowa&#324;, kod&oacute;w html/wiki i ukrytych link&oacute;w)",
"Ca&#322;kowita ilo&#347;&#263; wewn&#281;trznych link&oacute;w (bez przekierowa&#324;, stub&oacute;w i list link&oacute;w)",
"Ca&#322;kowita ilo&#347;&#263; link&oacute;w do innych Wikipedii",
"Ca&#322;kowita ilo&#347;&#263; grafik",
"Ca&#322;kowita ilo&#347;&#263; link&oacute;w do innych miejsc",
"Ca&#322;kowita ilo&#347;&#263; przekierowa&#324;",
"&#379;&#261;dania otwarcia strony dziennie (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definicja</font></a>, na podstawie <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> )",
"Wizyt dziennie (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definicja</font></a>, na podstawie <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> )",
"Dane za ostatnie miesi&#261;ce"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedy&#347;ci,kt&oacute;rzy wnie&#347;li wk&#322;ad 5 razy lub wi&#281;cej tygodniowo",
"Wikipedy&#347;ci,kt&oacute;rzy wnie&#347;li wk&#322;ad 25 razy lub wi&#281;cej tygodniowo"
) ;

$out_legend_daily_edits = "Edycji dziennie (w tym przekierowania i niezarejestrowani u&#380;ytkownicy)" ;
$out_report_description_daily_edits = "Edycji dziennie" ;
$out_report_description_edits       = "Edycji dziennie/miesi&#281;cznie" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Wsp&oacute;&#322;pracownicy",
"Nowi wikipedy&#347;ci",
"Aktywni wikipedy&#347;ci",
"Bardzo aktywni wikipedy&#347;ci",
"Ilo&#347;&#263; artyku&#322;&oacute;w (oficjalna)",
"Ilo&#347;&#263; artyku&#322;&oacute;w (alternatywna)",
"Nowe artyku&#322;y dziennie",
"Edycje na artyku&#322;",
"Bajt&oacute;w na artyku&#322;",
"Artyku&#322;y ponad 0.5 Kb",
"Artyku&#322;y ponad 2 Kb",
"Edycje na miesi&#261;c",
"Wielko&#347;&#263; bazy danych",
"S&#322;owa",
"Wewn&#281;trzne linki",
"Linki do innych Wikipedii",
"Grafiki",
"Linki do stron WWW",
"Przekierowania",
"&#379;&#261;dania odczytu stron dziennie",
"Wizyty dziennie",
"Przegl&#261;d"
) ;

# if you don't know all translation please mark untranslated ones

$out_languages {"aa"} = "Afar" ;
$out_languages {"ab"} = "Abchaska" ;
$out_languages {"af"} = "Afrykanerska" ;
$out_languages {"ak"} = "Akana" ;
$out_languages {"als"} = "Elsatian" ;
$out_languages {"am"} = "Amharska" ;
$out_languages {"an"} = "Aragonese" ;
$out_languages {"ang"} = "Anglo-Saxon" ;
$out_languages {"ar"} = "Arabska" ;
$out_languages {"as"} = "Asamska" ;
$out_languages {"ast"} = "Asturian" ;
$out_languages {"av"} = "Avienan" ;
$out_languages {"ay"} = "Ajmara" ;
$out_languages {"az"} = "Azerbejd&#380;a&#324;ska" ;
$out_languages {"ba"} = "Baszkirska" ;
$out_languages {"be"} = "Bia&#322;oruska" ;
$out_languages {"bg"} = "Bu&#322;garska" ;
$out_languages {"bh"} = "Biharska" ;
$out_languages {"bi"} = "Bislama" ;
$out_languages {"bj"} = "Bhojpuri" ;
$out_languages {"bn"} = "Bengalska" ;
$out_languages {"bo"} = "Tybeta&#324;ska" ;
$out_languages {"br"} = "Breto&#324;ska" ;
$out_languages {"bs"} = "Bo&#347;niacka" ;
$out_languages {"bug"} = "Buginese" ;
$out_languages {"ca"} = "Katalo&#324;ska" ;
$out_languages {"ch"} = "Chamoru" ;
$out_languages {"cho"} = "Chotaw" ;
$out_languages {"chr"} = "Cherokee" ;
$out_languages {"co"} = "Korsyka&#324;ska" ;
$out_languages {"cr"} = "Cree" ;
$out_languages {"cs"} = "Czeska" ;
$out_languages {"csb"} = "Kaszubska" ;
$out_languages {"cy"} = "Walijska" ;
$out_languages {"da"} = "Du&#324;ska" ;
$out_languages {"de"} = "Niemiecka" ;
$out_languages {"dv"} = "Divehi" ;
$out_languages {"dz"} = "Bhuta&#324;ska" ;
$out_languages {"ee"} = "Ewe" ;
$out_languages {"el"} = "Grecka" ;
$out_languages {"en"} = "Angielska" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Hiszpa&#324;ska" ;
$out_languages {"et"} = "Esto&#324;ska" ;
$out_languages {"eu"} = "Baskijska" ;
$out_languages {"fa"} = "Perska" ;
$out_languages {"fi"} = "Fi&#324;ska" ;
$out_languages {"fj"} = "Fid&#380;yjska" ;
$out_languages {"fo"} = "Farerska" ;
$out_languages {"fr"} = "Francuska" ;
$out_languages {"fy"} = "Fryzyjska" ;
$out_languages {"ga"} = "Irlandzka" ;
$out_languages {"gay"} = "Gayo" ;
$out_languages {"gd"} = "Szkocko&nbsp;gaelijska" ;
$out_languages {"gl"} = "Galicyjska" ;
$out_languages {"gn"} = "Guarani" ;
$out_languages {"got"} = "Gothic" ;
$out_languages {"gu"} = "Gud&#380;arati" ;
$out_languages {"gv"} = "Manx Gaelic" ;
$out_languages {"ha"} = "Hausa" ;
$out_languages {"haw"} = "Hawajska" ;
$out_languages {"he"} = "Hebrajska" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Chorwacka" ;
$out_languages {"ht"} = "Haita&#324;ska" ;
$out_languages {"hu"} = "W&#281;gierska" ;
$out_languages {"hy"} = "Arme&#324;ska" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"iba"} = "Iban" ;
$out_languages {"id"} = "Indonezyjska" ;
$out_languages {"ie"} = "Interlingue" ;
$out_languages {"ii"} = "Syczua&#324;ska" ;
$out_languages {"ik"} = "Inupiak" ;
$out_languages {"io"} = "Ido" ;
$out_languages {"is"} = "Islandzka" ;
$out_languages {"it"} = "W&#322;oska" ;
$out_languages {"iu"} = "Inuktitut" ;
$out_languages {"ja"} = "Japo&#324;ska" ;
$out_languages {"jbo"} = "Lojban" ;
$out_languages {"jv"} = "Jawajska" ;
$out_languages {"ka"} = "Gruzi&#324;ska" ;
$out_languages {"kaw"} = "Kawi" ;
$out_languages {"kj"} = "Otjiwambo" ;
$out_languages {"kk"} = "Kazachska" ;
$out_languages {"kl"} = "Grenlandzka" ;
$out_languages {"km"} = "Kambod&#380;a&#324;ska" ;
$out_languages {"kn"} = "Kannada" ;
$out_languages {"ko"} = "Korea&#324;ska" ;
$out_languages {"ks"} = "Kaszmirska" ;
$out_languages {"ku"} = "Kurdyjska" ;
$out_languages {"kw"} = "Komish" ;
$out_languages {"ky"} = "Kirgiska" ;
$out_languages {"la"} = "&#321;aci&#324;ska" ;
$out_languages {"lb"} = "Letzeburgesch" ;
$out_languages {"li"} = "Limburguish" ;
$out_languages {"ln"} = "Lingala" ;
$out_languages {"lo"} = "Laota&#324;ska" ;
$out_languages {"ls"} = "Latino Sine Flexione" ;
$out_languages {"lt"} = "Litewska" ;
$out_languages {"lv"} = "&#321;otewska" ;
$out_languages {"mad"} = "Madurese" ;
$out_languages {"mak"} = "Makasar" ;
$out_languages {"mg"} = "Malgaska" ;
$out_languages {"mh"} = "Marshall" ;
$out_languages {"mi"} = "Maoryska" ;
$out_languages {"minnan"} = "Tajwa&#324;ska" ;
$out_languages {"mk"} = "Macedo&#324;ska" ;
$out_languages {"ml"} = "Malajalam" ;
$out_languages {"mn"} = "Mongolska" ;
$out_languages {"mo"} = "Mo&#322;dawska" ;
$out_languages {"mr"} = "Marathi" ;
$out_languages {"ms"} = "Malajska" ;
$out_languages {"mt"} = "Malta&#324;ska" ;
$out_languages {"mus"} = "Muskogi" ;
$out_languages {"my"} = "Birma&#324;ska" ;
$out_languages {"na"} = "Nauru" ;
$out_languages {"nah"} = "Nahuatl" ;
$out_languages {"nds"} = "Dolnosakso&#324;ska" ;
$out_languages {"ne"} = "Nepalska" ;
$out_languages {"nl"} = "Holenderska" ;
$out_languages {"nn"} = "Nowonorweska" ;
$out_languages {"no"} = "Norweska" ;
$out_languages {"nv"} = "Nawaho" ;
$out_languages {"oc"} = "Prowansalska" ;
$out_languages {"om"} = "Oromo" ;
$out_languages {"or"} = "Oryska" ;
$out_languages {"pa"} = "Pend&#380;abska" ;
$out_languages {"pl"} = "Polska" ;
$out_languages {"ps"} = "Paszto" ;
$out_languages {"pt"} = "Portugalska" ;
$out_languages {"qu"} = "Keczua" ;
$out_languages {"roa-rup"} = "Arumu&#324;ska" ;
$out_languages {"rm"} = "Retoroma&#324;ska" ;
$out_languages {"rn"} = "Kirundi" ;
$out_languages {"ro"} = "Rumu&#324;ska" ;
$out_languages {"ru"} = "Rosyjska" ;
$out_languages {"rw"} = "Kinyarwanda" ;
$out_languages {"sa"} = "Sanskrycka" ;
$out_languages {"sc"} = "Sardy&#324;ska" ;
$out_languages {"scn"} = "Sycylijska" ;
$out_languages {"sd"} = "Sindhi" ;
$out_languages {"se"} = "Lapo&#324;ska" ;
$out_languages {"sg"} = "Sangho" ;
$out_languages {"sh"} = "Serbsko-chorwacka" ;
$out_languages {"si"} = "Syngaleska" ;
$out_languages {"simple"} = "Uproszczona&nbsp;angielska" ;
$out_languages {"sk"} = "S&#322;owacka" ;
$out_languages {"sl"} = "S&#322;owe&#324;ska" ;
$out_languages {"sm"} = "Samoa&#324;ska" ;
$out_languages {"sn"} = "Szona" ;
$out_languages {"so"} = "Somalijska" ;
$out_languages {"sq"} = "Alba&#324;ska" ;
$out_languages {"sr"} = "Serbska" ;
$out_languages {"ss"} = "Suazi" ;
$out_languages {"st"} = "Lesotho" ;
$out_languages {"su"} = "Suda&#324;ska" ;
$out_languages {"sv"} = "Szwedzka" ;
$out_languages {"sw"} = "Suahili" ;
$out_languages {"ta"} = "Tamilska" ;
$out_languages {"te"} = "Telugu" ;
$out_languages {"tg"} = "Tad&#380;ycka" ;
$out_languages {"th"} = "Tajska" ;
$out_languages {"ti"} = "Tigrinia" ;
$out_languages {"tk"} = "Turkme&#324;ska" ;
$out_languages {"tl"} = "Tagalog" ;
$out_languages {"tlh"} = "Klingo&#324;ska" ;
$out_languages {"tn"} = "Setswana" ;
$out_languages {"to"} = "Tonga" ;
$out_languages {"tokipona"} = "Liliponski" ;
$out_languages {"tpi"} = "Tok Pisin" ;
$out_languages {"tr"} = "Turecka" ;
$out_languages {"ts"} = "Tsonga" ;
$out_languages {"tt"} = "Tatarska" ;
$out_languages {"tw"} = "Twi" ;
$out_languages {"ty"} = "Tahitian" ;
$out_languages {"ug"} = "Ujgurska" ;
$out_languages {"uk"} = "Ukrai&#324;ska" ;
$out_languages {"ur"} = "Urdu" ;
$out_languages {"uz"} = "Uzbecka" ;
$out_languages {"ve"} = "Venda" ;
$out_languages {"vi"} = "Wietnamska" ;
$out_languages {"vo"} = "Volapuk" ;
$out_languages {"wa"} = "Walloon" ;
$out_languages {"wo"} = "Wolof" ;
$out_languages {"xh"} = "Xhosa" ;
$out_languages {"yi"} = "Jidysz" ;
$out_languages {"yo"} = "Joruba" ;
$out_languages {"za"} = "Zhuang" ;
$out_languages {"zh"} = "Chi&#324;ska" ;
$out_languages {"zu"} = "Zulu" ;
$out_languages {"zz"} = "Wszystkie&nbsp;j&#281;zyki" ;
}

# end of file marker, do not remove:
1;

