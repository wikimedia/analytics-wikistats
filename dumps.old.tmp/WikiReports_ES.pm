#!/usr/bin/perl

sub SetLiterals_ES
{
$out_statistics   = "Estad&iacute;sticas de Wikipedia" ;
$out_charts       = "Gr&aacute;ficos de Wikipedia" ;
$out_btn_tables   = "Tablas" ;
$out_btn_table    = "Tabla" ; # new singular
$out_btn_charts   = "Gr&aacute;ficos" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipedias" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary   = "Wikcionario" ;
$out_wiktionaries = "Wikcionarios" ;
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

$out_comparisons  = "Comparaciones" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generado el " ;
$out_sqlfiles     = "del volcado de archivos SQL de " ;
$out_version      = "Versi&oacute;n del script:" ;
$out_author       = "Autor" ;
$out_mail         = "Correo" ;
$out_site         = "Sitio web" ;
$out_home         = "Portada" ;
$out_sitemap      = "Mapa del sitio";
$out_rendered     = "Charts rendered with " ; #new
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

$out_date         = "Fecha" ;
$out_year         = "a&ntilde;o" ;
$out_month        = "mes" ;
$out_mean         = "Media" ;
$out_growth       = "Crecimiento" ;
$out_total        = "Total" ;
$out_bars         = "Barras" ;
$out_words        = "palabras" ;
$out_zoom         = "Zoom" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " se han aplicado conversiones (semi-)autom&aacute;ticas." ;

$out_phaseIII     = "S&oacute;lo se incluyen las Wikipedias que utilizan <a href='http://www.mediawiki.org'>MediaWiki</a>." ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free)" ; # new
$out_rendering    = "Rendering.... Please wait" ; # new

$out_sort_order   = "Las Wikipedias se ordenan por n&uacute;mero de enlaces internos (excluyendo redirecciones)<br>" .
                    "Esto parece una base m&aacute;s justa para comparar el esfuerzo total que el n&uacute;mero de art&iacute;culos o el tama&ntilde;o de la base de datos:<br>" .
                    "El n&uacute;mero de art&iacute;culos no es tan significativo dado que algunas Wikipedias contienen principalmente art&iacute;culos cortos,<br>" .
                    "o incluso muchos art&iacute;culos generados autom&aacute;ticamente, mientras que otras contienen menos art&iacute;culos pero mucho m&aacute;s largos, todos escritos manualmente.<br>" .
                    "El tama&ntilde;o de la base de datos depende del sistema de codificaci&oacute;n (los caracteres unicode ocupan varios bytes) y <br>" .
                    "de cu&aacute;nto significado puede transmitirse con un &uacute;nico car&aacute;cter (por ejemplo, en chino los caracteres son palabras completas).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "promedio de los meses mostrados" ;
$out_growth_1     = "crecimiento mensual promedio de los meses mostrados" ;
$out_formula      = "f&oacute;rmula" ;
$out_value        = "valor" ;
$out_monthes      = "meses" ;
$out_skip_values  = "(Las Wikipedias con valor(es) < 10 no cuentan)" ;

$out_history      = "Nota: las cifras para los primeros meses son demasiado bajas. " .
                    "Al principio las revisiones no siempre se archivaban." ;

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

$out_tbl1_intro   = "[[2]] wikipedistas activos recientemente, " .
                    "ordenados por n&uacute;mero de contribuciones:" ;
$out_tbl1_intro2  = "no se cuentan las ediciones de las p&aacute;ginas de discusi&oacute;n, etc., s&oacute;lo las de los art&iacute;culos" ;
$out_tbl1_intro3  = "&Delta; = cambio en la clasificaci&oacute;n en 30 d&iacute;as" ;


$out_tbl1_hdr1    = "Usuario" ;
$out_tbl1_hdr2    = "Ediciones" ;
$out_tbl1_hdr3    = "Primera edici&oacute;n" ;
$out_tbl1_hdr4    = "Ultima edici&oacute;n" ;
$out_tbl1_hdr5    = "fecha" ;
$out_tbl1_hdr6    = "hace<br>'n' d&iacute;as" ;
$out_tbl1_hdr7    = "total" ;
$out_tbl1_hdr8    = "&uacute;ltimos<br>30 d&iacute;as" ;
$out_tbl1_hdr9    = "puesto" ;
$out_tbl1_hdr10   = "ahora" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Art&iacute;culos" ;
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "[[3]] wikipedistas ausentes recientemente, " .
                   "ordenados por n&uacute;mero de contribuciones:" ;

