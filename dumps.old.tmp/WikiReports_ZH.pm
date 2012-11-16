#!/usr/bin/perl

sub SetLiterals_ZH
{
$out_statistics   = "&#32500;&#22522;&#30334;&#31185;&#25968;&#25454;" ;
$out_charts       = "&#32500;&#22522;&#30334;&#31185;&#22270;&#34920;" ;
$out_btn_tables   = "&#34920;&#26684;" ;
$out_btn_table    = "&#34920;&#26684;" ; # new singular OK ?
$out_btn_charts   = "&#22270;&#34920;" ;

$out_wikipedia    = "&#32500;&#22522;" ; # singular ??
$out_wikipedias   = "&#32500;&#22522;&#20154;" ;
$out_wikipedians   = "wikipedians" ; # new

$out_wiktionary   = "Wiktionary" ;
$out_wiktionaries = "Wiktionaries" ;
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

$out_comparisons  = "&#27604;&#36739;" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Average increase per month" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ; # new
$out_generated    = "&#29983;&#25104;&#26085;&#26399;&#65306;" ;
$out_sqlfiles     = "&#25968;&#25454;&#24211;&#26368;&#21518;&#26356;&#26032;&#65306;" ;
$out_version      = "&#33050;&#26412;&#29256;&#26412;" ;
$out_author       = "&#20316;&#32773;" ;
$out_mail         = "&#30005;&#23376;&#37038;&#20214;" ;
$out_site         = "&#32593;&#31449;" ;
$out_home         = "&#20027;&#39029;" ;
$out_sitemap      = "&#32593;&#31449;&#22320;&#22270;";
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

$out_date         = "&#26085;&#26399;" ;
$out_year         = "&#24180;" ;
$out_month        = "&#26376;" ;
$out_mean         = "&#24179;&#22343;" ;
$out_growth       = "&#25104;&#38271;" ;
$out_total        = "&#24635;&#35745;" ;
$out_bars         = "&#32479;&#35745;&#26465;" ;
$out_zoom         = "&#32858;&#28966;" ;
$out_scripts      = "Scripts" ; # new

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " &#25105;&#20204;&#20351;&#29992;&#20102;&#65288;&#21322;&#65289;&#33258;&#21160;&#36716;&#25442;&#12290;" ;

$out_phaseIII     = "&#21482;&#26377;&#20351;&#29992;<a href='http://www.mediawiki.org'>MediaWiki</a>&#36719;&#20214;&#30340;&#32500;&#22522;&#30334;&#31185;&#25165;&#34987;&#21015;&#20837;&#32479;&#35745;&#20013;&#12290;" ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free)" ; # new
$out_rendering    = "Rendering.... Please wait" ; # new

$out_sort_order   = "&#32500;&#22522;&#30334;&#31185;&#26159;&#26681;&#25454;&#20869;&#37096;&#38142;&#25509;&#25968;&#30446;&#25490;&#21015;&#30340;&#12290;<br>" .
                    "&#36825;&#35201;&#27604;&#25353;&#29031;&#26465;&#30446;&#25968;&#25110;&#25968;&#25454;&#24211;&#22823;&#23567;&#26469;&#25490;&#21015;&#26356;&#20844;&#24179;&#65306;<br>" .
                    "&#26465;&#30446;&#25968;&#24182;&#19981;&#33021;&#35828;&#26126;&#38382;&#39064;&#65292;&#22240;&#20026;&#19968;&#20123;&#32500;&#22522;&#30334;&#31185;&#21487;&#33021;&#21253;&#21547;&#20102;&#35768;&#22810;&#36739;&#30701;&#30340;&#26465;&#30446;<br>" .
                    "&#25110;&#19968;&#20123;&#33258;&#21160;&#29983;&#25104;&#30340;&#26465;&#30446;&#65292;&#32780;&#21478;&#19968;&#20123;&#21017;&#21487;&#33021;&#21253;&#21547;&#36739;&#23569;&#20294;&#26356;&#38271;&#30340;&#25991;&#31456;&#12290;<br>" .
                    "&#25968;&#25454;&#24211;&#30340;&#22823;&#23567;&#21462;&#20915;&#20110;&#32534;&#30721;&#31995;&#32479;&#65288;&#20687;unicode&#23383;&#31526;&#19968;&#33324;&#21344;&#20102;&#22810;&#20010;byte&#65289;&#65292;&#32780;&#19988;<br>" .
                    "&#21508;&#20010;&#35821;&#35328;&#30340;&#34920;&#36798;&#26041;&#24335;&#20063;&#19981;&#21516;&#65288;&#22914;&#19968;&#20010;&#20013;&#25991;&#23383;&#25152;&#33021;&#34920;&#36798;&#30340;&#24847;&#24605;&#24448;&#24448;&#19982;&#19968;&#20010;&#33521;&#25991;&#21333;&#35789;&#25152;&#33021;&#34920;&#36798;&#30340;&#24847;&#24605;&#30456;&#21516;&#65289;&#12290;<br>" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "&#24179;&#22343;&#32479;&#35745;" ;
