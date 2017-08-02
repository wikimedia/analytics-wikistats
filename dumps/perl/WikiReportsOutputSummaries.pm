#!/usr/bin/perl

# needed files
# StatisticsMonthly.csv
# StatisticsUserActivitySpread.csv
sub GenerateSummariesPerWiki
{
# print "Remove obsolete R plot files\n" ;
# $cmd = "rm $path_in" . "R-Plot*" ;
# print "$cmd\n" ;
# `$cmd` ;

  my $wp_only = shift ; # do all if empty argument

  my @months_en   = qw (January February March April May June July August September October November December);
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
  $summaries_published = "$mday ${months_en [$mon]} " . ($year+1900) ;

  $logo_project = &HtmlLogoProject ; # removed WMF logo <img src='http://stats.wikimedia.org/WikimediaLogo.jpg' width=30>

  $col_highlight = "#8080FF" ;

  $out_html_report_card = '' ;

     if ($mode eq 'wb')  { $out_publication  = $out_wikibook ; }
  elsif ($mode eq 'wk')  { $out_publication  = $out_wiktionary ; }
  elsif ($mode eq 'wn')  { $out_publication  = $out_wikinews ; }
  elsif ($mode eq 'wo')  { $out_publication  = $out_wikivoyage ; }
  elsif ($mode eq 'wq')  { $out_publication  = $out_wikiquote ; }
  elsif ($mode eq 'ws')  { $out_publication  = $out_wikisources ; }
  elsif ($mode eq 'wv')  { $out_publication  = $out_wikiversity ; }
  elsif ($mode eq 'wx')  { $out_publication  = $out_wikispecial ; }

  # Generate edit/view plots per wiki
  # Generate html file per single wiki
  # Collect html for multiple wikis (top 50 or per region), aka report card

  $summaries_index = 0 ;
  $summaries_collected = 0 ;
  $language_count = $#languages + 1 ;
  foreach $wp (@languages)
  {
  # next if $wp ne 'zz' and $wp ne 'en' and $wp ne 'commons' and $wp ne 'wikidata' ; # for quick tests
    
    next if $wp_only ne '' and $wp ne $wp_only ;

    $language         = $out_languages {$wp} ;
    $language_article = $out_article {$wp} ;
    $explanation  = &HtmlSummaryExplanation ("Sitemap.htm") ;
    $explanation2 = $explanation ;

    if ($mode_wx)
    {
      $explanation  =~ s/ARTICLE_LANGUAGE// ;
      $explanation2 =~ s/ARTICLE_LANGUAGE// ;
    }
    else
    {
      $explanation  =~ s/ARTICLE_LANGUAGE/Data are from the <a href='$language_article'>English Wikipedia page on $language<\/a>./ ;
      $explanation2 =~ s/ARTICLE_LANGUAGE/Data are from the English Wikipedia page for each language./ ;
    }

    $explanation_report_card = &HtmlSummaryExplanationReportCard ($explanation2) ;
    $explanation  =~ s/<p>/<p>&nbsp;<p>/ ;

    $summaries_index ++ ;
    $summaries_progress = "$summaries_index/$language_count" ;

    if ($skip {$wp}) 
    {
      &LogT ("$summaries_progress: skip $wp\n") ;
      next ;
    }

    $out_html = &GetSummaryPerWiki ($wp, $summaries_progress) ;
    if ($wp eq 'commons')
    {
      &GeneratePlotBinaries  ($wp,1) ;
      &GeneratePlotBinaries  ($wp,2) ;
      &GeneratePlotUploads   ($wp) ;
      &GeneratePlotUploaders ($wp) ;
    }
    else
    {
      &GeneratePlotArticles ($wp, 'Total') ;
      &GeneratePlotArticles ($wp, 'New') ;
    }

    $html =~ s/PLOT_TOTAL_ARTICLES/$html_plot_total_articles/ ;
    &GeneratePlotEditors   ($wp) ;

    if ($wp =~ /^zz+$/) 
    { &GeneratePlotActiveWikis ($wp) ; }

  # next if $wp !~ /^zz+$/ and $wp ne 'en' ; # for quick tests 

    &GeneratePlotPageviews ($wp) ; 

    $cmd = "mv *.Rout $path_in\n" ;
    `$cmd` ;
    if ($move_R_plot_output_logs++ == 0)
    { print "\nMove R plot output logs -> $cmd\n\n" ; }

    my $file_html = $path_out . "Summary" . uc ($wp) . ".htm" ;

    $out_html_multiple_wikis = $out_html ;
    $out_html_single_wiki    = $out_html ;

    $out_html_multiple_wikis =~ s/EXPLANATION// ;
    $out_html_single_wiki    =~ s/EXPLANATION/$explanation/ ;

    $out_html_multiple_wikis =~ s/EXPLANATION2/$explanation_report_card/ ;
    $out_html_single_wiki    =~ s/EXPLANATION2// ;

    $out_html_multiple_wikis =~ s/SEE_ALSO// ;
    $out_html_single_wiki    =~ s/SEE_ALSO/$see_also/ ;

    $out_html_multiple_wikis =~ s/DATASOURCES/$source/ ;
    $out_html_single_wiki    =~ s/DATASOURCES// ;

    $out_html_multiple_wikis =~ s/TOP/<a href='#top'>top<\/a>&nbsp;&lArr;/ ;
    $out_html_single_wiki    =~ s/TOP/&nbsp;/ ;

    if (($region ne '') || (++$summaries_collected <= 50))
    {
      $out_html_report_card .= $out_html_multiple_wikis . "&nbsp;<p>" ;
      $summaries_included {$wp} = $true ;
    }

    $out_html = &HtmlSingleWiki ($out_style2, $out_html_single_wiki) ;

    open "FILE_OUT", ">", $file_html ;
    print FILE_OUT &AlignPerLanguage ($out_html) ;
    close "FILE_OUT" ;

    # last if $summaries_collected >= 55 # speed up tests
  }

  my $title_content ;
  my $file_html_all ;

  # Generate report card
  if ($region ne '')
  {
    $file_html_all  = $path_out . "ReportCard" . ucfirst ($region) . ".htm" ;
    if ($region eq 'artificial')
    { $title_content = "Wikipedia Report Card: summaries for <font color=$col_highlight>Artificial Languages</font>" ; }
    else
    { $title_content = "Wikipedia Report Card: summaries for region <font color=$col_highlight>" . ucfirst ($region) . "</font>" ; }
  }
  else
  {
    $file_html_all  = $path_out . "ReportCardTopWikis.htm" ;
    if ($mode_wx)
    { $title_content = "Report Card: summaries for Commons and " . ($summaries_collected - 1) . " other projects" ; }
    elsif ($summaries_collected < 50)
    { $title_content = "$out_publication Report Card: summaries for $summaries_collected languages" ; }
    else
    { $title_content = "$out_publication Report Card: summaries for 50 most visited languages" ; }
  }

  # $title_report_card = "WMF Summary Report $coverage" ;

  my $index_html   = &SummaryAddIndexes (%summaries_included) ;
  my $cross_ref    = &HtmlSummariesCrossReference ;

  $out_html_header_report_card   = &HtmlHeaderReportCard ($logo_project, $index_html, $cross_ref, $title_content) ;
  $out_html_report_card = &HtmlReportCard ($title_content, $out_style2, $out_html_header_report_card, $out_html_report_card, $explanation_report_card) ;

print "write summary page $file_html_all\n" ;

  open "FILE_OUT", ">", $file_html_all ;
  print FILE_OUT &AlignPerLanguage ($out_html_report_card) ;
  close "FILE_OUT" ;
}

