#!/usr/bin/perl

# please specify all accented characters as html codes
# like &agrave; or $#224;
# do not edit with unicode editor, I will have to replace all unicode

# see for a list of codes
# http://evolt.org/article/ala/17/21234/

sub SetLiterals_PT # replace by language code
{
$out_thousands_separator = "." ;
$out_decimal_separator   = "," ;

$out_statistics   = "Estat&iacute;sticas da Wikip&eacute;dia" ;
$out_charts       = "Gr&aacute;ficos da Wikip&eacute;dia" ;
$out_btn_tables   = "Tabelas" ;
$out_btn_table    = "Tabela" ;
$out_btn_charts   = "Gr&aacute;ficos" ;

$out_wikipedia    = "Wikip&eacute;dia" ;
$out_wikipedias   = "Wikip&eacute;dias" ;
$out_wikipedians   = "wikipedistas" ; # new

$out_wiktionary   = "Wikcion&aacute;rio" ;
$out_wiktionaries = "Wikcion&aacute;rios" ;
$out_wiktionarians   = "wikcionaristas" ; # new

$out_wikibook        = "Wikilivros" ;  # new
$out_wikibooks       = "Wikilivros" ; # new
$out_wikibookies     = "wikiautores" ; # new

$out_wikiquote       = "Wikiquote" ;  # new
$out_wikiquotes      = "Wikiquotes" ; # new
$out_wikiquotarians  = "Wikiquotarians" ; # new

$out_wikinews        = "Wikinot&iacute;cias" ;  # new
$out_wikinewssites   = "S&iacute;tios de Wikinot&iacute;cias" ; # new
$out_wikireporters   = "wikinoticiaristas" ; # new

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Wikispecial" ;  # new
$out_wikispecials    = "Wikispecial sites" ; # new
$out_wikispecialists = "autores" ; # new

$out_wikimedia       = "Wikimedia" ;       # new
$out_wikimedia_sites = "S&iacute;tios da Wikimedia" ; # new

$out_comparisons  = "Compara&ccedil;&otilde;es" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "Estat&iacute;sticas geradas em " ; # I need to know what was generated, if it is the page, the website, the statistics etc. because the translation would be different.
$out_sqlfiles     = "a partir de c&oacute;pias do banco de dados SQL de " ;
$out_version      = "Vers&atilde;o do script:" ;
$out_author       = "Autor" ;
$out_mail         = "Endere&ccedil;o" ;
$out_site         = "S&iacute;tio web" ;
$out_home         = "P&aacute;gina inicial" ;
$out_sitemap      = "Mapa do s&iacute;tio";
$out_rendered     = "Gr&aacute;ficos gerados com " ;
$out_generated2   = "Tamb&eacute;m geradas:" ;       # new
$out_easytimeline = "Index to EasyTimeline charts per Wikipedia" ; # new
$out_categories   = "Category Overview per Wikipedia" ; # new
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new

$out_gigabytes    = "Gb" ;
$out_megabytes    = "Mb" ;
$out_kilobytes    = "kb" ;
$out_bytes        = "b" ;
$out_million      = "M" ;
$out_thousand     = "k" ;

$out_date         = "Data" ;
$out_year         = "ano" ;
$out_month        = "m&ecirc;s" ;
$out_mean         = "M&eacute;dia" ;
$out_growth       = "Crescimento" ;
$out_total        = "Total" ;
$out_bars         = "Barras" ;
$out_words        = "palavras" ;
$out_zoom         = "Zoom" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " convers&otilde;es (semi-)autom&aacute;ticas foram aplicadas." ;

$out_phaseIII     = "Somente as Wikip&eacute;dias que usam software da <a href='http://www.mediawiki.org'>MediaWiki</a> est&atilde;o inclu&iacute;das." ;

$out_svg_viewer   = "Para ver o conte&uacute;do desta p&aacute;gina, voc&ecirc; precisar&aacute; de um " .
                    "visualizador SVG, como o <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "para MS Explorer Win/Mac (gr&aacute;tis)" ;
$out_rendering    = "Carregando.... Aguarde, por favor" ;

$out_sort_order   = "As Wikip&eacute;dias est&atilde;o ordenadas por n&uacute;mero de liga&ccedil;&otilde;es internas (excluindo p&aacute;ginas de redirecionamento)<br>" .
                    "Isto parece ser mais justo como base de compara&ccedil;&atilde;o do esfor&ccedil;o total do que o n&uacute;mero de artigos ou o tamanho da base de dados:<br>" .
                    "o n&uacute;mero de artigos n&atilde;o &eacute; t&atilde;o significativo dado que algumas Wikip&eacute;dias consistem principalmente em artigos curtos,<br>" .
                    "ou mesmo muitos artigos gerados automaticamente, enquanto outras cont&ecirc;m menos artigos, mas estes s&atilde;o muito maiores e escritos &agrave; m&atilde;o.<br>" .
                    "O tamanho da base de dados depende do sistema de codifica&ccedil;&atilde;o (caracteres unicode ocupam muitos bytes) e <br>" .
                    "de quanto significado pode ser transmitido por um &uacute;nico caractere (por exemplo, caracteres chineses s&atilde;o palavras inteiras).<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "contagem m&eacute;dia nos meses mostrados" ;
$out_growth_1     = "crescimento mensal m&eacute;dio nos meses mostrados" ;
$out_formula      = "f&oacute;rmula" ;
$out_value        = "valor" ;
$out_monthes      = "meses" ;
$out_skip_values  = "(Wikip&eacute;dias com valor(es) < 10 s&atilde;o desconsideradas)" ;

$out_history      = "Nota: os valores para os primeiros meses est&atilde;o muito baixos. " .
                    "O hist&oacute;rico de revis&otilde;es nem sempre era preservado nos primeiros tempos." ;

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

$out_tbl1_intro   = "[[2]] wikipedistas recentemente ativos, " .
                    "ordenados por n&uacute;mero de contribui&ccedil;&otilde;es:" ;
$out_tbl1_intro2  = "somente edi&ccedil;&otilde;es em artigos s&atilde;o contadas, n&atilde;o altera&ccedil;&otilde;es em p&aacute;ginas de discuss&atilde;o, etc." ;
$out_tbl1_intro3  = "&Delta; = varia&ccedil;&atilde;o da posi&ccedil;&atilde;o nos &uacute;ltimos trinta dias" ;

$out_tbl1_hdr1    = "Usu&aacute;rio" ;
$out_tbl1_hdr2    = "Edi&ccedil;&otilde;es" ;
$out_tbl1_hdr3    = "Primeira edi&ccedil;&atilde;o" ;
$out_tbl1_hdr4    = "&uacute;ltima edi&ccedil;&atilde;o" ;
$out_tbl1_hdr5    = "data" ;
$out_tbl1_hdr6    = "dias<br>atr&aacute;s" ;
$out_tbl1_hdr7    = "total" ;
$out_tbl1_hdr8    = "&uacute;ltimos<br>30 dias" ;
$out_tbl1_hdr9    = "posi&ccedil;&atilde;o" ;
$out_tbl1_hdr10   = "agora" ;
$out_tbl1_hdr11   = "&Delta;" ;
$out_tbl1_hdr12   = "Artigos" ;
$out_tbl1_hdr13   = "Outros" ;

$out_tbl2_intro  = "[[3]] wikipedistas recentemente ausentes, " .
                   "ordenados por n&uacute;mero de contribui&ccedil;&otilde;es:" ;

$out_tbl3_intro   = "Crescimento no n&uacute;mero de wikipedistas ativos registrados e sua atividade" ;

$out_tbl3_hdr1a   = "Wikipedistas" ;
$out_tbl3_hdr1e   = "Artigos" ;
$out_tbl3_hdr1l   = "Base de dados" ;
$out_tbl3_hdr1o   = "Liga&ccedil;&otilde;es" ;
$out_tbl3_hdr1t   = "Uso di&aacute;rio" ;

# use &nbsp; (non breaking space) instead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(usu&aacute;rios&nbsp;registrados)" ;
$out_tbl3_hdr1e2  = "(excluindo&nbsp;p&aacute;ginas&nbsp;de&nbsp;redirecionamento)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "novos" ; # This translation refers to new 'articles'.
$out_tbl3_hdr2c   = "edi&ccedil;&otilde;es" ;
$out_tbl3_hdr2e   = "contagem" ;
$out_tbl3_hdr2f   = "novos<br>por&nbsp;dia" ;
$out_tbl3_hdr2h   = "m&eacute;dia" ;
$out_tbl3_hdr2j   = "maiores&nbsp;que" ;
$out_tbl3_hdr2l   = "edi&ccedil;&otilde;es" ;
$out_tbl3_hdr2m   = "tamanho" ;
$out_tbl3_hdr2n   = "palavras" ;
$out_tbl3_hdr2o   = "internas" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "imagem" ;
$out_tbl3_hdr2r   = "externas" ;
$out_tbl3_hdr2s   = "redirecio-<br>namento" ;
$out_tbl3_hdr2t   = "p&aacute;ginas<br>acessadas" ;
$out_tbl3_hdr2u   = "visitas" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "oficial" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;car" ;
$out_tbl3_hdr3h   = "edi&ccedil;&otilde;es" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0,5&nbsp;kb" ;
$out_tbl3_hdr3k   = "2&nbsp;kb" ;

$out_tbl6_intro  = "[[4]] usu&aacute;rios an&ocirc;nimos, ordenados por n&uacute;mero de contribui&ccedil;&otilde;es" ;
$out_table6_footer = "No total %d edi&ccedil;&otilde;es foram feitas por usu&aacute;rios an&ocirc;nimos, de um total de %d edi&ccedil;&otilde;es (% de \%)" ;

$out_tbl5_intro   = "Estat&iacute;sticas de visitantes (baseadas nos dados das <a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>defini&ccedil;&otilde;es</font></a>; " .
                    "do <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>, " .
                    "<a href=''><font color='#000088'>gr&aacute;fico</font></a>)" ;
$out_tbl5_hdr1a   = "M&eacute;dia di&aacute;ria" ;
$out_tbl5_hdr1e   = "Totais mensais" ;
$out_tbl5_hdr2a   = "Acessos" ;
$out_tbl5_hdr2b   = "Arquivos" ;
$out_tbl5_hdr2c   = "P&aacute;ginas" ;
$out_tbl5_hdr2d   = "Visitas" ;
$out_tbl5_hdr2e   = "S&iacute;tios" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "Visitas" ;
$out_tbl5_hdr2h   = "P&aacute;ginas" ;
$out_tbl5_hdr2i   = "Arquivos" ;
$out_tbl5_hdr2j   = "Acessos" ;

$out_tbl7_intro   = "Registros no banco de dados por dom&iacute;nio / Artigos categorizados<p>" .
                    "<small>1) Categorias inseridas por predefini&ccedil;&atilde;o n&atilde;o s&atilde;o detectadas.</small>" ; # new
$out_tbl7_hdr_ns  = "Dom&iacute;nio" ; # new
$out_tbl7_hdr_ca  = "Artigos<br>categorizados <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribui&ccedil;&atilde;o de edi&ccedil;&otilde;es de artigos por wikipedistas"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Artigo", "Usu&aacute;rio", "Projeto", "Imagem", "MediaWiki", "Predefini&ccedil;&atilde;o", "Ajuda", "Categoria") ; #new

@out_tbl3_legend  = (
"Wikipedistas que editaram pelo menos dez vezes desde que chegaram",
"Aumento no n&uacute;mero de wikipedistas que editaram pelo menos dez vezes desde que chegaram",
"Wikipedistas que contribu&iacute;ram cinco vezes ou mais este m&ecirc;s",
"Wikipedistas que contribu&iacute;ram cem vezes ou mais este m&ecirc;s",
"Artigos que cont&ecirc;m pelo menos uma liga&ccedil;&atilde;o interna",
"Artigos que cont&ecirc;m pelo menos uma liga&ccedil;&atilde;o interna e 200 caracteres de texto leg&iacute;vel, n&atilde;o contando c&oacute;digos wiki e html, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; liga&ccedil;&otilde;es ocultas, etc.; t&iacute;tulos tamb&eacute;m n&atilde;o contam (outras colunas s&atilde;o baseadas no m&eacute;todo oficial de contagem)",
"Novos artigos por dia no m&ecirc;s passado",
"N&uacute;mero m&eacute;dio de revis&otilde;es por artigo",
"Tamanho m&eacute;dio dos artigos em bytes",
"Porcentagem de artigos com pelo menos 0,5 kb de texto leg&iacute;vel (veja F)",
"Porcentagem de artigos com pelo menos 2 kb de texto leg&iacute;vel (veja F)",
"Edi&ccedil;&otilde;es no m&ecirc;s passado (incluindo p&aacute;ginas de redirecionamento e editores n&atilde;o registrados)",
"Tamanho combinado de todos os artigos (incluindo p&aacute;ginas de redirecionamento)",
"Total de palavras (excluindo p&aacute;ginas de redirecionamento, c&oacute;digos html e wiki e liga&ccedil;&otilde;es ocultas)",
"Total de liga&ccedil;&otilde;es internas (excluindo p&aacute;ginas de redirecionamento, esbo&ccedil;os e listas de liga&ccedil;&otilde;es",
"Total de liga&ccedil;&otilde;es para outras wikip&eacute;dias",
"Total de imagens apresentadas",
"Total de liga&ccedil;&otilde;es para outros s&iacute;tios",
"Total de p&aacute;ginas de redirecionamento",
"P&aacute;ginas acessadas por dia (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>defini&ccedil;&atilde;o</font></a>, base: dados do <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Visitas por dia (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>defini&ccedil;&atilde;o</font></a>, base: dados do<a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>)",
"Dados dos &uacute;ltimos meses"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedistas que contribu&iacute;ram cinco vezes ou mais em uma semana",
"Wikipedistas que contribu&iacute;ram vinte e cinco vezes ou mais em uma semana"
) ;

$out_legend_daily_edits = "Edi&ccedil;&otilde;es por dia (incluindo p&aacute;ginas de redirecionamento, incluindo editores n&atilde;o registrados)" ;
$out_report_description_daily_edits = "Edi&ccedil;&otilde;es por dia" ;
$out_report_description_edits       = "Edi&ccedil;&otilde;es por m&ecirc;s/dia" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Editores",
"Novos wikipedistas",
"Wikipedistas ativos",
"Wikipedistas muito ativos",
"Contagem de artigos (oficial)",
"Contagem de artigos (alternativa)",
"Novos artigos por dia",
"Edi&ccedil;&otilde;es por artigo",
"Bytes por artigo",
"Artigos acima de 0,5 kb",
"Artigos acima de 2 kb",
"Edi&ccedil;&otilde;es por m&ecirc;s",
"Tamanho da base de dados",
"Palavras",
"Liga&ccedil;&otilde;es internas",
"Liga&ccedil;&otilde;es para outras wikip&eacute;dias",
"Imagens",
"Liga&ccedil;&otilde;es Web",
"P&aacute;ginas de redirecionamento",
"P&aacute;ginas acessadas por dia",
"Visitas por dia",
"Sum&aacute;rio"
) ;