$out_growth_1     = "&#24179;&#22343;&#27599;&#26376;&#25104;&#38271;" ;
$out_formula      = "&#20844;&#24335;" ;
$out_value        = "&#20540;" ;
$out_monthes      = "&#26376;&#20221;" ;
$out_skip_values  = "&#65288;&#25968;&#20540;&#23567;&#20110;10&#30340;&#26376;&#20221;&#26410;&#34987;&#21015;&#20837;&#32479;&#35745;&#65289;" ;
# new text: Wikipedia's with value(s) < 10 are omitted

$out_history      = "&#27880;&#24847;&#65306;&#21069;&#20960;&#20010;&#26376;&#30340;&#32479;&#35745;&#25968;&#23383;&#22826;&#23567;&#12290;" .
                    "&#26089;&#26399;&#24182;&#27809;&#26377;&#20445;&#23384;&#20462;&#35746;&#21382;&#21490;&#12290;" ;

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

$out_tbl1_intro   = "&#26368;&#36817;&#27963;&#36291;&#30340;[[2]]&#20010;&#32500;&#22522;&#20154;&#65292;" .
                    "&#25353;&#29031;&#36129;&#29486;&#30340;&#25968;&#37327;&#25490;&#24207;&#65306;" ;
$out_tbl1_intro2  = "&#65288;&#21482;&#32479;&#35745;&#20102;&#25991;&#31456;&#30340;&#32534;&#36753;&#27425;&#25968;&#65292;&#35752;&#35770;&#39029;&#38754;&#19978;&#30340;&#32534;&#36753;&#27425;&#25968;&#24182;&#26410;&#34987;&#21015;&#20837;&#65289;" ;
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "&#29992;&#25143;" ;
$out_tbl1_hdr2    = "&#32534;&#36753;" ;
$out_tbl1_hdr3    = "&#31532;&#19968;&#27425;&#32534;&#36753;" ;
$out_tbl1_hdr4    = "&#26368;&#21518;&#19968;&#27425;&#32534;&#36753;" ;
$out_tbl1_hdr5    = "&#26085;&#26399;" ;
$out_tbl1_hdr6    = "&#27880;&#20876;&#22825;&#25968;" ;
$out_tbl1_hdr7    = "total" ; # new
$out_tbl1_hdr8    = "last<br>30 days" ; # new
$out_tbl1_hdr9    = "rank" ; # new
$out_tbl1_hdr10   = "now" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "&#26465;&#30446;" ; # new
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "&#26368;&#36817;&#31163;&#24320;&#30340;[[3]]&#20010;&#32500;&#22522;&#20154;&#65292;" .
                   "&#25353;&#29031;&#36129;&#29486;&#30340;&#25968;&#37327;&#25490;&#24207;&#65306;" ;

