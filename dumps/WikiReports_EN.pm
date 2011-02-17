#!/usr/bin/perl

sub SetLiterals_EN
{
$out_statistics      = "Wikipedia Statistics" ;
$out_charts          = "Wikipedia Charts" ;
$out_pageviews       = "Page Views" ;

$out_btn_tables      = "Tables" ;
$out_btn_table       = "Table" ;
$out_btn_charts      = "Charts" ;

$out_wikipedia       = "Wikipedia" ;
$out_wikipedias      = "Wikipedias" ;
$out_wikipedians     = "wikipedians" ;

$out_wiktionary      = "Wiktionary" ;
$out_wiktionaries    = "Wiktionaries" ;
$out_wiktionarians   = "wiktionarians" ;

$out_wikibook        = "Wikibook" ;  # new
$out_wikibooks       = "Wikibooks" ; # new
$out_wikibookies     = "Wikibook authors" ; # new

$out_wikiquote       = "Wikiquote" ;  # new
$out_wikiquotes      = "Wikiquotes" ; # new
$out_wikiquotarians  = "Wikiquoters" ; # new

$out_wikinews        = "Wikinews" ;  # new
$out_wikinewssites   = "Wikinews sites" ; # new
$out_wikireporters   = "Wikireporters" ; # new

$out_wikisources     = "Wikisource" ;  # new
$out_wikisourcesites = "Wikisources" ; # new
$out_wikilibrarians  = "Wikilibrarians" ; # new

$out_wikispecial     = "Other Projects" ;  # new
$out_wikispecials    = "Other Projects" ; # new
$out_wikispecialists = "Authors" ; # new

$out_wikimedia       = "Wikimedia" ;
$out_wikimedia_sites = "Wikimedia sites" ;

$out_comparisons     = "Comparisons" ;

$out_creation_history = "Creation history" ; # new
$out_accomplishments  = "Accomplishments" ; # new
$out_created          = "Created" ; # new
$average_increase     = "Projects are color coded by average monthly growth" ; # new

$out_explanation_categories = "Behind each category you find the number of articles that belong to this category" ; # new
$out_follow_links           = "Tip: in order to avoid lengthy page reloads use Shift+Mouseclick to follow links" ; # new
$out_categories_templates   = "Category tags that were inserted via a template are <b>not yet</b> recognised." ; # new
$out_categories_redirects   = "Also this overview may lists categories pages that only contain a redirect tag." ;

$out_license      = "All data and images on this page are in the public domain." ;
$out_generated    = "Generated on " ;

$out_sqlfiles     = "from recent <a href='http://download.wikimedia.org'>database dump</a> files.<br>Data processed up to " ;
$out_pageviewfiles = "from recent <a href='$out_pageviewlogs'>page view log files</a>, produced by Domas Mituzas.<br>Data processed up to " ;
$out_delay        = "Please note that the lengthy dump process (many weeks) means a delay in publishing these statistics is always to be expected." ;
$out_version      = "Script version:" ;
$out_author       = "Author" ;
$out_mail         = "Mail" ;
$out_site         = "Web site" ;
$out_home         = "Home" ;
$out_sitemap      = "Site map";
$out_rendered     = "Charts rendered with " ;
$out_generated2   = "Also generated:" ;       # new
$out_easytimeline = "EasyTimeline charts" ; ; # new # Index to
$out_categories   = "Category overview" ; # new # per Wikipedia
$out_botactivity  = "Bot activity" ;     # new
$out_stats_for    = "Statistics for " ; # new
$out_stats_per    = "Statistics per " ; # new
$out_documentation = "Documentation: see <a href='http://meta.wikipedia.org/wiki/Wikistats'>Meta</a>" ; #new
$out_scripts      = "Scripts" ;

$out_gigabytes    = "GB" ;
$out_megabytes    = "MB" ;
$out_kilobytes    = "kB" ;
$out_bytes        = "B" ;
$out_million      = "M" ;
$out_thousand     = "k" ;

$out_date         = "Date" ;
$out_year         = "year" ;
$out_month        = "month" ;
$out_week         = "week" ;
$out_mean         = "Mean" ;
$out_growth       = "Growth" ;
$out_total        = "Total" ;
$out_bars         = "Bars" ;
$out_zoom         = "Zoom" ;

$out_new          = "new" ; # new
$out_all          = "all" ; # new  (people)
$out_all2         = "all" ; # new  (things)

$out_conversions1 = "" ;
$out_conversions2 = " (semi-)automatic conversions have been applied." ;

$out_phaseIII     = "Only Wikipedias that run on <a href='http://www.mediawiki.org'>MediaWiki</a> software are included." ;

$out_svg_viewer   = "To view the contents of this page you will need a " .
                    "SVG viewer, e.g. <a href='http://www.adobe.com/svg/viewer/install/'>Adobe SVG Viewer</a> " .
                    "for MS Explorer Win/Mac (free). Firefox has native SVG support." ;

$out_rendering    = "Rendering.... Please wait" ;

$out_sort_order   = "Wikipedias are ordered by number of internal links (excl. redirects)<br>" .
                    "This seems a fairer base for comparing the total effort than either number of articles or database size:<br>" .
                    "Number of articles is not so meaningful given the fact that some Wikipedias contain mainly short articles,<br>" .
                    "or even many automatically generated articles, while other Wikipedias contain less but much longer articles, all handwritten.<br>" .
                    "Database size depends on coding system (unicode characters take several bytes) and <br>" .
                    "on how much meaning can be conveyed by one character (e.g. Chinese characters are whole words).<br>" .
                    "Oct 2007: possibly the sort order should be changed to number of manual edits (excl. bots) as best comparison of efforts.<br>" .
                    "Feedback and suggestions are welcome" ;

$out_comparison   = "Wikipedias which contain {xxx} or more articles {yyy} are included here" ;
$out_not_included = "Not included" ; #new

$out_average_1    = "average counts over shown months" ;
$out_growth_1     = "average monthly growth over shown months" ;
$out_formula      = "formula" ;
$out_value        = "value" ;
$out_monthes      = "months" ;
$out_skip_values  = "(Wikipedias with values < 10 are skipped)" ;

$out_history      = "Note: figures for first months are too low. " .
                    "Revision history was not always preserved in early days." ;

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

$out_tbl1_intro   = "[[2]] recently active wikipedians, excl. bots, " .
                    "ordered by number of contributions" ;
$out_tbl1_intro2  = "Only article edits are counted, not edits on discussion pages, etc<br>As an exception in this table editors with less than 10 edits overall are included" ;
$out_tbl1_intro3  = "&Delta; = change in rank in 30 days" ; # new

$out_tbl1_hdr1    = "User" ;
$out_tbl1_hdr2    = "Edits" ;
$out_tbl1_hdr3    = "First edit" ;
$out_tbl1_hdr4    = "Last edit" ;
$out_tbl1_hdr5    = "date" ;
$out_tbl1_hdr6    = "days<br>ago" ;
$out_tbl1_hdr7    = "total" ; # new
$out_tbl1_hdr8    = "last<br>30 days" ; # new
$out_tbl1_hdr9    = "rank" ; # new
$out_tbl1_hdr10   = "now" ; # new
$out_tbl1_hdr11   = "&Delta;" ; # $out_new
$out_tbl1_hdr12   = "Articles" ; # new
$out_tbl1_hdr13   = "Other" ; # new

$out_tbl2_intro  = "[[3]] recently absent wikipedians, " .
                   "ordered by number of contributions" ;

$out_tbl3_intro   = "Growth in number of registered active wikipedians and their activity" ;

$out_tbl3_hdr1a   = "Wikipedians" ;
$out_tbl3_hdr1e   = "Articles" ;
$out_tbl3_hdr1l   = "Database" ;
$out_tbl3_hdr1o   = "Links" ;
$out_tbl3_hdr1t   = "Daily Usage" ;

# use &nbsp; (non breaking space) in stead of normal spaces in following headers
# this ensures text will never be broken into two lines
$out_tbl3_hdr1a2  = "(registered users, incl. bots)" ;
$out_tbl3_hdr1e2  = "(excl. redirects)" ;

$out_tbl3_hdr2a   = "total" ;
$out_tbl3_hdr2b   = "new" ;
$out_tbl3_hdr2c   = "edits" ;
$out_tbl3_hdr2e   = "count" ;
$out_tbl3_hdr2f   = "new<br>per&nbsp;day" ;
$out_tbl3_hdr2h   = "mean" ;
$out_tbl3_hdr2j   = "larger&nbsp;than" ;
$out_tbl3_hdr2l   = "edits" ;
$out_tbl3_hdr2m   = "size" ;
$out_tbl3_hdr2n   = "words" ;
$out_tbl3_hdr2o   = "internal" ;
$out_tbl3_hdr2p   = "interwiki" ;
$out_tbl3_hdr2q   = "image" ;
$out_tbl3_hdr2r   = "external" ;
$out_tbl3_hdr2s   = "redirects" ;
$out_tbl3_hdr2t   = "page<br>requests" ;
$out_tbl3_hdr2u   = "visits" ;
$out_tbl3_hdr2s2  = "projects" ; # new

$out_tbl3_hdr3c   = ">&nbsp;5" ;
$out_tbl3_hdr3d   = ">&nbsp;100" ;
$out_tbl3_hdr3e   = "official" ;
$out_tbl3_hdr3f   = ">&nbsp;200&nbsp;ch" ;
$out_tbl3_hdr3h   = "edits" ;
$out_tbl3_hdr3i   = "bytes" ;
$out_tbl3_hdr3j   = "0.5&nbsp;Kb" ;
$out_tbl3_hdr3k   = "2&nbsp;Kb" ;

$out_tbl6_intro  = "[[4]] anonymous users, " .
                   "ordered by number of contributions" ;
$out_table6_footer = "All together %d article edits were made by anonymous users, out of a total of %d article edits (%.0f\%)" ;

$out_tbl5_intro   = "Visitor statistics (based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output ; " .
                    "<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definitions</font></a>, " .
                    "<a href=''><font color='#000088'>chart</font></a>)" ;
$out_tbl5_hdr1a   = "Daily Average" ;
$out_tbl5_hdr1e   = "Monthly Totals" ;
$out_tbl5_hdr2a   = "Hits" ;
$out_tbl5_hdr2b   = "Files" ;
$out_tbl5_hdr2c   = "Pages" ;
$out_tbl5_hdr2d   = "Visits" ;
$out_tbl5_hdr2e   = "Sites" ;
$out_tbl5_hdr2f   = "KBytes" ;
$out_tbl5_hdr2g   = "Visits" ;
$out_tbl5_hdr2h   = "Pages" ;
$out_tbl5_hdr2i   = "Files" ;
$out_tbl5_hdr2j   = "Hits" ;

$out_tbl7_intro   = "Database records per namespace / Categorised articles<p>" .
                    "<small>1) Categories that are inserted via a template are not detected.</small>" ; # new
$out_tbl7_hdr_ns  = "Namespace" ; # new
$out_tbl7_hdr_ca  = "Categorised<br>articles <sup>1</sup>" ; # new

$out_tbl8_intro   = "Distribution of article edits over registered editors, incl. bots"  ; # new

$out_tbl9_intro   = "[[5]] most edited articles (> 25 edits)"  ; # new

$out_tbl10_intro  = "[[3]] bots, ordered by number of contributions" ; # new

@out_namespaces   = ("Article", "User", "Project", "Binaries", "MediaWiki", "Template", "Help", "Category", "Unused", "100","102","104","106","108","110") ;

@out_tbl3_legend  = (
"Wikipedians who edited at least 10 times since they arrived",
"Increase in wikipedians who edited at least 10 times since they arrived",
"Wikipedians who contributed 5 times or more in this month",
"Wikipedians who contributed 100 times or more in this month",
"Articles that contain at least one internal link",
"Articles that contain at least one internal link and 200 characters readable text, <br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;disregarding wiki- and html codes, hidden links, etc.; also headers do not count<br>" .
   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(other columns are based on the official count method)",
"New articles per day in this month",
"Mean number of revisions per article",
"Mean size of article in bytes",
"Percentage of articles with at least 0.5 Kb readable text (see F)",
"Percentage of articles with at least 2 Kb readable text (see F)",
"Edits in past month (incl. redirects, incl. unregistered contributors, incl. bots)", # bots added
"Combined size of all articles (incl. redirects)",
"Total number of words (excl. redirects, html/wiki codes and hidden links)",
"Total number of internal links (excl. redirects, stubs and link lists)",
"Total number of links to other Wikipedias",
"Total number of images presented",
"Total number of links to other sites",
"Total number of redirects",
"Page requests per day (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Visits per day (<a href='http://www.mrunix.net/webalizer/webalizer_help.html'><font color='#000088'>definition</font></a>, based on <a href='http://www.mrunix.net/webalizer/'><font color='#000088'>Webalizer</font></a> output)",
"Data for last months"
) ;

$out_webalizer_note = "Note: Webalizer data are not consistently available. Low figures for Dec 2003 are result of major server outage." ;

# some plots have slightly other criteria than corresponding tables
@out_plot_legend  = (
"Wikipedians who contributed 5 times or more in a week",
"Wikipedians who contributed 25 times or more in a week"
) ;

$out_legend_daily_edits = "Edits per day (incl. redirects, incl. unregistered contributors)" ;
$out_report_description_daily_edits    = "Edits per day" ;
$out_report_description_edits          = "Edits per month/day" ;
$out_report_description_current_status = "Current status" ; # new

@out_report_descriptions = (
"Contributors",
"New wikipedians",
"Active wikipedians",
"Very active wikipedians",
"Article count (official)",
"Article count (alternate)",
"New articles per day",
"Edits per article",
"Bytes per article",
"Articles over 0.5 Kb",
"Articles over 2 Kb",
"Edits per month",
"Database size",
"Words",
"Internal links",
"Links to other Wikipedias",
"Binaries",
"External links",
"Redirects",
"Page requests per day",
"Visits per day",
"Overview recent months"
) ;

}
1;
