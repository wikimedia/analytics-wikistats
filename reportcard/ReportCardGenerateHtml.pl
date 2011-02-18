#!/usr/local/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Getopt::Std ;

  # !! adapt these for every run !!
  $p_year  = 2010 ;
  $p_month = 12  ;

  $debug = $false ;

  $public  = 0 ;
  $private = 1 ;

  $p_month_d2 = sprintf ("%02d", $p_month) ;

  @months = qw (January February March April May June July August September October November December) ;
  $p_month_prev = ($p_month > 1)  ? $p_month - 1 : 12 ;
  $p_month_next = ($p_month < 12) ? $p_month + 1 : 1 ;
  $p_month_next2 = ($p_month < 11) ? $p_month + 2 : $p_month - 10 ;
  $p_year_plus_m2 = ($p_month < 11) ? $p_year : $p_year + 1 ;
  $p_month_prev_d2 = sprintf ("%02d", $p_month_prev) ;
  $p_month_next_d2 = sprintf ("%02d", $p_month_next) ;

  $p_year_prev          = $p_year - 1 ;
  $p_year_next          = $p_year + 1 ;
  $p_year_short         = $p_year - 2000 ;
  $p_year_prev_short    = $p_year_prev - 2000 ;
  $p_year_short_d2      = sprintf ("%02d", $p_year_short) ;
  $p_year_prev_short_d2 = sprintf ("%02d", $p_year_prev_short) ;

  $p_month_name         = $months [$p_month     -1] ;
  $p_month_name_prev    = $months [$p_month_prev-1] ;
  $p_month_name_next    = $months [$p_month_next-1] ;
  $p_month_name_next2   = $months [$p_month_next2-1] ;


  $trend_one_year  = "{{m}}/{{y-1}}|{{m}}/{{y}}" ;

  if ($p_month == 1)
  { $trend_one_month = "12/{{y-1}}|1/{{y}}" ; }
  else
  { $trend_one_month = "{{m-1}}/{{y}}|{{m}}/{{y}}" ; }

  $p_year_month_m1 = ($p_month == 1) ? "$p_month_prev/$p_year_prev_short_d2" : "$p_month_prev/$p_year_short_d2" ; # m1 = minus 1

  print "\$p_year $p_year\n" ;
  print "\$p_year_prev $p_year_prev\n" ;
  print "\$p_year_plus_m2 $p_year_plus_m2\n" ;
  print "\$p_year_short $p_year_short\n" ;
  print "\$p_year_prev_short $p_year_prev_short\n" ;
  print "\$p_year_short_d2 $p_year_short_d2\n" ;
  print "\$p_year_prev_short_d2 $p_year_prev_short_d2\n" ;
  print "\n" ;
  print "\$p_month $p_month\n" ;
  print "\$p_month_d2 $p_month_d2\n" ;
  print "\$p_month_next $p_month_next\n" ;
  print "\$p_month_prev $p_month_prev\n" ;
  print "\$p_month_next_d2 $p_month_next_d2\n" ;
  print "\$p_month_prev_d2 $p_month_prev_d2\n" ;
  print "\$p_month_name $p_month_name\n" ;
  print "\$p_month_name_prev $p_month_name_prev\n" ;
  print "\$p_month_name_next $p_month_name_next\n" ;
  print "\$p_month_name_next2 $p_month_name_next2\n" ;
  print "\$p_year_month_m1 $p_year_month_m1\n" ;


  # example output for synopsys.txt
  #STATISTICS

  #http://infodisiac.com/Wikimedia/ReportCard/EN/RC_2009_08_summary.html

  #Y: Jun, 2008->2009    k=thousand  m=million  b=billion
  #M: 2009, May->Jun

  #Unique Visitors   301 m (Y:+21% / M: -5%)
  #Page Requests      11 b (Y: +6% / M: -6%)
  #Site Rank         5th   (Y: +0  / M: -1 )
  #Commons Files     4.7 m (Y:+62% / M: +4%) ++ growth pdf/djvu files
  #Article Count    20.6 m (Y:+33% / M: +2%)
  #New Articles       17 k (Y: -9% / M: -6%)
  #New Editors        18 k (Y:+39% / M:+25%) wp:it in one year -50%
  #Active Editors     88 k (Y:+ 1% / M: -2%) wp:ru in one year +45%

  print "\n"."="x80 . "\n\n" ;

# !! This is rather crummy Q&D way to collect variable data, data need to be externalized !!