$out_tbl3_intro   = "&#24050;&#27880;&#20876;&#30340;&#27963;&#36291;&#30340;&#32500;&#22522;&#20154;&#25968;&#37327;&#30340;&#25104;&#38271;&#24230;&#21450;&#20854;&#27963;&#36291;&#24230;" ;

$out_tbl3_hdr1a   = "&#32500;&#22522;&#20154;" ;
$out_tbl3_hdr1e   = "&#26465;&#30446;" ;
$out_tbl3_hdr1l   = "&#25968;&#25454;&#24211;" ;
$out_tbl3_hdr1o   = "&#38142;&#25509;" ;
$out_tbl3_hdr1t   = "&#27599;&#22825;&#20351;&#29992;&#29575;" ;

# use   (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(&#24050;&#27880;&#20876;&#29992;&#25143;)" ;
$out_tbl3_hdr1e2  = "(&#19981;&#21253;&#25324;&#37325;&#23450;&#21521;)" ;

$out_tbl3_hdr2a   = "&#24635;&#35745;" ;
$out_tbl3_hdr2b   = "&#26032;&#20154;" ;
$out_tbl3_hdr2c   = "&#32534;&#36753;" ;
$out_tbl3_hdr2e   = "&#35745;&#25968;" ;
$out_tbl3_hdr2f   = "&#27599;&#22825;<br>&#26032;&#22686;" ;
$out_tbl3_hdr2h   = "&#24179;&#22343;" ;
$out_tbl3_hdr2j   = "&#38271;&#26465;&#30446;" ;
$out_tbl3_hdr2l   = "&#32534;&#36753;" ;
$out_tbl3_hdr2m   = "&#22823;&#23567;" ;
$out_tbl3_hdr2n   = "&#23383;&#25968;" ;
$out_tbl3_hdr2o   = "&#20869;&#37096;&#38142;&#25509;" ;
$out_tbl3_hdr2p   = "&#36328;&#35821;&#35328;&#38142;&#25509;" ;
$out_tbl3_hdr2q   = "&#22270;&#20687;" ;
$out_tbl3_hdr2r   = "&#22806;&#37096;&#38142;&#25509;" ;
$out_tbl3_hdr2s   = "&#37325;&#23450;&#21521;" ;
$out_tbl3_hdr2t   = "&#39029;&#38754;<br>&#32034;&#21462;&#37327;" ;
$out_tbl3_hdr2u   = "&#35775;&#38382;&#37327;" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = "> 5" ;
$out_tbl3_hdr3d   = "> 100" ;
$out_tbl3_hdr3e   = "&#27491;&#24335;" ;
$out_tbl3_hdr3f   = "> 200&#23383;&#31526;" ;
$out_tbl3_hdr3h   = "&#32534;&#36753;" ;
$out_tbl3_hdr3i   = "&#23383;&#33410;" ;
$out_tbl3_hdr3j   = "0.5 Kb" ;
$out_tbl3_hdr3k   = "2 Kb" ;

$out_tbl6_intro  = "[[4]] anonymous users, ordered by number of contributions" ; # new
$out_table6_footer = "Alltogether %d edits were made by anonymous users, out of a total of %d edits (%.0f\%)" ; # new

$out_tbl5_intro   = "&#35775;&#38382;&#32773;&#32479;&#35745;(&#22522;&#20110;<a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>&#36755;&#20986;&#65307;" .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>&#35828;&#26126;</font></a>, " .
                    "<a href=''><font color='#000088'>&#22270;&#34920;</font></a>)" ;