sub GetSummaryPerWiki
{
  my ($wp,$progress,$wiki) = @_ ;

  my @months_en = qw (January February March April May June July August September October November December);

  my $html ;

  # my $m = $MonthlyStatsWpStop {$wp} ;
  # if ($month_max_incomplete)
  # { $m-- ; }

  $m = $editors_month_hi_5 {$wp} ;
  my $mmddyyyy = &m2mmddyyyy ($m) ;

  $month_year = $months_en [substr ($mmddyyyy,0,2)-1] . " " . substr ($mmddyyyy,6,4) ;
  my $out_language_name = $out_languages {$wp} ;

  my $main_page = &GetProjectBaseUrl ($wp) ;

  if ($wp =~ /^zz+$/)
  { $main_page = '' ; } 

  &LogT ("$progress: month $month_year $out_language_name $out_publication ($wp)\n") ;
  $html = "\n" ;

  # page views

  $daysinmonth     = days_in_month (substr ($mmddyyyy,6,4), substr ($mmddyyyy,0,2)) ;
# $pageviews_month = sprintf ("%.0f", ($PageViewsPerHour {$wp} * 24 * 30)) ; # use normalized count (month always 30 days)
  
  $pageviews_month = $pageviews {$wp.$m}    + $pageviews {"$wp.m".$m} ; 

  $pageviews_day   = $pageviews_month / 30 ; # $daysinmonth ;
  $pageviews_hour  = $pageviews_day / 24 ;
  $pageviews_min   = $pageviews_day / (24 * 60) ;
  $pageviews_sec   = $pageviews_day / (24 * 60 * 60) ;

  $this_month         = $pageviews_month ;
  $metric_PV_yearly   = "--" ;
  $metric_PV_monthly  = "--" ;

# print "$month_year: $daysinmonth days in month, page views $pageviews_month\n" ;

  $metric_PV_data     = &FormatSummary ($this_month) ; # based on $PageViewsPerHour {$wp} 

  $pageviews_month = &format($pageviews_month,'X') ;
  $pageviews_day   = &format($pageviews_day,'X') ;
  $pageviews_hour  = &format($pageviews_hour,'X') ;
  $pageviews_min   = &format($pageviews_min,'X') ;
  $pageviews_sec   = &format($pageviews_sec,'X') ;

  if ($pageviews_sec >= 1)
  { $pageviews_per_unit = "$pageviews_month/month = $pageviews_day /day = $pageviews_hour /hour = $pageviews_min /minute = $pageviews_sec /second" ; }
  elsif ($pageviews_min >= 1)
  { $pageviews_per_unit = "$pageviews_month/month = $pageviews_day /day = $pageviews_hour /hour = $pageviews_min /minute" ; }
  else
  { $pageviews_per_unit = "$pageviews_month/month = $pageviews_day /day = $pageviews_hour /hour " ; }

  $pageviews_per_unit =~ s/M/million/g ;
  $pageviews_per_unit =~ s/k/thousand/g ;
  $pageviews_per_unit =~ s/\// per /g ;

  if ($mode_wo) # no data yet for wikivoyage
  {
    $metric_PV_data      = '?' ;
    $pageviews_per_month = '?' ;
    $pageviews_per_day   = '?' ;
    $pageviews_per_hour  = '?' ;
    $pageviews_per_min   = '?' ;
    $pageviews_per_sec   = '?' ;
    $pageviews_per_unit = '?' ;
  }  

  # article count
  $this_month         = $MonthlyStats {$wp.$m.$c[4]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[4]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[4]} ;
  $metric_AC_yearly   = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_AC_monthly  = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_AC_data     = &FormatSummary ($this_month) ;

  # new articles per day
  $this_month         = $MonthlyStats {$wp.$m.$c[6]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[6]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[6]} ;
  $this_month =~ s/(\d)(\d\d\d)/$1,$2/g ;
  $metric_NAD_yearly  = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_NAD_monthly = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_NAD_data    = &FormatSummary ($this_month) ;

  # edits per month
  $this_month         = $MonthlyStats {$wp.$m.$c[11]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[11]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[11]} ;
  $metric_EPM_yearly  = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_EPM_monthly = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_EPM_data    = &FormatSummary ($this_month) ;

  # active editors
  $this_month         = $MonthlyStats {$wp.$m.$c[2]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[2]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[2]} ;
  $metric_AE_yearly   = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_AE_monthly  = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_AE_data     = &FormatSummary ($this_month) ;

  # very active editors
  $this_month         = $MonthlyStats {$wp.$m.$c[3]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[3]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[3]} ;
  $metric_VAE_yearly  = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_VAE_monthly = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_VAE_data    = &FormatSummary ($this_month) ;

  # new editors
  $this_month         = $MonthlyStats {$wp.$m.$c[1]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[1]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[1]} ;
  $metric_NE_yearly   = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_NE_monthly  = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_NE_data     = &FormatSummary ($this_month) ;

  if ($wp =~ /^zz+$/)
  {
    my $blue = '#AAF' ;
    my $msg  = 'View charts for this metric across all projects' ;
    my $url  = 'http://stats.wikimedia.org/EN' ;
    $link_total_editors   = "<br><a href='$url/ProjectTrendsEditors.html'><font color=$blue>$msg</font></a>" ;
    $link_total_pageviews = "<br><a href='$url/ProjectTrendsPageviews.html'><font color=$blue>$msg</a>" ;
    $link_total_articles  = "<br><a href='$url/ProjectTrendsTotalArticles.html'><font color=$blue>$msg</a>" ;
    $link_new_articles    = "<br><a href='$url/ProjectTrendsNewArticles.html'><font color=$blue>$msg</a>" ;
    $link_total_edits     = "<br><a href='$url/ProjectTrendsTotalEdits.html'><font color=$blue>$msg</a>" ;
    $link_active_wikis    = "<br><a href='$url/ProjectTrendsActiveWikis.html'><font color=$blue>$msg</a>" ;
  }
  else
  {
    $link_total_editors   = '' ;
    $link_total_pageviews = '' ;
    $link_total_articles  = '' ;
    $link_new_articles    = '' ;
    $link_total_edits     = '' ;
    $link_active_wikis    = '' ;
  }

  if (! $mode_wx)
  {
    # million speakers
    $speakers = $out_speakers {$wp} ;
    $editors  = $MonthlyStats {$wp.$m.$c[2]} ;

    if ($speakers == 0)
    { $participation = "?" ; }
    elsif ($editors / $speakers >= 1)
    { $participation = sprintf ("%.0f", $editors / $speakers) ; }
    else
    { $participation = sprintf ("%.1f", $editors / $speakers) ; }

    $this_month         = $speakers ;
    $metric_MS_yearly   = '--&nbsp;&nbsp;&nbsp;&nbsp;'  ;
    $metric_MS_monthly  = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_month) ;
    if ($speakers eq '')
    { $metric_MS_data   = '?' ; }
    else
    { $metric_MS_data   = &FormatSummary (sprintf ("%.0f", $this_month * 1000000)) ; }

    # editors per million speakers
    $metric_EMS_yearly   = '--&nbsp;&nbsp;&nbsp;&nbsp;' ;
    $metric_EMS_monthly  = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_month) ;
    $metric_EMS_data     = $participation ;
  }

  $out_style2 = $out_style ;
  $out_style2 =~ s/td   {white-space:nowrap;/td   {font-size:12px; white-space:nowrap;/ ;
  $out_style2 =~ s/body\s*\{.*?\}/body {font-family:arial,sans-serif;background-color:#C0C0C0}/ ;

  $plot_binaries1      = 'PlotBinaries'      . uc ($wp) . '1.png' ;
  $plot_binaries2      = 'PlotBinaries'      . uc ($wp) . '2.png' ;
  $plot_editors        = 'PlotEditors'       . uc ($wp) . '.png' ;
  $plot_pageviews      = 'PlotPageviews'     . uc ($wp) . '.png' ;
  $plot_uploads        = 'PlotUploads'       . uc ($wp) . '.png' ;
  $plot_uploaders      = 'PlotUploaders'     . uc ($wp) . '.png' ;
  $plot_total_articles = 'PlotTotalArticles' . uc ($wp) . '.png' ;
  $plot_new_articles   = 'PlotNewArticles'   . uc ($wp) . '.png' ;
  $plot_edits          = 'PlotEditsSmall'    . uc ($wp) . '.png' ;
  $plot_active_wikis   = 'PlotActivity'      . uc ($wp) . '.png' ;

  if ($mode_wx)
  { $wiki = $out_language_name ; }
  else
  { $wiki = "$out_language_name $out_publication" ; }

  if ($mode_wp)
  { $msg_pageviews_mobile_added = blank_text_after ("05/04/2014", "<br><font color=#080>Jan 2014: <b>NEW</b> trend lines have been added for views to mobile site and overall total.</font><br><font color=#666>Earlier this plot only showed views to the non mobile site, without mentioning this explicitly. Our apologies for any confusion caused.</font>") ; }

$html = <<__HTML_SUMMARY__ ;
<a id='lang_$wp' name='lang_$wp'></a>
<table width=660 cellpadding=18 align=center border=1 style="background-color:white">
<tr>
  <td class=c colspan=99 width=100%>
    <table width=100% border=0>
    <tr>
      <td width=100% colspan=99>

        <table width=100% border=0>
        <tr>
          <td class=l width=80% valign=top>
            <h2><a href='$main_page'><font color=$col_highlight>$wiki</font></a></h2>
          </td>
          <td class=r width=20% valign=top><a href='http://www.wikimedia.org'>$logo_project</td>
        </tr>
        </table>

      </td>
    </tr>
    </table>

    <table width=100% border=0>
    <tr>
      <td class=l colspan=99 width=100%>
         <b>&nbsp;$wiki at a glance</b>&nbsp;<i>$month_year</i>&nbsp;&nbsp;<br>
      </td>
    <tr>
    <!--
      <td width=5%>
        &nbsp;
      </td>
      <td width=95%>
    -->
      <td width=100%>
        <table width=100% border=0>
          <tr>
            <td class=l width=34%>TOP</td>
            <td class=r width=22%><font color=black><b>Data</b></td>
            <td class=r width=22%><font color=black><b>Yearly change</b></td>
            <td class=r width=22%><font color=black><b>Monthly change</b></td>
          </tr>
          <tr>
            <td colspan=99><hr color=#808080></td>
          </tr>

          <tr>
            <td class=l>Page Views per Month</td>
            <td class=r>$metric_PV_data</td>
            <td class=r>$metric_PV_yearly</td>
            <td class=r>$metric_PV_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          <tr>
            <td class=l>Article Count</td>
            <td class=r>$metric_AC_data</td>
            <td class=r>$metric_AC_yearly</td>
            <td class=r>$metric_AC_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          <tr>
            <td class=l>New Articles per Day</td>
            <td class=r>$metric_NAD_data</td>
            <td class=r>$metric_NAD_yearly</td>
            <td class=r>$metric_NAD_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          <tr>
            <td class=l>Edits per Month</td>
            <td class=r>$metric_EPM_data</td>
            <td class=r>$metric_EPM_yearly</td>
            <td class=r>$metric_EPM_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          <tr>
            <td class=l>Active Editors</td>
            <td class=r>$metric_AE_data</td>
            <td class=r>$metric_AE_yearly</td>
            <td class=r>$metric_AE_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          <tr>
            <td class=l>Very Active Editors</td>
            <td class=r>$metric_VAE_data</td>
            <td class=r>$metric_VAE_yearly</td>
            <td class=r>$metric_VAE_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          <tr>
            <td class=l>New Editors</td>
            <td class=r>$metric_NE_data</td>
            <td class=r>$metric_NE_yearly</td>
            <td class=r>$metric_NE_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          SPEAKERS
          PARTICIPATION
          BINARIES
        </table>
      </td>
    </tr>

    PLOT_ACTIVE_WIKIS
    PLOT_EDITORS
    PLOT_UPLOADERS
    PLOT_EDITS
    PLOT_PAGEVIEWS
    PLOT_BINARIES
    PLOT_UPLOADS
    PLOT_TOTAL_ARTICLES
    PLOT_NEW_ARTICLES

    EXPLANATION
    SEE_ALSO
    DATASOURCES
    </table>

  </td>
</tr>
</table>

__HTML_SUMMARY__

# obsolete ?
# if ($mode_wo) # no data yet for wikivoyage
# { $html =~ s/PLOT_PAGEVIEWS// ; }

$html_speakers = <<__HTML_SUMMARY_SPEAKERS__ ;
          <tr>
            <td class=l>Speakers</td>
            <td class=r>$metric_MS_data</td>
            <td class=r>$metric_MS_yearly</td>
            <td class=r>$metric_MS_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>
__HTML_SUMMARY_SPEAKERS__

$html_participation = <<__HTML_SUMMARY_PARTICIPATION__ ;
          <tr>
            <td class=l>Editors per Million Speakers</td>
            <td class=r>$metric_EMS_data</td>
            <td class=r>$metric_EMS_yearly</td>
            <td class=r>$metric_EMS_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>
__HTML_SUMMARY_PARTICIPATION__

$html_plot_binaries = <<__HTML_SUMMARY_PLOT_BINARIES__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_binaries1'>
      </td>
    </tr>
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_binaries2'>
      </td>
    </tr>
__HTML_SUMMARY_PLOT_BINARIES__

$html_plot_editors = <<__HTML_SUMMARY_PLOT_EDITORS__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_editors'>
      $link_total_editors
      </td>
    </tr>
__HTML_SUMMARY_PLOT_EDITORS__

$html_plot_pageviews = <<__HTML_SUMMARY_PLOT_PAGEVIEWS__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_pageviews'>
      <br><small><font color=#808080>Page views: $pageviews_per_unit</font>$msg_pageviews_mobile_added</small>
      <br><small><font color=#808080>Metrics have been normalized to months of 30 days: Jan*30/31, Feb*30/(28|29), Mar*30/31, etc</font></small> 
      $link_total_pageviews
      </td>
    </tr>
__HTML_SUMMARY_PLOT_PAGEVIEWS__

$html_plot_uploads = <<__HTML_SUMMARY_PLOT_UPLOADS__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_uploads'>
      </td>
    </tr>
__HTML_SUMMARY_PLOT_UPLOADS__
# <br><small><font color=#808080>uploads: $uploads_per_unit</font></small> # before </td>

$html_plot_uploaders = <<__HTML_SUMMARY_PLOT_UPLOADERS__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_uploaders'>
      </td>
    </tr>
__HTML_SUMMARY_PLOT_UPLOADERS__
# <br><small><font color=#808080>uploaders: $uploaders_per_unit</font></small> # before </td>

$html_plot_total_articles = <<__HTML_SUMMARY_PLOT_TOTAL_ARTICLES__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_total_articles'>
      $link_total_articles
      </td>
    </tr>
__HTML_SUMMARY_PLOT_TOTAL_ARTICLES__
# <br><small><font color=#808080>total articles: $total_articles_per_unit</font></small> # before </td>

$html_plot_new_articles = <<__HTML_SUMMARY_PLOT_NEW_ARTICLES__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_new_articles'>
      $link_new_articles
      </td>
    </tr>
__HTML_SUMMARY_PLOT_NEW_ARTICLES__
# <br><small><font color=#808080>new articles: $new_articles_per_unit</font></small> # before </td>

$html_plot_edits = <<__HTML_SUMMARY_PLOT_EDITS__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_edits'>
      $link_total_edits
      </td>
    </tr>
__HTML_SUMMARY_PLOT_EDITS__
# <br><small><font color=#808080>new articles: $edits_per_unit</font></small> # before </td>

$html_plot_active_wikis = <<__HTML_SUMMARY_PLOT_ACTIVE_WIKIS__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_active_wikis'>
      $link_active_wikis
      </td>
    </tr>
__HTML_SUMMARY_PLOT_ACTIVE_WIKIS__
# <br><small><font color=#808080>active wikis: $active_wikis</font></small> # before </td>

  if ($mode_wx)
  {
    if ($wp eq 'commons')
    {
      $html =~ s/PLOT_ACTIVE_WIKIS// ;
      $html =~ s/PLOT_TOTAL_ARTICLES// ;
      $html =~ s/PLOT_NEW_ARTICLES// ;
      $html =~ s/BINARIES/&ReadStatisticsBinariesCommons/e ;
      $html =~ s/SPEAKERS// ;
      $html =~ s/PARTICIPATION// ;
      $html =~ s/PLOT_BINARIES/$html_plot_binaries/ ;
      $html =~ s/PLOT_EDITORS/$html_plot_editors/ ;
      $html =~ s/PLOT_PAGEVIEWS/$html_plot_pageviews/ ;
      $html =~ s/PLOT_UPLOADS/$html_plot_uploads/ ;
      $html =~ s/PLOT_UPLOADERS/$html_plot_uploaders/ ;
      $html =~ s/PLOT_EDITS/$html_plot_edits/ ;
    }
    else
    {
      $html =~ s/PLOT_ACTIVE_WIKIS// ;
      $html =~ s/PLOT_TOTAL_ARTICLES/$html_plot_total_articles/ ;
      $html =~ s/PLOT_NEW_ARTICLES/$html_plot_new_articles/ ;
      $html =~ s/BINARIES// ;
      $html =~ s/SPEAKERS// ;
      $html =~ s/PARTICIPATION// ;
      $html =~ s/PLOT_BINARIES// ;
      $html =~ s/PLOT_EDITORS/$html_plot_editors/ ;
      $html =~ s/PLOT_UPLOADS// ;
      $html =~ s/PLOT_UPLOADERS// ;
      $html =~ s/PLOT_EDITS/$html_plot_edits/ ;

      if ($pageviews_max {$wp} == 0)
    # { $html =~ s/PLOT_PAGEVIEWS/<tr><td class=c><p><font color=#800000><small>Page views unknown<\/small><\/font><\/td><\/tr>/ ; }
      { $html =~ s/PLOT_PAGEVIEWS// ; }
      else
      { $html =~ s/PLOT_PAGEVIEWS/$html_plot_pageviews/ ; }
    }
  }
  else
  {
    $html =~ s/BINARIES// ;

    if ($wp =~ /^zz+$/)
    {
      $html =~ s/SPEAKERS// ; 
      $html =~ s/PARTICIPATION// ; 
    }
    else
    { $html =~ s/PLOT_ACTIVE_WIKIS// ; }
    
    $html =~ s/PLOT_ACTIVE_WIKIS/$html_plot_active_wikis/ ;

    $html =~ s/SPEAKERS/$html_speakers/ ; 

    if ($speakers * 1000000 >= 100000) # enough speakers for participation metric ?
    { $html =~ s/PARTICIPATION/$html_participation/ ; }
    else
    { $html =~ s/PARTICIPATION// ; }

    $html =~ s/PLOT_BINARIES// ;
    $html =~ s/PLOT_EDITORS/$html_plot_editors/ ;

    if ($pageviews_max {$wp} == 0)
  # { $html =~ s/PLOT_PAGEVIEWS/<tr><td class=c><p><font color=#800000><small>Page views unknown<\/small><\/font><\/td><\/tr>/ ; }
    { $html =~ s/PLOT_PAGEVIEWS// ; }
    else
    { $html =~ s/PLOT_PAGEVIEWS/$html_plot_pageviews/ ; }

    $html =~ s/PLOT_UPLOADS// ;
    $html =~ s/PLOT_UPLOADERS// ;
    $html =~ s/PLOT_TOTAL_ARTICLES/$html_plot_total_articles/ ;
    $html =~ s/PLOT_NEW_ARTICLES/$html_plot_new_articles/ ;
    $html =~ s/PLOT_EDITS/$html_plot_edits/ ;
  }

  if ($region eq '')
  {
    $langcode = 'EN' ;
    if ($mode_wb) { $url_base = "http://stats.wikimedia.org/wikibooks/$langcode" ; }
    if ($mode_wk) { $url_base = "http://stats.wikimedia.org/wiktionary/$langcode" ; }
    if ($mode_wn) { $url_base = "http://stats.wikimedia.org/wikinews/$langcode" ; }
    if ($mode_wo) { $url_base = "http://stats.wikimedia.org/wikivoyage/$langcode" ; }
    if ($mode_wp) { $url_base = "http://stats.wikimedia.org/$langcode" ; }
    if ($mode_wq) { $url_base = "http://stats.wikimedia.org/wikiquote/$langcode" ; }
    if ($mode_ws) { $url_base = "http://stats.wikimedia.org/wikisource/$langcode" ; }
    if ($mode_wv) { $url_base = "http://stats.wikimedia.org/wikiversity/$langcode" ; }
    if ($mode_wx) { $url_base = "http://stats.wikimedia.org/wikispecial/$langcode" ; }
  }

  $url_trends   = "$url_base/TablesWikipedia".uc($wp).".htm" ;
  $url_site_map = "$url_base/Sitemap.htm" ;

  $see_also = <<__HTML_SUMMARY_SEE_ALSO__ ;
    <tr>
      <td class=c colspan=99 width=100%>
        <table width=100%>
        <tr>
          <td class=l valign=bottom width=25>
           <a href='http://www.wikimedia.org'><img src='http://stats.wikimedia.org/WikimediaLogo.jpg' width=20></a>
          </td>
          <td class=c colspan=99>
           <hr color=#808080 width=100%>
           <font color=#808080>
           <small>
           Published $summaries_published&nbsp;&nbsp;/&nbsp;&nbsp;$out_license<br>
           <b>See Also</b>
           <a href='$url_trends'><font color=#000080>Detailed trends</font></a> for <a href='$main_page'><font color=#000080>$out_language_name $out_publication</font></a>&nbsp;&nbsp;/&nbsp;&nbsp;
           <a href='$url_site_map'><font color=#000080>Stats for all $out_publication wikis</font></a>&nbsp;&nbsp;/&nbsp;&nbsp;
           <a href='http://stats.wikimedia.org'><font color=#000080>Wikistats portal</font></a>
            </small>
           </font>
           </td>
          <td class=l valign=bottom width=25>&nbsp;</td>
         </tr>
         </table>
      </td>
    </tr>
__HTML_SUMMARY_SEE_ALSO__

$language_article = $out_article {$wp}  ;

if ($mode_wx)
{ $source_wikipedia = "" ;  }
else
{ $source_wikipedia = " / <a href='$language_article'>Wikipedia</a>" ; }

$source = <<__HTML_SUMMARY_SOURCE__ ;
    <tr>
      <td colspan=99 class=c>
      <p><i><small>Sources <a href='http://stats.wikimedia.org'>stats.wikimedia.org</a> $source_wikipedia / Published $summaries_published<br>$out_license</small></i>
      </td>
    </tr>
__HTML_SUMMARY_SOURCE__

  return ($html) ;
}

sub ReadStatisticsBinariesCommons
{
  my $file_csv_in = "$path_in/StatisticsPerBinariesExtension.csv" ;

  my (%extensions, @extensions, $extension, @counts) ;
  my ($pdf,$image,$audio_video,$scan,$other,$type,%types) ;
  my $html_binaries ;

  my $ext_documents     = qr/pdf/i ;
  my $ext_scans         = qr/djvu/i ;
  my $ext_audios_videos = qr/(?:ogg|oga|ogv|mid)/i ;
  my $ext_images        = qr/(?:jpg|jpeg|gif|tif|png|svg|bmp|xcf)/i ;

  if (! -e $file_csv_in)
  { &Abort ("Input file '$file_csv_in' not found") ; }

  print "Read '$file_csv_in'\n" ;
  open CSV_IN, '<', $file_csv_in ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    ($language,$date,$data) = split (',', $line, 3) ;

    if ($language ne "commons") { next ; }

    if ($date eq "00/0000")
    {
      @extensions = split (',', $data) ; # this line show extension names, not counts
      $field_ndx = 0 ;
      foreach $extension (@extensions)
      {
        $extensions {$field_ndx} = $extension ;

           if ($extension =~ $ext_documents)     { $type = 'pdf' ; }
        elsif ($extension =~ $ext_images)        { $type = 'image' ; }
        elsif ($extension =~ $ext_scans)         { $type = 'scan' ; }
        elsif ($extension =~ $ext_audios_videos) { $type = 'audio/video' ; }
        else                                     { $type = 'other' ; }

        if ($extension_codes {$type} ne '')
        { $extension_codes {$type} .= "/" ; }
        $extension_codes {$type} .= $extension ;

        # print "ndx $field_ndx : ext $extension\n" ;
        $field_ndx ++ ;
      }
      next ;
    }

    ($month,$year) = split ('\/', $date) ;
    my $m = &months_since_2000_01 ($year,$month) ;
    next if $m < $m_start ;

    @counts = split (',', $data) ;
    $field_ndx = 0 ;
    foreach $count (@counts)
    {
      $ext = lc ($extensions {$field_ndx}) ;

         if ($ext =~ $ext_documents)     { $type = 'pdf' ; }
      elsif ($ext =~ $ext_images)        { $type = 'image' ; }
      elsif ($ext =~ $ext_scans)         { $type = 'scan' ; }
      elsif ($ext =~ $ext_audios_videos) { $type = 'audio/video' ; }
      else                               { $type = 'other' ; }

      $ext =~ s/jpeg/jpg/ ;
      $binaries_per_month {"$m|$type"} += $count ;
      $binaries_per_month {"$m|$ext"}  += $count ;
      $field_ndx ++ ;
    }
  }
  close CSV_IN ;

  # my $m = $MonthlyStatsWpStop {$wp} ;
  # if ($month_max_incomplete)
  # { $m-- ; }
  $m = $editors_month_hi_5 {$wp} ;

  $html .= &HtmlSummaryBinaries ($m, 'image',       'Images') ;
  $html .= &HtmlSummaryBinaries ($m, 'audio/video', 'Audio/Video') ;
  $html .= &HtmlSummaryBinaries ($m, 'pdf',         'Documents') ;
  $html .= &HtmlSummaryBinaries ($m, 'scan',        'Scans') ;
  $html .= &HtmlSummaryBinaries ($m, 'other',       'Other') ;

  return ($html) ;
}

# code year,month as monthes since january 2000 (1 byte)
sub months_since_2000_01
{
  my $year  = shift ;
  my $month = shift ;
  my $m = ($year - 2000) * 12 + $month ;
  return $m ;
}

sub GeneratePlotBinaries
{
  my ($wp,$pass) = @_ ;

  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
  my @factors   = qw (0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9);

  my $wp = shift ;

  return if $wp ne 'commons' ;

# &LogT ("GeneratePlotBinaries $wp\n") ;

  my $file_csv_data_R   = $path_in . "R_PlotData_Binaries.R-data" ;
  my $file_script_R     = $path_in . "R_PlotScript_Binaries.R-in" ;
  my $path_png_raw      = "$path_out_plots\/PlotBinaries" . uc($wp) . "$pass.png" ;
  my $path_png_trends   = "$path_out_plots\/PlotBinariesTrends" . uc($wp) . "$pass.png" ;
  my $path_svg          = "$path_out_plots\/PlotBinaries" . uc($wp) . "$pass.svg" ;
  my $out_script_plot ;

  my $out_script_plot   = $out_script_plot_binaries ;

  my $out_language_name = $out_languages {$wp} ;
  my $month_plot_max    = $editors_month_hi_5 {$wp} ;

  $m = $editors_month_hi_5 {$wp} ;

  if ($pass == 1)
  { $binaries_max = $binaries_per_month {"$m|image"} ; }
  else
  {
    print $binaries_per_month {"$m|audio/video"} . "\n" ;
    print $binaries_per_month {"$m|pdf"} . "\n" ;
    print $binaries_per_month {"$m|scan"} . "\n" ;
    print $binaries_per_month {"$m|other"} . "\n" ;
    $binaries_max = $binaries_per_month {"$m|audio/video"} +
                    $binaries_per_month {"$m|pdf"} +
                    $binaries_per_month {"$m|scan"} +
                    $binaries_per_month {"$m|other"};
  }

  my $code              = uc ($wp) ;

  $file_csv_data_R      =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  open BINARIES_OUT, '>', $file_csv_data_R || &Abort ("Could not open file $file_csv_data_R") ;

  print BINARIES_OUT "language,month,count_1,count_2,count_3,count_4,count_5\n" ;

  # start in year where value exceeds 1/100 of max value

  $binaries_month_lo = &months_since_2000_01 (2004,01) ;

  $period = month_year_english_short ($binaries_month_lo) . ' ' . month_year_english_short ($editors_month_hi_5 {$wp}) ;

  for ($m = $binaries_month_lo ; $m <= $editors_month_hi_5 {$wp} ; $m++)
  {
    # make boundary not show at 2010-01-31 but at 2010-01-01 as follows:
    # instead of value for last day of month, present it as value for first day of next month
    # this requires outputting extra first value for 20xx-01-01 (to make chart start at January)
    if ($pass == 1)
    {
      $count_1 = 0 +  $binaries_per_month {"$m|image"} / 1000000 ;
      $count_2 = 0 + ($binaries_per_month {"$m|jpg"} + $binaries_per_month {"$m|jpeg"}) / 1000000 ;
      $count_3 = 0 +  $binaries_per_month {"$m|png"} / 1000000 ;
      $count_4 = 0 +  $binaries_per_month {"$m|svg"} / 1000000 ;
      $count_5 = 0 + ($binaries_per_month {"$m|image"} - $binaries_per_month  {"$m|jpg"} - $binaries_per_month  {"$m|png"} - $binaries_per_month  {"$m|svg"}) / 1000000 ;
    }
    else
    {
      $count_1 = 0 +  $binaries_per_month {"$m|audio/video"}  / 1000 ;
      $count_2 = 0 +  $binaries_per_month {"$m|pdf"}  / 1000 ;
      $count_3 = 0 +  $binaries_per_month {"$m|djvu"} / 1000 ;
      $count_4 = 0 ;
      $count_5 = 0 ;
    }

    if ($m == $binaries_month_lo)
    {
      $date = &m2mmddyyyy ($m) ;
      $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
      print BINARIES_OUT "$wp,$date,$count_1,$count_2,$count_3,$count_4,$count_5\n" ;
    }

    $date = &m2mmddyyyy ($m+1) ;
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;

    print BINARIES_OUT "$wp,$date,$count_1,$count_2,$count_3,$count_4,$count_5\n" ;
  }
  close BINARIES_OUT ;

  if ($binaries_max > 0)
  {
    # get nice rounded upper boundary for chart y axis
    $binaries_max_rounded = 10000000000000 ;

    while ($binaries_max_rounded / 10 > $binaries_max)  { $binaries_max_rounded /= 10 ; }

    foreach $factor (@factors)
    {
     if ($binaries_max_rounded * $factor > $binaries_max)
     { $binaries_max_rounded *= $factor ; last ; }
   }

    if ($pass == 1)
    { $binaries_max_rounded = sprintf ("%.0f", $binaries_max_rounded / 1000000) ; }
    else
    { $binaries_max_rounded = sprintf ("%.0f", $binaries_max_rounded / 1000) ; }
  # print "$wp binaries max $binaries_max -> binaries max rounded $binaries_max_rounded\n" ;

    $binaries_max =~ s/(\d)(\d\d\d)$/$1,$2/ ;
    $binaries_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
    $binaries_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
    $binaries_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  }
  else
  { $binaries_max = '10' ; }

  # edit plot parameters

  if ($wp eq 'zz')
  { $out_script_plot =~ s/TITLE/Images on all $out_publication wikis (x 1,000,000)/g ; }
  elsif ($mode_wx)
  { $out_script_plot =~ s/TITLE/Images on $out_language_name wiki (x 1,000,000)/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Images on LANGUAGE $out_publication (x 1,000,000)/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
    $out_script_plot =~ s/CODE/$code/g ;
  }

  if ($pass == 2)
  {
    $out_script_plot =~ s/Images/Other Binaries/g;
    $out_script_plot =~ s/1,000,000/1000/g;
  }

  $mmddyyyy = &m2mmddyyyy ($month_plot_max) ;
  $month_plot_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_data_R/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;
  $out_script_plot =~ s/CODE/$code/g ;

  $out_script_plot =~ s/COL_DATA/2:7/g ;
  $out_script_plot =~ s/COL_COUNTS/2:6/g ;

  if ($pass == 1)
  { $out_script_plot =~ s/MAX_VALUE/max images/ ; }
  else
  { $out_script_plot =~ s/MAX_VALUE/max other binaries/ ; }

  $out_script_plot =~ s/MAX_METRIC/binaries/g ;
  $out_script_plot =~ s/MAX_MONTH/$month_plot_max/g ;
  $out_script_plot =~ s/MAX_VALUE/$binaries_max/g ;
  $out_script_plot =~ s/YLIM_MAX/$binaries_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  if ($pass == 1)
  {
    $out_script_plot =~ s/LABEL_1/All images/g ;
    $out_script_plot =~ s/LABEL_2/Jpg/g ;
    $out_script_plot =~ s/LABEL_3/Png/g ;
    $out_script_plot =~ s/LABEL_4/Svg/g ;
    $out_script_plot =~ s/LABEL_5//g ; # no enough to stand out from x axis yet
  # $out_script_plot =~ s/LABEL_5/Other images/g ;
  }
  else
  {
    $out_script_plot =~ s/LABEL_1/Audio\/Video (ogg\/oga\/ogv\/mid)/g ;
    $out_script_plot =~ s/LABEL_2/Doc's (pdf)/g ;
    $out_script_plot =~ s/LABEL_3/Scans (djvu)/g ;
    $out_script_plot =~ s/LABEL_4//g ;
    $out_script_plot =~ s/LABEL_5//g ;
  }

  if ($pass == 1)
  {
    $out_script_plot =~ s/COLOR_1/orange/g ;
    $out_script_plot =~ s/COLOR_2/darkorange4/g ;
    $out_script_plot =~ s/COLOR_3/olivedrab4/g ;
    $out_script_plot =~ s/COLOR_4/mediumpurple4/g ;
    $out_script_plot =~ s/COLOR_5/#E0E0E0/g ;
  }
  else
  {
    $out_script_plot =~ s/COLOR_1/orange/g ;
    $out_script_plot =~ s/COLOR_2/darkorange4/g ;
    $out_script_plot =~ s/COLOR_3/olivedrab4/g ;
    $out_script_plot =~ s/COLOR_4/#E0E0E0/g ; # background color
    $out_script_plot =~ s/COLOR_5/#E0E0E0/g ;
  }

  &GeneratePlotCallR ($out_script_plot, $file_script_R) ;
}

sub GeneratePlotEditors
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;

# &LogT ("GeneratePlotEditors $wp\n") ;

  my $file_csv_data_R   = $path_in . "R_PlotData_Editors.R-data" ;
  my $file_script_R     = $path_in . "R_PlotScript_Editors.R-in" ;
  my $path_png_raw      = "$path_out_plots\/PlotEditors" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotEditorsTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotEditors" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_editors ;
  my $out_language_name = $out_languages {$wp} ;
  my $editors_max       = $editors_max_5 {$wp} ;
  my $month_plot_max    = $editors_month_max_5 {$wp} ;
  my $code              = uc ($wp) ;

  if ($month_plot_max == 0)
  { print "$wp: \$month_max = \$editors_month_max_5 \{\$wp\} <- == 0\n" ; return ; }
  $file_csv_data_R      =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  open EDITORS_OUT, '>', $file_csv_data_R || &Abort ("Could not open file $file_csv_data_R") ;
  print EDITORS_OUT "language,month,count_5,count_25,count_100\n" ;

  # start in year where value exceeds 1/100 of max value

  for ($m = $editors_month_lo_5 {$wp} ; $m < $editors_month_hi_5 {$wp} ; $m++)
  { last if $editors_5 {$wp.$m} >= $editors_max / 100 ; }
  $editors_month_lo_5_100th = $m - $m % 12 + 1 ;

  $period = month_year_english_short ($editors_month_lo_5_100th) . ' ' . month_year_english_short ($editors_month_hi_5 {$wp}) ;

  for ($m = $editors_month_lo_5_100th ; $m <= $editors_month_hi_5 {$wp} ; $m++)
  {
    # make boundary not show at 2010-01-31 but at 2010-01-01 as follows:
    # instead of value for last day of month, present it as value for first day of next month
    # this requires outputting extra first value for 20xx-01-01 (to make chart start at January)
    $count_5   = 0 + $editors_5   {$wp.$m} ;
    $count_25  = 0 + $editors_25  {$wp.$m} ;
    $count_100 = 0 + $editors_100 {$wp.$m} ;

    if ($m == $editors_month_lo_5_100th)
    {
      $date = &m2mmddyyyy ($m) ;
      $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
      print EDITORS_OUT "$wp,$date,$count_5,$count_25,$count_100\n" ;
    }

    $date = &m2mmddyyyy ($m+1) ;
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
    print EDITORS_OUT "$wp,$date,$count_5,$count_25,$count_100\n" ;
  }
  close EDITORS_OUT ;

  if ($editors_max > 0)
  {
    # get nice rounded upper boundary for chart y axis
    $editors_max_rounded = 10000000000000 ;
    while ($editors_max_rounded / 10 > $editors_max)  { $editors_max_rounded /= 10 ; }

       if ($editors_max_rounded * 0.15 > $editors_max) { $editors_max_rounded *= 0.15 ; }
    elsif ($editors_max_rounded * 0.2 > $editors_max) { $editors_max_rounded *= 0.2 ; }
    elsif ($editors_max_rounded * 0.4 > $editors_max) { $editors_max_rounded *= 0.4 ; }
    elsif ($editors_max_rounded * 0.6 > $editors_max) { $editors_max_rounded *= 0.6 ; }
    elsif ($editors_max_rounded * 0.8 > $editors_max) { $editors_max_rounded *= 0.8 ; }
  # print "$wp editors max $editors_max -> editors max rounded $editors_max_rounded\n" ;

    $editors_max =~ s/(\d)(\d\d\d)$/$1,$2/ ;
    $editors_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
    $editors_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
    $editors_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  }
  else
  { $editors_max = '10' ; }

  # edit plot parameters

  if ($wp eq 'zz')
  { $out_script_plot =~ s/TITLE/Active Editors on all $out_publication wikis/g ; }
  elsif ($mode_wx)
  { $out_script_plot =~ s/TITLE/Active Editors on $out_language_name wiki/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Active Editors on LANGUAGE $out_publication/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
    $out_script_plot =~ s/CODE/$code/g ;
  }

  $mmddyyyy = &m2mmddyyyy ($month_plot_max) ;
  $month_plot_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_data_R/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;

  $out_script_plot =~ s/COL_DATA/2:5/g ;
  $out_script_plot =~ s/COL_COUNTS/2:4/g ;

  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_METRIC/editors (5+ edits) in/ ;
  $out_script_plot =~ s/MAX_MONTH/$month_plot_max/g ;
  $out_script_plot =~ s/MAX_VALUE/$editors_max/g ;
  $out_script_plot =~ s/YLIM_MAX/$editors_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  $out_script_plot =~ s/COLOR_5/violetred2/g ;
  $out_script_plot =~ s/COLOR_25/purple2/g ;
  $out_script_plot =~ s/COLOR_100/dodgerblue2/g ;

  if ($mode_wo)
  { 
    $out_script_plot =~ s/PLOT_FOOTER_COLOR/#808080/ ;
    $out_script_plot =~ s/PLOT_FOOTER/Jan 2013 Wikivoyage became a new Wikimedia project. Earlier content was added at Wikitravel./ ; 
  }
  elsif ($wp eq 'commons')
  {
    $out_script_plot =~ s/PLOT_FOOTER_COLOR/#808080/ ;
    $out_script_plot =~ s/PLOT_FOOTER/Peaks in editors are from photo contests, mainly Wiki Loves Monuments (Sep 2011-..), Wiki Loves Earth (2014-..)/ ;
  }
  else
  {
    $out_script_plot =~ s/PLOT_FOOTER_COLOR/#808080/ ;
    $out_script_plot =~ s/PLOT_FOOTER// ; 
  }

  &GeneratePlotCallR ($out_script_plot, $file_script_R) ;
}

sub GeneratePlotActiveWikis
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;

  &LogT ("GeneratePlotActiveWikis $wp\n") ;

  my $file_csv_data_R   = $path_in . "R_PlotData_ActiveWikis.R-data" ;
  my $file_script_R     = $path_in . "R_PlotScript_ActiveWikis.R-in" ;
  my $path_png_raw      = "$path_out_plots\/PlotActivity" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotActivity" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotActivity" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_active_wikis ;
  my $out_language_name = $out_languages {$wp} ;
  my $month_plot_max    = $active_wikis_month_max_3 ;
  my $code              = uc ($wp) ;

  if ($month_plot_max == 0)
  { print "$wp: \$month_max = \$editors_month_max_5 \{\$wp\} <- == 0\n" ; return ; }

  $file_csv_data_R      =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  $active_wikis_max = $active_wikis_max_1 ;
  if ($active_wikis_max > 0)
  {
    # get nice rounded upper boundary for chart y axis
    $active_wikis_max_rounded = 10000000000000 ;
    while ($active_wikis_max_rounded / 10 > $active_wikis_max)  { $active_wikis_max_rounded /= 10 ; }

       if ($active_wikis_max_rounded * 0.15 > $active_wikis_max) { $active_wikis_max_rounded *= 0.15 ; }
    elsif ($active_wikis_max_rounded * 0.2 > $active_wikis_max) { $active_wikis_max_rounded *= 0.2 ; }
    elsif ($active_wikis_max_rounded * 0.25 > $active_wikis_max) { $active_wikis_max_rounded *= 0.25 ; }
    elsif ($active_wikis_max_rounded * 0.3 > $active_wikis_max) { $active_wikis_max_rounded *= 0.3 ; }
    elsif ($active_wikis_max_rounded * 0.4 > $active_wikis_max) { $active_wikis_max_rounded *= 0.4 ; }
    elsif ($active_wikis_max_rounded * 0.5 > $active_wikis_max) { $active_wikis_max_rounded *= 0.5 ; }
    elsif ($active_wikis_max_rounded * 0.6 > $active_wikis_max) { $active_wikis_max_rounded *= 0.6 ; }
    elsif ($active_wikis_max_rounded * 0.8 > $active_wikis_max) { $active_wikis_max_rounded *= 0.8 ; }
  # print "$wp editors max $editors_max -> editors max rounded $editors_max_rounded\n" ;

    $active_wikis_max =~ s/(\d)(\d\d\d)$/$1,$2/ ;
    $active_wikis_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
    $active_wikis_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
    $active_wikis_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  }
  else
  { $editors_max = '10' ; }

  # edit plot parameters
  open ACTIVITY_OUT, '>', $file_csv_data_R || &Abort ("Could not open file $file_csv_data_R") ;
  print ACTIVITY_OUT "language,month,count_1,count_3,count_5\n" ;

  # start in year where value exceeds 1/100 of max value

  for ($m = $editors_month_lo_5 {$wp} ; $m < $editors_month_hi_5 {$wp} ; $m++)
  { last if $editors_5 {$wp.$m} >= $editors_max / 100 ; }
  $editors_month_lo_5_100th = $m - $m % 12 + 1 ;

  $period = month_year_english_short ($editors_month_lo_5_100th) . ' ' . month_year_english_short ($editors_month_hi_5 {$wp}) ;

  for ($m = $editors_month_lo_5_100th ; $m <= $editors_month_hi_5 {$wp} ; $m++)
  {
    # make boundary not show at 2010-01-31 but at 2010-01-01 as follows:
    # instead of value for last day of month, present it as value for first day of next month
    # this requires outputting extra first value for 20xx-01-01 (to make chart start at January)
    $count_1 = $wikis_with_editors_with_at_least_x_edits {"$m.1"} ++ ;  
    $count_3 = $wikis_with_editors_with_at_least_x_edits {"$m.3"} ++ ; 
    $count_5 = $wikis_with_editors_with_at_least_x_edits {"$m.5"} ++ ;

    if ($m == $editors_month_lo_5_100th)
    {
      $date = &m2mmddyyyy ($m) ;
      $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
      print ACTIVITY_OUT "zz,$date,$count_1,$count_3,$count_5\n" ;
    # print              "zz,$date,$count_1,$count_3,$count_5\n" ; 
    }

    $date = &m2mmddyyyy ($m+1) ;
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
    print ACTIVITY_OUT "zz,$date,$count_1,$count_3,$count_5\n" ;
  # print              "zz,$date,$count_1,$count_3,$count_5\n" ; 
  }
  close ACTIVITY_OUT ;

  # edit plot parameters

  $out_script_plot =~ s/TITLE/Active $out_publication wikis (3+ active editors)/g ; 

  $mmddyyyy = &m2mmddyyyy ($month_plot_max) ;
  $month_plot_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_data_R/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;

# $out_script_plot =~ s/COL_DATA/2:7/g ;
  $out_script_plot =~ s/COL_DATA/2:5/g ;
  $out_script_plot =~ s/COL_COUNTS/2:4/g ;

  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_METRIC/active wikis/ ;
  $out_script_plot =~ s/MAX_MONTH/$month_plot_max/g ;
  $out_script_plot =~ s/MAX_VALUE/$active_wikis_max_3/g ;
  $out_script_plot =~ s/YLIM_MAX/$active_wikis_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  $out_script_plot =~ s/COLOR_1/gold2/g ;
  $out_script_plot =~ s/COLOR_3/violetred2/g ;
  $out_script_plot =~ s/COLOR_5/dodgerblue/g ;

  $out_script_plot =~ s/LABEL_1/1+ active editors/g ;
  $out_script_plot =~ s/LABEL_3/3+ active editors/g ;
  $out_script_plot =~ s/LABEL_5/5+ active editors/g ;

  &GeneratePlotCallR ($out_script_plot, $file_script_R) ;
}

# plot normalized (= all months are 30 days) page views from $pageviews {$wp.$m} ($wp=language code, $m=month ndx)
# which is hash filled in WikiReportsInput.pm from $file_csv_pageviewsmonthly = $path_in . "projectviews_per_month_all.csv" # was "PageViewsPerMonthAll.csv"
# which contains for every wiki in the project (e.g. in ../csv_wp for Wikipedia):
# one line per month for non-mobile (since Jan 2008 for Wikipedia, some months later for other projects) 
# and one line per month for mobile (since June 2010)
# format: 'xx,yyyy/mm/dd,count' where xx is language code, (+ postfix .m for mobile)
# e.g. 
# en,2013/12/31,6758017229 
# en.m,2013/12/31,2053305507
 
sub GeneratePlotPageviews
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;
  $wp =~ s/_/-/g ;

 &LogT ("GeneratePlotPageviews $wp\n") ;

  if ($pageviews_max {$wp} == 0)
  { print "\nNo pageviews found for wiki $wp!\n\n" ; return ; }

  my $file_csv_data_R   = $path_in . "R_PlotData_PageViews.R-data" ;
  my $file_script_R     = $path_in . "R_PlotScript_Pageviews.R-in" ;
  my $path_png_raw      = "$path_out_plots\/PlotPageviews" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotPageviewsTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotPageviews" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_pageviews ;
  my $out_language_name = $out_languages {$wp} ;
  my $pageviews_max     = $pageviews_max {$wp} ;
  my $month_plot_max    = $pageviews_month_max {$wp} ;

  return if $month_plot_max == 0 ; # Q&D temp fix

  my $code              = uc ($wp) ;
  $file_csv_data_R      =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  open PAGEVIEWS_OUT, '>', $file_csv_data_R || &Abort ("Could not open file $file_csv_data_R") ;
  print PAGEVIEWS_OUT "language,month,count_normalized_non_mobile_old_def,count_normalized_non_mobile_new_def,count_normalized_mobile_old_def,count_normalized_mobile_new_def,count_normalized_total_old_def,count_normalized_total_new_def\n" ;

  ($metric_max, $metric_max_rounded, $metric_unit, $metric_unit_text1, $metric_unit_text2) = &SummaryUnitAndScale ($pageviews_max) ;

  $period = month_year_english_short ($pageviews_month_lo {$wp}) . ' ' . month_year_english_short ($pageviews_month_hi {$wp}-1) ;

  $pageviews_month_lo = $pageviews_month_lo {$wp} - $pageviews_month_lo {$wp} % 12 ; # always start in January, to align x axis properly

  $pageviews_month_hi = $pageviews_month_hi {$wp} ;

# add code to suppres mobile counts when less than 0.1 of total
  $show_non_mobile_only = $false ;  
  $count_normalized_mobile_hi             = sprintf ("%.0f", $pageviews {"$wp.m".$pageviews_month_hi} / $metric_unit) ; 
  $count_normalized_non_mobile_new_def_hi = sprintf ("%.0f", $pageviews {$wp.$pageviews_month_hi} / $metric_unit) ;
  if ($count_normalized_mobile_hi < 0.2 * $count_normalized_non_mobile_new_def_hi)
  { $show_non_mobile_only = $true ; } 

  for ($m = $pageviews_month_lo ; $m < $pageviews_month_hi {$wp} ; $m++)
  {
    if ($m < $pageviews_month_lo {$wp})
    { 
      $count_normalized_non_mobile_old_def = "" ; 
      $count_normalized_non_mobile_new_def = "" ; 
      $count_normalized_mobile_old_def     = "" ; 
      $count_normalized_mobile_new_def     = "" ; 
      $count_normalized_total_old_def      = "" ; 
      $count_normalized_total_new_def      = "" ; 
    }
    else
    { 
      if ($m >= 185) # months since Jan 2000, 184 = April 2015
      {
        $count_normalized_non_mobile_new_def = &blank_zero (sprintf ("%.0f", $pageviews {$wp.$m} / $metric_unit)) ; 
        $count_normalized_non_mobile_old_def = "" ;
        $count_normalized_mobile_new_def     = &blank_zero (sprintf ("%.0f", $pageviews {"$wp.m".$m} / $metric_unit)) ; 
        $count_normalized_mobile_old_def     = "" ;
        $count_normalized_total_new_def      = &blank_zero ($count_normalized_non_mobile_old_def + $count_normalized_non_mobile_new_def + $count_normalized_mobile_old_def + $count_normalized_mobile_new_def) ;
        $count_normalized_total_old_def      = "" ;
      }
      else
      {
        $count_normalized_non_mobile_old_def = &blank_zero (sprintf ("%.0f", $pageviews {$wp.$m} / $metric_unit)) ; 
        $count_normalized_non_mobile_new_def = "" ;
        $count_normalized_mobile_old_def     = &blank_zero (sprintf ("%.0f", $pageviews {"$wp.m".$m} / $metric_unit)) ; 
        $count_normalized_mobile_new_def     = "" ;
        $count_normalized_total_old_def      = &blank_zero ($count_normalized_non_mobile_old_def + $count_normalized_non_mobile_new_def + $count_normalized_mobile_old_def + $count_normalized_mobile_new_def) ;
        $count_normalized_total_new_def      = "" ;
      }

      # suppress parts of black line (total) where almost similar to green line (main old or new)
      if ($count_normalized_total_old_def + $count_normalized_total_new_def < 1.05 * ($count_normalized_non_mobile_old_def + $count_normalized_non_mobile_new_def))
      { 
        $count_normalized_total_old_def = "" ; 
        $count_normalized_total_new_def = "" ; 
      }
      
      if ($show_non_mobile_only)
      {
        $count_normalized_mobile_old_def = "" ;
        $count_normalized_mobile_new_def = "" ;
        $count_normalized_total_old_def  = "" ;         
        $count_normalized_total_new_def  = "" ;         
      }  
    }

    # $days_in_month =  days_in_month (substr($date,6,4),substr($date,0,2)) ;
    # $count_normalized = sprintf ("%.0f", 30/$days_in_month * $count) ;

    # make boundary not show at 2010-01-31 but at 2010-01-01 as follows:
    # instead of value for last day of month, present it as value for first day of next month
    # this requires outputting extra first value for 20xx-01-01 (to make chart start at January)

    if ($m == $pageviews_month_lo {$wp})
    {
      $date = &m2mmddyyyy ($m) ;
      $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
      print PAGEVIEWS_OUT "$wp,$date,$count_normalized_non_mobile_old_def,$count_normalized_non_mobile_new_def,$count_normalized_mobile_old_def,$count_normalized_mobile_new_def,$count_normalized_total_old_def,$count_normalized_total_new_def\n" ;
    }

    $date = &m2mmddyyyy ($m+1) ;
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
    print PAGEVIEWS_OUT "$wp,$date,$count_normalized_non_mobile_old_def,$count_normalized_non_mobile_new_def,$count_normalized_mobile_old_def,$count_normalized_mobile_new_def,$count_normalized_total_old_def,$count_normalized_total_new_def\n" ;
  # print "$wp,$date,$count_normalized_non_mobile_old_def,$count_normalized_non_mobile_new_def,$count_normalized_mobile_old_def,$count_normalized_mobile_new_def,,$count_normalized_total\n" ; # 

  }
  close PAGEVIEWS_OUT ;

  # edit plot parameters

  if ($wp eq 'zz')
  { $out_script_plot =~ s/TITLE/Page Views on all $out_publication wikis$metric_unit_text1/g ; }
  elsif ($mode_wx)
  { $out_script_plot =~ s/TITLE/Page Views on $out_language_name wiki$metric_unit_text1/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Page Views on LANGUAGE $out_publication$metric_unit_text1/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
    $out_script_plot =~ s/CODE/$code/g ;
  }

  # patch legend, remove two empty lines
  if ($show_non_mobile_only)
  { $out_script_plot =~ s/\, \"mobile \"\, \"total \"// ; }

  $mmddyyyy = &m2mmddyyyy ($month_plot_max) ;
  $month_plot_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_data_R/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;

  $out_script_plot =~ s/COL_DATA/2:8/g ;
  $out_script_plot =~ s/COL_COUNTS/2:7/g ;

  $out_script_plot =~ s/CODE/$code/g ;

  $out_script_plot =~ s/MAX_METRIC/page views/g ;
  $out_script_plot =~ s/MAX_MONTH/$month_plot_max/g ;
  $out_script_plot =~ s/MAX_VALUE/$metric_max$metric_unit_text2/g ;
  $out_script_plot =~ s/YLIM_MAX/$metric_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/UNIT/$metric_unit_text/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  $out_script_plot =~ s/COLOR_NON_MOBILE_OLD_DEF/green4/g ; 
  $out_script_plot =~ s/COLOR_NON_MOBILE_NEW_DEF/green4/g ; 
  $out_script_plot =~ s/COLOR_MOBILE_OLD_DEF/blue/g ;
  $out_script_plot =~ s/COLOR_MOBILE_NEW_DEF/blue/g ;
  $out_script_plot =~ s/COLOR_TOTAL_OLD_DEF/black/g ;
  $out_script_plot =~ s/COLOR_TOTAL_NEW_DEF/black/g ;
  &GeneratePlotCallR ($out_script_plot, $file_script_R) ;
}

sub GeneratePlotUploads
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;

  return if $wp =~ /^z+$/ ;

  &LogT ("GeneratePlotUploads $wp\n") ;

  my $file_csv_data_R   = $path_in . "R_PlotData_Uploads.R-data" ;
  my $file_script_R     = $path_in . "R_PlotScript_Uploads.R-in" ;
  my $file_csv_data_in  = $path_in . "UserActivityTrendsUploadWizardCOMMONS.csv" ;
  my $path_png_raw      = "$path_out_plots\/PlotUploads" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotUploadsTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotUploads" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_uploads ;
  my $out_language_name = $out_languages {$wp} ;

# return if $month_plot_max == 0 ; # Q&D temp fix

  my $code              = uc ($wp) ;
  $file_csv_data_R      =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  $m_stop = $MonthlyStatsWpStop {$wp} ;

  if ($call_ignore_input_beyond_month++ == 0)
  { &Log ("\nIgnore input beyond month $m_stop: " . &month_year_english_short ($m_stop) . "\n\n") ; }

  $uploads_max = 0 ;
  $month_plot_max = 1 ;
  $m_lo = 999 ;
  $m_hi = 0 ;
  open UPLOADS_IN,  '<', $file_csv_data_in || &Abort ("Could not open file $file_csv_data_R") ;
  while ($line = <UPLOADS_IN>)
  {
    next if $line !~ /^\d\d\d\d-\d\d,/ ;
    chomp $line ;
    ($date,$uploads,$uploads_bot,$uploads_manual,$upload_wizards) = split (',', $line) ;

    $m = ord (&yyyymm2b (substr ($date,0,4),substr ($date,5,2))) ;
    next if $m > $m_stop ;

    if ($m_lo  > $m) { $m_lo = $m ; }
    if ($m_hi  < $m) { $m_hi = $m ; }

    if ($uploads > $uploads_max)
    {
      $uploads_max = $uploads ;
      $month_plot_max = $m ;
    }
  }
  close UPLOADS_OUT ;

  ($metric_max, $metric_max_rounded, $metric_unit, $metric_unit_text1, $metric_unit_text2) = &SummaryUnitAndScale ($uploads_max) ;

  open UPLOADS_OUT, '>', $file_csv_data_R || &Abort ("Could not open file $file_csv_data_R") ;
  print UPLOADS_OUT "language,month,uploads_tot,uploads_bot,uploads_manual,uploads_wizard\n" ;


  for ($m = $m_lo - ($m_lo % 12), $m < $m_lo, $m++)
  {
    $date = &m2mmddyyyy ($m) ;
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
    print UPLOADS_OUT "$wp,$date,0,0,0\n" ;
  }

  $period = month_year_english_short ($m_lo - ($m_lo % 12 - 1)) . ' ' . month_year_english_short ($m_hi) ; # always start in January

  open UPLOADS_IN,  '<', $file_csv_data_in || &Abort ("Could not open file $file_csv_data_in") ;
  while ($line = <UPLOADS_IN>)
  {
    next if $line !~ /^\d\d\d\d-\d\d,/ ;
    chomp $line ;
    ($date,$uploads,$uploads_bot,$uploads_manual,$uploads_wizard) = split (',', $line) ;

    $m = ord (&yyyymm2b (substr ($date,0,4),substr ($date,5,2))) ;
    next if $m > $m_stop ;

    $date = &m2mmdimyyyy ($m) ;
    print UPLOADS_OUT "$wp,$date," . sprintf ("%.0f", $uploads/$metric_unit) . "," . sprintf ("%.0f", ($uploads-$uploads_manual)/$metric_unit) . "," . sprintf ("%.0f", $uploads_manual/$metric_unit) . "," . sprintf ("%.0f", $uploads_wizard/$metric_unit) . "\n" ;
  }
  close UPLOADS_OUT ;
  # edit plot parameters

  $out_script_plot =~ s/TITLE/File uploads on $out_language_name wiki$metric_unit_text1/g ;

  $mmddyyyy = &m2mmddyyyy ($month_plot_max) ;
  $month_plot_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_data_R/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;

  $out_script_plot =~ s/COL_DATA/2:6/g ;
  $out_script_plot =~ s/COL_COUNTS/2:5/g ;

  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_METRIC/uploads/g ;
  $out_script_plot =~ s/MAX_MONTH/$month_plot_max/g ;
  $out_script_plot =~ s/MAX_VALUE/$metric_max$metric_unit_text2/g ;
  $out_script_plot =~ s/YLIM_MAX/$metric_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/UNIT/$metric/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  &GeneratePlotCallR ($out_script_plot, $file_script_R) ;
}

sub GeneratePlotUploaders
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;

  return if $wp =~ /^z+$/ ;

  # &LogT ("GeneratePlotUploaders $wp\n") ;

  my $file_csv_data_R   = $path_in . "R_PlotData_Uploaders.R-data" ;
  my $file_script_R     = $path_in . "R_PlotScript_Uploaders.R-in" ;
  my $file_csv_data_in  = $file_csv_uploaders ;
  my $path_png_raw      = "$path_out_plots\/PlotUploaders" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotUploadersTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotUploaders" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_uploaders ;
  my $out_language_name = $out_languages {$wp} ;

# return if $month_plot_max == 0 ; # Q&D temp fix

  my $code              = uc ($wp) ;

  $file_csv_data_R       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  $uploaders_max = 0 ;
  $month_plot_max = 1 ;
  $m_lo = 999 ;
  $m_hi = 0 ;

  $m_stop = $MonthlyStatsWpStop {$wp} ;

  if ($call_ignore_input_beyond_month++ == 0)
  { &Log ("\nIgnore input beyond month $m_stop: " . &month_year_english_short ($m_stop) . "\n\n") ; }

  open UPLOADERS_IN,  '<', $file_csv_data_in || &Abort ("Could not open file $file_csv_data_in") ;
  while ($line = <UPLOADERS_IN>)
  {
    next if $line !~ /^$wp/ ;
    chomp $line ;
    ($lang,$date,$uploaders_ge_1) = split (',', $line) ;

    $m = ord (&yyyymm2b (substr ($date,6,4),substr ($date,0,2))) ;
    next if $m > $m_stop ;

    if ($m_lo  > $m) { $m_lo = $m ; }
    if ($m_hi  < $m) { $m_hi = $m ; }

    if ($uploaders_ge_1 > $uploaders_max)
    {
      $uploaders_max = $uploaders_ge_1 ;
      $month_plot_max = $m ;
    }
  }
  close UPLOADERS_IN ;

  open  UPLOADERS_OUT, '>', $file_csv_data_R || &Abort ("Could not open file $file_csv_data_R") ;
  print UPLOADERS_OUT "language,month,uploaders_ge_1,uploaders_ge_5,uploaders_ge_25,uploaders_ge_100,uploaders_wizard_ge_1\n" ;

  ($metric_max, $metric_max_rounded, $metric_unit, $metric_unit_text1, $metric_unit_text2) = &SummaryUnitAndScale ($uploaders_max) ;

  for ($m = $m_lo - ($m_lo % 12), $m < $m_lo, $m++)
  {
    $date = &m2mmddyyyy ($m) ;
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
    print UPLOADERS_OUT "$wp,$date,0,0,0,0,0\n" ;
  }

  $period = month_year_english_short ($m_lo - ($m_lo % 12 - 1)) . ' ' . month_year_english_short ($m_hi) ; # always start in January

  open UPLOADERS_IN,  '<', $file_csv_data_in || &Abort ("Could not open file $file_csv_data_R") ;
  while ($line = <UPLOADERS_IN>)
  {
    next if $line !~ /^commons/ ;
    chomp $line ;
    ($lang,$date,$uploaders_ge_1,$uploaders_ge_3,$uploaders_ge_5,$uploaders_ge_10,$uploaders_ge_25,$uploaders_ge_100,$rest) = split (',', $line,9) ;
    $rest =~ s/^.*?\d\d\/\d\d\/\d\d\d\d,// ;
    ($uploaders_wizard_ge_1) = split (',', $rest,9) ;

    $m = ord (&yyyymm2b (substr ($date,6,4),substr ($date,0,2))) ;
    next if $m > $m_stop ;

    $date = &m2mmdimyyyy ($m) ;
    print UPLOADERS_OUT "$wp,$date," . sprintf ("%.0f", $uploaders_ge_1/$metric_unit) . "," . sprintf ("%.0f", $uploaders_ge_5/$metric_unit) . "," . sprintf ("%.0f", $uploaders_ge_25/$metric_unit) . "," . sprintf ("%.0f", $uploaders_ge_100/$metric_unit) .  "," . sprintf ("%.0f", $uploaders_wizard_ge_1/$metric_unit) . "\n" ;
  }
  close UPLOADERS_IN ;

  # edit plot parameters

  $out_script_plot =~ s/TITLE/File uploaders on $out_language_name wiki$metric_unit_text1/g ;

  $mmddyyyy = &m2mmddyyyy ($month_plot_max) ;
  $month_plot_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_data_R/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;

  $out_script_plot =~ s/COL_DATA/2:7/g ;
  $out_script_plot =~ s/COL_COUNTS/2:6/g ;

  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_METRIC/uploaders/g ;
  $out_script_plot =~ s/MAX_MONTH/$month_plot_max/g ;
  $out_script_plot =~ s/MAX_VALUE/$metric_max$metric_unit_text2/g ;
  $out_script_plot =~ s/YLIM_MAX/$metric_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/UNIT/$metric_unit_text/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  $out_script_plot =~ s/COLOR_100/dodgerblue2/g ;
  $out_script_plot =~ s/COLOR_W1/orange/g ;
  $out_script_plot =~ s/COLOR_1/green4/g ;
  $out_script_plot =~ s/COLOR_5/violetred2/g ;
  $out_script_plot =~ s/COLOR_25/purple2/g ;

  &GeneratePlotCallR ($out_script_plot, $file_script_R) ;
}

sub GeneratePlotArticles
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my ($wp,$tot_or_new) = @_ ;

# return if $wp ne 'am' ; # qqq debug

  $tot_or_new_lc = lc $tot_or_new ;

# return if $wp =~ /^z+$/ ;

  # &LogT ("GeneratePlotArticles $wp $tot_or_new\n") ;

  my $file_csv_data_R   = $path_in . "R_PlotData_"   . $tot_or_new . "Articles.R-data" ;
  my $file_script_R     = $path_in . "R_PlotScript_" . $tot_or_new . "Articles.R-in" ;
  my $file_csv_data_in  = $file_csv_monthly_stats ;

  my $path_png_raw      = "$path_out_plots\/Plot" . $tot_or_new . "Articles"       . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/Plot" . $tot_or_new . "ArticlesTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/Plot" . $tot_or_new . "Articles"       . uc($wp) . ".svg" ;

  my $out_script_plot   = $out_script_plot_articles ;
  my $out_language_name = $out_languages {$wp} ;

  # return if $month_plot_max == 0 ; # Q&D temp fix

  my $code              = uc ($wp) ;

  $file_csv_data_R      =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  $articles_max = 0 ;
  $articles_max_per_usertype = 0 ;
  $month_plot_max = 1 ;
  $m_lo = 999 ;
  $m_hi = 0 ;
 
  $m_stop = $MonthlyStatsWpStop {$wp} ;
  if ($call_ignore_input_beyond_month++ == 0)
  { &Log ("\nIgnore input beyond month $m_stop: " . &month_year_english_short ($m_stop) . "\n\n") ; }

  $articles = 0 ;
  $articles_per_usertype = 0 ;
  $tot_articles_prev = 0 ;

  &ReadFileCsv ($file_csv_monthly_stats, $wp) ;

  foreach $line (@csv)
  {
    chomp $line ;
    ($lang,$date,$tot_contributors,$new_contributors,$editors_ge5,$editors_ge100,$tot_articles,$alt_articles,$new_articles_per_day,
     $mean_versions,$mean_bytes,$over_size1,$over_size2,$edits_per_month,
     $tot_bytes,$tot_words,$tot_links,$tot_links_wiki,$tot_links_images,$tot_links_external,$tot_redirects,$tot_categorized,$pages_without_internal_link,
     $edits_per_month_reg,$edits_per_month_anon,$edits_per_month_bot,
     $new_articles_per_month_reg,$new_articles_per_month_anon,$new_articles_per_month_bot) = split (',', $line) ;

    $new_articles_per_usertype += $new_articles_per_month_reg + $new_articles_per_month_anon + $new_articles_per_month_bot ;

    $m = ord (&yyyymm2b (substr ($date,6,4),substr ($date,0,2))) ;
    next if $m > $m_stop ;

    if ($m_lo  > $m) { $m_lo = $m ; }
    if ($m_hi  < $m) { $m_hi = $m ; }

    if ($tot_or_new eq 'New')
    { $articles = $tot_articles - $tot_articles_prev ; }
    else
    { $articles = $tot_articles ; }

    if ($articles > $articles_max)
    {
      $articles_max = $articles ;
      $month_plot_max = $m ;
    }

    if ($tot_or_new eq 'New')
    {
      if ($articles_max_per_usertype < $new_articles_per_month_reg)
      { $articles_max_per_usertype = $new_articles_per_month_reg ; }
      if ($articles_max_per_usertype < $new_articles_per_month_anon)
      { $articles_max_per_usertype = $new_articles_per_month_anon ; }
      if ($articles_max_per_usertype < $new_articles_per_month_bot)
      { $articles_max_per_usertype = $new_articles_per_month_bot ; }
    }

    $tot_articles_prev = $tot_articles ;
  }

  if ($tot_or_new eq 'New')
  {
    # no new refined counts available ?
    if ($articles_max_per_usertype == 0)
    { print "No metrics found for new articles per month per usertype for language $wp -> skip plot.\n\n" ; return ; }
  }

  open  ARTICLES_OUT, '>', $file_csv_data_R || &Abort ("Could not open file $file_csv_data_R") ;

  if (($tot_or_new eq 'New') && ($new_articles_per_usertype > 0)) # new refined counts available ?
  { print ARTICLES_OUT "language,month,articles_reg,articles_anon,articles_bot\n" ; }
  else
  { print ARTICLES_OUT "language,month,articles\n" ; }

  if ($tot_or_new eq 'New')
  { ($metric_max, $metric_max_rounded_usertype, $metric_unit, $metric_unit_text1, $metric_unit_text2) = &SummaryUnitAndScale ($articles_max_per_usertype) ; }
  else
  { ($metric_max, $metric_max_rounded,          $metric_unit, $metric_unit_text1, $metric_unit_text2) = &SummaryUnitAndScale ($articles_max) ; }


  $m = $m_lo - 11 + $m_lo % 12 ;
  $date = &m2mmddyyyy ($m) ;
 print "1 date: $date m_lo: $m_lo, m: $m\n" ; # debug code
  while ($m < $m_lo)
  {
# for ($m = $m_lo - ($m_lo % 12) + 1 ; $m < $m_lo; $m++)
# {
    $date = &m2mmddyyyy ($m) ;
   print "2 date: $date m_lo: $m_lo, m: $m\n" ; # debug code
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
    if (($tot_or_new eq 'New') && ($new_articles_per_usertype > 0)) # new refined counts available ?
    { print ARTICLES_OUT "$wp,$date,0,0,0\n" ; }
    else
    { print ARTICLES_OUT "$wp,$date,0\n" ; }
    $m++ ;
  }

  $period = month_year_english_short ($m_lo - ($m_lo % 12 - 1)) . ' ' . month_year_english_short ($m_hi) ; # always start in January

  $tot_articles_prev = 0 ;
  foreach $line (@csv)
  {
    next if $line !~ /^$wp/ ;
    chomp $line ;
    ($lang,$date,$tot_contributors,$new_contributors,$editors_ge5,$editors_ge100,$tot_articles,$alt_articles,$new_articles_per_day,
     $mean_versions,$mean_bytes,$over_size1,$over_size2,$edits_per_month,
     $tot_bytes,$tot_words,$tot_links,$tot_links_wiki,$tot_links_images,$tot_links_external,$tot_redirects,$tot_categorized,$pages_without_internal_link,
     $edits_per_month_reg,$edits_per_month_anon,$edits_per_month_bot,
     $new_articles_per_month_reg,$new_articles_per_month_anon,$new_articles_per_month_bot) = split (',', $line) ;

    $m = ord (&yyyymm2b (substr ($date,6,4),substr ($date,0,2))) ;
    next if $m > $m_stop ;

    if ($tot_or_new eq 'New')
    { $articles = $tot_articles - $tot_articles_prev ; }
    else
    { $articles = $tot_articles ; }

    $date = &m2mmdimyyyy ($m) ;
    if (($tot_or_new eq 'New') && ($new_articles_per_usertype > 0)) # new refined counts available ?
    { print ARTICLES_OUT "$wp,$date," . sprintf ("%.1f", $new_articles_per_month_reg/$metric_unit) . ',' . sprintf ("%.1f", $new_articles_per_month_anon/$metric_unit) . ',' . sprintf ("%.1f", $new_articles_per_month_bot/$metric_unit) . "\n" ; }
    else
    { print ARTICLES_OUT "$wp,$date," . sprintf ("%.1f", $articles/$metric_unit) . "\n" ; }

    $tot_articles_prev = $tot_articles ;
  }
  close ARTICLES_OUT ;

  # edit plot parameters

  if ($wp eq 'zz') 
  { $out_script_plot =~ s/TITLE/Articles on all $out_publication wikis$metric_unit_text1/g ; } 
  elsif ($mode_wx)
  { $out_script_plot =~ s/TITLE/Article on $out_language_name wiki$metric_unit_text1/g ; } 
  else
  {
    $out_script_plot =~ s/TITLE/Articles on LANGUAGE $out_publication$metric_unit_text1/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
    $out_script_plot =~ s/CODE/$code/g ;
  }

  if (($tot_or_new eq 'New') && ($new_articles_per_usertype > 0)) # new refined counts available ?
  {
    $out_script_plot   = $out_script_plot_articles2 ;
    if ($wp eq 'zz') 
    { $out_script_plot =~ s/TITLE/New articles on all $out_publication wikis$metric_unit_text1/g ; } 
    elsif ($mode_wx)
    { $out_script_plot =~ s/TITLE/New articles on $out_language_name wiki$metric_unit_text1/g ; } 
    else
    {
      $out_script_plot =~ s/TITLE/New articles on LANGUAGE $out_publication$metric_unit_text1/g ;
      $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
      $out_script_plot =~ s/CODE/$code/g ;
    }
  # $out_script_plot =~ s/TITLE/New articles per month on $out_language_name $out_publication$metric_unit_text1/g ; 
  }
  else
  { $out_script_plot =~ s/TITLE/Total articles on $out_language_name $out_publication$metric_unit_text1/g ; } 

  $mmddyyyy = &m2mmddyyyy ($month_plot_max) ;
  $month_plot_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_data_R/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;

  if (($tot_or_new eq 'New') && ($new_articles_per_usertype > 0)) # new refined counts available ?
  {
    $out_script_plot =~ s/COL_DATA/2:5/g ;
    $out_script_plot =~ s/COL_COUNTS/2:4/g ;
  }
  else
  {
    $out_script_plot =~ s/COL_DATA/2:3/g ;
    $out_script_plot =~ s/COL_COUNTS/2:2/g ;
  }

  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_METRIC/$tot_or_new_lc articles/g ;
  $out_script_plot =~ s/MAX_MONTH/$month_plot_max/g ;
  $out_script_plot =~ s/MAX_VALUE/$metric_max$metric_unit_text2/g ;

  if ($tot_or_new eq 'New')
  { $out_script_plot =~ s/YLIM_MAX/$metric_max_rounded_usertype/g ; }
  else
  { $out_script_plot =~ s/YLIM_MAX/$metric_max_rounded/g ; }

  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/UNIT/$metric_unit_text/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  &GeneratePlotCallR ($out_script_plot, $file_script_R) ;
# exit ; # debug
}

