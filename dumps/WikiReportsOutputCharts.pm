#!/usr/bin/perl

sub GenerateChartsPerWikipedia
{
  my $wp = shift ;
  my ($m, $year, $date) ;

  $factor_5   = $factors_5   {$wp} ;
  $factor_100 = $factors_100 {$wp} ;

  undef (%years) ;
  for ($m = $MonthlyStatsWpStart {$wp} ; $m <= $month_max ; $m++)
  {
    $date  = &m2mmddyyyy ($m) ;
    $year  = substr ($date,6,4) ;
    $years {$year} ++ ;
  }

  &GenerateHtmlStartWikipediaReport ($wp, "Charts", "") ;

# $out_html =~ s/-->/img { width: 10px ; }\n-->/ ;

  $out_html .= "<noscript><h3><font color='red'>Charts can not be displayed. " .
               "Please use a browser that supports javascript.</font></h3><hr></noscript>" ;

# if ($wikimedia && ($wp eq "en") && $mode_wp)
# { $out_html .= "<br><font color=#C00000>Note: for the English Wikipedia data for months after Sep 2006 are based on a partial database dump (only event meta data, no article contents).<br>" .
#                "Therefore some information for those months can not yet be shown.</font><p>" ; }
# elsif (($wp eq "zz") && $ReportLargeWikiDataMissing)
  if (($wp eq "zz") && $ReportLargeWikiDataMissing)
  {
    my $from  = &GetDateShort2En ($MonthlyStatsWpStopLo) ;
    if ($dumpmonth_ord - $MonthlyStatsWpStopLo <= 3)
    { $out_html .= "<font color=#800000>   Note: data for month(s) after $from for one or more large projects are not yet known.<br>" .
                   "For those month(s) totals for all languages combined can not yet be shown.   </font><p>" ; }
    else
    {
      if (! $mode_wp)
      { $out_html .= "<font color=#FF0000><b>Note: data for month(s) after $from for one or more large projects are not yet known.<br>" .
                     "For those month(s) totals for all languages combined can not yet be shown.<b></font><p>" ; }
      else
      { $out_html .= "<font color=#FF0000><b>Note: data for month(s) after $from for one or more large projects are not yet known.<br>" .
                     "For those month(s) totals for all languages combined can not yet be shown.<br>" .
                     "See also <a href='ChartsWikipediaZZZ.htm'>report version without the English Wikipedia.</a>" .
                     "<b></font><p>" ; }
    }
  }

  elsif ($wp eq "zzz")
  {
     my $from  = &GetDateShort2En ($MonthlyStatsWpStopLo) ;
     $out_html .= "<font color=#FF0000><b>Note: data for month(s) after $from for the English Wikipedia are not yet known.<br>" .
                  "This report shows totals without the English Wikipedia.<br>" .
                  "Switch back to <a href='ChartsWikipediaZZ.htm'>regular report version with recent months missing.</a>" .
                  "<b></font><p>" ;
  }

  if ($wikimedia)
  { $out_html .= blank_text_after ("15/08/2009", "<p><font color=#008000>". &b(ucfirst($out_new).": ") .
                 "July 2009: the method of counting contributors and new $out_publishers has changed. All wikis will be upgraded to this new scheme in coming weeks.<br>" .
                 "In the new scheme $out_publishers will only be included in contributors and new $out_publishers (first two charts) from the month in which they made their 10th edit, not the month in which they registered.</font><br>" ) ; }
  if ($wikimedia && ($wp eq "en") && $mode_wp)
  { $out_html .= blank_text_after ("15/08/2009", "<p><font color=#008000>" .
                 "The English Wikipedia uses this new scheme, other wikis will follow.</font><p>" ) ; }


  &GenerateLinkBar (1) ;
  &GenerateChart ($wp, 'Y', 0, $out_tbl3_hdr1a) ;
  &GenerateChart ($wp, 'Y', 1, $out_tbl3_hdr1a) ;
  &GenerateChart ($wp, 'Y', 2, $out_tbl3_hdr1a) ;
  &GenerateChart ($wp, 'Y', 3, $out_tbl3_hdr1a) ;

  &GenerateLinkBar (2) ;
  &GenerateChart ($wp, 'B', 4, $out_tbl3_hdr1e) ;

  if ($mode_wp)
  { &GenerateChart ($wp, 'B', 5, $out_tbl3_hdr1e) ; }

  &GenerateChart ($wp, 'B', 6, $out_tbl3_hdr1e) ;
  &GenerateChart ($wp, 'B', 7, $out_tbl3_hdr1e) ;
  &GenerateChart ($wp, 'B', 8, $out_tbl3_hdr1e) ;
  if ($mode_wp)
  {
    &GenerateChart ($wp, 'B', 9, $out_tbl3_hdr1e) ;
    &GenerateChart ($wp, 'B',10, $out_tbl3_hdr1e) ;
  }

  &GenerateLinkBar (3) ;
  &GenerateChart ($wp, 'R',11, $out_tbl3_hdr1l) ;
  &GenerateChart ($wp, 'R',12, $out_tbl3_hdr1l) ;
  &GenerateChart ($wp, 'R',13, $out_tbl3_hdr1l) ;

  &GenerateLinkBar (4) ;
  &GenerateChart ($wp, 'G',14, $out_tbl3_hdr1o) ;
  &GenerateChart ($wp, 'G',15, $out_tbl3_hdr1o) ;
  &GenerateChart ($wp, 'G',16, $out_tbl3_hdr1o) ;
  &GenerateChart ($wp, 'G',17, $out_tbl3_hdr1o) ;
  &GenerateChart ($wp, 'G',18, $out_tbl3_hdr1o) ;

# if ($wikimedia && ($mode_wp))
# {
#   &GenerateLinkBar (5) ;
#   &GenerateChart ($wp, 'V',19, $out_tbl3_hdr1t) ;
#   &GenerateChart ($wp, 'V',20, $out_tbl3_hdr1t) ;
# }

  &GenerateColophon ($false, $false) ;

  $out_html .= "\n$out_script_embedded\n</body>\n</html>" ;
  $file_html = $path_out . "ChartsWikipedia" . uc($wp) . ".htm" ;
  open "FILE_OUT", ">", $file_html || abort ("Output file " . $file_html . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub GenerateLinkBar
{
  $barndx = shift ;
  if ($barndx == 1)
  {
    $out_html .= "<a id='1' name='1'></a>\n" ;
    $out_html .= &b ($out_tbl3_hdr1a) . " - \n" ;
    $out_html .= "<a href='\#2'>". $out_tbl3_hdr1e . "</a> - \n" ;
    $out_html .= "<a href='\#3'>" . $out_tbl3_hdr1l . "</a> - \n" ;
    $out_html .= "<a href='\#4'>" . $out_tbl3_hdr1o . "</a>" ;
    if ($wikimedia && ($mode_wp))
    { $out_html .= " - \n<a href='\#5'>" . $out_tbl3_hdr1t . "</a>\n" ; }
  }
  if ($barndx == 2)
  {
    $out_html .= "<p><hr>" ;
    $out_html .= "<a id='2' name='2'></a><br>\n" ;
    $out_html .= "<a href='\#1'>" . $out_tbl3_hdr1a . "</a> - \n" ;
    $out_html .= &b ($out_tbl3_hdr1e) . " - \n" ;
    $out_html .= "<a href='\#3'>" . $out_tbl3_hdr1l . "</a> - \n" ;
    $out_html .= "<a href='\#4'>" . $out_tbl3_hdr1o . "</a>" ;
    if ($wikimedia && ($mode_wp))
    { $out_html .= " - \n<a href='\#5'>" . $out_tbl3_hdr1t . "</a>\n" ; }
  }
  if ($barndx == 3)
  {
    $out_html .= "<p><hr>" ;
    $out_html .= "<a id='3' name='3'></a><br>\n" ;
    $out_html .= "<a href='\#1'>" . $out_tbl3_hdr1a . "</a> - \n" ;
    $out_html .= "<a href='\#2'>" . $out_tbl3_hdr1e . "</a> - \n" ;
    $out_html .= &b ($out_tbl3_hdr1l . "</font>") . " - \n" ;
    $out_html .= "<a href='\#4'>" . $out_tbl3_hdr1o . "</a>" ;
    if ($wikimedia && ($mode_wp))
    { $out_html .= " - \n<a href='\#5'>" . $out_tbl3_hdr1t . "</a>\n" ; }
  }
  if ($barndx == 4)
  {
    $out_html .= "<p><hr>" ;
    $out_html .= "<a id='4' name='4'></a><br>\n" ;
    $out_html .= "<a href='\#1'>" . $out_tbl3_hdr1a . "</a> - \n" ;
    $out_html .= "<a href='\#2'>" . $out_tbl3_hdr1e . "</a> - \n" ;
    $out_html .= "<a href='\#3'>" . $out_tbl3_hdr1l . "</a> - \n" ;
    $out_html .= &b ($out_tbl3_hdr1o) ;
    if ($wikimedia && ($mode_wp))
    { $out_html .= " - \n<a href='\#5'>" . $out_tbl3_hdr1t . "</a>\n" ; }
  }
  if ($barndx == 5)
  {
    $out_html .= "<p><hr>" ;
    $out_html .= "<a id='5' name='5'></a><br>\n" ;
    $out_html .= "<a href='\#1'>" . $out_tbl3_hdr1a . "</a> - \n" ;
    $out_html .= "<a href='\#2'>" . $out_tbl3_hdr1e . "</a> - \n" ;
    $out_html .= "<a href='\#3'>" . $out_tbl3_hdr1l . "</a> - \n" ;
    $out_html .= "<a href='\#4'>" . $out_tbl3_hdr1o . "</a> - \n" ;
    $out_html .= &b ($out_tbl3_hdr1t) . "\n" ;
  }
  $out_html .= "<p>" ;
}

sub GenerateChart
{
  my $wp = shift ;
  my $colour = shift ;
  my $f = shift ;
  my $chart_category = shift ;
  my @values ;

  my $max = 0 ;
  my $line_html = "" ;
  for ($m = $MonthlyStatsWpStart {$wp} ; $m < $month_max ; $m++)
  {
    $value = $MonthlyStats {$wp.$m.$c[$f]} ;
    $value =~ s/\%// ;
    if ($value > $max)
    { $max = $value ; }
  # $month  = substr (&GetMonthShort($m),0,1) ;
    $month  = &GetMonthShort($m) ;
    $line_html .= "bar('$colour','$value','0','$month');\n" ;
  }

  $forecast = 0 ;
  $value = $MonthlyStats {$wp.$m.$c[$f]} ;
  $value =~ s/\%// ;
  if ($value > $max)
  { $max = $value ; }

  if ($show_forecasts)
  {
    $forecast = $MonthlyStats {$wp.($m+1).$c[$f]} ;
    $forecast =~ s/\%// ;
    if ($forecast > $max)
    { $max = $forecast ; }
    $forecast -= $value ;
    if ($forecast < 0)
    { $forecast = 0 }
    if ($forecast == 0) # not numeric -> 0
    { $forecast = 0 }
    if ($forecast eq "-")
    { $forecast = 0 }

#   $decimal = index ($value, ".") ;
#   if ($decimal != -1)
#   { $forecast = sprintf ("%.1f", $forecast) ; }
#   else
#   { $forecast = sprintf ("%.0f", $forecast) ; }
#   $forecast = &format ($forecast, $c[$f]) ;
  }

  $month  = &GetMonthShort($m) ;
  $line_html .= "bar('$colour','$value','$forecast','$month');\n" ;

  my $chart_title = $out_report_descriptions [$f] ;
  my $description = $out_tbl3_legend [$f] ;

  if ($description =~ / F\)/)
  { $description =~ s/\([^\)]*\)// ; }
  if (($f == 5) && (($wp eq "ja") || ($wp eq "zh") || ($wp eq "ko")))
 { $description =~ s/200/50/ ; }

  if (($f == 9) || ($f == 10))
  { $chart_title .= "&nbsp;(%)" ; }

  &GenerateChartPrefix  ($f, $max, $colour, $chart_category, $chart_title) ;
  $out_html .= $line_html ;
  &GenerateChartPostfix ($description);
}

sub GenerateChartPrefix
{
  my $f              = shift ;
  my $max            = shift ;
  my $chart_colour   = shift ;
  my $chart_category = shift ;
  my $chart_title    = shift ;
  if    ($chart_colour eq "Y") { $title_colour = "'#FFFF00'" ; }
  elsif ($chart_colour eq "R") { $title_colour = "'#FF0000'" ; }
  elsif ($chart_colour eq "B") { $title_colour = "'#0000FF'" ; }
  elsif ($chart_colour eq "G") { $title_colour = "'#00FF00'" ; }
  elsif ($chart_colour eq "V") { $title_colour = "'#FF0066'" ; }
  else                         { $title_colour = "'#808080'" ; }

  my $url_table = "Tables" . $report_names [$f] . ".htm" ;
#<font color=$title_colour>
  $out_html .=
  "<table height=90 cellSpacing=1 cellPadding=0 bgcolor=#000000 border=0 width=350 summary='Chart'>\n" .
  "<tbody>\n" .
  "<tr bgcolor=#AAAAAA height=16>\n" .
  "<td class=c>" . &b ("&nbsp;$chart_category - <a href='$url_table'>$chart_title</a>") . "&nbsp;</td></tr>\n" .
  "<tr valign=bottom bgcolor='#FFFFFF'>\n" .
  "<td class=chart>\n\n" .
  "<table cellSpacing=0 background='../background1.gif' cellPadding=0 border=0 summary=''>\n" .
  "<tbody>\n" .
#  "<td class=chart valign=bottom>\n\n" .
  "<noscript>&nbsp;<b><font color='red'>No javascript support!</font></b>&nbsp;</noscript>\n" .
  "<script>\n<!--\n" .
  "y_axis(" . $max . ",-1,'" . $out_month . "',1,'$out_thousands_separator','$out_decimal_separator');\n" .
  "document.write (\"<td class=chart_scale rowspan='4' bgcolor='#000000'><img height='1' src='../blanco.gif' width=1></td>\");\n\n" ;
}

sub GenerateChartPostfix
{
  my $description = shift ;
  my $out_years = "" ;
  $yearcnt = keys %years ;
  my $yearndx = 1 ;
#  @years {2003} = 12 ;
  foreach $year (sort keys %years)
  {
    my $monthes = $years{$year} ;
    if (($yearndx > 1) && ($yearndx < $yearcnt))
    { $columns = $monthes - 2 ; }
    else
    { $columns = $monthes - 1 ; }
    if ($columns > 0)
    {
      $out_years .=
      "<td class=chart colspan='$columns'>$year</td>" ;
    }
    if ($yearndx < $yearcnt)
    {
      $out_years .=
      "<td class=chart colspan='2'>|</td>" ;
    }
    $yearndx++ ;
  }

  $out_html .=
  "document.write (\"</tr><tr>" .
  "<td class=chart_scale colspan=2>" . $out_year . "&nbsp;</td>" .
  $out_years .
  "</tr>\");\n" .
  "//-->\n</script>\n" .
  "</tbody>\n" .
  "</table>\n\n" .
  "</td></tr>\n</tbody>\n</table>\n\n" .
  "<small>$description</small><p>\n" ;
}


1;
