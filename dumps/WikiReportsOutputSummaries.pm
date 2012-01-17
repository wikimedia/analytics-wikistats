#!/usr/bin/perl

# needed files
# StatisticsMonthly.csv
# StatisticsUserActivitySpread.csv
sub GenerateSummariesPerWiki
{
  my @months_en   = qw (January February March April May June July August September October November December);
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
  $summaries_published = "$mday ${months_en [$mon]} " . ($year+1900) ;

  $logo_project = &HtmlLogoProject ; # removed WMF logo <img src='http://stats.wikimedia.org/WikimediaLogo.jpg' width=30>

  $col_highlight = "#8080FF" ;

  $out_html_report_card = '' ;

  # Generate edit/view plots per wiki
  # Generate html file per single wiki
  # Collect html for multiple wikis (top 50 or per region), aka report card

  $summaries_index = 0 ;
  $summaries_collected = 0 ;
  $language_count = $#languages + 1 ;
  foreach $wp (@languages)
  {
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

    if (($skip {$wp}) || ($wp =~ /^z+$/))
    {
      &LogT ("$summaries_progress: skip $wp\n") ;
      next ;
    }

    $out_html = &GetSummaryPerWiki ($wp, $summaries_progress) ;

    if ($wp eq 'commons')
    {
      &GeneratePlotBinaries ($wp,1) ;
      &GeneratePlotBinaries ($wp,2) ;
    }

    &GeneratePlotEditors   ($wp) ;
    &GeneratePlotPageviews ($wp) ;

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

  &LogT ("$progress: month $month_year $out_language_name $out_publication ($wp)\n") ;
  $html = "\n" ;

  # page views

  $daysinmonth     = days_in_month (substr ($mmddyyyy,6,4), substr ($mmddyyyy,0,2)) ;
  $pageviews_month = sprintf ("%.0f", ($PageViewsPerHour {$wp} * 24 * 30)) ; # use normalized count (month always 30 days)
  $pageviews_day   = $pageviews_month / 30 ; # $daysinmonth ;
  $pageviews_hour  = $pageviews_day / 24 ;
  $pageviews_min   = $pageviews_day / (24 * 60) ;
  $pageviews_sec   = $pageviews_day / (24 * 60 * 60) ;

  $this_month         = $pageviews_month ;
  $metric_PV_yearly   = "--" ;
  $metric_PV_monthly  = "--" ;

# print "$month_year: $daysinmonth days in month, page views $pageviews_month\n" ;

  $metric_PV_data     = &FormatSummary ($this_month) ;

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

  $plot_binaries1 = 'PlotBinaries'  . uc ($wp) . '1.png' ;
  $plot_binaries2 = 'PlotBinaries'  . uc ($wp) . '2.png' ;
  $plot_editors   = 'PlotEditors'   . uc ($wp) . '.png' ;
  $plot_pageviews = 'PlotPageviews' . uc ($wp) . '.png' ;

  if ($mode_wx)
  { $wiki = $out_language_name ; }
  else
  { $wiki = "$out_language_name $out_publication" ; }

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
            <td class=r width=22%><font color=$col_highlight>Data</td>
            <td class=r width=22%><font color=$col_highlight>Yearly change</td>
            <td class=r width=22%><font color=$col_highlight>Monthly change</td>
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

    PLOT_BINARIES
    PLOT_EDITORS
    PLOT_PAGEVIEWS

    EXPLANATION
    SEE_ALSO
    DATASOURCES
    </table>

  </td>
</tr>
</table>

__HTML_SUMMARY__

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
      &nbsp;<p><img src='$plot_editors'></td>
    </tr>
__HTML_SUMMARY_PLOT_EDITORS__

$html_plot_pageviews = <<__HTML_SUMMARY_PLOT_PAGEVIEWS__ ;
    <tr>
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_pageviews'>
      <br><small><font color=#808080>page views: $pageviews_per_unit</font></small></td>
    </tr>
__HTML_SUMMARY_PLOT_PAGEVIEWS__

  if ($mode_wx)
  {
    if ($wp eq 'commons')
    {
      $html =~ s/BINARIES/&ReadStatisticsBinariesCommons/e ;
      $html =~ s/SPEAKERS// ;
      $html =~ s/PARTICIPATION// ;
      $html =~ s/PLOT_BINARIES/$html_plot_binaries/ ;
      $html =~ s/PLOT_EDITORS/$html_plot_editors/ ;
      $html =~ s/PLOT_PAGEVIEWS/$html_plot_pageviews/ ;
    }
    else
    {
      $html =~ s/BINARIES// ;
      $html =~ s/SPEAKERS// ;
      $html =~ s/PARTICIPATION// ;
      $html =~ s/PLOT_BINARIES// ;
      $html =~ s/PLOT_EDITORS/$html_plot_editors/ ;

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
  }

  if ($region eq '')
  {
    $langcode = 'EN' ;
    if ($mode_wb)
    { $url_base = "http://stats.wikimedia.org/wikibooks/$langcode" ; }
    if ($mode_wk)
    { $url_base = "http://stats.wikimedia.org/wiktionary/$langcode" ; }
    if ($mode_wn)
    { $url_base = "http://stats.wikimedia.org/wikinews/$langcode" ; }
    if ($mode_wp)
    { $url_base = "http://stats.wikimedia.org/$langcode" ; }
    if ($mode_wq)
    { $url_base = "http://stats.wikimedia.org/wikiquote/$langcode" ; }
    if ($mode_ws)
    { $url_base = "http://stats.wikimedia.org/wikisource/$langcode" ; }
    if ($mode_wv)
    { $url_base = "http://stats.wikimedia.org/wikiversity/$langcode" ; }
    if ($mode_wx)
    { $url_base = "http://stats.wikimedia.org/wikispecial/$langcode" ; }
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
           Published $summaries_published&nbsp;&nbsp;/&nbsp;&nbsp;
           <b>See Also</b>
           <a href='$url_trends'><font color=#000080>Detailed trends</font></a> for <a href='$main_page'><font color=#000080>$out_language_name $out_publication</font></a>&nbsp;&nbsp;/&nbsp;&nbsp;
           <a href='$url_site_map'><font color=#000080>Stats for all $out_publications</font></a>&nbsp;&nbsp;/&nbsp;&nbsp;
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
      <p><i><small>Sources <a href='http://stats.wikimedia.org'>stats.wikimedia.org</a> $source_wikipedia / Published $summaries_published</small></i>
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

  my @months_en = qw (Jan Feby Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
  my @factors   = qw (0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9);

  my $wp = shift ;

  return if $wp ne 'commons' ;

# &LogT ("GeneratePlotBinaries $wp\n") ;

  my $file_csv_input    = $file_binaries_per_wiki ;
  my $path_png_raw      = "$path_out_plots\/PlotBinaries" . uc($wp) . "$pass.png" ;
  my $path_png_trends   = "$path_out_plots\/PlotBinariesTrends" . uc($wp) . "$pass.png" ;
  my $path_svg          = "$path_out_plots\/PlotBinaries" . uc($wp) . "$pass.svg" ;
  my $out_script_plot ;

  my $out_script_plot   = $out_script_plot_binaries ;

  my $out_language_name = $out_languages {$wp} ;
  my $month_max         = $editors_month_hi_5 {$wp} ;

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

  $file_csv_input       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  open BINARIES_OUT, '>', $file_csv_input || &Abort ("Could not open file $file_csv_input") ;

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

  # calc plot parameters

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
  { $out_script_plot =~ s/TITLE/Images on all $out_publications (x 1,000,000)/g ; }
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
    $out_script_plot =~ s/1,000,000/x 1000/g;
  }

  $mmddyyyy = &m2mmddyyyy ($month_max) ;
  $month_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_input/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;
  $out_script_plot =~ s/CODE/$code/g ;

  if ($pass == 1)
  { $out_script_plot =~ s/MAX_VALUE/max images/ ; }
  else
  { $out_script_plot =~ s/MAX_VALUE/max other binaries/ ; }

  $out_script_plot =~ s/MAX_MONTH/$month_max/g ;
  $out_script_plot =~ s/BINARIES/$binaries_max/g ;
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

  my $file_script = $path_in . "R-PlotBinaries.txt" ;
  open R_SCRIPT, '>', $file_script or die ("file $file_script not found") ; ;
  print R_SCRIPT $out_script_plot ;
  close R_SCRIPT ;

  $cmd = "R CMD BATCH \"$file_script\"" ;

  if ($generate_edit_plots++ == 0)
  { print "$cmd\n" ; }

  @result = `$cmd` ;
}

sub GeneratePlotEditors
{
  my @months_en = qw (Jan Feby Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;

  return if $wp =~ /^z+$/ ;

# &LogT ("GeneratePlotEditors $wp\n") ;

  my $file_csv_input    = $file_editors_per_wiki ;
  my $path_png_raw      = "$path_out_plots\/PlotEditors" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotEditorsTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotEditors" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_editors ;
  my $out_language_name = $out_languages {$wp} ;
  my $editors_max       = $editors_max_5 {$wp} ;
  my $month_max         = $editors_month_max_5 {$wp} ;
  my $code              = uc ($wp) ;

  if ($month_max == 0)
  { print "$wp: \$month_max = \$editors_month_max_5 \{\$wp\} <- == 0\n" ; return ; }
  $file_csv_input       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  open EDITORS_OUT, '>', $file_csv_input || &Abort ("Could not open file $file_csv_input") ;
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

  # calc plot parameters

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
  { $out_script_plot =~ s/TITLE/Active Editors on all $out_publications/g ; }
  elsif ($mode_wx)
  { $out_script_plot =~ s/TITLE/Active Editors on $out_language_name wiki/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Active Editors on LANGUAGE $out_publication/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
    $out_script_plot =~ s/CODE/$code/g ;
  }

  $mmddyyyy = &m2mmddyyyy ($month_max) ;
  $month_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_input/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;
  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_VALUE/max editors (5+ edits) in/ ;
  $out_script_plot =~ s/MAX_MONTH/$month_max/g ;
  $out_script_plot =~ s/EDITORS/$editors_max/g ;
  $out_script_plot =~ s/YLIM_MAX/$editors_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  $out_script_plot =~ s/COLOR_5/violetred2/g ;
  $out_script_plot =~ s/COLOR_25/purple2/g ;
  $out_script_plot =~ s/COLOR_100/dodgerblue2/g ;

  my $file_script = $path_in . "R-PlotEditors.txt" ;
  open R_SCRIPT, '>', $file_script or die ("file $file_script not found") ; ;
  print R_SCRIPT $out_script_plot ;
  close R_SCRIPT ;

  $cmd = "R CMD BATCH \"$file_script\"" ;

  if ($generate_edit_plots++ == 0)
  { print "$cmd\n" ; }

  @result = `$cmd` ;
}

sub GeneratePlotPageviews
{
  my @months_en = qw (Jan Feby Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;

  return if $wp =~ /^z+$/ ;

  if ($pageviews_max {$wp} == 0)
  { print "\nNo pageviews found for wiki $wp!\n\n" ; return ; }

# &LogT ("GeneratePlotPageviews $wp\n") ;

  my $file_csv_input    = $file_pageviews_per_wiki ;
  my $path_png_raw      = "$path_out_plots\/PlotPageviews" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotPageviewsTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotPageviews" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_pageviews ;
  my $out_language_name = $out_languages {$wp} ;
  my $pageviews_max     = $pageviews_max {$wp} ;
  my $month_max         = $pageviews_month_max {$wp} ;

  return if $month_max == 0 ; # Q&D temp fix

  my $code              = uc ($wp) ;
  $file_csv_input       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  open PAGEVIEWS_OUT, '>', $file_csv_input || &Abort ("Could not open file $file_csv_input") ;
  print PAGEVIEWS_OUT "language,month,count_normalized\n" ;

  $pageviews_unit = 1 ;
  $pageviews_unit_text = "" ;
  $pageviews_unit_text2 = "" ;
  if ($pageviews_max >= 1000000)
  {
    $pageviews_unit = 1000 ;
    $pageviews_unit_text = " (x 1000)" ;
    $pageviews_unit_text2 = ",000" ;
  }
  if ($pageviews_max >= 1000000000)
  {
    $pageviews_unit = 1000000 ;
    $pageviews_unit_text = " (in millions)" ;
    $pageviews_unit_text2 = " million" ;
  }
  $pageviews_max = sprintf ("%.0f", $pageviews_max / $pageviews_unit) ;

  $period = month_year_english_short ($pageviews_month_lo {$wp}) . ' ' . month_year_english_short ($pageviews_month_hi {$wp}-1) ;

  $pageviews_month_lo = $pageviews_month_lo {$wp} - $pageviews_month_lo {$wp} % 12 ; # always start in January, to align x axis properly

  for ($m = $pageviews_month_lo ; $m < $pageviews_month_hi {$wp} ; $m++)
  {
    if ($m < $pageviews_month_lo {$wp})
    { $count_normalized = "" ; }
    else
    { $count_normalized = sprintf ("%.0f", $pageviews {$wp.$m} / $pageviews_unit) ; }

    # $days_in_month =  days_in_month (substr($date,6,4),substr($date,0,2)) ;
    # $count_normalized = sprintf ("%.0f", 30/$days_in_month * $count) ;

    # make boundary not show at 2010-01-31 but at 2010-01-01 as follows:
    # instead of value for last day of month, present it as value for first day of next month
    # this requires outputting extra first value for 20xx-01-01 (to make chart start at January)

    if ($m == $pageviews_month_lo {$wp})
    {
      $date = &m2mmddyyyy ($m) ;
      $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
      print PAGEVIEWS_OUT "$wp,$date,$count_normalized\n" ;
    }

    $date = &m2mmddyyyy ($m+1) ;
    $date =~ s/(\d\d)\/\d\d\/(\d\d\d\d)/$1\/01\/$2/ ;
    print PAGEVIEWS_OUT "$wp,$date,$count_normalized\n" ;

  }
  close PAGEVIEWS_OUT ;

  # calc plot parameters

  $pageviews_max_rounded = 10000000000000 ;
  while ($pageviews_max_rounded / 10 > $pageviews_max)  { $pageviews_max_rounded /= 10 ; }

     if ($pageviews_max_rounded * 0.15 > $pageviews_max) { $pageviews_max_rounded *= 0.15 ; }
  elsif ($pageviews_max_rounded * 0.2 > $pageviews_max) { $pageviews_max_rounded *= 0.2 ; }
  elsif ($pageviews_max_rounded * 0.4 > $pageviews_max) { $pageviews_max_rounded *= 0.4 ; }
  elsif ($pageviews_max_rounded * 0.6 > $pageviews_max) { $pageviews_max_rounded *= 0.6 ; }
  elsif ($pageviews_max_rounded * 0.8 > $pageviews_max) { $pageviews_max_rounded *= 0.8 ; }

  $pageviews_max =~ s/(\d)(\d\d\d)$/$1,$2/ ;
  $pageviews_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  $pageviews_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;
  $pageviews_max =~ s/(\d)(\d\d\d),/$1,$2,/ ;

  # edit plot parameters

  if ($wp eq 'zz')
  { $out_script_plot =~ s/TITLE/Page Views on all $out_publications$pageviews_unit_text/g ; }
  elsif ($mode_wx)
  { $out_script_plot =~ s/TITLE/Page Views on $out_language_name wiki$pageviews_unit_text/g ; }
  else
  {
    $out_script_plot =~ s/TITLE/Page Views on LANGUAGE $out_publication$pageviews_unit_text/g ;
    $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
    $out_script_plot =~ s/CODE/$code/g ;
  }

  $mmddyyyy = &m2mmddyyyy ($month_max) ;
  $month_max = $months_en [substr ($mmddyyyy,0,2) - 1] . " " . substr ($mmddyyyy,6,4) ;

  $out_script_plot =~ s/Wikipedia/$out_publication/g ;

  $out_script_plot =~ s/FILE_CSV/$file_csv_input/g ;
  $out_script_plot =~ s/FILE_PNG_TRENDS/$path_png_trends/g ;
  $out_script_plot =~ s/FILE_PNG_RAW/$path_png_raw/g ;
  $out_script_plot =~ s/FILE_SVG/$path_svg/g ;
  $out_script_plot =~ s/CODE/$code/g ;
  $out_script_plot =~ s/MAX_MONTH/$month_max/g ;
  $out_script_plot =~ s/VIEWS/$pageviews_max$pageviews_unit_text2/g ;
  $out_script_plot =~ s/YLIM_MAX/$pageviews_max_rounded/g ;
  $out_script_plot =~ s/LANGUAGE/$out_language_name/g ;
  $out_script_plot =~ s/UNIT/$pageviews_unit_text/g ;
  $out_script_plot =~ s/PERIOD/$period/g ;

  my $file_script = $path_in . "R-PlotPageviews.txt" ;
  open R_SCRIPT, '>', $file_script or die ("file $file_script not found") ; ;
  print R_SCRIPT $out_script_plot ;
  close R_SCRIPT ;

  $cmd = "R CMD BATCH \"$file_script\"" ;

  if ($generate_edit_plots++ == 0)
  { print "$cmd\n" ; }

  @result = `$cmd` ;
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

     if ($mode_wb) { $html = "<a href='http://en.wikipedia.org/wikistats/wikibooks/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikibooks-logo.svg/30px-Wikibooks-logo.svg.png' width='30' height='30' border='0'  alt='Wikibooks' border=0 /></a>" ; }
  elsif ($mode_wk) { $html = "<a href='http://en.wikipedia.org/wikistats/wiktionary/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Wiktionary-logo-en.png/30px-Wiktionary-logo-en.png' width='30' height='30' border='0'  alt='Wiktionary' border=0 /></a>" ; }
  elsif ($mode_wn) { $html = "<a href='http://en.wikipedia.org/wikistats/wikinews/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Wikinews-logo.png/40px-Wikinews-logo.png' width='40' height='24' border='0'  alt='Wikinews' border=0 /></a>" ; }
  elsif ($mode_wp) { $html = "<a href='http://en.wikipedia.org/wikistats/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Wikipedia-logo.png/30px-Wikipedia-logo.png' width='30' height='30' border='0'  alt='Wikipedia' border=0 /></a>" ; }
  elsif ($mode_wq) { $html = "<a href='http://en.wikipedia.org/wikistats/wikiquote/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikiquote-logo.svg/30px-Wikiquote-logo.svg.png' width='30' height='30' border='0'  alt='Wikiquote' border=0 /></a>" ; }
  elsif ($mode_ws) { $html = "<a href='http://en.wikipedia.org/wikistats/wikisource/EN/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Wikisource-logo.svg/40px-Wikisource-logo.svg.png' width='40' height='32' border='0'  alt='Wikisource' border=0 /></a>" ; }
  elsif ($mode_wv) { $html = "<a href='http://en.wikipedia.org/wikistats/EN/wikiversity/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Wikiversity-logo.svg/30px-Wikiversity-logo.svg.png' width='30' height='30' border='0'  alt='Wikiversity' border=0 /></a>" ; }
  elsif ($mode_wx) { $html = "<a href='http://en.wikipedia.org/wikistats/EN/wikispecial/Sitemap.htm'><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Wikimedia-logo.svg/30px-Wikimedia-logo.svg.png' width='30' height='30' border='0'  alt='Wikimedia' border=0 /></a>" ; }

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
  my $explanation_comparison          = "<sup>1</sup> For comparison see also <a href='$page_sitemap'>$out_publication sitemap</a>.\n" ;

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
$out_google_analytics
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
$out_google_analytics
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

  if (! $mode_wq)
  { $html_xref_wm .= ", <a href='http://stats.wikimedia.org/wikiquote/EN/ReportCardTopWikis.htm'>Wikiquote</a>\n" ; }
  else
  { $html_xref_wm .= ", <font color='#808080'>Wikiquote</font>\n" ; }

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

1;
