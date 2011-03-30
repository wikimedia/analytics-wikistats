#!/usr/bin/perl

# needed files
# StatisticsMonthly.csv
# StatisticsUserActivitySpread.csv
sub GenerateSummariesPerWiki
{
  my @months_en   = qw (January February March April May June July August September October November December);
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
  $summaries_published = "$mday ${months_en [$mon]} " . ($year+1900) ;

  $col_highlight = "#8080FF" ;

$explanation = <<__HTML_SUMMARY_EXPLANATION__ ;
      <td class=l colspan=99 width=100%>
         <b>Definitions</b><p>
         All metrics below only take into account proper articles (aka namespace 0 pages),<br>which excludes discussion, help, project, etc pages.
         <p>
         <dl>
         <dt><b>Page Views</b><dd>The chart does not necessarily cover all years of a project's existence.
         <brThe first year presented is the year where page views reached at least 1/100th of all-time maximum.
         <dt><b>Article Count</b><dd>An article is defined as any page in namespace 0 which contains an internal link
         <dt><b>New Articles per Day</b><dd>
         <dt><b>Edits per Month</b><dd>
         <dt><b>Active Editors</b><dd>Registered (and signed in) users who made 5 or more edits in a month
         <dt><b>Very Active Editors</b><dd>Registered (and signed in) users who made 100 or more edits in a month
         <dt><b>New Editors</b><dd>Registered (and signed in) users who completed their all time 10th edit in this month
         <dt><b>Speakers</b><dd>Includes secondary language speakers, data from the English Wikipedia (page on this language)
         <dt><b>Editors per Million Speakers</b><dd> aka Participation Rate
         </dl>
      </td>
__HTML_SUMMARY_EXPLANATION__

$explanation2 = <<__HTML_SUMMARY_EXPLANATION_2__ ;
<table width=660 cellpadding=18 align=center border=1>
<tr>
  $explanation
</tr>
</table>
__HTML_SUMMARY_EXPLANATION_2__

$header_all = <<__HTML_SUMMARY_HEADER_ALL__ ;
<a name='top' id='top'></a>
<table width=660 cellpadding=18 align=center border=1 style="background-color:white">
<tr>
  <td class=c colspan=99 width=100%>

    <table width=100% border=0>
    <tr>
      <td width=100% colspan=99>

        <table width=100% border=0>
        <tr>
          <td class=c width=80% valign=top>
            <h2>WMF Report Card <font color=$col_highlight>India</h2>
            INDEX
          </td>
        </tr>
        </table>

      </td>
    </tr>
    </table>
  </td>
<tr>
</table>
&nbsp;<p>
__HTML_SUMMARY_HEADER_ALL__

  $out_html_all = '' ;

  foreach $wp (@languages)
  {
    next if $skip {$wp} ;
    next if $wp =~ /^z+$/ ;

    $title_all = "WMF Report Card India" ;

    $out_html = &GetSummaryPerWiki ($wp) ;
    &GeneratePlotEditors   ($wp) ;
    &GeneratePlotPageviews ($wp) ;

    my $file_html = $path_out . "Summary" . ucfirst ($wp) . ".htm" ;
    print "Write $file_html\n" ;

    $out_html2 = $out_html ;

    $out_html2 =~ s/EXPLANATION// ;
    $out_html  =~ s/EXPLANATION/$explanation/ ;

    $out_html2 =~ s/EXPLANATION2/$explanation2/ ;
    $out_html  =~ s/EXPLANATION2// ;

    $out_html2 =~ s/SEE_ALSO// ;
    $out_html  =~ s/SEE_ALSO/$see_also/ ;

    $out_html  =~ s/SOURCE// ;
    $out_html2 =~ s/SOURCE/$source/ ;

    $out_html  =~ s/TOP/&nbsp;/ ;
    $out_html2 =~ s/TOP/<a href='#top'>top<\/a>&nbsp;&lArr;/ ;

    $out_html_all .= $out_html2 . "&nbsp;<p>" ;

$out_html = <<__HTML_SUMMARY_ONE__ ;
<html>
<head>
<title>Wikimedia project at a glance</title>
<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">
<meta name="robots" content="index,follow">
<script language="javascript" type="text/javascript" src="../WikipediaStatistics14.js"></script>
$out_style2
</head>
<body>
$out_html
</body>
</html>
__HTML_SUMMARY_ONE__

    open "FILE_OUT", ">", $file_html ;
    print FILE_OUT &AlignPerLanguage ($out_html) ;
    close "FILE_OUT" ;

    # last if $summaries_written++ > 3 # test
  }

$out_html_all = <<__HTML_SUMMARY_ALL__ ;
<html>
<head>
<title>$title_all</title>
<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">
<meta name="robots" content="index,follow">
<script language="javascript" type="text/javascript" src="../WikipediaStatistics14.js"></script>
$out_style2
</head>
<body>
$header_all
$out_html_all
$explanation2
</body>
</html>
__HTML_SUMMARY_ALL__

  &SummaryAddIndexes ;
  $out_html_all =~ s/INDEX/$index_html/ ;

  $file_html_all = $path_out . "ReportCardIndia.htm" ;
  open "FILE_OUT", ">", $file_html_all ;
  print FILE_OUT &AlignPerLanguage ($out_html_all) ;
  close "FILE_OUT" ;
}