sub SummaryAddIndexes
{
  my (%summaries_included) = @_ ;
  my $index_html ;
  foreach $lang (sort {$out_languages {$a} cmp $out_languages {$b}} @languages)
  {
    next if $lang =~ /^z+$/ ;
    next if ! $summaries_included {$lang} ;
    push @index_languages1, "<a href='#lang_$lang'>${out_languages {$lang}}</a>" ;
  }

  foreach $lang (sort @languages)
  {
    next if $lang =~ /^z+$/ ;
    next if ! $summaries_included {$lang} ;
    push @index_languages2, "<a href='#lang_$lang'>$lang</a>" ;
  }

#  foreach $lang (keys_sorted_by_value_num_desc %{$editstottype{'R'}})
#  {
#    my $edits = &i2KM4 ($editstottype {'R'}{$lang} + $editstottype {'A'}{$lang} + $editstottype {'B'}{$lang}) ;
#    my $file_html = "EditsReverts" . uc ($lang) . ".htm" ;
#    my $file_csv  = "$path_in\/RevertedEdits" . uc($lang) . ".csv" ;
#    if (-e $file_csv)
#    { push @index_languages3, "<a href='$file_html'>${out_languages{$lang}}</a> ($edits)" ; }
#    else
#    { push @index_languages3, $out_languages{$lang} ; }
#  }

  $index_languages1 = join ', ', @index_languages1 ;
  $index_languages2 = join ', ', @index_languages2 ;
# $index_languages3 = join ', ', @index_languages3 ;
  $index_html = "\n\n" . &HtmlIndex3 ; # in WikiReportsOutputEditHistory
  $index_html .= "<tr><td class=l><b>Language index by <span id='caption'><font color=#006600>language name</font> / <font color=#A0A0A0>language code</font></span></b><br>&nbsp;</td><td class=r colspan=99><a href=\"#\" id='toggle' onclick=\"toggle_visibility_index();\">Toggle index</a></td></tr>\n" ;
  $index_html .= "<tr><td class=lwrap colspan=99>\n" .
                 "<span id='index1' style=\"display:block\">\n$index_languages1\n</span>\n" .
                 "<span id='index2' style=\"display:none\">\n$index_languages2\n</span>\n" .
               # "<span id='index3' style=\"display:none\">\n$index_languages3\n</span>" .
                 "</td></tr>\n\n\n" ;
  return ($index_html) ;
}

