#!/usr/bin/perl

sub SetLiterals_CA
{
$out_statistics      = "Estad&iacute;stiques de la Viquip&egrave;dia" ;
$out_charts          = "Diagrames de la Viquip&egrave;dia" ;
$out_btn_tables      = "Taules" ;
$out_btn_table       = "Taule" ; # new singular OK ?
$out_btn_charts      = "Diagrames" ;

$out_wikipedia       = "Viquip&egrave;dia" ;
$out_wikipedias      = "Viquip&egrave;dies" ;
$out_wikipedians     = "wikipedians" ; # new

$out_wiktionary      = "Wiktionary" ;
$out_wiktionaries    = "Wiktionaries" ;
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

$out_comparisons     = "Comparacions" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generat a " ;
$out_sqlfiles     = "a partir dels fitxers de SQL dump de " ;
$out_version      = "Versi&oacute; de l'Script:" ;
$out_author       = "Autor" ;
$out_mail         = "Correu" ;
$out_site         = "Lloc web" ;
$out_home         = "Principal" ;
$out_sitemap      = "Mapa del lloc";
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

$out_date         = "Data" ;
$out_year         = "any" ;
$out_month        = "mes" ;
$out_mean         = "Principal" ;
$out_growth       = "Creixement" ;
$out_total        = "Total" ;
$out_bars         = "Barres" ;
$out_words        = "Paraules" ;
$out_zoom         = "Ampliaci&oacute;" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " s'han aplicat conversions (semi-)autom&agrave;tiques." ;

$out_phaseIII     = "Nom&eacute;s s'ha incl&ograve;s les Viquip&egrave;dies que funcionen amb el programari <a href='http://www.mediawiki.org'>MediaWiki</a>." ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free)" ; # new
$out_rendering    = "Rendering.... Please wait" ; # new

$out_sort_order   = "Les Viquip&egrave;dies s'han ordenat pel nombre d'enlla&ccedil;os interns (excl. redireccions)<br>" .
                    "Aquesta sembla una base m&eacute;s justa per comparar l'esfor&ccedil; total que el nombre d'articles o la mida de la base de dades:<br>" .
                    "El nombre d'articles no &eacute;s tan significatiu degut a qu&egrave; algunes viquip&egrave;dies contenen b&agrave;sicament articles curts,<br>" .
                    "o alguns generats autom&agrave;ticament mentre que d'altres en contenen proporcionalment de m&eacute;s llargs i escruts completament a m&agrave;.<br>" .
                    "La mida de la base de dades dep&egrave;n del sistema de codificaci&oacute; (els car&agrave;cters unicode ocupen bastants octets) i <br>" .
                    "en quant de significat pot recollir cada car&agrave;cter (p.ex. els car&agrave;cters xinesos s&oacute;n paraules senceres).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "mesos demostrats que excedeixen el promig" ;
$out_growth_1     = "excedent mensual mig del creixement demostrat" ;
$out_formula      = "f&oacute;rmula" ;
$out_value        = "valor" ;
$out_monthes      = "mesos" ;
$out_skip_values  = "(Viquip&egrave;dies amb valors < 10 s&oacute;n omesos)" ;

$out_history      = "Nota: les figures pels primers mesos s&oacute;n massa baixes." .
                    "L'historial de revisi&oacute; no sempre s'ha preservat en els primers dies." ;

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

$out_tbl1_intro   = "[[2]] viquipedistes recentment actius, " .
                    "ordenat per nombre de contribucions:" ;
$out_tbl1_intro2  = "Only article edits are counted, not edits on discussion pages, etc" ; # new
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "Usuaris" ;
$out_tbl1_hdr2    = "Edicions" ;
$out_tbl1_hdr3    = "Primera edici&oacute;" ;
$out_tbl1_hdr4    = "&Uacute;ltima edici&oacute;" ;
$out_tbl1_hdr5    = "data" ;
$out_tbl1_hdr6    = "days<br>ago" ;
$out_tbl1_hdr7    = "total" ; # new
$out_tbl1_hdr8    = "last<br>30 days" ; # new
$out_tbl1_hdr9    = "rank" ; # new
$out_tbl1_hdr10   = "now" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Articles" ; # new
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "[[3]] viquipedistes recentment absents, " .
                   "ordenats pel nombre de redireccions:" ;

$out_tbl3_intro   = "Creixement en nombre de viquipedistes actius i la seva activitat" ;

$out_tbl3_hdr1a   = "Viquipedistes" ;
$out_tbl3_hdr1e   = "Articles" ;
$out_tbl3_hdr1l   = "Base de dades" ;
$out_tbl3_hdr1o   = "Enlla&ccedil;os" ;
$out_tbl3_hdr1t   = "&Uacute;s diari" ; # new

