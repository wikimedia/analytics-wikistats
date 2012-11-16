#!/usr/bin/perl

# needed files
# StatisticsMonthly.csv
# StatisticsUserActivitySpread.csv
sub GenerateAnimationsInputSizeAndCommunity
{
  my $out_js ;
  my $transparency = "0.7" ;

  $out_publication =~ s/Wikibook/Wikibooks/ ;

  $wikipedias = 0 ;
  foreach $wp (@languages2)
  {
    if ($wp ne "zz")
    { $wikipedias++ ; }
  }

  #collect totals
  if ($mode_wb) { $from_year = 2003 ; $from_month =  7 ; }
  if ($mode_wk) { $from_year = 2002 ; $from_month = 12 ; }
  if ($mode_wn) { $from_year = 2004 ; $from_month = 11 ; }
  if ($mode_wp) { $from_year = 2001 ; $from_month =  1 ; }
  if ($mode_wq) { $from_year = 2003 ; $from_month =  7 ; }
  if ($mode_ws) { $from_year = 2003 ; $from_month =  7 ; }
  if ($mode_wv) { $from_year = 2004 ; $from_month =  5 ; }
  if ($mode_wx) { $from_year = 2001 ; $from_month = 11 ; }

  $m1         = ord (&yyyymm2b ($from_year,$from_month)) ;
# $mmddyyyy   = &m2mmddyyyy ($month_max-1) ; # why -1 ?
  $mmddyyyy   = &m2mmddyyyy ($month_max) ;
  $till_year  = substr ($mmddyyyy,6,4) ;
  $till_month = substr ($mmddyyyy,0,2)+0 ;
  $m2 = $month_max ;

  $articles_max = $max_value_f {4} ;
  $editors_max  = $max_value_f {2} ;

  $out_js = "var PROJECT      = \"$out_publication\" ;\n" .
            "var FROM_YEAR    = $from_year ;\n" .
            "var FROM_MONTH   = $from_month ;\n" .
            "var TILL_YEAR    = $till_year ;\n" .
            "var TILL_MONTH   = $till_month ;\n\n" .
            "var WIKIPEDIAS   = $wikipedias ;\n\n" .
            "var ARTICLES_MAX = $articles_max ;\n\n" .
            "var EDITORS_MAX  = $editors_max ;\n\n" .
            "function init()\n" .
            "{\n" .
            "  for (i = 0; i < WIKIPEDIAS; i++)\n" .
            "  { a[i] = new Wikipedia(); }\n\n" ;

  my $ndx = 0 ;
  my $ndx_alias = 0 ;
  my $aliasses = "" ;
  my $label = "" ;

  foreach $wp (@languages2)
  {
    if ($wp eq "zz") { next ; }

    $label = $wp ;
    if (length ($wp) > 3)
    {
      $ndx_alias++ ;
      $label = "$ndx_alias" ;
      $aliasses .= "$ndx_alias: $wp,\n" ;
    }

    $out_js .= "  a[$ndx].langcode = \"$label\" ;\n" ;

    $language = $out_languages {$wp} ;
    if ($language eq "")
    { $language = "language unknown" ; }
    $language =~ s/\&uuml;/ü/g ; # to be generalised !!!
    $out_js .= "  a[$ndx].language = \"$language\" ;\n" ;

    # fill colors
    my $fill_red   = int (rand (255)) ;
    my $fill_green = int (rand (255)) ;
    my $fill_blue  = int (rand (255)) ;

    # line colors
    my $line_red   = $fill_red ;
    my $line_green = $fill_green ;
    my $line_blue  = $fill_blue ;

    # text colors
    my $text_red   = ($fill_red  +128) % 256 ;
    my $text_green = ($fill_green+128) % 256 ;
    my $text_blue  = ($fill_blue +128) % 256 ;

    $out_js .= "  a[$ndx].fill_color = \"rgba($fill_red, $fill_green, $fill_blue, $transparency)\" ;\n" ;
    $out_js .= "  a[$ndx].line_color = \"rgba($line_red, $line_green, $line_blue, $transparency)\" ;\n" ;
    $out_js .= "  a[$ndx].text_color = \"rgba($text_red, $text_green, $text_blue, $transparency)\" ;\n" ;

    $data = "" ;
    for ($m = $m1 ; $m <= $m2  ; $m++)
    { $data .= (0+@MonthlyStats {$wp.$m.$c[4]}) . "," ; }
    $data =~ s/,$// ;
    $out_js .= "  data = '$data' ;\n" ;
    $out_js .= "  a[$ndx].articles = data.split(',') ;\n\n" ;

    $data = "" ;
    for ($m = $m1 ; $m <= $m2 ; $m++)
    { $data .= (0+@MonthlyStats {$wp.$m.$c[9]}) . "," ; }
    $data =~ s/,$// ;
    $out_js .= "  data = '$data' ;\n" ;
    $out_js .= "  a[$ndx].values = data.split(',') ;\n\n" ;

    $data = "" ;
    for ($m = $m1 ; $m <= $m2 ; $m++)
    { $data .= (0+@MonthlyStats {$wp.$m.$c[2]}) . "," ; }
    $data =~ s/,$// ;
    $out_js .= "  data = '$data' ;\n" ;
    $out_js .= "  a[$ndx].editors5 = data.split(',') ;\n\n" ;

    if ($ndx++ >= $wikipedias - 1) { last ; }
  }

  $aliasses =~ s/,$//g ;
# print "\n\nAliasses:\n $aliasses\n" ;
  $aliasses =~ s/\n//gs ;

  $out_js .= "}\n\n" ;
  $out_js .= "var aliasses = \"$aliasses\" ;\n\n" ;

  &LogT ("\nWrite animation input to $file_animation_projects_growth\n") ;
  open  ANIMATION_PROJECTS_GROWTH, ">", $file_animation_projects_growth ;
  print ANIMATION_PROJECTS_GROWTH $out_js ;
  close ANIMATION_PROJECTS_GROWTH ;
}