sub GetSummaryPerWiki
{
  my $wp = shift ;

  my @months_en = qw (January February March April May June July August September October November December);

  my $html ;

  my $m = $MonthlyStatsWpStop {$wp} ;
  if ($month_max_incomplete)
  { $m-- ; }
  my $mmddyyyy = &m2mmddyyyy ($m) ;

  $month_year = $months_en [substr ($mmddyyyy,0,2)-1] . " " . substr ($mmddyyyy,6,4) ;
  my $out_language_name = $out_languages {$wp} ;

  my $main_page = &GetProjectBaseUrl ($wp) ;

  print "\n\n$wp:$out_language_name $out_publication\nmonth $m -> '$month_year' ;\n" ;
  $html = "\n" ;

  # page views

  $daysinmonth    = days_in_month (substr ($mmddyyyy,6,4), substr ($mmddyyyy,0,2)) ;
  $pageviews = sprintf ("%.0f", ($PageViewsPerHour {$wp} * 24 * 30)) ; # use normalized count (month always 30 days)
  $pageviews_day  = $pageviews / 30 ; # $daysinmonth ;
  $pageviews_hour = $pageviews_day / 24 ;
  $pageviews_min  = $pageviews_day / (24 * 60) ;
  $pageviews_sec  = $pageviews_day / (24 * 60 * 60) ;

  $this_month         = $pageviews ;
  $metric_PV_yearly   = "--" ;
  $metric_PV_monthly  = "--" ;

  print "DAYSINMONTH $month_year: $daysinmonth, PAGEVIEWS $pageviews\n" ;

  $metric_PV_data     = &FormatSummary ($this_month) ;

  $pageviews      = &format($pageviews,'X') ;
  $pageviews_day  = &format($pageviews_day,'X') ;
  $pageviews_hour = &format($pageviews_hour,'X') ;
  $pageviews_min  = &format($pageviews_min,'X') ;
  $pageviews_sec  = &format($pageviews_sec,'X') ;

  if ($pageviews_sec >= 1)
  { $pageviews_per_unit = "$pageviews/month = $pageviews_day /day = $pageviews_hour /hour = $pageviews_min /minute = $pageviews_sec /second" ; }
  elsif ($pageviews_min >= 1)
  { $pageviews_per_unit = "$pageviews/month = $pageviews_day /day = $pageviews_hour /hour = $pageviews_min /minute" ; }
  else
  { $pageviews_per_unit = "$pageviews/month = $pageviews_day /day = $pageviews_hour /hour " ; }
  $pageviews_per_unit =~ s/M/million/g ;
  $pageviews_per_unit =~ s/k/thousand/g ;
  $pageviews_per_unit =~ s/\// per /g ;

  # article count
  $this_month         = $MonthlyStats {$wp.$m.$c[4]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[4]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[4]} ;
  print "Article Count 0:$this_month, -1:$prev_month, -12:$prev_year\n" ;
  $metric_AC_yearly   = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_AC_monthly  = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_AC_data     = &FormatSummary ($this_month) ;

  # new articles per day
  $this_month         = $MonthlyStats {$wp.$m.$c[6]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[6]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[6]} ;
  $this_month =~ s/(\d)(\d\d\d)/$1,$2/g ;
  print "New Articles Per Day 0:$this_month, -1:$prev_month, -12:$prev_year\n" ;
  $metric_NAD_yearly  = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_NAD_monthly = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_NAD_data    = &FormatSummary ($this_month) ;

  # edits per month
  $this_month         = $MonthlyStats {$wp.$m.$c[11]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[11]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[11]} ;
  print "Edits Per Month 0:$this_month, -1:$prev_month, -12:$prev_year\n" ;
  $metric_EPM_yearly  = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_EPM_monthly = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_EPM_data    = &FormatSummary ($this_month) ;

  # active editors
  $this_month         = $MonthlyStats {$wp.$m.$c[2]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[2]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[2]} ;
  print "Active Editors 0:$this_month, -1:$prev_month, -12:$prev_year\n" ;
  $metric_AE_yearly   = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_AE_monthly  = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_AE_data     = &FormatSummary ($this_month) ;

  # very active editors
  $this_month         = $MonthlyStats {$wp.$m.$c[3]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[3]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[3]} ;
  print "Very Active Editors 0:$this_month, -1:$prev_month, -12:$prev_year\n" ;
  $metric_VAE_yearly  = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_VAE_monthly = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_VAE_data    = &FormatSummary ($this_month) ;

  # new editors
  $this_month         = $MonthlyStats {$wp.$m.$c[1]} ;
  $prev_month         = $MonthlyStats {$wp.($m-1).$c[1]} ;
  $prev_year          = $MonthlyStats {$wp.($m-12).$c[1]} ;
  print "New Editors 0:$this_month, -1:$prev_month, -12:$prev_year\n" ;
  $metric_NE_yearly   = &SummaryTrendChange ($this_month, $prev_year) ;
  $metric_NE_monthly  = &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_NE_data     = &FormatSummary ($this_month) ;

  # million speakers
  $speakers = $out_speakers {$wp} ;
  $editors  = $MonthlyStats {$wp.$m.$c[2]} ;
  print "SPEAKERS $speakers EDITORS $editors\n" ;
  if ($speakers == 0)
  { $participation = "" ; }
  elsif ($editors / $speakers >= 1)
  { $participation = sprintf ("%.0f", $editors / $speakers) ; }
  else
  { $participation = sprintf ("%.1f", $editors / $speakers) ; }

  $this_month         = $speakers ;
  $metric_MS_yearly   = '--&nbsp;&nbsp;&nbsp;&nbsp;'  ;
  $metric_MS_monthly  = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_MS_data     = &FormatSummary (sprintf ("%.0f", $this_month * 1000000)) ;

  # editors per million speakers
  $metric_EMS_yearly   = '--&nbsp;&nbsp;&nbsp;&nbsp;' ;
  $metric_EMS_monthly  = '--&nbsp;&nbsp;&nbsp;&nbsp;' ; # &SummaryTrendChange ($this_month, $prev_month) ;
  $metric_EMS_data     = $participation ;

  $out_style2 = $out_style ;
  $out_style2 =~ s/td   {white-space:nowrap;/td   {font-size:12px; white-space:nowrap;/ ;
  $out_style2 =~ s/body\s*\{.*?\}/body {font-family:arial,sans-serif;background-color:#C0C0C0}/ ;

  $plot_editors   = 'PlotEditors'   . uc ($wp) . '.png' ;
  $plot_pageviews = 'PlotPageviews' . uc ($wp) . '.png' ;

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
            <h2><a href='$main_page'><font color=$col_highlight>$out_language_name $out_publication</font></a></h2>
          </td>
          <td class=r width=20% valign=top><img src='WikimediaLogo.jpg' width=30></td>
        </tr>
        </table>

      </td>
    </tr>
    </table>

    <table width=100% border=0>
    <tr>
      <td class=l colspan=99 width=100%>
         <b>$out_language_name  $out_publication at a glance</b>&nbsp;<i>$month_year</i>&nbsp;&nbsp;<br>
         <small>Data are for last month with available database snapshots (dump system is recovering from backlog after server outage)</small>
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

          <tr>
            <td class=l>Speakers</td>
            <td class=r>$metric_MS_data</td>
            <td class=r>$metric_MS_yearly</td>
            <td class=r>$metric_MS_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

          <tr>
            <td class=l>Editors per Million Speakers</td>
            <td class=r>$metric_EMS_data</td>
            <td class=r>$metric_EMS_yearly</td>
            <td class=r>$metric_EMS_monthly</td>
          </tr>
          <tr>
            <td colspan=99><hr></td>
          </tr>

        </table>
      </td>
    </tr>

    <!--
    <tr>
      <td class=l colspan=99 width=100%>
      &nbsp;<p><b>Active Editors</b>
    </tr>
    -->
    <tr>
    <!--
      <td width=5%>
        &nbsp;
      </td>
      <td class=l colspan=99 width=95%>
    -->
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_editors'>
      </td>
    </tr>
    <tr>

    <!--
    <tr>
      <td class=l colspan=99 width=100%>
      &nbsp;<p><b>Page Views per Month</b><br>&nbsp;
    </tr>
    -->
    <tr>
    <!--
      <td width=5%>
        &nbsp;
      </td>
      <td class=l colspan=99 width=95%>
    -->
      <td class=c colspan=99 width=100%>
      &nbsp;<p><img src='$plot_pageviews'>
      </td>
    </tr>

EXPLANATION
SEE_ALSO
SOURCE
    </table>

  </td>
</tr>
</table>

__HTML_SUMMARY__

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
         &nbsp;<p><hr color=#808080>
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
    </tr>
__HTML_SUMMARY_SEE_ALSO__

$source = <<__HTML_SUMMARY_SOURCE__ ;
    <tr>
      <td colspan=99 class=c>
      <small><font color=#808080>page views: $pageviews_per_unit</font></small><p>
      <i><small>Source <a href='http://stats.wikimedia.org'>stats.wikimedia.org</a> / Published $summaries_published</small></i>
      </td>
    </tr>
__HTML_SUMMARY_SOURCE__

  return ($html) ;
}

sub GeneratePlotEditors
{
  my @months_en = qw (Jan Feby Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $wp = shift ;

  return if $wp =~ /^z+$/ ;

  &LogT ("GeneratePlotEditors $wp\n") ;

  my $file_csv_input    = $file_editors_per_wiki ;
  my $path_png_raw      = "$path_out_plots\/PlotEditors" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotEditorsTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotEditors" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_editors ;
  my $out_language_name = $out_languages {$wp} ;
  my $editors_max       = $editors_max_5 {$wp} ;
  my $month_max         = $editors_month_max_5 {$wp} ;
  my $code              = uc ($wp) ;

  $file_csv_input       =~ s/\\/\//g ;
  $path_png_raw         =~ s/\\/\//g ;
  $path_png_trends      =~ s/\\/\//g ;
  $path_svg             =~ s/\\/\//g ;
  $out_language_name    =~ s/&nbsp;/ /g ;

  open EDITORS_OUT, '>', $file_csv_input || &Abort ("Could not open file $file_csv_input") ;
  print EDITORS_OUT "language,month,count_5,count_25,count_100\n" ;
  print "$wp: " . (0+$editors_month_lo_5 {$wp}) . ", " . (0+$editors_month_hi_5 {$wp}) . "\n" ;

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
    $editors_max_rounded = 10000000000000 ;
    while ($editors_max_rounded / 10 > $editors_max)  { $editors_max_rounded /= 10 ; }

       if ($editors_max_rounded * 0.15 > $editors_max) { $editors_max_rounded *= 0.15 ; }
    elsif ($editors_max_rounded * 0.2 > $editors_max) { $editors_max_rounded *= 0.2 ; }
    elsif ($editors_max_rounded * 0.4 > $editors_max) { $editors_max_rounded *= 0.4 ; }
    elsif ($editors_max_rounded * 0.6 > $editors_max) { $editors_max_rounded *= 0.6 ; }
    elsif ($editors_max_rounded * 0.8 > $editors_max) { $editors_max_rounded *= 0.8 ; }
    print "$wp $editors_max -> $editorsmax_rounded\n" ;

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

  &LogT ("GeneratePlotPageviews $wp\n") ;

  my $file_csv_input    = $file_pageviews_per_wiki ;
  my $path_png_raw      = "$path_out_plots\/PlotPageviews" . uc($wp) . ".png" ;
  my $path_png_trends   = "$path_out_plots\/PlotPageviewsTrends" . uc($wp) . ".png" ;
  my $path_svg          = "$path_out_plots\/PlotPageviews" . uc($wp) . ".svg" ;
  my $out_script_plot   = $out_script_plot_pageviews ;
  my $out_language_name = $out_languages {$wp} ;
  my $pageviews_max     = $pageviews_max {$wp} ;
  my $month_max         = $pageviews_month_max {$wp} ;
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

  for ($m = $pageviews_month_lo {$wp} ; $m < $pageviews_month_hi {$wp} ; $m++)
  {
    $count_normalized = sprintf ("%.0f", $pageviews {$wp.$m} / $pageviews_unit) ;
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
  print "$wp $pageviews_max -> $pageviews_max_rounded\n" ;

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
  foreach $lang (sort {$out_languages {$a} cmp $out_languages {$b}} @languages)
  {
    next if $lang =~ /^z+$/ ;
    push @index_languages1, "<a href='#lang_$lang'>${out_languages {$lang}}</a>" ;
  }

  foreach $lang (sort @languages)
  {
    next if $lang =~ /^z+$/ ;
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
  $index_html = &HtmlIndex3 ; # in WikiReportsOutputEditHistory
  $index_html .= "<tr><td class=l><b>Projects indexed by <span id='caption'><font color=#006600>language</font> / <font color=#A0A0A0>language code</font></span></b></td><td class=r colspan=99><a href=\"#\" id='toggle' onclick=\"toggle_visibility_index();\">Toggle index</a></td></tr>\n" ;
  $index_html .= "<tr><td class=lwrap colspan=99>\n" .
                 "<span id='index1' style=\"display:block\">\n$index_languages1\n</span>\n" .
                 "<span id='index2' style=\"display:none\">\n$index_languages2\n</span>\n" .
               # "<span id='index3' style=\"display:none\">\n$index_languages3\n</span>" .
                 "</td></tr>\n" ;
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

  print "SM $now, $prev -> result $result\n" ;
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

1;