$out_tbl5_hdr1a   = "&#24179;&#22343;&#27599;&#22825;" ;
$out_tbl5_hdr1e   = "&#27599;&#26376;&#24635;&#35745;" ;
$out_tbl5_hdr2a   = "&#28857;&#20987;" ;
$out_tbl5_hdr2b   = "&#25991;&#20214;" ;
$out_tbl5_hdr2c   = "&#39029;&#38754;" ;
$out_tbl5_hdr2d   = "&#35775;&#38382;" ;
$out_tbl5_hdr2e   = "&#31449;&#28857;" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "&#35775;&#38382;" ;
$out_tbl5_hdr2h   = "&#39029;&#38754;" ;
$out_tbl5_hdr2i   = "&#25991;&#20214;" ;
$out_tbl5_hdr2j   = "&#28857;&#20987;" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro = "Distribution of article edits over wikipedians"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Image", "MediaWiki", "Template", "Help", "Category") ; #new

@out_tbl3_legend  = (
"&#27880;&#20876;&#21518;&#33267;&#23569;&#32534;&#36753;&#20102;10&#27425;&#30340;&#32500;&#22522;&#20154;",
"&#27880;&#20876;&#21518;&#33267;&#23569;&#32534;&#36753;&#20102;10&#27425;&#30340;&#32500;&#22522;&#20154;&#30340;&#22686;&#38271;&#37327;",
"&#22312;&#35813;&#26376;&#36129;&#29486;&#22810;&#20110;5&#27425;&#30340;&#32500;&#22522;&#20154;",
"&#22312;&#35813;&#26376;&#36129;&#29486;&#22810;&#20110;100&#27425;&#30340;&#32500;&#22522;&#20154;",
"&#26465;&#30446;&#26368;&#23569;&#21253;&#21547;&#19968;&#20010;&#20869;&#37096;&#38142;&#25509;",
"&#26465;&#30446;&#26368;&#23569;&#21253;&#21547;&#19968;&#20010;&#20869;&#37096;&#38142;&#25509;&#24182;&#19988;&#26368;&#23569;&#26377;200&#20010;&#23383;&#31526;&#30340;&#25991;&#26412;&#65292;<br>" .
   "     &#24573;&#30053;wiki-&#21644;html&#20195;&#30721;&#65292;&#38544;&#34255;&#38142;&#25509;&#31561;&#65307;&#20063;&#19981;&#21253;&#25324;&#26631;&#39064;<br>" .
   "     (&#20854;&#20182;&#21015;&#37117;&#22522;&#20110;&#36825;&#20010;&#27491;&#24335;&#30340;&#35745;&#25968;&#26041;&#27861;)",
"&#20197;&#24448;&#26376;&#20221;&#27599;&#22825;&#26032;&#22686;&#30340;&#26465;&#30446;",
"&#27599;&#20010;&#26465;&#30446;&#30340;&#24179;&#22343;&#20462;&#35746;&#27425;&#25968;",
"&#27599;&#20010;&#26465;&#30446;&#30340;&#24179;&#22343;&#23383;&#33410;&#22823;&#23567;",
"&#33267;&#23569;0.5 Kb&#23383;&#25968;&#30340;&#26465;&#30446;&#30340;&#30334;&#20998;&#25968;(&#21442;&#30475; F)",
"&#33267;&#23569;2 Kb &#23383;&#25968;&#30340;&#26465;&#30446;&#30340;&#30334;&#20998;&#25968;(&#21442;&#30475; F)",
"&#20197;&#24448;&#26376;&#20221;&#30340;&#32534;&#36753;&#27425;&#25968; (&#21253;&#25324;&#37325;&#23450;&#21521;&#65292;&#21253;&#25324;&#26410;&#27880;&#20876;&#29992;&#25143;&#30340;&#36129;&#29486;)",
"&#25152;&#26377;&#26465;&#30446;&#30340;&#24635;&#35745;&#22823;&#23567; (&#21253;&#25324;&#37325;&#23450;&#21521;)",
"&#23383;&#31526;&#24635;&#25968; (&#19981;&#21253;&#25324;&#37325;&#23450;&#21521;&#65292;html/wiki&#20195;&#30721;&#21644;&#38544;&#34255;&#38142;&#25509;)",
"&#20869;&#37096;&#38142;&#25509;&#24635;&#25968; (&#19981;&#21253;&#25324;&#37325;&#23450;&#21521;&#65292;&#30701;&#26465;&#30446;&#21644;&#38142;&#25509;&#21015;&#34920;)",
"&#38142;&#25509;&#21040;&#20854;&#20182;&#32500;&#22522;&#30334;&#31185;&#30340;&#24635;&#25968;",
"&#22270;&#20687;&#24635;&#25968;",
"&#38142;&#25509;&#21040;&#20854;&#20182;&#31449;&#28857;&#30340;&#24635;&#25968;",
"&#37325;&#23450;&#21521;&#30340;&#24635;&#25968;",
"&#39029;&#38754;&#27599;&#22825;&#32034;&#21462;&#37327; (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>&#35828;&#26126;</font></a>&#65292;&#22522;&#20110;<a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>&#30340;&#36755;&#20986;)", #new
"&#27599;&#22825;&#35775;&#38382;&#37327; (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>&#35828;&#26126;</font></a>&#65292;&#22522;&#20110;<a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a>&#36755;&#20986;)",
"&#26368;&#36817;&#19968;&#20010;&#26376;&#30340;&#25968;&#25454;"
) ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedians who contributed 5 times or more in a week",
"Wikipedians who contributed 25 times or more in a week"
) ;

