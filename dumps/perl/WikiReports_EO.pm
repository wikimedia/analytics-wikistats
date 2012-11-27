#!/usr/bin/perl

sub SetLiterals_EO
{
$out_statistics    = "Vikipediaj statistikoj" ;
$out_charts        = "Vikipediaj grafika&#309;oj" ;
$out_btn_tables    = "Tabeloj" ;
$out_btn_table     = "Tabelo" ;
$out_btn_charts    = "Grafika&#309;oj" ;

$out_wikipedia     = "Vikipedio" ;
$out_wikipedias    = "Vikipedioj" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary    = "Vikivortaro" ;
$out_wiktionaries  = "Vikivortaroj" ;
$out_wiktionarians = "wiktionarians" ; # new

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

$out_comparisons   = "Komparoj" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generita je la " ;
$out_sqlfiles     = "El la SQL &#349;utdosiero de " ;
$out_version      = "Skripta versio :" ;
$out_author       = "A&#365;toro" ;
$out_mail         = "Retpo&#349;to" ;
$out_site         = "TTT-ejo" ;
$out_home         = "Hejmo" ;
$out_sitemap      = "Pa&#285;armapo";
$out_rendered     = "Grafikoj kreitaj per " ;
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "Index to EasyTimeline charts per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_categories   = "Category Overview per Wikipedia" ; # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "Kb" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Dato" ;
$out_year         = "jaro" ;
$out_month        = "monato" ;
$out_mean         = "Avera&#285;e" ;
$out_growth       = "Kresko" ;
$out_total        = "Sumo" ;
$out_bars         = "Strekoj" ;
$out_zoom         = "Zoom" ; # new
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " (duon-)a&#365;tomataj konvertadoj estis faritaj." ;

$out_phaseIII     = "Nur Vikipedioj uzantaj la softvaron <a href='http://www.mediawiki.org'>MediaWiki</a> estas enkalkulitaj." ;

$out_svg_viewer   = "Por vidigi la entenon de la pa&#285;o vi bezonos SVG-montrilon, " .
                    "kiel ekzemple <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG montrilo</a> " .
                    "por MS Explorer Win/Mac (senpaga)" ;
$out_rendering    = "Grafikoj konstruataj ... Bonvolu atendi" ;

$out_sort_order   = "Vikipedioj estas ordigitaj la&#365; nombro de internaj ligoj (krom redirektoj)<br>" .
                    "&#348;ajnas pli fidinda bazo por kompari la suman penon ol &#265iu nombro de artikoloj a&#365; datumbazgrandeco :<br>" .
                    "Nombro de artikoloj ne estas tiom signifoplena pro la fakto ke kelkaj Vikipedioj entenas precipe mallongajn artikolojn,<br>" .
                    "a&#365; e&#265 multajn a&#365;tomate generitajn artikolojn, dum aliaj Vikipedioj entenas malpli multajn sed pli longajn artikolojn, &#265iuj mane verkitaj.<br>" .
                    "Datumbazograndeco dependas de la kodsistemo (unikodaj karaktroj prenas plurajn bajtojn) kaj <br>" .
                    "de kiom da signifoj povas preni unu karaktro (ekzemple &#264;inaj karaktroj estas plenaj vortoj).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "avera&#285;aj kalkuloj sur la montritaj monatoj" ;
$out_growth_1     = "avera&#285;a monata kresko sur la montritaj monatoj" ;
$out_formula      = "formulo" ;
$out_value        = "valoro" ;
$out_monthes      = "monatoj" ;
$out_skip_values  = "(Vikipedioj kun valoroj < 10 estas ignoritaj)" ;

$out_history      = "Noto: figuroj por unuaj monatoj estas tro malaltaj. " .
                    "Revizhistorio ne estis &#265iam konservita en la komencaj tagoj." ;

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

$out_tbl1_intro   = "[[2]] nove aktivaj Vikipediistoj, " .
                    "ordigitaj la&#365; nombro de kontribua&#309;oj:" ;
$out_tbl1_intro2  = "nur artikolredaktoj estas enkalkulitaj, ne redaktoj &#265;e diskutpa&#285;oj, ktp" ;
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "Vikipediisto" ;
$out_tbl1_hdr2    = "Redaktoj" ;
$out_tbl1_hdr3    = "Unua redakto" ;
$out_tbl1_hdr4    = "Lasta redakto" ;
$out_tbl1_hdr5    = "dato" ;
$out_tbl1_hdr6    = "de tiom<br>da tagoj" ;
$out_tbl1_hdr7    = "sumo" ;
$out_tbl1_hdr8    = "30 lastaj<br>tagoj" ;
$out_tbl1_hdr9    = "vico" ;
$out_tbl1_hdr10   = "nun" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Artikoloj" ;
$out_tbl1_hdr13   = "Aliaj" ;

$out_tbl2_intro  = "[[3]] laste forestantaj Vikipediistoj, " .
                   "ordigitaj la&#365; nombro de kontribua&#309;oj:" ;

$out_tbl3_intro   = "Kresko de la nombro de registritaj aktivaj Vikipediistoj kaj ilia aktiveco" ;

$out_tbl3_hdr1a   = "Vikipediistoj" ;
$out_tbl3_hdr1e   = "Artikoloj" ;
$out_tbl3_hdr1l   = "Datumbazo" ;
$out_tbl3_hdr1o   = "Ligoj" ;
$out_tbl3_hdr1t   = "Potaga uzo" ;

# uzu &nbsp; (ne rompeblaj spacoj) anstata&#365; normalajn spacojn en la sekvontaj &#265apoj
# tio garantias ke la teksto neniam estos disgita en du liniojn
$out_tbl3_hdr1a2  = "(registritaj uzuloj)" ;
$out_tbl3_hdr1e2  = "(krom redirektoj)" ;

$out_tbl3_hdr2a   = "grandeco" ;
$out_tbl3_hdr2b   = "nova" ;
$out_tbl3_hdr2c   = "redaktoj" ;
$out_tbl3_hdr2e   = "nombro" ;
$out_tbl3_hdr2f   = "nova<br>po&nbsp;tago" ;
$out_tbl3_hdr2h   = "avera&#285;a" ;
$out_tbl3_hdr2j   = "pli&nbsp;granda&nbsp;ol" ;
$out_tbl3_hdr2l   = "redaktoj" ;
$out_tbl3_hdr2m   = "grandeco" ;
$out_tbl3_hdr2n   = "vortoj" ;
$out_tbl3_hdr2o   = "interna" ;
$out_tbl3_hdr2p   = "interviki" ;
$out_tbl3_hdr2q   = "bildo" ;
$out_tbl3_hdr2r   = "ekstera" ;
$out_tbl3_hdr2s   = "redirektoj" ;
$out_tbl3_hdr2t   = "pa&#285;petoj" ;
$out_tbl3_hdr2u   = "vizitoj" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficiala" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;&#265;" ;
$out_tbl3_hdr3h   = "redaktoj" ;
$out_tbl3_hdr3i   = "bajtoj" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonimaj kontribuantoj, ordigitaj la&#365; nombro da kontribuoj" ;
$out_table6_footer = "Entute %d redaktoj estis faritaj de anonimaj kontribuantoj, el sumo da %d redaktoj (%.0f\%)" ;

$out_tbl5_intro   = "Vizitantaraj statistikoj (bazitaj sur <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> eligo ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>difinoj</font></a>, " .
                    "<a href=''><font color='#000088'>grafika&#309;o</font></a>)" ;
$out_tbl5_hdr1a   = "Taga Avera&#285;o" ;
$out_tbl5_hdr1e   = "Monataj Sumoj" ;
$out_tbl5_hdr2a   = "Trafoj" ;
$out_tbl5_hdr2b   = "Dosieroj" ;
$out_tbl5_hdr2c   = "Pa&#285;oj" ;
$out_tbl5_hdr2d   = "Vizitoj" ;
$out_tbl5_hdr2e   = "TTT-ejoj" ;
$out_tbl5_hdr2f   = "KBajtoj" ;
$out_tbl5_hdr2g   = "Vizitoj" ;
$out_tbl5_hdr2h   = "Pa&#285;oj" ;
$out_tbl5_hdr2i   = "Dosieroj" ;
$out_tbl5_hdr2j   = "Trafoj" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Vikipediistoj kiuj redaktis minimume 10 foje post kiam ili alvenis",
"Nombrokresko da Vikipediistoj kiuj redaktis minimume 10 foje post kiam ili alvenis",
"Vikipediistoj kiuj kontribuis 5 foje a&#365; pli en la pasinta monato",
"Vikipediistoj kiuj kontribuis 100 foje a&#365; pli en la pasinta monato",
"Artikoloj kiuj entenas almena&#365; unu internan ligon",
"Artikoloj kiuj entenas almena&#365; unu internan ligon kaj 200 karaktrojn da legebla teksto, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;preteratente viki- kaj html- kodojn, ka&#349;itajn ligojn, ktp.; titoloj anka&#365; ne enkalkuli&#285;as <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(aliaj kolumnoj estas bazitaj sur la oficialan kalkulmetodon)",
"Novaj artikoloj po tago en pasinta monato",
"Avera&#285;a nombro da revizioj po artikolo",
"Avera&#285;a artikolgrandeco en bajtoj",
"Procento da artikoloj pli grandaj ol 0.5 Kb da legebla teksto (ref F)",
"Procento da artikoloj pli grandaj ol 2 Kb da legebla teksto (ref F)",
"Redaktoj en la pasinta monato (kun redirektoj, kun neregistritaj kontribuantoj)",
"Kombinita grandeco de &#265iuj artikoloj (kun redirektoj)",
"Suma nombro de vortoj (krom redirektoj, viki- kaj html- kodojn, ka&#349;itajn ligojn)",
"Suma nombro de internaj ligoj (krom redirektoj, stumpoj kaj liglistoj)",
"Suma nombro de ligoj al alilingvaj Vikipedioj",
"Suma nombro de montritaj bildoj ",
"Suma nombro de ligoj al aliaj TTTejoj ",
"Suma nombro de redirektoj",
"Pa&#285;petoj (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>difino</font></a>, bazitaj sur <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> eligo)",
"Potagaj vizitoj (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>difino</font></a>, bazitaj sur <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> eligo)",
"Datumoj por lastaj monatoj"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Vikipediistoj kiuj kontribuis 5 foje a&#365; pli en la pasinta semajno",
"Vikipediistoj kiuj kontribuis 100 foje a&#365; pli en la pasinta semajno",
) ;


