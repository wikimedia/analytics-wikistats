#!/usr/bin/perl

  use WikiReportsNoWikimedia ;

sub Log
{
  my $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}

sub Log2
{
  my $msg = shift ;
  print FILE_LOG $msg ;
}

sub LogT
{
  my $msg = shift ;
  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;
  $msg =~ s/(^\n*)/$1$time /s ;
  print $msg ;
  print FILE_LOG $msg ;
}

sub CollectFileTimeStamps
{
  opendir (DIR, $path_out) ;
  while (defined ($file = readdir (DIR)))
  {
    if ($file =~ /^\.+$/)    { next ; }
    if ($file =~ /^Plots$/i) { next ; }

    $time_since = -M $path_out . $file ;

    if ($time_since > (1/48)) # > 30 min
    {
      $date_upd   = time - $time_since * 24 * 60 * 60 ;
      (my $min, my $hour, my $day, my $month, my $year) = (localtime $date_upd) [1,2,3,4,5] ;
      $date_upd = sprintf ("%02d/%02d/%04d %02d:%02d", ($month+1),$day,($year+1900),$hour,$min) ;
      &LogT ("Out of date [$date_upd] " . uc($language). "\/$file\n") ;
    }
  }
}

sub SignalPublishingToDo
{
  open "FILE_PUBLISH", ">>", $file_publish || abort ("File '$file_publish' could not be opened.") ;
  print FILE_PUBLISH &GetDateTime(time) . "\n" ;
  close "FILE_PUBLISH";
}

