#!/usr/bin/perl

sub WritePageViewsMonthly
{
  $wikimedia = $true ;

# $out_scriptfile  = "<script language=\"javascript\" type=\"text/javascript\" src=\"..\/WikipediaStatistics12.js\"></script>\n" .
#                    "<script language=\"javascript\" type=\"text/javascript\" src=\"..\/jquery-1.2.6.min.js\"></script>\n" .
#                    "<script language=\"javascript\" type=\"text/javascript\" src=\"..\/jquery.sparkline.js\"></script>\n" ;

  $legend_pageviews_monthly = "<table><tr>" ;
  $legend_pageviews_monthly .= &th ("<span class=d1>Yearly trend</span>") ;
  $legend_pageviews_monthly .= &td ("<table width=100% cellspacing=0 class=b style='margin-top:5px; border:solid 1px #000000'><tr><td class=cb bgcolor=#FFFFFF><span class=d1><b>r</b> th</span><br><span class=d2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>i</b> %</span></td></tr></table>") ;
  $legend_pageviews_monthly .= &td ("&nbsp;e.g.&nbsp;") ;
  $legend_pageviews_monthly .= &td ("<table width=100% cellspacing=0 class=b style='margin-top:5px; border:solid 1px #000000'><tr><td class=cb bgcolor=#FFE7E7><span class=d1><b>105</b> th</span><br><span class=d2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>+26</b> %</span></td></tr></table>") ;
  $legend_pageviews_monthly .= &td ("&nbsp;&nbsp;&nbsp;") ;
  $legend_pageviews_monthly .= &td ("<span class=d1><b>r</b> th=ranked yearly trend (compared to other languages)<br><b>i</b> %=increase in last year</span>") ;
  $legend_pageviews_monthly .= "</tr><tr>" ;
  $legend_pageviews_monthly .= &th ("<span class=d1>Monthly data</span>") ;
  $legend_pageviews_monthly .= &td ("<table width=100% cellspacing=0 class=b style='margin-top:5px; border:solid 1px #000000'><tr bgcolor=#FFFFFF><td class=cb><span class=d1><b>c</b>%,&nbsp;<b>s</b>%,&nbsp;<b>r</b> th</span><br><span class=d2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>v</b></span></td></tr></table>") ;
  $legend_pageviews_monthly .= &td ("&nbsp;e.g.&nbsp;") ;
  $legend_pageviews_monthly .= &td ("<table width=100% cellspacing=0 class=b style='margin-top:5px; border:solid 1px #000000'><tr bgcolor=#EFFFEF><td class=cb><span class=d1><b>+4</b>%,&nbsp;<b>4.21</b>%,&nbsp;<b>5</b> th</span><br><span class=d2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>765 M</b></span></td></tr></table>") ;
  $legend_pageviews_monthly .= &td ("&nbsp;&nbsp;&nbsp;") ;
  $legend_pageviews_monthly .= &td ("<span class=d1><b>c</b>%=change compared to previous month, &nbsp;<b>s</b>%=share of page views for this language, &nbsp;<b>r</b> th=rank this month<br>v=page views this month ($out_million = 10<sup>6</sup>, $out_thousand = 10<sup>3</sup>)</span>") ;
  $legend_pageviews_monthly .= "</tr></table>" ;

  &GenerateComparisonTable (0) ;

  if ($#languages > 25)
  { &GenerateTablePageviewsPerRange ; }

  &GenerateColophon ($true, $false) ;

  $out_html .= $out_script_embedded. "\n</body>\n</html>" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  if ($out_html =~ /<span id='wait'>/)
  {
    $out_html =~ s/<\/head>/$out_script_hide\n<\/head>/ ;
    $out_html =~ s/<(body[^\>]*)>/<$1 onLoad="hide('wait')">/ ;
  }

  my $file_html ;
  if ($pageviews_normal)
  {
    if ($normalize_days_per_month)
    { $file_html = $path_out . "TablesPageViewsMonthly.htm" ; }
    else
    { $file_html = $path_out . "TablesPageViewsMonthlyOriginal.htm" ; }
  }
  else # $pageviews_mobile
  {
    if ($normalize_days_per_month)
    { $file_html = $path_out . "TablesPageViewsMonthlyMobile.htm" ; }
    else
    { $file_html = $path_out . "TablesPageViewsMonthlyOriginalMobile.htm" ; }
  }

  print "\n\nFILE HTML '$file_html'\n\n" ;

  open "FILE_OUT", ">", $file_html || die "File '$file_html' could not be opened" ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

# store rendered html (header column and 'all languages' column = 'zz' = Sigma) for reuse on page views report for all projects
sub StoreHtmlPageviewsAllProjects
{
  my ($wp, $keys, $data) = @_ ;

  my ($source, $normalized) ;

  if ($mode_wx)
  { return if $wp ne 'commons' and $wp ne '' ; } # test here to keep call tidy
  else
  { return if $wp ne 'zz' and $wp ne '' ; } # test here to keep call tidy

  return if ! $pageviews ; # test here to keep call tidy

  $data =~ s/,/&comma;/g ;
  $data =~ s/\n/&linebreak;/g ;

  # print "\n$keys" ;
  if ($keys =~ /monthly,data_\d+/)
  {
    $data =~ s/100.00\%// ;
    $data =~ s/--// ;
  }
  push @csv_pageviews_all_projects, "$keys_html_pageviews_all_projects,$keys,$data\n" ;
# print "= $keys_html_pageviews_all_projects,,$keys,$data\n" ;
}

# write rendered html (header column and 'all languages' column = 'zz' = Sigma) for reuse on page views report for all projects
sub WriteMonthlyStatsHtmlAllProjects
{
  &LogT ("\nWriteMonthlyStatsHtmlAllProjects") ;

  my (@csv,$source, $normalized) ;

  open CSV, '<', $file_csv_pageviewsmonthly_html || abort ("Could not open file $file_csv_pageviewsmonthly_html") ;
  foreach $line (<CSV>)
  {
    next if $line =~ /^$keys_html_pageviews_all_projects,/ ;
    push @csv, $line ;
  }
  close CSV ;

  foreach $line (sort @csv_pageviews_all_projects)
  {
  # print "+ $line" ;
    push @csv, "$line" ;
  }

  # print "\n" ;
  # foreach $line (@csv)
  # { print "> $line" ; }
  # print "\n" ;

  open CSV, '>', $file_csv_pageviewsmonthly_html || abort ("Could not open file $file_csv_pageviewsmonthly_html") ;
  foreach $line (@csv)
  { print CSV $line ; }
  close CSV ;

  # print "\n" ;
}

1;

#V percentage 0% in onderste rij -> n.a. + kleur 0%
#  kleuren oprekken ?
#X normaliseren voor kleuring naar 30 dagen

#V werkt home button ?
#  zoom in/out, toggle colors, e.d.

#V forecast ??
#  rijen voor Q1 2008, etc

#  rijen voor day/hour/minutes/seconds

#  rijen perc. van totaal

#V slechte codes uitfilteren (zie helemaal rechts)

#V legenda M = million



#   wx juiste projecten selecteren, ook in WikiCountsVisitorsPerProjectPerDay.pl
#   meer macros in ...13.js