## if ($2010_12)
## {
  @visitors            = qw (   395,472,000    m  14.0    -3.7  %) ;  # Unique Visitors by Region
  @page_requests       = qw (13,976,000,000    b  22.6     2.4  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
  @commons_files       = qw (     8,046,377    m   43.1    3.0  %) ;  # Binaries per month - Absolute
  @article_count       = qw (    17,616,951    m   20.0    1.5  %) ;  # Starting Sep-2010 Wikipedia articles only / Article count (official) - Absolute
  @new_articles        = qw (         8,555    k   16.5    5.1  %) ;  # New articles per day - Absolute
  @edits               = qw (    11,566,371    m    3.6    3.8  %) ;  # Edits per month - Absolute
  @new_editors         = qw (        14,607    k  -16.6   -2.5  %) ;  # New editors - Absolute
  @active_editors      = qw (        79,324    k   -5.9   -0.5  %) ;  # Active editors - Absolute
  @very_active_editors = qw (        10,254    k   -1.6    0.1  %) ;  # Very active editors - Absolute
  @reach               = qw (            31.1  x    1.5   -1.4  %) ;  # Reach Percentage by Region
                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
 push @visitors, "1|Unique Visitors<br>1: Average for last 12 months 377M." ;
#                "2: Growth in UV count in last 12 months 18.8% (for whole internet 8.9%)." ;
#               "&nbsp;&nbsp;&nbsp;&nbsp;(avg 28.3%, low 25.7% in July 09). Reach in Asia lags behind other regions (15.9%)" ;
  push @page_requests, "2,3|Page Requests<br>" .
                  "2: <a href='http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm'>Mobile traffic</a> in Dec: 4.1% of total Wikipedia traffic (556M/13489M)<br>" .
#                   "&nbsp;&nbsp;&nbsp;&nbsp;Look ahead for page requests: Dec -> Jan = 13367M -> 14724M = +10.1%<br>" .
                  "#3: Page requests have been normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" ;
  push @rank,     "4|Site Rank<br>#4: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
 push @commons_files, "5|Commons Files<br>#5: Tiff uploads increased 5-fold in July 2010, 13-fold in last 12 months.<br>" ;
#                      "#7: Commons consistently fastest growing project, 48% in last 12 months." ;

#push @article_count, "8|Article Count<br>#8: From Sep 2010 this metric is for Wikipedia projects only. This prevents adding apples and oranges." ;
#                      "9: Seven Wiktionaries in top 25 Wikimedia projects" ;
# push @new_articles, "7|New Articles Per Day<br>" .
#                     "7: Strong growth in August by peaks on 3 wikis: Catalan/Dutch 3-fold inc., Slovene 17-fold (bots?)." ;
 push @edits, "6|Edits<br>#6: Over the last 3 years there is fairly consistent growth in manual, registered edits.<br>" .
                   "#&nbsp;&nbsp;&nbsp;&nbsp;Net growth in constructive edits is less clear, as this metric includes most reverting edits." ;
#               "&nbsp;&nbsp;&nbsp;&nbsp;Strong one-monthly dip in July due to World Cup Socker?." ;
#              "#13: Average monthly manual edits by registered users for all Wikipedia's combined, in millions<br>" .
#              "&nbsp;&nbsp;&nbsp;&nbsp;#2006 &rArr; 2010: &nbsp;&nbsp;7.7 &rArr; 9.9 &rArr; 11.5 &rArr; 12.4 &rArr; 12.7" ;
 push @new_editors, "7|New Editors Per Day<br>" .
#                     "10: Signifant decline in last month (All projects: -10.5%, <a href='http://stats.wikimedia.org/EN/ChartsWikipediaZZ.htm'>Wikipedias -11.2%</a>).<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;Arguably slowing influx of editors can partly be attributed to (multi-factorial) <a href='http://en.wikipedia.org/wiki/Market_saturation'>saturation process(es)</a><br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;But 19% drop for Wikipedias in half year (comparing 3-monthly averages) is not consistent with that.<br>" .
                    "#7:WMF recently commissioned in depth study of editor activity trends, which is ongoing." ;
 push @active_editors, "8|(Very) Active Editors<br>" .
#                   "11: Recent drops are well within normal bandwidth, largest drop was in <a href='charts/2010-08/Monthly-Active-Users-Since-Jan-2006.png'>June 2006</a>.<br>" .
                   "#8: Since a few months editors on Commons are no longer included in overall editor total,<br>" .
                   "#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; on the assumption that most of these also edit on one or more other projects.<br>" ;
#                   "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #Detection of double counts between any projects and languages is planned for late 2010." ;
 push @very_active_editors, "8|" ; #Very Active Editors<br>14: Ukrain +84% (61->112), Indonesian +180% (22->62) (during contest), Swedish -13% (141->122)." ;
## }


# if ($2010_11)
# {
#  @visitors            = qw (   410,816,000    m   18.8    0.6  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (13,976,000,000    b  22.6     2.4  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (             ?    m    ?      ?    %) ;  # Binaries per month - Absolute
#  @article_count       = qw (             ?    m    ?      ?    %) ;  # Starting Sep-2010 Wikipedia articles only / Article count (official) - Absolute
#  @new_articles        = qw (             ?    k    ?      ?    %) ;  # New articles per day - Absolute
#  @edits               = qw (             ?    m    ?      ?    %) ;  # Edits per month - Absolute
#  @new_editors         = qw (             ?    k    ?      ?    %) ;  # New editors - Absolute
#  @active_editors      = qw (             ?    k    ?      ?    %) ;  # Active editors - Absolute
#  @very_active_editors = qw (             ?    k    ?      ?    %) ;  # Very active editors - Absolute
#  @reach               = qw (            31.1  x    2.6    0.0  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>1: 410M UV's exceeds Oct 2010 record with 2M. Average for last 12 months 377M.<br>" .
#                 "2: Growth in UV count in last 12 months 18.8% (for whole internet 8.9%)." ;
#  push @page_requests, "3,4|Page Requests<br>" .
#                  "3: <a href='http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm'>Mobile traffic</a> in Sep: 3.4% of total traffic (492M/14468M)<br>" .
#                  "#4: Page requests have been normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" ;
#  push @rank,     "3|Site Rank<br>#3: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
# }

# if ($2010_10)
# {
#  @visitors            = qw (   408,350,000    m   18.5    2.6  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (             ?    b    ?      ?    %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (             ?    m    ?      ?    %) ;  # Binaries per month - Absolute
#  @article_count       = qw (             ?    m    ?      ?    %) ;  # Starting Sep-2010 Wikipedia articles only / Article count (official) - Absolute
#  @new_articles        = qw (             ?    k    ?      ?    %) ;  # New articles per day - Absolute
#  @edits               = qw (             ?    m    ?      ?    %) ;  # Edits per month - Absolute
#  @new_editors         = qw (             ?    k    ?      ?    %) ;  # New editors - Absolute
#  @active_editors      = qw (             ?    k    ?      ?    %) ;  # Active editors - Absolute
#  @very_active_editors = qw (             ?    k    ?      ?    %) ;  # Very active editors - Absolute
#  @reach               = qw (            31.1  x    2.3    0.5  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>1: 408M UV's beats September 2010 record with 10M.<br>" .
#                 "2: Growth in UV count in last 12 months 18.5% (for whole internet 9.6%)." ;
#  push @rank,     "3|Site Rank<br>#3: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
# }


# if ($2010_09)
# {
#  @visitors            = qw (   398,178,000    m   22.1    6.6  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (13,671,000,000    b   20.2    5.4  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     7,491,824    m   48.2    2.8  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    16,678,710    m   20.7    1.8  %) ;  # Starting Sep-2010 Wikipedia articles only / Article count (official) - Absolute
#  @new_articles        = qw (         7,578    k    3.9  -18.9  %) ;  # New articles per day - Absolute
#  @edits               = qw (    11,924,018    m    9.0   -3.3  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        15,805    k  -17.4  -10.5  %) ;  # New editors - Absolute
#  @active_editors      = qw (        82,503    k   -5.6   -3.3  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        11,011    k   -2.5   -3.4  %) ;  # Very active editors - Absolute
#  @reach               = qw (            30.8  x    3.2    1.8  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>1: 398M UV's beats May 2010 record with 9M or 2.4%.<br>" .
#                 "2: Growth in UV count in last 12 months 22% (for whole internet 10%)." ;
#  push @page_requests, "3,4|Page Requests<br>" .
#                  "3: <a href='http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm'>Mobile traffic</a> in Sep: 3.0% of total traffic (425M/14096M)<br>" .
#                  # "&nbsp;&nbsp;&nbsp;&nbsp;Look ahead for page requests: Aug -> Sep = 13367M -> 14724M = +10.1%<br>" .
#                  "#4: Page requests have been normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" ;
#  push @rank,     "5|Site Rank<br>#5: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "6,7|Commons Files<br>#6: Tiff uploads increased 5-fold in July 2010, 18-fold in last 12 months.<br>" .
#                       "7: Commons consistently fastest growing project, 48% in last 12 months." ;

#  push @article_count, "8|Article Count<br>8: From Sep 2010 this metric is for Wikipedia projects only. This prevents adding apples and oranges." ;
#  push @edits, "9|Edits<br>9: Over the last 3 years there is fairly consistent growth in manual, registered edits.<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;Net growth in constructive edits is less clear, as this metric includes most reverting edits." ;
#                "&nbsp;&nbsp;&nbsp;&nbsp;Strong one-monthly dip in July due to World Cup Socker?." ;
#  push @new_editors, "10|New Editors Per Day<br>" .
#                     "10: Signifant decline in last month (All projects: -10.5%, <a href='http://stats.wikimedia.org/EN/ChartsWikipediaZZ.htm'>Wikipedias -11.2%</a>).<br>" .
#                     "&nbsp;&nbsp;&nbsp;&nbsp;Arguably slowing influx of editors can partly be attributed to (multi-factorial) <a href='http://en.wikipedia.org/wiki/Market_saturation'>saturation process(es)</a><br>" .
#                     "&nbsp;&nbsp;&nbsp;&nbsp;But 19% drop for Wikipedias in half year (comparing 3-monthly averages) is not consistent with that.<br>" .
#                     "&nbsp;&nbsp;&nbsp;&nbsp;WMF recently commissioned in depth study of editor activity trends, which is ongoing." ;
#  push @active_editors, "11,12|(Very) Active Editors<br>" .
#                    "11: Recent drops are well within normal bandwidth, largest drop was in <a href='charts/2010-08/Monthly-Active-Users-Since-Jan-2006.png'>June 2006</a>.<br>" .
#                    "#12: Editors on Commons are no longer included in overall editor total,<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #on the assumption that most of these also edit on one or more other projects.<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #Detection of double counts between any projects and languages is planned for late 2010." ;
#  push @very_active_editors, "11,12|" ; #Very Active Editors<br>14: Ukrain +84% (61->112), Indonesian +180% (22->62) (during contest), Swedish -13% (141->122)." ;
# }

# if ($2010_08)
# {
#  @visitors            = qw (   373,392,000    m   21.4    3.7  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (13,367,000,000    b   23.9   -1    %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     7,298,379    m   48.1    2.8  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    34,963,360    m   30.0    2.4  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         9,437    k   22.4   25.7  %) ;  # New articles per day - Absolute
#  @edits               = qw (    12,346,207    m    7.9   15.4  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        17,026    k  -17.3   -1.1  %) ;  # New editors - Absolute
#  @active_editors      = qw (        85,643    k   -5.2    2.1  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        11,419    k   -1.6    5.0  %) ;  # Very active editors - Absolute
#  @reach               = qw (            29.0  x    2.6    0.5  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @page_requests, "1,2,3,4|Page Requests<br>" .
#                  "1: <a href='http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm'>Mobile traffic</a> in Sep: 2.9% of total traffic (425M/14724M)<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;Look ahead for page requests: Aug -> Sep = 13367M -> 14724M = +10.1%<br>" .
#                  "#&nbsp;&nbsp;&nbsp;&nbsp;Trend data for mobile will be added when more history is available.<br>" .
#                  "#2: Due to server problems counts from squid logs for December 2009 - March 2010 are too low,<br>" .
#                  "#&nbsp;&nbsp;&nbsp;&nbsp;estimated underreporting 10%-25%. Counts for April - July 2010 have been patched. Read <a href='http://infodisiac.com/blog/2010/07/wikimedia-page-views-some-good-and-bad-news/'>more</a>.<br>" .
#                  "#3: Many projects show peak traffic late 2009: see <a href='charts/2010-08/Page-Views-Per-Project-Indexed.png'>chart</a><br>" .
#                  "#4: Page requests are now normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" ;
#  push @rank,     "5|Site Rank<br>#5: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "6|Commons Files<br>#6: Tiff uploads increased <a href='charts/2010-07/Monthly-Binaries-Absolute-Log.png'>5-fold</a> in July 2010, <a href='charts/2010-07/Monthly-Binaries-Indexed.png'>22-fold</a> in a year." ;

#  push @new_articles, "7|New Articles Per Day<br>" .
#                      "7: Strong growth in August by peaks on 3 wikis: Catalan/Dutch 3-fold inc., Slovene 17-fold (bots?)." ;
#  push @edits, "8|Edits<br>8: All time high for edit count, even slightly above May level.<br>" .
#                "&nbsp;&nbsp;&nbsp;&nbsp;Strong one-monthly dip in July due to World Cup Socker?." ;
#  push @active_editors, "9,10|(Very) Active Editors<br>" .
#                    "9: After a <a href='charts/2010-08/Monthly-Active-Editors-Absolute-Linear.png'>6% drop in active Wikipedia editors</a> in June, and a further 2% drop in July,<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;trend is upwards again, with 2.5% increase in August.<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;Prospects for September are good, with +10% growth in page requests<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;(given strong correlation of 0.67 between page requests and active editors).<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;From a wider perspective drops were stil within normal bandwidth, largest drop was in <a href='charts/2010-08/Monthly-Active-Users-Since-Jan-2006.png'>June 2006</a>,<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;see also <a href='charts/2010-08/Monthly-Active-Users-Since-Jan-2008.png'>similar chart with trend line since June 2008</a>.<br>" .
#                    "10: New: Editors on Commons are no longer included in overall editor total,<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; on the assumption that most of these also edit on one or more other projects.<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detection of double counts between any projects and languages is planned for late 2010." ;
#  push @very_active_editors, "9,10|" ; #Very Active Editors<br>14: Ukrain +84% (61->112), Indonesian +180% (22->62) (during contest), Swedish -13% (141->122)." ;
# }

# if ($2010_07)
# {
#  @visitors            = qw (   360,225,000    m   21.9   -5    %) ;  # Unique Visitors by Region
#  @page_requests       = qw (13,116,000,000    b   27.2   -6    %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     7,104,689    m   49.1    2.9  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    34,198,285    m   29.9    2    %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         7,642    k    4.2   -0.6  %) ;  # New articles per day - Absolute
#  @edits               = qw (    10,734,940    m   -5.5   -9.8  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        16,661    k  -20.8   -5.6  %) ;  # New editors - Absolute
#  @active_editors      = qw (        90,554    k   -5.9   -1.6  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        11,818    k   -2.1   -1.8  %) ;  # Very active editors - Absolute
#  @reach               = qw (            28.5  x    2.8   -1.7  %) ;  # Reach Percentage by Region
                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
# push @visitors, "1,2|Unique Visitors<br>1: 375M UV's beats last month's record with 4M or 1.1 % (matches overall internet growth).<br>" .
#                 "2: Wikimedia projects reach 30.4 % of internet population, which is best reach for last year<br>" .
#                 "&nbsp;&nbsp;&nbsp;&nbsp;(avg 28.3%, low 25.7% in July 09). Reach in Asia lags behind other regions (15.9%)" ;
#  push @page_requests, "1,2,3,4|Page Requests<br>" .
#                  "1: Due to <a href='http://infodisiac.com/blog/2010/07/wikimedia-page-views-some-good-and-bad-news/'>server problems</a> counts from squid logs for December 2009 - March 2010 are too low,<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;estimated underreporting 10%-25%. Counts for April - July 2010 have been patched." .
#                  ".<br>" .
#                  "2: August : <a href='http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm'>Mobile traffic (401M)</a>: 3.0% of total traffic (13367M)<br>" .
#                  "#&nbsp;&nbsp;&nbsp;&nbsp;Trend data for mobile will be added when more history is available.<br>" .
#                  "#3: Many projects show peak traffic late 2009: see <a href='charts/2010-07/Page-Views-Per-Project-Indexed.png'>chart</a><br>" .
#                  "#4: Page requests are now normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" ;
#  push @rank,     "5|Site Rank<br>#5: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "6|Commons Files<br>#6: Tiff uploads increased <a href='charts/2010-07/Monthly-Binaries-Absolute-Log.png'>5-fold</a> in July 2010, <a href='charts/2010-07/Monthly-Binaries-Indexed.png'>25-fold</a> in a year." ;

# push @article_count, "8,9|Article Count<br>8: Serbian Wikinews: 5k->36k in a year, compare English Wikinews: 15k->17k<br>" .
#                      "9: Seven Wiktionaries in top 25 Wikimedia projects" ;
#  push @new_articles, "7|New Articles Per Day<br>" .
#                      "#7: Peak in April and May by massive activity on Aromanian and Waray-Waray Wp's, each by single user.<br>" .
#                      "#&nbsp;&nbsp;&nbsp;&nbsp;In May 20% of all new articles were created on these two small wikis (April 7%, June 11%)" ;
#  push @active_editors, "8,9|(Very) Active Editors<br>" .
#                    "8: The <a href='charts/2010-07/Monthly-Active-Editors-Absolute-Linear.png'>6% drop in active editors</a> for all Wikipias in June was relatively large,<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;but from a <a href='charts/2010-07/Monthly-Active-Users-Since-Jan-2006.png'>wider perspective</a> still within normal bandwidth, largest drop was in June 2006.<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;There might be a seasonal component in fluctuations.<br>" .
#                    "9: Bug fix: in earlier RC editions editors from Commons (6k active editors) were counted double.<br>" .
#                    "&nbsp;&nbsp;&nbsp;&nbsp;This has been fixed for all months in this RC." ;
#  push @very_active_editors, "9|" ; #Very Active Editors<br>14: Ukrain +84% (61->112), Indonesian +180% (22->62) (during contest), Swedish -13% (141->122)." ;
# }

# if ($2010_06)
# {
#  @visitors            = qw (   379,344,000    m   25.2   -2.5  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (13,957,000,000    b   26.0    1.0  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     6,910,267    m   50.1    2.5  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    33,430,039    m   29.7    1.5  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         7,865    k   14.5  -16.2  %) ;  # New articles per day - Absolute
#  @edits               = qw (    12,056,265    m   10.1   -1.6  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        17,573    k  -15.2  -10.6  %) ;  # New editors - Absolute
#  @active_editors      = qw (        99,124    k   -3.5   -4.4  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        13,042    k    0.7   -2.9  %) ;  # Very active editors - Absolute
#  @reach               = qw (            30.2  x    3.5   -1.1  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
# push @visitors, "1,2|Unique Visitors<br>1: 375M UV's beats last month's record with 4M or 1.1 % (matches overall internet growth).<br>" .
#                 "2: Wikimedia projects reach 30.4 % of internet population, which is best reach for last year<br>" .
#                 "&nbsp;&nbsp;&nbsp;&nbsp;(avg 28.3%, low 25.7% in July 09). Reach in Asia lags behind other regions (15.9%)" ;
#  push @page_requests, "1,2,3,4|Page Requests<br>" .
#                  "1: Traffic volume for recent months had been underreported due to monitor capacity problems.<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;Counts from April 2010 and later " .
#                  "<a href='http://infodisiac.com/blog/2010/07/wikimedia-page-views-some-good-and-bad-news/'>have been corrected</a>.<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;Data from Nov 2009 - Mar 2010 may still be too low.<br>" .
#                  "2: Traffic to mobile site is now counted. <a href='http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm'>(June 208M:13957M=1.5% of total)</a><br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;This is the first month, so no trend data yet. <a href='charts/2010-06/Page-Views-Breakdown-Mobile-Traffic.png'> " .
#                  "Breakdown per language</a>:" .
#                  "English:71.3%,<br>&nbsp;&nbsp;&nbsp;&nbsp; Japanese:8.6%, German:4.5%, French:3.9%, Russian:3.4%, Others:8.3%<br>" .
#                  "3: <a href='charts/2010-06/Page-Views-Per-Project-Indexed.png'>New chart</a> for breakdown of traffic volume per project: many projects show peak traffic late 2009.<br>" .
#                  "#4: Page requests are now normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" ;
#  push @rank,     "5|Site Rank<br>#5: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "6|Commons Files<br>#6: Fastest riser (relatively speaking): ogg vorbis video, djvu (for scanned docs) also booming." ;
#  push @new_articles, "7|New Articles Per Day<br>7: Peak in April and May by massive activity on <a href='http://stats.wikimedia.org/EN/TablesWikipediaROA_RUP.htm'>Aromanian</a> and <a href='http://stats.wikimedia.org/EN/TablesWikipediaWAR.htm'>Waray-Waray</a> Wp's, each by single user.<br>" .
#                      "&nbsp;&nbsp;&nbsp;&nbsp;In May 20% of all new articles were created on these two small wikis (April 7%, June 11%)" ;
#  push @edits, "9|Edits<br>9: For German,French and Polish Wikipedia dumps were not yet updated, reused data from previous month" ;
#              "Most Serbian Wikinews edits by (overactive?) weather bot that updates temp/wind speed every few seconds.<br>" .
#              "#13: Average monthly manual edits by registered users for all Wikipedia's combined, in millions<br>" .
#              "&nbsp;&nbsp;&nbsp;&nbsp;#2006 &rArr; 2010: &nbsp;&nbsp;7.7 &rArr; 9.9 &rArr; 11.5 &rArr; 12.4 &rArr; 12.7" ;
#  push @very_active_editors, "14|Very Active Editors<br>14: Ukrain +84% (61->112), Indonesian +180% (22->62) (during contest), Swedish -13% (141->122)." ;
# }

# if ($2010_05)
# {
#  @visitors            = qw (   388,932,000    m   22.6    3.8  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (11,250,000,000    b   -1.0   -1.0  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     6,765,082    m   51.9    3.1  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    32,410,992    m   31.9    2.3  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         8,638    k   11.2   12.9  %) ;  # New articles per day - Absolute
#  @edits               = qw (    12,119,403    m   11.6    0.0  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        18,761     k   -8.2   -8.1  %) ;  # New editors - Absolute
#  @active_editors      = qw (       102,689     k    1.7   -1.8  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        13,124    k    3.4   -1.9  %) ;  # Very active editors - Absolute
#  @reach               = qw (            31.3  x    3.0    0.9  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>1: 375M UV's beats last month's record with 4M or 1.1 % (matches overall internet growth).<br>" .
#                  "2: Wikimedia projects reach 30.4 % of internet population, which is best reach for last year<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;(avg 28.3%, low 25.7% in July 09). Reach in Asia lags behind other regions (15.9%)" ;
#  push @page_requests, "3,4|Page Requests<br>" .
#                  "#3: Page requests are now normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" .
#                  "4: Traffic to mobile site not yet included. <a href='http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm'>(June 154M:10700M=1.4% of total)</a><br>" .
#                  "5: Page request trends on several projects are falling for 4th month, which deserves some further analysis" ;
#  push @rank,     "6|Site Rank<br>#6: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "7|Commons Files<br>#8: Fastest riser (relatively speaking): ogg vorbis video, djvu (for scanned docs) also booming." ;
#  push @article_count, "8,9|Article Count<br>8: Serbian Wikinews: 5k->36k in a year, compare English Wikinews: 15k->17k<br>" .
#                       "9: Seven Wiktionaries in top 25 Wikimedia projects" ;
#  push @new_articles, "10,11|New Articles Per Day<br>10: All wikinews project combined +240% (39->133 p/d), see below Serbian Wikinews<br>" .
#                  "11:<a href='http://stats.wikimedia.org/EN/TablesWikipediaWAR.htm'>Waray-Waray Wikipedia</a> 2nd fastest grower with +610 mostly <a href='http://war.wikipedia.org/wiki/Obyce'>geo stubs</a> p/day by <a href='http://en.wikipedia.org/wiki/User:JinJian'>JinJian</a>" ;
#  push @edits, "12,13|Edits<br>12: 3 of 4 Wikinews monthly edits on Serbian Wikinews: 36k, English 5k, German/French 2k each<br>" .
#               "Most Serbian Wikinews edits by (overactive?) weather bot that updates temp/wind speed every few seconds.<br>" .
#               "#13: Average monthly manual edits by registered users for all Wikipedia's combined, in millions<br>" .
#               "&nbsp;&nbsp;&nbsp;&nbsp;#2006 &rArr; 2010: &nbsp;&nbsp;7.7 &rArr; 9.9 &rArr; 11.5 &rArr; 12.4 &rArr; 12.7" ;
#   push @very_active_editors, "14|Very Active Editors<br>14: Ukrain +84% (61->112), Indonesian +180% (22->62) (during contest), Swedish -13% (141->122)." ;
# }


# if ($2010_04)
# {
#  @visitors            = qw (   374,846,000    m   17.1    1.1  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (11,724,000,000    b   +7.4   -0.1  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     6,564,544    m   52.2    3.3  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    32,410,992    m   31.9    2.3  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         8,638    k   11.2   12.9  %) ;  # New articles per day - Absolute
#  @edits               = qw (    12,119,403    m   11.6    0.0  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        18,761    k   -8.2   -8.1  %) ;  # New editors - Absolute
#  @active_editors      = qw (       102,689    k    1.7   -1.8  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        13,124    k    3.4   -1.9  %) ;  # Very active editors - Absolute
#  @reach               = qw (            30.4  x    1.5    0.0  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>1: 375M UV's beats last month's record with 4M or 1.1 % (matches overall internet growth).<br>" .
#                  "2: Wikimedia projects reach 30.4 % of internet population, which is best reach for last year<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;(avg 28.3%, low 25.7% in July 09). Reach in Asia lags behind other regions (15.9%)" ;
#  push @page_requests, "3,4|Page Requests<br>" .
#                  "#3: Page requests are now normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" .
#                  "4: Traffic to mobile site not included. Expect this next month." ;
#  push @rank,     "5|Site Rank<br>#5: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "6|Commons Files<br>6: Fastest relative growth: tiff images (723%), ogg vorbis video (446%)." ;
#  push @article_count, "7,8|Article Count<br>7: Serbian Wikinews: 5k->36k in a year, compare English Wikinews: 15k->17k<br>" .
#                       "8: Seven Wiktionaries in top 25 Wikimedia projects" ;
#  push @new_articles, "9,10|New Articles Per Day<br>9: All wikinews project combined +240% (39->133 p/d), see below Serbian Wikinews<br>" .
#                  "10:<a href='http://stats.wikimedia.org/EN/TablesWikipediaWAR.htm'>Waray-Waray Wikipedia</a> 2nd fastest grower with +610 mostly <a href='http://war.wikipedia.org/wiki/Obyce'>geo stubs</a> p/day by <a href='http://en.wikipedia.org/wiki/User:JinJian'>JinJian</a>" ;
#  push @edits, "11,12|Edits<br>11: 3 of 4 Wikinews monthly edits on Serbian Wikinews: 36k, English 5k, German/French 2k each<br>" .
#               "All Serbian Wikinews edits by weather bot that updates temp/wind speed every few seconds.<br>" .
#               "30 June 2010: report filed for <a href='http://en.wikinews.org/wiki/Wikinews:Admin_action_alerts'>runaway bot</a><br>" .
#               "#12: Average monthly manual edits by registered users for all Wikipedia's combined, in millions<br>" .
#               "&nbsp;&nbsp;&nbsp;&nbsp;#2006 &rArr; 2010: &nbsp;&nbsp;7.7 &rArr; 9.9 &rArr; 11.5 &rArr; 12.4 &rArr; 12.7" ;
#   push @very_active_editors, "13|Very Active Editors<br>13: Ukrain +84% (61->112), Indonesian +180% (22->62) (during contest), Swedish -13% (141->122)." ;
# }

# if ($2010_03)
# {
#  @visitors            = qw (   370,744,000    m   13.3    7.4  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (11,730,000,000    b   +0.3    0.0  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     6,209,569    m   58.3    2.6  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    30,349,860    m   34.0    1.9  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         7,567    k   -5.7   -0.4  %) ;  # New articles per day - Absolute
#  @edits               = qw (    11,462,106    m    7.1   -3.2  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        18,362    k  -11.5  -10.8  %) ;  # New editors - Absolute
#  @active_editors      = qw (       101,730    k    1.5   -4.6  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        12,983    k    5.6   -5.4  %) ;  # Very active editors - Absolute
#  @reach               = qw (            30.4  x    0.5    1.7  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>1: March has 3 more (11%) more days than February<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;This will explain much of apparently large monthly growth in visitors<br>" .
#                  "2: All regions same of more unique visitors than year ago. North Am. +25%, Latin Am. + 27%" ;
#  push @page_requests, "3|Page Requests<br>" .
#                  "3: Page requests are now normalized to 30 days (Jan*30/31, Feb*30/28, Mar*30/31, etc)<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;This way monthly changes are more meaningful<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;Difference with not normalized data is mainly visible in Jan&rArr;Feb and Feb&rArr;Mar" ;
#  push @rank,     "4|Site Rank<br>#4: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "5|Commons Files<br>#5: Fastest riser (relatively speaking): ogg vorbis video, djvu (for scanned docs) also booming." ;
#  push @article_count, "6|Article Count<br>#6: 60% growth in Commons files in one year, English and French wiktionaries +36% through bots." ;
#  push @edits, "7|Edits<br>#7: Average monthly manual edits by registered users for all Wikipedia's combined, in millions<br>" .
#               "&nbsp;&nbsp;&nbsp;&nbsp;#2006 &rArr; 2010: &nbsp;&nbsp;7.7 &rArr; 9.9 &rArr; 11.5 &rArr; 12.4 &rArr; 12.7" ;
#  push @new_editors, "9|New Editors<br>#9: Most mature Wikipedia's see least growth in editors. Largest influx: Russian / Commons<p>" .
#  push @active_editors, "10|Active Editors<br>10: Russian editor base still growing steeply: +30% editors in one year." ;
# }

# if ($2010_02)
# {
#  @visitors            = qw (   345,218,000    m   14.8   -5.3  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (11,081,000,000    b   +5.8    0.0  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     6,209,569    m   58.3    2.6  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    30,349,860    m   34.0    1.9  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         7,567    k   -5.7   -0.4  %) ;  # New articles per day - Absolute
#  @edits               = qw (    11,462,106    m    7.1   -3.2  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        18,362    k  -11.5  -10.8  %) ;  # New editors - Absolute
#  @active_editors      = qw (       101,730    k    1.5   -4.6  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        12,983    k    5.6   -5.4  %) ;  # Very active editors - Absolute
#  @reach               = qw (            28.7  x    0.8   -0.8  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1|Unique Visitors<br>1: comScore reassesses online population in their target segments twice a year (Feb & Aug)<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;This time estimate for Indonesia, Philippines and Vietnam was lowered by -54%,<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;resulting in a worldwide reassesment of online population of -4%" ;
#  push @page_requests, "2,3|Page Requests<br>" .
#                  "2:Corrected for length of months Jan -> Feb increase was actually +11.0% !<br>" .
#                  "3:Russia maintains its steep growth: +57% in last 12 months, +137% in preceding 12 months<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;Indonesia is 2nd, and speeding up: +46% in last 12 months, +34% before that<br>" .
#                  "#&nbsp;&nbsp;&nbsp;&nbsp;German decline (-10%) is still atypical (caused by spike year ago after court decision)" ;
#  push @rank,     "5|Site Rank<br>#5: 5th position will be stable for long time: differences with those ranked 4th and 6th are considerable." ;
#  push @commons_files, "6|Commons Files<br>#6: Fastest riser (relatively speaking): ogg vorbis video, djvu (for scanned docs) also booming." ;
#  push @article_count, "7|Article Count<br>#7: 60% growth in Commons files in one year, English and French wiktionaries +36% through bots." ;
#  push @edits, "8|Edits<br>8: Average monthly manual edits by registered users for all Wikipedia's combined, in millions<br>" .
#               "&nbsp;&nbsp;&nbsp;&nbsp;2006 &rArr; 2010: &nbsp;&nbsp;7.7 &rArr; 9.9 &rArr; 11.5 &rArr; 12.4 &rArr; 12.7" ;
# }

# if ($2009_??)
# {
#  @visitors            = qw (   364,719,000    m   25.8    5.1  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (11,054,000,000    b   -3.1    6.4  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)  of http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm (Wikipedia only is good enough)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     6,058,601    m   59.5    6.5  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    29,742,993    m   34.7    2.4  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         7,626    k   -1.1    3.4  %) ;  # New articles per day - Absolute
#  @edits               = qw (    12,251,152    m    4.8    9.0  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        19,279    k  -12.4    5.6  %) ;  # New editors - Absolute
#  @active_editors      = qw (        98,597    k   -1.4    5.0  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        12,488    k   -1.1    6.3  %) ;  # Very active editors - Absolute
#  @reach               = qw (            29.0  x    1.0    1.0  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>#1: Yearly growth in UV's (26%) exceeds growth of total internet (21%).<br>" .
#                  "2: Large monthly shifts in UV/Reach in 3rd world explained by comScore as seasonal influences:<br>&nbsp;&nbsp;&nbsp;&nbsp;school vacations, and large festivals, religious (e.g. Ramadan) or otherwise (e.g. Carnival)." ;
#  push @page_requests, "3,4|Page Requests<br>3:<b> Trends measured by comScore and internal measurements diverge somewhat.</b><br>&nbsp;&nbsp;&nbsp;&nbsp;<b>Possible causes are under investigation.</b><p>" .
#                  "4:Fastest rising large Wikipedia's in last 12 months:<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;Vietnamese (87%), Ukranian (65%), Russian (45%), Indonesian (39%), Chinese (28%), Thai (23%)<br>" .
#                  "&nbsp;&nbsp;&nbsp;&nbsp;German decline (-32%) is atypical (caused by short massive spike year ago due after court decision)" ;
#  push @rank,     "5|Site Rank<br>#5: 5th position will be stable for long time: differences with 4th and 6th ranked properties are considerable." ;
#  push @commons_files, "6|Commons Files<br>#6: Fastest riser (relatively speaking): ogg vorbis video, djvu (for scanned docs) also booming." ;
#  push @article_count, "7|Article Count<br>#7: 60% growth in Commons files in one year. Wiktionaries exploding through bots." ;
#  push @edits, "8|Edits<br>#8: <a href='http://stats.wikimedia.org/EN/TablesWikipediaZZ.htm'>#Monthly edits for all Wikipedia's combined</a># remarkably stable between 10 and 12 million<br>#&nbsp;&nbsp;&nbsp;&nbsp;for 3 years now (as is the case for active and very active editors)" ;
#  push @new_editors, "9|New Editors<br>#9: Most mature Wikipedia's see least growth in editors. Largest influx: Russian / Commons<p>" .
#                     "Experiment: logarithmic chart now uses two scales for widely divergent values.<br>This helps to remove clutter, but may need some getting used to."  ;

#  push @active_editors, "10|Active Editors<br>10: Russian editor base still growing steeply: +30% editors in one year." ;
# }

# if ($2009_??)
# {
#  @visitors            = qw (   347,019,000    m   27.1    0.4  %) ;  # Unique Visitors by Region
#  @page_requests       = qw (10,389,000,000    b    0.0   -9.2  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)
#  @rank                = qw (           5th    x    0      0    th) ; # Web Properties - Unique Visitors
#  @commons_files       = qw (     5,695,283    m   55.1    2.6  %) ;  # Binaries per month - Absolute
#  @article_count       = qw (    29,016,248    m   34.3    2.1  %) ;  # Article count (official) - Absolute
#  @new_articles        = qw (         7,457    k    7.7    2.6  %) ;  # New articles per day - Absolute
#  @edits               = qw (    10,791,575    m    0.6    0.4  %) ;  # Edits per month - Absolute
#  @new_editors         = qw (        18,597    k   -6.3   -2.4  %) ;  # New editors - Absolute
#  @active_editors      = qw (        95,849    k    3.8   -0.4  %) ;  # Active editors - Absolute
#  @very_active_editors = qw (        11,764    k    0.4   -0.5  %) ;  # Very active editors - Absolute
#  @reach               = qw (            28.7  x    1.6   -0.0  %) ;  # Reach Percentage by Region
#                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
#  push @visitors, "1,2|Unique Visitors<br>1: Yearly growth in UV's (27%) exceeds growth of total internet (21%).<br>" .
#                  "2: Conversation with comScore on huge monthly shifts in UV/Reach in 3rd world continues." ;
#  push @page_requests, "3|Page Requests<br>3: Same as last year: dip in page requests (but spike in image requests)." ;
#  push @rank,     "4|Site Rank<br>4: 5th position will be stable for long time: 4th has 35% more UV's, 6th 23% less." ;
#  push @commons_files, "5|Commons Files<br>5: Fastest riser (relatively speaking): ogg vorbis video, djvu (for scanned docs) also booming." ;
#  push @article_count, "6|Article Count<br>6: 60% growth in Commons files in one year. Wiktionaries exploding through bots." ;
#  push @new_articles, "7|New Articles<br>7: Russian consistently fast riser, Ukranian growth 40% of previous months" ;
#  push @edits, "8|Edits<br>8: <a href='http://stats.wikimedia.org/EN/TablesWikipediaZZ.htm'>Monthly edits for all Wikipedia's combined</a> remarkably stable between 10 and 12 million<br>for 3 years now (as is the case for active and very active editors)" ;
#  push @new_editors, "9|New Editors<br>9: Most mature Wikipedia's see least growth in editors. Largest influx: Russian / Commons" ;
# }

# if ($2009_10)
# {
# @visitors            = qw (   345,805,000    m   23.1    0.4  %) ;  # Unique Visitors by Region
# @page_requests       = qw (11,257,000,000    b    7.7   -2.8  %) ;  # copy/calc manually monthly total and monthly and yearly growth from 1st column (Sigma)
# @rank                = qw (           5th    x   -1      0    th) ; # Web Properties - Unique Visitors
# @commons_files       = qw (     5,558,644    m   59.7    3.4  %) ;  # Binaries per month - Absolute
# @article_count       = qw (    28,506,011    m   35.4    2.5  %) ;  # Article count (official) - Absolute
# @new_articles        = qw (         7,357    k    2.1   -6.1  %) ;  # New articles per day - Absolute
# @edits               = qw (    10,772,957    m    2.8   -3.4  %) ;  # Edits per month - Absolute
# @new_editors         = qw (        18,779    k   -5.2   -4.5  %) ;  # New editors - Absolute
# @active_editors      = qw (        96,521    k    4.0    0.1  %) ;  # Active editors - Absolute
# @very_active_editors = qw (        11,726    k    2.7   -3.4  %) ;  # Very active editors - Absolute

# @reach               = qw (            28.7  x    0.5   -0.3  %) ;  # Reach Percentage by Region
                                                                      # http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
# push @visitors, "1|1: asked comScore to explain huge shifts in UV/Reach in Middle East-Africa." ;
# push @page_requests, "2|2: Capacity problems may have played a role. New servers ordered." ;
# push @new_articles, "2,3|3: Ukranian Wikipedia fastest riser (compare edits for Russian)" ;
# push @edits, "4|4: Russian Wikipedia fastest riser (compare new articles for Ukrain)" ;
# push @very_active_editors, "2" ;
# }

# if ($2009_10)
# {
# @new_editors         = qw (        19,002    k   -8.9    3.2  %) ;
# @active_editors      = qw (        97,132    k    1.9    3.4  %) ;
# @very_active_editors = qw (        12,172    k    2.8    1.2  %) ;
# @article_count       = qw (    27,852,471    m   35.6    2.8  %) ;
# @new_articles        = qw (         8,050    k   11.2    5.9  %) ;
# @edits               = qw (    11,188,080    m   -1.8    1.7  %) ;
# @commons_files       = qw (     5,539,645    m   60.3    5.5  %) ;
# @rank                = qw (           5th    x   -1      0    th) ;
# @visitors            = qw (   344,563,000    m   24.3    5.7  %) ;
# @reach               = qw (            29.0  x    0.8    1.3  %) ;
# @page_requests       = qw (11,586,000,000    b    8.8    1.9  %) ;
# }

# if ($2009_09)
# {
# @new_editors         = qw (        17,792    k   -8.7   -9.6  %) ;
# @active_editors      = qw (        94,565    k    2.3   -2.5  %) ;
# @very_active_editors = qw (        12,069    k    3.6   -2.5  %) ;
# @article_count       = qw (    27,120,974    m   36.6    2.0  %) ;
# @new_articles        = qw (        12,907    k   -0.3  -11.4  %) ;
# @edits               = qw (    12,578,009    m    8.8   -9.0  %) ;
# @commons_files       = qw (     5,115,042    m   57.4    2.7  %) ;
# @rank                = qw (           5th    x    0      0    th) ;
# @visitors            = qw (   325,998,000    m   19.8    6.0  %) ;
# @reach               = qw (            27.6  x   -1.4    4.5  %) ;
# @page_requests       = qw (11,372,000,000    b   11.7    5.1  %) ;
# }

# if ($2009_08)
# {
#  @new_editors         = qw (        17,998    k   -9.4   -6.2  %) ;
#  @active_editors      = qw (        91,359    k    1.1    0.8  %) ;
#  @very_active_editors = qw (        11,568    k    0.3    3.0  %) ;
#  @article_count       = qw (    21,143,943    m   29.9    2.0  %) ;
#  @new_articles        = qw (        13,174    k    8.1   11.4  %) ;
#  @edits               = qw (    12,807,952    m    8.4    4.8  %) ;
#  @commons_files       = qw (     4,996,023    m   60.2    3.6  %) ;
#  @rank                = qw (           5th    x    0      0    th) ;
#  @visitors            = qw (   307,641,000    m   23.8    4.1  %) ;
#  @reach               = qw (            26.4  x    1.9    2.7  %) ;
#  @page_requests       = qw (10,817,000,000    b   15.3    1.5  %) ;
# }

# if ($2009_07)
# {
#  @new_editors         = qw (        18,916    k   -8.5   -1    %) ;
#  @active_editors      = qw (        90,659    k   -0.3   -0.6  %) ;
#  @very_active_editors = qw (        11,242    k   -2.4   -0.7  %) ;
#  @article_count       = qw (    20,768,108    m   30.2    0.8  %) ;
#  @new_articles        = qw (        11,888    k  -18.9  -30.3  %) ;
#  @edits               = qw (    12,219,008    m    6.3    0.7  %) ;
#  @commons_files       = qw (     4,831,659    m   61.1    3.7  %) ;
#  @rank                = qw (           5th    x    0      0    th) ;
#  @visitors            = qw (   295,848,000    m   20.9   -2.5  %) ;
#  @reach               = qw (            25.7  x    0     -3.7  %) ;
#  @page_requests       = qw (10,700,000,000    b   12.9   -3.0  %) ;
# }

  $synopsis  = "Y: " . substr ($p_month_name,0,3) . ",$p_year_prev->$p_year    k=thousand  m=million  b=billion\n" ;
  $synopsis .= "M: $p_year," . substr ($p_month_name_prev,0,3) . "->" . substr ($p_month_name,0,3)  . "     M=monthly   D=daily    T=Total\n\n" ;

  $synopsis .= &FormatSynopsisText ("M Unique Visitors, All Projects", "", @visitors) ;
  $synopsis .= &FormatSynopsisText ("M Page Views, All Projects", "", @page_requests) ;
  $synopsis .= &FormatSynopsisText ("  Site Rank", "", @rank) ;
  $synopsis .= &FormatSynopsisText ("T Binary Files", "", @commons_files) ;
  $synopsis .= &FormatSynopsisText ("M Wikipedia Article Count", "", @article_count) ;
  $synopsis .= &FormatSynopsisText ("D New Wikipedia Articles", "", @new_articles) ;
  $synopsis .= &FormatSynopsisText ("M Wikipedia Edits per Month", "", @edits) ;
  $synopsis .= &FormatSynopsisText ("M New Wikipedia Editors", "", @new_editors) ;
  $synopsis .= &FormatSynopsisText ("M Active Wikipedia Editors", "", @active_editors) ;
  $synopsis .= &FormatSynopsisText ("M Very Active Wikipedia Ed.", "", @very_active_editors) ;

  print "\n\n$synopsis" ;
  print "\n"."="x80 . "\n\n" ;

  @visitors_            = @visitors ;
  @page_requests_       = @page_requests ;
  @rank_                = @rank ;
  @commons_files_       = @commons_files ;
  @article_count_       = @article_count ;
  @new_articles_        = @new_articles ;
  @edits_               = @edits ;
  @new_editors_         = @new_editors ;
  @active_editors_      = @active_editors ;
  @very_active_editors_ = @very_active_editors ;
  @reach_               = @reach ;

  $visitors            [0] =~ s/,//g ;
  $new_editors         [0] =~ s/,//g ;
  $active_editors      [0] =~ s/,//g ;
  $very_active_editors [0] =~ s/,//g ;
  $article_count       [0] =~ s/,//g ;
  $new_articles        [0] =~ s/,//g ;
  $edits               [0] =~ s/,//g ;
  $commons_files       [0] =~ s/,//g ;
  $rank                [0] =~ s/,//g ;
  $reach               [0] =~ s/,//g ;
  $page_requests       [0] =~ s/,//g ;

  $visitors            [0] = sprintf ("%.0f",$visitors [0]/1000000) ;
  $article_count       [0] = sprintf ("%.1f",$article_count [0]/1000000) ;
  $edits               [0] = sprintf ("%.1f",$edits [0]/1000000) ;
  $commons_files       [0] = sprintf ("%.1f",$commons_files [0]/1000000) ;
  $page_requests       [0] = sprintf ("%.1f",$page_requests [0]/1000000000) ;

  $new_editors         [0] =~ s/(\d\d\d)$/,$1/ ;
  $active_editors      [0] =~ s/(\d\d\d)$/,$1/ ;
  $very_active_editors [0] =~ s/(\d\d\d)$/,$1/ ;
  $new_articles        [0] =~ s/(\d\d\d)$/,$1/ ;

  $visitors            [2] = sprintf ("%.1f", $visitors [2]) ;
  $visitors            [3] = sprintf ("%.1f", $visitors [3]) ;
  $visitors            [5] =~ ($visitors [2] >= 0) ? 'A' : 'E' ;
  $visitors            [6] =~ ($visitors [3] >= 0) ? 'A' : 'E' ;

  $page_requests       [2] = sprintf ("%.1f", $page_requests [2]) ;
  $page_requests       [3] = sprintf ("%.1f", $page_requests [3]) ;
  $new_editors         [2] = sprintf ("%.1f", $new_editors [2]) ;
  $new_editors         [3] = sprintf ("%.1f", $new_editors [3]) ;
# $active_editors      [2] = sprintf ("%.1f", $active_editors [2]) ;
# $active_editors      [3] = sprintf ("%.1f", $active_editors [3]) ;
  $very_active_editors [2] = sprintf ("%.1f", $very_active_editors [2]) ;
  $very_active_editors [3] = sprintf ("%.1f", $very_active_editors [3]) ;
# $article_count       [2] = sprintf ("%.1f", $article_count [2]) ;
# $article_count       [3] = sprintf ("%.1f", $article_count [3]) ;
  $new_articles        [2] = sprintf ("%.1f", $new_articles [2]) ;
  $new_articles        [3] = sprintf ("%.1f", $new_articles [3]) ;
  $edits               [2] = sprintf ("%.1f", $edits [2]) ;
  $edits               [3] = sprintf ("%.1f", $edits [3]) ;
  $commons_files       [2] = sprintf ("%.1f", $commons_files [2]) ;
  $commons_files       [3] = sprintf ("%.1f", $commons_files [3]) ;
  $rank                [2] = sprintf ("%.0f", $rank [2]) ;
  $rank                [3] = sprintf ("%.0f", $rank [3]) ;
  $reach               [2] = sprintf ("%.1f", $reach [2]) ;
  $reach               [3] = sprintf ("%.1f", $reach [3]) ;
  $page_requests       [2] = sprintf ("%.1f", $page_requests [2]) ;
  $page_requests       [3] = sprintf ("%.1f", $page_requests [3]) ;

  for ($i = 0 ; $i <= 3 ; $i++)
  {
    $visitors            [$i] = '...' if $visitors_            [$i] eq '?' ;
    $page_requests       [$i] = '...' if $page_requests_       [$i] eq '?' ;
    $rank                [$i] = '...' if $rank_                [$i] eq '?' ;
    $commons_files       [$i] = '...' if $commons_files_       [$i] eq '?' ;
    $article_count       [$i] = '...' if $article_count_       [$i] eq '?' ;
    $new_articles        [$i] = '...' if $new_articles_        [$i] eq '?' ;
    $edits               [$i] = '...' if $edits_               [$i] eq '?' ;
    $new_editors         [$i] = '...' if $new_editors_         [$i] eq '?' ;
    $active_editors      [$i] = '...' if $active_editors_      [$i] eq '?' ;
    $very_active_editors [$i] = '...' if $very_active_editors_ [$i] eq '?' ;
    $reach               [$i] = '...' if $reach_               [$i] eq '?' ;
  }

  $path_input   = "W:/@ Report Card/Input/" ;
  $path_public  = "W:/@ Report Card/Public/" ;
  $path_private = "W:/@ Report Card/Extended/" ;  # few more charts with top 10 web properties based on data from comScore (slightly confidential)

  &WriteReports ($path_input, $path_public,  $public) ;
  &WriteReports ($path_input, $path_private, $private) ;

  print "\nReady\n\n" ;
  exit ;

sub WriteReports
{
  $path_in  = shift ;
  $path_out = shift ;
  $target_audience = shift ;

  &WriteSynopsis ($path_out) ;

  open TEMPLATE, '<', "RT_yyyy_mm.html" ;
  open DETAILS,  '>', "$path_out/RC_${p_year}_${p_month_d2}_detailed.html" ;
  open SUMMARY,  '>', "$path_out/RC_${p_year}_${p_month_d2}_summary.html" ;
  open COLUMNS,  '>', "$path_out/RC_${p_year}_${p_month_d2}_columns.html" ;


  $write_details  = $true ;
  $write_summary  = $true ;
  $write_columns  = $true ;

  $write_public   = $true ;
  $write_private  = $true ;

  $iscomment      = $false ;

  while ($line = <TEMPLATE>)
  {
    chomp $line ;

    $line =~ s/<!--.*?-->// ;
#    if ($line =~ /<!--/)
#    {
#      $iscomment = $true ;
#      $line =~ s/<!--.*$// ;
#    }
#    if ($line =~ /-->/)
#    {
#      $iscomment = $false ;
#      $line =~ s/^.*?-->// ;
#    }
#    if ($iscomment)
#    { $line = "<!-- {{$line}} -->" ; }

    if ($line =~ /\{\{yyyy\}\}_\{\{mm[+-]1\}\}/)
    {
      if ($p_month == 1)
      { $line =~ s/\{\{yyyy\}\}_\{\{mm\-1\}\}/{{yyyy-1}}_{{mm-1}}/ ; } # Q&D temp fix
      if ($p_month == 12)
      { $line =~ s/\{\{yyyy\}\}_\{\{mm\+1\}\}/{{yyyy+1}}_{{mm+1}}/ ; } # Q&D temp fix
    }

  #  $no_upd = "<font color=#800000>*<\/font>" ;

    if ($true) # test ?
    {
      # $no_upd = "&nbsp;&nbsp;<small><small><font color=#FF0000><b>chart could not be updated for current month</b></font></small></small>" ;
      $line =~ s/H2 (UNIQUE VISITORS)/A[$1] H2 {${visitors [0]} million|Unique Visitors, All Projects}/ ;
      $line =~ s/H2 (PAGE REQUESTS)/A[$1] H2 {${page_requests[0]} billion|Page Requests, All Projects}/ ;
      $line =~ s/H2 (WEB PROPERTIES)/A[$1] H2 {${rank[0]} in rank|Web Properties - Unique Visitors}/ ;
      $line =~ s/H2 (COMMONS FILES)/A[$1] H2 {${commons_files[0]} million|Binary Files $no_upd}/ ;
      $line =~ s/H2 (ARTICLE COUNT)/A[$1] H2 {${article_count[0]} million|Wikipedia Articles, Comparison with Other Projects $no_upd}/ ;
      $line =~ s/H2 (ARTICLES PER DAY)/A[$1] H2 {${new_articles[0]}|New Wikipedia Articles Per Day $no_upd}/ ;
      $line =~ s/H2 (EDITS PER MONTH)/A[$1] H2 {${edits[0]} million|Wikipedia Edits Per Month $no_upd}/ ;
      $line =~ s/H2 (NEW EDITORS PER MONTH)/A[$1] H2 {${new_editors[0]}|New Wikipedia Editors Per Month $no_upd}/ ;
      $line =~ s/H2 (ACTIVE EDITORS)/A[$1] H2 {${active_editors[0]}|Active Wikipedia Editors (5+ edits per month) $no_upd}/ ;
      $line =~ s/H2 (VERY ACTIVE EDITORS)/A[$1] H2 {${very_active_editors[0]}|Very Active Wikipedia Editors (100+ edits per month) $no_upd}/ ;

      $line =~ s/TRENDS UNIQUE VISITORS/TRENDS {$trend_one_year|${visitors[2]}%}{$trend_one_month|${visitors[3]}%}/ ;
      $line =~ s/TRENDS PAGE REQUESTS/TRENDS {$trend_one_year|${page_requests[2]}%}{$trend_one_month|${page_requests[3]}%}/ ;
      $line =~ s/TRENDS WEB PROPERTIES/TRENDS {$trend_one_year|${rank[2]}}{$trend_one_month|${rank[3]}}/ ;
      $line =~ s/TRENDS COMMONS FILES/TRENDS {$trend_one_year|${commons_files[2]}%}{$trend_one_month|${commons_files[3]}%}/ ;
      $line =~ s/TRENDS ARTICLE COUNT/TRENDS {$trend_one_year|${article_count[2]}%}{$trend_one_month|${article_count[3]}%}/ ;
      $line =~ s/TRENDS ARTICLES PER DAY/TRENDS {$trend_one_year|${new_articles[2]}%}{$trend_one_month|${new_articles[3]}%}/ ;
      $line =~ s/TRENDS EDITS PER MONTH/TRENDS {$trend_one_year|${edits[2]}%}{$trend_one_month|${edits[3]}%}/ ;
      $line =~ s/TRENDS NEW EDITORS PER MONTH/TRENDS {$trend_one_year|${new_editors[2]}%}{$trend_one_month|${new_editors[3]}%}/ ;
      $line =~ s/TRENDS ACTIVE EDITORS/TRENDS {$trend_one_year|${active_editors[2]}%}{$trend_one_month|${active_editors[3]}%}/ ;
      $line =~ s/TRENDS VERY ACTIVE EDITORS/TRENDS {$trend_one_year|${very_active_editors[2]}%}{$trend_one_month|${very_active_editors[3]}%}/ ;

      $line =~ s/{{yyyy}}/$p_year/g ;
      $line =~ s/{{yyyy\-1}}/$p_year_prev/g ;
      $line =~ s/{{yyyy\+1}}/$p_year_next/g ;
      $line =~ s/{{yyyy\+m2}}/$p_year_plus_m2/g ;
      $line =~ s/{{month}}/$p_month_name/g ;
      $line =~ s/{{month\-1}}/$p_month_name_prev/g ;
      $line =~ s/{{month\+1}}/$p_month_name_next/g ;
      $line =~ s/{{month\+2}}/$p_month_name_next2/g ;

      $line =~ s/{{y}}/$p_year_short/g ;
      $line =~ s/{{y\-1}}/$p_year_prev_short/g ;
      $line =~ s/{{yy}}/$p_year_short_d2/g ;
      $line =~ s/{{yy\-1}}/$p_year_prev_short_d2/g ;

      $line =~ s/{{m}}/$p_month/g ;
      $line =~ s/{{m\-1}}/$p_month_prev/g ;
      $line =~ s/{{mm}}/$p_month_d2/g ;
      $line =~ s/{{mm-1}}/$p_month_prev_d2/g ;
      $line =~ s/{{mm\+1}}/$p_month_next_d2/g ;

      $line =~ s/{{\(mm\/yy\)-1}}/$p_year_month_m1/g ;
    }
    else
    {
      $line =~ s/{{yyyy}}/[[yyyy]]/g ;
      $line =~ s/{{yyyy-1}}/[[yyyy-1]]/g ;
      $line =~ s/{{yyyy\+m2}}/[[yyyy\+m2]]/g ;
      $line =~ s/{{month}}/[[month]]/g ;
      $line =~ s/{{month-1}}/[[month-1]]/g ;
      $line =~ s/{{month\+1}}/[[month\+1]]/g ;
      $line =~ s/{{month\+2}}/[[month\+2]]/g ;

      $line =~ s/{{y}}/y/g ;
      $line =~ s/{{y-1}}/y-1/g ;
      $line =~ s/{{m}}/m/g ;
      $line =~ s/{{m-1}}/m-1/g ;
      $line =~ s/{{mm}}/mm/g ;
      $line =~ s/{{mm-1}}/mm-1/g ;
      $line =~ s/{{mm\+}}/mm+1/g ;

      $line =~ s/{{\(mm\/yy\)-1}}/(mm\/yy)-1/g ;
    }

    if ($line =~ /<!==\s*COMMENT\s*\{[^\}]*\}\s*==>/)
    {
      $comment = $line ;
      $comment =~ s/^.*?\{// ;
      $comment =~ s/\}.*$// ;
      $line = "  <span class=comment>$comment</span\n" ;
    }

    if ($line =~ /<!==\s*H1\s*\{[^\}]*\}\s*==>/)
    {
      $title = $line ;
      $title =~ s/^.*?\{// ;
      $title =~ s/\}.*$// ;
      $line = "  <tr>\n" .
              "    <td class=h1 colspan=99><span class=h9>$title</span></td>\n" .
              "  </tr>\n" .
              "  <tr>\n" .
              "    <td><small><small>&nbsp;</small></small></td>\n" .
              "  </tr>\n" ;
    }

    if ($line =~ /<!==\s*A\[[^\]]*\] H2\s*\{[^\}]*\}\s*==>/)
    {
      ($anchor = $line) ;
      $anchor =~ s/^.*?A\[// ;
      $anchor =~ s/\].*$// ;
      $anchor =~ s/\s/_/g ;
      $anchor = lc($anchor) ;

      $parms = $line ;
      $parms =~ s/^.*?\{// ;
      $parms =~ s/\}.*$// ;
      ($metric,$title) = split ('\|', $parms,2) ;
      ($title2 = $title) =~ s/ /_/g ;
      $line = "  <tr>\n" .
              "    <td class=score><a id='$anchor' name='$anchor'></a><span class=bg>$metric</sup></span></td>\n" .
              "    <td class=h2><span class=h2>$title</span><br></td>\n" .
              "</tr>\n" ;
    }

    if ($line =~ /<!==\s*TABS\s*\{[^\}]*\}\s*==>/)
    {
      $parms = $line ;
      $parms =~ s/^.*?\{// ;
      $parms =~ s/\}.*$// ;
      ($id,@texts) = split ('\|', $parms) ;
      $line  = "  <div id=\"container-" . ($id/10) . "\">\n" ;
      $line .= "  <ul>\n" ;
      foreach $text (@texts)
      {
        $id++ ;
        $line .= "  <li><a href=\"#fragment-$id\"><span>$text</span></a></li>\n" ;
      }
      $line .= "  </ul>\n" ;
      $id_hi = $id ;
    }

    if ($line =~ /<!==\s*TAB\s*\{[^\}]*\}\s*==>/)
    {
      $parms = $line ;
      $parms =~ s/^.*?\{// ;
      $parms =~ s/\}.*$// ;
      ($id,$text) = split ('\|', $parms) ;

      if ($text =~ /^START/i)
      {
        $line = "\n  <div id=\"fragment-$id\">\n" ;
      }
      elsif ($text =~ /^END/i)
      {
        if ($id == $id_hi)
        { $line = "  </div>" ; }
      }
      else
      {
        $line = "\n  <div id=\"fragment-$id\">\n  $text\n  </div>\n" ;
        if ($id == $id_hi)
        { $line .= "  </div>" ; }
      }
    }

    if ($line =~ /<!==\s*TRENDS\s*\{[^\}]*\}\{[^\}]*\}\s*==>/)
    {
      $parms = $line ;
      $parms =~ s/^[^\{]*\{// ;
      $parms =~ s/\}[^\}]*$// ;
      ($trendY,$trendM) = split ('\}\s*\{', $parms,2) ;

      # ($colorY,$month1Y,$month2Y,$trendY) = split ('\|',$trendY) ;
      # ($colorM,$month1M,$month2M,$trendM) = split ('\|',$trendM) ;
      ($month1Y,$month2Y,$trendY) = split ('\|',$trendY) ;
      ($month1M,$month2M,$trendM) = split ('\|',$trendM) ;
      if ($trendY >= 0)
      { $colorY = "A" ; $trendY = "+$trendY" }
      else
      { $colorY = "E" ; }
      if ($trendM >= 0)
      { $colorM = "A" ; $trendM = "+$trendM" }
      else
      { $colorM = "E" ; }


       #<!== TRENDS {A|5/8|5/9|+12%}{A|4/9|5/9|+8%} ==>
       $line = "    <td class=date>\n" .
               "      <table border=0>\n" .
               "        <tr>\n" .
               "          <td class=date$colorY><b>Y</b>&nbsp;$month1Y&rArr;$month2Y</td>\n" .
               "          <td class=date$colorY>$trendY</td>\n" .
               "        </tr>\n" .
               "        <tr>\n" .
               "          <td class=date$colorM><b>M</b>&nbsp;$month1M&rArr;$month2M</td>\n" .
               "          <td class=date$colorM>$trendM</td>\n" .
               "        </tr>\n" .
               "      </table>\n" .
               "    </td>\n" ;
    }

    if ($line =~ /<!==\s*OUT\s*PUBLIC\s*==>/)
    {
      $write_public  = $true ;
      $write_private = $false ;
    }
    elsif ($line =~ /<!==\s*OUT\s*EXTENDED\s*==>/)
    {
      $write_public  = $false ;
      $write_private = $true ;
    }
    elsif ($line =~ /<!==\s*OUT\s*ALWAYS\s*==>/)
    {
      $write_public  = $true ;
      $write_private = $true ;
    }
    elsif ($line =~ /<!==\s*OUT .*\s*==>/)
    {
      $line2 = $line ;
      $line2 =~ s/^.*<!==\s*OUT\s*// ;
      $line2 =~ s/\s*==>.*$// ;
      $write_details = $false ;
      $write_summary = $false ;
      $write_columns = $false ;
      if ($line2 =~ /C/)
      { $write_columns = $true ; }
      if ($line2 =~ /D/)
      { $write_details = $true ; }
      if ($line2 =~ /S/)
      { $write_summary = $true ; }

      &Print (COLUMNS, "$line\n") ;
      &Print (DETAILS, "$line\n") ;
      &Print (SUMMARY, "$line\n") ;
      next ;
    }

    if ($line =~ /<!==\s*INC .*\s*==>/)
    {
      $line2 = $line ;
      $line2 =~ s/^.*<!==\s*INC\s*// ;
      $line2 =~ s/\s*==>.*$// ;

      $file = "$path_in/$line2" ;
      print "\nInclude $file\n" ;
      if (! -e $file)
      { &Abort ("File $file not found\n") ; }
      open FILE, '<', $file ;
      foreach $line (<FILE>)
      {
        if ($write_columns)
        { &Print (COLUMNS, $line) ; }
        if ($write_details)
        { &Print (DETAILS, $line) ; }
        if ($write_summary)
        { &Print (SUMMARY, $line) ; }
      }
      next ;
    }

    if ($write_columns)
    { &Print (COLUMNS, "$line\n") ; }
    elsif ($line =~ /-->/)
    { &Print (COLUMNS, "<!-- $line\n") ; }
    else
    { &Print (COLUMNS, "<!-- $line -->\n") ; }

    if ($write_details)
    { &Print (DETAILS, "$line\n") ; }
    elsif ($line =~ /-->/)
    { &Print (DETAILS, "<!-- $line\n") ; }
    else
    { &Print (DETAILS, "<!-- $line -->\n") ; }

    if ($write_summary)
    { &Print (SUMMARY, "$line\n") ; }
    elsif ($line =~ /-->/)
    { &Print (SUMMARY, "<!-- $line\n") ; }
    else
    { &Print (SUMMARY, "<!-- $line -->\n") ; }
  }
}

