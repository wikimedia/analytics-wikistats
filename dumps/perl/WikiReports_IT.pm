#!/usr/bin/perl

sub SetLiterals_IT
{
$out_statistics   = "Statistiche di Wikipedia" ;
$out_charts       = "Grafici di Wikipedia" ;
$out_btn_tables   = "Tabelle" ;
$out_btn_table    = "Tabelle" ; # new singular OK ?
$out_btn_charts   = "Grafici" ;

$out_wikipedia    = "Wikipedia" ;
$out_wikipedias   = "Wikipediani" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary   = "Wikizionario" ;
$out_wiktionaries = "Wikizionarioni" ;
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

$out_comparisons  = "Confronti" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Generate il " ;
$out_sqlfiles     = "dai dump SQL del " ;
$out_version      = "Versione dello script:" ;
$out_author       = "Autore" ;
$out_mail         = "Email" ;
$out_site         = "Sito web" ;
$out_home         = "Pagina principale" ;
$out_sitemap      = "Mappa del sito";
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
$out_year         = "anno" ;
$out_month        = "mese" ;
$out_mean         = "Media" ;
$out_growth       = "Crescita" ;
$out_total        = "Totale" ;
$out_bars         = "Barre" ;
$out_words        = "parole" ;
$out_zoom         = "Zoom" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " sono state applicate conversioni (semi)automatiche." ;

$out_phaseIII     = "Solo le Wikipedia che usano il software <a href='http://www.mediawiki.org'>MediaWiki</a> sono incluse.";

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free)" ; # new
$out_rendering    = "Rendering.... Please wait" ; # new

$out_sort_order   = "Le Wikipedia sono ordinate secondo il numero di link interni (esclusi i redirect). Questo sembra essere<br>".
                    "il termine di confronto migliore per l'intero progetto, rispetto al numero di articoli o alla grandezza del<br>".
                    "database: il numero di articoli non &egrave; cos&igrave; significativo, perch&eacute; alcune Wikipedia possono contenere molti<br>".
                    "piccoli articoli, o anche molti articoli generati automaticamente, mentre altre Wikipedia possono contenere<br>".
                    "pochi articoli, ma molto pi&ugrave; lunghi e scritti a mano. La grandezza del database dipende dal sistema di codici<br>".
                    "utilizzato (i caratteri Unicode occupano molto spazio) e su quanto significato ha ogni carattere (per esempio,<br>".
                    "ogni carattere cinese &egrave; in realt&agrave; una parola intera).<br>";
$out_not_included = "Not included" ; #new

$out_average_1    = "conteggi medi dei mesi mostrati" ;
$out_growth_1     = "crescita media mensile dei mesi mostrati" ;
$out_formula      = "formula" ;
$out_value        = "valore" ;
$out_monthes      = "mesi" ;
$out_skip_values  = "(le Wikipedia con valori inferiori a 10 non sono incluse)";

$out_history      = "Nota: i valori per i primi mesi sono troppo bassi.<br>". 
                    "La versioni precedenti degli articoli non erano sempre coservate nei primi tempi.";

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

$out_tbl1_intro   = "[[2]] wikipediani attivi recentemente, " .
                    "ordinati secondo il numero di contributi:" ;
$out_tbl1_intro2 = "sono contate solo le modifiche agli articoli, non quelle alle pagine discussione, etc";
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "Utente" ;
$out_tbl1_hdr2    = "Contributo" ;
$out_tbl1_hdr3    = "Primo contributo" ;
$out_tbl1_hdr4    = "Ultimo contributo" ;
$out_tbl1_hdr5    = "data" ;
$out_tbl1_hdr6    = "fa" ;
$out_tbl1_hdr7    = "total" ; # new
$out_tbl1_hdr8    = "last<br>30 days" ; # new
$out_tbl1_hdr9    = "rank" ; # new
$out_tbl1_hdr10   = "now" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Articoli" ; # new
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "[[3]] wikipediani recentemente assenti, " .
                   "ordinati secondo il numero di contributi:" ;

$out_tbl3_intro   = "Crescita nel numero di wikipediani registrati e attivi, e della loro attivit&agrave;" ;

