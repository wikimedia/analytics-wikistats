#!/usr/bin/perl

# lijnen bij y = 0 beginnen
# database size tr loop uit grafiek

sub GetWp
{
  my $wp = shift ;
  $wp =~ s/\|.*$//g ;
  return ($wp) ;
}

# test Ploticus capabilities for this platform
sub PloticusDummyRun
{
  my $file_script = $path_in . "Ploticus.txt" ;

  open "FILE_OUT", ">", $file_script ;
  print FILE_OUT $out_ploticus_dummy ;
  close "FILE_OUT" ;

  &PloticusDummyRun2 ($file_script, "gif") ;
  &PloticusDummyRun2 ($file_script, "png") ;
  &PloticusDummyRun2 ($file_script, "svg") ;
  &PloticusDummyRun2 ($file_script, "svgz") ;
  &PloticusDummyRun2 ($file_script, "swf") ;
  &PloticusDummyRun2 ($file_script, "ps") ;
  &PloticusDummyRun2 ($file_script, "eps") ;
  &PloticusDummyRun2 ($file_script, "jpg") ;
  &PloticusDummyRun2 ($file_script, "wbmp") ;
}

sub PloticusDummyRun2
{
  my $file_script = shift ;
  my $format = shift ;
  my $file_plot = $path_out_plots . "PlotDummy.$format" ;
  my $cmd = "pl.exe -" . $format . " -o $file_plot $file_script" ;
  system ($cmd) ;
  if (-e $file_plot)
  {
    &Log ("\nFormat possibly supported (check output): $format") ;
    # unlink $file_plot ;
  }
  else
  { &Log ("\nFormat not supported: $format") ; }
}

sub GeneratePlotFiles {
  @plot_colors = ("rgb(1,0.2,0.2)",
                  "rgb(0.7,0.5,1)",
                  "rgb(0,0.7,0.9)",
                  "rgb(0.9,0.9,0)",
                  "rgb(1,0.5,0)",
                  "rgb(0,0.9,0.7)",
                  "rgb(0.2,0.2,1)",
                  "rgb(0,0.8,0.2)",
                  "rgb(0.9,0.8,0)",
                  "grey(0.85)") ;
  @plot_colors_CD = ("rgb(1,0,0)",   "rgb(0,0.9,0)",
                     "rgb(0,0,1)",   "rgb(0.9,0.9,0)") ;
  @plot_colors_L  = ("rgb(0.5,0.3,0.3)",   "rgb(1,0,0)",
                     "rgb(0.3,0.3,0.5)",   "rgb(0,0,1)",
                     "rgb(0.3,0.45,0.3)",  "rgb(0,1,0)") ;
  @plot_colors_UT = ("rgb(0.7,0.35,0.35)",   "rgb(1,0,0)",
                     "rgb(0.35,0.35,0.7)",   "rgb(0,0,1)",
                     "rgb(0.3,0.6,0.3)",   "rgb(0,1,0)",
                     "rgb(0.6,0.6,0.3)",   "rgb(1,1,0)") ;
#  @plot_colors_L = ("rgb(1,0,0)", "rgb(0.5,0.3,0.3)",
#                    "rgb(0,0,1)", "rgb(0.3,0.3,0.5)",
#                    "rgb(0,1,0)", "rgb(0.3,0.45,0.3)") ;
  if ($mode_wp)
  {
    if ($singlewiki)
  # { @report_columns = (0,2,3,4,5,11,12,14) ; } April 2010 : less trivia
    { @report_columns = (0,2,3,4,11,12) ; }
    else
  # { @report_columns = (0,2,3,4,5,11,12,14,15,20) ; }  April 2010 : less trivia
    { @report_columns = (0,2,3,4,11,20) ; }
  }
  else
  # { @report_columns = (0,2,3,4,11,12,14,15) ; } April 2010 : less trivia
  { @report_columns = (0,2,3,4,11) ; }

  %stats_X = %stats_A ;
  &GeneratePlotFiles2 (0) ;
  %stats_X = %stats_C ;
  &GeneratePlotFiles2 (2) ;
  %stats_X = %stats_D ;
  &GeneratePlotFiles2 (3) ;
  %stats_X = %stats_E ;
  &GeneratePlotFiles2 (4) ;
# if ($mode_wp) April 2010 : less trivia
#  {
#    %stats_X = %stats_F ;
#    &GeneratePlotFiles2 (5) ;
# }
  %stats_X = %stats_Lmax ;
  &GeneratePlotFiles2 (11) ;
# %stats_X = %stats_M ;
# &GeneratePlotFiles2 (12) ; April 2010 : less trivia
# %stats_X = %stats_O ;
# &GeneratePlotFiles2 (14) ; April 2010 : less trivia

# if (! $singlewiki)
# {
#   %stats_X = %stats_P ;
#   &GeneratePlotFiles2 (15) ; April 2010 : less trivia
# }

# %stats_X = %stats_Tmax ;
# &GeneratePlotFiles2 (19) ; ;
  if (($wikimedia) && ($mode_wp) && (! $singlewiki))
  {
    %stats_X = %stats_Umax ;
    &GeneratePlotFiles2 (20) ; ;
  }
  undef (%stats_X) ;
  undef (%stats_Y) ;
}

sub GeneratePlotFiles2 {
  my $f = shift ;
  my (@languages2, $out_links) ;
  undef @languages3 ;
  foreach $wp (@languages)
  { if ($wp ne "zz") { push @languages2, $wp ; }}
  $l = 1 ;
  foreach $wp (@languages2)
  { push @languages3, $wp . "|" . ++$l ; }

#  if (($f != 11) && ($f != 19) && ($f != 20))
#  { @languages3 = sort {@stats_X {&GetWp($b)} <=> @stats_X {&GetWp($a)}} @languages3 ; }
#  else
#  { @languages3 = sort {@stats_Y {&GetWp($b)} <=> @stats_Y {&GetWp($a)}} @languages3 ; }
  @languages3 = sort {@stats_X {&GetWp($b)} <=> @stats_X {&GetWp($a)}} @languages3 ;

  if ($debug)
  {
    if ($f == 11)
    {
      foreach $line (@languages3)
      {
        $wp2 = &GetWp ($line) ;
        &Log ("\n" . $wp2 . ": max=" . $stats_Lmax {$wp2} . ", avg=" . sprintf ("%.2f", $stats_Lavg {$wp2})) ;
      }
    }
    if ($f == 20)
    {
      foreach $line (@languages3)
      {
        $wp2 = &GetWp ($line) ;
        &Log ("\n" . $wp2 . ": max=" . $stats_Umax {$wp2} . ", avg=" . sprintf ("%.2f", $stats_Uavg {$wp2})) ;
      }
    }
  }

  undef (@links) ;

  $colmax = 8 ;
  if (($f == 2) || ($f == 3))
  { $colmax = 4 ; }
  if (($f == 11) || ($f == 20))
  { $colmax = 3 ; }

  $c   = 0 ;
  $p   = 1 ; # plot seq no -> e.g. PlotWikipediansContributors3.svg

  if (($mode_wp) || ($mode_wk))
  {
    $pmax = 7 ; # show no more than pmax plots on this page
  #  if ($f == 2)
  #  { $pmax = 5 ; }
    if ($f == 3)
    { $pmax = 5 ; }
    if (($f == 2) || ($f == 20))
    { $pmax = 10 ; }
  }
  else
  { $pmax = 4 ; }

  if (! $mode_wp) # wiktionary: limit plots per page on first months
  {
    if ($pmax > $dumpmonth_ord - 51)
    { $pmax = $dumpmonth_ord - 51 ; }
  }

  while (($c > -1) && ($p <= $pmax))
  { $c = &GeneratePlot ($f, $c, $p++, 3, $colmax) ; }
  if ($c < -1) { $p-- ; } # last call to GeneratePlot returned immediately

  $file_html_bitmap_alt = "PlotsPng" . $report_names [$f] . ".htm" ;
  $file_html_vector_alt = "PlotsSvg" . $report_names [$f] . ".htm" ;
  $file_html_bitmap = $path_out . $file_html_bitmap_alt ;
  $file_html_vector = $path_out . $file_html_vector_alt ;
  $format_bitmap = "Png" ;
  $format_vector = "Svg" ;

  &GenerateHtmlStartComparisonPlots ($format_bitmap, $format_vector,
                                     $file_html_vector_alt, $f) ;

# $out_html =~ s/FFFFDD/FFFFFF/g ;
  if (($mode_wp) && ($f == 20) && ($out_webalizer_note ne ""))
  { $out_html .= "<center>$out_webalizer_note</center>" ; }

  $tablewidth = 852 ;
  if ($p <= 4)
  { $tablewidth = 600 ; }

  $dir1 = "" ;
  $dir2 = "" ;
  if ($language eq "he")
  {
    $dir1 = "<div dir=ltr>" ;
    $dir2 = "</div>" ;
  }

  for ($i = 1 ; $i < $p ; $i++)
  {
    if ($pmax > 1)
    {
      $out_links = "\n<table width=$tablewidth summary='Navigate'><tr>\n<td align='left'><a href='\#0'>top<\/a></td>\n" ;
      for ($i2 = 1 ; $i2 < $p ; $i2++)
      {
        $filler = "" ;
        if (($p > 8) && ($i2 >= $p / 2) && (! ($out_links =~ /<\/tr>/)))
        { $out_links .= "</tr><tr><td>&nbsp;</td>" ; }
        if (($i2 == $p-1) && (! $mirror))
        { $filler = "&nbsp;&nbsp;" ; }

        if ($i2 != $i)
        { $out_links .= "<td align=center><a href='\#p$i2'>$dir1" . $i2 . ": " . $links [$i2-1] .
                         "$dir2</a>$filler</td>\n" ; }
        else
        { $out_links .= "<td align=center>$dir1" . $i2 . ": " . $links [$i2-1] .
                         "$dir2$filler</td>\n" ; }
      }
      $out_links .= "</tr></table>\n" ;

      if ($out_links =~ m/[\.\,]000[\.\,]000\)/)
      {
        $out_links =~ s/([\.\,]000[\.\,]000)\)/ M\)/g ;
        $out_links =~ s/([\.\,]000)\)/ K\)/g ;
      }
    }

    if ($singlewiki)
    { $out_links = "" ; }

    $out_html .= "<center><a name='p$i' id='p$i'>&nbsp;</a><br>" .
                 $out_links .