sub SummaryUnitAndScale
{
  my $metric_max = shift ;
  my $metric_unit = 1 ;
  my $metric_unit_text1 = "" ;
  my $metric_unit_text2 = "" ;

  if ($metric_max >= 10000)
  {
    $metric_unit = 1000 ;
    $metric_unit_text1 = " (x 1000)" ;
    $metric_unit_text2 = ",000" ;
  }
  if ($metric_max >= 10000000)
  {
    $metric_unit = 1000000 ;
    $metric_unit_text1 = " (x 1,000,000)" ;
    $metric_unit_text2 = " million" ;
  }
  $metric_max = sprintf ("%.0f", $metric_max / $metric_unit) ;

  my $metric_max_rounded = 10000000000000 ;
  while ($metric_max_rounded / 10 > $metric_max)  { $metric_max_rounded /= 10 ; }

# to be made into smarter routine
     if ($metric_max_rounded * 0.12 > $metric_max) { $metric_max_rounded *= 0.12 ; }
  elsif ($metric_max_rounded * 0.14 > $metric_max) { $metric_max_rounded *= 0.14 ; }
  elsif ($metric_max_rounded * 0.16 > $metric_max) { $metric_max_rounded *= 0.16 ; }
  elsif ($metric_max_rounded * 0.18 > $metric_max) { $metric_max_rounded *= 0.18 ; }
  elsif ($metric_max_rounded * 0.2  > $metric_max) { $metric_max_rounded *= 0.2 ; }
  elsif ($metric_max_rounded * 0.25 > $metric_max) { $metric_max_rounded *= 0.25 ; }
  elsif ($metric_max_rounded * 0.3  > $metric_max) { $metric_max_rounded *= 0.3 ; }
  elsif ($metric_max_rounded * 0.4  > $metric_max) { $metric_max_rounded *= 0.4 ; }
  elsif ($metric_max_rounded * 0.5  > $metric_max) { $metric_max_rounded *= 0.5 ; }
  elsif ($metric_max_rounded * 0.6  > $metric_max) { $metric_max_rounded *= 0.6 ; }
  elsif ($metric_max_rounded * 0.7  > $metric_max) { $metric_max_rounded *= 0.7 ; }
  elsif ($metric_max_rounded * 0.8  > $metric_max) { $metric_max_rounded *= 0.8 ; }

  $metric_max =~ s/(\d)(\d\d\d)$/$1,$2/ ;
  $metric_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  $metric_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  $metric_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;

  return ($metric_max, $metric_max_rounded, $metric_unit, $metric_unit_text1, $metric_unit_text2) ;
}