# if you don't know all translation please mark untranslated ones

$out_languages {"aa"} = "Afar" ; # *
$out_languages {"ab"} = "Abkhaz" ; # *
$out_languages {"af"} = "Afric&acirc;ner" ;
$out_languages {"als"} = "Alsaciano" ;
$out_languages {"am"} = "Am&aacute;rico" ;
$out_languages {"an"} = "Aragon&ecirc;s" ;
$out_languages {"ar"} = "&aacute;rabe" ;
$out_languages {"as"} = "Assam&ecirc;s" ;
$out_languages {"ast"} = "Asturiano" ;
$out_languages {"ay"} = "Aimar&aacute;" ;
$out_languages {"az"} = "Azeri" ;
$out_languages {"ba"} = "Bachkir" ; # *
$out_languages {"be"} = "Bielorrusso" ;
$out_languages {"bg"} = "B&uacute;lgaro" ;
$out_languages {"bh"} = "Bihari" ; # *
$out_languages {"bi"} = "Bislama" ; # *
$out_languages {"bn"} = "Bengali" ; # *
$out_languages {"bo"} = "Tibetano" ;
$out_languages {"br"} = "Bret&atilde;o" ;
$out_languages {"bs"} = "B&oacute;snio" ;
$out_languages {"bug"} = "Bugin&ecirc;s" ; # *
$out_languages {"ca"} = "Catal&atilde;o" ;
$out_languages {"co"} = "Corso" ;
$out_languages {"cs"} = "Tcheco" ;
$out_languages {"cy"} = "Gal&ecirc;s" ;
$out_languages {"da"} = "Dinamarqu&ecirc;s" ;
$out_languages {"de"} = "Alem&atilde;o" ;
$out_languages {"dz"} = "Zonc&aacute;" ;
$out_languages {"el"} = "Grego" ;
$out_languages {"en"} = "Ingl&ecirc;s" ;
$out_languages {"eo"} = "Esperanto" ;
$out_languages {"es"} = "Espanhol" ;
$out_languages {"et"} = "Estoniano" ;
$out_languages {"eu"} = "Basco" ;
$out_languages {"fa"} = "Persa" ;
$out_languages {"fi"} = "Finland&ecirc;s" ;
$out_languages {"fj"} = "Fijiano" ;
$out_languages {"fo"} = "Fero&ecirc;s" ;
$out_languages {"fr"} = "Franc&ecirc;s" ;
$out_languages {"fy"} = "Fr&iacute;sio" ;
$out_languages {"ga"} = "Ga&eacute;lico Irland&ecirc;s" ;
$out_languages {"gay"} = "Gayo" ; # *
$out_languages {"gd"} = "Ga&eacute;lico Escoc&ecirc;s" ;
$out_languages {"gl"} = "Galego" ;
$out_languages {"gn"} = "Guarani" ;
$out_languages {"gu"} = "Guzerate" ;
$out_languages {"gv"} = "Ga&eacute;lico Manx" ;
$out_languages {"ha"} = "Hau&ccedil;&aacute;" ;
$out_languages {"he"} = "Hebraico" ;
$out_languages {"hi"} = "Hindi" ;
$out_languages {"hr"} = "Croata" ;
$out_languages {"hu"} = "H&uacute;ngaro" ;
$out_languages {"hy"} = "Arm&ecirc;nio" ;
$out_languages {"ia"} = "Interl&iacute;ngua" ;
$out_languages {"iba"} = "Iban" ; # *
$out_languages {"id"} = "Indon&eacute;sio" ;
$out_languages {"ik"} = "Inupiak" ; # *
$out_languages {"io"} = "Ido" ;
$out_languages {"is"} = "Island&ecirc;s" ;
$out_languages {"it"} = "Italiano" ;
$out_languages {"iu"} = "Inuktitut" ; # *
$out_languages {"ja"} = "Japon&ecirc;s" ;
$out_languages {"jv"} = "Javan&ecirc;s" ;
$out_languages {"ka"} = "Georgiano" ;
$out_languages {"kaw"} = "Kawi" ; # *
$out_languages {"kk"} = "Cazaque" ;
$out_languages {"kl"} = "Groenland&ecirc;s" ;
$out_languages {"km"} = "Cambodjano" ;
$out_languages {"kn"} = "Kannada" ; # *
$out_languages {"ko"} = "Coreano" ;
$out_languages {"ks"} = "Caxemira" ;
$out_languages {"ku"} = "Curdo" ;
$out_languages {"ky"} = "Quirguiz" ;
$out_languages {"la"} = "Latim" ;
$out_languages {"li"} = "Limburgu&ecirc;s" ;
$out_languages {"ln"} = "Lingala" ; # *
$out_languages {"lo"} = "Laociano" ;
$out_languages {"ls"} = "Latino Sine Flexione" ; # *
$out_languages {"lt"} = "Lituano" ;
$out_languages {"lv"} = "Leto" ;
$out_languages {"mad"} = "Madur&ecirc;s" ; # *
$out_languages {"mak"} = "Macassar" ; # *
$out_languages {"mg"} = "Malgaxe" ;
$out_languages {"mi"} = "Maori" ;
$out_languages {"mk"} = "Maced&ocirc;nio" ;
$out_languages {"ml"} = "Malaiala" ;
$out_languages {"mn"} = "Mongol" ;
$out_languages {"mo"} = "Mold&aacute;vio" ;
$out_languages {"mr"} = "Marathi" ; # *
$out_languages {"ms"} = "Malaio" ;
$out_languages {"my"} = "Birman&ecirc;s" ;
$out_languages {"na"} = "Nauruano" ;
$out_languages {"nah"} = "N&aacute;uatle" ;
$out_languages {"nds"} = "Baixo-Sax&ocirc;nico" ;
$out_languages {"ne"} = "Nepal&ecirc;s" ;
$out_languages {"nl"} = "Holand&ecirc;s" ;
$out_languages {"nn"} = "Noruegu&ecirc;s (Nynorsk)" ;
$out_languages {"no"} = "Noruegu&ecirc;s" ;
$out_languages {"oc"} = "Occit&acirc;nico" ;
$out_languages {"om"} = "Oromo" ; # *
$out_languages {"or"} = "Oriya" ; # *
$out_languages {"pa"} = "Punjabi" ; # *
$out_languages {"pl"} = "Polon&ecirc;s" ;
$out_languages {"ps"} = "Pachto" ; # *
$out_languages {"pt"} = "Portugu&ecirc;s" ;
$out_languages {"qu"} = "Qu&iacute;chua" ;
$out_languages {"rm"} = "Reto-romanche" ;
$out_languages {"rn"} = "Kirundi" ; # *
$out_languages {"ro"} = "Romeno" ;
$out_languages {"ru"} = "Russo" ;
$out_languages {"rw"} = "Kinyarwanda" ; # *
$out_languages {"sa"} = "S&acirc;nscrito" ;
$out_languages {"sd"} = "Sindhi" ; # *
$out_languages {"sg"} = "Sangro" ; # *
$out_languages {"sh"} = "Serbo-Croata" ;
$out_languages {"si"} = "Cingal&ecirc;s" ;
$out_languages {"simple"} = "Ingl&ecirc;s&nbsp;Simplificado" ;
$out_languages {"sk"} = "Eslovaco" ;
$out_languages {"sl"} = "Esloveno" ;
$out_languages {"sm"} = "Samoano" ;
$out_languages {"sn"} = "Shona" ; # *
$out_languages {"sq"} = "Alban&ecirc;s" ;
$out_languages {"sr"} = "S&eacute;rvio" ;
$out_languages {"ss"} = "Siswati" ; # *
$out_languages {"st"} = "Seshoto" ; # *
$out_languages {"su"} = "Sundan&ecirc;s" ;
$out_languages {"sv"} = "Sueco" ;
$out_languages {"sw"} = "Sua&iacute;le" ;
$out_languages {"ta"} = "T&acirc;mil" ;
$out_languages {"te"} = "T&eacute;lugo" ;
$out_languages {"tg"} = "Tadjique" ;
$out_languages {"th"} = "Tai" ;
$out_languages {"ti"} = "Tigrinya" ; # *
$out_languages {"tk"} = "Turcomeno" ;
$out_languages {"tl"} = "Tagalo" ;
$out_languages {"tn"} = "Setswana" ; # *
$out_languages {"to"} = "Tonga" ;
$out_languages {"tr"} = "Turco" ;
$out_languages {"ts"} = "Tsonga" ; # *
$out_languages {"tt"} = "T&aacute;taro" ;
$out_languages {"tw"} = "Twi" ; # *
$out_languages {"ug"} = "Uigur" ;
$out_languages {"uk"} = "Ucraniano" ;
$out_languages {"ur"} = "Urdu" ;
$out_languages {"uz"} = "Usbeque" ;
$out_languages {"vi"} = "Vietnamita" ;
$out_languages {"vo"} = "Volapuque" ;
$out_languages {"wa"} = "Val&atilde;o" ;
$out_languages {"wo"} = "Uolofe" ;
$out_languages {"yi"} = "I&iacute;diche" ;
$out_languages {"yo"} = "Iorub&aacute;" ;
$out_languages {"za"} = "Zhuang" ; # *
$out_languages {"zh"} = "Chin&ecirc;s" ;
$out_languages {"zu"} = "Zulu" ;
$out_languages {"zz"} = "Todas as&nbsp;l&iacute;nguas" ;
}

# end of file marker, do not remove:
1;

