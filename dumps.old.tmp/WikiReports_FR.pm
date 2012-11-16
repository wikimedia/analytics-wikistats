#!/usr/bin/perl

sub SetLiterals_FR
{
$out_thousands_separator = " " ;
$out_decimal_separator   = "," ;

$out_statistics   = "Statistiques Wikip&eacute;dia" ;
$out_charts       = "Graphiques Wikip&eacute;dia" ;
$out_btn_tables   = "Tables" ;
$out_btn_table    = "Table" ;
$out_btn_charts   = "Graphiques" ;

$out_wikipedia    = "Wikip&eacute;dia" ;
$out_wikipedias   = "Wikip&eacute;dias" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary   = "Wiktionnaire" ;
$out_wiktionaries = "Wiktionnaires" ;
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

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_comparisons  = "Comparaisons" ;

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "G&eacute;n&eacute;r&eacute; le " ;
$out_sqlfiles     = "&agrave; partir des fichiers SQL du " ;
$out_version      = "Version du script:" ;
$out_author       = "Auteur" ;
$out_mail         = "Courriel" ;
$out_site         = "Site Web" ;
$out_home         = "Accueil" ;
$out_sitemap      = "Sitemap";
$out_rendered     = "Graphiques g&eacute;n&eacute;r&eacute;s par " ;
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "Index to EasyTimeline charts per Wikipedia" ; # new
$out_categories   = "Category Overview per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "Go" ;
$out_megabytes    = "Mo" ;
$out_kilobytes    = "Ko" ;
$out_bytes        = "o" ;
$out_million      = "M" ;
$out_thousand     = "K" ;

$out_date         = "Date" ;
$out_year         = "ann&eacute;e" ;
$out_month        = "mois" ;
$out_mean         = "Moyenne" ;
$out_growth       = "Progression" ;
$out_total        = "Total" ;
$out_bars         = "Barres" ;
$out_zoom         = "Zoom" ; # new
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " conversions (semi-)automatiques ont &eacute;t&eacute; appliqu&eacute;es." ;

$out_phaseIII     = "Seules les Wikip&eacute;dias <a href='http://www.mediawiki.org'>MediaWiki</a> sont comprises." ;

$out_svg_viewer   = "Pour visualiser le contenu de la page vous aurez besoin d'un visualiseur SVG " .
                    "comme par exemple <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG-viewer</a> " .
                    "pour MS Explorer Win/Mac (gratuit)" ;
$out_rendering    = "Graphes en cours ... Veuillez patienter" ;

$out_sort_order   = "Les Wikip&eacute;dias sont ordonn&eacute;s par nombre de liens internes (sauf les redirections)<br>" .
                    "Ceci semble une base plus &eacute;quitable pour comparer l'effort total que le nombre total d'articles ou la taille de la base de donn&eacute;es:<br>" .
                    "Le nombre d'articles n'est pas tr&egrave;s indicatif car certaines Wikip&eacute;dias contiennent surtout des articles courts,<br>" .
                    "ou m&ecirc;me de nombreux articles g&eacute;n&eacute;r&eacute;s automatiquement, tandis que d'autres Wikip&eacute;dias contiennent moins d'articles mais beaucoup plus longs, tous &eacute;crits manuellement.<br>" .
                    "La taille de la base de donn&eacute;es d&eacute;pend du syst&egrave;me d'encodage (les caract&egrave;res unicode prennent plusiers octets) et <br>" .
                    "de la quantit&eacute; d'information convoy&eacute;e par un caract&egrave;re (par exemple, les caract&egrave;res chinois repr&eacute;sentent des mots entiers).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "nombre moyen durant les mois affich&eacute;s" ;
$out_growth_1     = "progression mensuelle moyenne durant les mois affich&eacute;s" ;
$out_formula      = "formule" ;
$out_value        = "valeur" ;
$out_monthes      = "mois" ;
$out_skip_values  = "(Wikip&eacute;dias dont la valeur < 10 sont ignor&eacute;s)" ;

$out_history      = "Note: les valeurs pour les premiers mois sont trop basses. " .
                    "&Agrave; l'&eacute;poque, l'historique des versions n'&eacute;tait pas toujours pr&eacute;serv&eacute;." ;

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

$out_tbl1_intro   = "[[2]] contributeurs actifs r&eacute;cemment, " .
                    "tri&eacute;s par nombre de contributions:" ;
$out_tbl1_intro2  = "only article edits are counted, not edits on discussion pages, etc" ; # new
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "Utilisateur" ;
$out_tbl1_hdr2    = "Contributions" ;
$out_tbl1_hdr3    = "Premi&egrave;re contribution" ;
$out_tbl1_hdr4    = "Derni&egrave;re contribution" ;
$out_tbl1_hdr5    = "date" ;
$out_tbl1_hdr6    = "jours" ;
$out_tbl1_hdr7    = "total" ; # new
$out_tbl1_hdr8    = "last<br>30 days" ; # new
$out_tbl1_hdr9    = "rank" ; # new
$out_tbl1_hdr10   = "now" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Articles" ; # new
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "[[3]] contributeurs absents depuis peu, " .
                   "tri&eacute;s par nombre de contributions:" ;

$out_tbl3_intro   = "Progression en nombre de contributeurs actifs enregistr&eacute;s et leur activit&eacute;" ;

$out_tbl3_hdr1a   = "Wikip&eacute;diens" ;
$out_tbl3_hdr1e   = "Articles" ;
$out_tbl3_hdr1l   = "Base de donn&eacute;es" ;
$out_tbl3_hdr1o   = "Liens" ;
$out_tbl3_hdr1t   = "Utilisations par jour" ;

# use   (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(utilisateurs enregistr&eacute;s)" ;
$out_tbl3_hdr1e2  = "(sauf les redirections)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "nouveau" ;
$out_tbl3_hdr2c   = "r&eacute;dactions" ;
$out_tbl3_hdr2e   = "nombre" ;
$out_tbl3_hdr2f   = "nouveaux<br>par jour" ;
$out_tbl3_hdr2h   = "moyenne" ;
$out_tbl3_hdr2j   = "plus grand que" ;
$out_tbl3_hdr2l   = "r&eacute;dactions" ;
$out_tbl3_hdr2m   = "taille" ;
$out_tbl3_hdr2n   = "mots" ;
$out_tbl3_hdr2o   = "interne" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "image" ;
$out_tbl3_hdr2r   = "externe" ;
$out_tbl3_hdr2s   = "redirections" ;
$out_tbl3_hdr2t   = "demandes<br>de page" ;
$out_tbl3_hdr2u   = "visites" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = "> 5" ;
$out_tbl3_hdr3d   = "> 100" ;
$out_tbl3_hdr3e   = "officiel" ;
$out_tbl3_hdr3f   = "> 200 ch" ;
$out_tbl3_hdr3h   = "r&eacute;dactions" ;
$out_tbl3_hdr3i   = "octets" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Ko" ;
$out_tbl3_hdr3k   = "2&nbsp;Ko" ;

$out_tbl6_intro  = "[[4]] anonymous users, ordered by number of contributions" ; # new
$out_table6_footer = "Alltogether %d edits were made by anonymous users, out of a total of %d edits (%.0f\%)" ; # new

$out_tbl5_intro   = "Statistiques des visiteurs (bas&eacute;es <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> sortie ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>d&eacute;finitions</font></a>, " .
                    "<a href=''><font color='#000088'>graphique</font></a>)" ;
$out_tbl5_hdr1a   = "Moyenne quotidienne" ;
$out_tbl5_hdr1e   = "Totaux mensuels" ;
$out_tbl5_hdr2a   = "Hits" ; #  should be "Coups" ?
$out_tbl5_hdr2b   = "Fichiers" ;
$out_tbl5_hdr2c   = "Pages" ;
$out_tbl5_hdr2d   = "Visites" ;
$out_tbl5_hdr2e   = "Sites" ;
$out_tbl5_hdr2f   = "KOctets" ;
$out_tbl5_hdr2g   = "Visites" ;
$out_tbl5_hdr2h   = "Pages" ;
$out_tbl5_hdr2i   = "Fichiers" ;
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
"Wikip&eacute;diens ayant r&eacute;dig&eacute; au moins 10 fois depuis leur arriv&eacute;e",
"Augmentation des wikip&eacute;diens ayant r&eacute;dig&eacute; au moins 10 fois depuis leur arriv&eacute;e",
"Wikip&eacute;diens ayant contribu&eacute; au moins 5 fois durant le mois pr&eacute;c&eacute;dent",
"Wikip&eacute;diens ayant contribu&eacute; au moins 100 fois durant le mois pr&eacute;c&eacute;dent",
"Articles contenant au moins un lien interne",
"Articles contenant au moins un lien interne et 200 caract&egrave;res de texte lisible, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&agrave; l'exclusion de codes wiki et HTML, liens cach&eacute;s, et des en-t&ecirc;tes<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(les autres colonnes sont bas&eacute;es sur le comptage officiel)",
"Nouveaux articles par jour durant le mois pr&eacute;c&eacute;dent",
"Nombre moyen de r&eacute;visions par articles",
"Taille moyenne des articles en octets",
"Pourcentage d'articles de plus de 0.5 Ko de texte lisible (ref F)",
"Pourcentage d'articles de plus de 2 Ko de texte lisible (ref F)",
"R&eacute;dactions durant le mois pr&eacute;c&eacute;dent (y compris les redirections et les contributions anonymes)",
"Taille combin&eacute;e de tous les articles (y compris les redirections)",
"Nombre total de mots (except&eacute; les redirections, codes wiki et HTML et liens cach&eacute;s)",
"Nombre total de liens internes (except&eacute; les redirections, les bouchons et les listes de liens)",
"Nombre total de liens vers les autres wikip&eacute;dias",
"Nombre total d'images pr&eacute;sent&eacute;es",
"Nombre total de liens vers d'autres sites",
"Nombre total de redirections",
"Demandes de page par jour (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>d&eacute;finition</font></a>, bas&eacute;es         <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> sortie)",
"Visites par jour (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>d&eacute;finition</font></a>, bas&eacute;es <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> sortie)",
"Donn&eacute;es pour les derniers mois"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikip&eacute;diens ayant contribu&eacute; au moins 5 fois durant la semaine pr&eacute;c&eacute;dent",
"Wikip&eacute;diens ayant contribu&eacute; au moins 25 fois durant la semaine pr&eacute;c&eacute;dent",
) ;