$out_tbl3_hdr1a   = "Wikipediani" ;
$out_tbl3_hdr1e   = "Articoli" ;
$out_tbl3_hdr1l   = "Database" ;
$out_tbl3_hdr1o   = "Link" ;
$out_tbl3_hdr1t   = "Utilizzo giornaliero" ; # new

# use &nbsp; (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines

$out_tbl3_hdr1a2  = "(utenti&nbsp;registrati)" ;
$out_tbl3_hdr1e2  = "(escl.&nbsp;redirect)" ;

$out_tbl3_hdr2a   = "totale" ;
$out_tbl3_hdr2b   = "nuovi" ;
$out_tbl3_hdr2c   = "modifiche" ;
$out_tbl3_hdr2e   = "conteggio" ;
$out_tbl3_hdr2f   = "nuovi<br>al&nbsp;giorno" ;
$out_tbl3_hdr2h   = "media" ;
$out_tbl3_hdr2j   = "pi&ugrave;&nbsp;grandi&nbsp;di" ;
$out_tbl3_hdr2l   = "modifiche" ;
$out_tbl3_hdr2m   = "dimensione" ;
$out_tbl3_hdr2n   = "parole" ;
$out_tbl3_hdr2o   = "interni" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "immagine" ;
$out_tbl3_hdr2r   = "esterni" ;
$out_tbl3_hdr2s   = "redirect" ;
$out_tbl3_hdr2t   = "pagine<br>visitate" ;
$out_tbl3_hdr2u   = "visite" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "ufficiale" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;car." ;
$out_tbl3_hdr3h   = "modifiche" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] utenti anonimi, ordinati per numeri di contributi" ; # new
$out_table6_footer = "Complessivamente %d modifiche sono state fatte da utenti anonimi, rispetto a un totale di %d modifiche (%.0f\%)" ;

$out_tbl5_intro   = "Statistiche dei visitatori (basati sul risultato di  <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> ; ".
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definizioni</font></a>, " .
                    "<a href=''><font color='#000088'>grafici</font></a>)" ; #new
$out_tbl5_hdr1a   = "Media Giornaliera" ; # new
$out_tbl5_hdr1e   = "Totali Mensili" ; # new
$out_tbl5_hdr2a   = "Richieste" ; # new
$out_tbl5_hdr2b   = "Files" ; # new
$out_tbl5_hdr2c   = "Pagine" ; # new
$out_tbl5_hdr2d   = "Visite" ; # new
$out_tbl5_hdr2e   = "Siti" ; # new
$out_tbl5_hdr2f   = "KBytes" ; # new
$out_tbl5_hdr2g   = "Visite" ; # new
$out_tbl5_hdr2h   = "Pagine" ; # new
$out_tbl5_hdr2i   = "Files" ; # new
$out_tbl5_hdr2j   = "Richieste" ; # new

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"Wikipediani che hanno fatto almeno 10 modifiche da quando sono arrivati",
"Incremento dei wikipediani che hanno fatto almeno 10 modifiche da quando sono arrivati",
"Wikipediani che hanno contribuito 5 volte o pi&ugrave; in questo mese",
"Wikipediani che hanno contribuito 100 volte o pi&ugrave; in questo mese",
"Articoli che contengono almeno un link interno",
"Articoli che contengono almeno un link interno e 200 caratteri di testo leggibile, <br>".
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;togliendo codici wiki e html, link nascosti, etc.; inoltre le intestazioni non contano<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(le altre colonne sono basate sul metodo di conteggio ufficiale)",
"Nuovi articoli al giorno nell'ultimo mese",
"Numero medio di modifiche per articolo",
"Dimensione media di un articolo in bytes",
"Percentuale di articoli con almeno 0,5 Kb di testo leggibile (vedi F)",
"Percentuale di articoli con almeno 2 Kb di testo leggibile (vedi F)",
"Modifiche nell'ultimo mese (incl. redirect, incl. utenti non registrati)",
"Dimensione totale di tutti gli articoli (incl. redirect)",
"Numero totale di parole (escl. redirect, codici html/wiki e link nascosti)",
"Numero totale di link interni (escl. redirect, codici html/wiki e link nascosti)",
"Numero totale di link alle altre Wikipedia",
"Numero totale di immagini presentate",
"Numero totale di link ad altri siti",
"Numero totale di redirect",
"Pagine richieste al giorno (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definizione</font></a>, basato sul risultato di <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Visite al giorno (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definizione</font></a>, basato sul risultato di <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Dati degli ultimi mesi"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipediani che hanno contribuito 5 volte o pi&ugrave; in questo settimana",
"Wikipediani che hanno contribuito 25 volte o pi&ugrave; in questo settimana",
) ;

