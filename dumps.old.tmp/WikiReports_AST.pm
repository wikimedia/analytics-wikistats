#!/usr/bin/perl

sub SetLiterals_AST
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Estad&iacute;stiques de Uiquipedia" ;
$out_charts       = "Gr&aacute;ficos de Uiquipedia" ;
$out_btn_tables   = "Tables" ;
$out_btn_table    = "Tabla" ;
$out_btn_charts   = "Gr&aacute;ficos" ;

$out_wikipedia    = "Uiquipedia" ;
$out_wikipedias   = "Uiquipedies" ;
$out_wikipedians  = "wikipedians" ; # new

$out_wiktionary   = "Uiccionariu" ;
$out_wiktionaries = "Uiccionarios" ;
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

$out_comparisons  = "Comparances" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Xener&aacute;u el" ;
$out_sqlfiles     = "Del volc&aacute;u de los archivos SQL de " ;
$out_version      = "Versi&oacute;n del Script:" ;
$out_author       = "Autor" ;
$out_mail         = "Correu" ;
$out_site         = "Sitiu Web" ;
$out_home         = "Portada" ;
$out_sitemap      = "Mapa del sitiu";
$out_rendered     = "Gr&aacute;ficos traduc&iacute;os con " ;
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "Index to EasyTimeline charts per Wikipedia" ; # new
$out_categories   = "Category Overview per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new
$out_scripts      = "Scripts" ; # new

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "Kb" ;
$out_bytes        = "b" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "fecha" ;
$out_year         = "a&ntilde;u" ;
$out_month        = "mes" ;
$out_mean         = "media" ;
$out_growth       = "xorrecimientu" ;
$out_total        = "total" ;
$out_bars         = "barres" ;
$out_words        = "pallabres" ;
$out_zoom         = "Zoom" ;

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = "Aplic&aacute;ronse conversiones semiautom&aacute;tiques." ;

$out_phaseIII     = "S&oacute;lo tan incluyies les uiquipedies que usen software <a href='http://www.mediawiki.org'>MediaWiki</a>." ;

$out_svg_viewer   = "Pa ver los conten&iacute;os desta p&aacute;xina va necesitar un " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "pa MS Explorer Win/Mac (llibre)" ;
$out_rendering    = "Traduciendo...por favor, espere" ;

$out_sort_order   = "Les Uiquipedies tan ordenaes per n&uacute;mberu de enllaces internos (excl. redirecciones)<br>" .
                    "Esto paez una bona base pa comparar mas que'l n&uacute;mberu de art&iacute;culos o el tama&ntilde;u de la base datos:<br>" .
                    "El n&uacute;mberu de art&iacute;culos nun ye tan importante, teniendo en cuenta que dalgunes uiquipedies tienen mayormente art&iacute;culos curtios,<br>" .
                    "o art&iacute;culos xeneraos por bots, mentantes otres tienen menos art&iacute;culos pero m&aacute;s llargos y fechos toos a mano.<br>" .
                    "El tama&ntilde;u de la base datos depende del sistema de codificaci&oacute;n (los caracteres unicode lleven munchos bytes) y <br>" .
                    "algunos significaos pueden tar represent&aacute;os por &uacute;n solu caracter (los signos chinos son pallabres).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "Promediu de los meses mostraos" ;
$out_growth_1     = "Xorrecimientu mediu mensual nos meses se&ntilde;alaos" ;
$out_formula      = "f&oacute;rmula" ;
$out_value        = "valor" ;
$out_monthes      = "meses" ;
$out_skip_values  = "(Les Uiquipedies con valores < 10 son descartaes)" ;

$out_history      = "Nota: Les cifres pa los primeros meses son muy baxes. " .
                    "El historial de revisiones nun ta siempre recoy&iacute;u nos primeros d&iacute;es." ;

$out_unique_users = "Unique users" ; # new
$out_archived     = "Archived" ; # new
$out_reg          = "Reg." ;   # new (Reg. = Registered)
$out_unreg        = "Unreg." ; # new (Unreg. = Unregistered)

$out_reg_users_edited = "reg. users edited" ; # new
$out_reg_user_edited  = "reg. user edited" ;  # new

$out_no_wikimedia = "This script has been developed for <a href='http://www.wikimedia.org'>Wikimedia</a>.<br>" .
                    "Results on other sites running Mediawiki software may vary.<br>" .
                    "For comparison: <a href='http://en.wikipedia.org/wikistats/EN/Sitemap.htm'>Wikipedia statistics</a>." ;