$out_legend_daily_edits = "R&eacute;dactions par jour (y compris les redirections et les contributions anonymes)" ;
$out_report_description_daily_edits = "R&eacute;dactions par jour" ;
$out_report_description_edits       = "R&eacute;dactions par mois/jour" ;
$out_report_description_current_status = "&Eacute;tat actuel" ; # new

@out_report_descriptions = (
"Contributeurs",
"Nouveaux wikip&eacute;diens",
"Wikip&eacute;diens actifs",
"Wikip&eacute;diens tr&egrave;s actifs",
"Nombre d'articles (officiel)", #(comptage officiel)
"Nombre d'articles (alternatif)", #(comptage alternatif)
"Nouveaux articles par jour",
"R&eacute;dactions par article",
"Octets par article",
"Articles de plus de 0.5 Ko",
"Articles de plus de 2 Ko",
"R&eacute;dactions par mois",
"Taille de la base de donn&eacute;es",
"Mots",
"Liens internes",
"Liens vers d'autres Wikip&eacute;dias",
"Images",
"Liens vers le Web",
"Redirections",
"Demandes de page par jour",
"Visites par jour",
"Vue&nbsp;d&#39;ensemble"
) ;

$out_languages {"als"} = "Alsacien" ;
$out_languages {"ar"} = "Arabe" ;
$out_languages {"az"} = "Az&eacute;ri" ;
$out_languages {"bg"} = "Bulgare" ;
$out_languages {"bs"} = "Bosniaque" ;
$out_languages {"co"} = "Corse" ;
$out_languages {"cs"} = "Tch&egrave;que" ;
$out_languages {"cy"} = "Gallois" ;
$out_languages {"da"} = "Danois" ;
$out_languages {"de"} = "Allemand" ;
$out_languages {"el"} = "Grec" ;
$out_languages {"en"} = "Anglais" ;
$out_languages {"eo"} = "Esp&eacute;ranto" ;
$out_languages {"es"} = "Espagnol" ;
$out_languages {"et"} = "Estonien" ;
$out_languages {"fa"} = "Farsi" ;
$out_languages {"fi"} = "Finnois" ;
$out_languages {"fr"} = "Fran&ccedil;ais" ;
$out_languages {"fy"} = "Frison" ;
$out_languages {"ga"} = "Ga&eacute;lique" ;
$out_languages {"gd"} = "Ga&eacute;lique &eacute;cossais" ;
$out_languages {"gl"} = "Galicien" ;
$out_languages {"gv"} = "Manxois" ;
$out_languages {"he"} = "H&eacute;breu" ;
$out_languages {"hi"} = "Hind&icirc;" ;
$out_languages {"hr"} = "Croate" ;
$out_languages {"hu"} = "Hongrois" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"id"} = "Indon&eacute;sien" ;
$out_languages {"is"} = "Islandais" ;
$out_languages {"it"} = "Italien" ;
$out_languages {"ja"} = "Japonais" ;
$out_languages {"jv"} = "Javanais" ;
$out_languages {"ka"} = "G&eacute;orgien" ;
$out_languages {"ko"} = "Cor&eacute;en" ;
$out_languages {"ku"} = "Kurde" ;
$out_languages {"la"} = "Latin" ;
$out_languages {"lt"} = "Lituanien" ;
$out_languages {"lv"} = "Letton" ;
$out_languages {"mk"} = "Mac&eacute;donien" ;
$out_languages {"ms"} = "Malais" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"my"} = "Birman" ;
$out_languages {"nds"} = "Bas-allemand" ;
$out_languages {"nl"} = "N&eacute;erlandais" ;
$out_languages {"nn"} = "Norv&eacute;gien (Nynorsk)" ;
$out_languages {"no"} = "Norv&eacute;gien" ;
$out_languages {"oc"} = "Occitan" ;
$out_languages {"pl"} = "Polonais" ;
$out_languages {"pt"} = "Portuguais" ;
$out_languages {"ro"} = "Roumain" ;
$out_languages {"ru"} = "Russe" ;
$out_languages {"se"} = "Anglais simplifi&eacute;" ;
$out_languages {"sk"} = "Slovaque" ;
$out_languages {"sl"} = "Slov&egrave;ne" ;
$out_languages {"sq"} = "Albanais" ;
$out_languages {"sr"} = "Serbe" ;
$out_languages {"sh"} = "Serbo-Croate" ;
$out_languages {"su"} = "Soudanais" ;
$out_languages {"sv"} = "Su&eacute;dois" ;
$out_languages {"ta"} = "Tamil" ;
$out_languages {"th"} = "Tha&iuml;" ;
$out_languages {"tr"} = "Turc" ;
$out_languages {"uk"} = "Ukrainien" ;
$out_languages {"vi"} = "Vietnamien" ;
$out_languages {"wa"} = "Walon" ;
$out_languages {"zh"} = "Chinois" ;
$out_languages {"zz"} = "Toutes les langues" ;
}

1;