# use &nbsp; (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(usuaris&nbsp;registrats)" ;
$out_tbl3_hdr1e2  = "(excl.&nbsp;redirects)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "nous" ;
$out_tbl3_hdr2c   = "edicions" ;
$out_tbl3_hdr2e   = "compte" ;
$out_tbl3_hdr2f   = "nous<br>per&nbsp;dia" ;
$out_tbl3_hdr2h   = "principal" ;
$out_tbl3_hdr2j   = "m&eacute;s&nbsp;llargs&nbsp;que" ;
$out_tbl3_hdr2l   = "edicions" ;
$out_tbl3_hdr2m   = "mida" ;
$out_tbl3_hdr2n   = "paraules" ;
$out_tbl3_hdr2o   = "interns" ;
$out_tbl3_hdr2p   = "interwikis" ;
$out_tbl3_hdr2q   = "imatges" ;
$out_tbl3_hdr2r   = "externs" ;
$out_tbl3_hdr2s   = "redireccions" ;
$out_tbl3_hdr2t   = "sol&#183;licituds<br>de&nbsp;p&agrave;gines" ;
$out_tbl3_hdr2u   = "visites" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficial" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "edicions" ;
$out_tbl3_hdr3i   = "octets" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Ko" ;
$out_tbl3_hdr3k   = "2&nbsp;Ko" ;

$out_tbl6_intro  = "[[4]] anonymous users, ordered by number of contributions" ; # new
$out_table6_footer = "Alltogether %d edits were made by anonymous users, out of a total of %d edits (%.0f\%)" ; # new

$out_tbl5_intro   = "Estad&iacute;stiques de visitants (basat en <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> sortida&nbsp;de ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>defincions</font></a>, " .
                    "<a href=''><font color='#000088'>chart</font></a>)" ;

$out_tbl5_hdr1a   = "Mitjana di&agrave;ria" ;
$out_tbl5_hdr1e   = "Totals mensualment" ;
$out_tbl5_hdr2a   = "Clics" ;
$out_tbl5_hdr2b   = "Fitxers" ;
$out_tbl5_hdr2c   = "P&agrave;gines" ;
$out_tbl5_hdr2d   = "Visites" ;
$out_tbl5_hdr2e   = "Llocs" ;
$out_tbl5_hdr2f   = "Koctets" ;
$out_tbl5_hdr2g   = "Visites" ;
$out_tbl5_hdr2h   = "P&agrave;gines" ;
$out_tbl5_hdr2i   = "Fitxers" ;
$out_tbl5_hdr2j   = "Clics" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Viquipedistes que han editat almenys 10 cops des que van arribar",
"Increment dels viquipedistes que han editat almenys 10 cops des que van arribar",
"Viquipedistes que han contribu&iuml;t 5 cops o m&eacute;s en aquest mes",
"Viquipedistes que han contribu&iuml;t 100 cops o m&eacute;s en aquest mes",
"Articles que com a m&iacute;nim contenen un enlla&ccedil; intern",
"Articles que contenen almenys un enlla&ccedil; intern i 200 car&agrave;cters de text llegible, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sense fer cas dels codis wiki- i html, enlla&ccedil;os amagats, etc.; tampoc les cap&ccedil;aleres conten<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(altres columnes estan basades en el m&egrave;tode oficial de recompte)",
"Nous articles per dia del mes passat",
"Nombre principal de revisions per article",
"Mida principal d'articles en octets",
"Percentage d'articles amb almenys 0.5 Ko de text llegible (vegeu F)",
"Percentatge d'articles amb almenys 2 Ko de text llegible (vegeu F)",
"Edicions en el mes passat (incl. redireccions, incl. contribuidors no registrats)",
"Mida combinada de tots els articles (incl. redireccions)",
"Nombre total de paraules (excl. redireccions, codis html/wiki i enlla&ccedil;os amagats)",
"Nombre total d'enlla&ccedil;os interns (excl. redireccions, articles curts i llistats d'enlla&ccedil;os)",
"Nombre total d'enlla&ccedil;os a altres Viquip&egrave;dies",
"Nombre total d'imatges presentades",
"Nombre total d'enlla&ccedil;os cap a d'altres llocs",
"Nombre total de redireccions",
"Sol&#183;licituds de p&agrave;gina per dia (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, basat en <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Visites per dia (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definici&oacute;</font></a>, basat en <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> sortida)",
"Dades pels &uacute;ltims mesos"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Viquipedistes que han contribu&iuml;t 5 cops o m&eacute;s en aquest .. (week)", # new
"Viquipedistes que han contribu&iuml;t 25 cops o m&eacute;s en aquest .. (week)", # new
) ;