sub GenerateAnimationsInputProjectsGrowth
{
  my $out_js ;
  my $transparency = "0.7" ;

  $out_publication =~ s/Wikibook/Wikibooks/ ;

  $wikipedias = 0 ;
  foreach $wp (@languages2)
  {
    if ($wp ne "zz")
    { $wikipedias++ ; }
  }

  #collect totals
  if ($mode_wb) { $from_year = 2003 ; $from_month =  7 ; }
  if ($mode_wk) { $from_year = 2002 ; $from_month = 12 ; }
  if ($mode_wn) { $from_year = 2004 ; $from_month = 11 ; }
  if ($mode_wp) { $from_year = 2001 ; $from_month =  1 ; }
  if ($mode_wq) { $from_year = 2003 ; $from_month =  7 ; }
  if ($mode_ws) { $from_year = 2003 ; $from_month =  7 ; }
  if ($mode_wv) { $from_year = 2004 ; $from_month =  5 ; }
  if ($mode_wx) { $from_year = 2001 ; $from_month = 11 ; }

  $m1         = ord (&yyyymm2b ($from_year,$from_month)) ;
# $mmddyyyy   = &m2mmddyyyy ($month_max-1) ; # why -1 ?
  $mmddyyyy   = &m2mmddyyyy ($month_max) ;
  $till_year  = substr ($mmddyyyy,6,4) ;
  $till_month = substr ($mmddyyyy,0,2)+0 ;
  $m2 = $month_max ;

  $articles_max = $max_value_f {4} ;

  $out_js = "var PROJECT    = \"$out_publication\" ;\n" .
            "var FROM_YEAR  = $from_year ;\n" .
            "var FROM_MONTH = $from_month ;\n" .
            "var TILL_YEAR  = $till_year ;\n" .
            "var TILL_MONTH = $till_month ;\n\n" .
            "var WIKIPEDIAS = $wikipedias ;\n\n" .
            "var ARTICLES_MAX = $articles_max ;\n\n" .
            "function init()\n" .
            "{\n" .
            "  for (i = 0; i < WIKIPEDIAS; i++)\n" .
            "  { a[i] = new Wikipedia(); }\n\n" ;

  my $ndx = 0 ;
  my $ndx_alias = 0 ;
  my $aliasses = "" ;
  my $label = "" ;

  foreach $wp (@languages2)
  {
    if ($wp eq "zz") { next ; }

    $label = $wp ;
    if (length ($wp) > 3)
    {
      $ndx_alias++ ;
      $label = "$ndx_alias" ;
      $aliasses .= "$ndx_alias: $wp,\n" ;
    }

    $out_js .= "  a[$ndx].langcode = \"$label\" ;\n" ;

    $language = $out_languages {$wp} ;
    if ($language eq "")
    { $language = "language unknown" ; }
    $language =~ s/\&uuml;/ü/g ; # to be generalised !!!
    $out_js .= "  a[$ndx].language = \"$language\" ;\n" ;

    # fill colors
    my $fill_red   = int (rand (255)) ;
    my $fill_green = int (rand (255)) ;
    my $fill_blue  = int (rand (255)) ;

    # line colors
    my $line_red   = $fill_red ;
    my $line_green = $fill_green ;
    my $line_blue  = $fill_blue ;

    # text colors
    my $text_red   = ($fill_red  +128) % 256 ;
    my $text_green = ($fill_green+128) % 256 ;
    my $text_blue  = ($fill_blue +128) % 256 ;

    $out_js .= "  a[$ndx].fill_color = \"rgba($fill_red, $fill_green, $fill_blue, $transparency)\" ;\n" ;
    $out_js .= "  a[$ndx].line_color = \"rgba($line_red, $line_green, $line_blue, $transparency)\" ;\n" ;
    $out_js .= "  a[$ndx].text_color = \"rgba($text_red, $text_green, $text_blue, $transparency)\" ;\n" ;

    $data = "" ;
    for ($m = $m1 ; $m <= $m2  ; $m++)
    { $data .= (0+@MonthlyStats {$wp.$m.$c[4]}) . "," ; }
    $data =~ s/,$// ;
    $out_js .= "  data = '$data' ;\n" ;
    $out_js .= "  a[$ndx].articles = data.split(',') ;\n\n" ;

    $data = "" ;
    for ($m = $m1 ; $m <= $m2 ; $m++)
    { $data .= (0+@MonthlyStats {$wp.$m.$c[9]}) . "," ; }
    $data =~ s/,$// ;
    $out_js .= "  data = '$data' ;\n" ;
    $out_js .= "  a[$ndx].values = data.split(',') ;\n\n" ;

    $data = "" ;
    for ($m = $m1 ; $m <= $m2 ; $m++)
    { $data .= (0+@MonthlyStats {$wp.$m.$c[2]}) . "," ; }
    $data =~ s/,$// ;
    $out_js .= "  data = '$data' ;\n" ;
    $out_js .= "  a[$ndx].editors5 = data.split(',') ;\n\n" ;

    if ($ndx++ >= $wikipedias - 1) { last ; }
  }

  $aliasses =~ s/,$//g ;
# print "\n\nAliasses:\n $aliasses\n" ;
  $aliasses =~ s/\n//gs ;

  $out_js .= "}\n\n" ;
  $out_js .= "var aliasses = \"$aliasses\" ;\n\n" ;

  &LogT ("\nWrite animation input to $file_animation_projects_growth\n") ;
  open  ANIMATION_PROJECTS_GROWTH, ">", $file_animation_projects_growth ;
  print ANIMATION_PROJECTS_GROWTH $out_js ;
  close ANIMATION_PROJECTS_GROWTH ;
}

1;