sub SummaryTrendChange
{
  my ($now, $prev) = @_ ;
  if ($prev == 0)
  { $result = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; }
  else
  {
    $result = sprintf ("%.0f", (100 * ($now / $prev)) - 100) . '%' ;
    if ($result !~ /-/)
    { $result = "<font color=#009000>+$result</font>" ; }
    else
    { $result = "<font color=#900000>$result</font>" ; }
  }

# print "Trend prev $prev -> now $now => trend $result\n" ;
  return $result ;
}

sub FormatSummary
{
  my $x = shift ;
  $x =~ s/(\d)(\d\d\d)$/$1,$2/ ;
  $x =~ s/(\d)(\d\d\d),(\d\d\d)$/$1,$2,$3/ ;
  $x =~ s/(\d)(\d\d\d),(\d\d\d),(\d\d\d)$/$1,$2,$3,$4/ ;
  return ($x) ;
}

sub HtmlLogoProject
{
  my $html ;

     if ($mode_wb) { $html = "<a href='http://stats.wikimedia.org/wikibooks/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikibooks-logo.svg/30px-Wikibooks-logo.svg.png' width='30' height='30' border='0'  alt='Wikibooks' border=0 /></a>" ; }
  elsif ($mode_wk) { $html = "<a href='http://stats.wikimedia.org/wiktionary/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Wiktionary-logo-en.png/30px-Wiktionary-logo-en.png' width='30' height='30' border='0'  alt='Wiktionary' border=0 /></a>" ; }
  elsif ($mode_wn) { $html = "<a href='http://stats.wikimedia.org/wikinews/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Wikinews-logo.png/40px-Wikinews-logo.png' width='40' height='24' border='0'  alt='Wikinews' border=0 /></a>" ; }
  elsif ($mode_wo) { $html = "<a href='http://stats.wikimedia.org/wikivoyage/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/b/b7/Wikivoyage-Logo-v3-en-highlight.png' width='35' height='35' border='0'  alt='Wikivoyage' border=0 /></a>" ; } 
  elsif ($mode_wp) { $html = "<a href='http://stats.wikimedia.org/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Wikipedia-logo.png/30px-Wikipedia-logo.png' width='30' height='30' border='0'  alt='Wikipedia' border=0 /></a>" ; }
  elsif ($mode_wq) { $html = "<a href='http://stats.wikimedia.org/wikiquote/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikiquote-logo.svg/30px-Wikiquote-logo.svg.png' width='30' height='30' border='0'  alt='Wikiquote' border=0 /></a>" ; }
  elsif ($mode_ws) { $html = "<a href='http://stats.wikimedia.org/wikisource/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Wikisource-logo.svg/40px-Wikisource-logo.svg.png' width='40' height='32' border='0'  alt='Wikisource' border=0 /></a>" ; }
  elsif ($mode_wv) { $html = "<a href='http://stats.wikimedia.org/EN/wikiversity/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Wikiversity-logo.svg/30px-Wikiversity-logo.svg.png' width='30' height='30' border='0'  alt='Wikiversity' border=0 /></a>" ; }
  elsif ($mode_wx) { $html = "<a href='http://stats.wikimedia.org/EN/wikispecial/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Wikimedia-logo.svg/30px-Wikimedia-logo.svg.png' width='30' height='30' border='0'  alt='Wikimedia' border=0 /></a>" ; }

  return ($html) ;
}