$out_legend_daily_edits = "Modifiche al giorno (incl. redirect, incl. utenti non registrati)" ;
$out_report_description_daily_edits = "Modifiche al giorno" ;
$out_report_description_edits       = "Modifiche al mese/giorno" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Utenti",
"Nuovi wikipediani",
"Wikipediani attivi",
"Wikipediani molto attivi",
"Numero di articoli (ufficiale)",
"Numero di articoli (alternativo)",
"Nuovi articoli al giorno",
"Modifiche per ogni articolo",
"Dimensione media in bytes",
"Articoli sopra gli 0,5 Kb",
"Articoli sopra i 2 Kb",
"Modifiche al mese",
"Dimensione del database",
"Parole",
"Link interni",
"Link alle altre Wikipedia",
"Immagini",
"Link web",
"Redirect",
"Pagine richieste al giorno",
"Visite al giorno",
"Riassunto"
) ;

# the full list is in WikiReports.pl
# this selection is for translators only
$out_languages {"als"} = "Alsaziano" ;
$out_languages {"ar"} = "Arabo" ;
$out_languages {"bg"} = "Bulgaro" ;
$out_languages {"bs"} = "Bosniaco" ;
$out_languages {"cs"} = "Ceco" ;
$out_languages {"cy"} = "Scozzese" ;
$out_languages {"da"} = "Danese" ;
$out_languages {"de"} = "Tedesco" ;
$out_languages {"el"} = "Greco" ;
$out_languages {"en"} = "Inglese" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Spagnolo" ;
$out_languages {"et"} = "Estone" ;
$out_languages {"fa"} = "Persiano" ;
$out_languages {"fi"} = "Finlandese" ;
$out_languages {"fr"} = "Francese" ;
$out_languages {"fy"} = "Frisio" ;
$out_languages {"ga"} = "Irlandese" ;
$out_languages {"gv"} = "Gaelico" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"he"} = "Ebraico" ;
$out_languages {"hr"} = "Croato" ;
$out_languages {"hu"} = "Ungherese" ;
$out_languages {"ia"} = "Interlingua" ;
$out_languages {"id"} = "Indonesiano" ;
$out_languages {"it"} = "Italiano" ;
$out_languages {"ja"} = "Giapponese" ;
$out_languages {"ka"} = "Georgiano" ;
$out_languages {"ko"} = "Coreano" ;
$out_languages {"la"} = "Latino" ;
$out_languages {"lt"} = "Lituano" ;
$out_languages {"ml"} = "Malayalam" ;
$out_languages {"ms"} = "Malay" ;
$out_languages {"my"} = "Burmese" ;
$out_languages {"nah"} = "Nahuatl" ;
$out_languages {"nl"} = "Olandese" ;
$out_languages {"no"} = "Norvegese" ;
$out_languages {"oc"} = "Occitan" ;
$out_languages {"pl"} = "Polacco" ;
$out_languages {"pt"} = "Portoghese" ;
$out_languages {"ro"} = "Rumeno" ;
$out_languages {"ru"} = "Russo" ;
$out_languages {"sh"} = "Serbo-Croato" ;
$out_languages {"sk"} = "Slovacco" ;
$out_languages {"sr"} = "Serbo" ;
$out_languages {"sv"} = "Svedese" ;
$out_languages {"ta"} = "Tamil" ;
$out_languages {"th"} = "Thai" ;
$out_languages {"tr"} = "Turco" ;
$out_languages {"vi"} = "Vietnamese" ;
$out_languages {"wa"} = "Wallonese" ;
$out_languages {"zh"} = "Cinese" ;
$out_languages {"zz"} = "Tutte&nbsp;le&nbsp;lingue" ;
}

1;