$out_legend_daily_edits = "Edicions per dia (incl. redireccions, incl. contribuidors no registrats)" ;
$out_report_description_daily_edits = "Edicions per dia" ;
$out_report_description_edits       = "Edicions per mes/dia" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Contribu&iuml;dors",
"Nous viquipedistes",
"Viquipedistes actius",
"Viquipedistes molt actius",
"Recompte d'articles (oficial)",
"Recompte d'articles (alternatiu)",
"Nous articles per dia",
"Edicions per article",
"Octets per article",
"Articles amb m&eacute;s de 0.5 Kb",
"Articles amb m&eacute;s de 2 Kb",
"Edicions per mes",
"Mida de la base de dades",
"Paraules",
"Enlla&ccedil;os intrerns",
"Enlla&ccedil;os a altres Viquip&egrave;dies",
"Imatges",
"Enlla&ccedil;os web",
"Redireccionaments",
"Sol&#183;licituds de p&agrave;gina per dia",
"Visites per dia",
"General"
) ;

# the full list is in WikiReports.pl
# this selection is for translators only
$out_languages {"als"} = "Alsaci&agrave;" ;
$out_languages {"ar"} = "&Agrave;rab" ;
$out_languages {"bg"} = "B&uacute;lgar" ;
$out_languages {"bs"} = "Bosni&agrave;" ;
$out_languages {"cs"} = "Txec" ;
$out_languages {"cy"} = "Gal&#183;l&egrave;s" ;
$out_languages {"da"} = "Dan&egrave;s" ;
$out_languages {"de"} = "Alemany" ;
$out_languages {"el"} = "Grec" ;
$out_languages {"en"} = "Angl&egrave;s" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Castell&agrave;" ;
$out_languages {"et"} = "Estoni&agrave;" ;
$out_languages {"fa"} = "Persa" ;
$out_languages {"fi"} = "Fin&egrave;s" ;
$out_languages {"fr"} = "Franc&egrave;s" ;
$out_languages {"fy"} = "Fris&oacute;" ;
$out_languages {"ga"} = "Irland&egrave;s" ;
$out_languages {"gv"} = "Ga&egrave;lic de Man" ;
$out_languages {"he"} = "Hebreu" ;
$out_languages {"hi"} = "Indi" ;
$out_languages {"hr"} = "Croat" ;
$out_languages {"hu"} = "Hongar&egrave;s" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"id"} = "Indonesi" ;
$out_languages {"it"} = "Itali&agrave;" ;
$out_languages {"ja"} = "Japon&egrave;s" ;
$out_languages {"ka"} = "Georgi&agrave;" ;
$out_languages {"ko"} = "Core&agrave;" ;
$out_languages {"la"} = "Llat&iacute;" ;
$out_languages {"lt"} = "Litu&agrave;" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"ms"} = "Malai" ;
$out_languages {"my"} = "Burm&egrave;s" ;
$out_languages {"na"} = "Naur&agrave;" ;
$out_languages {"nl"} = "Holand&egrave;s" ;
$out_languages {"nn"} = "Noruec (Nynorsk)" ;
$out_languages {"no"} = "Noruec" ;
$out_languages {"pl"} = "Polon&egrave;s" ;
$out_languages {"pt"} = "Portugu&egrave;s" ;
$out_languages {"ro"} = "Roman&egrave;s" ;
$out_languages {"ru"} = "Rus" ;
$out_languages {"sh"} = "Serbo-Croat" ;
$out_languages {"sk"} = "Eslovac" ;
$out_languages {"sl"} = "Eslov&egrave;" ;
$out_languages {"sr"} = "Serbi" ;
$out_languages {"sv"} = "Suec" ;
$out_languages {"ta"} = "T&agrave;mil" ;
$out_languages {"th"} = "Tailand&egrave;s" ;
$out_languages {"tr"} = "Turc" ;
$out_languages {"vi"} = "Vietnamita" ;
$out_languages {"zh"} = "Xin&egrave;s" ;
$out_languages {"zz"} = "Totes&nbsp;les&nbsp;lleng&uuml;es" ;
}



#Before consonants:
#(number) de (month) del (year) > 1 de gener del 2003,      24 de setembre
#del 2003
#
#Before vowel (for Abril, Agost, Octubre)
#
#(number) d'(month) del (year) > 1 d'agost del 2003, 13 d'abril del 2003

1;