sub SpoolPreviousErrors
{
  if (-e $file_errors)
  {
    open  (ERRORS, "<", $file_errors) ;
    @errors = <ERRORS> ;
    close (ERRORS) ;
    if ($#errors != -1)
    {
      &LogT ("Runtime errors on previous run spooled to $file_log.\n") ;
      &Log2 (">>\n") ;
      foreach $line (@errors)
      { &Log2 ($line) ; }
      &Log2 ("<<\n\n") ;
    }
    unlink $file_errors ;
    undef @errors ;
  }
}

sub GenerateGallery
{
  my $out_html = "<html><head><title>Wikipedia Main Page Gallery - screen shots taken on May 1, 2004</title></head>\n" .
                 "<body bgcolor=black><table summary='Gallery'><tr>\n" ;
  foreach $wp (@languages)
  {
    if ($wp eq "zz") { next ; }
    $out_bat .= "url2bmp.exe -url \"$wp.wikipedia.org\" -file \"$wp.png\" -format PNG -wx 1000 -wy 3000 -bx 400 -by 1200 -wait 1 -notinteractive\n" ;
    $out_html .= "<td align='center' valign='top'>\n" .
                 "<small><b><font color='#AAAAAA'>" . uc($wp) . "</font>" .
                 "&nbsp;&nbsp;&nbsp;" .
                 "<a href='http://$wp.wikipedia.org'><font color='#AAAAAA'>" . $out_languages {$wp} . "</font></a></small></b><p>" .
                 "<img src='$wp.png'></td>\n" ;
  }
  $out_html .= "</tr></table></body>" ;

  open "FILE_OUT", ">", $path_out . "Gallery.bat" ;
  print FILE_OUT $out_bat ;
  close "FILE_OUT" ;

  open "FILE_OUT", ">", $path_out . "Gallery.htm" ;
  print FILE_OUT $out_html ;
  close "FILE_OUT" ;
}

sub GenerateSiteMapNew
{
  &LogT ("\nGenerate Sitemap") ;

  $sitemap_new_layout = $false ;
  if ($wikimedia && $mode_wp)
  { $sitemap_new_layout = $true ; }

  my $out_zoom = "" ;
  my $out_options = "" ;
  my $out_explanation = "" ;
  my $out_button_prev = "" ;
  my $out_button_next = "" ;
  my $out_button_switch = "" ;
  my $out_page_subtitle = "" ;
  my $out_crossref = "" ;
  my $out_description = "" ;
  my $lang ;

  my $out_html_title = $out_statistics . " \- " . $out_sitemap ;
  my $out_page_title = $out_statistics ;

  if ($region ne "")
  {
    $out_html_title .= " - " . ucfirst ($region) ;
    $out_page_title .= " - " . ucfirst ($region) ;
  }

  if ($out_btn_plots eq "")
  { $out_btn_plots = "Plots" ; }

  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
    $out_page_title .= "<b>" . &GetDate ($dumpdate2) . "<\/b>" ;
  }

  if ($region eq '')
  { $out_crossref = &GenerateCrossReference ($language) ; }
  else
  { $out_button_switch = &btn (" " . "All languages" . " ", "http://stats.wikimedia.org/EN/Sitemap.htm") ; }

#  &ReadLog ($language) ;

# if ($wikimedia && $mode_wp)
# { $out_msg = "All statistics on this site are extracted from full archive database dumps. " .
#               "Since a year it has become increasingly difficult to produce valid dumps for the largest wikipedias. " .
#               "Until that problem is fixed some figures will be outdated. " ; }

  &GenerateHtmlStart ($out_html_title,  $out_zoom,          $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

  if ($sitemap_new_layout)
  { $out_html .= $out_script_sorter ; }

# if ($mode_wp)
# { $out_html .= blank_text_after ("15/01/2009",
#                "<font color=#FF0000><b>Jan 2009: After a long outage the wikistats job is currently processing all available Wikipedia dumps (all minus English Wikipedia, which is too large for current dump process). " .
#                "This report will be updated regularly in the coming days until all data have been actualized.</b></font>") ; }

  $out_html .= "<table border=0 cellspacing=0 id=table1 style='' width='100%' summary='SiteMap'>\n" ;
  $out_html .= "<tr><td width='200' class='l' valign='top'>" ;

  $out_more_tables = "" ;
  if ($sitemap_new_layout)
# { $out_more_tables = "<a href='#comparisons'><b>$out_comparisons</b></a> / <a href='#see_also'><b>$out_generated2</b></a>" ; }
  {
    if ($region eq "")
    { $out_more_tables = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small>See bottom of page for <a href='#comparisons'><b>language comparisons</b></a> / <a href='#see_also'><b>other reports</b></a></small>" ; }
    else
    {
      if ($#languages > 50)
      { $out_more_tables = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small>See below for <a href='#comparisons'><b>language comparisons</b></a></small>" ; }
    }
  }
  $out_more_tables =~ s/\://g ;

  if ($singlewiki)
  {
    foreach $wp (@languages)
    {
      if ($wp ne "zz")
      {
        $out_html .= "<h2><a href='TablesWikipedia" . uc($wp) . ".htm'> " . $out_btn_tables . " </a></h2><p>" .
                     "<h2><a href='ChartsWikipedia" . uc($wp) . ".htm'> " . $out_btn_charts . " </a></h2><p>" ;
      }
    }
  }
  else
  {
    if ($sitemap_new_layout && (! $mode_wx))
    {
      $out_html .= "<table border=0><tr><td><h2>$out_publications</h2></td><td><h3>$out_more_tables</h3></td>" .
                 # "<td><b>&nbsp;&nbsp;&nbsp;<img src='../Tables.png'>&nbsp;=&nbsp;$out_btn_tables&nbsp;<img src='../BarCharts.png'>&nbsp;=&nbsp;$out_btn_charts</b></td>" .
                 # "<td>&nbsp;&nbsp;&nbsp;&nbsp;<b><font size=+1 color='#0000A0' face=\'Times'>W</font> = Wikipedia Article&nbsp;&nbsp;&nbsp;<img src='../BarCharts.png'>&nbsp;=&nbsp;$out_btn_charts</b></td>" .
                   "</tr></table>\n" ;
    }
    else
    { $out_html .= "<h2>$out_publications</h2>\n" ; }

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

    $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Tables and charts' class=tablesorter>\n" ;

    if ($sitemap_new_layout)
    {
      $out_html .= "<thead>\n" ;
      $out_html .= &tr (&tdcbt4 (&b ("Languages")) .
                        &tdcbt  (&b ("Regions")) .
                        &tdcbt3 (&b ("Participation")) .
                        &tdcbt  (&b ("Usage")) .
                        &tdcbt  (&b ("Content"))) ;
                      # &tdcbt  (&b ($out_site)) .

#     $out_html .= &tr (&tdcbt ("<small>&rArr; Article<br>&rArr; $out_btn_charts</small>") .
#                       (&tdcbt ("<small>Code<br>&rArr; Project</small>")) .
#                       (&tdlbt ("<small>Name<br>&rArr; $out_btn_tables</small>")) .
#                       $out_participation {"header"} .
#                       &tdcbt ("<small>Views<br>per hour</small>") .
#                       &tdcbt ("<small>Article<br>count</small>")) ;
      $out_html .= &tr (&the . &the .
                        (&tdcbt ("<small>Code<br>&rArr; Project<br>Main Page</small>")) .
                        (&tdlbt ("<small>Language<br>&rArr; Wikipedia article</small>")) .
                        $out_participation {"header"} .
                        &tdcbt ("<small>Views<br>per hour</small>") .
                        &tdcbt ("<small>Article<br>count</small>")) ;
      $out_html .= &tr (&tde . &tde . &the . &the . &the . &the . &the . &the . &the . &the) ;
    # $out_html .= &tr (&tdimg ("<a href='TablesWikipediaZZ.htm'><img src='../Tables.png'></a> <a href='ChartsWikipediaZZ.htm'><img src='../BarCharts.png'></a>") .

      if ($region eq '')
      {
        $out_html .= &tr (
                        # &tdimg ("<font size=+1 color='#FFFFDD' face=\'Times'>W</font><a href='ChartsWikipediaZZ.htm'><img src='../BarCharts.png'></a>&nbsp;") .
                        # &tdimg ("<a href='ChartsWikipediaZZ.htm'><img src='../BarCharts.png'></a>&nbsp;") .
                          &tdcb (&w("<a href='TablesWikipediaZZ.htm'> " . $out_btn_tables . " </a>")) .
                          &tdcb (&w("<a href='ChartsWikipediaZZ.htm'> " . $out_btn_charts . " </a>")) .
                          &tdcbt ("<a href='$out_url_all'>&Sigma;</a>") .
                         (&tdlbt ("<a href='TablesWikipediaZZ.htm'>" . $out_languages {"zz"} . "</a>&nbsp;(" . $#languages . ")")) .
                          &tdlbt ("<small><small><small>" .
                                  "<font color=#008800><span title='Africa'>AF<\/span><\/font> " .
                                  "<font color=#DD0000><span title='Asia'>AS<\/span><\/font> " .
                                  "<font color=#0000CC><span title='Europe'>EU<\/span><\/font> " .
                                  "<font color=#CC00CC><span title='North America'>NA<\/span><\/font> " .
                                  "<font color=#FFAA00><span title='South America'>SA<\/span><\/font> " .
                                  "<font color=#00AAD4><span title='Oceania'>OC<\/span><\/font> " .
                                  "<font color=#000000><span title='Constructed Language'>CL<\/span><\/font> " .
                                  "<font color=#000000><span title='World Language'>W<\/span><\/font></small></small></small>") .
                          &tde . &tde . &tde . &tde . &tde) ;
                        # &tdcbt ("<a href='$out_url_all'>" . &w( $out_site) . "</a>") .
      }
      $out_html .= "</thead><tbody>\n" ;
    }

    my @languages2 = @languages ;
    if ($sitemap_new_layout)
    { @languages2 = @languages_speakers ; }

    foreach $wp (@languages2)
    {
      if ($skip {$wp}) { next ; }

      $wpc = $wp ;
      # if ($wp eq "simple")
      # { $wpc = "se" ; }

      if ($wpc eq "zz")
      {
        if (! ($sitemap_new_layout || $singlewiki))
        {
          my $views = "" ;
          if ($wikimedia)
          { $views = &tdcb ("Views/hr") ; }

          if ($mode_wx) # no totals for all 'languages'
          {
            $out_html .= &tr ($views .
                              &tdcb ($out_tbl1_hdr12) .
                              &tdlb ("Code") .
                              &tdlb ("Project") .
                              &tde . &tde . &tde) ;
          }
          else
          {
            $out_html .= &tr ($views .
                              &tdcb ($out_tbl1_hdr12) .
                              ($wikimedia ? &tdcb ("&Sigma;") : &tdlb ("&Sigma;")) .
                              ($wikimedia ? &tdlb ($out_languages {$wpc} . "&nbsp;(" . $#languages . ")") : "") .
                              &tdcb ("<a href='$out_url_all'>" . &w($out_site) . "</a>") .
                              &tdcb (&w("<a href='TablesWikipedia" . uc($wpc) . ".htm'> " . $out_btn_tables . " </a>")) .
                             &tdcb (&w("<a href='ChartsWikipedia" . uc($wpc) . ".htm'> " . $out_btn_charts . " </a>"))) ;
          }
        }
      }
      else
      {
        if (! $wikimedia)
        { $out_urls {$wp} =  &UrlWebsite ($wpc) ; }

        # if ($wpc eq "roa-rup")    { $wpc = "roa_rup" ; }
        # if ($wpc eq "zh-min-nan") { $wpc = "zh_min_nan" ; }
        $wpc2 = $wpc ;
        $wpc2 =~ s/_/-/g ;
        $wpc3 = $wpc2 ;
        if (length ($wpc3) > 5)
        { $wpc3 = "<small>$wpc3</small>" ; }

        $out_language_wpc = $out_languages {$wpc} ;
        if ((! $mode_wx) && (length ($out_language_wpc) > 20))
        { $out_language_wpc = "<small>$out_language_wpc</small>" ; }

        if ($wikimedia && ! $sitemap_new_layout)
      # { $out_language_name = "<a href='" . $out_article {$wpc} . "'>$out_language_wpc</a>" ; }
        { $out_language_name = "<a href='TablesWikipedia" . uc($wpc) . ".htm'>$out_language_wpc</a>" ; }
        else
        { $out_language_name = $out_language_wpc ; }

        if ($lastdump_ago {$wp} > 3)
        { $out_language_name .= " <font color=red><small>(!!".$lastdump_short {$wp}."!!)</small></font>" ; }
        elsif ($lastdump_ago {$wp} > 1)
        { $out_language_name .= " <font color=#808000><small>(".$lastdump_short {$wp}.")</small></font>" ; }

        my $totarticles = @MonthlyStats {$wp.$MonthlyStatsWpStop{$wp}.$c[4]} ;
        if ($totarticles > 1000000)
        { $totarticles =~ s/(\d\d\d)(\d\d\d)$/$out_thousands_separator$1$out_thousands_separator$2/ ; }
        elsif ($totarticles > 1000)
        { $totarticles =~ s/(\d\d\d)$/$out_thousands_separator$1/ ; }
        if ($lastdump_ago {$wp} > 3)
        { $totarticles = "<font color=red><small>($totarticles)</small></font>" ; }
        elsif ($lastdump_ago {$wp} > 1)
        { $totarticles = "<font color=#808000><small>($totarticles)</small></font>" ; }

        my $views = "" ;
        if ($wikimedia)
        {
          $views = $PageViewsPerHour {$wp} ;
          if ($views == 0)
          { $views = "?" ; }
          elsif ($views < 0.1)
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
          $views = &tdrb (&w ($views)) ;
        }

        $code_website = "<a href='${out_urls {$wpc}}'>$wpc3</a>" ;


        if ($sitemap_new_layout)
        {
        # $out_html .= &tr (&tdimg ("<a href='TablesWikipedia" . uc($wpc) . ".htm'><img src='../Tables.png'></a> " .
        # $out_language_article = "<a href='" . $out_article {$wpc} . "'><b><font size=+1 color='#0000A0' face=\'Times'>W</font></b></a>" ;
        # $out_language_article = "[<a href='" . $out_article {$wpc} . "'>?</a>]" ;
          $out_language_article = "<a href='" . $out_article {$wpc} . "'>?</a> |" ;
          $out_html .= &tr (
                          # &tdcb ($out_language_article .
                          # "<a href='ChartsWikipedia" . uc($wpc) . ".htm'><img src='../BarCharts.png'></a>") .
                            &tdcb (&w("<a href='TablesWikipedia" . uc($wpc) . ".htm'> " . $out_btn_tables . " </a>")) .
                            &tdcb (&w("<a href='ChartsWikipedia" . uc($wpc) . ".htm'> " . $out_btn_charts . " </a>")) .
                          # &tdcb ("<a href='ChartsWikipedia" . uc($wpc) . ".htm'><img src='../BarCharts.png'></a>") .
                            (($wikimedia && (!$mode_wx)) ? &tdcb ($code_website) : &tdlb ($code_website)) .
                          # (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name . ' ' . $out_language_article) : "") : "") .
                          # (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ("$out_language_article $out_language_name") : "") : "") .
                            (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ("<a href='" . $out_article {$wpc} . "'>$out_language_name</a>") : "") : "") .
                            $out_participation {$wpc2} .
                            $views .
                            &tdrb (&w ($totarticles))) ;
                          # &tdcb ("<a href='" . $out_urls {$wpc} . "'>" . &w($out_site) . "</a>") .
        }
        else
        {
          $out_html .= &tr ($views .
                            &tdrb (&w ($totarticles)) .
                            (($wikimedia && (!$mode_wx)) ? &tdcb ($wpc2) : &tdlb ($wpc2)) .
                            (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") .
                            (  $mode_wx ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") .
                            &tdcb ("<a href='" . $out_urls {$wpc} . "'>" . &w($out_site) . "</a>") .
                            &tdcb (&w("<a href='TablesWikipedia" . uc($wpc) . ".htm'> " . $out_btn_tables . " </a>")) .
                            &tdcb (&w("<a href='ChartsWikipedia" . uc($wpc) . ".htm'> " . $out_btn_charts . " </a>"))) ;
        }
     }
    }
    $out_html .= "</tbody>\n</table>\n" ;

    if (($some_languages_only) || ($#languages < 25))
    { &TableSeeAlso (1) ; }

    if (! $sitemap_new_layout)
    { $out_html .= "</td><td width='30'>&nbsp;</td><td class='l' valign='top'>" ; }
    else
    { $out_html .= "</td></tr><tr><td><p></td></tr><tr><td class='l' valign='top'>" ; }
  }

  if ((! $mode_wx) && (! $singlewiki))
  { $out_html .= "<a id='comparisons' name='comparisons'></a><h2>" . $out_comparisons . "</h2>\n" ; }
  else
  {
    if ($singlewiki)
    { $out_html .= "<h2>" . $out_btn_plots . "</h2>\n" ; }
    else
    { $out_html .= "<h2>" . $out_btn_charts . "</h2>\n" ; }
  }

  $out_html .= "<a id='see_also' name='see_also'><table class='l' border=1 cellspacing=0 id=table3 style='' summary=''>\n" ;

  if ((! $mode_wx) && (! $singlewiki))
  {
    $out_html .= &tr (&tdlb   (&w ($out_report_descriptions [$#report_names])) .
                      &tdlb2b (&w ("<a href='Tables" . $report_names [$#report_names]. ".htm'>".
                                    $out_btn_tables . " &amp; " . $out_btn_charts . "</a>"))) ;

    if ($wikimedia)
    {
      if ($region eq '')
      { $out_html .= &tr (&tdlb   (&w ($out_pageviews)) .
                          &tdlb2b (&w ("<a href='../EN/TablesPageViewsMonthly.htm'>$out_btn_tables</a> " . blank_text_after ("31/03/2009", " <font color=#008000><b>NEW</b></font>")))) ; }
      else
      {
        my $region_uc = ucfirst ($region) ;
        $out_html .= &tr (&tdlb   (&w ($out_pageviews)) .
                          &tdlb2b (&w ("<a href='../EN/TablesPageViewsMonthly.htm'>All languages</a><br>" .
                                       "<a href='../EN_$region_uc/TablesPageViewsMonthly.htm'>$region_uc</a>"
                          ))) ;

      }
    }

    if ($growth_summary_generated)
    { $out_html .= &tr (&tdlb   (&w ($out_creation_history)) .
                        &tdlb2b (&w ("<a href='TablesWikipediaGrowthSummaryContributors.htm'>$out_btn_tables</a>"))) ; }

    $out_html .= &tr (&tdlb   (&w ($out_report_description_current_status)) .
                      &tdlb2b (&w ("<a href='TablesCurrentStatusVerbose.htm'>$out_btn_tables</a> "))) ;
    $out_html .= &tr (&tdlb   (&w ($out_botactivity)) .
                      &tdlb2b (&w ("<a href='../EN/BotActivityMatrix.htm'>$out_btn_tables</a>"))) ;
    $out_html .= &tr (&tde3b) ;
  }

  $imagelinks_incomplete = $false ;
  if ((($wp !~ /^zzz?/) && ($imagecodes {$wp}  !~ /(?:^|\|)IMAGE(?:$|\|)/i)) ||
      (($wp =~ /^zzz?/) && ($imagecodes {"de"} !~ /(?:^|\|)IMAGE(?:$|\|)/i)))
  { $imagelinks_incomplete = $true ; }
  if ((($wp !~ /^zzz?/) && ($imagecodes {$wp}  !~ /(?:^|\|)FILE(?:$|\|)/i)) ||
      (($wp =~ /^zzz?/) && ($imagecodes {"de"} !~ /(?:^|\|)FILE(?:$|\|)/i)))
  { $imagelinks_incomplete = $true ; }

  $r = 0 ;
  foreach $report (@report_names)
  {
    $out_description = $out_report_descriptions [$r++] ;

    if ($r == 6) { next ; } # skip alternate article count (obsolete)

  # if ((! $mode_wp) && ($r > 19)) { last ; } # skip missing visitor stats
    if ($r > 19) { last ; } # skip missing visitor stats

    if (($mode_wp) ||
        (($r != 6) && ($r != 10) && ($r != 11)))
    {
      if ((! $mode_wx) && (! $singlewiki))
      {
        if ($r == 12)
        { $out_description = $out_report_description_edits ; }
        $out_line = &tdlb ($out_description).
                    &tdcb (&w ("<a href='Tables" . $report . ".htm'>" . $out_btn_tables . "</a>")) ;
      # if (($r == 1) || (($r >= 3) && ($r <= 6)) || ($r == 12) || ($r == 13) || ($r == 15) || ($r == 16) || (($mode_wp) && ($r == 21))) # April 2010: less trivia
        if (($r == 1) || (($r >= 3) && ($r <= 6)) || ($r == 12) || (($mode_wp) && ($r == 21)))
        { $out_line .= &tdcb (&w ($out_btn_charts . "&nbsp;&nbsp;" .
                                  "<a href='PlotsPng" . $report . ".htm'>PNG</a>&nbsp;&nbsp;" .
                                  "<a href='PlotsSvg" . $report . ".htm'>SVG</a>")) ; }
        else
        { $out_line .= &tdeb ; }

        if (($imagelinks_incomplete) && ($r == 17))
        { $out_line =~ s/<\/?a[^>]*>//g ; }

        $out_html .= &tr ($out_line) ;
      }
      else
      {
      # if (($r == 1) || (($r >= 3) && ($r <= 6)) || ($r == 12) || ($r == 13) || ($r == 15) || ($r == 16)) # April 2010: less trivia
        if (($r == 1) || (($r >= 3) && ($r <= 6)) || ($r == 12))
        {
          if ($r == 12)
          { $out_description = $out_report_description_edits ; }

          if (($r == 16) && ($singlewiki)) { next ; }

          $out_line = &tdlb ($out_description) .
                      &tdcb (&w ("<small>" .
                                 "<a href='PlotsPng" . $report . ".htm'>PNG</a>&nbsp;&nbsp;" .
                                 "<a href='PlotsSvg" . $report . ".htm'>SVG</a></small>")) ;
          $out_html .= &tr ($out_line) ;
        }
      }
    }
    if ($r == $#report_names) { last ; }
  }

  $out_html .= "</table>\n" ;

  if ($categorytrees && (! $category_index))
  {
    if ($singlewiki)
    {
      my $wp = $languages [1] ;

      $file_categories_all = "CategoryOverview_".uc($wp)."_Complete.htm" ;
      $file_categories_top = "CategoryOverview_".uc($wp)."_Concise.htm" ; # top 4
      $file_categories_tip = "CategoryOverview_".uc($wp)."_Main.htm" ;    # tip of the iceberg = top 3
      $size_all = -s $path_out_categories . $file_categories_all ;
      $size_top = -s $path_out_categories . $file_categories_top ;
      $size_tip = -s $path_out_categories . $file_categories_tip ;

      $out_html .= "<p><h2>" . $out_categories . "</h2>\n" ;

      $out_html .= "<a href='CategoryOverview_".uc($wp)."_Complete.htm'>$out_categories_complete</a><br>" ;
      if ($size_top > 0)
      { $out_html .= "<a href='CategoryOverview_".uc($wp)."_Concise.htm'>$out_categories_concise</a><br>" ; }
      if ($size_tip > 0)
      { $out_html .= "<a href='CategoryOverview_".uc($wp)."_Main.htm'>$out_categories_main</a><br>" ; }
      $out_html .= "<p>" ;
    }
  }

  if (! (($some_languages_only) || ($#languages < 25)))
  { &TableSeeAlso (2) ; }

  $out_html .= "</td>" ;

#  $out_html .= "<td class=r valign='top'>" ;
#  if (defined ($dumpdate_hi))
#  {
#    $dumpdate2 = timegm (0,0,0,
#                         substr ($dumpdate_hi,6,2),
#                         substr ($dumpdate_hi,4,2)-1,
#                         substr ($dumpdate_hi,0,4)-1900) ;
#    $out_html .= "<h2>" . &GetDate ($dumpdate2) . "<\/h2>\n" ;
#  }
#  $out_html .= "</td>" ;

  $out_html .= "</tr>" ;
  $out_html .= "</table>\n" ;

  $generate_sitemap = $true ;
  &GenerateColophon ($false, $false) ;
  $generate_sitemap = $false ;

  if ($sitemap_new_layout)
  { $out_html .= $out_script_sorter_invoke ; }

  $out_html .= "</body>\n</html>" ;

  $out_html =~ s/roa_rup/roa-rup/g ;
  $out_html =~ s/zh_min_nan/zh-min-nan/g ;
  $out_html =~ s/fiu_vro/fiu-vro/g ;

  my $file_html ;
  $file_html = $path_out . "Sitemap.htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
  $file_html = $path_out . "index.html" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
  $file_html = $path_out . "#index.html" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub TableSeeAlso
{
  my $column = shift ;
  my $width = "" ;
  # if ($column == 1)
  # { $width = "width='100%'" ; }

  if ($wikimedia)
  {
    my $more_stats = $out_stats_for ;
    $more_stats =~ s/\/([^\/]*)$/$1/ ;
    $out_generated2 =~ s/\:// ;

    $out_html .= "<p><h2>$out_generated2</h2>" ;
    $out_html .= "<table class='l' border=1 cellspacing=0 id=table4 style='' $width summary='See also'>\n" ;

    if ($region eq '')
    {
      if (! $mode_wb)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikibooks/$langcode/Sitemap.htm'>" . $out_wikibooks .  "</a>")) ; }
      if (! $mode_wk)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wiktionary/$langcode/Sitemap.htm'>" . $out_wiktionaries .  "</a>")) ; }
      if (! $mode_wn)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikinews/$langcode/Sitemap.htm'>" . $out_wikinews .  "</a>")) ; }
      if (! $mode_wp)
      { $out_html .= &tr (&tdlb ("$more_stats <a href='http://stats.wikimedia.org/$langcode/Sitemap.htm'>" . $out_wikipedias .  "</a>")) ; }
      if (! $mode_wq)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikiquote/$langcode/Sitemap.htm'>" . $out_wikiquotes .  "</a>")) ; }
      if (! $mode_ws)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikisource/$langcode/Sitemap.htm'>" . $out_wikisources .  "</a>")) ; }
      if (! $mode_wv)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikiversity/$langcode/Sitemap.htm'>" . $out_wikiversities .  "</a>")) ; }
      if (! $mode_wx)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikispecial/$langcode/Sitemap.htm'>" . $out_wikispecial .  "</a>")) ; }
    }

    if ($mode_wp && ($region ne ''))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/$langcode/Sitemap.htm'>" . $out_wikipedias .  ", all languages</a>")) ; }
    if ($mode_wp && ($region ne 'africa'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Africa/Sitemap.htm'>" . $out_wikipedias .  ", region Africa</a>")) ; }
    if ($mode_wp && ($region ne 'asia'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Asia/Sitemap.htm'>" . $out_wikipedias .  ", region Asia</a>")) ; }
    if ($mode_wp && ($region ne 'america'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_America/Sitemap.htm'>" . $out_wikipedias .  ", region America's</a>")) ; }
    if ($mode_wp && ($region ne 'europe'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Europe/Sitemap.htm'>" . $out_wikipedias .  ", region Europe</a>")) ; }
    if ($mode_wp && ($region ne 'india'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_India/Sitemap.htm'>" . $out_wikipedias .  ", region India</a>")) ; }
    if ($mode_wp && ($region ne 'oceania'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Oceania/Sitemap.htm'>" . $out_wikipedias .  ", region Oceania</a>")) ; }
    if ($mode_wp && ($region ne 'artificial'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Artificial/Sitemap.htm'>" . $out_wikipedias .  ", artificial languages</a>")) ; }

    if ($region eq '')
    {
      if (($mode_wx) && ($growth_summary_generated))
      { $out_html .= &tr (&tdlb   (&w ("<a href='TablesWikipediaGrowthSummary.htm'>$out_creation_history</a>"))) ; }

      if ($mode_wx)
      {
        $out_html .= &tr (&tdlb (&w ("<a href='TablesCurrentStatusVerbose.htm'>$out_report_description_current_status</a> "))) ;
      }
      $out_html .= &tr (&tdlb ("<a href='../EN/CategoryOverviewIndex.htm'>$out_categories</a>")) ;
    # $out_html .= &tr (&tdlb ("<a href='../EN/BotActivityMatrix.htm'>$out_botactivity</a>")) ;

      if ($mode_wp)
      { $out_html .= &tr (&tdlb ("<font color=#808080>$out_easytimeline</font>")) ; }
    # { $out_html .= &tr (&tdlb ("<a href='../EN/TimelinesIndex.htm'>$out_easytimeline</a>")) ; }

      if ($mode_wb || $mode_wv)
      { $out_html .= &tr (&tdlb ("<a href='../EN/WikiBookIndex.htm'>$out_stats_per $out_wikibook</a>")) ; }

      $out_html .= &tr (&tdlb ("Top 100 articles ranked <a href='http://stats.wikimedia.org/EN/TableRankArticleHistoryByArchiveSize.html'>by archive size</a>" .
                               blank_text_after ("30/04/2009", " <font color=#008000><b>NEW</b></font>") . "&nbsp;&nbsp;" .
                               "<a href='http://stats.wikimedia.org/EN/TableRankArticleHistoryByTotalEdits.html'>by edit count</a>" .
                               blank_text_after ("30/04/2009", " <font color=#008000><b>NEW</b></font>") )) ;
      $out_html .= &tr (&tdlb ("<a href='http://meta.wikimedia.org/wiki/Template:Wikimedia_Growth'>Wikimedia growth</a>")) ;
      $out_html .= &tr (&tdlb ("Mailing list activity: <a href='http://www.infodisiac.com/Wikipedia/ScanMail/index.html'>All lists</a>&nbsp;/&nbsp;".
                              "<a href='http://www.infodisiac.com/Wikipedia/ScanMail/_PowerPosters.html'>Power posters</a>")) ;

      $out_html .= &tr (&tdlb ("Job progress: <a href='http://www.infodisiac.com/cgi-bin/WikimediaDownload.pl'>Database dumps</a>&nbsp;/&nbsp;" .
                               "<a href='http://stats.wikimedia.org/WikiCountsJobProgress.html'>Data gathering</a> " . blank_text_after ("31/03/2009", " <font color=#008000><b>NEW</b></font>"))) ;
      $out_html .= &tr (&tdlb ("Raw data: <a href='../csv/csv.zip'>csv.zip</a> (doc: <a href='http://meta.wikimedia.org/wiki/Wikistat_csv'>meta</a>)")) ;
    }

    $out_html .= "<\/table>\n" ;
  }
}

sub GenerateSiteMap
{
  my $out_zoom = "" ;
  my $out_options = "" ;
  my $out_explanation = "" ;
  my $out_button_prev = "" ;
  my $out_button_next = "" ;
  my $out_button_switch = "" ;
  my $out_page_subtitle = "" ;
  my $out_crossref = "" ;
  my $out_msg = "" ;

  my $out_html_title = $out_statistics . " \- " . $out_sitemap ;
  my $out_page_title = $out_html_title ;
  my $lang ;

#  &ReadLog ($language) ;

  @other_languages = split (",", $crossref) ;
  my $tillbreak = int ($#other_languages / 2) + 1 ;
  foreach $other (@other_languages)
  {
    if ($other ne $language)
    {
      $out_crossref .= " <a href='../" . uc ($other) . "/Sitemap.htm'>" .
                       $out_languages_org {$other} . "</a>" ;
      $tillbreak -- ;
      if ($tillbreak == 0)
      { $out_crossref .= "<br>" ; }
      else
      { $out_crossref .= " |" ; }
    }
  }
  $out_crossref =~ s/\|$// ;

  &GenerateHtmlStart ($out_html_title,  $out_zoom,          $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;

  $out_html .= "<table border=0 cellspacing=0 id=table1 style='' width='100%' align='left' summary='SiteMap'>\n" ;
  $out_html .= "<tr><td width='200' class='l' valign='top' align='left'>" ;

  if ($mode_wb)  { $out_html .= "<h2>" . $out_wikibooks .    "</h2>\n" ; }
  if ($mode_wk)  { $out_html .= "<h2>" . $out_wiktionaries . "</h2>\n" ; }
  if ($mode_wn)  { $out_html .= "<h2>" . $out_wikinews .     "</h2>\n" ; }
  if ($mode_wp)  { $out_html .= "<h2>" . $out_wikipedias .   "</h2>\n" ; }
  if ($mode_wq)  { $out_html .= "<h2>" . $out_wikiquotes .   "</h2>\n" ; }
  if ($mode_ws)  { $out_html .= "<h2>" . $out_wikisources .  "</h2>\n" ; }
  if ($mode_wv)  { $out_html .= "<h2>" . $out_wikiversity .  "</h2>\n" ; }
  if ($mode_wx)  { $out_html .= "<h2>" . $out_wikispecial .  "</h2>\n" ; }

  $out_html .= "<table border=1 cellspacing=0 id=table1 style='' align='left' summary='Tables and charts'>\n" ;

  foreach $wp (@languages)
  {
    $wpc = $wp ;
    # if ($wp eq "simple")
    # { $wpc = "se" ; }

    if ($wp eq "zz")
    {
      $out_html .= &tr (&tdc ("&Sigma;") .
                        &tdl ($out_languages {$wp} . "&nbsp;(" . $#languages . ")") .
                        &tde .
                        &tdc (&w("<a href='TablesWikipedia" . uc($wp) . ".htm'> " . $out_btn_tables . " </a>")) .
                        &tdc (&w("<a href='ChartsWikipedia" . uc($wp) . ".htm'> " . $out_btn_charts . " </a>"))) ;
    }
    else
    {
      $out_html .= &tr (&tdc ($wpc) .
                        &tdl ($out_languages {$wp}) .
                        &tdc ("<a href='" . $out_urls {$wp} . "'>" . &w($out_site) . "</a>") .
                        &tdc (&w("<a href='TablesWikipedia" . uc($wp) . ".htm'> " . $out_btn_tables . " </a>")) .
                        &tdc (&w("<a href='ChartsWikipedia" . uc($wp) . ".htm'> " . $out_btn_charts . " </a>"))) ;
   }
  }
  $out_html .= "</table>\n" ;
  $out_html .= "</td><td width='30'>&nbsp;</td><td class='l' align='left' valign='top'>" ;
  $out_html .= "<h2>" . $out_comparisons . "</h2>\n" ;
  $out_html .= "<table border=1 cellspacing=0 id=table1 style='' align='left' summary='Comparison tables'>\n" ;

  $out_html .= &tr (&tdl ("<a href='Tables" . $report_names [$#report_names]. ".htm'>".
                             $out_report_descriptions [$#report_names] . "</a>")) ;
  $out_html .= &tr (&tde) ;
  $r = 0 ;
  foreach $report (@report_names)
  {
    $out_html .= &tr (&tdl ("<a href='Tables" . $report . ".htm'>".
                             $out_report_descriptions [$r++] . "</a>")) ;
    if ($r == $#report_names) { last ; }
  }

  $out_html .= "</table>\n" ;
  $out_html .= "</td><td align='right' valign='top'>" ;

  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
    $out_html .= "<h2>" . &GetDate ($dumpdate2) . "<\/h2>\n" ;
  }
  $out_html .= "</td></tr>" ;
  $out_html .= "</table>\n" ;

  &GenerateColophon ($true, $false) ;

  $out_html .= "</body>\n</html>" ;

  my $file_html = $path_out . "Sitemap.htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ;
  close "FILE_OUT" ;
}

sub GenerateHtmlStartWikipediaReport
{
  my $wp = shift ;
  my $pagetype = shift ;
  my $out_zoom_buttons = shift ;
  my $out_msg = shift ;
  my $out_page_title ;
  my $out_page_subtitle ;
  my $out_html_title ;
  my $out_button_switch ;
  my $out_crossref ;

  if ($pagetype eq "Tables")
  { $out_page_title    = $out_statistics ; }
  else
  { $out_page_title    = $out_charts ; }

  if ($wp eq "")
  {
    $out_page_subtitle = $out_report_descriptions [$#out_report_descriptions] ;
    $out_html_title    = $out_statistics . " - " . $pagetype . " - " . $out_page_subtitle ;
    $out_page_subtitle = "" ;
  }
  else
  {
    $out_page_subtitle = $out_languages {$wp} ;

    $out_html_title    = $out_statistics . " - " . $pagetype . " - " . $out_page_subtitle ;

    if ($wp =~ /^zzz?$/)
    { $out_page_subtitle = "<font color='#A00000'>" . $out_page_subtitle . "</font>" ; }
    else
    { $out_page_subtitle = "<a href='" . $out_urls {$wp} . "'>" . $out_page_subtitle . "</a>" ; }
  }

  if (($region ne "") && ($wp =~ /^zz+$/))
  {
    $out_html_title .= " - " . ucfirst ($region) ;
    $out_page_title .= " - " . ucfirst ($region) ;
  }

  my $out_explanation   = $out_tbl3_intro ;
  if ($pagetype eq "Charts")
  { $out_explanation   = "" ; }

  my $out_button_prev   = "" ;
  my $out_button_next   = "" ;
  my $out_options       = "" ;
  my $url ;

  if ($#languages > 0)
  {
    $ndx_lang = 0 ;
    foreach $l (@languages)
    {
      if ($l eq $wp) { last ; }
      $ndx_lang ++ ;
    }

    $ndx_min = 0 ;
    $ndx_max = $#languages ;
    if ($mode_wx)
    { $ndx_min = 1 ; }
    $ndx_prev = $ndx_lang > $ndx_min ? $ndx_lang - 1 : $ndx_max ;
    $url = $pagetype . "Wikipedia" . uc ($languages [$ndx_prev]) . ".htm" ;
    $out_button_prev = &btn (" < ", $url) ;

    $ndx_next = $ndx_lang < $ndx_max ? $ndx_lang + 1 : $ndx_min ;
    $url = $pagetype . "Wikipedia" . uc ($languages [$ndx_next]) . ".htm" ;
    $out_button_next = &btn (" > ", $url) ;
  }

  if ($pagetype eq "Tables")
  {
    $url = "ChartsWikipedia" . uc ($wp) . ".htm" ;
    $out_button_switch = &btn (" " . $out_btn_charts . " ", $url) ;
  }
  else
  {
    $url = "TablesWikipedia" . uc ($wp) . ".htm" ;
    $out_button_switch = &btn (" " . $out_btn_tables . " ", $url) ;
  }

  my $reports   = $#languages ;
  my $ndx_lang2 = $ndx_lang ;
  for ($report = 0 ; $report <= $reports ; $report ++)
  {
    $url = $pagetype . "Wikipedia" . uc ($languages [$ndx_lang2]) . ".htm" ;
    $description  = $out_languages {$languages [$ndx_lang2]} ;
    if ((! $mode_wx) || ($ndx_lang2 ne 0))
    {  $out_options .= &opt ($url, $description) ; }
    $ndx_lang2 ++ ;
    if ($ndx_lang2 > $reports)
    { $ndx_lang2 = 0 ; }
  }

  if ($singlewiki)
  { $out_page_subtitle = "" ; }

  $out_page_title   .= "&nbsp;" . $out_page_subtitle ;
  $out_page_subtitle = "" ;
  $out_explanation   = "" ;
  &GenerateHtmlStart ($out_html_title,  $out_zoom_buttons,  $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;
}

sub GenerateHtmlStartComparisonPlots
{
  my $image_fmt     = shift ;
  my $image_fmt_alt = shift ;
  my $file_html_alt = shift ;
  my $ndx_report    = shift ;


  my $out_html_language = $language ;

  my $out_page_title    = $out_statistics ;
  my $out_page_subtitle = $out_report_descriptions [$ndx_report] ;
  if ($ndx_report == 11)
  { $out_page_subtitle = $out_report_description_daily_edits ; }

  my $out_html_title    = $out_statistics . " - Plots - " . $out_page_subtitle ;
  my $out_explanation   = $out_tbl3_legend [$ndx_report] ;
  if ($ndx_report == 11)
  { $out_explanation = $out_legend_daily_edits ; }

  if ($region ne "")
  {
    $out_html_title .= " - " . ucfirst ($region) ;
    $out_page_title .= " - " . ucfirst ($region) ;
  }

  if ($out_explanation =~ / F\)/)
  { $out_explanation =~ s/\([^\)]*\)// ; }
  if ($ndx_report == 2)
  { $out_explanation = $out_plot_legend [0] ; $out_explanation =~ s/week/<b>week<\/b>/ ; }
  if ($ndx_report == 3)
  { $out_explanation = $out_plot_legend [1] ; $out_explanation =~ s/week/<b>week<\/b>/ ;  }
  if ($ndx_report == 5)
  {
    if ($wikimedia)
    {
      $out_explanation =~ s/([^\#\d])200([^\;])/$1 . "200 (ja,ko,zh:50)" . $2/e ;
      $out_explanation =~ s/\<br\>[^\<]*$// ;
    }
  }
  my $out_crossref      = "" ;

  my ($out_button_prev, $out_button_next, $out_options, $url) ;

  $ndx_max = $#report_columns ;
#  if (! $mode_wp)
#  { $ndx_max-- ; }
  for ($ndx = 0 ; $report_columns [$ndx] != $ndx_report ; $ndx++) {;}
  $ndx_prev = $ndx - 1 ; if ($ndx_prev  < 0) { $ndx_prev = $ndx_max ; }
  $ndx_next = $ndx + 1 ; if ($ndx_next > $ndx_max) { $ndx_next = 0 ; }

  if ($ndx > 0)
  {
    $url = "Plots" . $image_fmt . $report_names [$report_columns [$ndx_prev]]. ".htm" ;
    $out_button_prev = &btn (" < ", $url) ;
  }
  else
  { $out_button_prev = &btn (" &nbsp;&nbsp; ", "") ; }

  if ($ndx < $#report_columns)
  {
    $url = "Plots" . $image_fmt . $report_names [$report_columns [$ndx_next]]. ".htm" ;
    $out_button_next = &btn (" > ", $url) ;
  }
  else
  { $out_button_next = &btn (" &nbsp;&nbsp; ", "") ; }

  $out_button_fmt_alt = &btn (" " . uc ($image_fmt_alt) . " ", $file_html_alt) ;
  $out_zoom_buttons2 = $out_zoom_buttons ;
  if ($image_fmt=~ m/svg/i)
  { $out_zoom_buttons2 =~ s/switchFontSize/switchPlotSize/g; }
  else
  { $out_zoom_buttons2 = "" ; }
  $out_zoom_buttons2 = $out_zoom_buttons2 . "&nbsp;" . $out_button_fmt_alt ;
# $out_button_switch = &btn (" " . @out_report_descriptions[$#out_report_descriptions] . " ", "TablesRecentTrends.htm") ;

  $out_button_switch = "" ;
  if ((! $mode_wx) && (! $singlewiki))
  {
    $url = "Tables" . $report_names [$report_columns [$ndx]]. ".htm" ;
    $out_button_switch = &btn (" " . $out_btn_table . " ", $url) ;
  }

  my $reports     = $#report_columns ;
  my $ndx_report2 = $ndx ;
  for ($report = 0 ; $report <= $reports ; $report ++)
  {
    $url = "Plots" . $image_fmt . $report_names [$report_columns [$ndx_report2]] . ".htm" ;
    $description  = @out_report_descriptions [$report_columns [$ndx_report2]] ;
    if ($report_columns [$ndx_report2] == 11)
    { $description = $out_report_description_daily_edits ; }

    $out_options .= &opt ($url, $description) ;

    $ndx_report2 ++ ;
    if ($ndx_report2 > $reports)
    { $ndx_report2 = 0 ; }
  }

  my $out_msg = "" ;
  &GenerateHtmlStart ($out_html_title,  $out_zoom_buttons2, $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;
}

sub GenerateHtmlStartComparisonTables
{
  if ($pageviews)
  {
    my $out_zoom = "" ;
    my $out_options = "" ;
    my $out_explanation = "" ;
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
    $out_zoom_buttons2 = "<small><font color=#888866>Firefox: Ctrl+ Ctrl-</font></small> " . $out_zoom_buttons ;

    $out_zoom = $out_color_buttons . " " . $out_zoom_buttons2 ;


    my ($out_html_title, $out_page_title) ;
    if ($pageviews_all_projects)
    {
      $out_html_title = "$out_wikimedia  $out_pageviews - All projects" ;
      $out_page_title = "$out_wikimedia  $out_pageviews - All projects" ;
    }
    else
    {
      $out_html_title = "$out_publication $out_pageviews" ;
      $out_page_title = "$out_publication $out_pageviews" ;
    }

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
    return ;
  }

  my $ndx_report = shift ;
  my $out_html_language = $language ;

  my $out_page_title    = $out_statistics ;
  my $out_page_subtitle = $out_report_descriptions [$ndx_report] ;

    print "ndx_report $ndx_report out_page_subtitle $out_page_subtitle\n" ;

  my $out_html_title    = $out_statistics . " - Tables - " . $out_page_subtitle ;
  my $out_explanation   = $out_tbl3_legend [$ndx_report] ;
  if ($out_explanation =~ / F\)/)
  { $out_explanation =~ s/\([^\)]*\)// ; }

  if ($ndx_report == 5)
  {
    $out_explanation =~ s/([^\#\d])200([^\;])/$1 . "200 (ja,ko,zh:50)" . $2/e ;
    $out_explanation =~ s/\<br\>[^\<]*$// ;
  }
  my $out_crossref      = "" ;

  my ($out_button_prev, $out_button_next, $out_options, $url) ;

  $ndx_report_next = $ndx_report+1 ;
  $ndx_report_prev = $ndx_report-1 ;

  if (! $mode_wp)
  {
    if    ($ndx_report_prev ==  5) { $ndx_report_prev = 4 ; }
    elsif ($ndx_report_prev ==  9) { $ndx_report_prev = 8 ; }
    elsif ($ndx_report_prev == 10) { $ndx_report_prev = 8 ; }
 #  elsif ($ndx_report_prev == 20) { $ndx_report_prev = 18 ; }

    if    ($ndx_report_next ==  5) { $ndx_report_next = 6 ; }
    elsif ($ndx_report_next ==  9) { $ndx_report_next = 11 ; }
    elsif ($ndx_report_next == 10) { $ndx_report_next = 11 ; }
 #  elsif ($ndx_report_next == 19) { $ndx_report_next = 21 ; }
  }

  if ($ndx_report > 0)
  {
    $url = "Tables" . $report_names [$ndx_report_prev]. ".htm" ;
    $out_button_prev = &btn (" < ", $url) ;
  }
  else
  { $out_button_prev = &btn (" &nbsp;&nbsp; ", "") ; }

  if ($ndx_report < $#report_names - 3) # skip very incomplete visitor stats
  {
    $url = "Tables" . $report_names [$ndx_report_next]. ".htm" ;
    $out_button_next = &btn (" > ", $url) ;
  }
  else
  { $out_button_next = &btn (" &nbsp;&nbsp; ", "") ; }

  if ($ndx_report < $#out_report_descriptions)
  {
    $out_zoom_buttons2 = "<small><font color=#888866>Firefox: Ctrl+ Ctrl-</font></small> " . $out_zoom_buttons ;

    if (($ndx_chart <= 6) || ($ndx_chart >= 9))
    { $out_zoom_buttons2 = $out_color_buttons . " " . $out_zoom_buttons2 ; }
    else
    { $out_zoom_buttons2 = $out_color_button  . " " . $out_zoom_buttons2 ; }

    $ndx_chart = $ndx_report + 1 ; #
  # if (($ndx_chart == 1) || (($ndx_chart >= 3) && ($ndx_chart <= 6)) || (($ndx_chart >= 12) && ($ndx_chart <= 16)) || ($ndx_chart >= 20)) April 2010 less trivia
    if (($ndx_chart == 1) || (($ndx_chart >= 3) && ($ndx_chart <= 5)) || ($ndx_chart == 12) || ($ndx_chart >= 20))
    {
      $url = "Plots'+imageFormat+'". $report_names [$ndx_report]. ".htm" ;
      $out_button_switch = &btn (" " . $out_btn_charts . " ", $url) ;
    }
    else
    { $out_button_switch = &btn (" " . $out_report_descriptions[$#out_report_descriptions] . " ", "TablesRecentTrends.htm") ; }
  }
  else
  {
     $out_zoom_buttons2 = &b ($out_bars) . "&nbsp;&nbsp;" .
                  "<input type='button' value=' &Sigma; ' onclick = \"switchShowTotals('-');\">&nbsp;\n" .
                  "<input type='button' value='1:10' onclick = \"switchTwoScales('-');\">" .
                  "&nbsp;&nbsp;" . $out_zoom_buttons ;
     $out_button_switch = "" ;
  }

  my $reports     = $#out_report_descriptions ;
  my $ndx_report2 = $ndx_report;
  for ($report = 0 ; $report <= $reports ; $report ++)
  {
    $url = "Tables" . $report_names [$ndx_report2] . ".htm" ;
    $description  = $out_report_descriptions [$ndx_report2] ;

    if (($mode_wp) ||
        (($ndx_report2 != 5) && ($ndx_report2 != 9) && ($ndx_report2 != 10)))
    { $out_options .= &opt ($url, $description) ; }

    $ndx_report2 ++ ;
    if ($ndx_report2 > $reports)
    { $ndx_report2 = 0 ; }
  }

  my $out_msg = "" ;

  &GenerateHtmlStart ($out_html_title,  $out_zoom_buttons2, $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;
}

sub GenerateHtmlStart
{
  my ($out_html_title,  $out_zoom_buttons,  $out_options,
      $out_page_title,  $out_page_subtitle, $out_explanation,
      $out_button_prev, $out_button_next,   $out_button_switch,
      $out_crossref,    $out_msg) = @_ ;

  $out_page_subtitle =~ s/^\s*$/&nbsp;/ ;

  my $out_sitemap = &btn (" $out_home ", "Sitemap.htm") . "&nbsp;" ;

  if ($out_options ne "")
  {
    $out_form2 = $out_form ;
    $out_form2 =~ s/HOME/$out_sitemap/ ;
    $out_form2 =~ s/ZOOM/$out_zoom_buttons/ ;
    $out_form2 =~ s/Zoom/$out_zoom/ ;
    $out_form2 =~ s/BUTTON_SWITCH/$out_button_switch/ ;

    if ($singlewiki)
    {
      $out_form2 =~ s/<select.*?select>//s ;
      $out_form2 =~ s/OPTIONS// ;
      $out_form2 =~ s/BUTTON_PREVIOUS// ;
      $out_form2 =~ s/BUTTON_NEXT// ;
    }
    else
    {
      $out_form2 =~ s/OPTIONS/$out_options/ ;
      $out_form2 =~ s/BUTTON_PREVIOUS/$out_button_prev/ ;
      $out_form2 =~ s/BUTTON_NEXT/$out_button_next/ ;
    }
  }
  elsif ($out_button_switch eq "home")
  {
    $out_sitemap = &btn (" $out_home ", "Sitemap.htm") . "&nbsp;" ;
    $out_form2 = $out_form ;
    $out_form2 =~ s/<select.*?select>//s ;
    $out_form2 =~ s/HOME/$out_sitemap/ ;

    if ($pageviews)
    {
      $out_form2 =~ s/ZOOM/$out_zoom_buttons/ ;
      $out_form2 =~ s/Zoom/$out_zoom/ ;
    }
    else
    {
      $out_form2 =~ s/ZOOM// ;
      $out_form2 =~ s/Zoom// ;
    }

    $out_form2 =~ s/BUTTON_SWITCH// ;
    $out_form2 =~ s/BUTTON_PREVIOUS// ;
    $out_form2 =~ s/BUTTON_NEXT// ;
    $out_form2 =~ s/OPTIONS// ;
  }
  # special case for category tree pages (make this more general some time)
  elsif ($out_button_switch ne "")
  {
    if ($region eq '')
    {
      if ($category_index)
      { $out_sitemap = &btn (" Index ", "CategoryOverviewIndex.htm") . "&nbsp;" ; }
      else
      { $out_sitemap = &btn (" Home ", "Sitemap.htm") . "&nbsp;" ; }
    }
    else
    { $out_sitemap = '' ; }
    $out_form2 = $out_form ;
    $out_form2 =~ s/<select.*?select>//s ;
    $out_form2 =~ s/HOME/$out_sitemap/ ;
    $out_form2 =~ s/ZOOM// ;
    $out_form2 =~ s/Zoom// ;
    $out_form2 =~ s/BUTTON_SWITCH/$out_button_switch/ ;
    $out_form2 =~ s/BUTTON_PREVIOUS// ;
    $out_form2 =~ s/BUTTON_NEXT// ;
    $out_form2 =~ s/OPTIONS// ;
  }
  else
  { $out_form2 = "" ; }

  $out_page_header2  = $out_page_header ;

  if (($out_page_subtitle eq "&nbsp;") && ($out_explanation eq ""))
  {
    $out_page_header2 =~ s/<tr><td class=l><h3>PAGE_SUBTITLE<\/h3><\/td>// ;
    $out_page_header2 =~ s/<td valign='top' class=r>EXPLANATION<\/td><\/tr>// ;
  }

  $out_page_header2 =~ s/FORM/$out_form2/ ;
  $out_page_header2 =~ s/PAGE_TITLE/$out_page_title/ ;
  $out_page_header2 =~ s/PAGE_SUBTITLE/$out_page_subtitle/ ;
  $out_page_header2 =~ s/EXPLANATION/$out_explanation/ ;
  $out_page_header2 =~ s/CROSSREF/$out_crossref/ ;

  $out_page_header2 =~ s/<h2>(.*?)(<b>.*?<\/b>)<\/h2>/<h2>$1<\/h2>$2/m ; # exception for sitemap page

  if ($unicode)
  { $out_meta_charset  = $out_meta_utf8 ; }
  else
  { $out_meta_charset  = $out_meta_8859 ; }

# if ($mode_wp)
# { $out_special_msg = "<small><font color=#800000>Note: Statistics for English Wikipedia are temporarily not available due to technical problems.</font></small><p>" ; }
  if ($out_msg ne "")
  { $out_msg = "$out_msg" ; }

  $out_html  = $out_html_doc .
               "<html lang=\"$out_html_language\">\n<head>\n" .
               "<title>".$out_html_title."</title>\n" .
               $out_meta_charset . $out_meta_robots .
               $out_scriptfile . $out_style .
               "</head>\n\n" .
               "<body bgcolor='#FFFFDD'>\n" .
               $out_page_header2 . $out_msg . "<hr class=b>$out_special_msg\n" ;
  if (($language eq "ja") || ($language eq "zh"))
  { $out_html =~ s/<\/?b>//g ; }
}

sub GenerateColophon
{
  my $comparison =  shift ;
  my $ploticus = shift ;
  my $r = shift ;
  my $out_sort_order3 = "" ;
  my $out_comparison2 = "" ;
# my $out_phaseIII2 = "" ;
  my $out_ploticus2 = "" ;
  my $dumpdate2 ;
  my $out_history ;

# debug:
# if ($comparison)
# { &Log ("\nCOMPARISON: YES\n") ; }
# else
# { &Log ("\nCOMPARISON: NO\n") ; }

  if ($mode_wv)
  { $out_history = "Note: Before the official launch of Wikiversity as a project, in August 2006," .
                   "<br>some course materials were already produced on <a href='http://www.wikibooks.org'>Wikibooks</a>.<br>" .
                   "Wikistats pages that show monthly trends include that early history.<p>" ; }

# $out_phaseIII =~ s/Phase III/<a href='http:\/\/www.mediawiki.org'>Wikimedia<\/a>/ ;

  $out_sort_order3 = $out_sort_order . "<br>" ;
  if ((($comparison) && (! $mode_wx) && (! $singlewiki)) || $pageviews)
  {
    $out_sort_order3 = $out_sort_order2 . "<br>" ;
    if (($skip_threshold ne "") && ($skipprojects2 ne ""))
    {
      $out_comparison3 = "$out_comparison<br>" ;
      $out_comparison3 =~ s/\{xxx\}/$skip_threshold/ ;
      $out_comparison3 =~ s/\{yyy\}/\($not_skipped\)/ ;
      $out_comparison3 .= "$out_not_included: $skipprojects2<p>" ;
    }
    # if ($generate_sitemap)
    # { $out_comparison3 = "" ; }
  }
# if ($comparison)
# { $out_phaseIII2 = $out_phaseIII . "<br><br>" ; }
  if ($ploticus)
  { $out_ploticus2 = "<p>$out_rendered <a href='http://ploticus.sourceforge.net/'>Ploticus</a>\n" ; }
  if ($r)
  { $out_r = "<p>$out_rendered <a href='http://www.r-project.org/'>R</a>\n" ; }


  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
  }

  $path_scripts = "http://stats.wikimedia.org/scripts.zip" ;

  if ($out_delay ne "")
  { $out_delay = "$out_delay<p>" ; }

  $out_html .= "<p><small>\n" .
#              ($wikimedia ? $out_sort_order3 : "") .
               $out_history . "\n" .
               $out_sort_order3 .
               (($sitemap_new_layout) ? $participation {"intro"} : "") .
               $out_comparison2 .
               $out_generated . &GetDate (time) . " " .
               ($pageviews ? $out_pageviewfiles : $out_sqlfiles) .
               &GetDate ($dumpdate2) . "\n<br>" .
               (! $pageviews ? $out_delay : "") .
               (! $wikimedia ? "$out_no_wikimedia<br>" : "") .
               $out_version . $version . "\n<br>" .
               $out_author . ":" . $out_myname .
               " (<a href='" . $out_mysite . "'>" . $out_site . "</a>)\n<br>" .
               ($wikimedia ? $out_mail . ":" . $out_mymail . "<br>\n" : "") .
               ($wikimedia ? $out_documentation . "<br>\n" : "" ) .
               ($wikimedia ? $out_scripts . ": <a href='$path_scripts'>scripts.zip</a>\n" : "") .
               $out_translator . "\n" .
               $out_ploticus2 . $out_r . "\n" .
               ((! $wikimedia && $mail ne "") ? "<p>" .$siteadmin . "\n" . $mail . "\n" : "") .
               $out_index_timelines . "\n<br><br>" .
               ($wikimedia ? $out_license : "") .
               "</small>\n" ;
#              "</small>\n$out_counter\n" ;

  # add dummy tables to satisfy javascript
  for ($i = 1 ; $i <= 7 ; $i++)
  {
    # if (index ($out_html, 'table' . $i) == -1)
    # { $out_html .= "<table border=0 cellspacing=0 id=table" . $i . " style='' summary=''>" .
    #                "<tr><td>&nbsp;</td></tr></table>\n" ; }
    if (index ($out_html, 'table' . $i) == -1)
    { $out_html .= "<table border=0 id=table$i><tr><td></td></tr></table>\n" ; }
  }
}

sub GenerateCrossReference
{
  my $language = shift ;
  my @other_languages = split (",", $crossref) ;
  my $tillbreak = int ($#other_languages / 2) ;
  my $out_crossref ;
  foreach my $other (@other_languages)
  {
    if ($other ne $language)
    {
      $out_crossref .= " <a href='../" . uc ($other) . "/Sitemap.htm'>" .
                       $out_languages_org {$other} . "</a>" ;
      $tillbreak -- ;
      if ($tillbreak == 0)
      { $out_crossref .= "<br>" ; }
      else
      { $out_crossref .= " |" ; }
    }
  }
  $out_crossref =~ s/\|$// ;
  return ($out_crossref) ;
}

# small html formatting functions

1;