sub Anchor
{
  my $anchor = shift ;
  $anchor =~ s/^\s*// ;
  $anchor =~ s/\s*$// ;
  $anchor =~ s/\s/_/g ;
  return (lc ($anchor)) ;
}

sub WriteSynopsis
{
  my $path_out = shift ;

  $notice_synopsis = "" ;
  # "<font color=#008000><b>New: multi-year trends for most metrics. Depending on history available reporting period can vary.</b></font>" ;

  open SYNOPSIS, '>', "$path_out/RC_${p_year}_${p_month_d2}_synopsis.txt" ;
  print SYNOPSIS $synopsis ;
  close SYNOPSIS ;

# some day also get this code from RT_yyyy_mm.html, for uniformity
$synopsis = <<__SYNOPSIS__ ;
<html lang="en">
<head>
<title>Wikimedia Report Card Synopsis - {{month}} {{yyyy}}</title>
<meta http-equiv="content-type" content="text/html"; charset="iso-8859-1">
<meta http-equiv="Window-target" content="_top">
<meta name="language" content="en,English">
<meta name="robots" content="index,follow">
<link rel="shortcut icon" href="http://wikimediafoundation.org/favicon.ico" />
<link rel="apple-touch-icon" href="http://wikimediafoundation.org/favicon.ico" />
<script src="assets/jquery-1.1.3.1.pack.js" type="text/javascript"></script>
<script src="assets/jquery.history_remote.pack.js" type="text/javascript"></script>
<script src="assets/jquery.tabs.pack.js" type="text/javascript"></script>
<script src="assets/jquery.tablesorter.js" type="text/javascript"></script>

<script type="text/javascript">
\$(function()
{
  \$("#Synopsis").tablesorter();
})
</script>

<script type="text/javascript">
\$(document).ready(
function()
{
\$("#Synopsis").tablesorter(sortList: [[0,0]] );
}
);
</script>

<script type="text/javascript">
\$.tablesorter.addParser({
  id: "nohtml",
  is: function(s) { return false; },
  format: function(s) { return s.replace(/<.*?>/g,"").replace(/&nbsp;/g,""); },
  type: "text"
});
\$.tablesorter.addParser({
  id: "digitsonly",
  is: function(s) { return false; },
  format: function(s) { return $.tablesorter.formatFloat(s.replace(/<.*?>/g,"").replace(/&nbsp;/g,"").replace(/,/g,"").replace(/-/,"-1")); },
  type: "numeric"
});
</script>

<style type="text/css">
/* tables */
table.tablesorter
{
        font-family:arial;
        background-color: #FFF; // #CDCDCD;
        margin:10px 0pt 15px;
        font-size: 7pt;
        width: 80%;
        text-align: left;
}
table.tablesorter thead tr th, table.tablesorter tfoot tr th
{
        background-color: #AAB;
        border: 1px solid #FFF;
        font-size: 8pt;
        padding: 4px;
}
table.tablesorter thead tr .header
{
        background-image: url(assets/bg.gif);
        background-repeat: no-repeat;
        background-position: center right;
        cursor: pointer;
}
table.tablesorter tbody td
{
        color: #3D3D3D;
        padding: 4px;
        background-color: #FFF;
        vertical-align: top;
}
table.tablesorter tbody tr.odd td
{ background-color:#F0F0F6; }
table.tablesorter thead tr .headerSortUp
{ background-image: url(assets/asc.gif); }
table.tablesorter thead tr .headerSortDown
{ background-image: url(assets/desc.gif); }
table.tablesorter thead tr .headerSortDown, table.tablesorter thead tr .headerSortUp
{ background-color: #BBF; //#8dbdd8; }
<!--
body {font-family:arial,sans-serif;background-color:#B0B0B0}
table,td,tr{background-color:#FFFFFF;font-size:11pt}
h1{font-size:22px}
h2{font-size:18px ; color:#006000 ; margin-top:40px}
h3{font-size:15px ; color:#006000}
form{margin:0}
a:link    {color:#000080;text-decoration:none}
a:visited {color:#000080;text-decoration:none}
a:active  {color:#000080;text-decoration:none}
a:hover   {color:#0000FF;text-decoration:underline}
a img     {border-color:black}
td.detail-left   {font-size:12px ; color:#000000 ; text-align:left ; }
td.detail-center {font-size:12px ; color:#000000 ; text-align:center ;  }
td.detail-right  {font-size:12px ; color:#000000 ; text-align:right ; }
-->
</style>
</head>
<body>
<table width=800 cellpadding=18 align=center>
<tr>
  <td align='center'>

    <table width=95%>

    <tr>
      <td width=100% colspan=99>
        <table width=100%>
        <tr>
          <td align=left width=150 valign=top><img src='assets/WikimediaLogo.png' width=30></td>
          <td align=center valign=top><h1>Wikimedia Report Card <font color=#008000>{{month}} {{yyyy}} </font></h1>
          </td>
          <td align=right width=150 valign=top><h1>Synopsis</h1></td>
        <!-- <td align=right width=150 valign=top><small><small>Published<br>{{month+2}}<br>{{yyyy+m2}}</small></small></td> -->
        </tr>
        <tr>
          <td align=left width=150 valign=top><!--  <small><a href='RC_{{yyyy}}_{{mm-1}}_synopsis.html'>&lArr;&nbsp;{{month-1}}</a></small>--> </td>
          <td align=center valign=top>
            <small>&rArr; <a href='RC_{{yyyy}}_{{mm}}_detailed.html'>Detailed version</a>&nbsp;&nbsp;&nbsp;&nbsp; &rArr; <a href='RC_{{yyyy}}_{{mm}}_summary.html'>Summary, 1 column</a>&nbsp;&nbsp;&nbsp;&nbsp; &rArr; <a href='RC_{{yyyy}}_{{mm}}_columns.html'>Summary, 2 columns</a></small>
          </td>
          <td align=right width=150 valign=top><!--<small><a href='RC_{{yyyy}}_{{mm+1}}_synopsis.html'>{{month+1}}&nbsp;&rArr;</a></small>--></td>
        </tr>
        </table>
      </td>
    </tr>
 <tr>
   <td colspan=99>
   <small>
     <center>
       $notice_synopsis
     </center> <!--  General comment -->
   </small>
  </td>
</tr>
<tr><td colspan=99 align=center>
<table border=1 id='Synopsis' class=tablesorter>
<!-- <tr> -->
<!--   <td align='left' colspan=99> -->
<!--  <font color=#800000><b><small>No English Wikipedia dump was produced this month.<br>Without it some totals and trends are also meaningless and left blank.</small></b></font> -->
<!--   </td> -->
<!-- </tr> -->
DATA
</table>
</td></tr>
    <tr>
      <td colspan=99 align=center>
      <hr class=thin>
      <small><small><font color=808080>Author Erik Zachte - mail: ezachte@###.org (nospam: ###=wikimedia)</font></small></small>
    </td>
    </tr>
    </table>
<script type='text/javascript'>
\$('#Synopsis').tablesorter({
  // debug:true,
  headers:{0:{sorter:'nohtml'},1:{sorter:false},2:{sorter:'digitsonly'},3:{sorter:'digitsonly'},4:{sorter:false}}
});
</script>

</body>
</html>
__SYNOPSIS__

  undef @synopsis_notes ;

# $data = "<tr><th>Unique Visitors</th></tr>\n" ;
# $synopsis  = "Y: " . substr ($p_month_name,0,3) . ",$p_year_prev->$p_year    k=thousand  m=million  b=billion\n" ;
# $synopsis .= "M: $p_year," . substr ($p_month_name_prev,0,3) . "->" . substr ($p_month_name,0,3)  . "     M=monthly   D=daily    T=Total\n\n" ;
  $data  = "<thead><tr><th class=detail-left   valign=top>&nbsp;<b>Metric</b>&nbsp;</th>" .
               "<th class=detail-center valign=top>&nbsp;<b>Now</b>&nbsp;<br>{{mm}}/{{yy}}</th>" .
               "<th class=detail-center valign=top>&nbsp;<b>Yearly change</b>&nbsp;<br>{{mm}}/{{yy-1}} &rArr; {{mm}}/{{yy}}</th>" .
               "<th class=detail-center valign=top>&nbsp;<b>Monthly change</b>&nbsp;<br>{{(mm/yy)-1}} &rArr; {{mm}}/{{yy}}</th>" .
               "<th class=detail-center valign=top>&nbsp;<b>Notes</b>&nbsp;</th></tr></thead>\n<tbody>\n" ;
#  $data .= "<tr><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th></tr></thead>" ;

# $comment_prev_month = "<sup><font color=#800000>*</font></sup>" ; # qqq

  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#unique_visitors'>Unique Visitors</a> <sup>All</sup>", "", @visitors) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#page_requests'>Page Requests</a> <sup>All</sup>", "", @page_requests) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#web_properties'>Site Rank</a> <sup>All</sup>", "", @rank) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#commons_files'>Binary Files</a> <sup>Commons</sup> $comment_prev_month", "", @commons_files) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#article_count'>Article Count</a> <sup>Wp</sup> $comment_prev_month", "", @article_count) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#articles_per_day'>New Articles Per Day</a> <sup>Wp</sup> $comment_prev_month", "", @new_articles) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#edits_per_month'>Edits</a> <sup>Wp</sup> $comment_prev_month", "", @edits) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#new_editors_per_month'>New Editors <sup>Wp</sup></a> $comment_prev_month", "", @new_editors) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#active_editors'>Active Editors</a> <sup>Wp</sup> $comment_prev_month", "", @active_editors) ;
  $data .= &FormatSynopsisTable ("<a href='RC_{{yyyy}}_{{mm}}_detailed.html#very_active_editors'>Very Active Editors</a> <sup>Wp</sup> $comment_prev_month", "", @very_active_editors) ;
  $data .= "</tbody>\n<tfoot><tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $data .= "<tr><td colspan=99><b><small>Repeated observations below are grayed</small></b></td></tr>\n" ;

  foreach $note (@synopsis_notes)
  {
    $data .= "<tr><td class=detail-left colspan=99>$note</td></tr>" ;
  }
# $data .= "<tr><td class=detail-left colspan=99><font color=#800000><small>* For German and Polish Wikipedias data for June were not yet available: reused counts from May</small></font></td></tr>" ;
  $data .= "<tr><td class=detail-left colspan=99><font color=#808080><small>All = All projects, Wp = Wikipedia project&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;B = billion, M = million, k = thousand</small></font></td></tr></tfoot>" ;

  $synopsis =~ s/DATA/$data/ ;

  $synopsis =~ s/{{yyyy}}/$p_year/g ;
  $synopsis =~ s/{{yyyy-1}}/$p_year_prev/g ;
  $synopsis =~ s/{{yyyy\+m2}}/$p_year_plus_m2/g ;
  $synopsis =~ s/{{month}}/$p_month_name/g ;
  $synopsis =~ s/{{month-1}}/$p_month_name_prev/g ;
  $synopsis =~ s/{{month\+1}}/$p_month_name_next/g ;
  $synopsis =~ s/{{month\+2}}/$p_month_name_next2/g ;

  $synopsis =~ s/{{y}}/$p_year_short/g ;
  $synopsis =~ s/{{y\-1}}/$p_year_prev_short/g ;
  $synopsis =~ s/{{yy}}/$p_year_short_d2/g ;
  $synopsis =~ s/{{yy\-1}}/$p_year_prev_short_d2/g ;
  $synopsis =~ s/{{m}}/$p_month/g ;
  $synopsis =~ s/{{m\-1}}/$p_month_prev/g ;
  $synopsis =~ s/{{mm}}/$p_month_d2/g ;
  $synopsis =~ s/{{mm-1}}/$p_month_prev_d2/g ;
  $synopsis =~ s/{{mm\+1}}/$p_month_next_d2/g ;

  $synopsis =~ s/{{\(mm\/yy\)-1}}/$p_year_month_m1/g ;
  open SYNOPSIS, '>', "$path_out/RC_${p_year}_${p_month_d2}_synopsis.html" ;
  print SYNOPSIS $synopsis ;
  close SYNOPSIS ;
}

sub Print
{
  $handle = shift ;
  $text   = shift ;

  if ((! $debug) && ($text !~ /\[if lte/))  # Q&D: keep MSIE directive
  {
    if ($text =~ /<!--/) # comments
    { return ; }
    if ($text =~ /<!==/) # template markup
    { return ; }
  }

  if (($target_audience == $public)  && $write_public)
  { print $handle $text ; }
  if (($target_audience == $private) && $write_private)
  { print $handle $text ; }
}

sub FormatSynopsisText
{
  $label   = shift ;
  $comment = shift ;
  @metrics = @_ ;

  $metric  = $metrics [0] ;
  $size    = $metrics [1] ;
  $inc_y   = $metrics [2] ; # yearly
  $inc_m   = $metrics [3] ; # monthly
  $inc     = $metrics [4] ; # perc ?

  $metric =~ s/,//g ;
  if ($inc eq "th") # rank
  {
    $inc_y .= "  " ;
    $inc_m .= "  " ;
    $inc = " " ;
  }
  $size=~ s/[x]/ / ;


  if ($inc_y !~ /-/) { $inc_y = '+' . $inc_y ; }
  if ($inc_m !~ /-/) { $inc_m = '+' . $inc_m ; }
  $inc_y = sprintf ("%5s", $inc_y) . $inc ;
  $inc_m = sprintf ("%5s", $inc_m) . $inc ;

  if ($metric =~ /^\.+$/)
  { ; }
  elsif ($size eq "b")
  { $metric = sprintf ("%.0f", $metric / 1000000000) ; }
  elsif ($size eq "m")
  { $metric = sprintf ("%.0f", $metric / 1000000) ; }
  elsif ($size eq "k")
  { $metric = sprintf ("%.0f", $metric / 1000) ; }
  else
  { $metric = sprintf ("%.0f", $metric) ; }

  my $text = sprintf ("%-20s", $label) . sprintf ("%8s", "$metric $size") ;
  $text .= " (Y:$inc_y / M:$inc_m) $comment\n" ;
  return $text ;
}

sub FormatSynopsisTable
{
  $label   = shift ;
  $comment = shift ;

  @metrics = @_ ;

  $metric  = $metrics [0] ;
  $size    = $metrics [1] ;
  $inc_y   = $metrics [2] ; # yearly
  $inc_m   = $metrics [3] ; # monthly
  $inc     = $metrics [4] ; # perc ?
  $notes   = $metrics [5] ; # perc ?

  ($notes_ref,$notes) = split ('\|', $notes) ;
  if ($notes ne "")
  {
    # text between '#' and first bracket (<>) will be grayed (repeated remarks)
    $notes =~ s/#([^<>]+)/<font color=#808080>$1<\/font>/g ;
    push @synopsis_notes, $notes ;
  }

  $metric =~ s/,//g ;
  if ($inc eq "th") # rank
  {
    $inc_y .= "  " ;
    $inc_m .= "  " ;
    $inc = " " ;
  }
  $size=~ s/[x]/ / ;


  if ($inc_y !~ /-/) { $inc_y = '+' . $inc_y ; }
  if ($inc_m !~ /-/) { $inc_m = '+' . $inc_m ; }
  $inc_y = sprintf ("%5s", $inc_y) . $inc ;
  $inc_m = sprintf ("%5s", $inc_m) . $inc ;

  if ($size eq "k")
  { $metric = sprintf ("%.1f", $metric / 1000) ; }
  elsif ($size eq "b")
  { $size = "B" ; }
  elsif ($size eq "m")
  { $size = "M" ; }
  elsif ($size eq "k")
  { $size = "K" ; }
  else
  { $size = "&nbsp;&nbsp;" ; }

  if ($notes_ref eq "")
  { $notes_ref = '&nbsp;' ; }

  $metric = "$metric $size" ;

  if (($metric =~ /\.\./) || ($metric =~ /^0\.0/)) { $metric = "<font color=#C0C0C0>$metric</font>" ; }
  if (($metric =~ /\.\./) || ($metric =~ /^0\.0/)) { $metric = "<font color=#C0C0C0>$metric</font>" ; }
  if (($inc_y  =~ /\.\./) || ($inc_y  =~ /^0\.0/)) { $inc_y  = "<font color=#C0C0C0>$inc_y</font>" ; }
  if (($inc_m  =~ /\.\./) || ($inc_m  =~ /^0\.0/)) { $inc_m  = "<font color=#C0C0C0>$inc_m</font>" ; }

  my $text = "<tr><td class=detail-left>$label</td><td class=detail-right>$metric</td><td class=detail-right>$inc_y</td><td class=detail-right>$inc_m</td><td class=detail-right>$notes_ref</td></tr>\n" ;
  return $text ;
}

sub Abort
{
  $msg = shift ;
  chomp $msg ;
  print "\n!!! Abort script: '$msg'\n" ;
  exit ;
}