#                "<img src='Plots/Plot" . $report_names [$f] . $i . ".png' border='0' alt='Plot'>" .
                 "<img src='Plot" . $report_names [$f] . $i . ".png' border='0' alt='Plot'>" .
                 "</center><p><p>\n" ;
#   if ($i == 0)
#   { $out_links =~ s/\&nbsp\;/<a href='\#0'>top<\/a>/ ; }
  }

# $out_html =~ s/>top</&nbsp;/ ; # no need for top on first link line

  SetScriptImageFormat ("Png") ;
  &GenerateColophon ($false, $true) ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;

  $out_html .= "\n$out_script_embedded\n$out_script_embedded_imageformat\n</body>\n</html>" ;
  open "FILE_OUT", ">", $file_html_bitmap || abort ("Output file " . $file_html_bitmap . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;

  &GenerateHtmlStartComparisonPlots ($format_vector, $format_bitmap,
                                     $file_html_bitmap_alt, $f) ;

# $out_html =~ s/FFFFDD/FFFFFF/g ;

  $out_html =~ s/<\/head>/$out_script_hide\n<\/head>/ ;
  $out_html =~ s/<(body[^\>]*)>/<$1 onLoad="hide('wait')">/ ;

# $out_html .= "<center>" . $dir1 . $out_svg_viewer . $out_svg_firefox . $dir2 . "</center><p>\n" ;
  $out_html .= "<center>" . $dir1 . $out_svg_viewer . $dir2 . "</center><p>\n" ;

  # http://forum.chromefans.org/problem-with-span-p-and-style-display-none-t389.html
# $out_html .= "<span id='wait'><center><font color='green'>" . $out_rendering . "</font></center><p></span>" ;
  $out_html .= "<span id='wait'><center><font color='green'>" . $out_rendering . "</font></center></span><p>" ;

  if (($mode_wp) && ($f == 20) && ($out_webalizer_note ne ""))
  { $out_html .= "<center><p>$out_webalizer_note</center><p>" ; }

  for ($i = 1 ; $i < $p ; $i++)
  {
    if ($pmax > 1)
    {
      $out_links = "\n<table width=$tablewidth summary='Navigate'><tr>\n<td align='left'><a href='\#0'>top<\/a></td>\n" ;
      for ($i2 = 1 ; $i2 < $p ; $i2++)
      {
        $filler = "" ;
        if (($p > 8) && ($i2 >= $p / 2) && (! ($out_links =~ /<\/tr>/)))
        { $out_links .= "</tr><tr><td>&nbsp;</td>" ; }
        if (($i2 == $p-1) && (! $mirror))
        { $filler = "&nbsp;&nbsp;" ; }
        if ($i2 != $i)
        { $out_links .= "<td align=center><a href='\#p$i2'>$dir1" . $i2 . ": " . $links [$i2-1] . "$dir2</a>$filler</td>\n" ; }
        else
        { $out_links .= "<td align=center>$dir1" . $i2 . ": " . $links [$i2-1] . "$dir2$filler</td>\n" ; }
      }
      $out_links .= "</tr></table>\n" ;

      if ($out_links =~ m/[\.\,]000[\.\,]000\)/)
      {
        $out_links =~ s/([\.\,]000[\.\,]000)\)/ M\)/g ;
        $out_links =~ s/([\.\,]000)\)/ K\)/g ;
      }
    }

    if ($singlewiki)
    { $out_links = "" ; }

# use embed instead of object for svg files: http://www.alleged.org.uk/pdc/2002/svg-object.html <- no longer

    $out_html .= "<center>\n<a name='p$i' id='p$i'></a>\n" .
                 $out_links .
                 "<noscript>\n" .
                 "<noembed>\n" .
                 "your browser does not support embedded objects\n" .
                 "</noembed>\n" .
#                "<embed src='Plots/Plot" . $report_names [$f] . $i . ".svg' " . "name='SVGEmbed' \n" .
                 "<object data='Plot" . $report_names [$f] . $i . ".svg' " . "name='SVGEmbed' \n" .
                 "width='900' height='540' type='image/svg+xml'>\n" .
                 "<embed src='Plot" . $report_names [$f] . $i . ".svg' " . "name='SVGEmbed' \n" .
                 "width='900' height='540' type='image/svg+xml' pluginspage='http://www.adobe.com/svg/viewer/install/'>\n" .
                 "</object>\n" .
                 "</noscript>\n" .
#                "<script>\n<!--\nembedSvg('Plots/Plot" . $report_names [$f] . $i . ".svg');\n//-->\n</script> \n" .
                 "<script>\n<!--\nembedSvg('Plot" . $report_names [$f] . $i . ".svg');\n//-->\n</script> \n" .
                 "</center>\n\n" ;
#   if ($i == 0)
#   { $out_links =~ s/\&nbsp\;/<a href='\#0'>top<\/a>/ ; }
  }