$out_webalizer_note = "Note: Webalizer data are not consistently available. Low figures for Dec 2003 are result of major server outage." ;
$out_svg_firefox  = "<br><a href='http://magnusmanske.de/wikimaps/index.php/How_to_SVG-enable_Firefox'>How to enable SVG in Firefox for Windows</a>" ;

$out_index        = "Index" ;    # new
$out_complete     = "Complete" ; # new
$out_concise      = "Concise" ;  # new

$out_categories_complete = "Complete" ; # new
$out_categories_concise  = "Concise" ;  # new
$out_categories_main     = "Main" ;     # new
$out_category_trees      = "Wikipedia Category Overviews" ; # new
$out_category_tree       = "Wikipedia Category Overview" ;  # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new

$out_tbl1_intro   = "[[2]] Uiquipedistes activos recientes, " .
                    "ordenaos por n&uacute;mberu de contribuciones:" ;
$out_tbl1_intro2  = "Solo se cuenten les ediciones de art&iacute;culos, non les de les p&aacute;xines de discusi&oacute;n, etc" ;
$out_tbl1_intro3  = "? = cambiu na posici&oacute;n en 30 d&iacute;es" ;

$out_tbl1_hdr1    = "Usuariu" ;
$out_tbl1_hdr2    = "Ediciones" ;
$out_tbl1_hdr3    = "Primera edici&oacute;n" ;
$out_tbl1_hdr4    = "Cabera edici&oacute;n" ;
$out_tbl1_hdr5    = "fecha" ;
$out_tbl1_hdr6    = "hai<br>'n' d&iacute;es" ;
$out_tbl1_hdr7    = "total" ;
$out_tbl1_hdr8    = "caberos<br>30 d&iacute;es" ;
$out_tbl1_hdr9    = "posici&oacute;n" ;
$out_tbl1_hdr10   = "agora" ;
$out_tbl1_hdr11   = "?" ;
$out_tbl1_hdr12   = "Art&iacute;culos" ;
$out_tbl1_hdr13   = "Otros" ;

$out_tbl2_intro  = "[[3]] uiquipedistes ausentes hai poco, " .
                   "orden&aacute;os por n&uacute;mberu de contribuciones:" ;

$out_tbl3_intro   = "Xorrecimientu nel n&uacute;mberu de uiquipedistes rexistraos activos y la so activid&aacute;" ;

$out_tbl3_hdr1a   = "Uiquipedistes" ;
$out_tbl3_hdr1e   = "Art&iacute;culos" ;
$out_tbl3_hdr1l   = "Base de datos" ;
$out_tbl3_hdr1o   = "Enllaces" ;
$out_tbl3_hdr1t   = "Usu diariu" ;

# use   (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(usuarios rexistraos)" ;
$out_tbl3_hdr1e2  = "(excl. redireiciones)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "nuevos" ;
$out_tbl3_hdr2c   = "ediciones" ;
$out_tbl3_hdr2e   = "total" ;
$out_tbl3_hdr2f   = "nuevos<br>per d&iacute;a" ;
$out_tbl3_hdr2h   = "principal" ;
$out_tbl3_hdr2j   = "mayor que" ;
$out_tbl3_hdr2l   = "ediciones" ;
$out_tbl3_hdr2m   = "tama&ntilde;u" ;
$out_tbl3_hdr2n   = "pallabres" ;
$out_tbl3_hdr2o   = "internos" ;
$out_tbl3_hdr2p   = "interuiqui" ;
$out_tbl3_hdr2q   = "semeyes" ;
$out_tbl3_hdr2r   = "esternos" ;
$out_tbl3_hdr2s   = "redireici&oacute;n" ;
$out_tbl3_hdr2t   = "p&aacute;xines<br>solicitaes" ;
$out_tbl3_hdr2u   = "visites" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = "> 5" ;
$out_tbl3_hdr3d   = "> 100" ;
$out_tbl3_hdr3e   = "oficial" ;
$out_tbl3_hdr3f   = "> 200 ch" ;
$out_tbl3_hdr3h   = "ediciones" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0.5 Kb" ;
$out_tbl3_hdr3k   = "2 Kb" ;

$out_tbl6_intro  = "[[4]] usuarios an&oacute;nimos, orden&aacute;o per n&uacute;mberu de contribuciones" ;
$out_table6_footer = "En total %d ediciones foron feches por usuarios an&oacute;nimos, d'un total de %d ediciones (%.0f\%)" ;