$out_tbl3_intro   = "Crecimiento en n&uacute;mero de wikipedistas registrados activos y su actividad" ;

$out_tbl3_hdr1a   = "Wikipedistas" ;
$out_tbl3_hdr1e   = "Art&iacute;culos" ;
$out_tbl3_hdr1l   = "Base de datos" ;
$out_tbl3_hdr1o   = "Enlaces" ;
$out_tbl3_hdr1t   = "Uso diario" ;

# use &nbsp; (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(usuarios registrados)" ;
$out_tbl3_hdr1e2  = "(excluyendo redirecciones)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "nuevos" ;
$out_tbl3_hdr2c   = "ediciones" ;
$out_tbl3_hdr2e   = "n&uacute;mero total" ;
$out_tbl3_hdr2f   = "nuevos<br>por&nbsp;d&iacute;a" ;
$out_tbl3_hdr2h   = "media" ;
$out_tbl3_hdr2j   = "mayor&nbsp;que" ;
$out_tbl3_hdr2l   = "ediciones" ;
$out_tbl3_hdr2m   = "tama&ntilde;o" ;
$out_tbl3_hdr2n   = "palabras" ;
$out_tbl3_hdr2o   = "internos" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "imagen" ;
$out_tbl3_hdr2r   = "externos" ;
$out_tbl3_hdr2s   = "redirecciones" ;
$out_tbl3_hdr2t   = "peticiones<br>de&nbsp;p&aacute;ginas" ;
$out_tbl3_hdr2u   = "visitas" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficial" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "ediciones" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0,5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] usuarios an&oacute;nimos, ordenados por n&uacute;mero de contribuciones";

$out_table6_footer = "En total %d ediciones fueron hechas por usuarios an&oacute;nimos, de un total de %d ediciones (%.0f\%)" ;


$out_tbl5_intro   = "Estad&iacute;sticas de visitantes (basadas en la salida de <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definiciones</font></a>, " .
                    "<a href=''><font color='#000088'>chart</font></a>)" ;
$out_tbl5_hdr1a   = "Media diaria" ;
$out_tbl5_hdr1e   = "Totales por mes" ;
$out_tbl5_hdr2a   = "Hits" ;
$out_tbl5_hdr2b   = "Archivos" ;
$out_tbl5_hdr2c   = "P&aacute;ginas" ;
$out_tbl5_hdr2d   = "Visitas" ;
$out_tbl5_hdr2e   = "Sitios" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "Visitas" ;
$out_tbl5_hdr2h   = "P&aacute;ginas" ;
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
"Wikipedistas que editaron al menos 10 veces desde su llegada",
"Incremento en wikipedistas que editaron al menos 10 veces desde su llegada",
"Wikipedistas que contribuyeron 5 veces o m&aacute;s en este mes",
"Wikipedistas que contribuyeron 100 veces o m&aacute;s en este mes",
"Art&iacute;culos que contienen al menos un enlace interno",
"Art&iacute;culos que contienen al menos un enlace interno y 200 caracteres de texto legible, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;descontando wiki- y c&oacute;digos HTML, enlaces escondidos, cabeceras de secci&oacute;n, etc. <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(las otras columnas se basan en el m&eacute;todo de cuenta oficial)",
"Nuevos art&iacute;culos por d&iacute;a en el mes pasado",
"N&uacute;mero medio de revisiones por art&iacute;culo",
"Tama&ntilde;o medio de art&iacute;culos en bytes",
"Porcentaje de art&iacute;culos con al menos 0,5 Kb de texto legible (ver F)",
"Porcentaje de art&iacute;culos con al menos 2 Kb de texto legible (ver F)",
"Ediciones en el pasado mes (incluyendo redirecciones, incluyendo colaboradores an&oacute;nimos)",
"Tama&ntilde;o combinado de todos los art&iacute;culos (incluyendo redirecciones)",
"N&uacute;mero total de palabras (excluyendo redirecciones, c&oacute;digos html/wiki y enlaces ocultos)",
"N&uacute;mero total de enlaces internos (excluyendo redirecciones, esbozos y listas de enlaces)",
"N&uacute;mero total de enlaces a otras Wikipedias",
"N&uacute;mero total de im&aacute;genes presentadas",
"N&uacute;mero total de enlaces a otros sitios",
"N&uacute;mero total de redirecciones",
"Peticiones de p&aacute;ginas por d&iacute;a (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, basado en la salida de <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Visitas por d&iacute;a (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, basado en <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Datos de los &uacute;ltimos meses"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedistas que contribuyeron 5 veces o m&aacute;s en una semana",
"Wikipedistas que contribuyeron 25 veces o m&aacute;s en una semana"
) ;