sub HtmlSummaryExplanation
{
  my ($page_sitemap) = @_ ;

  my $explanation_proper_articles     = "Metrics are about proper articles only (aka 'real' content or  <a href='http://www.mediawiki.org/wiki/Help:Namespaces'>namespace 0 pages</a>), not discussion/help/project pages, etc.\n" ;
  my $explanation_page_views          = "<dt><b><A href='../EN/TablesPageViewsMonthly.htm'>Page Views</a> <sup>1</sup></b><dd>\n" ;
  my $explanation_page_views_2        = "<dt><b><A href='../EN/TablesPageViewsMonthly.htm'>Page Views</a> </b><dd>\n" ;
  my $explanation_articles_total      = "<dt><b><a href='../EN/TablesArticlesTotal.htm'>Article Count</a> <sup>1</sup></b><dd>An article is defined as any 'real' content page which contains at least one link to any other page\n" ;
  my $explanation_articles_per_day    = "<dt><b><a href='../EN/TablesArticlesNewPerDay.htm'>New Articles per Day</a></b><dd>\n" ;
  my $explanation_edits_per_month     = "<dt><b><a href='../EN/TablesDatabaseEdits.htm'>Edits per Month</a></b><dd>\n" ;
  my $explanation_active_editors      = "<dt><b><a href='../EN/TablesWikipediansEditsGt5.htm'>Active Editors</a></b><dd>Registered (and signed in) users who made 5 or more edits in a month\n" ;
  my $explanation_very_active_editors = "<dt><b><a href='../EN/TablesWikipediansEditsGt100.htm'>Very Active Editors</a></b><dd>Registered (and signed in) users who made 100 or more edits in a month\n" ;
  my $explanation_new_editors         = "<dt><b><a href='../EN/TablesWikipediansNew.htm'>New Editors</a></b><dd>Registered (and signed in) users who completed their all time 10th edit in this month\n" ;
  my $explanation_speakers            = "<dt><b>Speakers <sup>1</sup></b><dd>Includes secondary language speakers. ARTICLE_LANGUAGE\n" ;
  my $explanation_editors_per_million = "<dt><b>Editors per Million Speakers <sup>1</sup></b><dd> aka Participation Rate.\n" ;
  my $explanation_comparison          = "<sup>1</sup> For language/project comparisons see also <a href='$page_sitemap'>$out_publication sitemap</a> and new WMF <a href='http://reportcard.wmflabs.org/'>Report Card</a> (beta).\n" ;

  my $html = <<__HTML_SUMMARY_EXPLANATION__ ;
      <td class=l colspan=99 width=100%>
      <a id='definitions' name='definitions'></a>
         <p><b>Definitions</b><p>
         $explanation_proper_articles
         <p>
         <dl>
         $explanation_page_views
         $explanation_articles_total
         $explanation_articles_per_day
         $explanation_edits_per_month
         $explanation_edits_per_month
         $explanation_active_editors
         $explanation_very_active_editors
         $explanation_new_editors
         $explanation_speakers
         $explanation_editors_per_million
         </dl>
         $explanation_comparison
      </td>
__HTML_SUMMARY_EXPLANATION__

  if ($wp eq 'commons')
  {
    $html = <<__HTML_SUMMARY_EXPLANATION_2__ ;
      <td class=l colspan=99 width=100%>
         <p><b>Definitions</b><p>
         $explanation_proper_articles
         <p>
         <dl>
         $explanation_page_views_2
         $explanation_edits_per_month
         $explanation_active_editors
         $explanation_very_active_editors
         $explanation_new_editors
         </dl>
      </td>
__HTML_SUMMARY_EXPLANATION_2__
  }

  if ($mode_wp)
  { $html =~ s/TablesPageViewsMonthly.htm/TablesPageViewsMonthlyCombined.htm/ ; }

  return ($html) ;
}