$out_tbl5_intro   = "Estad&iacute;stiques de visites (bas&aacute;es en <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definiciones</font></a>, " .
                    "<a href=''><font color='#000088'>chart</font></a>)" ;
$out_tbl5_hdr1a   = "Media diaria" ;
$out_tbl5_hdr1e   = "Totales mensuales" ;
$out_tbl5_hdr2a   = "Hits" ;
$out_tbl5_hdr2b   = "Archivos" ;
$out_tbl5_hdr2c   = "P&aacute;xines" ;
$out_tbl5_hdr2d   = "Visites" ;
$out_tbl5_hdr2e   = "Sitios" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "Visites" ;
$out_tbl5_hdr2h   = "P&aacute;xines" ;
$out_tbl5_hdr2i   = "Archivos" ;
$out_tbl5_hdr2j   = "Hits" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new


@out_tbl3_legend  = (
"Uiquipedistes qu'editaron un m&iacute;nimu de 10 vegaes dende qu'aportaron",
"Incrementu en uiquipedistes que editaron un m&iacute;nimu de 10 vegaes dende qu'aportaron",
"Uiquipedistes que contribuyeron 5 vegaes o m&aacute;s nesti mes",
"Uiquipedistes que contribuyeron 100 vegaes o m&aacute;s nesti mes",
"Art&iacute;culos que tienen como m&iacute;nimu un enllace internu",
"Art&iacute;culos que tienen como m&iacute;nimu un enllace internu y 200 caracteres de testu lle&iacute;ble, <br>" .
   "     excluyendo p&aacute;xines wiki y c&oacute;digos html, enllacios de cabecera ya escond&iacute;os, etc.;<br>" .
   "     (otres columnes b&aacute;sense nel m&eacute;todu oficial de contabilid&aacute;)",
"Art&iacute;culos nuevos per d&iacute;a nel mes pas&aacute;u",
"N&uacute;mberu medio de revisiones per art&iacute;culu",
"Media de bytes per art&iacute;culu",
"Proporci&oacute;n de art&iacute;culos con un m&iacute;nimu de 0,5 Kb de testu lle&iacute;ble (ver F)",
"Proporci&oacute;n de art&iacute;culos con un m&iacute;nimu de 2 Kb de testu lle&iacute;ble (ver F)",
"Ediciones nel mes pas&aacute;u (incl. redireciones, incl. usuarios an&oacute;nimos)",
"Tama&ntilde;u combin&aacute;u de tolos art&iacute;culos (incl. redireiciones)",
"N&uacute;mberu total de pallabres (excl. redireiciones, c&oacute;digos html/wiki y enllacios escond&iacute;os)",
"Total de enllacios (excl. redireiciones, entamos y llistes d'enllaces)",
"N&uacute;mberu total de enllaces interuiqius",
"N&uacute;mberu total de semeyes",
"N&uacute;mberu total de enllaces a otres webs",
"N&uacute;mberu total de redireiciones",
"P&aacute;xines solicitaes per d&iacute;a (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definici&oacute;n</font></a>, bas&aacute;u nel <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Visites per d&iacute;a (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definici&oacute;n</font></a>, bas&aacute;u nel <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Datos de los caberos meses"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Uiquipedistes que contribuyeron 5 vegaes o m&aacute;s n'una selmana",
"Uiquipedistes que contribuyeron 25 vegaes o m&aacute;s n'una selmana"
) ;

$out_legend_daily_edits = "Ediciones por d&iacute;a (incl. redireiciones, incl. collaboradores nun rexistr&aacute;os)" ;
$out_report_description_daily_edits    = "Ediciones per d&iacute;a" ;
$out_report_description_edits          = "Ediciones per mes/d&iacute;a" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Collaboradores",
"Uiquipedistes nuevos",
"Uiquipedistes activos",
"Uiquipedistes peractivos",
"N&uacute;mberu d'art&iacute;culos (oficial)",
"N&uacute;mberu d'art&iacute;culos (alternativu)",
"Art&iacute;culos nuevos per d&iacute;a",
"Ediciones por art&iacute;culu",
"Bytes por art&iacute;culu",
"Art&iacute;culos de m&aacute;s de 0,5 Kb",
"Art&iacute;culos de m&aacute;s de 2 Kb",
"Ediciones al mes",
"Tama&ntilde;u de la base de datos",
"Pallabres",
"Enllaces internos",
"Enllaces a otres uiquipedies",
"Semeyes",
"Enllaces Web",
"Redireiciones",
"P&aacute;xines solicitaes al d&iacute;a",
"Visites al d&iacute;a",
"Sumariu"
) ;