$out_legend_daily_edits = "&#27599;&#22825;&#32534;&#36753;&#27425;&#25968; (&#21253;&#25324;&#37325;&#23450;&#21521;&#65292;&#21253;&#25324;&#26410;&#27880;&#20876;&#29992;&#25143;&#30340;&#36129;&#29486;)" ;
$out_report_description_daily_edits = "&#27599;&#22825;&#32534;&#36753;&#27425;&#25968;" ;
$out_report_description_edits       = "&#27599;&#26376;/&#22825;&#32534;&#36753;&#27425;&#25968;",
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"&#21442;&#19982;&#32773;",
"&#26032;&#26469;&#30340;&#32500;&#22522;&#20154;",
"&#27963;&#36291;&#30340;&#32500;&#22522;&#20154;",
"&#38750;&#24120;&#27963;&#36291;&#30340;&#32500;&#22522;&#20154;",
"&#26465;&#30446;&#35745;&#25968; (&#27491;&#24335;)",
"&#26465;&#30446;&#35745;&#25968; (&#39044;&#22791;)",
"&#27599;&#22825;&#26032;&#22686;&#26465;&#30446;",
"&#27599;&#20010;&#26465;&#30446;&#30340;&#32534;&#36753;&#27425;&#25968;",
"&#27599;&#20010;&#26465;&#30446;&#30340;&#23383;&#33410;&#25968;",
"&#36229;&#36807;0.5 Kb&#30340;&#26465;&#30446;",
"&#36229;&#36807;2 Kb&#30340;&#26465;&#30446;",
"&#27599;&#26376;&#32534;&#36753;&#27425;&#25968;",
"&#25968;&#25454;&#24211;&#22823;&#23567;",
"&#23383;&#31526;",
"&#20869;&#37096;&#38142;&#25509;",
"&#38142;&#25509;&#21040;&#20854;&#20182;&#32500;&#22522;&#30334;&#31185;",
"&#22270;&#20687;",
"&#32593;&#39029;&#38142;&#25509;",
"&#37325;&#23450;&#21521;",
"&#27599;&#22825;&#39029;&#38754;&#32034;&#21462;&#37327;",
"&#27599;&#22825;&#35775;&#38382;&#37327;",
"&#24635;&#35272;"
) ;