$out_legend_daily_edits = "Redaktoj po tago (kun redirektoj, kun neregistritaj kontribuantoj)" ;
$out_report_description_daily_edits = "Redaktoj po tago" ;
$out_report_description_edits       = "Redaktoj monate/po tago" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Kontribuantoj",
"Novaj vikipediistoj",
"Aktivaj vikipediistoj",
"Tre aktivaj vikipediistoj",
"Artikolnombro (oficiale)",
"Artikolnombro (alternative)",
"Novaj artikoloj po tago",
"Redaktoj po artikolo",
"Bajtoj po artikolo",
"Artikoloj super 0.5 Kb",
"Artikoloj super 2 Kb",
"Redaktoj monate",
"Datumbaza grandeco",
"Vortoj",
"Internaj ligoj",
"Ligoj al alilingvaj vikipedioj",
"Bildoj",
"Retligoj",
"Redirektoj",
"Potagaj pa&#285;petoj",
"Potagaj vizitoj",
"Superrigardo"
) ;

$out_languages {"aa"} = "Afara" ;
$out_languages {"ab"} = "Ab&#293;aza" ;
$out_languages {"af"} = "Afrikansa" ;
$out_languages {"ak"} = "Akana" ;
$out_languages {"als"} = "Alzaca" ;
$out_languages {"am"} = "Amhara" ;
$out_languages {"an"} = "Aragona" ;
$out_languages {"ang"} = "Angla malnova" ;
$out_languages {"ar"} = "Araba" ;
$out_languages {"arc"} = "Aramea" ;
$out_languages {"as"} = "Asama" ;
$out_languages {"ast"} = "Asturia" ;
$out_languages {"av"} = "Avara" ;
$out_languages {"ay"} = "Aymara" ;
$out_languages {"az"} = "Azera" ;
$out_languages {"ba"} = "Ba&#349;kira" ;
$out_languages {"be"} = "Belorusa" ;
$out_languages {"bg"} = "Bulgara" ;
$out_languages {"bh"} = "Bihara" ;
$out_languages {"bi"} = "Bislama" ;
$out_languages {"bo"} = "Tibeta" ;
$out_languages {"bn"} = "Bengala" ;
$out_languages {"br"} = "Bretona" ;
$out_languages {"bs"} = "Bosna" ;
$out_languages {"ca"} = "Kataluna" ;
$out_languages {"ce"} = "&#264;e&#265;ena" ;
$out_languages {"ch"} = "&#264;amora" ;
$out_languages {"cho"} = "&#264;okta&#365;a" ;
$out_languages {"chr"} = "&#264;eroka" ;
$out_languages {"chy"} = "&#264;ejena" ;
$out_languages {"co"} = "Korsika" ;
$out_languages {"cr"} = "Kria" ;
$out_languages {"cs"} = "&#264;e&#293;a" ;
$out_languages {"csb"} = "Ka&#349;uba" ;
$out_languages {"cv"} = "&#264;uva&#349;a" ;
$out_languages {"cy"} = "Kimra" ;
$out_languages {"da"} = "Dana" ;
$out_languages {"de"} = "Germana" ;
$out_languages {"dv"} = "Maldiva" ;
$out_languages {"dz"} = "Dzonka" ;
$out_languages {"ee"} = "Evea" ;
$out_languages {"el"} = "Greka" ;
$out_languages {"en"} = "Angla" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Hispana" ;
$out_languages {"et"} = "Estona" ;
$out_languages {"eu"} = "E&#365;ska" ;
$out_languages {"fa"} = "Persa" ;
$out_languages {"fi"} = "Finna" ;
$out_languages {"fj"} = "Fi&#285;ia" ;
$out_languages {"fo"} = "Feroa" ;
$out_languages {"fr"} = "Franca" ;
$out_languages {"fy"} = "Frisa" ;
$out_languages {"ga"} = "Irlanda" ;
$out_languages {"gd"} = "Skota" ;
$out_languages {"gl"} = "Galega" ;
$out_languages {"got"} = "Gota" ;
$out_languages {"gn"} = "Gvarania" ;
$out_languages {"gu"} = "Gu&#285;arata" ;
$out_languages {"gv"} = "Manska" ;
$out_languages {"ha"} = "Ha&#365;sa" ;
$out_languages {"haw"} = "Havaja" ;
$out_languages {"he"} = "Hebrea" ;
$out_languages {"hi"} = "Hinda" ;
$out_languages {"hr"} = "Kroata" ;
$out_languages {"ht"} = "Haita" ;
$out_languages {"hu"} = "Hungara" ;
$out_languages {"hy"} = "Armena" ;
$out_languages {"ia"} = "Interlingvaa" ;
$out_languages {"id"} = "Indoneza" ;
$out_languages {"ie"} = "Interlingvao" ;
$out_languages {"ik"} = "Inupiaka" ;
$out_languages {"ii"} = "Sic&#265;uana jia" ;
$out_languages {"io"} = "Ido" ;
$out_languages {"is"} = "Islanda" ;
$out_languages {"it"} = "Itala" ;
$out_languages {"iu"} = "Inuktituta" ;
$out_languages {"ja"} = "Japana" ;
$out_languages {"jbo"} = "Lo&#309;bana" ;
$out_languages {"jv"} = "Java" ;
$out_languages {"ka"} = "Kartvela" ;
$out_languages {"kj"} = "Kuanjama" ;
$out_languages {"kk"} = "Kaza&#293;a" ;
$out_languages {"kl"} = "Grondlanda" ;
$out_languages {"km"} = "Kambo&#285;a" ;
$out_languages {"kn"} = "Kannada" ;
$out_languages {"ko"} = "Korea" ;
$out_languages {"kr"} = "Kanura" ;
$out_languages {"ks"} = "Ka&#349;mira" ;
$out_languages {"kw"} = "Kornvala" ;
$out_languages {"ky"} = "Kirgiza" ;
$out_languages {"la"} = "Latina" ;
$out_languages {"lb"} = "Luksemburga" ;
$out_languages {"li"} = "Limburgia" ;
$out_languages {"ln"} = "Lingala" ;
$out_languages {"lo"} = "Laosa" ;
$out_languages {"lt"} = "Litova" ;
$out_languages {"lv"} = "Latva" ;
$out_languages {"mg"} = "Malagasa" ;
$out_languages {"mh"} = "Mar&#349;ala" ;
$out_languages {"mi"} = "Maora" ;
$out_languages {"mk"} = "Makedona" ;
$out_languages {"ml"} = "Malajalama" ;
$out_languages {"mn"} = "Mongola" ;
$out_languages {"mo"} = "Moldava" ;
$out_languages {"mr"} = "Marata" ;
$out_languages {"ms"} = "Malaja" ;
$out_languages {"mt"} = "Malta" ;
$out_languages {"mus"} = "Mukogia" ;
$out_languages {"my"} = "Burma" ;
$out_languages {"na"} = "Na&#365;ra" ;
$out_languages {"nah"} = "Na&#365;atla" ;
$out_languages {"nds"} = "Platgermana" ;
$out_languages {"ne"} = "Nepala" ;
$out_languages {"nl"} = "Nederlanda" ;
$out_languages {"nn"} = "Norvega malnova" ;
$out_languages {"no"} = "Norvega" ;
$out_languages {"nv"} = "Navaha" ;
$out_languages {"ny"} = "Njan&#285;a" ;
$out_languages {"oc"} = "Okcitana" ;
$out_languages {"om"} = "Oroma" ;
$out_languages {"or"} = "Orija" ;
$out_languages {"pa"} = "Pan&#285;aba" ;
$out_languages {"pl"} = "Pola" ;
$out_languages {"ps"} = "Pa&#349;tua" ;
$out_languages {"pt"} = "Portugala" ;
$out_languages {"qu"} = "Ke&#265;ua" ;
$out_languages {"rm"} = "Roman&#265;a" ;
$out_languages {"rn"} = "Burunda" ;
$out_languages {"ro"} = "Rumana" ;
$out_languages {"ru"} = "Rusa" ;
$out_languages {"rw"} = "Ruanda" ;
$out_languages {"sa"} = "Sanskrita" ;
$out_languages {"sc"} = "Sarda" ;
$out_languages {"scn"} = "Sicilia" ;
$out_languages {"sd"} = "Sinda" ;
$out_languages {"se"} = "Samea" ;
$out_languages {"sg"} = "Sangoa" ;
$out_languages {"sh"} = "Serbo-Kroata" ;
$out_languages {"si"} = "Sinhala" ;
$out_languages {"simple"} = "Simpla angla" ;
$out_languages {"sk"} = "Slovaka" ;
$out_languages {"sl"} = "Slovena" ;
$out_languages {"sm"} = "Samoa" ;
$out_languages {"sn"} = "&#384;ona" ;
$out_languages {"so"} = "Somalia" ;
$out_languages {"sq"} = "Albana" ;
$out_languages {"sr"} = "Serba" ;
$out_languages {"ss"} = "Svazia" ;
$out_languages {"st"} = "Sesota" ;
$out_languages {"su"} = "Sudana" ;
$out_languages {"sv"} = "Sveda" ;
$out_languages {"sw"} = "Svahila" ;
$out_languages {"ta"} = "Tamila" ;
$out_languages {"te"} = "Telugua" ;
$out_languages {"tg"} = "Ta&#285;ika" ;
$out_languages {"th"} = "Taja" ;
$out_languages {"ti"} = "Tigraja" ;
$out_languages {"tk"} = "Turkmena" ;
$out_languages {"tl"} = "Tagaloga" ;
$out_languages {"tlh"} = "Klignona" ;
$out_languages {"tn"} = "Cvana" ;
$out_languages {"to"} = "Tonga" ;
$out_languages {"tokipona"} = "Tokipona" ;
$out_languages {"tpi"} = "Tokpisina" ;
$out_languages {"tr"} = "Turka" ;
$out_languages {"ts"} = "Conga" ;
$out_languages {"tt"} = "Tatara" ;
$out_languages {"tum"} = "Tumbuka" ;
$out_languages {"tw"} = "Tvia" ;
$out_languages {"ty"} = "Tahitia" ;
$out_languages {"ug"} = "Ujgura" ;
$out_languages {"uk"} = "Ukrajna" ;
$out_languages {"ur"} = "Urdua" ;
$out_languages {"uz"} = "Uzbeka" ;
$out_languages {"ve"} = "Vendaa" ;
$out_languages {"vi"} = "Vjetnama" ;
$out_languages {"vo"} = "Volapuka" ;
$out_languages {"wa"} = "Valona" ;
$out_languages {"wo"} = "Volofa" ;
$out_languages {"xh"} = "Ksosa" ;
$out_languages {"yi"} = "Jida" ;
$out_languages {"yo"} = "Joruba" ;
$out_languages {"za"} = "&#284;uanga" ;
$out_languages {"zh"} = "&#264;ina" ;
$out_languages {"zu"} = "Zulua" ;
$out_languages {"zz"} = "&#264;iuj&nbsp;lingvoj" ;
}

1;