sub HtmlSummaryExplanationReportCard
{
  my $explanation = shift ;
  my $html = <<__HTML_SUMMARY_EXPLANATION_2__ ;
<table width=660 cellpadding=18 align=center border=1 style="background-color:white">
<tr>
  $explanation
</tr>
</table>
__HTML_SUMMARY_EXPLANATION_2__

  return ($html) ;
}

sub HtmlSingleWiki
{
  my ($out_style, $out_body) = @_ ;
  my $html = <<__HTML_SUMMARY_SINGLE_WIKI__ ;
<html>
<head>
<title>Wikimedia project at a glance</title>
<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">
<meta name="robots" content="index,follow">
<script language="javascript" type="text/javascript" src="../WikipediaStatistics14.js"></script>
$out_style
$out_tracker_code
</head>
<body>
$out_body
</body>
</html>
__HTML_SUMMARY_SINGLE_WIKI__

  return ($html) ;
}

sub HtmlHeaderReportCard
{
  my ($logo_project, $index, $cross_ref, $title_content) = @_ ;


  my $html = <<__HTML_SUMMARY_HEADER_ALL__ ;
<a name='top' id='top'></a>
<table width=660 cellpadding=18 align=center border=1 style="background-color:white">
<tr>
  <td class=c width=100%>

    <table width=100% border=0>
    <tr>
      <td class=l width=100% colspan=99>

        <table width=100% border=0>
        <tr>
          <td class=l valign=top>
          <h2>$title_content</h2>
          </td>
          <td class=r width=20% valign=top><a href='http://www.wikimedia.org'>$logo_project</a></td>
        </tr>
        <tr>
          <td class=l colspan=99 valign=top>$index</td>
        </tr>
        <tr>
          <td class=l colspan=99 valign=top>$cross_ref</td>
        </tr>
        </table>

        <p>See <a href='#definitions'>definitions</a> below.
      </td>
    </tr>
    </table>
  </td>
<tr>
</table>
&nbsp;<p>
__HTML_SUMMARY_HEADER_ALL__

  return ($html) ;
}