# $out_html =~ s/>top</&nbsp;/ ; # no need for top on first link line

  SetScriptImageFormat ("Svg") ;
  &GenerateColophon ($false, $true) ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;

  $out_html .= "\n$out_script_embedded\n$out_script_embedded_imageformat\n</body>\n</html>" ;
  open "FILE_OUT", ">", $file_html_vector|| abort ("Output file " . $file_html_vector . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub GeneratePlot {
  my $f = shift ;
  my $c = shift ;
  my $p = shift ;
  my $cmin = shift ;
  my $cmax = shift ;
  my $columns ;
  my $ymax ;
  my $ymin ;

  $ymax = $stats_X {&GetWp ($languages3 [$c])} ;
# if (($f == 11) || ($f == 19) || ($f == 20))
  if (($f == 11) || ($f == 20))
  {
    $ymax2 = $stats_X {&GetWp ($languages3 [$c+1])} ;
    $ymax3 = $stats_X {&GetWp ($languages3 [$c+2])} ;
    if ($ymax2 > $ymax)
    { $ymax = $ymax2 ; }
    if ($ymax3 > $ymax)
    { $ymax = $ymax3 ; }
  }
  if (($f > 3) && ($ymax < 20))
  { return (-2) ; }
  if ($mode_wp)
  {
    if (($f == 11) && ($ymax < 50))
    { return (-2) ; }
  }

  $i = 1 ;
  while ($ymax > 100)
  { $i *= 10 ; $ymax /= 10 ; }
  $ymax = $i * int ($ymax + 0.99) ;
  $ymin = $ymax / 12 ;

  $clo = $c ;
  $chi = $c + $cmax - 1 ;
  if ($chi > $#languages3)
  { $chi = $#languages3 ; }
  # add a few columns if only few left to chart
  # if ($#languages3 - $chi <= 2)
  # { $chi = $#languages3 ; $cmax = 99 ;}

  # plot at most $cmax columns, till when y < ymin
  # plot at least $cmin columns, even when y < ymin

  $wp1 = &GetWp ($languages3 [$c]) ; # first wp on this chart
  for ($c2 = $c ; ($c2 <= $clo + $cmax-1) && ($c2 <= $chi) ; $c2++)
  {
    if ($chi < $#languages3)
    {
      if (($c2 > $clo + $cmin - 1) && ($stats_X {&GetWp ($languages3 [$c2])} < $ymin))
      { last ; }
    }
    $columns .= $languages3 [$c2] . "|" . $c2 . "," ;
    $wp2 = &GetWp ($languages3 [$c2]) ; # last wp on this chart
  }

  $columns =~ s/\,$// ;

  $desc = "$wp1 - $wp2" ;

  $ymax = &GeneratePlot2 ($f, $p, $c, $desc, $columns, $ymax) ;

  $ymax2 = $ymax ;
  $ymax2 =~ s/^(\d+)(\d\d\d)(\d\d\d)$/$1$out_thousands_separator$2$out_thousands_separator$3/ ;
  $ymax2 =~ s/^(\d?\d0)(000)$/$1$out_thousands_separator$2/ ;
  if ($wikimedia)
  { $link = "$desc (..$ymax2)" ; }
  else
  { $link = "..$ymax2" ; }

  push @links, $link ;

  if ($c2 >= $#languages) # signals last chart done
  { $c = -1 ; }
  else
  {
    if ($f == 11)
    { $c = $c + 3 ; }
#    else
#    if (($f == 19) || ($f == 20))
#    { $c = $c + 2 ; }
    else
    { # repeat columns with are close to bottom of chart on next chart
      for ($c = $c+1 ; $c < $chi ; $c++)
      { if ($stats_X {&GetWp ($languages3 [$c])} < ($ymax / 3)) { last ; } }
    }
  }

  return ($c) ;
}

sub RegisterField
{
  push @yfields, shift ;
  return ($#yfields+2) ; # yfield 1 = date, first data column = 2
}

sub SelectPlotData
{
  my $file_csv  = shift ;
  my $file_plot = shift ;
  my $zeros ;

  open "FILE_CSV",  "<", $file_csv ;
  open "FILE_PLOT", ">", $file_plot ;
  while (my $line = <FILE_CSV>)
  {
    chomp ($line) ;
    my @fields = split ("," , $line) ;
    if ($fields [0] eq "date") { next ; }
    $line = $fields [0] ;
    for (my $f = 0 ; $f <= $#yfields ; $f++)
    { $line .= "," . $fields [$yfields [$f]-1] ; }
    print FILE_PLOT $line . ",\n" ;
  }
  close "FILE_CSV" ;
  close "FILE_PLOT" ;
}

sub GeneratePlot2 {
  my $f        = shift ;
  my $p        = shift ;
  my $c        = shift ;
  my $desc     = shift ;
  my $columns  = shift ;
  my $yrange   = shift ;
  my $incstub  ; #= shift ;
  my $minortic ; #= shift ;

  my $out_script = $out_ploticus ;
  my $scale   = "" ;
  my $title1  = "" ;
  my $title2  = "" ;

  if ($language eq "ast")
  { $months = "Xin Feb Mar Abr May Xun Xnt Ago Set Oc Pay Avi" ; }
  elsif ($language eq "ca")
  { $months = "Gen Feb Mar Abr Mai Jun Jul Ago Set Oct Nov Dec" ; }
  elsif ($language eq "da")
  { $months = "jan feb mar apr maj jun jul aug sep okt nov dec" ; }
  elsif ($language eq "de")
  { $months = "Jan Feb M\xE4r Apr Mai Jun Jul Aug Sep Okt Nov Dez" ; }
  elsif ($language eq "eo")
  { $months = "jan feb mrt apr maj jun jul auxg sep okt nov dec" ; }
  elsif ($language eq "es")
  { $months = "Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dic" ; }
  elsif ($language eq "fr")
  { $months = "jan f\xE9v mar avr mai juin juil ao\xFCt sep oct nov d\xE9c" ; }
  elsif ($language eq "it")
  { $months = "Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dec" ; }
  elsif (($language eq "ja") || ($language eq "zh") || ($language eq "he") || ($language eq "ru") || ($language eq "cs"))
  { $months = "1 2 3 4 5 6 7 8 9 10 11 12" ; }
  elsif ($language eq "nl")
  { $months = "jan feb mrt apr mei jun jul aug sep okt nov dec" ; }
  elsif ($language eq "pl")
  { $months = "Sty Lut Mar Kwi Maj Cze Lip Sie Wrz Paz Lis Gru" ; } # actually Pa&zacute;
  elsif ($language eq "ro")
  { $months = "Ian Feb Mar Apr Mai Iun Iul Aug Sep Oct Nov Dec" ; }
  elsif ($language eq "sl")
  { $months = "jan feb mar apr maj jun jul avg sep okt nov dec" ; }
  elsif ($language eq "sv")
  { $months = "jan feb mar apr maj jun jul aug sep okt nov dec" ; }
  elsif ($language eq "wa")
  { $months = "Dja Fev Mas Avr May Djn Djl Awo Set Oct Nov Dec" ; }
  else # ($language eq "en")
  { $months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec" ; }

  if (($language ne "ja") && ($language ne "zh") && ($language ne "he") && ($language ne "ru") && ($language ne "pl") && ($language ne "cs"))
  {
    if ($f != 11)
    { $title1 = $out_report_descriptions [$f] ; }
    else
    { $title1 = $out_report_description_daily_edits ; }
    $title1 =~ s/(\&[^\;]{2,6}\;)/&HtmlToAscii($1)/ge ;
  }
  $title2 = $p . ": $desc" ;
  if ($singlewiki)
  { $title2 = "" ; }

  # make sure yrange and stub intervals are nice round figures

  $incstub     = 1 ;
  $incstubmult = 1 ;
  $incstubmax  = 12 ;

  while ($incstubmax * $incstub * $incstubmult < $yrange)
  {
    # Log ($incstub . " * " . $incstubmult . " < " . $yrange . "\n") ;
   if ($incstub == 1)
    {
      if ($incstubmult == 1)
      { $incstub = 5 ; }
      else
      { $incstub  = 2.5 ; }
      $incstubmax  = 10 ;
    }
    elsif ($incstub == 2.5)
    {
      $incstub  = 5 ;
      $incstubmax  = 10 ;
    }
    else
    {
      $incstub     = 1 ;
      $incstubmult *= 10 ;
      $incstubmax  = 12 ;
    }
  }

  $incstub  *= $incstubmult ;
  $minortic = 0 ;

  $yrange2 = 0 ;
  while ($yrange2 <= $yrange)
  { $yrange2 += $incstub ; }
  $yrange = $yrange2 ;

  if ($yrange > 10000000)
  {
    $incstub /= 1000000 ;
    $incstub .= " 1000000" ;
    $scale = "1000" . $out_thousands_separator . "000 x" ;
  }
  elsif ($yrange > 100000)
  {
    $incstub /= 1000 ;
    $incstub .= " 1000" ;
    $scale = "1000 x" ;
  }

  if ($mode_wb)
  { $xrangelo = "07/01/2003" ; }
  if ($mode_wk)
  { $xrangelo = "01/01/2003" ; }
  if ($mode_wn)
  { $xrangelo = "11/01/2004" ; }
  if ($mode_wp)
  { $xrangelo = "07/01/2001" ; }
  if ($mode_wq)
  { $xrangelo = "07/01/2003" ; }
  if ($mode_ws)
  { $xrangelo = "11/01/2003" ; }
  if ($mode_wv)
  { $xrangelo = "01/01/2005" ; }
  if ($mode_wx)
  { $xrangelo = "07/01/2001" ; }
  if (! $wikimedia)
  { $xrangelo = $plot_start ; }

  $monthinc = 1 ;

  $xrangehi = "$dumpmonth/$dumpday/$dumpyear" ;

  $yearlo = $xrangelo ;
  $yearhi = $xrangehi ;
  $yearlo =~ s/.*\/(\d+)$/$1/ ;
  $yearhi =~ s/.*\/(\d+)/$1/ ;
  if (($yearhi - $yearlo) >= 4)
  { $monthinc = 2 ; }
  if (($yearhi - $yearlo) >= 8)
  { $monthinc = 3 ; }

  $out_script =~ s/MONTHS/$months/ ;
  $out_script =~ s/MONTHINC/$monthinc/ ;
  $out_script =~ s/XRANGELO/$xrangelo/ ;
  $out_script =~ s/XRANGEHI/$xrangehi/ ;
  $out_script =~ s/YRANGE/$yrange/ ;
  $out_script =~ s/INCSTUB/$incstub/ ;
# $out_script =~ s/MINORTIC/$minortic/ ;
  $out_script =~ s/TITLE1/$title1/ ;
  $out_script =~ s/TITLE2/$title2/ ;
  $out_script =~ s/SCALE/$scale/ ;

  my $file_csv ;

#  if (($f == 0) || ($f == 1) || ($f == 3))
#  { $file_csv = $path_in . $report_names [$f] . ".csv" ; }
#  else
#  { $file_csv = $path_in . "InputPloticus_" . @c[$f] . ".csv" ; }
  $file_csv  = $path_in . "InputPloticus_" . $c[$f] . ".csv" ;
  $file_plot = $path_in . "InputPloticusTemp.csv" ;
  $out_script =~ s/FILE/$file_plot/ ;
  my $file_script = $path_in . "Ploticus.txt" ;

  my $procs_plot   = "" ;
  my $procs_plot2  = "" ;
  my $proc_legend  = "#proc legend\n" .
                     "  seglen:   0.15\n" .
                     "  sep:      0.15\n" .
                     "  textdetails: adjust=-0.03,0.02\n" .
                     "  location: min+0.4 max-0.1\n" .
                     "  noclear: yes\n" .
                     "  colortext: yes\n" .
                     "  specifyorder:\n" ;
  my $legend_height = 0.17 ;
  my $legend_width  = 0.6 ;
  if (! $wikimedia)
  { $legend_width  = $plot_legend_width ; }
  if ($mode_wx)
  { $legend_width  = 1.25 ; }


  my @columns = split (",", $columns) ;
  $colcnt = 0 ;
  $style  = 0 ;
  $clusters = $#columns +  1 ;
  undef (@yfields) ;
  foreach $column (@columns)
  {
    my ($wp, $yfield, $c2) = split ('\|', $column) ;
    my $wpc = $wp ;
    # if ($wp eq "simple")
    # { $wpc = "se" ; }

    if (($f == 2) || ($f == 3))
    { $color = @plot_colors_CD [$c2 % 4] ; }
    else
    { $color = @plot_colors [$c2 % 8] ; }
    if ($colcnt++ > 9)
    { $style = 1 ; }
    $width = "1.4" ;

#   if (($f == 11) || ($f == 19) || ($f == 20))
    if (($f == 11) || ($f == 20))
    {
      my $repeat_on_next_chart = $false ;
      if (($f == 20) &&
          (($stats_X {$wp} < $yrange / 3) || ($colcnt > 2)))
      { $repeat_on_next_chart = $true ; }

      if (! $repeat_on_next_chart) # else show daily figures on next graph
      {
        if ($f == 11)
        { $color = (@plot_colors_L  [2 * ($colcnt - 1)]) ; }
        else
        { $color = (@plot_colors_UT [2 * (($c + $colcnt - 1) % 4)]) ; }

  #     { $color = (@plot_colors_UT [2 * ($c % 3)]) ; }

        $procs_plot  .= "#proc lineplot\n" .
                        "  gapmissing: yes\n" .
                        "  xfield: 1\n" .
                        "  yfield: " . &RegisterField ($yfield * 2) . "\n" .
                        "  clip: yes\n " .
                        "  linedetails: width=0.5 style=$style color=$color\n" .
                        "  legendlabel: " . $wpc . "\n\n" ;
        $proc_legend .= "  " . $wpc . "\n" ;
        $legend_height += 0.155 ;
      }

      if ($f == 11)
      { $color = (@plot_colors_L [2 * ($colcnt - 1) + 1]) ; }
      else
      { $color = (@plot_colors_UT [2 * (($c + $colcnt - 1) % 4) + 1]) ; }

      if (($f == 11) || ($f == 20))
      {
        $width = 1.5 ;
        # if ($repeat_on_next_chart)
        # { $width = 0.5 ; }

        $procs_plot2 .= "#proc lineplot\n" .
                        "  gapmissing: yes\n" .
                        "  xfield: 1\n" .
                        "  yfield: " . &RegisterField($yfield * 2 + 1). "\n" .
                        "  clip: yes\n " .
                        "  linedetails: width=$width style=$style color=$color\n" .
                        "  legendlabel: " . $wpc . " avg\n\n" ;
        $proc_legend .= "  " . $wpc . " avg\n" ;
        $legend_height += 0.155 ;
        $legend_width   = 0.8 ;
      }
    }
    else
    {
      $procs_plot  .= "#proc lineplot\n" .
                      "  gapmissing: yes\n" .
                      "  xfield: 1\n" .
                      "  yfield: " . &RegisterField($yfield) . "\n" .
                      "  clip: yes\n " .
                      "  linedetails: width=$width style=$style color=$color\n" .
                     (($f == 1) ? "  stairstep: yes\n" : "") .
                      "  legendlabel: " . $wpc . "\n\n" ;
      $proc_legend .= "  " . $wpc . "\n" ;
      $legend_height += 0.155 ;
    }
  }
  $proc_rect = "#proc rect\n" .
               "color: gray(0.1)\n" .
               "rectangle: min+0.02 max-0.02 min+$legend_width max-$legend_height\n" ;

  $procs_plot .= $procs_plot2 ;
  $out_script =~ s/PROCSPLOT/$procs_plot/ ;

  if ($singlewiki)
  {
    $out_script =~ s/PROCRECT// ;
    $out_script =~ s/PROCLEGEND// ;
  }
  else
  {
    $out_script =~ s/PROCRECT/$proc_rect/ ;
    $out_script =~ s/PROCLEGEND/$proc_legend/ ;
  }

  &SelectPlotData ($file_csv, $file_plot) ;
  open "FILE_SCRIPT", ">", $file_script ;
  print FILE_SCRIPT $out_script ;
  close "FILE_SCRIPT" ;
  &InvokePloticus ($f, $p, "png", $file_script) ;

  $out_script =~ s/backgroundcolor: gray\(0\.9\)/backgroundcolor: gray(0.95)/ ;
  open "FILE_SCRIPT", ">", $file_script ;
  print FILE_SCRIPT $out_script ;
  close "FILE_SCRIPT" ;
  &InvokePloticus ($f, $p, "svg", $file_script) ;

  $file_svg = "$path_out_plots" . "Plot" . $report_names [$f] . $p . ".svg" ;

  open  FILE_PLOT, "<", $file_svg ;
  @plot = <FILE_PLOT> ;
  close FILE_PLOT ;

  foreach $line (@plot)
  {
    $line =~ s/<text /<text font-size="6" /g ;
    $line =~ s/<text font-size="6"  font-size="6" /<text font-size="6" /g ;
  }

  open  FILE_PLOT, ">", $file_svg ;
  print FILE_PLOT @plot ;
  close FILE_PLOT ;

# unlink $file_script ;

  return ($yrange) ;
}

sub InvokePloticus {
  my $f     = shift ;
  my $p     = shift ;
  my $fmt   = shift ;
  my $file_script = shift ;

  if (($fmt eq "png") && defined ($gif2png))
  { $fmt = "gif" ; }

  my $file_plot   = "Plot" . $report_names [$f] . $p . "." . $fmt ;
  my $path_plot = "$path_out_plots$file_plot" ;

  # my $cmd = $path_pl . "pl -" . $fmt . " -o '$path_out_plots$file_plot' '$file_script' -tightcrop" ;
  my $cmd = $path_pl . "pl -" . $fmt . " -o \"$path_plot\" \"$file_script\" -tightcrop" ;

  if (($p == 1) && (($fmt eq "gif") || ($fmt eq "png")))
  { &Log ("\nPlot " . $report_names [$f] . "...\n") ; }

  &Log (" $p" . substr ($fmt,0,1)) ;
  system ($cmd) ;

  if (($fmt eq "gif") && (defined ($gif2png)))
  {
    if (-e $path_plot)
    {
   #   $cmd = "nconvert -out png '$path_out_plots$file_plot'" ;
      $cmd = "nconvert -out png \"$path_plot\"" ;
      system ($cmd) ;
  #   unlink $path_out_plots . $file_plot ;
      unlink $path_plot ;
    }
    else
    { &Log ("InvokePloticus: file $path_plot not found.\n") ; }
  }
}


sub GeneratePlotDataFiles {
  my $dumpdate = sprintf ("%2d/%2d/%4d", $dumpmonth, $dumpday, $dumpyear) ;
  $dumpdate = &mmddyyyyDec ($dumpdate) ;

  &GeneratePlotDataFilesX ($file_csv_edits_per_day, "InputPloticus_L.csv") ;
  %stats_Lmax = %stats_Xmax ;
  %stats_Lavg = %stats_Xavg ;

# &GeneratePlotDataFilesX ($file_csv_web_requests_daily, "InputPloticus_T.csv") ;
# %stats_Tmax = %stats_Xmax ;
# %stats_Tavg = %stats_Xavg ;

  &GeneratePlotDataFilesX ($file_csv_web_visits_daily, "InputPloticus_U.csv") ;
  %stats_Umax = %stats_Xmax ;
  %stats_Uavg = %stats_Xavg ;

################################################################################

  &ReadFileCsv ($file_csv_stats_ploticus) ;

if ($false) # test only: fake en data, dump too large to download
{
  undef @csv2 ;
  foreach $line (@csv)
  {
    ($wp, $date, @fields) = split (",", $line) ;
    if ($wp eq "zz") { next ; }
    if ($wp eq "en") { next ; }
    push @csv2, $line ;
    if ($wp eq "de")
    {
      $fields[0] = 5 * $fields[0] ;
      $fields[1] = 5 * $fields[1] ;
      $wp = "en" ;
      $line = join (",", ($wp, $date, $fields)) ;
      push @csv2 , $line ;
    }
  }
  @csv = @csv2 ;
  undef (@csv2) ;
}

  @csv = sort {&csvkey_date ($a) cmp &csvkey_date ($b)} @csv ;
  open "FILE_E", ">", $path_in . "InputPloticus_E.csv" ;
  open "FILE_F", ">", $path_in . "InputPloticus_F.csv" ;
  open "FILE_K", ">", $path_in . "InputPloticus_K.csv" ;
# open "FILE_L", ">", $path_in . "InputPloticus_L.csv" ;
  open "FILE_M", ">", $path_in . "InputPloticus_M.csv" ;
  open "FILE_N", ">", $path_in . "InputPloticus_N.csv" ;
  open "FILE_O", ">", $path_in . "InputPloticus_O.csv" ;
  open "FILE_P", ">", $path_in . "InputPloticus_P.csv" ;

  $line_csv_header = "date," ;
  foreach $wp (@languages)
  {
    if ($wp eq "zz") { next ; }
    $line_csv_header .= &csv ($wp) ;
  }
  $line_csv_header .= "\n" ;
  print FILE_E $line_csv_header ;
  print FILE_F $line_csv_header ;
  print FILE_K $line_csv_header ;
  print FILE_M $line_csv_header ;
  print FILE_N $line_csv_header ;
  print FILE_O $line_csv_header ;
  print FILE_P $line_csv_header ;

  undef (%stats) ;

  my $lines = -1 ;
  my ($wp, $prev_date) = split (",", $csv [0]) ;
  my ($date, $fields) ;
  foreach $line (@csv)
  {
    $lines ++ ;
    ($wp, $date, @fields) = split (",", $line) ;
    if ($wp eq "zz") { next ; }
    undef (%stats) ;
    $stats_E  {$wp} = $fields [0] ;
    $stats_F  {$wp} = $fields [1] ;
#   $stats_L  {$wp} = $fields [2] ;
    $stats_M  {$wp} = $fields [3] ;
    $stats_N  {$wp} = $fields [4] ;
    $stats_O  {$wp} = $fields [5] ;
    $stats_P  {$wp} = $fields [6] ;

    $stats_L0 {$wp} = $stats_L1 {$wp} ;
    $stats_L1 {$wp} = $stats_L2 {$wp} ;
    $stats_L2 {$wp} = $stats_L3 {$wp} ;
    $stats_L3 {$wp} = $fields [2] ;
    $stats_L  {$wp} = sprintf ("%.0f", (($stats_L3 {$wp}-$stats_L0 {$wp}))/9) ;
    if ($stats_L {$wp} > $stats_Lmax {$wp})
    { $stats_Lmax {$wp} = $stats_L {$wp} ; }

#    $stats_T0 {$wp} = $stats_T1 {$wp} ;
#    $stats_T1 {$wp} = $stats_T2 {$wp} ;
#    $stats_T2 {$wp} = $stats_T3 {$wp} ;
#    $stats_T3 {$wp} = $fields [2] ;
#    $stats_T  {$wp} = sprintf ("%.0f", (($stats_T3 {$wp}-$stats_T0 {$wp}))/9) ;
#    if ($stats_T {$wp} > $stats_Tmax {$wp})
#    { $stats_Tmax {$wp} = $stats_T {$wp} ; }

#    $stats_U0 {$wp} = $stats_U1 {$wp} ;
#    $stats_U1 {$wp} = $stats_U2 {$wp} ;
#    $stats_U2 {$wp} = $stats_U3 {$wp} ;
#    $stats_U3 {$wp} = $fields [2] ;
#    $stats_U  {$wp} = sprintf ("%.0f", (($stats_U3 {$wp}-$stats_U0 {$wp}))/9) ;
#    if ($stats_U {$wp} > $stats_Umax {$wp})
#    { $stats_Umax {$wp} = $stats_U {$wp} ; }

#   if (($lines % 2) == 0)
#   {
#     $stats_L  {$wp} = sprintf ("%.0f", ($fields [2]-$prev_L {$wp})/3) ;
#     if ($stats_L {$wp} > $stats_Lmax {$wp})
#     { $stats_Lmax {$wp} = $stats_L {$wp} ; }
#     $prev_L {$wp} = $fields [2] ;
#   }
    if (($date ne $prev_date) || ($lines == $#csv))
    {
      if ((substr ($prev_date,6,4) == $dumpyear) &&
          (substr ($prev_date,0,2) == $dumpmonth) &&
          (substr ($prev_date,3,2) > $dumpday))
      { $prev_date = sprintf ("%02d/%02d/%04d", $dumpmonth, $dumpday, $dumpyear) ; }
      $line_csv_E = &csv ($prev_date) ;
      $line_csv_F = &csv ($prev_date) ;
      $line_csv_K = &csv ($prev_date) ;
#     $line_csv_L = &csv ($prev_date) ;
      $line_csv_M = &csv ($prev_date) ;
      $line_csv_N = &csv ($prev_date) ;
      $line_csv_O = &csv ($prev_date) ;
      $line_csv_P = &csv ($prev_date) ;
      foreach $wp (@languages)
      {
        if ($wp eq "zz") { next ; }

#        $line_csv_E .= ($stats_E {$wp} > 0) ? &csv ($prev_E} : &csv2 ($prev_E} ;
#        $line_csv_F .= ($stats_F {$wp} > 0) ? &csv ($prev_F} : &csv2 ($prev_F} ;
#        $line_csv_K .= ($stats_K {$wp} > 0) ? &csv ($prev_K} : &csv2 ($prev_K} ;
##       $line_csv_L .= ($stats_L {$wp} > 0) ? &csv ($prev_L} : &csv2 ($prev_L} ;
#        $line_csv_M .= ($stats_M {$wp} > 0) ? &csv ($prev_M} : &csv2 ($prev_M} ;
#        $line_csv_N .= ($stats_N {$wp} > 0) ? &csv ($prev_N} : &csv2 ($prev_N} ;
#        $line_csv_O .= ($stats_O {$wp} > 0) ? &csv ($prev_O} : &csv2 ($prev_O} ;
#        $line_csv_P .= ($stats_P {$wp} > 0) ? &csv ($prev_P} : &csv2 ($prev_P} ;

#        $prev_E = $stats_E {$wp} ;
#        $prev_F = $stats_F {$wp} ;
#        $prev_K = $stats_K {$wp} ;
##       $prev_L = $stats_L {$wp} ;
#        $prev_M = $stats_M {$wp} ;
#        $prev_N = $stats_N {$wp} ;
#        $prev_O = $stats_O {$wp} ;
#        $prev_P = $stats_P {$wp} ;

        $line_csv_E .= &csv3 ($stats_E {$wp}) ;
        $line_csv_F .= &csv3 ($stats_F {$wp}) ;
        $line_csv_K .= &csv3 ($stats_K {$wp}) ;
#       $line_csv_L .= &csv3 ($stats_L {$wp}) ;
        $line_csv_M .= &csv3 ($stats_M {$wp}) ;
        $line_csv_N .= &csv3 ($stats_N {$wp}) ;
        $line_csv_O .= &csv3 ($stats_O {$wp}) ;
        $line_csv_P .= &csv3 ($stats_P {$wp}) ;
      }
      $line_csv_E =~ s/,$// ;
      $line_csv_F =~ s/,$// ;
      $line_csv_K =~ s/,$// ;
#     $line_csv_L =~ s/,$// ;
      $line_csv_M =~ s/,$// ;
      $line_csv_N =~ s/,$// ;
      $line_csv_O =~ s/,$// ;
      $line_csv_P =~ s/,$// ;
      print FILE_E $line_csv_E . "\n" ;
      print FILE_F $line_csv_F . "\n" ;
      print FILE_K $line_csv_K . "\n" ;
#     print FILE_L $line_csv_L . "\n" ;
      print FILE_M $line_csv_M . "\n" ;
      print FILE_N $line_csv_N . "\n" ;
      print FILE_O $line_csv_O . "\n" ;
      print FILE_P $line_csv_P . "\n" ;
    }
    $prev_date = $date ;
  }

  close "FILE_E" ;
  close "FILE_F" ;
  close "FILE_K" ;
# close "FILE_L" ;
  close "FILE_M" ;
  close "FILE_N" ;
  close "FILE_O" ;
  close "FILE_P" ;

#  &MarkFirstEntry ("InputPloticus_E.csv") ;
#  &MarkFirstEntry ("InputPloticus_F.csv") ;
#  &MarkFirstEntry ("InputPloticus_K.csv") ;
#  &MarkFirstEntry ("InputPloticus_L.csv") ;
#  &MarkFirstEntry ("InputPloticus_M.csv") ;
#  &MarkFirstEntry ("InputPloticus_N.csv") ;
#  &MarkFirstEntry ("InputPloticus_O.csv") ;
#  &MarkFirstEntry ("InputPloticus_P.csv") ;

  &ReadFileCsv ($file_csv_weekly_stats) ;

if ($false) # test only: fake en: data (dump is too large to download)
{
  undef @csv2 ;
  foreach $line (@csv)
  {
    ($wp, $date, @fields) = split (",", $line) ;
    if ($wp eq "zz") { next ; }
    if ($wp eq "en") { next ; }
    push @csv2, $line ;
    if ($wp eq "de")
    {
      $fields[0] = 5 * $fields[0] ;
      $fields[1] = 5 * $fields[1] ;
      $fields[2] = 3 * $fields[2] ;
      $fields[3] = 3 * $fields[3] ;
      $wp = "en" ;
      $line = join (",", ($wp, $date, @fields)) ;
      push @csv2 , $line ;
    }
  }
  @csv = @csv2 ;
  undef (@csv2) ;
}

  @csv = sort {&csvkey_date ($a) cmp &csvkey_date ($b)} @csv ;

  open "FILE_A", ">", $path_in . "InputPloticus_A.csv" ;
  open "FILE_C", ">", $path_in . "InputPloticus_C.csv" ;
  open "FILE_D", ">", $path_in . "InputPloticus_D.csv" ;

  print FILE_A $line_csv_header ;
  print FILE_C $line_csv_header ;
  print FILE_D $line_csv_header ;

  undef (%stats) ;
  undef ($plot_date) ;
  my ($plot_day, $plot_month, $plot_year );
  my ($prev_day, $prev_month , $diff_days) ;
  my $lines = -1 ;
  my ($wp, $prev_date) = split (",", $csv [0]) ;
  my ($date, @fields) ;

  foreach $line (@csv)
  {
    $lines ++ ;
    ($wp, $date, @fields) = split (",", $line) ;
    if ($wp eq "zz") { next ; }
    if ($fields[0] == 0) { next ; }  # no contributors yet (10+ edits)
    undef (%stats) ;

    $field_A_prev {$wp} = $field_A {$wp} ;
    $field_C_prev {$wp} = $field_C {$wp} ;
    $field_D_prev {$wp} = $field_D {$wp} ;
    $field_A {$wp} = $fields [0] ;
    $field_C {$wp} = $fields [2] ;
    $field_D {$wp} = $fields [3] ;
    if ($field_A_prev {$wp} > $stats_A {$wp})
    { $stats_A {$wp} = $field_A_prev {$wp} ; }
    if ($field_C_prev {$wp} > $stats_C {$wp})
    { $stats_C {$wp} = $field_C_prev {$wp} ; }
    if ($field_D_prev {$wp} > $stats_D {$wp})
    { $stats_D {$wp} = $field_D_prev {$wp} ; }

    if (($date ne $prev_date) || ($lines == $#csv))
    {
      # do not plot (very) active users for partial last week
      # ignore entries less then 7 days apart
      if (length ($plot_date) == 10)
      {
        #print "defined plot_date\n" ;
        $plot_day   = substr ($plot_date,3,2) ;
        $plot_month = substr ($plot_date,0,2) ;
        $plot_year  = substr ($plot_date,6,4) ;
        $prev_day   = substr ($prev_date,3,2) ;
        $prev_month = substr ($prev_date,0,2) ;
        if ($plot_month == $prev_month)
        { $diff_days = $prev_day - $plot_day ; }
        else
        { $diff_days = $prev_day + days_in_month ($plot_year, $plot_month) - $plot_day ; }
      }
      else
      { $diff_days = 7 ; }

      if ((length ($prev_date) == 10) && (($diff_days >= 7) || ($lines == $#csv)))
      {
        if ((substr ($prev_date,6,4) == $dumpyear) &&
            (substr ($prev_date,0,2) == $dumpmonth) &&
            (substr ($prev_date,3,2) > $dumpday))
        { $prev_date = sprintf ("%02d/%02d/%04d", $dumpmonth, $dumpday, $dumpyear) ; }

        $line_csv_A = &csv ($prev_date) ;
        $line_csv_C = &csv ($prev_date) ;
        $line_csv_D = &csv ($prev_date) ;

        foreach $wp (@languages)
        {
          if ($wp eq "zz") { next ; }

          if ($field_A_prev {$wp} > $field_csv_A_max {$wp})
          { $field_csv_A_max {$wp} = $field_A_prev {$wp} ; }

          if ($field_C_prev {$wp} > $field_csv_C_max {$wp})
          { $field_csv_C_max {$wp} = $field_C_prev {$wp} ; }

          if ($field_D_prev {$wp} > $field_csv_D_max {$wp})
          { $field_csv_D_max {$wp} = $field_D_prev {$wp} ; }

          $line_csv_A .= &csv3 ($field_A_prev {$wp}) ;

          if ($field_csv_C_max {$wp} > 0)
          { $line_csv_C .= &csv ($field_C_prev {$wp}) ; }
          else
          { $line_csv_C .= &csv3 ($field_C_prev {$wp}) ; }

          if ($field_csv_D_max {$wp} > 0)
          { $line_csv_D .= &csv ($field_D_prev {$wp}) ; }
          else
          { $line_csv_D .= &csv3 ($field_D_prev {$wp}) ; }
        }

        $line_csv_A =~ s/,$// ;
        print FILE_A $line_csv_A . "\n" ;
        if ($diff_days >= 7)
        {
          $line_csv_C =~ s/,$// ;
          $line_csv_D =~ s/,$// ;
          print FILE_C $line_csv_C . "\n" ;
          print FILE_D $line_csv_D . "\n" ;
        }

        $plot_date = $prev_date ;
      }
    }
    $prev_date = $date ;
  }
  close "FILE_A" ;
  close "FILE_C" ;
  close "FILE_D" ;

if ($false)
{
  &ScanCsvFileForMaxValues (0) ;
  &ScanCsvFileForMaxValues (1) ;
  &ScanCsvFileForMaxValues (2) ;
  &ScanCsvFileForMaxValues (3) ;

  my @languages2 ;
  foreach $wp (@languages)
  { if ($wp ne "zz") { push @languages2, $wp ; }}
  $l = 1 ;
  foreach $wp (@languages2)
  { push @languages3, $wp . "|" . ++$l ; }
  @languages3 = sort {$stats_C {&GetWp ($b)} <=> $stats_C {&GetWp ($a)}} @languages3 ;

  $file_csv = $path_in . $report_names [2] . ".csv" ;
  open "FILE_CSV", "<", $file_csv ;
  open "FILE_C", ">", $path_in . "InputPloticus_C.csv" ;
  $lines = 0 ;
  while ($line = <FILE_CSV>)
  {
    if ($lines++ == 0)
    {
     ($date, @wps) = split (",", $line) ;
      next ;
    }
    ($date, $tot, @fields_new) = split (",", $line) ;

    if ($lines == 1)
    { @fields = @fields_new ; }

    for ($i = 0 ; $i <= $#fields ; $i+=5)
    { $fields [$i] = $fields_new [$i] ; }
    if ($lines == 1)
    { $date = &mmddyyyyInc ($date) ; }
    else
    {
      $date = &mmddyyyyDec ($date) ;
      $date = &mmddyyyyDec ($date) ;
      $date = &mmddyyyyDec ($date) ;
      $date = &mmddyyyyDec ($date) ;
    }
    $line = join (",", ($date, @fields)) ;
    print FILE_C $line . "\n"  ;

    for ($i = 1 ; $i <= $#fields ; $i+=5)
    { $fields [$i] = sprintf ("%.1f", ($fields_new [$i] * 1.05)) ; }
    if ($lines > 1)
    {
      $date = &mmddyyyyInc ($date) ;
      $date = &mmddyyyyInc ($date) ;
    }
    $line = join (",", ($date, @fields)) ;
    print FILE_C $line . "\n" ;

    for ($i = 2 ; $i <= $#fields ; $i+=5)
    { $fields [$i] = sprintf ("%.1f", ($fields_new [$i] * 1.10)) ; }
    if ($lines > 1)
    {
      $date = &mmddyyyyInc ($date) ;
      $date = &mmddyyyyInc ($date) ;
    }
    $line = join (",", ($date, @fields)) ;
    print FILE_C $line . "\n"  ;

    for ($i = 3 ; $i <= $#fields ; $i+=5)
    { $fields [$i] = sprintf ("%.1f", ($fields_new [$i] * 1.15)) ; }
    if ($lines > 1)
    {
      $date = &mmddyyyyInc ($date) ;
      $date = &mmddyyyyInc ($date) ;
    }
    $line = join (",", ($date, @fields)) ;
    print FILE_C $line . "\n"  ;

    for ($i = 4 ; $i <= $#fields ; $i+=5)
    { $fields [$i] = sprintf ("%.1f", ($fields_new [$i] * 1.15)) ; }
    if ($lines > 1)
    {
      $date = &mmddyyyyInc ($date) ;
      $date = &mmddyyyyInc ($date) ;
    }
    $line = join (",", ($date, @fields)) ;
    print FILE_C $line . "\n"  ;
  }
  close "FILE_CSV" ;
  close "FILE_C" ;
}
}

sub GeneratePlotDataFilesX
{
  my $dumpdate = sprintf ("%2d/%2d/%4d", $dumpmonth, $dumpday, $dumpyear) ;
  my (%trend_max, $line_csv, @values, $prev_date, $diff, $factor, $file_U, $avg_days) ;
  my @csv2 ;

  $dumpdate = &mmddyyyyDec ($dumpdate) ;

  my $file_in  = shift ;
  my $file_out = shift ;

  if ($file_out =~ /U/) # file_U : visitor stats
  {
    $file_U = $true ;
    $avg_days = 15 ;
  }
  else
  {
    $file_U = $false ;
    $avg_days = 15 ; # was 9 till end 2004 ;
  }

  my $diff_days = int ($avg_days / 2) ;

  undef %stats_Xmax ;
  undef %stats_Xavg ;

  &ReadFileCsv ($file_in) ;
  if ($#csv == -1)
  { return ; }

#  # remove last entry per wikipedia: incomplete day
#  my $line_prev = '' ;
#  my $wp_prev   = '' ;
#  foreach $line (@csv)
#  {
#    ($wp) = split (',', $line) ;
#    if (($wp eq $wp_prev) && ($line_prev ne ''))
#    { push @csv2, $line_prev ; }
#    $wp_prev   = $wp ;
#    $line_prev = $line ;
#  }
  @csv = sort {&csvkey_date ($a) cmp &csvkey_date ($b)} @csv ;

  $line = $csv [$#csv] ;
  my ($wp, $date, $value) = split (",", $line) ;
  for ($d = 0 ; $d <= $diff_days ; $d++)
  {
    $date = mmddyyyyInc ($date) ;
    $line = join (",", ("00", $date, 0)) ;
    push @csv, $line ;
  }

  my (%values) ;
  foreach $wp (@languages)
  {
    $trend_max {$wp} = 0 ;
    for ($i = $avg_days ; $i >= 0 ; $i--)
    { $values {$wp. "-" . $i} = -1 ; }
  }

  my $prev_date = "" ;
  open "FILE_X", ">", $path_in . $file_out ;
  $dates_read = 0 ;
  foreach $line (@csv)
  {
    ($wp, $date, $value) = split (",", $line) ;
#    if ($date eq $dumpdate)
#    { last ; }

    if (($date ne $prev_date) && ($prev_date ne ""))
    {
      for ($i = $avg_days ; $i >= 1 ; $i--)
      { $values {"date-" . $i} = $values {"date-" . ($i-1)} ; } ;
      $values {"date-0"} = $prev_date ;

      if (++$dates_read >= $diff_days + 1)
#      if (++$dates_read >= $avg_days)
      {
        my $date2 = $values {"date-$diff_days"} ;
        $line_csv = &csv ($date2) ;

        # around 28 December 2003 Wikipedia was really down, so these low figures are significant and
        # no incomplete Webalizer data
        $file_U_count_always = $false ;
        if ((substr ($date2,6,4) == 2003) &&
            (substr ($date2,0,2) == 12)   &&
            (substr ($date2,3,2) > 20))
        { $file_U_count_always = $true ; }
        if ((substr ($date2,6,4) == 2004) &&
            (substr ($date2,0,2) == 1)   &&
            (substr ($date2,3,2) < 5))
        { $file_U_count_always = $true ; }

        foreach $wp (@languages)
        {
          $line_csv .= &csv ($values {$wp . "-$diff_days"}) ;

          if ($values {$wp . "-$diff_days"} == -1)
          { $trend = -1 ; }
          else
          {
            $valtot = 0 ; $valdiv = 0 ;

            for ($diff = $diff_days ; $diff >= 0 ; $diff--)
            {
              $factor = $diff_days - $diff + 1 ;

              $val = $values {$wp . "-" . sprintf ("%d", ($diff_days - $diff))} ;

              # edit counts: skip days where values are missing
              # visitor counts: skip days where values are less than 10% of highest trend figure so far
              # these may well be actual low in visitor counts but more probably incomplete Webalizer stats
              # exception: include figures for confirmed down time at end of December 2003

              if (((! $file_U) && ($val > 0)) || ($file_U && ($file_U_count_always || ($val >= $stats_Xmax {$wp} / 10))))
              { $valtot += $factor * $val ; $valdiv += $factor ; }

              if ($diff != 0)
              {
                $val = $values {$wp . "-" . sprintf ("%d", ($diff_days + $diff))} ;
                if (((! $file_U) && ($val > 0)) ||
                    ($file_U && ($file_U_count_always || ($val >= $stats_Xmax {$wp} / 10))))
                { $valtot += $factor * $val ; $valdiv += $factor ; }
              }
            }

            if ($valdiv == 0)
            { $trend = -1 ; }
            else
            {
              $trend = sprintf ("%.0f", ($valtot / $valdiv)) ;
              if ($trend > $trend_max {$wp})
              { $trend_max {$wp} = $trend ; }
            }
          }

          $line_csv .= &csv3 ($trend) ;

          if ($trend > $stats_Xmax {$wp})
          { $stats_Xmax {$wp} = $trend ; }
        }
        $line_csv =~ s/\,$/\n/ ;
      # $line_csv =~ s/\,\-1/,/g ;
      # $line_csv =~ s/\,0/,/g ;
        print FILE_X $line_csv ;
      }
    }
    if ($wp eq "00")
    {
      foreach $wp (@languages)
      {
        for ($i = $avg_days ; $i >= 1 ; $i--)
        { $values {$wp. "-"   . $i} = $values {$wp. "-"   . ($i-1)} ; }

        $values {$wp . "-0"}   = 0 ;
      }
    }
    else
    {
      $values {$wp} = $value ;
      if ($value > 0)
      {
        $values {$wp. "tot"} += $value ;
        $values {$wp. "cnt"} ++ ;
      }

      for ($i = $avg_days ; $i >= 1 ; $i--)
      { $values {$wp. "-"   . $i} = $values {$wp. "-"   . ($i-1)} ; }

      $values {$wp . "-0"}   = $value ;
    }
    $prev_date = $date ;
  }

if ($false)
{
  $file_U_count_always = $false ;
  for ($l = 0 ; $l < $avg_days ; $l++)
  {
    for ($i = $avg_days ; $i >= 1 ; $i--)
    { $values {"date-" . $i} = $values {"date-" . ($i-1)} ; } ;

    $line_csv = &csv2 ($values {"date-$diff_days"}) ;

    foreach $wp (@languages)
    {
      $line_csv .= &csv ($values {$wp . "-$diff_days"}) ;

      if ($values {$wp . "-$diff_days"} == -1)
      { $trend = -1 ; }
      else
      {
        $valtot = 0 ; $valdiv = 0 ;

        for ($diff = $diff_days ; $diff >= 0 ; $diff--)
        {
          $factor = $diff_days - $diff + 1 ;
          $val = $values {$wp . "-" . sprintf ("%d", ($diff_days - $diff))} ;

          if (((! $file_U) && ($val >= 0)) || ($file_U && ($file_U_count_always || ($val >= $stats_Xmax {$wp} / 10))))
          { $valtot += $factor * $val ; $valdiv += $factor ; }

          if ($diff != 0)
          {
            $val = $values {$wp . "-" . sprintf ("%d", ($diff_days + $diff))} ;
            if (((! $file_U) && ($val >= 0)) || ($file_U && ($file_U_count_always || ($val >= $stats_Xmax {$wp} / 10))))
            { $valtot += $factor * $val ; $valdiv += $factor ; }
          }
        }

        if ($valdiv == 0)
        { $trend = -1 ; }
        else
        {
          $trend = sprintf ("%.0f", ($valtot / $valdiv)) ;
          if ($trend > $trend_max {$wp})
          { $trend_max {$wp} = $trend ; }
        }
      }

      $line_csv .= &csv ($trend) ;

      if ($trend > $stats_Xmax {$wp})
      { $stats_Xmax {$wp} = $trend ; }
    }

    $line_csv =~ s/\,$/\n/ ;
    $line_csv =~ s/\,\-1/,/g ;
    $line_csv =~ s/\,0/,/g ;
    print FILE_X $line_csv ;

    $values {$wp} = $value ;
    if ($value > 0)
    {
      $values {$wp. "tot"} += $value ;
      $values {$wp. "cnt"} ++ ;
    }

    for ($i = $avg_days ; $i >= 1 ; $i--)
    { $values {$wp. "-"   . $i} = $values {$wp. "-"   . ($i-1)} ; }

    $values {$wp . "-0"}   = $value ;
    $prev_date = $date ;
  }
}
  close "FILE_X" ;

  foreach $wp (@languages)
  {
    $stats_Xmax {$wp} = sprintf ("%.0f", 1.1 * $stats_Xmax {$wp}) ;
    if ($values {$wp. "cnt"} > 0)
    { $stats_Xavg {$wp} = $values {$wp. "tot"} / $values {$wp. "cnt"} ; }
  }
}

sub ScanCsvFileForMaxValues {
  my $f = shift ;
  $file_csv = $path_in . $report_names [$f] . ".csv" ;
  open "FILE_CSV", "<", $file_csv ;
  $lines = 0 ;
  while ($line = <FILE_CSV>)
  {
    if ($lines++ == 0)
    {
     ($date, @wps) = split (",", $line) ;
      next ;
    }
    ($date, @fields) = split (",", $line) ;
    for ($i = 0 ; $i <= $#fields ; $i++)
    {
      $wp = $wps [$i] ;

      if    ($f == 0)
      { if ($fields [$i] > $stats_A {$wp}) { $stats_A {$wp} = $fields [$i] ; } }
      elsif ($f == 2)
      { if ($fields [$i] > $stats_C {$wp}) { $stats_C {$wp} = $fields [$i] ; } }
      elsif ($f == 3)
      { if ($fields [$i] > $stats_D {$wp}) { $stats_D {$wp} = $fields [$i] ; } }
    }
  }
  close "FILE_CSV" ;
}

1;