$out_legend_daily_edits = "Ediciones por d&iacute;a (incl. redirecciones, incl. colaboradores an&oacute;nimos)" ;
$out_report_description_daily_edits = "Ediciones por d&iacute;a" ;
$out_report_description_edits       = "Ediciones por mes/d&iacute;a" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Colaboradores",
"Wikipedistas nuevos",
"Wikipedistas activos",
"Wikipedistas muy activos",
"N&uacute;mero de art&iacute;culos (oficial)",
"N&uacute;mero de art&iacute;culos (alternativo)",
"Art&iacute;culos nuevos por d&iacute;a",
"Ediciones por art&iacute;culo",
"Bytes por art&iacute;culo",
"Art&iacute;culos de m&aacute;s de 0,5 Kb",
"Art&iacute;culos de m&aacute;s de 2 Kb",
"Ediciones por mes",
"Tama&ntilde;o de la base de datos",
"Palabras",
"Enlaces internos",
"Enlaces a otras Wikipedias",
"Im&aacute;genes",
"Enlaces externos",
"Redirecciones",
"Peticiones de p&aacute;gina por d&iacute;a",
"Visitas por d&iacute;a",
"Sumario"
) ;

$out_languages {"als"} = "Alsaciano" ;
$out_languages {"ar"} = "&Aacute;rabe" ;
$out_languages {"bg"} = "B&uacute;lgaro" ;
$out_languages {"bs"} = "Bosnio" ;
$out_languages {"cs"} = "Checo" ;
$out_languages {"cy"} = "Gal&eacute;s" ;
$out_languages {"da"} = "Dan&eacute;s" ;
$out_languages {"de"} = "Alem&aacute;n" ;
$out_languages {"el"} = "Griego" ;
$out_languages {"en"} = "Ingl&eacute;s" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Espa&ntilde;ol" ;
$out_languages {"et"} = "Estonio" ;
$out_languages {"fa"} = "Persa" ;
$out_languages {"fi"} = "Finland&eacute;s" ;
$out_languages {"fr"} = "Franc&eacute;s" ;
$out_languages {"fy"} = "Fris&oacute;n" ;
$out_languages {"ga"} = "Irland&eacute;s" ;
$out_languages {"gv"} = "Man&eacute;s" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"he"} = "Hebreo" ;
$out_languages {"hr"} = "Croata" ;
$out_languages {"hu"} = "H&uacute;ngaro" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"id"} = "Indonesio" ;
$out_languages {"it"} = "Italiano" ;
$out_languages {"ja"} = "Japon&eacute;s" ;
$out_languages {"ka"} = "Georgiano" ;
$out_languages {"ko"} = "Coreano" ;
$out_languages {"la"} = "Lat&iacute;n" ;
$out_languages {"lt"} = "Lituano" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"ms"} = "Malayo" ;
$out_languages {"my"} = "Birmano" ;
$out_languages {"nah"} = "N&aacute;huatl" ;
$out_languages {"nl"} = "Holand&eacute;s" ;
$out_languages {"nn"} = "Noruego (Nynorsk)" ;
$out_languages {"no"} = "Noruego" ;
$out_languages {"oc"} = "Occitano" ;
$out_languages {"pl"} = "Polaco" ;
$out_languages {"pt"} = "Portugu&eacute;s" ;
$out_languages {"ro"} = "Rumano" ;
$out_languages {"ru"} = "Ruso" ;
$out_languages {"sh"} = "Serbo-croata" ;
$out_languages {"simple"} = "Ingl&eacute;s&nbsp;simplificado" ;
$out_languages {"sk"} = "Eslovaco" ;
$out_languages {"sr"} = "Serbio" ;
$out_languages {"sv"} = "Sueco" ;
$out_languages {"ta"} = "Tamil" ;
$out_languages {"th"} = "Thai" ;
$out_languages {"tr"} = "Turco" ;
$out_languages {"vi"} = "Vietnamita" ;
$out_languages {"wa"} = "Val&oacute;n" ;
$out_languages {"zh"} = "Chino" ;
$out_languages {"zz"} = "Todos&nbsp;los&nbsp;idiomas"
;
}

# please also give example of whole date
# different languages use different styles like :

# August 18, 2003
# 18 de agosto de 2003

1;