# if you don't know all translation please mark untranslated ones

$out_languages {"aa"} = "Afar" ;
$out_languages {"ab"} = "Abyasiu" ;
$out_languages {"af"} = "Africaans" ;
$out_languages {"als"} = "Alsacianu" ;
$out_languages {"am"} = "Amh&aacute;ricu" ;
$out_languages {"an"} = "Aragon&eacute;s" ;
$out_languages {"ar"} = "Arabe" ;
$out_languages {"as"} = "Asam&eacute;s" ;
$out_languages {"ast"} = "Asturianu" ;
$out_languages {"ay"} = "Aymar&aacute;" ;
$out_languages {"az"} = "Azerbaiyan&iacute;" ;
$out_languages {"ba"} = "Baxquir" ;
$out_languages {"be"} = "Bielorrusu" ;
$out_languages {"bg"} = "B&uacute;lgaru" ;
$out_languages {"bh"} = "Bihar&iacute;" ;
$out_languages {"bi"} = "Bislam&aacute;" ;
$out_languages {"bn"} = "Bengal&iacute;" ;
$out_languages {"bo"} = "Tibetanu" ;
$out_languages {"br"} = "Bret&oacute;n" ;
$out_languages {"bs"} = "Bosniu" ;
$out_languages {"bug"} = "Bugin&eacute;s" ;
$out_languages {"ca"} = "Catal&aacute;n" ;
$out_languages {"co"} = "Corsu" ;
$out_languages {"cs"} = "Checu" ;
$out_languages {"cy"} = "Gal&eacute;s" ;
$out_languages {"da"} = "Dan&eacute;s" ;
$out_languages {"de"} = "Alem&aacute;n" ;
$out_languages {"dz"} = "Dzongkha" ;
$out_languages {"el"} = "Griegu" ;
$out_languages {"en"} = "Ingl&eacute;s" ;
$out_languages {"eo"} = "Esperantu" ;
$out_languages {"es"} = "Espa&ntilde;ol" ;
$out_languages {"et"} = "Estoniu" ;
$out_languages {"eu"} = "Vascu" ;
$out_languages {"fa"} = "Persa" ;
$out_languages {"fi"} = "Fin&eacute;s" ;
$out_languages {"fj"} = "Fiyianu" ;
$out_languages {"fo"} = "Fero&eacute;s" ;
$out_languages {"fr"} = "Franc&eacute;s" ;
$out_languages {"fy"} = "Fris&oacute;n" ;
$out_languages {"ga"} = "Irland&eacute;s" ;
$out_languages {"gay"} = "Gayu" ;
$out_languages {"gd"} = "Escoc&eacute;s" ;
$out_languages {"gl"} = "Gallegu" ;
$out_languages {"gn"} = "Guaran&iacute;" ;
$out_languages {"gu"} = "Gujarat&iacute;" ;
$out_languages {"gv"} = "Man&eacute;s" ;
$out_languages {"ha"} = "Hausa" ;
$out_languages {"he"} = "Hebreu" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Croata" ;
$out_languages {"hu"} = "H&uacute;ngaru" ;
$out_languages {"hy"} = "Armeniu" ;
$out_languages {"ia"} = "Interllingua" ;
$out_languages {"iba"} = "Iban" ;
$out_languages {"id"} = "Indonesiu" ;
$out_languages {"ik"} = "Inupiak" ;
$out_languages {"io"} = "Ido" ;
$out_languages {"is"} = "Island&eacute;s" ;
$out_languages {"it"} = "Italianu" ;
$out_languages {"iu"} = "Inuktitut" ;
$out_languages {"ja"} = "Xapon&eacute;s" ;
$out_languages {"jv"} = "Xavan&eacute;s" ;
$out_languages {"ka"} = "Georgianu" ;
$out_languages {"kaw"} = "Kawi" ;
$out_languages {"kk"} = "Cazacu" ;
$out_languages {"kl"} = "Groenland&eacute;s" ;
$out_languages {"km"} = "Camboyanu" ;
$out_languages {"kn"} = "Kannada" ;
$out_languages {"ko"} = "Coreanu" ;
$out_languages {"ks"} = "Caxmir" ;
$out_languages {"ku"} = "Curdu" ;
$out_languages {"ky"} = "Kirgiz" ;
$out_languages {"la"} = "Llat&iacute;n" ;
$out_languages {"li"} = "Luxemburgu&eacute;s" ;
$out_languages {"ln"} = "Lingala" ;
$out_languages {"lo"} = "Lao" ;
$out_languages {"ls"} = "Latino Sine Flexione" ;
$out_languages {"lt"} = "Lituanu" ;
$out_languages {"lv"} = "Let&oacute;n" ;
$out_languages {"mad"} = "Madur&eacute;s" ;
$out_languages {"mak"} = "Macasar" ;
$out_languages {"mg"} = "Malgache" ;
$out_languages {"mi"} = "Maor&iacute;" ;
$out_languages {"mk"} = "Macedoniu" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"mn"} = "Mongol" ;
$out_languages {"mo"} = "Moldavu" ;
$out_languages {"mr"} = "Marat&iacute;" ;
$out_languages {"ms"} = "Malai" ;
$out_languages {"my"} = "Birmanu" ;
$out_languages {"na"} = "Nauru" ;
$out_languages {"nah"} = "Nahu&aacute;tl" ;
$out_languages {"nds"} = "Saxon Baxu" ;
$out_languages {"ne"} = "Nepal&iacute;" ;
$out_languages {"nl"} = "Holand&eacute;s" ;
$out_languages {"nn"} = "Noruegu (Nynorsk)" ;
$out_languages {"no"} = "Noruegu" ;
$out_languages {"oc"} = "Occitanu" ;
$out_languages {"om"} = "Oromo" ;
$out_languages {"or"} = "Oriya" ;
$out_languages {"pa"} = "Punyabi" ;
$out_languages {"pl"} = "Polacu" ;
$out_languages {"ps"} = "Paxtu" ;
$out_languages {"pt"} = "Portugu&eacute;s" ;
$out_languages {"qu"} = "Quechua" ;
$out_languages {"rm"} = "Retorrom&aacute;nicu" ;
$out_languages {"rn"} = "Kirundi" ;
$out_languages {"ro"} = "Rumanu" ;
$out_languages {"ru"} = "Rusu" ;
$out_languages {"rw"} = "Kinyarwanda" ;
$out_languages {"sa"} = "S&aacute;nscritu" ;
$out_languages {"sd"} = "Sind&iacute;" ;
$out_languages {"sg"} = "Sangro" ;
$out_languages {"sh"} = "Serbocroata" ;
$out_languages {"si"} = "Singal&eacute;s" ;
$out_languages {"simple"} = "Ingl&eacute;s Cenciellu" ;
$out_languages {"sk"} = "Eslovacu" ;
$out_languages {"sl"} = "Eslovenu" ;
$out_languages {"sm"} = "Samoanu" ;
$out_languages {"sn"} = "Xona" ;
$out_languages {"sq"} = "Alban&eacute;s" ;
$out_languages {"sr"} = "Serbiu" ;
$out_languages {"ss"} = "Siswati" ;
$out_languages {"st"} = "Sexoto" ;
$out_languages {"su"} = "Sudan&eacute;s" ;
$out_languages {"sv"} = "Suecu" ;
$out_languages {"sw"} = "Swahili" ;
$out_languages {"ta"} = "Tamil" ;
$out_languages {"te"} = "Telugu" ;
$out_languages {"tg"} = "Tayik" ;
$out_languages {"th"} = "Tai" ;
$out_languages {"ti"} = "Tigri&ntilde;a" ;
$out_languages {"tk"} = "Turkmenu" ;
$out_languages {"tl"} = "Tagalu" ;
$out_languages {"tn"} = "Setswana" ;
$out_languages {"to"} = "Tonga" ;
$out_languages {"tr"} = "Turcu" ;
$out_languages {"ts"} = "Tsonga" ;
$out_languages {"tt"} = "T&aacute;rtaru" ;
$out_languages {"tw"} = "Twi" ;
$out_languages {"ug"} = "Uigur" ;
$out_languages {"uk"} = "Ucranianu" ;
$out_languages {"ur"} = "Urdu" ;
$out_languages {"uz"} = "Uzbecu" ;
$out_languages {"vi"} = "Vietnamita" ;
$out_languages {"vo"} = "Volap&uuml;k" ;
$out_languages {"wa"} = "Val&oacute;n" ;
$out_languages {"wo"} = "Volof" ;
$out_languages {"yi"} = "Yidix" ;
$out_languages {"yo"} = "Yoruba" ;
$out_languages {"za"} = "Zhuang" ;
$out_languages {"zh"} = "Chinu" ;
$out_languages {"zu"} = "Zul&uacute;" ;
$out_languages {"zz"} = "Toles lling&uuml;es" ;
}

# end of file marker, do not remove:
1;
