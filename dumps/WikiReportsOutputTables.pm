#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  use WikiReportsNoWikimedia ;

sub GenerateCurrentStatus
{
  &LogT ("\nGenerate Current Status Tables") ;

  my $out_zoom = "" ;
  my $out_options = "" ;
  my $out_explanation = "#version#" ;
  my $out_button_prev = "" ;
  my $out_button_next = "" ;
  my $out_page_subtitle = "" ;
  my $out_crossref = "" ;
  my $out_description = "" ;
  my $lang ;
  my $out_html_start   = "" ;
  my $out_html_verbose = "" ;
  my $out_html_concise = "" ;
  if ($out_overview eq "")
  { $out_overview = "Current status" ; }
  my $out_button_switch = "home" ;
  my $out_msg = "" ;

  my $out_html_title = $out_statistics . " \- " . $out_overview ;
  my $out_page_title = $out_statistics ;

  if ($region ne "")
  {
    $out_html_title .= " - " . ucfirst ($region) ;
    $out_page_title .= " - " . ucfirst ($region) ;
  }

  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
    $out_page_title .= "<b>" . &GetDate ($dumpdate2) . "<\/b>" ;
  }
#  $out_crossref = &GenerateCrossReference ($language) ;

#  &ReadLog ($language) ;

  &GenerateHtmlStart ($out_html_title,  $out_zoom,          $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

  $out_html .= "<table border=0 cellspacing=0 id=table1 style='' width='100%' summary='Overview'>\n" ;
  $out_html .= "<tr><td width='100%' class='l' valign='top'>" ;

if (0)
{
  if ($mode_wb) { $out_html .= "<h2>" . $out_wikibooks .    "</h2>\n" ; }
  if ($mode_wk) { $out_html .= "<h2>" . $out_wiktionaries . "</h2>\n" ; }
  if ($mode_wn) { $out_html .= "<h2>" . $out_wikinews .     "</h2>\n" ; }
  if ($mode_wp) { $out_html .= "<h2>" . $out_wikipedias .   "</h2>\n" ; }
  if ($mode_wq) { $out_html .= "<h2>" . $out_wikiquotes .   "</h2>\n" ; }
  if ($mode_ws) { $out_html .= "<h2>" . $out_wikisources .  "</h2>\n" ; }
  if ($mode_wv) { $out_html .= "<h2>" . $out_wikiversity .  "</h2>\n" ; }
  if ($mode_wx) { $out_html .= "<h2>" . $out_wikispecial .  "</h2>\n" ; }
}
  if ($wikimedia)
  {
    if ($mode_wb) { $out_url_all = "http://wikibooks.org" ; }
    if ($mode_wk) { $out_url_all = "http://wiktionary.org" ; }
    if ($mode_wn) { $out_url_all = "http://wikinews.org" ; }
    if ($mode_wp) { $out_url_all = "http://wikipedia.org" ; }
    if ($mode_wq) { $out_url_all = "http://wikiquote.org" ; }
    if ($mode_ws) { $out_url_all = "http://wikisource.org" ; }
    if ($mode_wv) { $out_url_all = "http://wikiversity.org" ; }
    if ($mode_wx) { $out_url_all = "http://wikimedia.org" ; }
  }

# if ($wikimedia && $mode_wp)
# {
#   $out_html .= "All statistics on this site are extracted from full archive database dumps. " .
#                "Since a year it has become increasingly difficult to produce valid dumps for the largest wikipedias.<br>" .
#                "Until that problem is fixed, some figures will be missing or will be outdated (red). " .
#                "You can find more up to date article counts (collected differently) at the <a href='http://en.wikipedia.org/wiki/Wikipedia:Multilingual_ranking_June_2007'>English Wikipedia</a>." ;
# }

  $out_html_start = $out_html ;

  &ReadFileCsv ($file_csv_log) ;
  foreach $line (@csv)
  {
    ($wp, $dumpdate, $countdate, $counttime, $conversions, $dummy, $dummy2, $dummy3, $edits_total_, $edits_total_ip_) = split (",", $line) ;
    $edits_total_ip {$wp} = $edits_total_ip_ ;
    $edits_total    {$wp} = $edits_total_ ;
  }

  &ReadFileCsv ($file_csv_namespace_stats) ;
  foreach $line (@csv)
  {
    chomp ($line) ;
    my ($wp, $date, $ns0, $ns2, $ns4, $ns6, $ns8, $ns10, $ns12, $ns14, $ns16, $ns100, $ns102, $ns104) = split (',', $line) ;
    $namespaces {$wp} = $line ;
  }

  &ReadFileCsv ($file_csv_access_levels) ;
  foreach $line (@csv)
  {
    chomp ($line) ;
    my ($wp, $level, $count) = split (',', $line) ;
    $access {"$wp|$level"} = $count ;
  }

  my $rows ;
  foreach $wp (@languages)
  {
    if ($skip {$wp}) { next ; }

    $wpc = $wp ;
    # if ($wp eq "simple")
    # { $wpc = "se" ; }

    if ($wpc eq "zz")
    {
#     if ((! $mode_wx) && (! $singlewiki))
#     {
#       $out_html .= &tr (($wikimedia ? &tdcb ("&Sigma;") : &tdlb ("&Sigma;")) .
#                         ($wikimedia ? &tdlb ($out_languages {$wpc} . "&nbsp;(" . $#languages . ")") : "") .
#                         &tdcb ("<a href='$out_url_all'>" . &w($out_site) . "</a>") .
#                         &tdrb (&w ($max_value {"$wp-4"}))) ;
#     }
    }
    else
    {
      if (! $wikimedia)
      { $out_urls {$wp} =  &UrlWebsite ($wpc) ; }

      # if ($wpc eq "roa-rup")    { $wpc = "roa_rup" ; }
      # if ($wpc eq "zh-min-nan") { $wpc = "zh_min_nan" ; }
      $wpc2 = $wpc ;
      $wpc2 =~ s/_/-/g ;
      if ((length ($wpc2) > 7) & (!$mode_wx))
      { $wpc2 = "<small>$wpc2</small>" ; }

      if ($wikimedia)
      {
        $out_language_name = $out_languages {$wpc} ;
        if (length ($out_language_name) > 13)
        { $out_language_name = "<small>$out_language_name</small>" ; }
        $out_language_name = "<a href='" . $out_article {$wpc} . "'>$out_language_name</a>" ;
      }
      else
      { $out_language_name = $out_languages {$wpc} ; }

      $uptodate = (yyyymmdd2i ($lastdump {"zz"}) - yyyymmdd2i ($lastdump {$wp}) < 3) ;
      $lastdump2    = $lastdump_short {$wp} ;
      $localization = $translate_wiki {$wp} ;
      if ($localization eq "")
      { $localization = "-" ; }


      $a100 = $MonthlyStatsWp100Articles {$wp} ;
      if ($a100 ne "")
      { $a100 = &GetDateShort2 ($a100, $true) ; }

      $a1000 = $MonthlyStatsWp1000Articles {$wp} ;
      if ($a1000 ne "")
      { $a1000 = &GetDateShort2 ($a1000, $true) ; }

      $a10000 = $MonthlyStatsWp10000Articles {$wp} ;
      if ($a10000 ne "")
      { $a10000 = &GetDateShort2 ($a10000, $true) ; }

      $a100000 = $MonthlyStatsWp100000Articles {$wp} ;
      if ($a100000 ne "")
      { $a100000 = &GetDateShort2 ($a100000, $true) ; }

      my $views = "" ;
      if ($wikimedia)
      {
        $views = $PageViewsPerHour {$wp} ;

        $totpages = $max_value {"$wp-4"} ;
        $views_per_article = "n.a." ;
        if ($totpages > 0)
        { $views_per_article = sprintf ("%.2f", $views / $totpages) ; }

        if ($views < 0.1)
        { $views = sprintf ("%.2f", $views) ; }
        elsif ($views < 1)
        { $views = sprintf ("%.1f", $views) ; }
        else
        {
          $views = sprintf ("%.0f", $views) ;
          if ($views > 1000000)
          { $views =~ s/(\d\d\d)(\d\d\d)$/$out_thousands_separator$1$out_thousands_separator$2/ ; }
          elsif ($views > 1000)
          { $views =~ s/(\d\d\d)$/$out_thousands_separator$1/ ; }
        }
      }

      my $views_delta = $views_yearly_growth {$wp} ;
      if ($views_delta eq "")
      { $views_delta = "n.a." ; }
      elsif ($views_delta =~ /\(/)
      {
        # $views_delta =~ s/[\(\)]//g ;
        # if ($views_delta !~ /-/)
        # { $views_delta = "+$views_delta%" ; }
        # else
        # { $views_delta = "$views_delta%" ; }
        # { $views_delta = "$views_delta%" ; }
        # $views_delta = "($views_delta)" ;
        $views_delta =~ s/\)/%\)/ ;
      }
      else
      {
        # if ($views_delta !~ /-/)
        # { $views_delta = "$views_delta%" ; }
        # else
        # { $views_delta = "$views_delta%" ; }
        $views_delta = "$views_delta%" ;
      }

      $maxarticles2 = &format ($max_value {"$wp-4"}) ;
      $maxarticles2b = &i2K2  ($max_value {"$wp-4"}) ;
      $articles_plus = @MonthlyStats {$wp.$c[4].'+'} ;
      if ($articles_plus ne "")
      { $articles_plus = "+" . &format ($articles_plus) ; }
      $articles_perc  = "" ;
      $articles_perc2 = "" ;
      if ($articles_plus ne "+0")
      {
        $articles_perc  = @MonthlyStats {$wp.$c[4].'%'} . "%" ;
        if ($articles_perc ne "100%")
        { $articles_perc2 = "<small>+" . @MonthlyStats {$wp.$c[4].'+%'} . "%</small>" ; }
      }

#      if ($articles_perc ne "")
#      {
#      # if (($articles_perc < 100) && ($articles_perc2 ne ""))
#        if (($articles_perc > 0) && ($articles_perc < 90))
#        { $articles_perc = "$articles_perc% <small><small>(+$articles_perc2%)</small></small>" ; }
#        else
#        { $articles_perc = "$articles_perc%" ; }
#      }

      $maxeditors2  = &format ($max_value {"$wp-0"}) ;
      $maxeditors2b = &i2KM2  ($max_value {"$wp-0"}) ;
      $editors_plus = @MonthlyStats {$wp.$c[0].'+'} ;
      if ($editors_plus ne "")
      { $editors_plus = "+" . &format ($editors_plus) ; }
      $editors_perc  = "" ;
      $editors_perc2 = "" ;
      if ($editors_plus ne "+0")
      {
        $editors_perc  = @MonthlyStats {$wp.$c[0].'%'} . "%" ;
        if ($editors_perc ne "100%")
        { $editors_perc2 = "<small>+" . @MonthlyStats {$wp.$c[0].'+%'} . "%</small>" ; }
      }
#      if ($editors_perc ne "")
#      { $editors_perc = "$editors_perc% <small><small>(+$editors_perc2%)</small></small>" ; }

      $edits_tot = &format (@MonthlyStats {$wp.$c[11].'tot'}) ;
      $edits_tot2 = &i2KM2 (@MonthlyStats {$wp.$c[11].'tot'}) ;
      $edits_plus = @MonthlyStats {$wp.$c[11].'+'} ;
      if ($edits_plus ne "")
      { $edits_plus = "+" . &format ($edits_plus) ; }
      $edits_perc  = "" ;
      $edits_perc2 = "" ;
      if ($edits_plus ne "+0")
      {
        $edits_perc  = @MonthlyStats {$wp.$c[11].'%'} . "%" ;
        if ($edits_perc ne "100%")
        { $edits_perc2 = "<small>+" . @MonthlyStats {$wp.$c[11].'+%'} . "%</small>" ; }
      }
#      if ($edits_perc ne "")
#      {
#      # if (($edits_perc < 100) && ($edits_perc2 ne ""))
#        if (($edits_perc > 0) &&($edits_perc < 90))
#        { $edits_perc = "$edits_perc% <small><small>(+$edits_perc2%)</small></small>" ; }
#        else
#        { $edits_perc = "$edits_perc%" ; }
#      }

      $articles_new   = @MonthlyStats {$wp.$c[1].'avg3'} ;
      $editors_ge_5   = @MonthlyStats {$wp.$c[2].'avg3'} ;
      $editors_ge_100 = @MonthlyStats {$wp.$c[3].'avg3'} ;
      $edits_average  = @MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[7]} ;

      $cnt = @MonthlyStats {$wp.$c[11].'tot'} ;
      if ($cnt > 0)
      { $edits_bot = sprintf ("%.0f", 100 * $BotStatsWpTot1 {$wp} / $cnt) . "%" ; }
      else
      { $edits_bot = "0%" ; }
      if (($wp eq "en") && ($BotStatsWpTot1 {$wp} == 0))
      { $edits_bot = "" ; } # no data yet

      $words      = &i2KM  (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[13]}) ;
      $links_int  = &i2KM  (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[14]}) ;
      $links_ext  = &i2KM  (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[15]}) ;
      $links_iwi  = &i2KM  (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[17]}) ;
      $binaries   = &i2KM  (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[15]}) ;
      $redirects  = &i2KM  (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[16]}) ;

      $words2     = &i2KM3 (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[13]}) ;
      $links_int2 = &i2KM3 (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[14]}) ;
      $links_ext2 = &i2KM3 (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[17]}) ;
      $links_iwi2 = &i2KM3 (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[15]}) ;
      $binaries2  = &i2KM3 (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[16]}) ;
      $redirects2 = &i2KM3 (@MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[18]}) ;

      $edits_anonymous = sprintf ("%.0f", 100 * $edits_total_ip {$wp} / ($edits_total {$wp} - $BotStatsWpTot1 {$wp})) . "%" ;

      ($wp, $date, $ns0, $ns2, $ns4, $ns6, $ns8, $ns10, $ns12, $ns14, $ns16, $ns100, $ns102, $ns104) = split (',', $namespaces {$wp}) ;

      $ns0   = &i2KM3 ($ns0) ;
      $ns2   = &i2KM3 ($ns2) ;
      $ns4   = &i2KM3 ($ns4) ;
      $ns6   = &i2KM3 ($ns6) ;
      $ns8   = &i2KM3 ($ns8) ;
      $ns10  = &i2KM3 ($ns10) ;
      $ns12  = &i2KM3 ($ns12) ;
      $ns14  = &i2KM3 ($ns14) ;
      $ns16  = &i2KM3 ($ns16) ;
      $ns100 = &i2KM3 ($ns100) ;
      $ns102 = &i2KM3 ($ns102) ;
      $ns104 = &i2KM3 ($ns104) ;

      $access_bots       = @access {"$wp|bot"} ;
      $access_sysop      = @access {"$wp|sysop"} ;
      $access_bureaucrat = @access {"$wp|bureaucrat"} ;
      $access_checkuser  = @access {"$wp|checkuser"} ;
      $access_developer  = @access {"$wp|developer"} ;
      $access_oversight  = @access {"$wp|oversight"} ;
      $access_user       = @access {"$wp|user"} ;
      $access_ratio      = "" ;
      if ($articles_new > 0)
      { $access_ratio = sprintf ("%.1f", $access_sysop/$articles_new) ; }

      if (! $mode_wx)
      {
        $regions = $out_regions {$wp} ;

        if ($out_speakers {$wp} == 0)
        { $participation = "" ; }
        else
        { $participation = sprintf ("%.1f", $editors_ge_5 / $out_speakers {$wp}) ; }

        push @participations, "$wp,${out_languages {$wp}},${out_speakers {$wp}},$editors_ge_5,$participation,$regions\n" ;

        $speakers = &i2KM2 ($out_speakers {$wp} * 1000000) ;
        if ($out_speakers {$wp} == 0)
        { $participation = "" ; }
        elsif ($editors_ge_5 / $out_speakers {$wp} >= 1)
        { $participation = sprintf ("%.0f", $editors_ge_5 / $out_speakers {$wp}) ; }
        else
        { $participation = sprintf ("%.1f", $editors_ge_5 / $out_speakers {$wp}) ; }
      }

      if (! $uptodate)
      {
        $lastdump2       = "<font color=#FF0000>$lastdump2</font>" ;
        $localization    = "<font color=#FF0000>$localization</font>" ;
        $maxarticles2    = "<font color=$color_outofdate>$maxarticles2</font>" ;
        $maxarticles2b   = "<font color=$color_outofdate>$maxarticles2b</font>" ;
        $articles_plus   = "<font color=$color_outofdate>$articles_plus</font>" ;
        $articles_new    = "<font color=$color_outofdate>$articles_new</font>" ;
        $articles_perc   = "<font color=$color_outofdate>$articles_perc</font>" ;
        $articles_perc2  = "<font color=$color_outofdate>$articles_perc2</font>" ;
        $maxeditors2     = "<font color=$color_outofdate>$maxeditors2</font>" ;
        $maxeditors2b    = "<font color=$color_outofdate>$maxeditors2b</font>" ;
        $editors_plus    = "<font color=$color_outofdate>$editors_plus</font>" ;
        $editors_perc    = "<font color=$color_outofdate>$editors_perc</font>" ;
        $editors_perc2   = "<font color=$color_outofdate>$editors_perc2</font>" ;
        $editors_ge_5    = "<font color=$color_outofdate>$editors_ge_5</font>" ;
        $editors_ge_100  = "<font color=$color_outofdate>$editors_ge_100</font>" ;
        $edits_tot       = "<font color=$color_outofdate>$edits_tot</font>" ;
        $edits_tot2      = "<font color=$color_outofdate>$edits_tot2</font>" ;
        $edits_plus      = "<font color=$color_outofdate>$edits_plus</font>" ;
        $edits_perc      = "<font color=$color_outofdate>$edits_perc</font>" ;
        $edits_perc2     = "<font color=$color_outofdate>$edits_perc2</font>" ;
        $edits_bot       = "<font color=$color_outofdate>$edits_bot</font>" ;
        $edits_average   = "<font color=$color_outofdate>$edits_average</font>" ;
        $edits_anonymous = "<font color=$color_outofdate>$edits_anonymous</font>" ;

        $words           = "<font color=$color_outofdate>$words</font>" ;
        $links_int       = "<font color=$color_outofdate>$links_int</font>" ;
        $links_ext       = "<font color=$color_outofdate>$links_ext</font>" ;
        $links_iwi       = "<font color=$color_outofdate>$links_iwi</font>" ;
        $binaries        = "<font color=$color_outofdate>$binaries</font>" ;
        $redirects       = "<font color=$color_outofdate>$redirects</font>" ;

        $words2          = "<font color=$color_outofdate>$words2</font>" ;
        $links_int2      = "<font color=$color_outofdate>$links_int2</font>" ;
        $links_ext2      = "<font color=$color_outofdate>$links_ext2</font>" ;
        $links_iwi2      = "<font color=$color_outofdate>$links_iwi2</font>" ;
        $binaries2       = "<font color=$color_outofdate>$binaries2</font>" ;
        $redirects2      = "<font color=$color_outofdate>$redirects2</font>" ;

        $ns0             = "<font color=$color_outofdate>$ns0</font>" ;
        $ns2             = "<font color=$color_outofdate>$ns2</font>" ;
        $ns4             = "<font color=$color_outofdate>$ns4</font>" ;
        $ns6             = "<font color=$color_outofdate>$ns6</font>" ;
        $ns8             = "<font color=$color_outofdate>$ns8</font>" ;
        $ns10            = "<font color=$color_outofdate>$ns10</font>" ;
        $ns12            = "<font color=$color_outofdate>$ns12</font>" ;
        $ns14            = "<font color=$color_outofdate>$ns14</font>" ;
        $ns100           = "<font color=$color_outofdate>$ns100</font>" ;
        $ns102           = "<font color=$color_outofdate>$ns102</font>" ;
        $ns104           = "<font color=$color_outofdate>$ns104</font>" ;

        $access_bots       = "<font color=$color_outofdate>$access_bots</font>" ;
        $access_bureaucrat = "<font color=$color_outofdate>$access_bureaucrat</font>" ;
        $access_checkuser  = "<font color=$color_outofdate>$access_checkuser</font>" ;
        $access_developer  = "<font color=$color_outofdate>$access_developer</font>" ;
        $access_oversight  = "<font color=$color_outofdate>$access_oversight</font>" ;
        $access_sysop      = "<font color=$color_outofdate>$access_sysop</font>" ;
        $access_ratio      = "<font color=$color_outofdate>$access_ratio</font>" ;

        $views_per_article    = "<font color=$color_outofdate>$views_per_article</font>" ;

        if (! $mode_wx)
        {
          $speakers          = "<font color=$color_outofdate>$speakers</font>" ;
          $participation     = "<font color=$color_outofdate>$participation</font>" ;
          $regions           = "<font color=$color_outofdate>$regions</font>" ;
        }
      }

      # colors derived from http://commons.wikimedia.org/w/thumb.php?f=Location%20of%20Continents.svg&width=200px
      # Oceania is not colored separately on map
      # http://web.forret.com/tools/rgb_gradient.asp?to=FFCC00
      $regions =~ s/AF/<font color=#008800><span title='Africa'>AF<\/span><\/font>/ ;
      $regions =~ s/AS/<font color=#DD0000><span title='Asia'>AS<\/span><\/font>/ ;
      $regions =~ s/OC/<font color=#00AAD4><span title='Oceania'>OC<\/span><\/font>/ ;
      $regions =~ s/EU/<font color=#0000CC><span title='Europe'>EU<\/span><\/font>/ ;
      $regions =~ s/NA/<font color=#CC00CC><span title='North America'>NA<\/span><\/font>/ ;
      $regions =~ s/SA/<font color=#FFAA00><span title='South America'>SA<\/span><\/font>/ ;
      $regions =~ s/AL/<font color=#000000><span title='Constructed Language'>CL<\/span><\/font>/ ;
      $regions =~ s/W/<font color=#000000><span title='World Language'>W<\/span><\/font>/ ;
      $regions =~ s/,/ /g ;

      $total_speakers = "" ;

      if ($out_speakers {$wp} > 0)
      {
        $total_speakers = sprintf ("%.0f", 125 * log10 ($out_speakers {$wp}) / log10 ($speakers_max)) ;
        if ($total_speakers < 1)
        { $total_speakers = 2 ; }

        $total_speakers = "<img src='../bluebar2_hor.gif' width='$total_speakers' height='7'>" ;
      }
      else
      { $total_speakers = "<img src='../bluebar2_hor.gif' width='2' height='7'>" ; }


      $participation2 = 0 ;
      if ($out_speakers {$wp} > 0)
      { $participation2 =  sprintf ("%.1f", 0.8 * $editors_ge_5 / $out_speakers {$wp}) ; }
      if ( $participation2 > 1)
      { $participation2 =  sprintf ("%.0f",  $participation2) ; }

      $participation_max = 125 ;
      if ($participation2 > $participation_max)
      {
        $participation2 = $participation_max ;
        $share_participation = "<img src='../redbar2_hor.gif' width='" . $participation2 . "' height='7'>&nbsp;<img src='../redbar2_hor.gif' width='5' height='7'>" ;
      }
      else
      {
        if ($participation2 < 2)
        { $participation2 = 2 ; }
        $share_participation = "<img src='../redbar2_hor.gif' width='" . $participation2 . "' height='7'>" ;
      }

      if ( $out_speakers {$wp} < 0.05) # ($speakers =~ /^\d+$/)
      {
        # print "1 $share_participation\n" ;
        $participation = "<font color=#A0A0A0>$participation</font>" ;
        $share_participation =~ s/redbar2/redbar3/g ;
        # print "2 $share_participation\n" ;

        if ($out_speakers {$wp} == 0)
        {
          $share         = "<font color=#808080>-</font>" ;
          $speakers      = "<font color=#808080>-</font>" ;
          $participation = "<font color=#808080>-</font>" ;
        }

      }

      $share = "<small><small><small>$total_speakers</small></small><br><small><small>$share_participation</small></small></small>" ;

      if ($participation =~ /\./)
      { $participation = "<small><small><font color=#606060>$participation</font></small></small>" ; }

      $site = "<a href='" . $out_urls {$wpc} . "'>" . &w($wpc2) . "</a>" ;


      ($wp2=$wp) =~ s/_/-/g ;
      $out_participation {$wp2} = &tdlb (&w (&b ($regions))) .
                                  &tdlb (&w ($share)) .
                                  &tdrb (&w ($speakers)) .
                                  &tdrb (&w ($participation)) ;


      $out_html_verbose .= &tr ((($wikimedia && !$mode_wx)? &tdcb ($site) : &tdlb ($site)) .
                        (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") .
                        &tdcb (&w("<a href='TablesWikipedia" . uc($wpc) . ".htm'>T</a> | " .
                                  "<a href='ChartsWikipedia" . uc($wpc) . ".htm'>C</a>")) .
                      # &tdcb ("<a href='" . $out_urls {$wpc} . "'>" . &w($out_site2) . "</a>") .
                        &tdcb (&w ($lastdump2)) .
                        &tdrb (&w ($localization)) .
                        (! $mode_wx?&tdlb (&w (&b ($regions))):"") .
                        (! $mode_wx?&tdrb (&w ($speakers)):"") .
                        (! $mode_wx?&tdrb (&w ($participation)):"") .
                        (! $mode_wx?&tdlb (&w ($share)):"") .
                        &tdrb (&w ($views)) .
                        &tdrb (&w ($views_delta)) .
                        &tdcb (&w ($views_per_article)) .
                        &tdrb (&w ($a100)) .
                        &tdrb (&w ($a1000)) .
                        ($mode_wp?&tdrb (&w ($a10000)):"") .
                        ($mode_wp?&tdrb (&w ($a100000)):"") .
                        &tdrb (&w ($maxarticles2)) .
                        &tdrb (&w ($articles_plus)) .
                        &tdrb (&w ($articles_perc)) .
                        &tdrb (&w ($articles_perc2)) .
                        &tdrb (&w ($articles_new)) .
                        &tdrb (&w ($maxeditors2)) .
                        &tdrb (&w ($editors_plus)) .
                        &tdrb (&w ($editors_perc)) .
                        &tdrb (&w ($editors_perc2)) .
                        &tdrb (&w ($editors_ge_5)) .
                        &tdrb (&w ($editors_ge_100)) .
                        &tdcb ($site) .
                        &tdrb (&w ($access_sysop)) .
                        &tdrb (&w ($access_bureaucrat)) .
                        &tdrb (&w ($access_checkuser)) .
                        &tdrb (&w ($access_developer)) .
                        &tdrb (&w ($access_oversight)) .
                        &tdrb (&w ($access_bots)) .
                        &tdrb (&w ($access_ratio)) .
                        &tdrb (&w ($edits_tot)) .
                        &tdrb (&w ($edits_plus)) .
                        &tdrb (&w ($edits_perc)) .
                        &tdrb (&w ($edits_perc2)) .
                        &tdrb (&w ($edits_average)) .
                        &tdrb (&w ($edits_bot)) .
                        &tdrb (&w ($edits_anonymous)) .
                        &tdrb (&w ($words)) .
                        &tdrb (&w ($links_int)) .
                        &tdrb (&w ($links_ext)) .
                        &tdrb (&w ($links_iwi)) .
                        &tdrb (&w ($binaries)) .
                        &tdrb (&w ($redirects)) .
                        &tdrb (&w ($ns0)) .
                        &tdrb (&w ($ns2)) .
                        &tdrb (&w ($ns4)) .
                        &tdrb (&w ($ns6)) .
                        &tdrb (&w ($ns8)) .
                        &tdrb (&w ($ns10)) .
                        &tdrb (&w ($ns12)) .
                        &tdrb (&w ($ns14)) .
                        &tdrb (&w ($ns100)) .
                        &tdrb (&w ($ns102)) .
                        &tdrb (&w ($ns104)) .
                        &tdcb ($site) .
                        # ((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") ;
                        &tdlb ($out_language_name)) ;

      if (++$rows % 10 == 0)
      { $out_html_verbose .= &tr_hr ; }

      $articles_perc =~ s/\s*\(.*$// ;
      $editors_perc  =~ s/\s*\(.*$// ;
      $edits_perc    =~ s/\s*\(.*$// ;

      $out_html_concise .= &tr ((($wikimedia && !$mode_wx)? &tdcb ($site) : &tdlb ($site)) .
                        (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") .
                        &tdcb (&w("<a href='TablesWikipedia" . uc($wpc) . ".htm'>T</a> | " .
                                  "<a href='ChartsWikipedia" . uc($wpc) . ".htm'>C</a>")) .
                        &tdcb (&w ($lastdump2)) .
                        &tdrb (&w ($a100)) .
                        ($mode_wp?&tdrb (&w ($a10000)):"") .
                        &tdrb (&w ($maxarticles2b)) .
 #                      &tdrb (&w ($articles_plus)) .
                        &tdrb (&w ($articles_perc)) .
                        &tdrb (&w ($articles_new)) .
                        &tdrb (&w ($maxeditors2b)) .
#                       &tdrb (&w ($editors_plus)) .
                        &tdrb (&w ($editors_perc)) .
                        &tdrb (&w ($editors_ge_5)) .
                        &tdrb (&w ($editors_ge_100)) .
                        &tdrb (&w ($access_sysop)) .
                        &tdrb (&w ($access_bureaucrat)) .
                        &tdrb (&w ($access_checkuser)) .
                        &tdrb (&w ($access_developer)) .
                        &tdrb (&w ($access_oversight)) .
                        &tdrb (&w ($access_bots)) .
                        &tdrb (&w ($edits_tot2)) .
 #                      &tdrb (&w ($edits_plus)) .
                        &tdrb (&w ($edits_perc)) .
                        &tdrb (&w ($edits_average)) .
                        &tdrb (&w ($edits_bot)) .
                        &tdrb (&w ($edits_anonymous)) .
                        &tdrb (&w ($words2)) .
                        &tdrb (&w ($links_int2)) .
                        &tdrb (&w ($links_ext2)) .
                        &tdrb (&w ($links_iwi2)) .
                        &tdrb (&w ($binaries2)) .
                        &tdrb (&w ($redirects2)) .
                        &tdrb (&w ($ns0)) .
                        &tdrb (&w ($ns2)) .
                        &tdrb (&w ($ns4)) .
                        &tdrb (&w ($ns6)) .
                        &tdrb (&w ($ns8)) .
                        &tdrb (&w ($ns10)) .
                        &tdrb (&w ($ns12)) .
                        &tdrb (&w ($ns14)) .
                        &tdrb (&w ($ns100)) .
                        &tdrb (&w ($ns102)) .
                        &tdrb (&w ($ns104)) .
                        &tdcb ($site) .
                      # ((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") ;
                        &tdlb ($out_language_name)) ;

      if ($rows % 10 == 0)
      { $out_html_concise .= &tr_hr ; }
   }
  }

  $out_html = $out_html_start ;

  $legend = "<p><b>Legend: </b>(3m)=3 month average&nbsp;&nbsp;|&nbsp;&nbsp;<b>M</b>=x1000,000, <b>k</b>=x1000&nbsp;&nbsp;|&nbsp;&nbsp;" .
            "More: <b>T</b>=Tables, <b>C</b>=Charts" .
            "&nbsp;&nbsp;|&nbsp;&nbsp;Access: <b>A</b>=Admin, <b>B</b>=Bureaucrat, <b>C</b>=Checkuser, <b>D</b>=Developer, <b>O</b>=Oversight, <b>X</b>=bot, <b>R</b>=Ratio: Admins/New articles per day</small>" ;
  $out_html .= $legend ;
  $out_html .= "<a id='speakers' name='speakers'></a><p>Number of speakers of a language is the estimated total of primary and secondary speakers, and is in many cases a very rough estimation (based on the page on the English Wikipedia about that language)" ;
  $out_html .= "<br>Regions are parts of the world where the language is spoken in substantial amounts (compared to total number of speakers). Regions where a language gained presence only by a recent diaspora are generally not included." ;
  $out_html .= "<br>Region codes: <b>AF</b>:Africa, <b>AS</b>:Asia, <b>EU</b>:Europe, <b>NA</b>:North America, <b>OC</b>:Oceania, <b>SA</b>:South America, <b>W</b>:World Wide, <b>CL</b>:Constructed Language" ;

  $hint_speakers = "Number of speakers of a language is the estimated total of primary and secondary speakers, is in many cases a very rough estimation (based on the page on the English Wikipedia about that language)\\n\\n" .
                   "Regions are parts of the world where the language is spoken in substantial amounts (compared to total number of speakers). Regions where a language gained presence only by a recent diaspora are generally not included.\\n\\n" .
                   "Region codes: AF:Africa, AS:Asia, EU:Europe, NA:North America, OC:Oceania, SA:South America, W:World Wide, CL:Constructed Language" ;
  $hover_speakers = "See explanatory note at bottom of page" ;

  # for sitemap
  $participation {"intro"}  = "<a id='speakers' name='speakers'></a><p><b>Speakers:</b> Number of speakers of a language is the estimated total of primary and secondary speakers, is in many cases a very rough estimation (based on the page on the English Wikipedia about that language)" ;
  $participation {"intro"} .= "<br>Regions are parts of the world where the language is spoken in substantial amounts (compared to total number of speakers). Regions where a language gained presence only by a recent diaspora are generally not included." ;
  $participation {"intro"} .= "<br>Region codes: <b>AF</b>:Africa, <b>AS</b>:Asia, <b>EU</b>:Europe, <b>NA</b>:North America, <b>OC</b>:Oceania, <b>SA</b>:South America, <b>W</b>:World Wide, <b>CL</b>:Constructed Language<p>" ;

  $out_html .= "<p><b>Localization level:</b> The localization score expresses in a number between 0 and 100 how complete the localization for a given language is on <a href='http://translatewiki.net/wiki/Main_Page'>translatewiki.net</a>. It is a weighted average of the completeness levels for different categories of messages. For details see the <a href='http://svn.wikimedia.org/viewvc/mediawiki/trunk/extensions/Translate/scripts/groupStatistics.php?view=markup'>script</a>." ;
  $out_html .= "<p><b>Percentages:</b> percentage anonymous edits is calculated as percentage of manual edits (= total edits - bot edits). " ;
  $out_html .= "See below for <a href='#percentages'>explanation of other percentages</a>." ;
# $out_html =~ s/#version#/For less columns, and more figures rounded, see <a href='TablesCurrentStatusConcise.htm'>concise version<\/a>\n<p>/ ;
  $out_html =~ s/#version#// ;

  $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Tables and charts'>\n" ;

  $header1 =  &trh (((!$mode_wx)?&thcb5("Wikipedia"):&thcb4("Wikipedia")).
                    "<td rowspan=999></td>" .
                    (! $mode_wx ? &thcb ("Region") : "") .
                    (! $mode_wx ? &thcb3("Participation") : "") .
                    (! $mode_wx ? "<td rowspan=999></td>" : "") .
                    &thcb3("Page Views") .
                    "<td rowspan=999></td>" .
                    ((!$mode_wp)?&thcb7("Articles"):&thcb9("Articles")).
                    "<td rowspan=999></td>" .
                    &thcb4("Contributors") .
                    "<td rowspan=999></td>" .
                    &thcb2("Active editors") .
                    "<td rowspan=999></td>" .
                    (! $mode_wx ?&thcb("Wikipedia")."<td rowspan=999></td>" : "") .
                    &thcb7("Access") .
                    "<td rowspan=999></td>" .
                    &thcb7("Edits") .
                    "<td rowspan=999></td>" .
                    &thcb6("Database") .
                    "<td rowspan=999></td>" .
                    &thcb11("Namespaces") .
                    "<td rowspan=999></td>" .
                    &thcb2("Wikipedia")) ;

  $header3 = $header1 ;
  $header3 =~ s/<td rowspan=999><\/td>//g ;

  $out_participation {"header"} = &tdc("<img src='../Location_of_Continents.gif' border=0>") .
                                  &tdlbt("<small>&nbsp;<img src='../bluebar2_hor.gif' width=15 height=7> Speakers in millions<br>&nbsp;<font color=#909090>(log scale)</font> (<span onclick=\"alert('$hint_speakers');\"><font color=blue>?</font></span>)</small><br><small>&nbsp;<img src='../redbar2_hor.gif' width=15 height=7> Editors per million<br>&nbsp;speakers <font color=#909090>(5+ edits)</font></small>") .
                                  &tdcbt("<small>Prim.+Sec.<br>Speakers<br><font color=#909090>M=millions<br>k=thousands</font></small>") .
                                  &tdcbt("<small>Editors (5+)<br>per million<br>speakers</small>") ;

  $header2 = &trh2 (((!$mode_wx)?&thcb("<small>Language<br>code</small>"):"").
                    ((!$mode_wx)?&thlb("&nbsp;Language"):&thlb("&nbsp;Project")).
                    &thcb("<small>More</small>").
                    &thcb("Last<br>dump").
                    &thcb("<small>Locali-<br>zation<br>level</small>").
                    (! $mode_wx ? &thlb("<img src='../Location_of_Continents.gif'>") : "") . # "<small>Regions</small><br>"
                    (! $mode_wx ? &thcb("<small>Prim.+Sec.<br>Speakers<br>in millions</small>") : "") .
                    (! $mode_wx ? &thcb("<small>Editors (5+)<br>per million<br>speakers</small>") : "").
                    (! $mode_wx ? &thlb("<small>&nbsp;<img src='../bluebar2_hor.gif' width=15 height=7> Speakers in millions<br>&nbsp;(log scale)</small><br><small>&nbsp;<img src='../redbar2_hor.gif' width=15 height=7> Editors (5+) per<br>&nbsp;million speakers</small>") : "").
                    &thcb("<small>Views<br>per hour</small>").
                    &thcb("<small>Growth<br>last 12<br>months</small>").
                    &thcb("<small>Views<br>per hour<br>per<br>article</small>").
                    &thcb("100+").
                    &thcb("1000+").
                    ($mode_wp?&thcb("10,000+"):"").
                    ($mode_wp?&thcb("100,000+"):"").
                    &thcb("<a href='TablesArticlesTotal.htm'><small>Total</small></a>") .
                    &thcb3("Added last year<br><small>(since $articles_plus_since)<br>new | %new | %inc</small>") .
                    &thcb("<small>New<br>p/day<br>(3m)</small>") .
                    &thcb("<a href='TablesWikipediansContributors.htm'><small>Total</small></a>") .
                    &thcb3("Arrived last year<br><small>(since $articles_plus_since)<br>new | %new | %inc</small>") .
                    &thcb("<a href='TablesWikipediansEditsGt5.htm'><small>5+ edits<br>&nbsp;p/month&nbsp;</small></a><br><small>(3m)</small>") .
                    &thcb("<a href='TablesWikipediansEditsGt100.htm'><small>100+ edits<br>&nbsp;p/month&nbsp;</small></a><br><small>(3m)</small>") .
                    (! $mode_wx ? &thcb("<small>Language<br>code</small>") : "").
                    &thcb("A") .
                    &thcb("B") .
                    &thcb("C") .
                    &thcb("D") .
                    &thcb("O") .
                    &thcb("X") .
                    &thcb("R") .
                    &thcb("<a href='TablesDatabaseEdits.htm'><small>Total</small></a>") .
                    &thcb3("Edits last year<br><small>(since $articles_plus_since)<br>new | %new | %inc</small>") .
                    &thcb ("<a href='TablesArticlesEditsPerArticle.htm'><small>Avg.<br>per<br>article</small></a>") .
                    &thcb ("<a href='BotActivityMatrix.htm'><small>Bot<br>edits</small></a>") .
                    &thcb ("<small>Anony<br>mous<br>edits</small>") .
                  # &thcb("<a href='TablesDatabaseSize.htm'>Size</a>") .
                    &thcb("<a href='TablesDatabaseWords.htm'><small>Words</small></a>") .
                    &thcb("<a href='TablesDatabaseLinks.htm'><small>Links<br>int.</small></a>") .
                    &thcb("<a href='TablesDatabaseLinks.htm'><small>Links<br>ext.</small></a>") .
                    &thcb("<a href='TablesDatabaseLinks.htm'><small>Links<br>inter<br>wiki</small></a>") .
                    &thcb("<a href='TablesDatabaseImageLinks.htm'><small>Bina<br>ries</small></a>") .
                    &thcb("<a href='TablesDatabaseRedirects.htm'><small>Redi<br>rects</small></a>") .
                    &thcb("<small>Article</small>") .
                    &thcb("<small>User</small>") .
                    &thcb("<small>Project</small>") .
                    &thcb("<small>Binary</small>") .
                    &thcb("<small>Media<br>wiki</small>") .
                    &thcb("<small>Tem<br>plate</small>") .
                    &thcb("<small>Help</small>") .
                    &thcb("<small>Cate<br>gory</small>") .
                    &thcb("<small>Portal</small>") .
                    &thcb("<small>102</small>") .
                    &thcb("<small>104</small>").
                    (! $mode_wx ? &thcb("<small>Language<br>code</small>") : "").
                    (! $mode_wx ? &thlb("&nbsp;Language") : "")) ;

  $out_html .= $header1 . $header2 . $out_html_verbose . $header2 . $header3 ;

  $out_html .= "</table>\n" ;
  $out_html .= "</td><td width='30'>&nbsp;</td><td class='l' valign='top'>" ;
  $out_html .= "</table>\n" ;
  $out_html .= "</td>" ;
  $out_html .= "</tr>" ;
  $out_html .= "</table>\n" ;

  $out_html .= "<a id='percentages' name='percentages'></a>" .
               "<p>Percentages are shown as follows: <b>%new | %inc = x% | <small>+y%</small></b>" .
               "<p>x% shows which fraction of the current total results from last year's activity." .
               "<br>y% shows the same growth figure, but now as a percentual increase over last year's figure." .
               "<br>Both percentages have been rounded to integers." .
               "<p>Example:" .
               "<br>The total number of articles has increased in a year from 80,000 to 100,000 =>" .
               "<br>Equivalent statements are:" .
               "<br>- 20% of the current articles has been added last year." .
               "<br>- The current number of articles is 125% as large as a year ago." .
               "<br>- The number of articles has grown by 25% in a year." .
               "<br>This will be shown as <b>20% | <small>+25%</small></b>" ;

  $generate_sitemap = $false ;
  &GenerateColophon ($false, $false) ;

  $out_html .= "</body>\n</html>" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  my $file_html ;
  $file_html = $path_out . "TablesCurrentStatusVerbose.htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;

  $out_html = $out_html_start ;

  $out_html =~ s/#version#/For more columns, and less figures rounded, see <a href='TablesCurrentStatusVerbose.htm'>verbose version<\/a>. \n<p>/ ;
  $out_html .= $legend ;
  $out_html .= "<p><small>Note: anonymous edits is shown as percentage of manual edits (= total edits - bot edits).</small> " ;
  $out_html .= "<small>Read columns 'New last year' as: increase in last year as percentage of current total.</small>" ;
  $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Tables and charts'>\n" ;

  $header1 =  &trh (((!$mode_wx)?&thcb4("Wikipedia"):&thcb3("Wikipedia")).
                    "<td rowspan=999></td>" .
                    ((!$mode_wp)?&thcb4("Articles"):&thcb5("Articles")).
                    "<td rowspan=999></td>" .
                    &thcb2("Contributors") .
                    "<td rowspan=999></td>" .
                    &thcb2("Active editors") .
                    "<td rowspan=999></td>" .
                    &thcb6("Access") .
                    "<td rowspan=999></td>" .
                    &thcb5("Edits") .
                    "<td rowspan=999></td>" .
                    &thcb6("Database") .
                    "<td rowspan=999></td>" .
                    &thcb11("Namespaces") .
                    "<td rowspan=999></td>" .
                    &thcb2("&nbsp;Language")) ;

  $header3 = $header1 ;
  $header3 =~ s/<td rowspan=999><\/td>//g ;

  $header2 = &trh2 (((!$mode_wx)?&thcb("<small>Language<br>code</small>"):"").
                    ((!$mode_wx)?&thlb("&nbsp;Language"):&thlb("&nbsp;Project")).
                    &thcb("<small>More</small>").
                    &thcb("Last<br>dump").
                    &thcb("100+").
                    ($mode_wp?&thcb("10,000+"):"").
                    &thcb("<a href='TablesArticlesTotal.htm'><small>Total</small></a>") .
                    &thcb("<small>New<br>last<br>year</small>") .
                    &thcb("<small>New<br>p/day<br>(3m)</small>") .
                    &thcb("<a href='TablesWikipediansContributors.htm'><small>Total</small></a>") .
                    &thcb("<small>New<br>last<br>year</small>") .
                    &thcb("<a href='TablesWikipediansEditsGt5.htm'><small>5+ edits<br>&nbsp;p/month&nbsp;</small></a><br><small>(3m)</small>") .
                    &thcb("<a href='TablesWikipediansEditsGt100.htm'><small>100+ edits<br>&nbsp;p/month&nbsp;</small></a><br><small>(3m)</small>") .
                    &thcb("A") .
                    &thcb("B") .
                    &thcb("C") .
                    &thcb("D") .
                    &thcb("O") .
                    &thcb("X") .
                    &thcb("<a href='TablesDatabaseEdits.htm'><small>Total</small></a>") .
                    &thcb("<small>New<br>last<br>year</small>") .
                    &thcb ("<a href='TablesArticlesEditsPerArticle.htm'><small>Avg.<br>per<br>article</small></a>") .
                    &thcb ("<a href='BotActivityMatrix.htm'><small>Bot<br>edits</small>") .
                    &thcb ("<small>Anony<br>mous<br>edits</small>") .
                  # &thcb("<a href='TablesDatabaseSize.htm'>Size</a>") .
                    &thcb("<a href='TablesDatabaseWords.htm'><small>Words</small></a>") .
                    &thcb("<a href='TablesDatabaseLinks.htm'><small>Links<br>int.</small></a>") .
                    &thcb("<a href='TablesDatabaseLinks.htm'><small>Links<br>ext.</small></a>") .
                    &thcb("<a href='TablesDatabaseLinks.htm'><small>Links<br>inter<br>wiki</small></a>") .
                    &thcb("<a href='TablesDatabaseImageLinks.htm'><small>Bina<br>ries</small></a>") .
                    &thcb("<a href='TablesDatabaseRedirects.htm'><small>Redi<br>rects</small></a>") .
                    &thcb("<small>Article</small>") .
                    &thcb("<small>User</small>") .
                    &thcb("<small>Project</small>") .
                    &thcb("<small>Binary</small>") .
                    &thcb("<small>Media<br>wiki</small>") .
                    &thcb("<small>Tem<br>plate</small>") .
                    &thcb("<small>Help</small>") .
                    &thcb("<small>Cate<br>gory</small>") .
                    &thcb("<small>Portal</small>") .
                    &thcb("<small>102</small>") .
                    &thcb("<small>104</small>").
                    (! $mode_wx ? &thcb("<small>Language<br>code</small>") : "").
                    (! $mode_wx ? &thlb("&nbsp;Language") : "")) ;

  $out_html .= $header1 . $header2 . $out_html_concise . $header2 . $header3 ;

  $out_html .= "</table>\n" ;
  $out_html .= "</td><td width='30'>&nbsp;</td><td class='l' valign='top'>" ;
  $out_html .= "</table>\n" ;
  $out_html .= "</td>" ;
  $out_html .= "</tr>" ;
  $out_html .= "</table>\n" ;

  $generate_sitemap = $false ;
  &GenerateColophon ($true, $false) ;

  $out_html .= "</body>\n</html>" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  $file_html = $path_out . "TablesCurrentStatusConcise.htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;

  open  FILE_OUT, '>', $file_csv_participation ;
  print FILE_OUT @participations ;
  close FILE_OUT ;
}

sub GenerateBotSummary
{
  &LogT ("\nGenerateBotSummary") ;

  @bots = sort { $BotStatsBotTot1 {$b} <=> $BotStatsBotTot1 {$a}} keys %BotStatsBotTot1 ;

  my $out_html_title    = $out_statistics . " \- " . "Bot activity" ;
  my $out_page_title    = $out_statistics ;
  my $out_page_subtitle = "Bot activity" ;
  my $language ;
  my $out_button_switch = "home" ;
  my $out_explanation = "Only registered bots have been included. Only bot edits for articles have been counted.<br>" .
                        "Names registered as bot on at least 10 projects are assumed to be bot on all projects." ;
  my $out_msg = "" ;

  &GenerateHtmlStart ($out_html_title,  $out_zoom_buttons2, $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

  $out_html .= "<a id='botmatrix' name='botmatrix'></a>" . &b($out_tbl_bot_usage_matrix_summary_intro) ;
  $out_html .= "<table border=1 cellspacing=0 id='table1' style=''  summary='Bots Usage Matrix'>\n" ;

  $wikimedia = $true ;
  if (! $mode_wx)
  { &GenerateComparisonTableHeadersCascade ($f, $true, 9999) ; }
  if ($wikimedia)
  { &GenerateComparisonTableHeaders ($f, $true) ; }

  $line_html  = &tdlb (&w ("&Sigma; total edits")) ;
  $line_html .= &tdrb ("xxx") ;
  $tot_gen = 0 ;
  foreach my $wp (@languages)
  {
    if ($wp eq "zz") { next ; }
    if ($skip {$wp}) { next ; }
    $cnt = @MonthlyStats {$wp.$c[11].'tot'} ;
    $tot_gen += $cnt ;
    $cnt = &i2KM ($cnt) ;
    if (($wp eq "en") && ($BotStatsWpTot1 {$wp} == 0))
    { $cnt = "" ; } # no data yet
    $line_html .= &tdrb (&w ($cnt)) ;
  }
  $tot = &i2KM ($tot_gen) ;
  $line_html =~ s/xxx/$tot/ ;
  $out_html  .= &tr ($line_html) ;

  $line_html =  &tdlb (&w ("&Sigma; manual edits")) ;
  $line_html .= &tdrb ("xxx") ; # &tde ;
  $tot_man = 0 ;
  foreach my $wp (@languages)
  {
    if ($wp eq "zz") { next ; }
    if ($skip {$wp}) { next ; }
    $cnt = @MonthlyStats {$wp.$c[11].'tot'} - $BotStatsWpTot1 {$wp} ;
    $tot_man += $cnt ;
    $cnt = &i2KM ($cnt) ;
    if (($wp eq "en") && ($BotStatsWpTot1 {$wp} == 0))
    { $cnt = "" ; } # no data yet
    $line_html .= &tdrb (&w ($cnt)) ;
  }
  $tot = &i2KM ($tot_man) ;
  $line_html =~ s/xxx/$tot/ ;
  $out_html  .= &tr ($line_html) ;

  $line_html =  &tdlb (&w (&b ("<font color='#400040'>&Sigma; bot edits</font>"))) ;
  $line_html .= &tdrb (&w (&b (&i2KM ($BotStatsTotGen1)))) ;
  $columns = 2 ;

  $tot_bot = 0 ;
  foreach my $wp (@languages)
  {
    if ($wp eq "zz") { next ; }
    if ($skip {$wp}) { next ; }
    $cnt = $BotStatsWpTot1 {$wp} ;
    $tot_bot += $cnt ;
    $cnt = &i2KM ($cnt) ;
    $line_html .= &tdrb (&b (&w ($cnt))) ;
    $columns++ ;
  }
  $out_html  .= &tr ($line_html) ;

  $line_html =  &tdlb (&w (&b ("<font color='#400040'>Share of bot edits</font>"))) ;
  $line_html .= &tdrb ("xxx") ; # &tde ;
  foreach my $wp (@languages)
  {
    if ($wp eq "zz") { next ; }
    if ($skip {$wp}) { next ; }
    $cnt = @MonthlyStats {$wp.$c[11].'tot'} ;
    if (($cnt > 0) && ($BotStatsWpTot1 {$wp} > 0))
    {
      $perc = 100 * $BotStatsWpTot1 {$wp} / $cnt ;
      if ($perc >= 1)
      { $perc = sprintf ("%.0f", $perc) . "%" ; }
      else
      { $perc = sprintf ("%.1f", $perc) . "%" ; }
    }
    else
    { $perc = "" ; }
    if (($wp eq "en") && ($BotStatsWpTot1 {$wp} == 0))
    { $perc = "" ; } # no data yet
    $line_html .= &tdrb (&w (&b ($perc))) ;
  }
  $perc_bot = &b (sprintf ("%.1f", 100 * $tot_bot / $tot_gen) . "%") ;
  $line_html =~ s/xxx/$perc_bot/ ;
  $out_html  .= &tr ($line_html) ;

  $out_html  .= &tr ("<td colspan=$columns></td>") ;

  foreach $bot (@bots)
  {
    if ($botrows++ > 1000)          { last ; }
    if ($BotStatsBotTot1 {"$bot"} < 100) { last ; }

    $line_html  = &tdlb ($bot) ;
    $line_html .= &tdrb (&b (&i2KM ($BotStatsBotTot1 {"$bot"}))) ;
    $cnt0 = 0 ;
    $cols = 0 ;
    foreach my $wp (@languages)
    {
      if ($wp eq "zz") { next ; }
      if ($skip {$wp}) { next ; }
      $cols++ ;
      $cnt = $BotStatsWpBot1 {"$wp|$bot"} ;
      if (($cnt == 0) && (defined ($BotStatsWpBot1 {"$wp|$bot"})))
      { $cnt = "*" ; }

      if ($cnt == 0)
      { $cnt0 ++ ; }

      if (($cnt > 0) || ($cols % 5 == 0))
      {
        if ($cnt0 == 1)
        { $line_html .= &tdrb (&w (0)) ; }
        elsif ($cnt0 > 1)
        { $line_html .= &tdrbc ($cnt0, &w (0)) ; }
        $cnt0 = 0 ;

        if ($cnt > 0)
        {
          if ($BotStatsTotGen1 > 10000)
          { $cnt = &i2KM ($cnt) ; }

          if ($cnt =~ /\d\./)
          {
            if ($out_decimal_separator ne ".")
            { $cnt =~ s/\./$out_decimal_separator/ ; }
          }

          $line_html .= &tdrb ($cnt) ;
        }
      }
    }

    if ($cnt0 == 1)
    { $line_html .= &tdrb (&w (0)) ; }
    else
    { $line_html .= &tdrbc ($cnt0, &w (0)) ; }

  # $line_html =~ s/(?:<td class=rb colspan=5>&nbsp;<\/td>)+(?:<td class=rb>&nbsp;<\/td>)$/<td class=rb colspan=999>&nbsp;<\/td>/ ;
    $out_html  .= &tr ($line_html) ;
  }
  $out_html .= "<\/table>" ;

  &GenerateColophon ($false, $false) ;
  $out_html .= "\n$out_script_embedded\n</body>\n</html>" ;
  $file_html = $path_out . "BotActivityMatrix.htm" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  $out_html =~ s/a:hover\s*\{[^\}]*\}/a:hover {text-color:black;color:black;text-decoration:underline;}/ ;

  open "FILE_OUT", ">", $file_html || abort ("Output file " . $file_html . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub GenerateGrowthSummary
{
#  if ($mode_wp)
#  { return ; }
  my $out_html_title    = $out_statistics . " \- " . $out_sitemap ;
  my $out_page_title    = $out_statistics ;
# my $out_page_subtitle = "$out_creation_history / $out_accomplishments" ;
  my $out_page_subtitle = "$out_creation_history - " . $out_report_descriptions [0] ;
  my $out_explanation   = "See also: <a href='TablesWikipediaGrowthSummaryArticles.htm'>Creation history - Articles</a>" ;
  my $language ;
  my $crossref ;
  my $out_button_switch = "home" ;

  if ($mode_wv)
  { $out_explanation = "Note: For each wikiversity the month listed indicates when the first course material was added on wikibooks." .
                       "<br>This predates the official launch date of Wikiversity as a project (August 2006)." ; }

  &GenerateHtmlStart ($out_html_title,  $out_zoom_buttons2, $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

  $m1 = $MonthlyStatsWpStart {"zz"} ;

  $m2 = $dumpmonth_ord - 1 ;
  if ($m2 < $m1 + 5)
  { return ; }

# $out_html .= "<a id='growthsummary' name='growthsummary'></a>" . &b($out_tbl_growth_summary_intro) ;
# $out_html .= "<h3>" . @out_report_descriptions [0] . "</h3>" . @out_tbl3_legend [0] ."<p>" ;

  $out_html .= "$average_increase: ${out_report_descriptions [0]} "  .
               "0 &le; <b><font color='#A05050'>Xxx</font></b>" .
               " &lt; 0.5 &le; <b><font color='#A08000'>Xxx</font></b>" .
               " &lt; 5 &le; <b><font color='#007000'>Xxx</font></b>" .
               " &lt; 50 &le; <b><font color='#0000A0'>Xxx</font></b><p>" ;

  $out_html .= "<table border=1 cellspacing=0 id='table1' style=''  summary='Growth summary'>\n" ;
  $line_html = &tdlb ($out_created) . &tdlb ($out_report_descriptions [0]) ;
  $out_html  .= &trh ($line_html) ;
  for ($m = $m1 ; $m <= $m2 ; $m++)
  {
    $MonthlyStatsWpStartPerMonth {$m} =~ s/,$// ;
    my @NewWp = split (',', $MonthlyStatsWpStartPerMonth {$m}) ;

    $line_html = &tdrb (&GetDateShort2 ($m)) ;
    $data = "" ;

    @NewWp = sort { $MonthlyStatsHigh {$b.'A'} <=> $MonthlyStatsHigh {$a.'A'} } @NewWp ;
    foreach my $wp (@NewWp)
    {
      my $dm = $m2 - $MonthlyStatsWpStart {$wp} + 1 ;
      $language = $out_languages {$wp} ;
      if ($language eq "")
      { $language = "{$wp}" ; }

      $editors     = $MonthlyStatsHigh {$wp.'A'} ;

      if ($editors <= $dm/2)
      { $color = "#A05050" ; }
      elsif ($editors >= $dm*50)
      { $color = "#0000A0" ; }
      elsif ($editors >= $dm*5)
      { $color = "#007000" ; }
      else
     { $color = "#A08000" ; }

      $anchor  = "<a href='TablesWikipedia".uc ($wp).".htm' title='$wp'><font color=$color><b>$language</b></font></a> " ;
      $editors_txt = sprintf ("%d", $editors) ;
      $editors_txt = "<font color=$color>$anchor <font color=black>$editors_txt</font></font>" ;
      $data .= $editors_txt . "&nbsp;|&nbsp;" ;
    }
    $data =~ s/\&nbsp;\|\&nbsp;$// ;
    $data =~ s/\|/<font color=#909090>\|<\/font>/g ;
    $line_html .= &tdlb ($data) ;
    $out_html  .= &tr ($line_html) ;
  }
  $out_html .= "</table>\n" ;

  $out_html .= "<p>$average_increase: ${out_report_descriptions [0]} " .
               "0 &le; <b><font color='#A05050'>Xxx</font></b>" .
               " &lt; 0.5 &le; <b><font color='#A08000'>Xxx</font></b>" .
               " &lt; 5 &le; <b><font color='#007000'>Xxx</font></b>" .
               " &lt; 50 &le; <b><font color='#0000A0'>Xxx</font></b>" ;

  &GenerateColophon ($false, $false) ;
  $out_html .= "\n$out_script_embedded\n</body>\n</html>" ;
  $file_html = $path_out . "TablesWikipediaGrowthSummaryContributors.htm" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  $out_html =~ s/a:hover\s*\{[^\}]*\}/a:hover {text-color:black;color:black;text-decoration:underline;}/ ;
  open "FILE_OUT", ">", $file_html || abort ("Output file " . $file_html . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;

# ----------------------------------------------------------------------

  $out_explanation   = "See also: <a href='TablesWikipediaGrowthSummaryContributors.htm'>Creation history - Contributors</a>" ;

  $out_page_subtitle = "$out_creation_history - " . $out_report_descriptions [4] ;

  &GenerateHtmlStart ($out_html_title,  $out_zoom_buttons2, $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

# $out_html .= "<br><a id='growthsummary' name='growthsummary'>&nbsp;</a><hr>" . &b($out_tbl_growth_summary_intro) . "<br>"  ;
# $out_html .= "<h3>" . @out_report_descriptions [4] . "</h3>" . @out_tbl3_legend [4] ."<p>" ;

  $out_html .= "$average_increase: ${out_report_descriptions [4]} " .
               "0 &le; <b><font color='#A05050'>Xxx</font></b>" .
               " &lt; 5 &le; <b><font color='#A08000'>Xxx</font></b>" .
               " &lt; 50 &le; <b><font color='#007000'>Xxx</font></b>" .
               " &lt; 500 &le; <b><font color='#0000A0'>Xxx</font></b><p>" ;

  $out_html .= "<table border=1 cellspacing=0 id='table2' style='' summary='Growth summary'>\n" ;
  $line_html = &tdlb ($out_created) . &tdlb ($out_report_descriptions [4]) ;
  $out_html  .= &trh ($line_html) ;
  for ($m = $m1 ; $m <= $m2 ; $m++)
  {
    $MonthlyStatsWpStartPerMonth {$m} =~ s/,$// ;
    my @NewWp = split (',', $MonthlyStatsWpStartPerMonth {$m}) ;

    $line_html = &tdrb (&GetDateShort2 ($m)) ;
    $data = "" ;

    @NewWp = sort { $MonthlyStatsHigh {$b.'E'} <=> $MonthlyStatsHigh {$a.'E'} } @NewWp ;
    foreach my $wp (@NewWp)
    {
      my $dm = $m2 - $MonthlyStatsWpStart {$wp} + 1 ;
      $language = $out_languages {$wp} ;
      if ($language eq "")
      { $language = "{$wp}" ; }

      $articles = $MonthlyStatsHigh {$wp.'E'} ;

      if ($articles <= $dm*5)
      { $color = "#A05050" ; }
      elsif ($articles >= $dm*500)
      { $color = "#0000A0" ; }
      elsif ($articles >= $dm*50)
      { $color = "#007000" ; }
      else
     { $color = "#A08000" ; }

      $anchor  = "<a href='TablesWikipedia".uc ($wp).".htm' title='$wp'><font color=$color><b>$language</b></font></a> " ;
      $articles_txt = sprintf ("%d", $articles) ;
      $articles_txt = "<font color=$color>$anchor <font color=black>$articles_txt</font></font>" ;
      $data .= $articles_txt . "&nbsp;|&nbsp;" ;
    }

    $data =~ s/\&nbsp;\|\&nbsp;$// ;
    $data =~ s/\|/<font color=#909090>\|<\/font>/g ;
    $line_html .= &tdlb ($data) ;
    $out_html  .= &tr ($line_html) ;
  }
  $out_html .= "</table>\n" ;
  $out_html .= "<p>$average_increase: ${out_report_descriptions [0]} " .
               "0 &le; <b><font color='#A05050'>Xxx</font></b>" .
               " &lt; 5 &le; <b><font color='#A08000'>Xxx</font></b>" .
               " &lt; 50 &le; <b><font color='#007000'>Xxx</font></b>" .
               " &lt; 500 &le; <b><font color='#0000A0'>Xxx</font></b>" ;


  &GenerateColophon ($false, $false) ;
  $out_html .= "\n$out_script_embedded\n</body>\n</html>" ;
  $file_html = $path_out . "TablesWikipediaGrowthSummaryArticles.htm" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  $out_html =~ s/a:hover\s*\{[^\}]*\}/a:hover {text-color:black;color:black;text-decoration:underline;}/ ;
  open "FILE_OUT", ">", $file_html || abort ("Output file " . $file_html . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;

  $growth_summary_generated = $true ;
}

sub GenerateWikiSpecificTables
{
  my $t0 = time ;
  my $t1 = $t0 ;
  &Log ("\n") ;

  if ($mode_wp)
  { &GenerateTablesPerWiki ("zzz") ; }

  foreach $wp (@languages)
  {
    &GenerateTablesPerWiki ($wp) ;
    if (++$tablesgenerated % 10 == 0)
    {
      $t = time ;
      $dt0 = $t - $t0 ;
      $dt1 = $t - $t1 ;
      &Log ("$tablesgenerated in $dt0 sec (+$dt1), ") ;
      $t1 = $t ;
    }
  }
  if ($tablesgenerated % 10 != 0)
  {
    $t = time ;
    $dt0 = $t - $t0 ;
    $dt1 = $t - $t1 ;
    &Log ("$tablesgenerated in $dt0 sec (+$dt1) ") ;
  }
  if ($mode_wp)
  {
    for $table (sort {$TimesGenerateTables{$b} <=> $TimesGenerateTables {$a}} keys %TimesGenerateTables)
    { &Log ("\n" . sprintf ("%3d sec ", $TimesGenerateTables {$table}) . " - $table") ; }
  }
}

sub GenerateTablesPerWiki
{
  my $wp = shift ;

  $show_all_months = $false ;
  $total_months = $dumpmonth_ord - $MonthlyStatsWpStart {$wp} + 1 ;
  if (($total_months <= 24) || ($wp =~ /^zz+$/) || ($wp ne 'commons'))
  { $show_all_months = $true ; }

  &ReadLog ($wp) ;

  $out_toc  = "" ;
  if ($wp !~ /^zzz?$/)
  {
    $out_toc  = "Monthly counts & Quarterly rankings" ;
    $out_toc .= " / " . blank_text_after ("15/10/2009", "<font color=#008000>". &b(ucfirst($out_new). ": ") . "</font>") . " <a href='#activitylevels'>Editor activity levels</a>" ;
    $out_toc .= " / <a href='#editdistribution'>Distribution of article edits</a>" ;
    $out_toc .= " / Most prolific <a href='#wikipedians'>active</a> and " ;
    $out_toc .= "<a href='#sleeping'>inactive</a> registered contributors, " ;
    $out_toc .= "<a href='#anonymous'>anonymous contributors</a> and " ;
    $out_toc .= "<a href='#bots'>bots</a>" ;
    if ($mode_wp)
    { $out_toc .= " / <a href='#distribution'>Articles per size range</a>" ; }
    $out_toc .= " / <a href='#namespaces'>Records per namespace</a>" ;
    $out_toc .= " / <a href='#mostedited'>Most edited articles</a>" ;
    $out_toc .= " / <a href='#zeitgeist'>Zeitgeist</a>" ;
  }

  &GenerateHtmlStartWikipediaReport ($wp, "Tables", $out_zoom_buttons, $out_toc) ;

# if ($wikimedia && ($wp eq "en") && $mode_wp)
# { $out_html .= "<br><font color=#C00000>Note: for the English Wikipedia data for months after Sep 2006 are based on a partial database dump (only event meta data, no article contents).<br>" .
#                 "Therefore some information for those months can not yet be shown.</font><br>" ; }

# elsif (($wp eq "zz") && $ReportLargeWikiDataMissing)
  if ($wp eq "zz")
  {
    if ($ReportLargeWikiDataMissing)
    {
      my $from  = &GetDateShort2En ($MonthlyStatsWpStopLo) ;
      if ($dumpmonth_ord - $MonthlyStatsWpStopLo <= 3)
      { $out_html .= "<font color=#800000>   Note: data for months after $from for one or more large projects ($ListLargeWikisDataMissing) are not yet known.<br>" .
                     "For those months totals for all languages combined can not yet be shown.</font><p>" ; }
      else
      {
        if (! $mode_wp)
        { $out_html .= "<font color=#FF0000><b>Note: data for month(s) after $from for one or more large projects ($ListLargeWikisDataMissing) are not yet known.<br>" .
                       "For those month(s) totals for all languages combined can not yet be shown.</b></font><p>" ; }
        else
        { $out_html .= "<font color=#FF0000><b>Note: data for month(s) after $from for one or more large projects ($ListLargeWikisDataMissing) are not yet known.<br>" .
                       "For those month(s) totals for all languages combined can not yet be shown.<br>" .
                       "See also <a href='TablesWikipediaZZZ.htm'>report version without the English Wikipedia.</a>" .
                       "</b></font><p>" ; }
      }
    }
    if ($mode_wp)
    { $out_html .= "<p>Partially filled rows for recent months can also occur. In that case only selected data were collected for one or more large projects, due to time constraints.<p>" ; }
  }

  elsif ($wp eq "zzz")
  {
     my $from  = &GetDateShort2En ($MonthlyStatsWpStopLo2) ;
     $out_html .= "<font color=#FF0000><b>Note: data for month(s) after $from for the English Wikipedia are not yet known.<br>" .
                  "This report show totals without the English Wikipedia.<br>" .
                  "Switch back to <a href='TablesWikipediaZZ.htm'>regular report version with recent months missing.</a>" .
                  "</b></font><p>" ;
  }

  if ($wikimedia)
  { $out_html .= blank_text_after ("9/08/2009", "<p><font color=#008000>". &b(ucfirst($out_new).": ") .
                 "July 17, 2009: the method of counting total and new $out_publishers has changed. All wikis will be upgraded to this new scheme in coming weeks.<br>" .
                 "In the new scheme $out_publishers will only be included in total/new $out_publishers from the month in which they made their 10th edit, not the month in which they registered.</font><br>" ) ; }
  if ($wikimedia && ($wp eq "en") && $mode_wp)
  { $out_html .= blank_text_after ("9/08/2009", "<p><font color=#008000>" .
                 "The English Wikipedia uses this new scheme, other wikis will follow.</font><br>" ) ; }

  my ($t0,$t1) ;
  if ($mode_wp) { $t0 = time ; }
  &GenerateTableMonthlyStats ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableMonthlyStats"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableDistributionUsers ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableDistributionUsers"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableDistributionActiveUsers ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableDistributionActiveUsers"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableMostActiveUsers ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableMostActiveUsers"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableSleepingUsers ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableSleepingUsers"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableAnonymousUsers ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableAnonymousUsers"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableMostActiveBots ($wp) ;
  if ($mode_wp)
  { &GenerateTableSizeDistribution ($wp) ; }
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableSizeDistribution"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableNamespaces ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableNamespaces"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableEditsPerTable ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableEditsPerTable"} += $t1 - $t0 ; $t0 = $t1 ; }
  &GenerateTableZeitGeist ($wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableZeitGeist"} += $t1 - $t0 ; $t0 = $t1 ; }
  # &GenerateTableVisitorStats ($wp) ;

  &GenerateColophon ($false, $false) ;
  $out_html .= "\n$out_script_embedded\n</body>\n</html>" ;
  $file_html = $path_out . "TablesWikipedia" . uc($wp) . ".htm" ;
  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  open "FILE_OUT", ">", $file_html || abort ("Output file " . $file_html . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;

}

sub GenerateTableMonthlyStats
{
  my $wp = shift ;

  $imagelinks_incomplete = $false ;
  if ((($wp !~ /^zzz?/) && ($imagecodes {$wp}  !~ /(?:^|\|)IMAGE(?:$|\|)/i)) ||
      (($wp =~ /^zzz?/) && ($imagecodes {"de"} !~ /(?:^|\|)IMAGE(?:$|\|)/i)))
  { $imagelinks_incomplete = $true ; }
  if ((($wp !~ /^zzz?/) && ($imagecodes {$wp}  !~ /(?:^|\|)FILE(?:$|\|)/i)) ||
      (($wp =~ /^zzz?/) && ($imagecodes {"de"} !~ /(?:^|\|)FILE(?:$|\|)/i))) # de is last one to be fixed
  { $imagelinks_incomplete = $true ; }

  if ($wp !~ /^zzz?$/)
  { $out_html .= "\n\n<a id='monthlycounts' name='monthlycounts'>&nbsp;</a><br>" . &b("Monthly counts & Quarterly rankings") . "<br>&nbsp;\n" ; }

  if ($mode_wp)
  {
    $out_html .= "<table border=1 cellspacing=0 id='table1' style='' summary='Monthly stats'>\n" ;
    $out_html .= &trh (&tdcb  (&b($out_date)) .
                 &tdc4b (&b("<a href='#wikipedians'>$out_tbl3_hdr1a</a>")) .
                 &tdc7b (&b("<a href='#distribution'>$out_tbl3_hdr1e</a>")) .
                 &tdc3b (&b("<a href='#namespaces'>$out_tbl3_hdr1l</a>")) .
                 &tdc5b (&b($out_tbl3_hdr1o))) ;
  #  if ($wikimedia)
  #  { $out_html .= &tdc2b (&b($out_tbl3_hdr1t)) ; }

    $header1   = &tde2b.
                 &tdcr2ab (0,$out_tbl3_hdr2a) .
                 &tdcr2ab (1,$out_tbl3_hdr2b) .
                 &tdc2b   ($out_tbl3_hdr2c) .
                 &tdc2b   ($out_tbl3_hdr2e) .
                 &tdcr2ab (6,$out_tbl3_hdr2f) .
                 &tdc2b   ($out_tbl3_hdr2h) .
                 &tdc2b   ($out_tbl3_hdr2j) .
                 &tdcr2ab (11,$out_tbl3_hdr2l) .
                 &tdcr2ab (12,$out_tbl3_hdr2m) .
                 &tdcr2ab (13,$out_tbl3_hdr2n) .
                 &tdcr2ab (14,$out_tbl3_hdr2o) .
                 &tdcr2ab (15,$out_tbl3_hdr2p) .
                 &tdcr2ab (16,$out_tbl3_hdr2q) .
                 &tdcr2ab (17,$out_tbl3_hdr2r) .
                 &tdcr2ab (18,$out_tbl3_hdr2s) ;
    # if ($wikimedia)
    # { $header1 .= &tdcr2ab (19,$out_tbl3_hdr2t) .
    #               &tdcr2ab (20,$out_tbl3_hdr2u) ; }

    $header1   = &trh2 ($header1) ;

    $header1b = $header1 ;
    $header1c = $header1 ;

    $out_tbl3_hdr3f2 = $out_tbl3_hdr3f ;
    if (($wp eq "ja") || ($wp eq "zh"))
    { $out_tbl3_hdr3f2 =~ s/([^\#\d])200([^\;])/$1 . "50" . $2/e ; }

    $header2   = &trh2 (
                 &tdcab (2,$out_tbl3_hdr3c) .
                 &tdcab (3,$out_tbl3_hdr3d) .
                 &tdcab (4,$out_tbl3_hdr3e) .
                 &tdcab (5,$out_tbl3_hdr3f2) .
                 &tdcab (7,$out_tbl3_hdr3h) .
                 &tdcab (8,$out_tbl3_hdr3i) .
                 &tdcab (9,$out_tbl3_hdr3j) .
                 &tdcab (10,$out_tbl3_hdr3k)) ;
  }

  if (! $mode_wp)
  {
    $out_html .= "<table border=1 cellspacing=0 id='table1' style='' summary='Monthly stats'>\n" ;
    $out_html .= &trh (&tdcb (&b($out_date)) .
                 &tdc4b (&b("<a href='#wikipedians'>$out_tbl3_hdr1a</a>")) .
                 &tdc4b (&b($out_tbl3_hdr1e)) .
                 &tdc3b (&b($out_tbl3_hdr1l)) .
                 &tdc5b (&b($out_tbl3_hdr1o))) ;
               # &tdc2b (&b($out_tbl3_hdr1t))) ;

    $header1   = &trh2 (&tde2b.
                 &tdcr2ab (0,$out_tbl3_hdr2a) .
                 &tdcr2ab (1,$out_tbl3_hdr2b) .
                 &tdc2b   ($out_tbl3_hdr2c) .
                 &tdcr2ab (4,$out_tbl3_hdr2e) .
                 &tdcr2ab (6,$out_tbl3_hdr2f) .
                 &tdc2b   ($out_tbl3_hdr2h) .
                 &tdcr2ab (11,$out_tbl3_hdr2l) .
                 &tdcr2ab (12,$out_tbl3_hdr2m) .
                 &tdcr2ab (13,$out_tbl3_hdr2n) .
                 &tdcr2ab (14,$out_tbl3_hdr2o) .
                 &tdcr2ab (15,$out_tbl3_hdr2p) .
                 &tdcr2ab (16,$out_tbl3_hdr2q) .
                 &tdcr2ab (17,$out_tbl3_hdr2r) .
                 &tdcr2ab (18,$out_tbl3_hdr2s)) ;
               # &tdcr2ab (19,$out_tbl3_hdr2t) .
               # &tdcr2ab (20,$out_tbl3_hdr2u)) ;

    $header1b = $header1 ;
    $header1c = $header1 ;

    $header2   = &trh2 (
                 &tdcab (2,$out_tbl3_hdr3c) .
                 &tdcab (3,$out_tbl3_hdr3d) .
                 &tdcab (7,$out_tbl3_hdr3h) .
                 &tdcab (8,$out_tbl3_hdr3i)) ;
  }

  $out_html .= $header1 ;
  $out_html .= $header2 ;


  &TableMonthlyStatsTrends ($wp) ;

  # for (my $m = $dumpmonth_ord ; $m >= $MonthlyStatsWpStart {$wp} ; $m--)
  # for (my $m = $MonthlyStatsWpStop {$wp} ; $m >= $MonthlyStatsWpStart {$wp} ; $m--)

  if ($wp eq "zzz")
  { $m1 = $MonthlyStatsWpStopLo2 ; }
  elsif ($wp eq "zz")
  { $m1 = $MonthlyStatsWpStopLo ; }
  else
  { $m1 = $MonthlyStatsWpStop {$wp} ; }

  $lines_html_1 = "" ;
  $lines_html_2 = "" ;
  my $months = 0 ;

  for (my $m = $m1 ; $m >= $MonthlyStatsWpStart {$wp} ; $m--)
  {
    if ($m == $MonthlyStatsWpStop {$wp})
    { $line_html = &tdrb (&GetDateShort($MonthlyStatsWpDate {$wp}, $false)) ; }
    else
    { $line_html = &tdrb (&GetDateShort2 ($m)) ; }

    for ($f = 0 ; $f <= $fmax ; $f++)
    {
      if (($mode_wp) ||
          (($f != 5) && ($f != 9) && ($f != 10)))
      {
        $value = &format($MonthlyStats {$wp.$m.$c[$f]},$c[$f]) ;
        if (($f == 16) && $imagelinks_incomplete)
        { $value = "($value)" ; }
        $line_html .= &tdrb ($value) ;
      }
    }

    if ($show_all_months)
    { $lines_html_1 .= &tr ($line_html) ; }
    else
    {
      if ($months++ < 12)
      { $lines_html_1 .= &tr ($line_html) ; }

      next if $m % 3 != 1 ;

      { $lines_html_2 .= &tr ($line_html) ; }
    }

    # $out_html .= &tr ($line_html) ;

    if ($m == $dumpmonth_ord)
    {
      if ($true) # if ($show_forecasts)
      {
        if ($javascript)
        {
          $line_html = "\n<script language='javascript'>\n" .
                       "trc('#ffdead');\n" .
                       "<\/script>\n" ;
        }
        else
        { $line_html = "<tr bgcolor='#ffdead'>" ; }

        $line_html .= "<td colspan=333 class=cb>" .
                     "<img src='../black.gif' height='1' alt=''></td></tr>" ;
        $out_html .= $line_html ;
      }

      if (($show_forecasts) && (defined ($MonthlyStats {$wp.$m.$c[0]})))
      { &TableMonthlyStatsForecast ($wp) ; }
    }
  }

  $out_html .= $lines_html_1 ;
  if (! $show_all_months)
  {
    $out_html .= "<tr bgcolor=#ffdead><td colspan=333 class=lb><img src='../black.gif' width='1' height='4' alt=''></td></tr>" ;
    $out_html .= $lines_html_2 ;
  }

  $header1b =~ s/<\/?a[^>]*>//g ;
  $header1c =~ s/<\/?a[^>]*>//g ;
  $header2  =~ s/<\/?a[^>]*>//g ;
  $header1b =~ s/$out_tbl3_hdr2s/<hr><br>$out_tbl3_hdr2s2/ ;
  $header1c =~ s/$out_tbl3_hdr2s/$out_tbl3_hdr2s2/ ;

  $out_html .= $header1b ;
  $out_html .= $header2 ;

  if ((! $mode_wx) && ($wp !~ /^zzz?$/) && ($MonthlyStats {$wp.$MonthlyStatsWpStop {$wp}.$c[4]} >= 1000))
  {
    $out_table_ranks = "The following table ranks this project in relation to projects in other languages with 1000+ articles" ;

    if ($ReportLargeWikiDataMissing)
    {
      if ($MonthlyStatsWpStopLo < $MonthlyStatsWpStop {$wp})
      {
        my $from  = &GetDateShort2En ($MonthlyStatsWpStopLo) ;
        $out_table_ranks .= "<br><font color=#A00000><small>Note: data for month(s) after $from for one or more large projects are not yet known.<br>" .
        "As a temporary approximation missing data for a project are substituted by the highest historic value for that project.<br>" .
        "Once those missing data are available final rankings for recent months can shift one or more positions.</small>" ;
      }
    }
  # $out_html .= blank_text_after ("31/03/2009", &trh(&tdcxnb(99,$out_table_ranks))) ;
    $out_html .= &trh(&tdcxnb(99,$out_table_ranks)) ;

    for (my $m = $MonthlyStatsWpStop {$wp} ; $m >= $MonthlyStatsWpStart {$wp} ; $m--)
    {
      next if $m % 3 != 1 ;

      if ($m == $MonthlyStatsWpStop {$wp})
      { $line_html = &tdrb (&GetDateShort($MonthlyStatsWpDate {$wp}, $false)) ; }
      else
      {  $line_html = &tdrb (&GetDateShort2 ($m)) ; }

      $add_line = $false ;
      # do not rank # redirects, reuse column for project count in that month
      for ($f = 0 ; $f <= $fmax  - 1; $f++)
      {
        if (($mode_wp) ||
            (($f != 5) && ($f != 9) && ($f != 10)))
        {
          $line_html .= &tdrb ($MonthlyStatsRank {$wp.$m.$c[$f]}) ;
          if ($MonthlyStatsRank {$wp.$m.$c[$f]} ne "")
          { $add_line = $true ; }
        }
      }
      $line_html .= &tdrb ($MonthlyStatsProjects {$m}) ;

      if ($add_line)
      { $out_html .= &tr ($line_html) ; }
    }

    $out_html .= $header1c ;
    $out_html .= $header2 ;
  }

  if ($mode_wp)
  {
    my $html = &tdeb .
               &tdc4b (&b($out_tbl3_hdr1a)) .
               &tdc7b (&b($out_tbl3_hdr1e)) .
               &tdc3b (&b($out_tbl3_hdr1l)) .
               &tdc5b (&b($out_tbl3_hdr1o)) ;
    # if ($wikimedia)
    # { $html .= &tdc2b (&b($out_tbl3_hdr1t)) ; }
    $out_html .= &trh ($html) ;
  }

  if (! $mode_wp)
  {
    $out_html .= &trh (&tdeb .
                 &tdc4b (&b($out_tbl3_hdr1a)) .
                 &tdc4b (&b($out_tbl3_hdr1e)) .
                 &tdc3b (&b($out_tbl3_hdr1l)) .
                 &tdc5b (&b($out_tbl3_hdr1o))) ;
               # &tdc2b (&b($out_tbl3_hdr1t))) ;
  }

  $out_html .= "</table>\n" ;

  if (($wp !~ /^zzz?/) && ($wp !~ /^commons/) && (($imagecodes {$wp} !~ /(?:^|\|)IMAGE(?:$|\|)/i) || ($imagecodes {$wp} !~ /(?:^|\|)FILE(?:$|\|)/i)))
  {
    $out_html .= "<p><font color=#800000>Counts for image links are based on keyword(s) found in the message file for this language: " . unicode_to_html($imagecodes {$wp}) . ".<br>" .
                 "Note that image links based on default keyword 'Image' and/or 'File' have been missed. This will be repaired on the next run.</font><p>" ;
  }
  elsif (($wp =~ /^zzz?/) && (($imagecodes {"de"} !~ /(?:^|\|)IMAGE(?:$|\|)/i) || ($imagecodes {"de"} !~ /(?:^|\|)FILE(?:$|\|)/i)))
  {
    $out_html .= "<p><font color=#800000>Counts for image links are based on keyword(s) found in the message file for every language.<br>" .
                 "Note that image links based on default keyword 'Image' and/or 'File' have been missed. This will be repaired on the next run.</font><p>" ;
  }

  &TableMonthlyStatsLegend ($wp) ;
}

sub TableMonthlyStatsTrends
{
  my $wp = shift ;

  $imagelinks_incomplete = $false ;
  if ((($wp !~ /^zzz?/) && ($imagecodes {$wp}  !~ /(?:^|\|)IMAGE(?:$|\|)/i)) ||
      (($wp =~ /^zzz?/) && ($imagecodes {"de"} !~ /(?:^|\|)IMAGE(?:$|\|)/i)))
  { $imagelinks_incomplete = $true ; }
  if ((($wp !~ /^zzz?/) && ($imagecodes {$wp}  !~ /(?:^|\|)FILE(?:$|\|)/i)) ||
      (($wp =~ /^zzz?/) && ($imagecodes {"de"} !~ /(?:^|\|)FILE(?:$|\|)/i)))
  { $imagelinks_incomplete = $true ; }

  my $linesallzero = $true ;
  my $out_html_len = length ($out_html) ;

  if ($javascript)
  {
    $out_html .= "\n<script language='javascript'>\n" .
                 "trc('#ffdead');\n" .
                 "<\/script>\n" ;
  }
  else
  { $out_html .= "<tr bgcolor='#ffdead'>" ; }

  $out_html .= "<td colspan=333 class=cb>" .
               "<a name='growth' id='growth'></a><img src='../black.gif' height='1' alt=''></td></tr>" ;

  my $m2 = $dumpmonth_ord ;
  if ((! $show_forecasts) && $dumpmonth_incomplete)
  { $m2 -- ; }
  my $m1 = $m2 - 5 ;
  for (my $m = $m2 ; $m >= $m1 ; $m--)
  {
    if (($m == $dumpmonth_ord) && $dumpmonth_incomplete && $show_forecasts)
    {
      $prefix = "<font color='#606060'>&plusmn;<\/font>&nbsp;" ;
      $line_html = &tdrb (&GetDateShort (sprintf ("%02d/%02d/%04d", $dumpmonth, days_in_month ($dumpyear, $dumpmonth), $dumpyear))) ;
    }
    else
    {
      $prefix = "" ;
      $line_html = &tdrb (&GetDateShort2 ($m)) ;
    }

    $lineallzero = $true ;
    for ($f = 0 ; $f <= $fmax ; $f++)
    {
      if (($mode_wp) ||
          (($f != 5) && ($f != 9) && ($f != 10)))
      {
        if (($f == 0) || ($f == 2) || ($f == 3) || (($f >= 4) && ($f <= 6)) || ($f >= 11))
        {
          $value = $MonthlyStats {$wp.$m.$c[$f].'p'} ;
          if ((defined ($value)) && ($value != 0))
          {
            $lineallzero  = $false ;
            $linesallzero = $false ;
            $value = $prefix . $value ;
          }

          if (($f == 16) && $imagelinks_incomplete)
          { $value = "($value)" ; }
          $line_html .= &tdrb  (&sign ($value)) ;
        }
        else
        { $line_html .= &tdeb ; }
      }
    }

    if (! $lineallzero)
    { $out_html .= &tr ($line_html) ; }
  }

#  if ($linesallzero)
#  { $out_html = substr ($out_html, 0, $out_html_len) ; }

  $line_html = "" ;
  if ($mode_wp)
  {
    for ($f = 0 ; $f <= $fmax ; $f++)
    {
      $char = $c[$f] ;
    # $line_html .= &tdcxb ("<a href='\#$char'>$char</a>") ;
      $line_html .= &tdcxb ($char) ;
    }
  }

  if (! $mode_wp)
  {
    for ($f = 0 ; $f <= $fmax - 3 ; $f++)
    {
      $char = $c[$f] ;
    # $line_html .= &tdcxb ("<a href='\#$char'>$char</a>") ;
      $line_html .= &tdcxb ($char) ;
    }
  }

  $out_html .= &trh2 (&tdeb . $line_html) ;

# $out_html .= &trh (&tde .
#              &tdc4 (&b($out_tbl3_hdr1a)) .
#              &tdc7 (&b($out_tbl3_hdr1e)) .
#              &tdc3 (&b($out_tbl3_hdr1l)) .
#              &tdc5 (&b($out_tbl3_hdr1o)) .
#              &tdc2 (&b($out_tbl3_hdr1t))) ;
}

sub TableMonthlyStatsLegend
{
  my $wp = shift ;

  if (($mode_wp) && ($MonthlyStatsWpStart {$wp} < ord (&yyyymm2b (2001,7)))) # (2001,7) is a guess
  { $out_html .= "<p>\n" . $out_history . "\n" ; }

  $out_html .= $out_colors_perc ;

  $char = 'A' ;
  $lines = 1 ;
  foreach $line (@out_tbl3_legend)
  {
     if (($mode_wp) ||
          (($lines != 6) && ($lines != 10) && ($lines != 11)))
     {
       # if (! $wikimedia && ($lines == 20)) { last ; }
       if ($lines == 20) { last ; }

       if ($lines ==  1) {$out_html .= "<p>" . &b($out_tbl3_hdr1a). " " . &w($out_tbl3_hdr1a2) ; }
       if ($lines ==  5) {$out_html .= "<p>" . &b($out_tbl3_hdr1e). " " . &w($out_tbl3_hdr1e2) ; }
       if ($lines == 12) {$out_html .= "<p>" . &b($out_tbl3_hdr1l) ; }
       if ($lines == 15) {$out_html .= "<p>" . &b($out_tbl3_hdr1o) ; }
       if ($mode_wp)
       { if ($lines == 20) {$out_html .= "<p>" . &b($out_tbl3_hdr1t) ; } }

       $line2= $line ;
       if (($lines == 6) && (($wp eq "ja") || ($wp eq "zh")))
       { $line2 =~ s/([^\#\d])200([^\;])/$1 . "50" . $2/e ; }

       if (($mode_wp) || ($char le "P"))
       { $out_html .= "<br><a id='$char' name='$char'></a>\n$char = $line2\n" ; }
       $char++ ;

     }
     if ($lines == $#out_tbl3_legend) { last ; }
     $lines++ ;
  }
}

sub TableMonthlyStatsForecast
{
  my $wp = shift ;

  $lineallzero = $true ;
  my $m = $dumpmonth_ord + 1 ;

  $cell_html = &tdrb (&GetDateShort (
                      sprintf ("%02d/%02d/%04d", $dumpmonth, days_in_month ($dumpyear, $dumpmonth), $dumpyear)
                      )) ;
  $line_html .= $cell_html ;

  for (my $f = 0 ; $f <= $fmax ; $f++)
  {
    if (($mode_wp) ||
        (($f != 5) && ($f != 9) && ($f != 10)))
    {
      my $forecast = $MonthlyStats {$wp.$m.$c[$f]} ;
      if ($forecast == 0)
      { $line_html .= &tdeb ; }
      else
      {
        $lineallzero = $false ;
        $line_html .= &tdrb ("&nbsp;<font color='#606060'>&plusmn;<\/font>&nbsp;" . &format($MonthlyStats {$wp.$m.$c[$f]},$c[$f])) ;
      }
    }
  }
  if (! $lineallzero)
  { $out_html .= &tr ($line_html) ; }
}

sub GenerateTableDistributionUsers
{
  # count user with over x edits
  # threshold starting with a 3 are 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10), etc
  @thresholds = (5,10,25,32,50,100,250,316,500,1000,2500,3162,5000,10000,25000,31623,50000,100000,250000,316228,500000,1000000,2500000,3162278,500000,10000000,25000000,31622777,5000000,100000000) ;
  my $wp = shift ;
  my %namespaces ;
  my %usertypes ;
  my %users ;
  my %threshold_max ;

  $namespaces {'A'} = "&nbsp;Articles&nbsp;" ;
  $namespaces {'T'} = "&nbsp;Talk&nbsp;" ;
  $namespaces {'O'} = "&nbsp;Other&nbsp;" ;
  $usertypes  {'R'} = "&nbsp;Users&nbsp;" ;
  $usertypes  {'B'} = "&nbsp;Bots&nbsp;" ;

# if ($wp =~ /^zzz?$/)
# { return ; }

  if ($wp =~ /^zzz?$/)
  { &ReadFileCsv ($file_csv_users_activity_spread) ; }
  else
  { &ReadFileCsv ($file_csv_users_activity_spread, $wp) ; }

  foreach $line (@csv)
  {
    chomp ($line) ;
    ($lang,$date,$usertype,$nscat,$count1,$count3,@counts) = split (',', $line) ;

    next if ! $mode_wx and $lang =~ /commons/i ; # occurs (still) also in wikipedia csv files (commons was on wikipedia input queue shortly, in start 2010, by error)

    $month = substr ($date,0,2) ;
    $year  = substr ($date,6,4) ;
    $m = &yyyymm2b ("$year$month") ;
    for ($c = 0 ; $c <= $#counts ; $c ++)
    { $users {$date} {$usertype} {$nscat} {$c} += $counts [$c] ; }

#    if ($m % 3 < 999) # do only for visible months
    {
      if ($#counts > $threshold_max {$usertype} {$nscat})
      { $threshold_max {$usertype} {$nscat} = $#counts ; }
    }
  }

  $out_header       = "Edit activity levels of registered users and bots per group of namespaces" ;
# $out_explanation  = "Namespaces: Articles = 0&nbsp;&nbsp;&nbsp;Talk = 1,3,5,7,9,..&nbsp;&nbsp;&nbsp;Other = 2,4,6,8,..<br>10, 10&radic;10, 100, 100&radic;10, 1000, 1000&radic;10,.. &rArr; 10, 32, 100, 316, 1000, 3162, .. ( 316 : 1000 ~ 10000 : 316 )" ;
  $out_explanation  = "Namespaces: Articles = 0&nbsp;&nbsp;&nbsp;Talk = 1,3,5,7,9,..&nbsp;&nbsp;&nbsp;Other = 2,4,6,8,.." ;

  $out_explanation2 = "Note: users that edit on more than one wiki are counted double." ;
  $out_html .= "<br><a id='activitylevels' name='activitylevels'>&nbsp;</a><hr><p>" .  blank_text_after ("15/10/2009", "<font color=#008000>". &b(ucfirst($out_new).": ") . "</font>") .
               "<b>$out_header</b><p>$out_explanation<p>"  ;

  if ($wikimedia && $mode_wp && ($wp =~ /^zzz?$/))
  { $out_html .= "$out_explanation2<p>" ; }

# debug: $out_html .= "<p>RA: ${threshold_max {'R'}{'A'}}, BA: ${threshold_max {'B'}{'A'}}, RT: ${threshold_max {'R'}{'T'}}, BT: ${threshold_max {'B'}{'T'}}, RO: ${threshold_max {'R'}{'O'}}, BO: ${threshold_max {'B'}{'O'}}" ;

  $out_html .= "<table border=1 cellspacing=0 id='table4' style='' summary='Size distribution'>\n" ;

  $file_csv = $file_csv_user_activity_trends ;
  $file_csv =~ s/\.csv/uc($wp).".csv"/e ;

  my ($line_csv, $line_csv1, $line_csv2, $line_csv3, @csv_users, @csv_users_head, $wiki, $lang) ;

  $lines_html_1 = "" ;
  $lines_html_2 = "" ;
  my $months = 0 ;

  if ($mode_wb) { $wiki = $out_wikibooks ; }
  if ($mode_wk) { $wiki = $out_wiktionaries ; }
  if ($mode_wn) { $wiki = $out_wikinews ; }
  if ($mode_wp) { $wiki = $out_wikipedias ; }
  if ($mode_wq) { $wiki = $out_wikiquotes ; }
  if ($mode_ws) { $wiki = $out_wikisources ; }
  if ($mode_wv) { $wiki = $out_wikiversity ; }
  if ($mode_wx) { $wiki = $out_wikispecial ; }
  $lang = $out_languages {$wp} ;
  $lang =~ s/\&nbsp\;/ /g ;

  push @csv_users_head, "$wiki - $lang - User Activity Trends\n" ;
  push @csv_users_head, "Articles = namespace 0 - Talk pages = namespaces 1 3 5 7 etc - Other pages = namespaces 2 4 6 8 etc\n" ;
# push @csv_users_head, "3  32  316  3162  31623 = square root 10 times largest lower power of 10 e.g. 316 : 1000 ~ 10000 : 316\n" ;

  $line_html1 = &thcb ("&nbsp;") ;
  $line_html2 = &thcb ("&nbsp;") ;
  $line_html3 = &thcb ("Edits &ge;") ;

  for ($n = 0 ; $n <= 2 ; $n++)
  {
    $nscat = substr ("ATO",$n,1) ; # article, talk, other
    $columns1 = 0 ;

    for ($u = 0 ; $u <= 1 ; $u++)
    {
      $usertype = substr ("RB",$u,1) ; # bot, registered (non bot) ; no stats for anonymous written here

      if (($wp =~ /^zzz?$/) && ($usertype eq "B")) # most bots run on many wikis so totals would be meaningless, through double counts
      { next ; }

      if ($line_csv3 ne "")
      {
        $line_csv1 .= "," ;
        $line_csv2 .= "," ;
        $line_csv3 .= "," ;
      }
      $line_csv3 .= "Date" ;

      if ($nscat    eq "A") { $line_csv1 .= "Articles" ; }
      if ($nscat    eq "T") { $line_csv1 .= "Talk pages" ; }
      if ($nscat    eq "O") { $line_csv1 .= "Other pages" ; }

      if ($usertype eq "R") { $line_csv2 .= "Reg. User" ; }
      if ($usertype eq "B") { $line_csv2 .= "Bot" ; }

      $columns2 = 0 ;
      for ($c = 0 ; $c <= $#thresholds ; $c++)
      {
        if (($c > 0) && ($c > $threshold_max {$usertype} {$nscat}))
        {
          last ;
        }
      # print "NSCAT $nscat US $usertype C $c TH ${thresholds [$c]} MAX ${threshold_max {$usertype} {$nscat}}\n" ;
      # if (($threshold_max {'R'} {$nscat} < $c) && ($threshold_max {'B'} {$nscat} < $c))
      # { last ; }

      # if ((($usertype eq 'R') && ($thresholds [$c] =~ /^(?:5|10|32|100|316|1000|3162|10000|31623|100000|316228|1000000|3162278|10000000|31622777|100000000)$/)) ||
        if ((($usertype eq 'R') && ($thresholds [$c] =~ /^(?:5|10|25|100|250|1000|2500|10000|25000|100000|250000|1000000|2500000|10000000|25000000|100000000)$/)) ||
            (($usertype eq 'B') && ($thresholds [$c] =~ /^(?:5|10|100|1000|10000|100000|1000000|10000000|100000000)$/)))
        {
        # $line_html .= &thcb ("${thresholds [$c]}:$nscat:$usertype") ;
          $columns1++ ;
          $columns2++ ;
          $line_html3 .= &thcnb ("&nbsp;".$thresholds [$c]."&nbsp;") ;
        }
        if ($thresholds [$c] !~ /^(?:1|3)$/)
        {
          $line_csv1 .= "," ;
          $line_csv2 .= "," ;
          $line_csv3 .= "," . $thresholds [$c] ;
        }
      }
      # $line_html3 .= &thcnb ("&nbsp;") ;
      # $line_html2 .= &thcxb ($columns2+1, &w ($usertypes {$usertype})) ;
      if ($columns2 == 0) { $columns2++ ; }
      $line_html2 .= &thcxb ($columns2, &w ($usertypes {$usertype})) ;
      $line_html2 .= &tdlbrx (999,'');
    }
    # $line_html1 .= &thcxb ($columns1+2, &w ($namespaces {$nscat})) ;

    if ($wp !~ /^zzz?$/)
    { $line_html1 .= &thcxb ($columns1+2, &w ($namespaces {$nscat})) ; }
    else
    { $line_html1 .= &thcxb ($columns1+1, &w ($namespaces {$nscat})) ; }
  }

  push @csv_users_head, "$line_csv1\n" ;
  push @csv_users_head, "$line_csv2\n" ;
  push @csv_users_head, "$line_csv3\n" ;

  $line_csv = "" ;

  $out_html .= &trhb ($line_html1) ;
  $out_html .= &trh2b ($line_html2) ;
  $out_html .= &trh2b ($line_html3) ;

  $months = 0 ;
  for (my $m = $m1 ; $m >= $MonthlyStatsWpStart {$wp} ; $m--)
  {
    if ($m == $MonthlyStatsWpStop {$wp})
    { $line_html = &tdrb (&GetDateShort($MonthlyStatsWpDate {$wp}, $false)) ; }
    else
    { $line_html = &tdrb (&GetDateShort2 ($m)) ; }
    $date = &m2mmddyyyy ($m) ;

    for ($n = 0 ; $n <= 2 ; $n++)
    {
      $nscat = substr ("ATO",$n,1) ; # article, talk, other

      for ($u = 0 ; $u <= 1 ; $u++)
      {
        $usertype = substr ("RB",$u,1) ; # bot, registered (non bot) ; no stats for anonymous written here

        if (($wp =~ /^zzz?$/) && ($usertype eq "B")) # most bots run on many wikis so totals would be meaningless, through double counts
        { next ; }

        if ($line_csv ne "")
        { $line_csv .= "," ; }
        $line_csv .= $date ;

        $linepart_csv  = "" ;
        $linepart_html = "" ;
        for ($c = 0 ; $c <= $#thresholds ; $c++)
        {
          if (($c > 0) && ($c > $threshold_max {$usertype} {$nscat}))
          { last ; }

        # if ((($usertype eq 'R') && ($thresholds [$c] =~ /^(?:5|10|32|100|316|1000|3162|10000|31623|100000|316228|1000000|3162278|10000000|31622777|100000000)$/)) ||
          if ((($usertype eq 'R') && ($thresholds [$c] =~ /^(?:5|10|25|100|250|1000|2500|10000|25000|100000|250000|1000000|2500000|10000000|25000000|100000000)$/)) ||
              (($usertype eq 'B') && ($thresholds [$c] =~ /^(?:5|10|100|1000|10000|100000|1000000|10000000|100000000)$/)))
          {
         # $count_R = $users {$date} {'R'} {$nscat} {$c} ;
         #  $count_B = $users {$date} {'B'} {$nscat} {$c} ;
         #  $line_html .= &tdrb ($count_R) ;
         # $line_html .= &tdlb ($count_B) ;
            $count = $users {$date} {$usertype} {$nscat} {$c} ;
            $linepart_html .= &tdrb ($count) ;
          }
          if ($thresholds [$c] !~ /^(?:1|3)$/)
          {
            $count = $users {$date} {$usertype} {$nscat} {$c} ;
            $linepart_csv .= ",$count" ;
          }
        # $line_html .= &tdcb("<img src=../black.gif width=2 height=10>") ;
        }
        if ($linepart_csv eq "")
        { $linepart_csv  = "," ; }
        if ($linepart_html eq "")
        { $linepart_html = &tdrb ("&nbsp;") ; }
        $line_csv  .= $linepart_csv ;
        $line_html .= $linepart_html ;
      }
    }

    push @csv_users, "$line_csv\n" ;
    $line_csv = "" ;

    if ($show_all_months)
    { $lines_html_1 .= &tr ($line_html) ; }
    else
    {
      if ($months++ < 12)
      { $lines_html_1 .= &tr ($line_html) ; }

      next if $m % 3 != 1 ;

      $lines_html_2 .= &tr ($line_html) ;
    }
  }

  if ($langcode eq "EN")
  {
    open (FILE_CSV_USERS, ">", $file_csv) ;
    @csv_users = reverse @csv_users ;
    print FILE_CSV_USERS @csv_users_head ;
    print FILE_CSV_USERS @csv_users ;
    close FILE_CSV_USERS ;
  }

  $out_html .= $lines_html_1 ;
  if (! $show_all_months)
  {
    $out_html .= "<tr bgcolor=#ffdead><td colspan=333 class=lb><img src='../black.gif' width='1' height='4' alt=''></td></tr>" ;
    $out_html .= $lines_html_2 ;
  }
  $out_html .= "</table>\n" ;
}

sub GenerateTableDistributionActiveUsers
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  &ReadFileCsv ($file_csv_edit_distribution, $wp) ;

#  $out_htmlx .= "<br><a id='wikipedians' name='wikipedians'>&nbsp;</a><hr><p>" . &b($out_tbl1_intro) ;
#  if (defined ($out_tbl1_intro2))
#  { $out_html .= "<br><small>" . $out_tbl1_hdr9 . ": " . $out_tbl1_intro2 . "</small>" ; }
#  if (defined ($out_tbl1_intro3))
#  { $out_html .= "<br><small>" . $out_tbl1_intro3 . "</small>" ; }

  $out_html .= "\n\n<br><a id='editdistribution' name='editdistribution'>&nbsp;</a><hr><p>" . &b($out_tbl8_intro) . "<br><small>$out_tbl1_intro2</small>" ;
  $out_html .= "<p>1 : 3 : 10 : 32 : 100 : 316 : 1000 ... = 1 : &radic;10 : 10 : 10&radic;10 : 100 : 100&radic;10 : 1000 ... " ;
  $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table8' style='' summary='Distribution active users'>\n" ;

  $out_tbl8_hdr1 = $out_tbl1_hdr2 . " &gt;=" ; # "Edits"
  $out_tbl8_hdr2 = ucfirst ($out_publishers) ; # "Wikipedians" / "Wiktionarians" etc
  $out_tbl8_hdr3 = "$out_tbl1_hdr2 $out_tbl1_hdr7" ; # "Edits total"

  $out_html .= &trh (&tdcb     (&b($out_tbl8_hdr1)) .
                     &tdc2b    (&b($out_tbl8_hdr2)) .
                     &tdc2b    (&b($out_tbl8_hdr3))) ;

  foreach $line (sort {$a <=> $b} @csv)
  {
    my ($lang,$index,$edits_min,$users,$users_perc,$edits,$edits_perc) = split (',', $line) ;

    if ($users == 0) { last ; }

    $out_html .= &tr (&tdrb (sprintf ("%.0f", $edits_min)).
                      &tdrb ($users).
                      &tdrb ($users_perc) .
                      &tdrb ($edits).
                      &tdrb ($edits_perc)) ;
  }
  $out_html .= "</table>\n" ;
}

sub GenerateTableDistributionActiveUsers_OldObsoleteRemove
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

#===============================================================================================
  &ReadFileCsv ($file_csv_users, $wp) ;

  if ($#csv < 100)
  { return ; }

  my $sqrt10 = sqrt (10) ;
  my $bins = 15 ;
  my $users_tot = 0 ;
  my $edits_tot = 0 ;
# my (%edits_min, %edits, %users) ;
  my (@edits_min, @edits, @users) ;
  $j = 1 ;
  for ($i = 0 ; $i < $bins ; $i++)
# { $edits_min {$i} = $j - 0.01 ; $j *= $sqrt10 ; }
  { $edits_min [$i] = $j - 0.01 ; $j *= $sqrt10 ; }

  foreach $line (@csv)
  {
    my ($language, $edits_namespace_a) = split (',', $line) ;
    $users_tot ++ ;
    $edits_tot += $edits_namespace_a ;

    for ($i = 0 ; $i < $bins ; $i++)
    {
#     if ($edits_min {$i} <= $edits_namespace_a)
      if ($edits_min [$i] <= $edits_namespace_a)
      {
#       $users {$i} ++ ;
        $users [$i] ++ ;
#       $edits {$i} += $edits_namespace_a ;
        $edits [$i] += $edits_namespace_a ;
      }
    }
  }

#===============================================================================================

#  $out_htmlx .= "<br><a id='wikipedians' name='wikipedians'>&nbsp;</a><hr><p>" . &b($out_tbl1_intro) ;
#  if (defined ($out_tbl1_intro2))
#  { $out_html .= "<br><small>" . $out_tbl1_hdr9 . ": " . $out_tbl1_intro2 . "</small>" ; }
#  if (defined ($out_tbl1_intro3))
#  { $out_html .= "<br><small>" . $out_tbl1_intro3 . "</small>" ; }

  $out_html .= "\n\n<br><a id='editdistribution' name='editdistribution'>&nbsp;</a><hr><p>" . &b($out_tbl8_intro) . "<br><small>$out_tbl1_intro2</small>" ;
  $out_html .= "<p>1 : 3 : 10 : 32 : 100 : 316 : 1000 ... = 1 : &radic;10 : 10 : 10&radic;10 : 100 : 100&radic;10 : 1000 ... " ;
  $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table8' style='' summary='Distribution active users'>\n" ;

  $out_tbl8_hdr1 = $out_tbl1_hdr2 . " &gt;=" ; # "Edits"
  $out_tbl8_hdr2 = ucfirst ($out_publishers) ; # "Wikipedians" / "Wiktionarians" etc
  $out_tbl8_hdr3 = "$out_tbl1_hdr2 $out_tbl1_hdr7" ; # "Edits total"

  $out_html .= &trh (&tdcb     (&b($out_tbl8_hdr1)) .
                     &tdc2b    (&b($out_tbl8_hdr2)) .
                     &tdc2b    (&b($out_tbl8_hdr3))) ;

  for ($i = 0 ; $i < $bins ; $i++)
  {
#   if (@users {$i} == 0) { last ; }
    if ($users [$i] == 0) { last ; }

#    $out_html .= &tr (&tdrb (sprintf ("%.0f", $edits_min {$i})).
    $out_html .= &tr (&tdrb (sprintf ("%.0f", $edits_min [$i])).
#                     &tdrb ($users {$i}).
                      &tdrb ($users [$i]).
#                     &tdrb (sprintf ("%.1f\%", 100 * ($users {$i} / $users_tot))) .
                      &tdrb (sprintf ("%.1f\%", 100 * ($users [$i] / $users_tot))) .
#                     &tdrb ($edits {$i}).
                      &tdrb ($edits [$i]).
#                     &tdrb (sprintf ("%.1f\%", 100 * ($edits {$i} / $edits_tot)))) ;
                      &tdrb (sprintf ("%.1f\%", 100 * ($edits [$i] / $edits_tot)))) ;
  }
  $out_html .= "</table>\n" ;

}

sub GenerateTableMostActiveUsers
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  &ReadFileCsv ($file_csv_active_users, $wp) ;

  if ($#csv < 0) { return ; }
  my @fields = split (",", $csv [0]) ;
  if ($#fields < 9) { return ; } # old format, without other namespace counts

  $out_html .= "<br><a id='wikipedians' name='wikipedians'>&nbsp;</a><hr><p>" . &b($out_tbl1_intro) ;
  if (defined ($out_tbl1_intro2))
  { $out_html .= "<br><small>" . $out_tbl1_hdr9 . ": " . $out_tbl1_intro2 . "</small>" ; }
  if (defined ($out_tbl1_intro3))
  { $out_html .= "<br><small>" . $out_tbl1_intro3 . "</small>" ; }

  $out_html .= blank_text_after ("15/06/2009", "<small><b><p><font color=#800000>Note May 21, 2009: some names have nog been recognized as bot names on last run and may be listed here. Will be fixed on next run.</font></b></small>") ;

  $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table2' style='' summary='Most active users'>\n" ;
  $out_html .= &trh (
               &tdlr2b   (&b($out_tbl1_hdr1)) .
               &tdc6b    (&b(&w($out_tbl1_hdr2))) .
               &tdcr2b   (&b(&w($out_tbl1_hdr3)))) ;
  $out_html .= &trh (
               &tdc4b    (&b(&w($out_tbl1_hdr12))) .
               &tdc2b    (&b(&w($out_tbl1_hdr13)))) ;
  $out_html .= &trh2b    (
               &tdltr2b  ("&nbsp;") .
               &tdc2b    ($out_tbl1_hdr9) .
               &tdctr2b  ($out_tbl1_hdr8) .
               &tdctr2b  ($out_tbl1_hdr7) .
               &tdctr2b  ($out_tbl1_hdr7) .
               &tdctr2b  ($out_tbl1_hdr8) .
               &tdctr2b  ($out_tbl1_hdr5) .
               &tdctr2b  ($out_tbl1_hdr6)) ;
  $out_html .= &trh2(
               &tdctb    ($out_tbl1_hdr10) .
               &tdctb    ($out_tbl1_hdr11)) ;

  $active_users  = 0 ;
  $recently_active_users = 0 ;

  $userpage = $out_userpages {$wp} ;
  if (! defined ($userpage))
  { $userpage = "user" ; }
  $url = $out_urls {$wp} . $out_wikipage . $userpage ;

  foreach $line (@csv)
  {
    my ($dummy, $user,
        $edits_0, $edits_recent_0, $edits_x, $edits_recent_x,
        $rank_now, $rank_prev, $first, $days) = split (",", $line) ;
    $user =~ s/ /_/g ;

    my $delta = "" ;
    if ($edits_0 == $edits_recent_0)
    { $delta = "..." ; }
    else
    {
      $delta = $rank_prev - $rank_now ;
      if ($delta == 0)
      { $delta = "&nbsp;0" ; }
      elsif ($delta > 0)
      { $delta = '+' . $delta ; }
    }
    $active_users ++ ;
    $recently_active_users ++ ;

    $out_html .= &tr (&tdlb ("<a href='$url:$user'>$user</a>").
                      &tdrb ($rank_now).
                      &tdrb ($delta).
                      &tdrb ($edits_recent_0).
                      &tdrb ($edits_0).
                      &tdrb ($edits_x).
                      &tdrb ($edits_recent_x).
                      &tdrb (&w(&GetDateShort ($first,$true))).
                      &tdrb ($days)) ;
  }
  $out_html .= "</table>\n" ;
  $out_html =~ s/\[\[1\]\]/$active_users/ ;
  $out_html =~ s/\[\[2\]\]/$recently_active_users/ ;
}

sub GenerateTableMostActiveBots
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  if (! -e $file_csv_bot_edits) { return ; }

  &ReadFileCsv ($file_csv_bot_edits, $wp) ;

  if ($#csv < 0)    { return ; }
  my @fields = split (",", $csv [0]) ;
  if ($#fields < 9) { return ; } # old format, without other namespaces

  $out_html .= "<br><a id='bots' name='bots'>&nbsp;</a>&nbsp;<hr><p>" . &b($out_tbl10_intro) ;

  if (defined ($out_tbl1_intro2))
  { $out_html .= "<br><small>" . $out_tbl1_intro2 . "</small>" ; }
  $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table3' style='' summary='Sleeping users'>\n" ;
  $out_html .= &trh (&tdlb (&b($out_tbl1_hdr1)) .
               &tdc2b (&b(&w($out_tbl1_hdr2))) .
               &tdc2b (&b(&w($out_tbl1_hdr3))) .
               &tdc2b (&b(&w($out_tbl1_hdr4)))) ;
  $out_html .= &trh2(&tdeb .
               &tdcb  ($out_tbl1_hdr9) .
               &tdcb  ($out_tbl1_hdr7) .
               &tdcb  ($out_tbl1_hdr5) .
               &tdcb  ($out_tbl1_hdr6) .
               &tdcb  ($out_tbl1_hdr5) .
               &tdcb  ($out_tbl1_hdr6)) ;

  my $bots = 0 ;

  $userpage = $out_userpages {$wp} ;
  if (! defined ($userpage))
  { $userpage = "user" ; }
  $url = $out_urls {$wp} . $out_wikipage . $userpage ;

  foreach $line (@csv)
  {
    my ($dummy, $user, $edits_0, $edits_x, $rank_now, $rank_prev,
        $first, $days_first, $last, $days_last) = split (",", $line) ;
    $user =~ s/ /_/g ;

    $bots ++ ;

    $out_html .= &tr (&tdlb ("<a href='$url:$user'>$user</a>").
                      &tdrb ($rank_now).
                      &tdrb ($edits_0).
                      &tdrb (&w(&GetDateShort ($first,$true))).
                      &tdrb ($days_first).
                      &tdrb (&w(&GetDateShort ($last,$true))).
                      &tdrb ($days_last)) ;
    if ($bots >= 50) { last ; }
  }
  $out_html .= "</table>\n" ;
  $out_html =~ s/\[\[3\]\]/$bots/ ;
  if ($out_tbl1_footer !~ /^\s*$/)
  { $out_html .= "<br><small>" . $out_tbl1_footer . "</small>" ; }
}

sub GenerateTableSleepingUsers
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  &ReadFileCsv ($file_csv_sleeping_users, $wp) ;

  if ($#csv < 0) { return ; }
  my @fields = split (",", $csv [0]) ;
  if ($#fields < 9) { return ; } # old format, without other namespaces

  $out_html .= "<br><a id='sleeping' name='sleeping'>&nbsp;</a><hr><p>" . &b($out_tbl2_intro) ;

  if (defined ($out_tbl1_intro2))
  { $out_html .= "<br><small>" . $out_tbl1_intro2 . "</small>" ; }
  $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table3' style='' summary='Sleeping users'>\n" ;
  $out_html .= &trh (&tdlb (&b($out_tbl1_hdr1)) .
               &tdc2b (&b(&w($out_tbl1_hdr2))) .
               &tdc2b (&b(&w($out_tbl1_hdr3))) .
               &tdc2b (&b(&w($out_tbl1_hdr4)))) ;
  $out_html .= &trh2(&tdeb .
               &tdcb  ($out_tbl1_hdr9) .
               &tdcb  ($out_tbl1_hdr7) .
               &tdcb  ($out_tbl1_hdr5) .
               &tdcb  ($out_tbl1_hdr6) .
               &tdcb  ($out_tbl1_hdr5) .
               &tdcb  ($out_tbl1_hdr6)) ;

  $memorable_absent_users = 0 ;

  $userpage = $out_userpages {$wp} ;
  if (! defined ($userpage))
  { $userpage = "user" ; }
  $url = $out_urls {$wp} . $out_wikipage . $userpage ;

  foreach $line (@csv)
  {
    my ($dummy, $user, $edits_0, $edits_x, $rank_now, $rank_prev,
        $first, $days_first, $last, $days_last) = split (",", $line) ;
    $user =~ s/ /_/g ;

    $memorable_absent_users ++ ;

    $out_html .= &tr (&tdlb ("<a href='$url:$user'>$user</a>").
                      &tdrb ($rank_now).
                      &tdrb ($edits_0).
                      &tdrb (&w(&GetDateShort ($first,$true))).
                      &tdrb ($days_first).
                      &tdrb (&w(&GetDateShort ($last,$true))).
                      &tdrb ($days_last)) ;
    if ($memorable_absent_users >= 20) { last ; }
  }
  $out_html .= "</table>\n" ;
  $out_html =~ s/\[\[3\]\]/$memorable_absent_users/ ;
  if ($out_tbl1_footer !~ /^\s*$/)
  { $out_html .= "<br><small>" . $out_tbl1_footer . "</small>" ; }
}

sub GenerateTableAnonymousUsers
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }


  &ReadFileCsv ($file_csv_anonymous_users, $wp) ;
  if ($#csv < 0) { return ; }

  if ($#csv > 0) # if ((! $mode_wp) || (wp ne "en"))
  {
    $out_html .= "<br><a id='anonymous' name='anonymous'>&nbsp;</a><hr><p>" . &b($out_tbl6_intro) ;

    if (defined ($out_tbl1_intro2))
    { $out_html .= "<br><small>" . $out_tbl1_intro2 . "</small>" ; }

    $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table6' style='' summary='Anonymous users'>\n" ;
    $out_html .= &trh (&tdlb (&b($out_tbl1_hdr1)) .
                       &tdcb (&b(&w($out_tbl1_hdr2))))  ;

    my $ip_users = 0 ;
    foreach $line (@csv)
    {
      $line =~ s/\&\#44;/,/g ; # temp : fix bug where all commas were replaced by &#42;
      my ($dummy, $edits_0, $edits_x, $user) = split (",", $line) ;
      $user =~ s/ /_/g ;

      $out_html .= &tr (&tdlb ($user).
                        &tdrb ($edits_0))  ;
      if (++$ip_users >= 10) { last ; }
    }
    $out_html .= "</table>\n" ;
  }
  else
  {
    $out_html .= "<br><a id='anonymous' name='anonymous'>&nbsp;</a><hr><p>" . &b("Anonymous users") .
                 "<p>No detailed statistics for anonymous users are available for this wiki (performance reasons)" ;
  }

  if ($edits_total > 0)
  {
    $perc_edits_ip = 100*($edits_total_ip/$edits_total) ;
    $out_table6_footer =~ s/\%d/\%s/g ; # change to string fromatting

    if ($edits_total_ip > 1000000)
    {
      $edits_total_ip    =~ s/(\d\d\d)(\d\d\d)$/$out_thousands_separator$1$out_thousands_separator$2/ ;
      $edits_total       =~ s/(\d\d\d)(\d\d\d)$/$out_thousands_separator$1$out_thousands_separator$2/ ;
    }
    elsif ($edits_total_ip > 1000)
    {
      $edits_total_ip    =~ s/(\d\d\d)$/$out_thousands_separator$1/ ;
      $edits_total       =~ s/(\d\d\d)$/$out_thousands_separator$1/ ;
    }
    $out_table6_footer2 = sprintf ($out_table6_footer, $edits_total_ip, $edits_total, $perc_edits_ip) ;

    $out_html .= "<p>$out_table6_footer2" ;
  }
  $out_html =~ s/\[\[4\]\]/$ip_users/ ;
}

sub GenerateTableSizeDistribution
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  &ReadFileCsv ($file_csv_size_distribution, $wp) ;

  $out_tbl4_intro = $out_tbl3_legend [5] ;
  $out_tbl4_intro =~ s/([^\#\d])200([^\;])/$1 . "\.\." . $2/e ;
  $out_tbl4_intro =~ s/\(.*$// ;
  $out_tbl4_intro =~ s/\&nbsp\;//g ;
  $out_tbl4_intro =~ s/\([^\)]*\)$// ;
  $out_tbl4_intro .= "&nbsp;" . $out_tbl3_hdr1e2 ;

  $out_html .= "<br><a id='distribution' name='distribution'>&nbsp;</a><hr><p>" . &b($out_tbl4_intro) . "<p>"  ;

  $out_html .= "<table border=1 cellspacing=0 id='table4' style='' summary='Size distribution'>\n" ;
  $out_html .= &trh (&tdcb   (&b($out_date)) .
                     &tdc12b (&b($out_tbl3_hdr1e))) ;

  $line_html = &tdeb("&nbsp;") ;

  my $ch = "ch" ;
  my $chK = "k ch" ;
  for ($s=32, $i = 0 ; $i <= 11 ; $s *= 2 , $i++)
  {
    # actually should be chars instead of bytes in column sheaders
    if ($s < 1024)
    # { $line_html .= &tdrb ("&lt;&nbsp;". $s . "&nbsp;$out_bytes") ; }
    { $line_html .= &tdrb ("&lt;&nbsp;". $s . "&nbsp;$ch") ; }
    else
    # { $line_html .= &tdrb ("&lt;&nbsp;".sprintf ("%.0f", $s/1024) . "&nbsp;$out_kilobytes") ; }
    { $line_html .= &tdrb ("&lt;&nbsp;".sprintf ("%.0f", $s/1024) . "&nbsp;$chK") ; }
  }
  $out_html .= &trh2 ($line_html) ;

  $lines_html_1 = "" ;
  $lines_html_2 = "" ;
  my $months = 0 ;

  @csv = reverse @csv ;
  foreach $line (@csv)
  {
    my ($dummy, $date, @perc) = split (",", $line) ;
    my $month = substr ($date,0,2) ;

    $line_html = &tdrb (&GetDateShort($date,$false)) ;
    $perc_tot = 0 ;
    for ($i = 0 ; $i <= 11 ; $i++)
    {
      $perc_tot += $perc [$i] ;
      if ($perc_tot >= 100)
      { $perc_tot = 100 ; }
      $perc_tot_show = sprintf ("%.1f",$perc_tot) . "%" ;
      $perc_tot_show =~ s/\./$out_thousands_separator/g;
      $line_html .= &tdrb ($perc_tot_show) ;
    }

    if ($show_all_months)
    { $lines_html_1 .= &tr ($line_html) ; }
    else
    {
      if ($months++ < 6)
      { $lines_html_1 .= &tr ($line_html) ; }

      next if $m % 3 != 1 ;

      $lines_html_2 .= &tr ($line_html) ;
    }
  }
  $out_html .= $lines_html_1 ;
  if ($show_all_months)
  {
    $out_html .= "<tr bgcolor=#ffdead><td colspan=333 class=lb><img src='../black.gif' width='1' height='4' alt=''></td></tr>" ;
    $out_html .= $lines_html_2 ;
  }
  $out_html .= "</table>\n" ;
}

sub GenerateTableNamespaces
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  $out_tbl7_hdr_b = "Binaries" ;

  $f = 21 ; # would be have become new column V in table 1 = percentage categorized articles
            # instead show it here
            # because instead of adding column V, to keep columns grouped
            # it would have to be inserted between current columns K and L
            # and massive maintenance would be needed to shuffle column indexes

  &ReadFileCsv ($file_csv_binaries_stats, $wp) ;
  @csv2 = @csv ;
  my $show_binaries = ($#csv2 > -1) ;

  &ReadFileCsv ($file_csv_namespace_stats, $wp) ;

  $out_tbl7_intro2 = $out_tbl7_intro ;
  if ($show_binaries)
  { $out_tbl7_intro2 =~ s/(.*)<p>/$1 \/ Binaries (=namespace 6: images, sound files, etc)<p>/ ; }
  $out_html .= "<br><a id='namespaces' name='namespaces'>&nbsp;</a><hr><p>" . &b($out_tbl7_intro2) ;

  if (($wikimedia) && ($mode_wp))
  {
    $file_categories_all = "CategoryOverview_" . uc($wp) . "_Complete.htm" ;
    $file_categories_top = "CategoryOverview_" . uc($wp) . "_Concise.htm" ;
    $size_all = -s $path_out_categories . $file_categories_all ;
    $size_top = -s $path_out_categories . $file_categories_top ;

    if ($size_all > 0)
    {
      if ($size_all > 500 * 1024)
      {
        $out_size_all = " (" . i2KbMb ($size_all) . "!)" ;
        $out_size_top = " (" . i2KbMb ($size_top) . ")" ;
      }
      else
      {
        $out_size_all = "" ;
        $out_size_top = "" ;
      }

      $out_complete = "Complete" ;
      $out_concise  = "Concise" ;
      $line_html = "<p>See also Category Overview " ;
      $line_html .= "<a href='../EN/$file_categories_all'> " . $out_complete . "</a>" . $out_size_all;
      if ($size_top > 0)
      { $line_html .= ", <a href='../EN/$file_categories_top'> " . $out_concise . "</a>"  . $out_size_top ; }
      $out_html .= $line_html ;
    }
  }

  $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table7' style='' summary='Name spaces'>\n" ;
  $out_html .= &trh (&tdcb   (&b($out_date)) .
                     &tdc14b  (&b($out_tbl7_hdr_ns)) .
                     &tdcbr2 (&b($out_tbl7_hdr_ca)) .
                     ($show_binaries ? &tdc99b (&b($out_tbl7_hdr_b)) : "")) ;

  $line_html = &tdeb("&nbsp;") ;

  my $ns ;
  for ($ns=0 ; $ns <= 14 ; $ns+=2)
  { $line_html .= &tdrb (@out_namespaces [$ns/2]) ; }
  for ($ns=100 ; $ns <= 110 ; $ns+=2)
  {
    my $text = @out_namespaces [(($ns-100)/2)+9] ;
    if ($text eq "")
    { $text = "$ns" ; }
    $line_html .= &tdrb ($text) ;
  }

  # find extensions
  undef %ext_skip ;
  $line2 = $csv2 [0] ;
  $line_html_ext_skip = "" ;
  my ($dummy, $date, @exts) = split (",", $line2) ;
  $ext_ndx = 0 ;
  foreach $ext (@exts)
  {
    if ($ext !~ /^\w{1,4}$/)
    {
      $ext_skip {$ext_ndx} = $true ;
      $ext =~ s/\s/\&not;/g ;
      $line_html_ext_skip .= "\".".ucfirst ($ext)."\", "  ;
    }
    else
    { $line_html .= &tdrb (&w(ucfirst ($ext))) ; }
    $ext_ndx++ ;
  }
  $line_html_ext_skip =~ s/, $// ;
  if ($line_html_ext_skip =~ /\&not;/)
  { $line_html_ext_skip .= " (&not; = space)" ; }

  $out_html .= &trh2 ($line_html) ;

  $lines_html_1 = "" ;
  $lines_html_2 = "" ;
  my $months = 0 ;

  @csv = reverse @csv ;
  foreach $line (@csv)
  {
    my ($dummy,  $date,  @counts)  = split (",", $line) ;
    $line_html = &tdrb (&GetDateShort($date,$false)) ;
    my $namespace = 0 ; # remove namespace 16, not yet used
    foreach $count (@counts)
    {
      if (($namespace += 2) == 18) { next ; }
      $count = &format($count,'E') ;
      $count =~ s/M./M/ ;
      $count =~ s/K./K/ ;
      $count =~ s/k./k/ ;
      $line_html .= &tdrb ($count) ;
    }
    my $month = substr ($date,0,2) ;
    my $year  = substr ($date,6,4) ;
    my $m     = ord (&yyyymm2b ($year, $month)) ;
    if (($counts [7] > 0) && ($MonthlyStats {$wp.$m.$c[13]} > 0)) # any categories ? + word count > 0, if not ran WikiCounts -e (edits_only)
    { $line_html .= &tdrb ($MonthlyStats {$wp.$m.$c[$f]}) ; }
    else
    { $line_html .= &tdeb ; }

    if ($show_binaries)
    {
      $line = pop (@csv2) ;
      if ($line ne "")
      {
        ($dummy, $date, @counts) = split (",", $line) ;

        # $year  = substr ($date,3,4) ;
        # $month = substr ($date,0,2) ;
        # $day   = days_in_month ($year, $month) ;
        # $date = sprintf ("%02d/%02d/%04d",$month,$day,$year) ;
        # $line_html .= &tdrb (&GetDateShort("$date",$false)) ;
        $ext_ndx = 0 ;
        foreach $count (@counts)
        {
          if (! $ext_skip {$ext_ndx})
          {
            $count = &format($count,'E') ;
            $count =~ s/M./M/ ;
            $count =~ s/K./K/ ;
            $count =~ s/k./k/ ;
            $line_html .= &tdrb ($count) ;
          }
          $ext_ndx++ ;
        }
      }
      else
      {
        $ext_ndx = 0 ;
        foreach $ext (@exts)
        {
          if (! $ext_skip {$ext_ndx})
          { $line_html .= &tdeb ; }
          $ext_ndx++ ;
        }
      }
    }

    if ($show_all_months)
    { $lines_html_1 .= &tr ($line_html) ; }
    else
    {
      if ($months++ < 6)
      { $lines_html_1 .= &tr ($line_html) ; }

      next if $m % 3 != 1 ;

      $lines_html_2 .= &tr ($line_html) ;
    }
  }

  $out_html .= $lines_html_1 ;
  if (! $show_all_months)
  {
    $out_html .= "<tr bgcolor=#ffdead><td colspan=333 class=lb><img src='../black.gif' width='1' height='4' alt=''></td></tr>" ;
    $out_html .= $lines_html_2 ;
  }
  $out_html .= "</table>\n" ;

  if ($line_html_ext_skip ne "")
  { $out_html.= "<p>Binaries were not counted for the following (suspect) extension(s): $line_html_ext_skip\n" ; }
}

sub GenerateTableVisitorStats
{
  my $wp = shift ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  my $out_web_address = $out_urls{$wp} . "/stats/" ;
  $out_tbl5_intro2 = $out_tbl5_intro ;
  $out_tbl5_intro2 =~ s/\'\'/$out_web_address/ ;

  $out_html .= "<br><a id='visitors' name='visitors'>&nbsp;</a><hr><p>" . &b($out_tbl5_intro2) . "<p>"  ;
  $out_html .= "<table border=1 cellspacing=0 id='table5' style='' summary='Visitor stats'>\n" ;
  $out_html .= &trh (&tdcb   (&b($out_date)) .
                     &tdc4b (&b($out_tbl5_hdr1a)) .
                     &tdc6b (&b($out_tbl5_hdr1e))) ;
  $out_html .= &trh2(&tdeb .
                     &tdcb  ($out_tbl5_hdr2a) .
                     &tdcb  ($out_tbl5_hdr2b) .
                     &tdcb  ($out_tbl5_hdr2c) .
                     &tdcb  ($out_tbl5_hdr2d) .
                     &tdcb  ($out_tbl5_hdr2e) .
                     &tdcb  ($out_tbl5_hdr2f) .
                     &tdcb  ($out_tbl5_hdr2g) .
                     &tdcb  ($out_tbl5_hdr2h) .
                     &tdcb  ($out_tbl5_hdr2i) .
                     &tdcb  ($out_tbl5_hdr2j)) ;

  $line_html = &tdc("&nbsp;") ;

  my ($date, $year, $month, $lines) ;

  $lines = 0 ;
  foreach $line (@csv)
  {
    my ($dummy, $date, @fields) = split (",", $line) ;
    $year  = substr ($date,6,4) ;
    $month = substr ($date,0,2) ;
    $date = &GetDateShort($date,$false) ;
    if (++$lines >= $#csv - 11)
    { $date  = "<a href='" . $out_urls{$wp} . "/stats/usage_" . $year . $month .".html'>$date</a>" ; }
    $line_html  = &tdrb ($date) ;
    for ($f = 0 ; $f <= $#fields ; $f++)
    { $line_html .= &tdrb (&i2KM ($fields [$f])) ; }
    $out_html .= &tr ($line_html) ;
  }
  $out_html .= "</table>\n" ;

  if ((defined ($conversions)) && ($conversions != 0))
  { $out_html .= "<br>" . $out_conversions1 . $conversions . $out_conversions2 ; }
}

sub GenerateTableActiveUsers
{
  # add total (Sigma)
  # tell one name may mean different users on different Wp's
  # tell filter >= 25 edits on one Wikipedia
  # tell [..] means rank (if <= 100)
  # wp dependent links user, etc

  if ($wp =~ /^zzz?$/)
  { return ; }

  &ReadFileCsv ($file_csv_users) ;

  @csv = sort {&csvkey_name_edits ($a) cmp &csvkey_name_edits ($b)} @csv ;

  $file_html = $path_out . "TablesWikipediaUserActivity" . uc($wp) . ".htm" ;

  $out_html = "<html>\n<head>\n" .
              "<meta http-equiv='Content-type' content='text/html; charset=utf-8'>\n" .
              "</head>\n<body>\n" ;

  my $prev_name = "" ;
  my $line_html = "" ;
  foreach $line (@csv)
  {
    my ($language, $edits, $rank, $delta, $name) = split (",", $line) ;
    if (($name ne $prev_name) && ($prev_name ne ""))
    {
      if ($edits_25)
      { $out_html  .= $line_html . "\n" ; }

      $line_html = "<br><a href='" . $out_urls {$wp} . $out_wikipage . "user:$name'>$name</a> " ;
      $edits_25 = $false ;
      if ($edits >= 25)
      { $edits_25 = $true ; }
    }

    if ($line_html =~ /\s$/)
    { $line_html .= "$language: $edits" ; }
    else
    { $line_html .= ", $language: $edits" ; }
    if ($rank <= 100)
    { $line_html .= " [$rank]" ; }

    $prev_name = $name ;
  }
  $out_html  .= $line_html . "\n" ;

  $out_html .= "</table></body></html>\n" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  open "FILE_OUT", ">", $file_html || abort ("Output file " . $file_html . " could not be opened.") ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub GenerateTableEditsPerTable
{
  my $wp = shift ;
  my $file_html = $path_out . "TablesWikipediaArticleEdits" . uc($wp) . ".htm" ;

  my ($language, $edits, $edits_reg, $size, $users_reg, $users_ip, $title) ;

  if ($wp =~ /^zzz?$/)
  { return ; }

  my ($t0,$t1) ;
  if ($mode_wp) { $t0 = time ; }
  &ReadFileCsv ($file_csv_webalizer, $wp) ;
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableEditsPerTable 1"} += $t1 - $t0 ; $t0 = $t1 ; }

  $file_csv_edits_per_article2 = $file_csv_edits_per_article ;
  $file_csv_edits_per_article2 =~ s/\.csv/uc($wp).".csv"/e ;
  &ReadFileCsv ($file_csv_edits_per_article2, $wp, 5000) ;

  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableEditsPerTable 2"} += $t1 - $t0 ; $t0 = $t1 ; }
  if ($#csv < 0) { return ; }

  $out_html .= "<br><a id='mostedited' name='mostedited'>&nbsp;</a><hr><p>" . &b($out_tbl9_intro) ;

  if ($#csv >= 50)
  {
    $file_html = "TablesWikipediaArticleEdits" . uc($wp) . ".htm" ;
    $out_html .= "&nbsp;&nbsp;<a href='$file_html'>More..</a>" ;
  }

  $out_html .= "<br>&nbsp;<table border=1 cellspacing=0 id='table9' style='' summary='Edits per table'>\n" ;

  if ($registration_enforced)
  {
    $out_html .= &trh (&tdlb   (&b(&w($out_tbl1_hdr2))) .
                       &tdlb   (&b(&w($out_unique_users))).
                       &tdlb   (&b(&w($out_tbl1_hdr12))).
                       &tdlb   (&b(&w($out_archived))))  ;
  }
  else
  {
    $out_html .= &trh (&tdc2b  (&b(&w($out_tbl1_hdr2))) .
                       &tdc2b  (&b(&w($out_unique_users))).
                       &tdcbr2 (&b(&w($out_tbl1_hdr12))).
                       &tdcbr2 (&b(&w($out_archived))))  ;
    $out_html .= &trh (&tdcb   (&b(&w($out_total))) .
                       &tdcb   (&b(&w($out_reg))) .
                       &tdcb   (&b(&w($out_reg))) .
                       &tdcb   (&b(&w($out_unreg)))) ;
  }

  my $most_edited_articles = 0 ;
  foreach $line (@csv)
  {
    ($language, $edits, $edits_reg, $size, $users_reg, $users_ip, $title) = split (",", $line, 7) ;
    $edits_reg_perc = '-- ' ;

    if ($edits > 0)
    { $edits_reg_perc = sprintf ("%.0f", (100 * $edits_reg) / $edits) ; }

    if ($size < $Mb)
    { $size = "<font color=#AAAAAA>&lt; 1 $out_megabytes</font> &nbsp;" ; }
    else
    { $size = sprintf ("%.1f", $size / $Mb) . " $out_megabytes &nbsp;" ; }

    $url = $out_urls {$wp} . $out_wikipage . encode_url ($title) ;

    if ($registration_enforced)
    {
      $out_html .= &tr (&tdrb (&w ($edits)).
                        &tdrb (&w ($users_reg)).
                        &tdlb ("<a href='$url'>" . &EncodeHtml ($title) . "</a>") .
                        &tdrb ($size))  ;
    }
    else
    {
      $out_html .= &tr (&tdrb (&w ($edits)).
                        &tdcb ($edits_reg_perc . "%").
                        &tdrb (&w ($users_reg)).
                        &tdrb (&w ($users_ip)).
                        &tdlb ("<a href='$url'>" . &EncodeHtml ($title) . "</a>") .
                        &tdrb ($size))  ;
    }

    if (++$most_edited_articles >= 50) { last ; }
  }
  if ($mode_wp) { $t1 = time ; $TimesGenerateTables {"GenerateTableEditsPerTable 3"} += $t1 - $t0 ; $t0 = $t1 ; }

  $out_html .= "</table>\n" ;

  $out_html =~ s/\[\[5\]\]/$most_edited_articles/ ;

#-------------------------------------------------------------------------------

# if (($language eq "en") && ($#csv > 50))
  if ($#csv > 50)
  {
    $base = $out_urls {$wp} . encode_url ($out_wikipage) ;
    $out_html2 = "<html>\n<head>\n" .
                "<meta http-equiv='Content-type' content='text/html; charset=utf-8'>\n" .
                "<base href='$base'>\n" .
                "$out_script_expand2\n" .
                "</head>\n<body bgcolor='#FFFFDD'><small>\n" ;

    $file_html = $path_out . "TablesWikipediaArticleEdits" . uc($wp) . ".htm" ;

    my $prev_name = "" ;
    my $line_html = "" ;
    $out_html2 .= "Fields: ET - PR , RU - UU, T<br>" ;
    $out_html2 .= "ET=Edits total, PR=Perc. edits by registered users, RU=Contributing registered users UU=Contributing unregistered unique IP addresses, T=Title<br>" ;
    $out_html2 .= "Ad UU: This is not the same as unregistered persons: several people may use the same IP address, and one person may use many IP addresses<br>" ;
    my $linecnt = 0 ;
    $out_html2 .= "\n<script>\n" ;
    foreach $line (@csv)
    {
      if (++$linecnt > 5000)
      { last ; }
      ($language, $edits, $edits_reg, $size, $users_reg, $users_ip, $title) = split (",", $line, 7) ;
      $edits_reg_perc = '-- ' ;
      if ($edits > 0)
      { $edits_reg_perc = sprintf ("%.0f", (100 * $edits_reg) / $edits) ; }

      $url = encode_url ($title) ;
      $url =~ s/\:/%3A/g ; # otherwise html base does not work
      $title2 = &EncodeHtml ($title) ;
      if ($url eq $title2)
      { $url = '' ; }
      $out_html2 .= "e($edits,$edits_reg_perc,$users_reg,$users_ip,\"$url\",\"$title2\");\n" ;

      if ($linecnt % 100 == 0)
      { $out_html2 .= "</script>\n<script>\n" ; }
    }
    $out_html2 .= "</script>\n" ;
  #  $out_html2 .= "</table>\n" ;

    if (++$linecnt > 5000)
    { $out_html2 .= "<p>etc ... = " . ($linecnt-5000) . " lines skipped" ; }

    $out_html2 .= "</small></body></html>\n" ;

    $out_html2 =~ s/roa_rup/roa-rup/g ;
    $out_html2 =~ s/zh_min_nan/zh-min-nan/g ;
    $out_html2 =~ s/fiu_vro/fiu-vro/g ;

    if (defined ($dumpdate_hi))
    {
      $dumpdate2 = timegm (0,0,0,
                           substr ($dumpdate_hi,6,2),
                           substr ($dumpdate_hi,4,2)-1,
                           substr ($dumpdate_hi,0,4)-1900) ;
    }

    $path_scripts = "http://stats.wikimedia.org/scripts.zip" ;

    $out_html2 .= "<small><p>\n" .
                 $out_generated . &GetDate (time) . " " .
                 $out_sqlfiles  . &GetDate ($dumpdate2) . "\n<br>" .
                 (! $wikimedia ? "$out_no_wikimedia<br>" : "") .
                 $out_version . $version . "\n<br>" .
                 $out_author . ":" . $out_myname .
                 " (<a href='" . $out_mysite . "'>" . $out_site . "</a>)\n<br>" .
                 ($wikimedia ? $out_mail . ":" . $out_mymail . "<br>\n" : "") .
                 ($wikimedia ? $out_documentation . "<br>\n" : "" ) .
                 ($wikimedia ? $out_scripts . ": <a href='$path_scripts'>scripts.zip</a>\n" : "") .
                 $out_translator . "\n" .
                 $out_ploticus2 . "\n" .
                 ((! $wikimedia && $mail ne "") ? "<p>" .$siteadmin . "\n" . $mail . "\n" : "") .
                 $out_index_timelines . "\n<p>" .
                 ($wikimedia ? $out_license : "") .
                 "</small>\n" ;


    open "FILE_OUT", ">", $file_html || abort ("Output file " . $file_html . " could not be opened.") ;
    print FILE_OUT &AlignPerLanguage ($out_html2) ;
    close "FILE_OUT" ;
  }
#-------------------------------------------------------------------------------
#  @csv = sort {&csvkey_name_edits ($a) cmp &csvkey_name_edits ($b)} @csv ;
}

sub GenerateTableZeitGeist
{
  my $wp = shift ;

  my ($dummy, $month, $month_prev, $rank, $type, $users, $title) ;

  if ($wp =~ /^zzz?$/)
  { return ; }

my $start_zeitgeist0 = Time::HiRes::time() ;
my $start_zeitgeist1 = Time::HiRes::time() ;
  &ReadFileCsv ($file_csv_zeitgeist, $wp) ;
&RecordTime ("ZeitGeist1", $start_zeitgeist1) ;

  if ($#csv < 0) { return ; }

  $out_html .= "<br><a id='zeitgeist' name='zeitgeist'>&nbsp;</a><hr><p>" . &b("ZeitGeist") . "<p>" ;

  if ($wikimedia)
  {
  # $out_html .= "Separate stats may be added later for registered + anonymous editors, but some filtering will be needed: there is no one to one relationship between IP address and unique user.<br>" ;
    $out_html .= "For each month articles with most contributors in that month are shown.<br>" ;
    if ($wp eq "en")
    { $out_html .= "Sometimes an article has been renamed repeatedly. For this reason the English Wikipedia article 'October 2003' features as article with most editors for many months.<p>" ; }
    $out_html .= "<b>x</b> <sup>y</sup> z&nbsp;&nbsp;&nbsp;&nbsp;&lArr;&nbsp;&nbsp;&nbsp;&nbsp;" ;
    $out_html .= "x = rank, y = contributors in that month, z = article title<p>" ;
  }

  $month_prev = "" ;
  foreach $line (@csv)
  {
my $start_zeitgeist2 = Time::HiRes::time() ;
    ($dummy, $month, $rank, $type, $users, $title) = split (",", $line, 6) ;

    if ($type ne "REG") { next ; }
    $month = substr ($month,4,2) . "/99/" . substr ($month,0,4) ;
    $month = &GetDateShort ($month, $false) ;
&RecordTime ("ZeitGeist2", $start_zeitgeist2) ;
my $start_zeitgeist3 = Time::HiRes::time() ;
    if ($month ne $month_prev)
    { $out_html .= "<p><b>$month</b>: " ; }
    else
    { $out_html .= ", " ; }

    $url = $out_urls {$wp} . $out_wikipage . encode_url ($title) ;
#   $out_html .= "<b>".($rank+1) . "</b>&nbsp;$users&nbsp;" . $out_reg_users_edited . " <a href='$url'>" .
#                &EncodeHtml ($title) . "</a><br>\n" ;
    $out_html .= "<b>".($rank+1) . "</b> <sup>$users</sup> <a href='$url'>" . &EncodeHtml ($title) . "</a> \n" ;
&RecordTime ("ZeitGeist3", $start_zeitgeist3) ;
    $month_prev = $month ;
  }
&RecordTime ("ZeitGeist1", $start_zeitgeist0) ;
}

sub GenerateComparisonTables
{
  for ($f = 0 ; $f <= $fmax ; $f++)
  {
    # if ($f == 6) { next ; } # skip obsolete alternate article counts

    if (($mode_wp) ||
        (($f != 5) && ($f != 9) && ($f != 10)))
    {
      &GenerateComparisonTable ($f) ;

      $postfix = $report_names [$f] ;
      $file_csv = $path_in . $postfix . ".csv" ;
      open "FILE_OUT", ">", $file_csv ;
      print FILE_OUT $out_csv ;
      close "FILE_OUT" ;

      $file_html = $path_out . "Tables" . $postfix . ".htm" ;
      open "FILE_OUT", ">", $file_html ;
      print FILE_OUT &AlignPerLanguage ($out_html) ;
      close "FILE_OUT" ;
    }
  }
}

sub GenerateComparisonTable
{
  my $f = shift ;
  my $date = "" ;
  my $date_prev = "" ;
  my $language_ndx = 0 ;
  my $output = "date" ;
  my $out_xref ;

  $javascript_ = $javascript ;
  $javascript  = $true ;

  # reset to English values (no language support for consolidated reports)
  # $out_megabytes = "Mb" ;
  # $out_kilobytes = "Kb" ;

  $colormode = 'X' ;
  if (index ("AEFMNOPQRSTUV", $c[$f]) > -1) { $colormode = 'A' ; }
  if (index ("BG",            $c[$f]) > -1) { $colormode = 'B' ; }
  if (index ("L",             $c[$f]) > -1) { $colormode = 'H' ; } # was 'C'
  if (index ("JK",            $c[$f]) > -1) { $colormode = 'D' ; }
  if (index ("H",             $c[$f]) > -1) { $colormode = 'E' ; }
  if (index ("I",             $c[$f]) > -1) { $colormode = 'F' ; }
  if (index ("CD",            $c[$f]) > -1) { $colormode = 'G' ; }
  if ($pageviews)                           { $colormode = 'I' ; }

  &GenerateHtmlStartComparisonTables ($f) ;

  if ($pageviews_normal)
  {
    $mode_wp ? $root = ".." : $root = "../.." ;

    $out_xref = "<a href='$root/EN/TablesPageViewsMonthlyAllProjects.htm'>All projects, </a>\n" ;
    $mode_wb ? ($out_xref .= "Wikibooks, ")   : ($out_xref .= "<a href='$root/wikibooks/EN/TablesPageViewsMonthly.htm'>Wikibooks, </a>\n") ;
    $mode_wk ? ($out_xref .= "Wiktionary, ")  : ($out_xref .= "<a href='$root/wiktionary/EN/TablesPageViewsMonthly.htm'>Wiktionaries, </a>\n") ;
    $mode_wn ? ($out_xref .= "Wikinews, ")    : ($out_xref .= "<a href='$root/wikinews/EN/TablesPageViewsMonthly.htm'>Wikinews, </a>\n") ;
    $mode_wp ? ($out_xref .= "Wikipedia, ")   : ($out_xref .= "<a href='$root/EN/TablesPageViewsMonthly.htm'>Wikipedias, </a>\n") ;
    $mode_wq ? ($out_xref .= "Wikiquote, ")   : ($out_xref .= "<a href='$root/wikiquote/EN/TablesPageViewsMonthly.htm'>Wikiquotes, </a>\n") ;
    $mode_ws ? ($out_xref .= "Wikisource, ")  : ($out_xref .= "<a href='$root/wikisource/EN/TablesPageViewsMonthly.htm'>Wikisources, </a>\n") ;
    $mode_wv ? ($out_xref .= "Wikiversity, ") : ($out_xref .= "<a href='$root/wikiversity/EN/TablesPageViewsMonthly.htm'>Wikiversities, </a>\n") ;
    $mode_wx ? ($out_xref .= "Wikispecial")   : ($out_xref .= "<a href='$root/wikispecial/EN/TablesPageViewsMonthly.htm'>Wikispecial</a>\n") ;
  }

  if ($wikimedia && ($f <= 1) && $mode_wp)
  {
    $out_html .= blank_text_after ("15/08/2009", "<p><font color=#008000>". &b(ucfirst($out_new).": " .
                 "July 17, 2009: the method of counting contributors and new $out_publishers has changed. All wikis will be upgraded to this new scheme.<br>" .
                 "In the new scheme $out_publishers will only be included in contributors and new $out_publishers from the month in which they made their 10th edit, not the month in which they registered.<br>" .
                 "The English Wikipedia uses this new scheme, other wikis will follow in coming weeks.</font><p>")) ;
  }

  if ($pageviews)
  {
    $out_html .= "<b><font color=#A00000>Warning: page view counts from Nov 2009 till March 2010 are too low.</font></b> " .
                 "In July 2010 is was established that the server that collects and aggregates log data for all squids could not keep up with all incoming messages, and hence underreported page views. " .
                 "This issue has been resolved. For April - July 2010 the amount of underreporting could be inferred from still available log files and counts for these months have been corrected (read <a href='http://infodisiac.com/blog/wp-content/uploads/2010/07/assessment.pdf'>more</a>). For earlier months, possibly from Nov 2009 till March 2010 counts in the table below are too low.<p>" .
                 "<hr>" ;
    $out_html .= "<p><b>Legend:</b><br>$legend_pageviews_monthly<br>&nbsp;<hr>" ;

    if ($pageviews_mobile)
    {
      if ($region eq '')
      { $out_html .= "<p>$msg_perc_mobile" ; }
      $out_html .= "<h3>Page views per language per month (mobile site) <font color=#A0A0A0>(plus links to edit trends)</font>&nbsp;&nbsp;&nbsp;&nbsp;<span id='wait'><font color='#666600'>" . $out_rendering . "</font></span></h3>\n" ;
      $out_html .= "<p><b><font color=#008000>Mobile traffic only! </font></b>" ;
    }
    else
    {
      if ($region eq '')
      { $out_html .= "<p>$msg_perc_non_mobile" ; }
      $out_html .= "<h3>Page views per language per month <font color=#A0A0A0>(plus links to edit trends)</font>&nbsp;&nbsp;&nbsp;&nbsp;<span id='wait'><font color='#444400'>" . $out_rendering . "</font></span></h3>" ;
      $out_html .= "<p><b><font color=#008000>Non-mobile traffic only! </font></b>" ;
    }

    if ($normalize_days_per_month)
    { $out_html .= "<b><font color=#008000>View counts on this page have been normalized to months of 30 days, for fair comparison.</font></b>. " ; }
    else
    { $out_html .= "<b><font color=#800000>View counts on this page have <font color=#FF0000>not</font> been normalized to months of 30 days.</font></b>. " ; }

  # $out_html .= "<p><b><font color='#600000'>Everything on this page is about page views, except links named 'Edit Trend'</font></b>" ;

    # for linear regression
    # use Statistics:LineFit ;
    # http://search.cpan.org/~randerson/Statistics-LineFit-0.07/lib/Statistics/LineFit.pm

    # http://forum.chromefans.org/problem-with-span-p-and-style-display-none-t389.html
  # $out_html .= "\n<span id='wait'><left><font color='green'><b>" . $out_rendering . "</b></font></left><p></span>\n" ;

    if ($pageviews_mobile)
    {
      $href_normalized     = 'TablesPageViewsMonthlyMobile.htm' ;
      $href_not_normalized = 'TablesPageViewsMonthlyOriginalMobile.htm' ;
    }
    else
    {
      $href_normalized     = 'TablesPageViewsMonthly.htm' ;
      $href_not_normalized = 'TablesPageViewsMonthlyOriginal.htm' ;
    }

    if ($mode_wp)
    {
      if ($pageviews_mobile)
      { $out_html .= "<p>Switch to <a href='TablesPageViewsMonthly.htm'>regular (non-mobile) page views</a>" ; }
      else
      { $out_html .= "<p>Switch to <a href='TablesPageViewsMonthlyMobile.htm'>mobile page views</a>" . blank_text_after ("15/09/2010"," <b><font color=#008000>(June 2010: New)</font></b>") ;    }
    }

    if ($normalize_days_per_month)
    {
      $out_html .= "<p>Switch to <a href='$href_not_normalized'>not normalized version</a>" ;
      $href_current_file =  $href_normalized ;
    }
    else
    {
      $out_html .= "<p>For fairer comparison of monthly trends switch to <a href='$href_normalized'>normalized version</a>" ;
      $href_current_file =  $href_not_normalized ;
    }

    if ($mode_wp)
    {
      $out_html .= "<p>Switch to " ;
      if ($mode_wp && ($region ne ''))
      { $out_html .= "<a href='http://stats.wikimedia.org/EN/$href_current_file'>all languages</a>, " ; }
      if ($mode_wp && ($region ne 'africa'))
      { $out_html .= "<a href='http://stats.wikimedia.org/EN_Africa/$href_current_file'>Africa</a>, " ; }
      if ($mode_wp && ($region ne 'asia'))
      { $out_html .= "<a href='http://stats.wikimedia.org/EN_Asia/$href_current_file'>Asia</a>, " ; }
      if ($mode_wp && ($region ne 'america'))
      { $out_html .= "<a href='http://stats.wikimedia.org/EN_America/$href_current_file'>America's</a>, " ; }
      if ($mode_wp && ($region ne 'europe'))
      { $out_html .= "<a href='http://stats.wikimedia.org/EN_Europe/$href_current_file'>Europe</a>, " ; }
      if ($mode_wp && ($region ne 'india'))
       { $out_html .= "<a href='http://stats.wikimedia.org/EN_India/$href_current_file'>India</a>, " ; }
      if ($mode_wp && ($region ne 'oceania'))
      { $out_html .= "<a href='http://stats.wikimedia.org/EN_Oceania/$href_current_file'>Oceania</a>, " ; }
      if ($mode_wp && ($region ne 'artificial'))
      { $out_html .= "<a href='http://stats.wikimedia.org/EN_Artificial/$href_current_file'>artificial languages</a>, " ; }
      $out_html =~ s/, $// ;
    }
  }

  $out_html .= "<table border=1 cellspacing=0 id='table1' class=b style='margin-top:5px; border:solid 1px #000000' summary='Header comparison table'>\n" ;

  if (! $mode_wx)
  { &GenerateComparisonTableHeadersCascade ($f, $true, 9999) ; }
  if ($wikimedia)
  { &GenerateComparisonTableHeaders ($f, $true) ; }

  undef ($out_html_yearly) ;
  $out_html .= "{{YEARLY}}" ;

  if ($pageviews)
  {
    &GenerateComparisonTableEditPlots ;
    &GenerateComparisonTableYearlyGrowth (0) ;
    &GenerateComparisonTableViewRates (0) ;
    &GenerateComparisonTableSparklinesWithBars ;
  }

  if (! $pageviews)
  { &GenerateComparisonTableMonthlyTrends ($f) ; }

  $out_csv = &csv ("date") ;
  foreach my $wp (@languages)
  {
    if ($wp =~ /^zzz?$/)
    { $out_csv .= &csv ("tot") ; }
    else
    { $out_csv .= &csv ($wp) ; }
  }
  $out_csv =~ s/\,$/\n/ ;

  &GenerateComparisonTableMonthlyData (ord (&yyyymm2b (2001,1)), $f, 0, 999, $true, $true) ;

  if ($pageviews)
  { # &GenerateComparisonTableMaxData (0) ;
  }


#  $line_languages =~ s/<\/?a[^>]*>//g ;
#  $out_html .= &trh ($line_languages) ;
  if ($wikimedia)
  { &GenerateComparisonTableHeaders ($f, $false) ; }

  $out_html .= "</table>\n\n" ;

#  if ($pageviews)
#  {
#    $out_html .= "</table>\n<p>" ;
#    $out_html .= "<table><tr>" ;
#    $out_html .= &td ("<span class=d1>x%,&nbsp;y%</span><span class=d2>z</span>") ;
#    $out_html .= &td ("&nbsp;&nbsp;&nbsp;") ;
#    $out_html .= &td ("<span class=d1>x%=change compared to previous month, &nbsp;y%=share of page views for this language<br>z=page views this month ($out_million = 10<sup>6</sup>, $out_thousand = 10<sup>3</sup>)</span>") ;
#    $out_html .= "</tr></table>" ;
#  }

  if ($out_html_yearly ne '')
  {
    if ($javascript)
    {
      $out_html_yearly .= "\n<script language='javascript'>\n" .
                          "trc('#ffdead');\n" .
#                         "showOnNoPercentages('<td class=lb colspan=333 >&nbsp;</td></tr>');\n" .
                          "<\/script>\n" .
                          "<td class=lb colspan=333 >&nbsp;</td>\n" .
                          "<\/tr>\n" ;
    }
    else
    { $out_html_yearly .= "<tr bgcolor='#ffdead'><td class=lb colspan=333 >&nbsp;</td></tr>" ; }
  }

  $out_html =~ s/\{\{YEARLY\}\}/$out_html_yearly/ ;

  if ($colormode ne 'X')
  {
    $legend = "" ;
    $period = "month" ;
    if ($pageviews)
    { $period = "year/month" ; }
    if ($colormode eq 'A')
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('A', "< 0%") .
                &TdBgColor ('A', "0%") .
                &TdBgColor ('A', "1%") .
                &TdBgColor ('A', "2%") .
                &TdBgColor ('A', "4%") .
                &TdBgColor ('A', "8%") .
                &TdBgColor ('A', "16%") .
                &TdBgColor ('A', "32%") .
                &TdBgColor ('A', "64%") .
                &TdBgColor ('A', "128%") .
#               &TdBgColor ('A', "256%") .
#               &TdBgColor ('A', "512%") .
#               &TdBgColor ('A', "1024%") .
#               &TdBgColor ('A', "2048%") .
#               &TdBgColor ('A', "4096") .
#               &TdBgColor ('A', "8192%") .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Percentage increase compared to previous month</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'B')
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('B', 0) .
                &TdBgColor ('B', 1) .
                &TdBgColor ('B', 2) .
                &TdBgColor ('B', 4) .
                &TdBgColor ('B', 8) .
                &TdBgColor ('B', 16) .
                &TdBgColor ('B', 32) .
                &TdBgColor ('B', 64) .
                &TdBgColor ('B', 128) .
                &TdBgColor ('B', 256) .
                &TdBgColor ('B', 512) .
                &TdBgColor ('B', 1024) .
                &TdBgColor ('B', 2048) .
                &TdBgColor ('B', 4096) .
                &TdBgColor ('B', 8192) .
                &TdBgColor ('B', 16384) .
                &TdBgColor ('B', '32768 or more') .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Absolute value</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'C')
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('C', '-50%') .
                &TdBgColor ('C', '-40%') .
                &TdBgColor ('C', '-30%') .
                &TdBgColor ('C', '-20%') .
                &TdBgColor ('C', '-10%') .
                &TdBgColor ('C',   '0%') .
                &TdBgColor ('C',  '10%') .
                &TdBgColor ('C',  '20%') .
                &TdBgColor ('C',  '30%') .
                &TdBgColor ('C',  '40%') .
                &TdBgColor ('C',  '50%') .
                &TdBgColor ('C',  '60%') .
                &TdBgColor ('C',  '70%') .
                &TdBgColor ('C',  '80%') .
                &TdBgColor ('C',  '90%') .
                &TdBgColor ('C', '100%') .
                &TdBgColor ('C', '110%') .
                &TdBgColor ('C', '120%') .
                &TdBgColor ('C', '130%') .
                &TdBgColor ('C', '140%') .
                &TdBgColor ('C', '150%') .
                &TdBgColor ('C', '160%') .
                &TdBgColor ('C', '170%') .
                &TdBgColor ('C', '180%') .
                &TdBgColor ('C', '190%') .
                &TdBgColor ('C', '200%') .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Percentage increase or decrease compared to previous month</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'D')
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('D',  '0%') .
                &TdBgColor ('D',  '10%') .
                &TdBgColor ('D',  '20%') .
                &TdBgColor ('D',  '30%') .
                &TdBgColor ('D',  '40%') .
                &TdBgColor ('D',  '50%') .
                &TdBgColor ('D',  '60%') .
                &TdBgColor ('D',  '70%') .
                &TdBgColor ('D',  '80%') .
                &TdBgColor ('D',  '90%') .
                &TdBgColor ('D', '100%') .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Absolute value</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'E')
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('E',  '0') .
                &TdBgColor ('E',  '5') .
                &TdBgColor ('E',  '10') .
                &TdBgColor ('E',  '15') .
                &TdBgColor ('E',  '20') .
                &TdBgColor ('E',  '25') .
                &TdBgColor ('E',  '30') .
                &TdBgColor ('E',  '35') .
                &TdBgColor ('E',  '40') .
                &TdBgColor ('E',  '45') .
                &TdBgColor ('E',  '50') .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Absolute value</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'F')
    {
      my $valmax = 10000 ;
      if ($mode_wk) { $valmax = 1000 ; }
      if ($mode_wb) { $valmax = 50000 ; }
      if ($mode_wv) { $valmax = 50000 ; }

      $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('F',  0) .
                &TdBgColor ('F',  $valmax*0.1) .
                &TdBgColor ('F',  $valmax*0.2) .
                &TdBgColor ('F',  $valmax*0.3) .
                &TdBgColor ('F',  $valmax*0.4) .
                &TdBgColor ('F',  $valmax*0.5) .
                &TdBgColor ('F',  $valmax*0.6) .
                &TdBgColor ('F',  $valmax*0.7) .
                &TdBgColor ('F',  $valmax*0.8) .
                &TdBgColor ('F',  $valmax*0.9) .
                &TdBgColor ('F',  $valmax) .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Absolute value</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'G')
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('G', '-50%') .
                &TdBgColor ('G', '-40%') .
                &TdBgColor ('G', '-30%') .
                &TdBgColor ('G', '-20%') .
                &TdBgColor ('G', '-10%') .
                &TdBgColor ('G',   '0%') .
                &TdBgColor ('G',  '10%') .
                &TdBgColor ('G',  '20%') .
                &TdBgColor ('G',  '30%') .
                &TdBgColor ('G',  '40%') .
                &TdBgColor ('G',  '50%') .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Percentage increase or decrease compared to previous month</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'H')
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('H', '-100%') .
                &TdBgColor ('H', '-75%') .
                &TdBgColor ('H', '-50%') .
                &TdBgColor ('H', '-25%') .
                &TdBgColor ('H',   '0%') .
                &TdBgColor ('H',  '25%') .
                &TdBgColor ('H',  '50%') .
                &TdBgColor ('H',  '75%') .
                &TdBgColor ('H',  '100%') .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Percentage increase or decrease compared to previous month</td></tr></table></td><tr></table>" ; }
    if ($colormode eq 'I') # also for pageviews
    { $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
                &TdBgColor ('I', '-50%') .
                &TdBgColor ('I', '-40%') .
                &TdBgColor ('I', '-30%') .
                &TdBgColor ('I', '-20%') .
                &TdBgColor ('I', '-10%') .
                &TdBgColor ('I',   '0%') .
                &TdBgColor ('I',  '10%') .
                &TdBgColor ('I',  '20%') .
                &TdBgColor ('I',  '30%') .
                &TdBgColor ('I',  '40%') .
                &TdBgColor ('I',  '50%') .
                "</tr></table></td><td valign=bottom><table border='0'><tr><td>Percentage increase or decrease compared to previous $period</td></tr></table></td><tr></table>" ; }
#   $legend = @c [$f] . " " . $legend ;

    if ($javascript)
    {
      $legend  = "\n<script language='javascript'>\n" .
                 "if (showCellColors == 'y')\n" .
                 "{ document.write (\"$legend\"); } \n" .
                 "<\/script>\n" ;

      $out_html =~ s/(<hr[^>]*>)/$legend$out_xref$1/ ;
    }
  }

  if (! $pageviews)
  {
    &GenerateColophon ($true, $false) ;

    $out_html .= $out_script_embedded. "\n</body>\n</html>" ;

    $out_html =~ s/roa_rup/roa-rup/g ;
    $out_html =~ s/zh_min_nan/zh-min-nan/g ;
    $out_html =~ s/fiu_vro/fiu-vro/g ;
  }

  $javascript = $javascript_ ;
}

sub GenerateComparisonTablePageviewsAllProjects
{
  my ($filter_source_normalized) = @_ ;

  return if $pageviews_mobile ;
  return if $mode ne 'wp' ; # test here to keep calling code simple
  return if ! $wikimedia ;  # test here to keep calling code simple

  &LogT ("\nGenerateComparisonTablePageviewsAllProjects $filter_source_normalized") ;

  $legend = "<table border='0'><tr><td valign=bottom><table border=1 cellspacing=0 id='legend' class=b style='margin-top:5px; border:solid 1px #000000'><tr>" .
             &TdBgColor ('I', '-50%') .
             &TdBgColor ('I', '-40%') .
             &TdBgColor ('I', '-30%') .
             &TdBgColor ('I', '-20%') .
             &TdBgColor ('I', '-10%') .
             &TdBgColor ('I',   '0%') .
             &TdBgColor ('I',  '10%') .
             &TdBgColor ('I',  '20%') .
             &TdBgColor ('I',  '30%') .
             &TdBgColor ('I',  '40%') .
             &TdBgColor ('I',  '50%') .
             "</tr></table></td><td valign=bottom><table border='0'><tr><td>Percentage increase or decrease compared to previous $period</td></tr></table></td><tr></table>" ;

  $pageviews_all_projects = $true ;
  &GenerateHtmlStartComparisonTables ;

  if ($javascript)
  {
    $legend  = "\n<script language='javascript'>\n" .
               "if (showCellColors == 'y')\n" .
               "{ document.write (\"$legend\"); } \n" .
               "<\/script>\n" ;
    $out_html =~ s/(<hr[^>]*>)/$legend$1/ ;
  }

  $javascript_ = $javascript ;
  $javascript  = $true ;

#  if ($pageviews_mobile)
#  {
#    $out_html .= "<h3>Page views per project per month (mobile site) <font color=#A0A0A0>(plus links to edit trends)</font></h3>" ;
#    $out_html .= "<p><b><font color=#008000>Mobile traffic only! </font></b>. Switch to <a href='TablesPageViewsMonthlyAllProjects.htm'>regular (non-mobile) site</a><p>$msg_perc_mobile" ;
#  }
#  else
#  {
#    $out_html .= "<h3>Page views per project per month <font color=#A0A0A0>(plus links to edit trends)</font></h3>" ;
#    $out_html .= "<p><b><font color=#008000>Non-mobile traffic only!</font></b> Switch to <a href='TablesPageViewsMonthlyAllProjectsMobile.htm'>mobile site</a>" . blank_text_after ("15/09/2010"," <b><font color=#008000>(June 2010: New)</font></b>") . "<p>$msg_perc_non_mobile" ;
#  }

  # $out_html .= "<p><b><font color='#600000'>Everything on this page is about page views, except links named 'Edit Trend'</font></b>" ;

  $out_html .= "<b><font color=#A00000>Warning: page view counts from Nov 2009 till March 2010 are too low.</font></b> " .
               "In July 2010 is was established that the server that collects and aggregates log data for all squids could not keep up with all incoming messages, and hence underreported page views. " .
               "This issue has been resolved. For April - July 2010 the amount of underreporting could be inferred from still available log files and counts for these months have been corrected (read <a href='http://infodisiac.com/blog/wp-content/uploads/2010/07/assessment.pdf'>more</a>). For earlier months, possibly from Nov 2009 till March 2010 counts in the table below are too low.<hr><p>" ;

  $out_html .= $legend_pageviews_monthly ;

  if ($pageviews_mobile)
  {
    $href_normalized     = 'TablesPageViewsMonthlyAllProjectsMobile.htm' ;
    $href_not_normalized = 'TablesPageViewsMonthlyAllProjectsOriginalMobile.htm' ;
  }
  else
  {
    $href_normalized     = 'TablesPageViewsMonthlyAllProjects.htm' ;
    $href_not_normalized = 'TablesPageViewsMonthlyAllProjectsOriginal.htm' ;
  }

  if ($filter_source_normalized =~ /not-normalized/)
  { $out_html .= "<p><b><font color=#800000>View counts on this page have <font color=#FF0000>not</font> been normalized to months of 30 days.</font></b>. " .
                 "For fairer comparison of monthly trends <a href='$href_normalized'>switch to normalized version</a>." ; }
  else
  { $out_html .= "<p><b><font color=#008000>View counts on this page have been normalized to months of 30 days, for fair comparison.</font></b>. " .
                 "<a href='$href_not_normalized'>Switch to not normalized version.</a>" ; }

  $out_html .= "<table border=1 cellspacing=0 id='table1' class=b style='margin-top:5px; border:solid 1px #000000' summary='Header comparison table'>\n" ;

  &Log ("\n") ;
  my ($key1,$key2,$html) ;
  $month_lo_pageviews = 999 ;
  foreach $code (qw (wb wk wn wp wq ws wv wx)) # in case of wx (wikispecial), file contains only results for commons
  {
    $path_in_views = $path_in ;
    $path_in_views =~ s/csv_$mode/csv_$code/ ;
    $file_views_html = "$path_in_views/PageViewsPerMonthHtmlAllProjects.csv" ;

    if (! -e $file_views_html)
    { print "$file_views_html not found\n" ; next ; }

    print "Read $file_views_html\n" ;
    open CSV, '<', $file_views_html ;
    while ($line = <CSV>)
    {
      next if $line !~ /^$filter_source_normalized/ ;
      chomp $line ;
      $line =~ s/$filter_source_normalized,// ;
      ($key1,$key2,$html) = split (',', $line) ;
      $html =~ s/&comma;/,/g ;
    # &Log ("< $line = $key1 $key2 $html\n") ;
      $html =~ s/&linebreak;/\n/g ;

      if ($key2 =~ /header_\d+/)
      {
        ($key2b = $key2) =~ s/[^\d]//g ;
        if ($key2b < $month_lo_pageviews)
        { $month_lo_pageviews = $key2b ; }
        if ($key2b > $month_hi_pageviews)
        { $month_hi_pageviews = $key2b ; }
      }
      $html_pageviews_all_projects {"$code,$key1,$key2"} = $html ;
      $html_row_keys_all_projects  {$key1}++ ;
    }
  }
  print "\n\$month_hi_pageviews $month_hi_pageviews\n" ;
  print "\$month_lo_pageviews $month_lo_pageviews\n" ;

  $out_html .= "<p>\n\n<table border=1>\n" ;

  my %project_names ;
  $project_names {'wb'} = 'wikibooks' ;
  $project_names {'wk'} = 'wiktionary' ;
  $project_names {'wn'} = 'wikinews' ;
  $project_names {'wp'} = 'wikipedia' ;
  $project_names {'wq'} = 'wikiquote' ;
  $project_names {'ws'} = 'wikisource' ;
  $project_names {'wv'} = 'wikiversity' ;
  $project_names {'wx'} = 'commons' ;

  $url_report_pageviews {'wb'} = "http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm" ;

  $line_html = &the;
  foreach $code (qw (wb wk wn wp wq ws wv wx))
  {
    if ($pageviews_normal)
    {
      $root = "http://stats.wikimedia.org" ;

      if ($code eq 'wb') { $link = "<a href='$root/wikibooks/EN/TablesPageViewsMonthly.htm'>Wikibooks</a>" ; }
      if ($code eq 'wk') { $link = "<a href='$root/wiktionary/EN/TablesPageViewsMonthly.htm'>Wiktionaries</a>" ; }
      if ($code eq 'wn') { $link = "<a href='$root/wikinews/EN/TablesPageViewsMonthly.htm'>Wikinews</a>" ; }
      if ($code eq 'wp') { $link = "<a href='$root/EN/TablesPageViewsMonthly.htm'>Wikipedia</a>" ; }
      if ($code eq 'wq') { $link = "<a href='$root/wikiquote/EN/TablesPageViewsMonthly.htm'>Wikiquote</a>" ; }
      if ($code eq 'ws') { $link = "<a href='$root/wikisource/EN/TablesPageViewsMonthly.htm'>Wikisource</a>" ; }
      if ($code eq 'wv') { $link = "<a href='$root/wikiversity/EN/TablesPageViewsMonthly.htm'>Wikiversity</a>" ; }
      if ($code eq 'wx') { $link = "<a href='$root/wikispecial/EN/TablesPageViewsMonthly.htm'>Commons</a>" ; }
      $line_html .= &th("&nbsp;$link&nbsp;") ;
    }
    else
    { $line_html .= &th("&nbsp;" . ucfirst($project_names {$code}). "&nbsp;") ; }
  }
  $out_html .= &tr ($line_html) ;

  $line_html = &the ;
  foreach $code (qw (wb wk wn wp wq ws wv wx))
  {
    if ($code eq 'wb') { $link = "$root/wikibooks/EN/PlotEditsZZ.png" ; }
    if ($code eq 'wk') { $link = "$root/wiktionary/EN/PlotEditsZZ.png" ; }
    if ($code eq 'wn') { $link = "$root/wikinews/EN/PlotEditsZZ.png" ; }
    if ($code eq 'wp') { $link = "$root/EN/PlotEditsZZ.png" ; }
    if ($code eq 'wq') { $link = "$root/wikiquote/EN/PlotEditsZZ.png" ; }
    if ($code eq 'ws') { $link = "$root/wikisource/EN/PlotEditsZZ.png" ; }
    if ($code eq 'wv') { $link = "$root/wikiversity/EN/PlotEditsZZ.png" ; }
    if ($code eq 'wx') { $link = "$root/wikispecial/EN/PlotEditsZZ.png" ; }
    $line_html .= &tdcb ("<a href='$link'>Edit Trends</a>") ;
  }
  $out_html .= &tr ($line_html) ;

  foreach $key1 (qw (year_trend view_rates sparklines forecast forecast2))
  {
    $line_html = $html_pageviews_all_projects {"wp,$key1,header"} ;

    if ($key1 =~ /year_trend|forecast/)
    { $line_html .= "\n<script language='javascript'>\n" ; }

    foreach $code (qw (wb wk wn wp wq ws wv wx))
    {
      $cell_html = $html_pageviews_all_projects {"$code,$key1,data"} ;
      if ($cell_html eq '')
      {
        if ($key1 =~ /year_trend|forecast|forecast2/)
        { $cell_html = "tdg('');" ; }
        else
        { $cell_html = "<td>&nbsp;</td>" ; }
      }
      $line_html .= $cell_html ;
    }

    if ($key1 =~ /year_trend|forecast|forecast2/)
    { $line_html .= "\n</script>\n" ; }

    $out_html .= &tr ($line_html) ;
  }

  for ($m = $month_hi_pageviews ; $m >= $month_lo_pageviews ; $m--)
  {
    $line_html = $html_pageviews_all_projects {"wp,monthly,header_$m"} ;
    next if $line_html eq '' ;

    $line_html .= "\n<script language='javascript'>\n" ;
    foreach $code (qw (wb wk wn wp wq ws wv wx))
    {
      $cell_html = $html_pageviews_all_projects {"$code,monthly,data_$m"} ;
      if ($cell_html eq '')
      { $cell_html = "tdg('');" ; }
      $line_html .= $cell_html ;
    }
    $line_html .= "\n</script>\n" ;
    $out_html .= &tr ($line_html) ;
  }

  $line_html = &the;
  foreach $code (qw (wb wk wn wp wq ws wv wx))
  { $line_html .= &th('&nbsp;'. ucfirst($project_names {$code}).'&nbsp;') ; }
  $out_html .= &tr ($line_html) ;

  #    &GenerateComparisonTableEditPlots ;
#    &GenerateComparisonTableYearlyGrowth (0) ;
#    &GenerateComparisonTableViewRates (0) ;
#    &GenerateComparisonTableSparklinesWithBars ;


#  &GenerateComparisonTableMonthlyData (ord (&yyyymm2b (2001,1)), $f, 0, 999, $true, $true) ;

#  &GenerateComparisonTableHeaders ($f, $false) ;

  $out_html .= "</table>\n\n" ;

  $generate_sitemap = $false ;
  &GenerateColophon ($true, $false) ;

  $out_html .= "</body>\n</html>" ;

  if ($filter_source_normalized =~ /not-normalized/)
  { $file_html = $path_out . "TablesPageViewsMonthlyAllProjectsOriginal.htm" ; }
  else
  { $file_html = $path_out . "TablesPageViewsMonthlyAllProjects.htm" ; }

  open "FILE_HTML", ">", $file_html ;
  print FILE_HTML &AlignPerLanguage ($out_html) ;
  close "FILE_HTML" ;
}

sub BgColor
{
  my $colormode   = shift ;
  my $val    = shift ;
  my $column = shift ;
  my $trend ;
  my $color ;
  my $hue ;
  my $sat ;
  my $value ;

  if ($colormode eq 'A')
  {
    $trend  = $val ;
    $trend  =~ s/[\+\%]//g ;
    if (($trend < 0) || ($trend =~ /<\s0/))
    { $color = hsl2rgb (0.4,1,0.65) ; }
    elsif ($trend == 0)
    { $color = hsl2rgb (0.5,1,0.7) ; }
    else
    {
      $trend = log ($trend) / log (2) ;
      $trend = 0.5 + (($trend+1)/16) ; # trend + 1 to keep clear distinctin between 0 and 1
      if ($trend > 1) { $trend = 1 ;}
      $color = hsl2rgb ($trend,1,0.7) ;
    }
  }

  elsif ($colormode eq 'B')
  {
    $trend  = $val ;
    $trend  =~ s/[^\d\-]//g ;
    if ($trend <= 0)
    { $color = "\#C0C0C0"; }
    else
    {
      $trend = log ($trend) / log (2) ;
      $trend = (($trend+1)/16) * 255 ; # trend + 1 to keep clear distinctin between 0 and 1
      if ($trend > 255) { $trend = 255 ;}
      $trend = sprintf ("%.0f", $trend) ;
      $color = "\#FF" . sprintf ("%02X", 255-$trend) . sprintf ("%02X",$trend) ;
    }
  }

  elsif ($colormode eq 'C')
  {
    $trend  = $val ;
    $negative = (index ($trend, '-') > -1) ;
    $trend =~ s/[^\+\-\d]//g ;
    $trend2 = $trend ;

    # /50 vs /25 = amplify negative trend compare to positive trends
    # * 127 = fit neg and pos within range /50 vs /25 = amplify negative trend compare to positive trends
    # fit neg in 0-96 (128-32) and pos in (128+32) 160-255

    $trend = ($trend + 50) / 250 ;
    if ($trend < 0) { $trend = 0 ; }
    if ($trend > 1) { $trend = 1 ; }
    $color = hsl2rgb ((1-$trend*0.8),1,0.7) ;

#    if ($trend > 0)
#    { $trend = $trend/50 * (255-160) + 160 ; } # -> 0% = 160,  50% and more  = 255 and more
#    else
#    { $trend = -$trend/50 * 96 + 96 ; }        # -> 0% =   96, -25% and less  = 0 an less

#    # if ($trend > 255) { $trend = 255 ;}
#    if ($trend < 0)
#    { $trend = 0 ;}

#    if ($trend > 255)
#    {
#      $trend -= 255 ; if ($trend > 255) { $trend = 255 ; }
#      $trend = sprintf ("%.0f", $trend*.75) ;
#      $color = "\#FF" . sprintf ("%02X", 64+$trend) . sprintf ("%02X", 255 - $trend) ;
#    }
#    elsif ($trend2 >= 0)
#    {
#      $trend = sprintf ("%.0f", $trend*.75) ; # shrink range 0-255 to 0-191 (=255-64)
#      $color = "\#" . sprintf ("%02X", 64+$trend) . sprintf ("%02X", 255 - $trend) . "FF" ; # add 64 to keeps colors light
#    }
#    else
#    {
#      $trend = sprintf ("%.0f", $trend*.75) ; # shrink range 0-255 to 0-191 (=255-64)
#      $color = "\#00" . sprintf ("%02X", 64+$trend) . sprintf ("%02X", 255 - $trend) ; # add 64 to keeps colors light
#    }
  }

  elsif ($colormode eq 'D')
  {
    $val =~ s/\%// ;
    #f ($column eq 'K')
    #
    # $val = $val/50 * 255 ; # min = 0%, max = 50%
    # if ($val > 255) { $val = 255 ;}
    # $color = "\#" . sprintf ("%02X", $val) . sprintf ("%02X", 255 - $val) . "FF";
    #
    #lse
    #
      $val = ($val/100) * 255 ;
      $color = "\#" . sprintf ("%02X", $val) . sprintf ("%02X", 255 - $val) . "FF";
    #
  }

  elsif ($colormode eq 'E')
  {
    my $valmax = 50 ; # update in 2007: make this dynamic
                      # however do not base it on max value found some are pretty extreme
    if ($val > $valmax) { $val = $valmax ; }
    $val = ($val/$valmax) * 255 ;
    $color = "\#" . sprintf ("%02X", $val) . sprintf ("%02X", 255 - $val) . "FF";
  }

  elsif ($colormode eq 'F')
  {
    # update in 2007: make this dynamic
    # however do not base it on max value found some are pretty extreme
    my $valmax = 10000 ;
    if ($mode_wk) { $valmax = 1000 ; }
    if ($mode_wb) { $valmax = 50000 ; }
    if ($mode_wv) { $valmax = 50000 ; }
    if ($val > $valmax) { $val = $valmax ; }
    # $val = ($val/$valmax) * 255 ;
    $color = hsl2rgb (0.25+($val/$valmax)*0.75,1,0.75) ;
    # $color = "\#" . sprintf ("%02X", $val) . sprintf ("%02X", 255 - $val) . "FF";
  }
  elsif ($colormode eq 'G')
  {
    $val =~ s/\%// ;
    my $valmax = 50 ;
    if ($val > $valmax) { $val = $valmax ; }
    if ($val < (0 - $valmax)) { $val = 0 - $valmax ; }
    $valmax = 0 - $valmax ; # min red to pos green
    $color = hsl2rgb (0.25+(($val+$valmax)/(2*$valmax))*0.75,1,0.75) ;
  }
  elsif ($colormode eq 'H')
  {
    $val =~ s/\%// ;
    my $valmax = 100 ;
    if ($val > $valmax) { $val = $valmax ; }
    if ($val < (0 - $valmax)) { $val = 0 - $valmax ; }
    $valmax = 0 - $valmax ; # min red to pos green
    $color = hsl2rgb (0.25+(($val+$valmax)/(2*$valmax))*0.75,1,0.75) ;
  }
  elsif ($colormode eq 'I')
  {
    $val =~ s/\%// ;
    my $valmax = 50 ;
    if ($val > $valmax) { $val = $valmax ; }
    if ($val < (0 - $valmax)) { $val = 0 - $valmax ; }

    if ($val == 0)
    { $color = "#FFFFFF " ; }
    elsif ($val > 0)
    {
      $col1 = 255 ;
      $col2 = int (255 - ($val/$valmax) * 200) ;
      $color = "\#" . sprintf ("%02X%02X%02X", $col2, $col1, $col2) ;
    }
    else
    {
      $col1 = 255 ;
      $col2 = int (255 + ($val/$valmax) * 200) ;
      $color = "\#" . sprintf ("%02X%02X%02X", $col1, $col2, $col2) ;
    }
  }

  return ($color) ;
}

sub TdBgColor
{
  my $mode = shift ;
  my $val  = shift ;
  my $color = &BgColor ($mode, $val, 'p') ;
  if ($val =~ /-/)
  { return ("<td width=25 bgcolor=$color nowrap><nobr>$val</nobr></td>") ; }
  else
  { return ("<td width=25 bgcolor=$color>$val</td>") ; }
}

sub GenerateConsolidatedTablePlusCharts
{
  &LogT ("\nGenerateConsolidatedTablePlusCharts") ;

  my $md = $dumpmonth_ord ;

  my $wpmax = $#languages ;
  if ($wpmax > 75)
  { $wpmax = 75 ; }

  &GenerateHtmlStartComparisonTables ($#out_report_descriptions) ;

  $show_forecast = $true ;

  $line_languages = &tdcb ("&nbsp;") ;

  my $wpcnt = 0 ;
  foreach my $wp2 (@languages)
  {
    if ($skip {$wp2}) { next ; }

    if ($wpcnt++ > $wpmax)
    { last ; }

    if ($wp2 eq "zz")
    {  $line_languages .= &tdcb (&b (&w ("<font color='#400040'>&Sigma;</font>"))) ; }
    else
    {  $line_languages .= &tdcb (&b (&w ("<a href='TablesWikipedia".uc ($wp2).".htm' " .
                                       ((($language ne "ja") && ($language ne "zh"))? "title='" . $out_languages {$wp2} . "'" : "") .
                                        ">".$wp2."</a>"))) ; }
  }
  $line_languages12 = $line_languages ;
  $line_languages12 =~ s/(<td[^>]*>)/$1<font color='#007733'>K=$out_kilobytes, M=$out_megabytes<\/font>/ ;

  my @days ;
  $days [0] = substr ($recent_dates [0],3,2) ;
  $days [1] = substr ($recent_dates [1],3,2) ;
  $days [2] = substr ($recent_dates [2],3,2) ;
  $days [3] = substr ($recent_dates [3],3,2) ;
  $days [4] = substr ($recent_dates [4],3,2) ;
  my $dayst_m  = $days[0] + $days[1] + $days[2] + $days[3] ;
  my $dayst_p  = $days[0] + $days[1] + $days[2] + $days[3] + $days[4] ;

  $out_html .= "<small>" .
               $out_mean . " = " . $out_average_1 . "&nbsp;&nbsp;|&nbsp;&nbsp;" .
               $out_growth . " = " . $out_growth_1 . " (<a href='#formula'>" . $out_formula . "</a>) &nbsp;&nbsp;\n" .
               "<script>\n<!--\ndocument.write(getLegend());\n//-->\n</script>\n" .
               "</small><br>\n" ;

# $out_html .= "<a id='A' name='A'>&nbsp;</a>\n" ;
  $out_html .= "<table border=1 cellspacing=0 id='table1' class=b summary='Comparison table'>\n" ;

  $line_html2 = "" ;
  for ($f = 0 ; $f <= $fmax ; $f++)
  {
    if ((! $mode_wp) &&
          (($f == 5) || ($f == 9) || ($f == 10)))
    { next ; }

    if ($f ==  0) { &GenerateLinkBarRow (1) ; }
    if ($f ==  4) { &GenerateLinkBarRow (2) ; }
    if ($f == 11) { &GenerateLinkBarRow (3) ; }
    if ($f == 14) { &GenerateLinkBarRow (4) ; }
 #  if ($f == 19) { last ; }
    if ($f == 19) { &GenerateLinkBarRow (5) ; }

    if ($f > 0)
    { $out_html .= &tr ("<td class=lb colspan='" . ($#languages+4) . "'>\n" .
                        "<a id='" . $c[$f] . "' name='" . $c[$f] . "'>&nbsp;</a></td>\n") ; }

    $style = "style='border-bottom:solid 1px #808080'" ;
    $style = "" ;
    $out_html .= &trh ("<td class=c' colspan='" . ($#languages+4) . "'>\n\n" .
                       "<table border=1 width='100%' class=b style='border:solid 1px #808080' summary='Headers'>\n<tr>\n" .
                       ((($mode_wp) || ($mode_wk))?"<th class=l width='10%' $style>\n":"<th class='l' $style>\n") .
                       # (($f > 0) ? "<a href='\#0'>\#</a>&nbsp;&nbsp;\n" : "") .
                       "$out_links" .
                       (($f > 0    ) ? "&nbsp;\n<font size='2'><a href='\#" . $c[$f-1] . "'>&#171;</a></font>\n" : "") .
                       (($f < $fmax) ? "&nbsp;&nbsp;\n<font size='2'><a href='\#" . $c[$f+1] . "'>&#187;</a></font>\n" : "") .
                       "</th>\n" .
                       "<th class=c>\n" .
                       "<table width='100%' summary=''><tr>\n" .
                       "<th class=c $style>" . &w(&b("$out_group - <a href='Tables" . $report_names [$f] . ".htm'>" .
                       $out_report_descriptions [$f] . "</a>")) . "</th>\n" .

                       ((($mode_wp) || ($mode_wk))?
                       ($wpmax > 20 ? "<th class=c $style>" . &w(&b("$out_group - <a href='Tables" . $report_names [$f] . ".htm'>" .
                       $out_report_descriptions [$f] . "</a>")) . "</th>\n" : "") .

                       ($wpmax > 40 ? "<th class=c $style>" . &w(&b("$out_group - <a href='Tables" . $report_names [$f] . ".htm'>" .
                       $out_report_descriptions [$f] . "</a>")) . "</th>\n" : "").

                       ($wpmax > 60 ? "<th class=c $style>" . &w(&b("$out_group - <a href='Tables" . $report_names [$f] . ".htm'>" .
                       $out_report_descriptions [$f] . "</a>")) . "</th>\n" : "").

                       ($wpmax > 80 ? "<th class=c $style>" . &w(&b("$out_group - <a href='Tables" . $report_names [$f] . ".htm'>" .
                       $out_report_descriptions [$f] . "</a>")) . "</th>\n" : "")
                       :"") .

                       "</tr></table></td>\n" .
#                      "<td width='10%'>&nbsp;</td>\n" .
                       "</tr>\n</table>\n\n" .
                       "</td>") ;
    $out_id = "&nbsp;" ;

    if (((! $wikimedia) || ($f == 0)) && (! $mode_wx))
    { &GenerateComparisonTableHeadersCascade ($f, ($f==0 ? $true : $false), $wpmax) ; }

    if ($wikimedia)
    {
      if ($f == 12)
      { $out_html .= &trh2c ($line_languages12) ; }
      else
      { $out_html .= &trh2c ($line_languages) ; }
    }

    $d = 0 ;
    $maxf1 [$f] = 0 ;
    $maxf2 [$f] = 0 ;

    # show graph for last month or previous month (if incomplete month)
    $mg = $month_max ;
    if ($month_max_incomplete)
    {
      if (",1,2,3,6,7,8,9,10,11," =~ m/,$f,/)
      { $mg -- ; }
    }
    # go up to 2 months back when it has data for more (large) wikis
    for ($months_step_back = 0 ; $months_step_back < 2 ; $months_step_back++)
    {
      for ($l = 0 ; ($l <= $#languages) && ($l <= 15) ; $l++)
      {
        if (($MonthlyStats {$languages [$l].$mg.    $c[0]} == 0) &&
            ($MonthlyStats {$languages [$l].($mg-1).$c[0]} != 0))
        { $mg -- ; last ; }
      }
    }

    &GenerateComparisonTableMonthlyData ($month_max - 4, $f, $mg, $wpmax, $false, $false);

    if ($show_forecasts)
    {
      if ($javascript)
      {
        $out_html .= "\n<script language='javascript'>\n" .
                     "trc('#ffdead');\n" .
                     "<\/script>\n" ;
      }
      else
      { $out_html .= "<tr bgcolor='#ffdead'>" ; }

      $out_html .= "<td colspan=333 class=cb>" .
                   "<img src='../black.gif' height='3' width='1' alt=''></td></tr>" ;
    }

    $fc = ",1,2,3,6,11," ;
    if ($fc =~ m/,$f,/)
    {
      $line_html = &tdrb (&w ($out_mean)) ;

      $wpcnt = 0 ;
      for ($l = 0 ; $l <= $#languages ; $l++)
      {
        if ($skip {$languages[$l]}) { next ;}
        if ($wpcnt++ > $wpmax) { last ; }

        $value = $MonthlyStats {$languages [$l].$c[$f].'m'} ;
        if ($value < 0.05)
        { $value = "&nbsp;" ; }
        elsif ($f != 11)
        { $value = sprintf ("%.0f", $value) ; }
        else
        { $value = &format(sprintf ("%.0f", $value),$c[$f]) ; }
        if ($l == 0)
        { $line_html .= &tdrs ($value) ; }
        else
        { $line_html .= &tdrb ($value) ; }
      }
      $out_html .= &trh2 ($line_html) ;
    }

    $fc = ",0,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20," ;
    if ($fc =~ m/,$f,/)
    {
      $line_html = &tdrb (&w ($out_growth)) ;
      $wpcnt = 0 ;
      for ($l = 0 ; $l <= $#languages ; $l++)
      {
        if ($skip {$languages[$l]}) { next ;}
        if ($wpcnt++ > $wpmax) { last ; }

        $value = $MonthlyStats {$languages [$l].$c[$f].'p'} ;
        $value = sprintf ("%.0f", $value) ;
        if (($value > -1) & ($value < 1))
        { $value = "&nbsp;" }
        elsif ($value < 0)

        { $value = "<font color='#FF0000'>" . $value . "%</font>" ; }
        else
        { $value = $value . "%" ; }
        if ($l == 0)
        { $line_html .= &tdrs ($value) ; }
        else
        { $line_html .= &tdrb ($value) ; }
      }
      $out_html .= &trh2 ($line_html) ;
    }
    $line_languages =~ s/<a[^>]*>//g ;
    $line_languages =~ s/<\/a>//g ;

    $d = 0 ;
    $colour = "Y" ;

    $recent_date = GetDateShort (@recent_dates [($mg < $month_max) ? 3 : 4]);

    $line_html =
    "<noscript><tr><td colspan='" . ($#languages+4) ." align='center'>&nbsp;<b><font color='#AA0000'>Javascript not available or not active. Charts can not be shown.</font></b>&nbsp;</td></tr></noscript>\n" .
    "<script>\n<!--\n" .
    "y_axis(" . $maxf1 [$f] . "," . $maxf2 [$f] . ",'" .
                $recent_date . "',2,'$out_thousands_separator','$out_decimal_separator');\n" ;

    $wpcnt = 0 ;
    for ($l = 0 ; $l <= $#languages ; $l++)
    {
      if ($skip {$languages[$l]}) { next ;}
      if ($wpcnt++ > $wpmax) { last ; }

      $value = @MonthlyStats {$languages[$l].$mg.$c[$f]} ;
      $value =~ s/\%// ;
      if ($value == 0) # change non numerics in zero
      { $value = 0 ; }
      $line_html .= "bar2('Y',".$value.");\n" ;
    }
    $out_html .= $line_html ;
    $out_html .= "document.write (\"</tr>\");\n" .
                 "//-->\n</script>\n\n" ;
  }
  $out_html .= "</tbody></table><p>" ;

  $out_html .= "<a id='formula' name='formula'></a><small>" .
               $out_mean . " = " . $out_average_1 . " = (" .
               $days [0] . " x $out_value\[" . GetMonthShort (substr ($recent_dates [0],0,2)) . "] + " .
               $days [1] . " x $out_value\[" . GetMonthShort (substr ($recent_dates [1],0,2)) . "] + " .
               $days [2] . " x $out_value\[" . GetMonthShort (substr ($recent_dates [2],0,2)) . "] + " .
               $days [3] . " x $out_value\[" . GetMonthShort (substr ($recent_dates [3],0,2)) . "] + " .
               $days [4] . " x $out_value\[" . GetMonthShort (substr ($recent_dates [4],0,2)) . "]) / " .
               $dayst_m . "\n" ;
  $out_html .= "<p>" .
               $out_growth . " = " . $out_growth_1 . "  = " .
               "100 * (" . $days [1] . " x ($out_value\[" . GetMonthShort (substr ($recent_dates [1],0,2)) . "] - " .
               "$out_value\[" . GetMonthShort (($m = substr ($recent_dates [1],0,2)) > 1? $m-1:12) . "])" .
               " / $out_value\[" . GetMonthShort (($m = substr ($recent_dates [1],0,2)) > 1? $m-1:12) . "]" .
               " + " . $days [2] . " x ...etc) / " . $dayst_p . "&nbsp;&nbsp;".$out_skip_values."</small>\n" ;

  &GenerateColophon ($true, $false) ;

  $out_html .= $out_script_embedded. "\n</body>\n</html>" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  # remove most class info, not needed in this table, a waste
#  $out_html =~ s/class=(cb[\s>])/class-$1/g ; # keep only this class
  $out_html =~ s/(<td[^>]*)class=\w+\s?/$1/g ;
#  $out_html =~ s/class-/class=/g ;

  $out_html =~ s/(<th[^>]*)class=\w+\s?/$1/g ;
  $out_html =~ s/<td\s+>/<td>/g ;
  $out_html =~ s/<th\s+>/<th>/g ;

  # restore alignment for first cells (header)
  $out_html =~ s/<td>/<td class=l>/ ;
  $out_html =~ s/<td>/<td class=r>/ ;
  $out_html =~ s/<td>/<td class=l>/ ;

  my $file_html = $path_out . "TablesRecentTrends.htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub GenerateComparisonTableHeaders
{
  &LogT ("\nGenerateComparisonTableHeaders") ;

  my $f = shift ;
  my $link = shift ;
  my $line_languages = &tdlb (($f ne 12)? "&nbsp;":"<font color='#007733'>K=".$out_kilobytes.", M=".$out_megabytes."</font>") . "\n" ;

  if ($javascript)
  { $line_languages .= "\n<script language='javascript'>\n" ; }
  my $columns = 0 ;
  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ;}

#   if ($wp =~ /^zzz?$/)
#   {
#     $line_languages .= &tdc (&b (&w ("<a href='TablesWikipediaZZ.htm' " .
#                                      "OnMouseOver=\"ShowCellTopLeft ('$out_language', 'blue','small');\" " .
#                                      "OnMouseOut=\"ShowCellTopLeft ('$out_language', '#ffdead','small');\">" .
#                                      "<font color='#400040'>&Sigma;</font></a> "))) ;
#   }
#   else
#   {
      $wpc = $wp ;
      #if ($wp eq "simple")
      #{ $wpc = "se" ; }
      if ($wp eq "zz")
      { $wpc = "&Sigma;" ; }
      if (length ($wpc) > 7)
      { $wpc = "<small>$wpc</small}" ; }

      my $out_language = $out_languages {$wp} ;
      $out_language =~ s/\'/&#27;/g ;
      if ($link)
      {
        if ($javascript)
        { $line_languages .= "ll1('" . uc ($wp) . "','$out_language','$wpc');\n" ; }
        else
        {
          $line_languages .= &tdcb (&b (&w ("<a href='TablesWikipedia".uc ($wp).".htm' " .
                                            "title='$out_language'" .
                                            ">".$wpc."</a>"))) . "\n" ;
        }
      }
      else
      {
        if ($javascript)
        { $line_languages .= "ll2('$wpc');\n" ; }
        else
        { $line_languages .= &tdcb (&b (&w ($wpc))) ; }
      }
  }
  if ($javascript)
  { $line_languages .= "\n<\/script>\n" ; }
  $out_html .= &trh ($line_languages) ;
}

sub GenerateComparisonTableHeadersCascade
{
  &LogT ("\nGenerateComparisonTableHeadersCascade") ;

  my $f     = shift ;
  my $link  = shift ;
  my $wpmax = shift ;
  my $wpcnt = 0 ;

# my $line = &thcnb  (($f ne 12)? "&nbsp;":"<font color='#007733'>K=".$out_kilobytes.", M=".$out_megabytes."</font>") . "\n" ;
  my $line = &thebl ;
  my $out_language ;
  my $header ;

  $columns = 0 ;
  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }

    if ($wpcnt++ > $wpmax)
    { last ; }

    $columns++ ;
  }

  my $rows = 3 ;
  for ($row = 0 ; $row < $rows ; $row++)
  {
    $column = 0 ;
    $done   = 0 ;
    $wpcnt  = 0 ;
    for (my $r = $row - 1 ; $r > 0 ; $r--)
    {
      $line .= &th ("&nbsp;") . "\n" ;
      $done ++ ;
    } # was &thcnb

    if ($javascript)
    { $line .= "\n<script language='javascript'>\n" ; }

    foreach my $wp (@languages)
    {
      if ($skip {$wp}) { next ;}

      if ($wpcnt++ > $wpmax)
      { last ; }

      if (($wikimedia) || ($wp eq "zz"))
      { $out_language = $out_languages {$wp} ; }
      else
      { $out_language = $wp ; }

      if ($out_language eq '')
      { $out_language = "($wp)" ; }
      $out_language =~ s/\'/&#39;/g ;

      if ($column % $rows == $row)
      {
        if ($link)
        { $header = &b ("<a href='TablesWikipedia".uc ($wp).".htm'><small>$out_language</small></a>") ; }
        else
        { $header = &b ("<small>$out_language</small>") ; }
        $wpu = uc($wp) ;

        if (($row == 0) && ($wp eq "zz"))
        {
          if ($javascript)
          { $line .= "thl2nb('$wpu','$out_language');" ; }
          else
          { $line .= &thl2nb ($header) ; }
          $done += 2 ;
        }
        elsif ($columns - $column == 1)
        {
          if ($javascript)
          { $line .= "thcnb('','');thcnb('$wpu','$out_language');" ; }
          else
          { $line .=  &thcnb ("&nbsp;") . &thcnb ($header) ; }
          $done += 2 ;
        }
        elsif ($columns - $column == 0)
        {
          if ($javascript)
          { $line .= "thcnb('$wpu','$out_language');" ; }
          else
          { $line .= &thcnb ($header) ; }
          $done ++ ;
        }
        else
        {
          if ($javascript)
          { $line .= "thcxnb('$rows','$wpu','$out_language');" ; }
          else
          { $line .= &thcxnb ($rows, $header) ; }
          $done += $rows ;
        }
        $line .= "\n" ;

      }
      $column++ ;
    }

    if ($javascript)
    { $line .= "\n<\/script>\n" ; }

    while ($done++ < $columns)
    { $line .= &thcnb ("&nbsp;")."\n" ; }

    $out_html .= &trh ($line) ;
    $line = &thebl . "\n" ;
  }
}

sub GenerateComparisonTableMonthlyData
{
  &LogT ("\nGenerateComparisonTableMonthlyData") ;

  my $m0 = shift ;
  my $f  = shift ;
  my $mg = shift ;
  my $wpmax = shift ;
  my $rowspan = shift ;
  my $usecolors = shift ;

  my $line_html ;
  my @first ;
  my ($value, $value0, $trend, $rank) ;

  $fc = ",6,7,8,9,10,19,20," ;
  $show_forecasts_here = ($show_forecasts && (! ($fc =~ m/,$f,/))) ;

  $line_csv = "" ;

  my $m0b = 99999 ;
  foreach my $wp (@languages)
  {
    $first {$wp} = $dumpmonth_ord ;
    for (my $m = $dumpmonth_ord ; $m >= $m0 ; $m--)
    {
      if ($MonthlyStats {$wp.$m.$c[$f]} > 0)
      { $first {$wp} = $m ; }
    }
    if ($first {$wp} < $m0b)
    { $m0b = $first {$wp} ; }
  }

  $m0 = $m0b ;

  for (my $m = $dumpmonth_ord ; $m >= $m0 ; $m--)
  {

    $line_html = '' ;
    if (($m % 12 == 0) && ($m < $dumpmonth_ord) && ($m > $m0))
    {
      if ($javascript)
      {
        $out_html .= "\n<script language='javascript'>\n" .
                     "trc('#ffdead');\n" .
                     "<\/script>\n" ;
      }
      else
      { $out_html .= "<tr bgcolor='#ffdead'>" ; }

      $out_html .= "<td class='thin' colspan=333 >" .
                   "<img src='../blanco.gif' width='100%' height='1' alt=''></td></tr>" ;
    }

    if ($m == $dumpmonth_ord)
    { $line_html = "\n\n<!-- extra spaces in next row to ensure minimal column width, to make 3 cell centered title more or less above the proper column-->\n\n" ; }

    $cell_html = &td ((($m == $mg) ? "<img src='../yellowbar.gif' width='3' height='10' alt=''>" .
                                     "<img src='../blanco.gif' width='1' height='1' alt=''>" .
                                     "<img src='../greenbar.gif' width='3' height='7' alt=''>&nbsp;" : "") .
                        &GetDateShort2 ($m)) ;

    $line_html .= $cell_html ;
    if (($m == $dumpmonth_ord) && ($show_forecasts_here))
    { &StoreHtmlPageviewsAllProjects ('', "forecast,header", $cell_html) ; }
    else
    { &StoreHtmlPageviewsAllProjects ('', "monthly,header_$m", $cell_html) ; }

    $line_csv  = &csv (&m2mmddyyyy ($m)) ;
    $data_found = $false ;

    if ($javascript)
    { $line_html .= "\n<script language='javascript'>\n" ; }

    my $wpcnt = 0 ;

    if ($pageviews)
    {
      undef %pageviews ;
      foreach my $wp (@languages)
      {
        next if $skip {$wp} ;
        next if $wp eq "zz" ;
        $pageviews {$wp} = $MonthlyStats {$wp.$m.$c[$f]} ;
      }

      $rank = 1 ;
      foreach my $wp (keys_sorted_by_value_num_desc %pageviews)
      { $ranking_by_pageview {$wp} = $rank++ ; }
    }

    foreach my $wp (@languages)
    {
      if ($skip {$wp}) { next ; }

      if ($wpcnt++ > $wpmax) { last ; }

      $value = 0 ;
      $share = "" ;
# $value = $MonthlyStats {$wp.$m.$c[$f]} ;
      if ($m <= $MonthlyStatsWpStop {$wp})
      {
        $value = $MonthlyStats {$wp.$m.$c[$f]} ;

        $total = $MonthlyStats {"zz".$m.$c[$f]} ;
        $share = "--" ;
        if ($total > 0)
        { $share = sprintf ("%.2f",100*$value/$total). "%" ; }

        if ($pageviews)
        {
          if ($wp eq "zz")
          { $rank = "--" ; }
          else
          {
            $rank = $ranking_by_pageview {$wp} ;
               if ($rank == 1) { $rank .=  'st' ; }
            elsif ($rank == 2) { $rank .=  'nd' ; }
            elsif ($rank == 3) { $rank .=  'rd' ; }
            else               { $rank .=  'th' ; }
          }
        }
      }

      if (($m < $MonthlyStatsWpStop {"zz"}) &&
          (($m == $MonthlyStatsWpStop {$wp}) && $MonthlyStatsWpIncomplete {$wp}))
      { $value = 0 ; }
      if ($value != 0)
      { $data_found = $true ; }
      $value0 = $value ;

      if ($m == $mg)
      {
        $value2 = $value ;
        $value2 =~ s/\%// ;
        if ($value2 > $maxf1 [$f])
        { $maxf1 [$f] = $value2 ; }
        if (($wp ne "zz") && ($value2 > $maxf2 [$f]))
        { $maxf2 [$f] = $value2 ; }
      }

      $line_csv  .= &csv ($value) ;
      if ($pageviews)
      { $value = &format($value,'E') ; }
      else
      { $value = &format($value,$c[$f]) ; }
      $value =~ s/M./M/ ;
      $value =~ s/K./K/ ;
      $value2 = $value ;

      if ($m == $dumpmonth_ord) # ensure minimal width for column , to make 3 cell centered title more or less above the column
      {
        $value =~ s/\&nbsp\;/ /g ;
        while (length ($value) < 7)
        { $value = "*" . $value ; }
        $value =~ s/\*\*/&nbsp;&nbsp;&nbsp;/g ;
        $value =~ s/\*/&nbsp;/g ;
      }

      $nocolor = ((! $usecolors) || ($m == $dumpmonth_ord) && $dumpmonth_incomplete && $show_forecasts) ;

      if (($colormode eq 'X') || $nocolor)
      {
        if ($javascript)
        { $cell_html = "tdg('$value');" ; } # was tdnc
        else
        { $cell_html = "<td>$value</td>" ; }

        $line_html .= $cell_html ;
        if (($m == $dumpmonth_ord) && ($show_forecasts_here))
        { &StoreHtmlPageviewsAllProjects ($wp, "forecast,data", $cell_html) ; }
        else
        { &StoreHtmlPageviewsAllProjects ($wp, "monthly,data_$m", $cell_html) ; }

        next ;
      }

      if (($m < $first {$wp}) || (! defined ($value0))) # ($value !~ /\d/))
      {
        if ($javascript)
        { $line_html .= "tdg('');" ; }
        else
        { $line_html .= "<td bgcolor=#C0C0C0>&nbsp;</td>" ; }
        next ;
      }

      if ($colormode eq 'A')
      {
        $trend = $MonthlyStats {$wp.$m.$c[$f].'p'} ;
        $trend2 = $trend ;
        $color = &BgColor ('A', $trend) ;

        if (($trend2 =~ /\%/) && ($trend2 !~ /\-\-\%/))
        {
          if ($javascript)
          { $line_html .= "tdc('$color','$trend2','$value');" ; }
          else
          { $line_html .= "<td bgcolor=$color><span class=d1>$trend2</span> <span class=d2>$value</span></td>" ; }
        }
        else
        {
          if ($javascript)
          { $line_html .= "tdg('$value');" ; }
          else
          { $line_html .= "<td bgcolor=#C0C0C0>$value</td>" ; }
        }
        next ;
      }

      if ($colormode eq 'B')
      {
        $trend = $MonthlyStats {$wp.$m.$c[$f]} ; # no percentage here, just the absolute figure
        $trend2 = $trend ;
        $color = &BgColor ('B', $trend) ;
        if ($javascript)
        { $line_html .= "tdc('$color','','$value');" ; }
        else
        { $line_html .= "<td bgcolor=$color>$value</td>" ; }
        next ;
      }

      if ($colormode eq 'C')
      {
        $trend = $MonthlyStats {$wp.$m.$c[$f].'p'} ;

        if (($trend =~ /\%/) && ($trend !~ /\-\-\%/))
        {
          $color = &BgColor ('C', $trend) ;

          if ($javascript)
          { $line_html .= "tdc('$color','$trend','$value');" ; }
          else
          { $line_html .= "<td bgcolor=$color><span class=d1>$trend</span> <span class=d2>$value</span></td>" ; }
        }
        else
        {
          if ($javascript)
          { $line_html .= "tdg('$value');" ; } # was tdng
          else
          { $line_html .= "<td>$value</td>" ; }
        }
        next ;
      }

      if ($colormode eq 'D')
      {
        if ($value0 == 0)
        { $value = "0%" ; }
        $color = &BgColor ('D', $value0, $c[$f]) ;

        if ($javascript)
        { $line_html .= "tdc('$color','','$value');" ; }
        else
        { $line_html .= "<td bgcolor=$color>$value</td>" ; }
      }

      if ($colormode eq 'E')
      {
        $trend = $MonthlyStats {$wp.$m.$c[$f]} ; # no percentage here, just the absolute figure
        $trend2 = $trend ;
        $color = &BgColor ('E', $trend) ;
        if ($javascript)
        { $line_html .= "tdc('$color','','$value');" ; }
        else
        { $line_html .= "<td bgcolor=$color>$value</td>" ; }
        next ;
      }

      if ($colormode eq 'F')
      {
        $trend = $MonthlyStats {$wp.$m.$c[$f]} ; # no percentage here, just the absolute figure
        $trend2 = $trend ;
        $color = &BgColor ('F', $trend) ;
        if ($javascript)
        { $line_html .= "tdc('$color','','$value');" ; }
        else
        { $line_html .= "<td bgcolor=$color>$value</td>" ; }
        next ;
      }

      if ($colormode =~ /[GHI]/) # I also for pageviews
      {
        $trend = $MonthlyStats {$wp.$m.$c[$f].'p'} ;

        if (($trend =~ /\%/) && ($trend !~ /\-\-\%/))
        {
          $color = &BgColor ($colormode, $trend) ;

          if (($pageviews) and ($share ne ""))
          { $trend .= ", $share" ; }
          if (($pageviews) and ($rank ne ""))
          { $trend .= ", $rank" ; }

          if ($javascript)
          { $cell_html = "tdc('$color','$trend','$value');" ; }
          else
          { $cell_html = "<td bgcolor=$color><span class=d1>$trend</span> <span class=d2>$value</span></td>" ; }

          $line_html .= $cell_html ;

          if (($m == $dumpmonth_ord) && ($show_forecasts_here))
          { &StoreHtmlPageviewsAllProjects ($wp, "forecast,data", $cell_html) ; }
          else
          { &StoreHtmlPageviewsAllProjects ($wp, "monthly,data_$m", $cell_html) ; }
        }
        else
        {
          if ($javascript)
          { $cell_html = "tdg('$value');" ; } # was tdng
          else
          { $cell_html = "<td>$value</td>" ; }

          $line_html .= $cell_html ;
          if (($m == $dumpmonth_ord) && ($show_forecasts_here))
          { &StoreHtmlPageviewsAllProjects ($wp, "forecast,data", $cell_html) ; }
          else
          { &StoreHtmlPageviewsAllProjects ($wp, "monthly,data_$m", $cell_html) ; }
        }
        next ;
      }
    }


    if ($javascript)
    { $line_html .= "\n</script>\n" ; }

    if (($m == $dumpmonth_ord) && ($show_forecasts_here))
    {

      $line_html  = &tr ($line_html) ;
      if ($javascript)
      {
        $line_html .= "\n<script language='javascript'>\n" .
                      "trc('#ffdead');\n" .
                      "<\/script>\n" ;
      }
      else
      { $line_html .= "<tr bgcolor='#ffdead'>" ; }

      $line_html .= "<td class=lb colspan=333 >" .
                    "<img src='../black.gif' width='1' height='1' alt=''></td></tr>" ;
      $out_html .= $line_html ;

      &GenerateComparisonTableForecasts ($f, $wpmax) ;
    }
    else
    {
      if ($data_found)
      {
        $out_html .= &tr ($line_html) ;
        if ((! $pageviews) && $wikimedia && $mode_wp  && ($dumpmonth_ord - $m0 >= 36) && (($dumpmonth_ord - $m) % 12 == 0))
        {
          $line_html =~ s/tdc\([^,]*,[^,]*,([^,]*)\)/tdg\($1\)/g ;
          $line_html =~ s/tdg\(([^\)]*)\)\;/<td>$1<\/td>/g ;
          $line_html =~ s/<\/?script[^>]*>//g ;
          $line_html =~ s/\'//g ;
          $line_html =~ s/(?:\&nbsp;){2,}//g ;
          $out_html_yearly .= &tr ($line_html) ;
        }
      }
    }

    $line_csv =~ s/\,$/\n/ ;
    $out_csv .= $line_csv ;
  }
}

sub GenerateComparisonTableMaxData
{
  &LogT ("\nGenerateComparisonTableMaxData") ;

  my $f  = shift ;
  if ($f > 0) { return ; }

  if ($javascript)
  {
    $out_html .= "\n<script language='javascript'>\n" .
                 "trc('#ffdead');\n" .
                 "<\/script>\n" .
                 "<td class=lb colspan=333 >&nbsp;</td>\n" .
                 "<\/tr>\n" ;
  }
  else
  { $out_html .= "<tr bgcolor='#ffdead'><td class=lb colspan=333 >&nbsp;</td></tr>" ; }

  if ($out_max eq "")
  { $out_max = 'Max' ; }

  $line_html = &td ($out_max) ;
  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }

    $value = "<small>" . &GetDateShort2 ($MonthlyStatsHighMonth {$wp.$c[$f]}). "</small>" .
             "<br>" . &b (&format ($MonthlyStatsHigh {$wp.$c[$f]}, 'E')) ;
    $line_html .= &td ($value) ;
  }

  $out_html .= &tr ($line_html) ;
}

sub GenerateComparisonTableSparklines
{
  &LogT ("\nGenerateComparisonTableSparklines") ;

  my $f  = shift ;
  if ($f > 0) { return ; }

  $sparkline  = "<script type='text/javascript'>\n" .
                "/* <![CDATA[ */\n" .
                "\$(function() {\n" ;
  for ($sid= 0 ; $sid < 150 ; $sid++)
  { $sparkline .= "\$('#sparkline$sid').sparkline([1,223,6433,35,867,245,43,76,65,5,8,8,43,43,34,43,43,436,5,7,2],{type:'bar',barSpacing:0,barWidth:1});\n" ; }
  $sparkline .= "});\n" .
                "/* ]]> */\n" .
                "</script>\n" ;

  if ($javascript)
  {
    $out_html .= "\n<script language='javascript'>\n" .
                 "trc('#ffdead');\n" .
                 "<\/script>\n" .
                 "<td class=lb colspan=333 >&nbsp;</td>\n" .
                 "<\/tr>\n" ;
  }
  else
  { $out_html .= "<tr bgcolor='#ffdead'><td class=lb colspan=333 >&nbsp;</td></tr>" ; }

  if ($out_trend eq "")
  { $out_trend = 'Trend' ; }

  $line_html = &td ($out_trend) ;
  $sid = 0 ;
  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }
    $value = "<span id=sparkline$sid>Loading..</span>\n" ;
    $line_html .= &td ($value) ;
    if ($sid++ > 150)
    { last ; }
  }

  $out_html .= &tr ($line_html) ;
  $out_html .= $sparkline ;
}

sub GenerateComparisonTableSparklinesWithBars
{
  &LogT ("\nGenerateComparisonTableSparklinesWithBars") ;

  my $f  = shift ;
  if ($f > 0) { return ; }

  $javascript_ = $javascript ;
  $javascript  = $true ;

  if ($out_trend eq "")
  { $out_trend = 'Top month<p>&nbsp;<p>Trend last<br>24 months' ; }

  &StoreHtmlPageviewsAllProjects ('zz',"sparklines,header", &td ($out_trend)) ;

  $line_html = &td ($out_trend) ;
  my $wpcnt = 0 ;
  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }
  # if (++$wpcnt > 50) { last ; }
  # if ($MonthlyStatsHigh {$wp.$c[0]} < 1000000) { next ; } # show selectively to reduce page size

    $m2 = $dumpmonth_ord ;
    $m1 = $m2 - 24 ;
    $m0 = $MonthlyStatsWpStart {$wp} ;

    if ($dumpmonth_incomplete)
    { $m2 -- ; }
    if ($m1 < $m0) { $m1 = $m0 ; }

    $views_lo = 999999999999 ;
    $views_hi = 0 ;
    for ($m = $m2 ; $m >= $m1 ; $m--)
    {
      $views = $MonthlyStats {$wp.$m.$c[$f]} ;
      if ($views < $views_lo) { $views_lo = $views ; }
      if ($views > $views_hi) { $views_hi = $views ; }
    }
    $views_range = $views_hi - $views_lo + 1 ;

    $value1 = "<small>" . &GetDateShort2 ($MonthlyStatsHighMonth {$wp.$c[$f]}).
              "<br>" . &b (&format ($MonthlyStatsHigh {$wp.$c[$f]}, 'E')) . "<br>&nbsp;<br></small>" ;

    if ($javascript)
    { $value2 = "b1();" ; }
    else
    { $value2 = "<img src='../blanco.gif' width=3 height=1>" ; }

    for ($m = $m2 ; $m >= $m1 ; $m--)
    {
      $views  = $MonthlyStats {$wp.$m.$c[$f]} ;
    # $height =  sprintf ("%.0f", (($views - $views_lo) / $views_range) * 20) + 1 ;
      $height = 0 ;
      if ($views_hi > 0)
      { $height =  sprintf ("%.0f", (($views / $views_hi) * 50)) + 1 ; }
#     if ($views eq "") { last ; }
      if ($views == $views_hi)
      { $img = "black.gif" ; }
      else
      { $img = "grey.gif" ; }

      if ($javascript)
      {
      # if ($views == $views_hi)
      #  { $value2 = "b1();b2a(3,$height);" . $value2 ; }
      # else
      # { $value2 = "b1();b2b(3,$height);" . $value2 ; }
        if ($views == $views_hi)
        { $value2 = "b1(1);b2a(2,$height);" . $value2 ; }
        else
        { $value2 = "b1(1);b2b(2,$height);" . $value2 ; }
      }
      else
      {
      # $value2 = "<img src='../$img' width=3 height=$height>" . $value2 ; # $m2 -> $m1 = right to left
      # $value2 = "<img src='../blanco.gif' width=3 height=1>" . $value2 ;
        $value2 = "<img src='../$img' width=2 height=$height>" . $value2 ; # $m2 -> $m1 = right to left
        $value2 = "<img src='../blanco.gif' width=1 height=1>" . $value2 ;
      }
    }
    $value2 .= "\n" ;

    if ($javascript)
    { $cell_html = &tdc ("<center>$value1\n<script language='javascript'>\n$value2</script>\n</center>") . "\n" ; }
    else
    { $cell_html = &tdc ("<center>$value1$value2</center>") . "\n" ; }

    $line_html .= $cell_html ;
    &StoreHtmlPageviewsAllProjects ($wp,"sparklines,data", $cell_html) ;
  }

  $out_html .= &tr ($line_html) ;

  $javascript = $javascript_ ;
}

sub GenerateComparisonTableViewRates
{
  &LogT ("\nGenerateComparisonTableViewRates") ;

  my $f  = shift ;
  if ($f > 0) { return ; }

  $m = $dumpmonth_ord ;
  if ($dumpmonth_incomplete)
  { $m -- ; }
  $cell_html = &tdrb ("<small>".&GetDateShort2 ($m) . "<br>../day<br>../hour<br>../min<br>../sec</small>") ;

  $line_html = $cell_html ;
  &StoreHtmlPageviewsAllProjects ('zz',"view_rates,header", $cell_html) ;

  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }

    $pageviews = $MonthlyStats {$wp.$m.$c[$f]} ;
    my $year    = int (($m - 1) / 12) ;
    my $month   = $m - $year * 12 ;
    $daysinmonth    = days_in_month (2000+$year, $month) ;

    $pageviews_day  = $pageviews / 30 ;
    $pageviews_hour = $pageviews_day / 24 ;
    $pageviews_min  = $pageviews_day / (24 * 60) ;
    $pageviews_sec  = $pageviews_day / (24 * 60 * 60) ;

    $pageviews      = &format($pageviews,'X') ;
    $pageviews_day  = &format($pageviews_day,'X') ;
    $pageviews_hour = &format($pageviews_hour,'X') ;
    $pageviews_min  = &format($pageviews_min,'X') ;
    $pageviews_sec  = &format($pageviews_sec,'X') ;
#    if ($pageviews_day > 5)
#    { $pageviews_day = sprintf ("%.0f", $pageviews_day) ; }
#    else
#    { $pageviews_day = sprintf ("%.1f", $pageviews_day) ; }
#    if ($pageviews_hour > 5)
#    { $pageviews_hour = sprintf ("%.0f", $pageviews_hour) ; }
#    else
#    { $pageviews_hour = sprintf ("%.1f", $pageviews_hour) ; }
#    if ($pageviews_min > 5)
#    { $pageviews_min = sprintf ("%.0f", $pageviews_min) ; }
#    else
#    { $pageviews_min = sprintf ("%.1f", $pageviews_min) ; }
#    if ($pageviews_sec < 0.1)
#    { $pageviews_sec = sprintf ("%.2f", $pageviews_sec) ; }
#    elsif ($pageviews_sec < 5)
#    { $pageviews_sec = sprintf ("%.1f", $pageviews_sec) ; }
#    else
#    { $pageviews_sec = sprintf ("%.0f", $pageviews_sec) ; }
#    if ($pageviews_sec >= 1)
#    { $line_html .= &td ("<small>$pageviews /mon<br>$pageviews_day /day<br>$pageviews_hour /hr&nbsp;&nbsp;<br>$pageviews_min /min<br>$pageviews_sec /sec</small>") ; }
#    else
#    { $line_html .= &td ("<small>$pageviews /mon<br>$pageviews_day /day<br>$pageviews_hour /hr&nbsp;&nbsp;<br>$pageviews_min /min<br>&nbsp;</small>") ; }

    if ($pageviews_sec >= 1)
    { $cell_html = &tdc ("<small>$pageviews &nbsp;&nbsp;&nbsp;<br>$pageviews_day /d<br>$pageviews_hour /h<br>$pageviews_min /m<br>$pageviews_sec /s&nbsp;</small>") ; }
    elsif ($pageviews_min >= 1)
    { $cell_html = &tdc ("<small>$pageviews &nbsp;&nbsp;&nbsp;<br>$pageviews_day /d<br>$pageviews_hour /h<br>$pageviews_min /m<br>&nbsp;</small>") ; }
    else
    { $cell_html = &tdc ("<small>$pageviews &nbsp;&nbsp;&nbsp;<br>$pageviews_day /d<br>$pageviews_hour /h<br>&nbsp;<br>&nbsp;</small>") ; }

    $line_html .= $cell_html ;
    &StoreHtmlPageviewsAllProjects ($wp,"view_rates,data", $cell_html) ;
  }

  $out_html .= &tr ($line_html) ;

#  if ($javascript)
#  {
#    $out_html .= "\n<script language='javascript'>\n" .
#                 "trc('#ffdead');\n" .
#                 "<\/script>\n" .
#                 "<td class=lb colspan=333 >&nbsp;</td>\n" .
#                 "<\/tr>\n" ;
#  }
#  else
#  { $out_html .= "<tr bgcolor='#ffdead'><td class=lb colspan=333 >&nbsp;</td></tr>" ; }
}

sub GenerateComparisonTableYearlyGrowth
{
  &LogT ("\nGenerateComparisonTableYearlyGrowth") ;

  my $f  = shift ;
  if ($f > 0) { return ; }

  $m1 = $dumpmonth_ord ;
  if ($dumpmonth_incomplete)
  { $m1 -- ; }
  $m2 = $m1 - 12 ;

  if ($MonthlyStats {'zz'.$m1.'yg'} eq "") { return ; } # no full year of data yet

  if ($javascript)
  {
    $line_html = "\n<script language='javascript'>\n" .
                 "trc('#ffffdd');\n" .
                 "<\/script>\n" ;
  }
  else
  { $line_html = "<tr bgcolor='#ffffdd'>" ; }

  $cell_html = &tdr ("<small>".&GetDateShort2 ($m2) . "<br>&rArr; " . &GetDateShort2 ($m1) . "</small>") ;

  $line_html .= $cell_html ;
  &StoreHtmlPageviewsAllProjects ('zz', "year_trend,header", $cell_html) ;

  if ($javascript)
  { $line_html .= "\n<script language='javascript'>\n" ; }

  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }
    if ($wp eq "zz") { next ; }

    my $yearlytrend = $MonthlyStats {$wp.$m1.'yg'} ;
    if (($yearlytrend =~ /\(/) || ($yearlytrend < 1000))
    { $yearlytrends {$wp} = $yearlytrend ; }
  }

  $rankyearlytrends = 1 ;
  foreach $wp (sort {$yearlytrends {$b} <=> $yearlytrends {$a}} keys %yearlytrends)
  {
    if ($wp eq "zz") { next ; }

    my $yearlytrend = $MonthlyStats {$wp.$m1.'yg'} ;

    if ($yearlytrend eq "n.a.") # no previous data at all ?
    { $yearlytrendsranked {$wp} = "n.a." ; }
    else
    { $yearlytrendsranked {$wp} = $rankyearlytrends ++ ; }
  }

  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }

    my $yearlytrend = $MonthlyStats {$wp.$m1.'yg'} ;

    if ($yearlytrend eq "n.a.") # no previous data at all ?
    { ; }
    elsif ($yearlytrend =~ /\(/) # less than 12 months data ?
    {
      $yearlytrend =~ s/[\(\)]//g ;
      if ($yearlytrend >= 0)
      { $yearlytrend = "+$yearlytrend%" ; }
      else
      { $yearlytrend = "$yearlytrend%" ; }
      $yearlytrend = "<small>[$yearlytrend]</small>" ;
    }
    else
    {
      if ($yearlytrend >= 0)
      { $yearlytrend = "+$yearlytrend%" ; }
      else
      { $yearlytrend = "$yearlytrend%" ; }
    }

    $rank = $yearlytrendsranked {$wp} ;
       if ($rank eq "n.a.") { ; }
    elsif ($wp eq "zz") { $rank = "&nbsp;" ; }
    elsif ($rank eq "") {;}
    elsif ($rank == 1)  { $rank .= 'st' ; }
    elsif ($rank == 2)  { $rank .= 'nd' ; }
    elsif ($rank == 3)  { $rank .= 'rd' ; }
    else                { $rank .= 'th' ; }

    $color = &BgColor ('I', $yearlytrend) ;
    if ($javascript)
    { $cell_html = "tdc('$color','$rank','$yearlytrend');" ; }
    else
    { $cell_html = "<td bgcolor=$color><span class=d1>$yearlytrend</span> <span class=d2>$yearlytrend</span></td>" ; }

    $line_html .= $cell_html ;
    &StoreHtmlPageviewsAllProjects ($wp, "year_trend,data", $cell_html) ;

  # $line_html .= &tdc ("$yearlytrend") ;
  }

  if ($javascript)
  { $line_html .= "\n<\/script>\n" ; }
  $line_html .= "</tr>\n" ;

  $out_html .= $line_html ;
# $out_html .= "<tr><td colspan=333 class=cb height=8></td></tr>" ;
}

sub GenerateComparisonTableMonthlyTrends
{
  &LogT ("\nGenerateComparisonTableMonthlyTrends") ;

  my $f = shift ;
  my $line_html ;
  my ($m, $m1, $m2) ;
  $show_colors_perc = $false ;

  if (($f == 0) || ($f == 2) || (($mode_wp) && ($f == 3)) || (($f >= 4) && ($f <= 6)) || ($f >= 11))
  {
    $show_colors_perc = $true ;
    $prefix = "" ;
    $m2 = $dumpmonth_ord ;
    if ((! $show_forecasts) && $dumpmonth_incomplete)
    { $m2 -- ; }
    $m1 = $m2 - 5 ;
    for ($m = $m2 ; $m >= $m1 ; $m--)
    {
      if (($m == $dumpmonth_ord) && $dumpmonth_incomplete && $show_forecasts)
      {
        $prefix = "<font color='#606060'>&plusmn;<\/font>&nbsp;" ;
        $line_html = &td (&GetDateShort (sprintf ("%02d/%02d/%04d", $dumpmonth, days_in_month ($dumpyear, $dumpmonth), $dumpyear))) ; # was &tdrb
      }
      else
      {
        $prefix = "" ;
        $line_html = &td (&GetDateShort2 ($m)) ;
      } # was &tdrb

      $lineallzero = $true ;
      foreach my $wp (@languages)
      {
        if ($skip {$wp}) { next ; }

        undef ($value) ;
        if ($m <= $MonthlyStatsWpStop {$wp})
        { $value = $MonthlyStats {$wp.$m.$c[$f].'p'} ; }
        if (($m == $MonthlyStatsWpStop {$wp}) && $MonthlyStatsWpIncomplete {$wp})
        { undef ($value) ; }

        if (defined ($value))
        {
          $lineallzero = $false ;
          $value = $prefix . $value ;
        }
        # $value = &format($value,$c[$f]) ;
        $line_html .= &td (&sign ($value)) ;
      }

      if (! $lineallzero)
      {
        if ($javascript)
        {
          $line_html =~ s/\'/&#27;/g ;
          $line_html = &tr ($line_html) ;
          $line_html =~ s/\n//gs ;
          $out_html .= "\n<script language='javascript'>\n" .
                       "showOnNoPercentages('$line_html');\n" .
                       "<\/script>\n" ;
        }
        else
        { $out_html .= &tr ($line_html) ; }
      }
    }

    if ($javascript)
    {
      $out_html .= "\n<script language='javascript'>\n" .
                   "trc('#ffdead');\n" .
                   "showOnNoPercentages('<td class=lb colspan=333 >&nbsp;</td></tr>');\n" .
                   "<\/script>\n" ;
    }
    else
    { $out_html .= "<tr bgcolor='#ffdead'><td class=lb colspan=333 >&nbsp;</td></tr>" ; }
  }

}

sub GenerateComparisonTableForecasts
{
  &LogT ("\nGenerateComparisonTableForecasts") ;

  my $f = shift ;
  my $wpmax = shift ;

  my $line_html ;

  my $m = $dumpmonth_ord + 1 ;

  $cell_html = &tdrb (&GetDateShort (
                      sprintf ("%02d/%02d/%04d", $dumpmonth, days_in_month ($dumpyear, $dumpmonth), $dumpyear)
                      )) ;
  $line_html .= $cell_html ;
  &StoreHtmlPageviewsAllProjects ('', "forecast2,header", $cell_html) ;

  if ($pageviews && $javascript)
  { $line_html .= "\n<script language='javascript'>\n" ; }

  my $wpcnt = 0 ;
  foreach my $wp (@languages)
  {
    if ($wpcnt++ > $wpmax) { last ; }

    if ($skip {$wp}) { next ; }

    $forecast = $MonthlyStats {$wp.$m.$c[$f]} ;

    if ($forecast < 25)
    {
      if ($pageviews)
      { $line_html .= "tdnc ('$nbsp');" ; }
      else
      { $line_html .= &tdeb ; }
    }
    else
    {
      $forecast = &format($forecast,$c[$f]) ;
      $forecast =~ s/M./M/ ;
      $forecast =~ s/K./K/ ;
#      if ($wp eq "zz")
#      { $line_html .= &tdrs ("<font color='#606060'>&plusmn;<\/font>&nbsp;" . $forecast) ; }
#      else
#      { $line_html .= &tdrb ("<font color='#606060'>&plusmn;<\/font>&nbsp;" . $forecast) ; }

      if ($pageviews)
      {
        $trend = $MonthlyStats {$wp.$m.$c[$f].'p'} ;   # ???
        $trend2 = $trend ;
        $color = &BgColor ('F', $trend) ;

        if ($trend2 =~ /\%/)
        {
          if ($javascript)
          { $cell_html = "tdc('$color','$trend2','&plusmn;&nbsp;$forecast');" ; }
          else
          { $cell_html = "<td bgcolor=$color><span class=d1>$trend2</span> <span class=d2>&plusmn;&nbsp;$forecast</span></td>" ; }
        }
        else
        {
          if ($javascript)
          { $cell_html = "tdg('&plusmn;&nbsp;$forecast');" ; }
          else
          { $cell_html = "<td bgcolor=#C0C0C0>&plusmn;&nbsp;$forecast</td>" ; }
        }

        $line_html .= $cell_html ;
        &StoreHtmlPageviewsAllProjects ($wp, "forecast2,data", $cell_html) ;

      }
      else
      { $line_html .= &tdrb ("<font color='#606060'>&plusmn;<\/font>&nbsp;" . $forecast) ; }
    }
  }

  if ($pageviews && $javascript)
  { $line_html .= "\n</script>\n" ; }
  $out_html .= &tr ($line_html) ;
}

sub GenerateTablePageviewsPerRange
{
  &LogT ("\nGenerateTablePageviewsPerRange") ;
# $javascript = $true ; # do without till javascript till new macro in next js version

  my ($wpfrom, $wptill, $wpcntfrom, $wpcntill, $wpheaders, $wprange1, $wprange2, $wpndx) ;

  $wpcnt  = 0 ;
  foreach $wp (@languages)
  {
    if ($wp eq "zz") { next ; }
    if ($wpcnt++ > 50) { last ; }

    if ($wpcnt == 1)
    { $wpfrom0 = $wp ; }
    if ($wpcnt % 10 == 1)
    {
      $wpfrom = $wp ;
      $wpcntfrom = $wpcnt ;
    }
    if ($wpcnt % 10 == 0)
    {
      $wptill  = $wp ;
      $wpcnttill = $wpcnt ;
      $wprange1 [$wpndx] = "$wpfrom .. $wptill" ;
      $wprange2 [$wpndx] = "$wpcntfrom .. $wpcnttill" ;
      $wprange3 [$wpndx] = "$wpfrom0 .. $wptill" ;
      $wprange4 [$wpndx] = "1 .. $wpcnttill" ;
      $wpndx++ ;
    }
  }
  if (($wpcnt > 50) || ($wpcnt % 10 != 0))
  {
    $wprange1 [$wpndx] = "$wpfrom .. " . $languages [$#languages] ;
    $wprange2 [$wpndx] = "$wpcntfrom .. " . $#languages ; # $#languages+1 for all elements - 1 for "zz"
    $wprange3 [$wpndx] = "$wpfrom0 .. " . $languages [$#languages] ;
    $wprange4 [$wpndx] = "1 .. " . $#languages ; # $#languages+1 for all elements - 1 for "zz"
    $wpndx++ ;
  }

  if ($region eq '')
  {
    $out_html .= "<p>&nbsp;<hr>&nbsp;<h3>Distribution of page views</h3>" ;

    $out_html .= "<table border=0><tr>" ;
    $out_html .= &td ("<span class=d1>x%</span><span class=d2>y%</span>") ;
    $out_html .= &td ("<span class=d1>x%=cumulative share (including previous columns)<br>y%=share of page views for this subset of languages</span>") ;
    $out_html .= "</tr></table>" ;

    $out_html .= "\n\n<p><table border=1 cellspacing=0 id=table2 style='' summary='Share of page views per wiki range'>\n" ;

    $line_html = &tde ;

    for ($wpndx2 = 0 ; $wpndx2 < $wpndx ; $wpndx2++)
    {
      $value = &b ($wprange1 [$wpndx2] . "<br>" . $wprange2 [$wpndx2]) ;
      $line_html .= &tdcb ($value) ;
    }

    $line_html2 = $line_html ;
    $out_html .= &trh5b ($line_html) ;

    $javascript_ = $javascript ;
    $javascript  = $true ;

    $m1 = $dumpmonth_ord ;
    $m2 = $MonthlyStatsWpStart {"zz"} ;
    for ($m = $m1 ; $m >= $m2 ; $m--)
    {
      $line_html = '' ;
      if (($m % 12 == 0) && ($m < $dumpmonth_ord) && ($m > $m0))
      {
        if ($javascript)
        {
          $line_html .= "\n<script language='javascript'>\n" .
                       "trc('#ffdead');\n" .
                       "<\/script>\n" ;
        }
        else
        { $line_html .= "<tr bgcolor='#ffdead'>" ; }

        $line_html .= "<td class='thin' colspan=333 >" .
                     "<img src='../blanco.gif' width='100%' height='1' alt=''></td></tr>" ;
      }

      if ($m == $dumpmonth_ord)
      { $line_html = "\n\n<!-- extra spaces in next row to ensure minimal column width, to make 3 cell centered title more or less above the proper column-->\n\n" ; }

      $line_html .= &td ((($m == $mg) ? "<img src='../yellowbar.gif' width='3' height='10' alt=''>" .
                                        "<img src='../blanco.gif' width='1' height='1' alt=''>" .
                                        "<img src='../greenbar.gif' width='3' height='7' alt=''>&nbsp;" : "") .
                           &GetDateShort2 ($m)) ;

      $wpcnt  = 0 ;
      $wpndx  = 0 ;
      $total  = $MonthlyStats {"zz".$m.$c[0]} ;

    #  if ($javascript)
    #  { $line_html .= "\n<script language='javascript'>\ntdg('&nbsp;');\n" ; }
    #  else
    #  { $line_html .= &tde ; }
      foreach $wp (@languages)
      {
        if ($wp eq "zz") { next ; }
        if ($wpcnt++ > 50) { last ; }

        if ($wpcnt % 10 == 0)
        {
          if ($total != 0)
          { $perc_cum [$wpndx] = sprintf ("%.2f",100*@MonthlyStats {$wp.$m.'c'}/$total) ; }
          if ($wpndx == 0)
          { $perc_diff [$wpndx] = $perc_cum [$wpndx] ; }
          else
          { $perc_diff [$wpndx] = sprintf ("%.2f", $perc_cum [$wpndx] - $perc_cum [$wpndx-1]) ; }
          $wpndx++ ;
        }
      }
      if (($wpcnt > 50) || ($wpcnt % 10 != 0))
      {
        $perc_cum  [$wpndx] = 100 ;
        $perc_diff [$wpndx] = sprintf ("%.2f", 100 - $perc_cum [$wpndx-1]) ;
        $wpndx++ ;
      }

      if ($javascript)
      { $line_html .= "\n<script language='javascript'>\n" ; }

      for ($wpndx2 = 0 ; $wpndx2 < $wpndx ; $wpndx2++)
      {
        $value_diff = $perc_diff [$wpndx2] . '%' ;
        $value_cum  = $perc_cum  [$wpndx2] . '%' ;
        if ($javascript)
        { $line_html .= "tdc('#ffffff','$value_cum','$value_diff');" ; } # was tdnc
        else
        { $line_html .= &td ("<span class=d1>$value_cum</span><span class=d2>$value_diff</span>") ; }
      }

      if ($javascript)
      { $line_html .= "\n<\/script>\n" ; }

      $out_html .= &trh4b ($line_html) ;
    }
  }

  $out_html .= &trh5b ($line_html2) ;
  $out_html .= "</table>" ;

  $javascript = $javascript_ ;
}

sub GenerateComparisonTableEditPlots
{
  &LogT ("\nGenerateComparisonTableEditPlots") ;

  my $f  = shift ;
  if ($f > 0) { return ; }

  $m = $dumpmonth_ord ;
  if ($dumpmonth_incomplete)
  { $m -- ; }
  $line_html = &tdrb ("") ;

  foreach my $wp (@languages)
  {
    if ($skip {$wp}) { next ; }

    if ($wp =~ /^z+$/)
    { $line_html .= &tdcb ("&nbsp;") ; }
    else
    {
      my $link = "../EN/EditsReverts" . uc ($wp) . ".htm" ;
      $line_html .= &tdcb ("<small><a href='$link'><font color='#000080'>Edit Trends</font></a></small>") ;
    }
  }

  $out_html .= &tr ($line_html) ;
}

sub GenerateLinkBarRow
{
  &LogT ("\nGenerateLinkBarRow") ;

  $barndx = shift ;
  $out_links = "" ;
  if ($barndx == 1)
  {
    $out_id     = "&nbsp;" ;  # "<a id='A' name='A'>&nbsp;</a>" ;
    $out_group  = $out_tbl3_hdr1a ;
#   $out_links .= &b ($out_tbl3_hdr1a) . "&nbsp;\n" ;
    $out_links .= "<a href='\#E'>" . $out_tbl3_hdr1e . "</a> - \n" ;
    $out_links .= "<a href='\#L'>" . $out_tbl3_hdr1l . "</a> - \n" ;
    $out_links .= "<a href='\#O'>" . $out_tbl3_hdr1o . "</a> - \n" ;
    $out_links .= "<a href='\#T'>" . $out_tbl3_hdr1t . "</a>\n" ;
  }
  if ($barndx == 2)
  {
    $out_id    = "<a id='E' name='E'>&nbsp;</a>\n" ;
    $out_group  = $out_tbl3_hdr1e ;
    $out_links .= "<a href='\#0'>" . $out_tbl3_hdr1a . "</a> - \n" ;
#   $out_links .= &b ($out_tbl3_hdr1e) . "&nbsp;\n" ;
    $out_links .= "<a href='\#L'>" . $out_tbl3_hdr1l . "</a> - \n" ;
    $out_links .= "<a href='\#O'>" . $out_tbl3_hdr1o . "</a> - \n" ;
    $out_links .= "<a href='\#T'>" . $out_tbl3_hdr1t . "</a>\n" ;
  }
  if ($barndx == 3)
  {
    $out_id    = "<a id='L' name='L'>&nbsp;</a>\n" ;
    $out_group  = $out_tbl3_hdr1l ;
    $out_links .= "<a href='\#0'>" . $out_tbl3_hdr1a . "</a> - \n" ;
    $out_links .= "<a href='\#E'>" . $out_tbl3_hdr1e . "</a> - \n" ;
#   $out_links .= &b ($out_tbl3_hdr1l) . "&nbsp;\n" ;
    $out_links .= "<a href='\#O'>" . $out_tbl3_hdr1o . "</a> - \n" ;
    $out_links .= "<a href='\#T'>" . $out_tbl3_hdr1t . "</a>\n" ;
  }
  if ($barndx == 4)
  {
    $out_id     = "<a id='O' name='O'>&nbsp;</a>\n" ;
    $out_group  = $out_tbl3_hdr1o ;
    $out_links .= "<a href='\#0'>" . $out_tbl3_hdr1a . "</a> - \n" ;
    $out_links .= "<a href='\#E'>" . $out_tbl3_hdr1e . "</a> - \n" ;
    $out_links .= "<a href='\#L'>" . $out_tbl3_hdr1l . "</a> - \n" ;
#   $out_links .= &b ($out_tbl3_hdr1o) . "&nbsp;\n" ;
    $out_links .= "<a href='\#T'>" . $out_tbl3_hdr1t . "</a>\n" ;
  }
  if ($barndx == 5)
  {
    $out_id     = "<a id='T' name='T'>&nbsp;</a>\n" ;
    $out_group  = $out_tbl3_hdr1t ;
    $out_links .= "<a href='\#0'>" . $out_tbl3_hdr1a . "</a> - \n" ;
    $out_links .= "<a href='\#E'>" . $out_tbl3_hdr1e . "</a> - \n" ;
    $out_links .= "<a href='\#L'>" . $out_tbl3_hdr1l . "</a> - \n" ;
    $out_links .= "<a href='\#O'>" . $out_tbl3_hdr1o . "</a>\n" ;
#   $out_links .= &b ($out_tbl3_hdr1t) . "&nbsp;\n" ;
  }
}

sub RecordTime
{
  my $label = shift ;
  my $start = shift ;
  $Invocations {$label} ++ ;
  $TimeSpent   {$label} += Time::HiRes::time - $start ;
}

1;