# the full list is in WikiReports.pl
# this selection is for translators only
$out_languages {"ar"} = "&#38463;&#25289;&#20271;&#35821;" ;
$out_languages {"bs"} = "&#27874;&#26031;&#23612;&#20122;&#35821;" ;
$out_languages {"cs"} = "&#25463;&#20811;&#35821;" ;
$out_languages {"cy"} = "&#23041;&#23572;&#22763;&#35821;";
$out_languages {"da"} = "&#20025;&#40614;&#35821;" ;
$out_languages {"de"} = "&#24503;&#35821;" ;
$out_languages {"el"} = "&#24076;&#33098;&#35821;" ;
$out_languages {"en"} = "&#33521;&#35821;" ;
$out_languages {"eo"} = "&#19990;&#30028;&#35821;" ;
$out_languages {"es"} = "&#35199;&#29677;&#29273;&#35821;" ;
$out_languages {"et"} = "&#29233;&#27801;&#23612;&#20122;&#35821;" ;
$out_languages {"fa"} = "&#27874;&#26031;&#35821;" ;
$out_languages {"fi"} = "&#33452;&#20848;&#35821;" ;
$out_languages {"fr"} = "&#27861;&#35821;" ;
$out_languages {"fy"} = "&#24343;&#37324;&#35199;&#35821;" ;
$out_languages {"ga"} = "&#29233;&#23572;&#20848;&#35821;" ;
$out_languages {"hi"} = "&#21360;&#22320;&#35821;" ;
$out_languages {"he"} = "&#24076;&#20271;&#26469;&#35821;" ;
$out_languages {"hr"} = "&#20811;&#32599;&#22320;&#20122;&#35821;" ;
$out_languages {"hu"} = "&#21256;&#29273;&#21033;&#35821;" ;
$out_languages {"ia"} = "&#22269;&#38469;&#35821;" ;
$out_languages {"id"} = "&#21360;&#24230;&#23612;&#35199;&#20122;&#35821;" ;
$out_languages {"it"} = "&#24847;&#22823;&#21033;&#35821;" ;
$out_languages {"ja"} = "&#26085;&#35821;" ;
$out_languages {"ka"} = "&#26684;&#40065;&#21513;&#20122;&#35821;" ;
$out_languages {"ko"} = "&#26397;&#40092;&#35821;" ;
$out_languages {"la"} = "&#25289;&#19969;&#35821;" ;
$out_languages {"lt"} = "&#31435;&#38518;&#23451;&#35821;" ;
$out_languages {"ms"} = "&#39532;&#26469;&#35821;" ;
$out_languages {"my"} = "&#32517;&#30008;&#35821;" ;
$out_languages {"ml"} = "&#39532;&#25289;&#38597;&#25289;&#22982;&#35821;" ;
$out_languages {"nah"} = "&#32435;&#29926;&#29305;&#23572;&#35821;";
$out_languages {"nl"} = "&#33655;&#20848;&#35821;" ;
$out_languages {"no"} = "&#25386;&#23041;&#35821;" ;
$out_languages {"pl"} = "&#27874;&#20848;&#35821;" ;
$out_languages {"pt"} = "&#33889;&#33796;&#29273;&#35821;" ;
$out_languages {"ro"} = "&#32599;&#39532;&#23612;&#20122;&#35821;" ;
$out_languages {"ru"} = "&#20420;&#35821;" ;
$out_languages {"sh"} = "&#22622;&#23572;&#32500;&#20122;-&#20811;&#32599;&#22320;&#20122;&#35821;" ;
$out_languages {"sk"} = "&#26031;&#27931;&#20240;&#20811;&#35821;";
$out_languages {"sl"} = "&#26031;&#27931;&#25991;&#23612;&#20122;&#35821;";
$out_languages {"sr"} = "&#22622;&#23572;&#32500;&#20122;&#35821;" ;
$out_languages {"sv"} = "&#29790;&#20856;&#35821;" ;
$out_languages {"th"} = "&#27888;&#35821;" ;
$out_languages {"tr"} = "&#22303;&#32819;&#20854;&#35821;" ;
$out_languages {"zh"} = "&#27721;&#35821;" ;
$out_languages {"zz"} = "&#25152;&#26377;&#35821;&#35328;" ;
}

1;