sub HtmlReportCard
{
  my ($title_report_card, $out_style, $header_report_card, $html_multiple_wikis, $explanation_report_card) = @_ ;

  my $html = <<__HTML_SUMMARY_REPORT_CARD__ ;
<html>
<head>
<title>$title_report_card</title>
<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">
<meta name="robots" content="index,follow">
<script language="javascript" type="text/javascript" src="../WikipediaStatistics14.js"></script>
$out_style
$out_tracker_code
</head>
<body>
$header_report_card
$html_multiple_wikis
$explanation_report_card
</body>
</html>
__HTML_SUMMARY_REPORT_CARD__

  return ($html) ;
}

sub HtmlSummariesCrossReference
{
  my ($html, $html_xref_wp, $html_xref_wm) ; ;

  if ($mode_wp)
  {
    if ($region ne '')
    { $html_xref_wp = "\n<a href='http://stats.wikimedia.org/$langcode/ReportCardTopWikis.htm'>Top 50 Languages</a>\n" ; }
    else
    { $html_xref_wp = "\n<font color='#808080'>Top 50 languages</font>\n" ; }

    if ($region ne 'africa')
    { $html_xref_wp .= ", <a href='http://stats.wikimedia.org/${langcode}_Africa/ReportCardAfrica.htm'>Africa</a>\n" ; }
    else
    { $html_xref_wp .= ", <font color='#808080'>Africa</font>\n" ; }

    if ($region ne 'asia')
    { $html_xref_wp .= ", <a href='http://stats.wikimedia.org/${langcode}_Asia/ReportCardAsia.htm'>Asia</a>\n" ; }
    else
    { $html_xref_wp .= ", <font color='#808080'>Asia</font>\n" ; }

    if ($region ne 'america')
    { $html_xref_wp .= ", <a href='http://stats.wikimedia.org/${langcode}_America/ReportCardAmerica.htm'>America</a>\n" ; }
    else
    { $html_xref_wp .= ", <font color='#808080'>America</font>\n" ; }

    if ($region ne 'europe')
    { $html_xref_wp .= ", <a href='http://stats.wikimedia.org/${langcode}_Europe/ReportCardEurope.htm'>Europe</a>\n" ; }
    else
    { $html_xref_wp .= ", <font color='#808080'>Europe</font>\n" ; }

    if ($region ne 'india')
    { $html_xref_wp .= ", <a href='http://stats.wikimedia.org/${langcode}_India/ReportCardIndia.htm'>India</a>\n" ; }
    else
    { $html_xref_wp .= ", <font color='#808080'>America</font>\n" ; }

    if ($region ne 'oceania')
    { $html_xref_wp .= ", <a href='http://stats.wikimedia.org/${langcode}_Oceania/ReportCardOceania.htm'>Oceania</a>\n" ; }
    else
    { $html_xref_wp .= ", <font color='#808080'>Oceania</font>\n" ; }

    if ($region ne 'artificial')
    { $html_xref_wp .= ", <a href='http://stats.wikimedia.org/${langcode}_Artificial/ReportCardArtificial.htm'>Artificial Languages</a>\n" ; }
    else
    { $html_xref_wp .= ", <font color='#808080'>Artificial Languages</font>\n" ; }

    $html = "<br><b>Wikipedia summaries:</b> $html_xref_wp" ;
  }

  if (! $mode_wp)
  { $html_xref_wm = "<a href='http://stats.wikimedia.org/EN/ReportCardTopWikis.htm'>Wikipedia</a>\n" ; }
  else
  { $html_xref_wm = "<font color='#808080'>Wikipedia</font>\n" ; }

  if (! $mode_wk)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wiktionary/EN/ReportCardTopWikis.htm'>Wiktionary</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Wiktionary</font>\n" ; }

  if (! $mode_wb)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wikibooks/EN/ReportCardTopWikis.htm'>Wikibooks</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Wikibooks</font>\n" ; }

  if (! $mode_wn)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wikinews/EN/ReportCardTopWikis.htm'>Wikinews</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Wikinews</font>\n" ; }

  if (! $mode_wo)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wikivoyage/EN/ReportCardTopWikis.htm'>Wikivoyage</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Wikivoyage</font>\n" ; }

  if (! $mode_wq)
  { $html_xref_wm .= ", <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='http://stats.wikimedia.org/wikiquote/EN/ReportCardTopWikis.htm'>Wikiquote</a>\n" ; }
  else
  { $html_xref_wm .= ", <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color='#808080'>Wikiquote</font>\n" ; }

  if (! $mode_ws)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wikisource/EN/ReportCardTopWikis.htm'>Wikisource</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Wikisource</font>\n" ; }

  if (! $mode_wv)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wikiversity/EN/ReportCardTopWikis.htm'>Wikiversity</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Wikiversity</font>\n" ; }

  if (! $mode_wx)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wikispecial/EN/ReportCardTopWikis.htm'>Other projects</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Other projects</font>\n" ; }

  $html .= "\n\n&nbsp;<br><a href='http:www.wikimedia.org'>WMF</a> <b>Projects: </b>" . $html_xref_wm . "\n\n" ;

  return ($html) ;
}

sub HtmlSummaryBinaries
{
  my ($month, $type, $description) = @_ ;

  my $html = <<__HTML_SUMMARY_BINARIES__ ;
          <tr>
            <td class=l>CAPTION</td>
            <td class=r>METRIC_DATA</td>
            <td class=r>METRIC_YEARLY</td>
            <td class=r>METRIC_MONTHLY</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>
__HTML_SUMMARY_BINARIES__

  # binaries: images
  $this_month     = $binaries_per_month {"$month|$type"} ;
  $prev_month     = $binaries_per_month {($month-1) . "|$type"} ;
  $prev_year      = $binaries_per_month {($month-12) . "|$type"} ;

  # print "Ext $type 0:$this_month, -1:$prev_month, -12:$prev_year\n" ;
  $metric_yearly  = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_monthly = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_data    = &FormatSummary ($this_month) ;

  $caption_images = "Binaries - $description (" . $extension_codes {$type} . ")" ;

  $html =~ s/CAPTION/$caption_images/ ;
  $html =~ s/METRIC_DATA/$metric_data/ ;
  $html =~ s/METRIC_YEARLY/$metric_yearly/ ;
  $html =~ s/METRIC_MONTHLY/$metric_monthly/ ;

  return ($html) ;
}

sub GeneratePlotCallR
{
  my ($script, $file_script) = @_ ;

  ($file_script_out = $file_script) =~ s/R-in/R-out/ ;

  open R_SCRIPT, '>', $file_script or die ("file $file_script could not be opened") ;
  print R_SCRIPT $script ;
  close R_SCRIPT ;

# if "Error in library(Cairo) : there is no package called 'Cairo'":
# see https://phabricator.wikimedia.org/T155254:
#
# export http_proxy=http://webproxy.eqiad.wmnet:8080; export HTTPS_PROXY=http://webproxy.eqiad.wmnet:8080;
# R
# > install.packages(c("Cairo"), repos="http://cran.r-project.org" )
  $cmd = "R CMD BATCH \"$file_script\" \"$file_script_out\"" ;

  if ($generate_edit_plots++ < 10)
  { print "CMD $cmd\n" ; }

  @result = `$cmd` ;
}

sub blank_zero
{
  my $count = shift ;
  $count = '' if $count == 0 ;
  return ($count) ;
}
 
1;

