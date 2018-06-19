#!/usr/bin/perl

# html reports no longer generated, after migration from predecessor SquidReportArchive.pl:

# WriteReportBrowsersTimed
# WriteReportClients
# WriteReportCountriesInfo
# WriteReportCountryBrowser
# WriteReportCountryOpSys
# WriteReportCrawlers
# WriteReportDevices
# WriteReportDevicesTimed
# WriteReportGoogle
# WriteReportMethods
# WriteReportMimeTypes
# WriteReportOpSys
# WriteReportOrigins
# WriteReportScripts
# WriteReportSkins
# WriteReportUserAgents
# WriteReportUserAgentsTimed

# 2018-04 csv_shorten_demographics: no longer shorten demographics for csv files (still do for html files)  
# csv files are now also post processed into json file, which could benefit from more detailed figures
# so for WiViVi shortening needs to be done in javascript 
# for request data (= page views) shortening still provides some fuzziness on purpose 

sub PrepHtml
{
  my ($reports_set,$sample_rate) = @_ ;

  &LogSub ("PrepHtml\n\n") ;

  $language = "en" ;
  $header = &HtmlHead ;

  $body_top = &HtmlBodyTop ;

  if ($sample_rate == 1)
  { $header_sample_rate = "1:1 unsampled" ; }
  else
  { $header_sample_rate = "1:$sample_rate sampled" ; }

  $run_time = "<font color=#888877>" . date_time_english (time) . " UTC</font> " ;

  $header.=  "\n<body bgcolor='\#FFFFDD'>\n$body_top\n<hr>" .
            "$run_time<p>\nALSO<p>NOTICE" ;

  if ($set_reports eq 'country_reports')
  {
    $errata .= "<p><p>&nbsp;<font color=#900000>WMF traffic logging service suffered from server capacity problems from Nov 2009 till July 2010 and again in Aug/Sep/Oct 2011.<br>" .
               "&nbsp;Data loss only occurred during peak hours. It therefore may have had somewhat different impact for traffic from different parts of the world." ;
  }
  else
  {
    $errata .= "<font color=#900000>WMF traffic logging service suffered from server capacity problems in Aug/Sep/Oct 2011.<br>" .
               "Absolute traffic counts for October 2011 are approximatly 7% too low.<br>" .
               "Data loss only occurred during peak hours. It therefore may have had somewhat different impact for traffic from different parts of the world.<br>" .
               "and may have also skewed relative figures like share of traffic per browser or operating system.</font><p>" ;
    $errata .= "<font color=#900000>From mid September till late November squid log records for mobile traffic were in invalid format.<br>" .
               "Data could be repaired for logs from mid October onwards. Older logs were no longer available.</font><p>" ;
    $errata .= "<font color=#900000>In a an unrelated server outage precisely half of traffic to WMF mobile sites was not counted from Oct 16 - Nov 29 (one of two load-balanced servers did not report traffic).<br>" .
               "WMF has since improved server monitoring, so that similar outages should be detected and fixed much faster from now on.</font><p>" ;
  }

  if ($reports_set eq $reports_set_countries)
  {
  # $notice = "<p><font color=red>" .
  #           "&nbsp;Unresolved Bugzilla bugs: " .
  #           "<a href='https://bugzilla.wikimedia.org/show_bug.cgi?id=55443'>55443</a>" .
  #           "</font><p><font color=green>" .
  #            "Recently resolved bugs: " .
  #           "<a href='https://bugzilla.wikimedia.org/show_bug.cgi?id=46205'>46205</a> (Aug 2013)" .
  #           "<a href='https://bugzilla.wikimedia.org/show_bug.cgi?id=46289'>46289</a> (Nov 2013)" .
  #           "</font><p>" ;
  }
  $header =~ s/NOTICE/$notice/ ;

  # to be localized some day like any reports
  $out_explorer     = "<font color=#800000>Note: page may load slower on Microsoft Internet explorer than on other major browsers</font>" ;
  $out_license      = "All data and images on this page are in the public domain." ;
  $out_generated    = "Generated on " ;
  $out_author       = "Author" ;
  $out_mail         = "Mail" ;
  $out_site         = "Web site" ;

  $out_myname_ez = "Erik Zachte" ;
  $out_mymail_ez = "ezachte\@### (no spam: ### = wikimedia.org)" ;
  $out_mysite_ez = "//infodisiac.com/" ;

  $colophon_ez = "<p><a id='errata' name='errata'><b>Errata:</b> $errata<p>\n" .
               $out_generated . date_time_english (time) . "\n<br>" .
               $out_author . ":" . $out_myname_ez . ' ' .
               " (<a href='" . $out_mysite_ez . "'>" . $out_site . "</a>)<br>" .
               "$out_mail: $out_mymail_ez<br>\n" .
               "$out_license<p>" .
               "$out_explorer" .
               "</small>\n" .
               "</body>\n" .
               "</html>\n" ;


  $errata = 'No data loss or anomalies reported' ; 

  $dummy_countries   = "<font color=#000060>Countries</font>" ;

  $link_countries_overview = "<a href='SquidReportPageViewsPerCountryOverview.htm'>Overview</a>" ;
  $link_countries_projects = "<a href='SquidReportPageViewsPerCountryBreakdown.htm'>Projects</a>" ;
  $link_countries_trends = "<a href='//stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Trends</a>" ;
  $link_trends_countries = "<a href='//stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Countries</a>" ;
}

sub WriteReportPerLanguageBreakDown
{
  &LogSub ("WriteReportPerLanguageBreakDown\n") ;

  my ($title,$views_edits,$links) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my @index_countries ;
  my $views_edits_lc = lc $views_edits ;

  $html  = $header ;
  $html =~ s/WORLDMAP_D3// ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/ALSO// ;
  $html =~ s/LINKS/$links/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (23) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  my $languages_reported ;

  foreach $language (keys_sorted_by_value_num_desc %requests_recently_per_language)
  {
    next if $requests_recently_per_language {$language} < 100 ;

    ($language_name,$anchor_language) = &GetLanguageInfo ($language) ;

    my %requests_per_country = %{$requests_recently_per_language_per_country {$language}} ;
    @countries = keys_sorted_by_value_num_desc %requests_per_country ;

    my $requests_this_language = $requests_recently_per_language {$language} ;

    $perc_global = '..' ;
    if ($requests_recently_all > 0)
    { $perc_global = &Percentage ($requests_this_language / $requests_recently_all) ; }

    $html_total .= "<tr><td colspan=6>&nbsp;</td><td colspan=8>&nbsp;</td><td colspan=8>&nbsp;</td></tr>" ;

    $html .= "<tr><th colspan=8 class=lh3><a id='$anchor_language' name='$anchor_language'></a><br>$language_name ($language) <small>($perc_global share of world total)</small></th></tr>" ;

    if ($languages_reported % 2 == 0)
    { $gif = "bluebar_hor.gif" ; }
    else
    { $gif = "greenbar_hor2.gif" ; }

    $perc_tot = 0;
    for ($l = 0 ; $l < 50 ; $l++)
    {
      my $requests_this_country  = $requests_recently_per_language_per_country {$language} {$countries [$l]} ;
      my $requests_all_countries = $requests_recently_per_language             {$language} ;
      $perc = 0 ;
      if ($requests_all_countries > 0)
      {
        $perc = &Percentage ($requests_this_country / $requests_all_countries) ;

        last if ($perc < 0.5) || (($perc_global < 0.1) && ($perc < 1) || (($perc_global < 0.01) && ($perc < 3)) || (($perc_global < 0.001) && ($perc < 5))) ;

        $perc_tot += $perc ;
      }

      $country = $countries [$l] ;
      $country =~ s/ .*$// if length ($country) > 20 ;
      $bar_width = int ($perc * $perc2bar) ;

      $bar_100 = "" ;
      if ($bars++ == 0)
      {
        $bar_width_100 = 600 - $bar_width ;
        $bar_100 = "<img src='white.gif' width=$bar_width_100 height=15>" ;
        $bar_100 = '' ; # until gif is added
      }
      if (($country =~ /Australia/) && ($language_name =~ /Japanese/) && ($perc > $perc2bar))
      { $perc .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}
      $html .= "<tr><th class=l class=small nowrap>$country</th>" .
             # "<td class=c>[$requests_this_country ]$perc</td>" .
               "<td class=c>$perc</td>" .
               "<td class=l><img src='$gif' width=$bar_width height=15>$bar_100</td></tr>\n" ;
    }

    if ($perc_tot > 100) { $perc_tot = 100 ; }

    $perc_other = sprintf '%.1f', 100 - $perc_tot ;
    if ($perc_other > 0)
    {
      $bar_width = $perc_other * $perc2bar ;
      $html .= "<tr><th class=l class=small nowrap>Other</th>" .
               "<td class=c>$perc_other%</td>" .
               "<td class=l><img src='$gif' width=$bar_width height=15></td></tr>\n" ;
    }

    push @index_languages, "<a href='#$anchor_language'>$language_name</a> " ;

  # print "\n" ;
  # $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  }
  $html .= "</table>" ;
  $html .= "<p><b>Share<\/b> is the percentage of requesting ip addresses (out of the world total) which originated from this country" .
           "<br>&nbsp;Further percentages show per country share of requests per Wikipedia visited" ;
  $html .= "<p>Countries are only included if the number of requests in the period exceeds 100,000 (100 matching records in 1:1000 sampled log)" ;
  $html .= "<br>Page requests by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " ;
  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_languages)) ;
  $html =~ s/INDEX/$index/ ;

  &PrintHtml ($html, "$path_reports/$file_html_per_language_breakdown") ;
}

sub WriteReportPerCountryOverview
{
  &LogSub ("WriteReportPerCountryOverview\n") ;

  my ($title,$views_edits,$links,$sample_rate) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my (@index_countries,@csv_countries) ;
  my $views_edits_lc = lc $views_edits ;
  my $views_edits_lcf = ucfirst $views_edits_lc ;

  if ($views_edits =~ /edit/i)
  { $MPVE = 'MPE' ; } # monthly page edits
  else
  { $MPVE = 'MPV' ; } # monthly page views

  $html  = $header ;
  $html =~ s/WORLDMAP_D3// ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS/$links/ ;
  $html =~ s/ALSO// ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;
  
  &AddNoticeSurvey (21) ;

  $html .= &HtmlSortTable ;

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a>\n" ;

  $html .= "<p><table border=1 width=800 class=tablesorter id=table1>\n" ;
  $html .= "<thead>\n" ;
  $html .= "INDEX\n" ;

  $html .= &HtmlWorldMapsFixed ;

  $html .= "<tr><td class=hr colspan=3 rowspan=1><b>Location</b></td>" .
               "<td class=hc colspan=2 rowspan=2><b>Population</b><br><small><font color=#404040>absolute count and percentage of world population</font></small></td>" . # <td class=hc rowspan=2><b>$MPVE's<br>Per<br>Person</b></td>" .
               "<td class=hc colspan=2 rowspan=2><b>Internet<br>Users</b><br><small><font color=#404040>absolute count and percentage of country population</font></small></td>" .
               "<td class=hl colspan=4 rowspan=1><b>Monthly $views_edits</b></td></tr>\n" ;
#  $html .= "<tr>" .
#             # "<td class=hc><b>${MPVE}'s<br>Per<br>I U</b></td>" .
#               "<td colspan=99 class=hc><b>Share in Global Monthly $views_edits</b><br><small><font color=#808080>red and blue bars have different scale</font></small></td></tr>\n" ;
  $html .= "<tr><td class=hr><b>Country</b></td><td class=hc><b>Region</b><br><img src='//stats.wikimedia.org/Location_of_Continents2.gif'></td><td class=hc><b>N/S</b></td><td class=hc colspan=2><small><font color=#404040>absolute count and monthly ${views_edits}s per internet user</font></small></td><td class=hl colspan=2><small>share of world total<font color=#808080><p>note:blue and red bars have different scale</font></small></td></tr>\n" ;
  $html .= "<tr><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th colspan=2>&nbsp;</th></tr>\n" ;
  $html .= "</thead><tbody>\n" ;
  $html .= "TOTAL\nREGIONS\n" ;

  push @csv_countries, "# Wikimedia Traffic Analysis Report - Wikipedia $views_edits Per Country - Overview\n" .
                       "# Report based on data from $requests_recently_start - $requests_recently_stop\n" .
                       "country name, country code, monthly $views_edits_lc,population,internet users,internet penetration,monthly $views_edits_lc per internet user,share of global $views_edits_lc\n" ;

  $requests_tot = 0 ;

  undef %requests_per_region ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_recently_per_country_code)
  {
    my ($country,$code) = split ('\|', $country_code) ;

    my $region_code      = $region_codes {$code} ;

    if ($region_code eq '')
    { $region_code = 'XX' ; } 

  #  if ($region_code eq 'XX')
  # { print "$code $country $region_code\n" ; exit ; } # debug only # qqq 

    my $north_south_code = $north_south_codes {$code} ;

    $region_name = $region_code ;
    $region_name =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region_name =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region_name =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region_name =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region_name =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region_name =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region_name =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;
    $region_name =~ s/^XX$/<font color=#808080><b>Unknown1<\/b><\/font>/ ;

    $north_south_name = $north_south_code ;
    $north_south_name =~ s/^N$/<font color=#000BF7><b>N<\/b><\/font>/ ;
    $north_south_name =~ s/^S$/<font color=#FE0B0D><b>S<\/b><\/font>/ ;

    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;
     
    my $requests_this_country  = $requests_recently_per_country {$country} ;
    my $requests_this_country2 = int ($requests_this_country * $sample_rate / $months_recently) ;
    $requests_tot += $requests_this_country2  ;

    $requests_per_region {$region_code}      += $requests_this_country ;
    $requests_per_region {$north_south_code} += $requests_this_country ;
    $requests_per_region2 {$region_code}      += $requests_this_country2 ;
    $requests_per_region2 {$north_south_code} += $requests_this_country2 ;

    $requests_per_person = ".." ;
    if ($population > 0)
    { $requests_per_person    = sprintf ("%.0f", $requests_this_country2 / $population) ; }

    $requests_per_connected_person = ".." ;
    if ($connected > 0)
    {
      if ($views_edits =~ /edit/i)
      { $requests_per_connected_person = sprintf ("%.4f", $requests_this_country2 / $connected) ; }
      else
      {
        if ($requests_this_country2 / $connected >= 1.95)
        { $requests_per_connected_person = sprintf ("%.0f", $requests_this_country2 / $connected) ; }
        else
        { $requests_per_connected_person = sprintf ("%.1f", $requests_this_country2 / $connected) ; }
      }
    }

    $perc_share_total = '..' ;
    if ($requests_recently_all > 0)
    { $perc_share_total = &Percentage ($requests_this_country / $requests_recently_all) ; }
    $perc_share_total2 = $perc_share_total ;    
    # if ($perc_share_total2 =~ /0\.0/)
    # { $perc_share_total2 = '<font color=#CCC><small><&nbsp;0.1%</small></font>' ; }

    &Percentage ($requests_this_country / $requests_recently_all) ; 
    
    $perc_tot += $perc_share_total ;

    $bar = "&nbsp;" ;
    $bar2 = "&nbsp;" ;
    if (int ($perc_share_total * 10) > 0)
    { 
    # $bar  = &Perc2Bar ($share_requests,'redbar_hor',15) ;
    # $bar2 = &Perc2Bar ($share_requests,'redbar_hor',12) ;
      $bar  = "<img src='redbar_hor.gif' width=" . (int ($perc_share_total * $perc2bar)) . " height=15>" ; 
      $bar2 = "<img src='redbar_hor.gif' width=" . (int ($perc_share_total * $perc2bar)) . " height=12>" ; 
    }

    $perc_connected = ".." ;
    if ($population > 0)
    { $perc_connected = sprintf ("%.0f", 100 * $connected / $population) .'%' ; }

    # now use country names that are suitable for http://gunn.co.nz/map/
    $country2 = $country ;
    $country2 =~ s/Moldova, Republic of/Moldova/ ;
  # $country2 =~ s/Korea, Republic of/South Korea/ ;
  # $country2 =~ s/Korea, Democratic People's Republic of/North Korea/ ;
    $country2 =~ s/Iran, Islamic Republic of/Iran/ ;
    $country2 =~ s/UAE/United Arab Emirates/ ;
    $country2 =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
  # $country2 =~ s/Congo - The Democratic Republic of the/Congo Dem. Rep./ ;
  # $country2 =~ s/^Congo$/Republic of the Congo/ ;
    $country2 =~ s/Syrian Arab Republic/Syria/ ;
    $country2 =~ s/Tanzania, United Republic of/Tanzania/ ;
    $country2 =~ s/Libyan Arab Jamahiriya/Libya/ ;
    $country2 =~ s/C..?te d'Ivoire/C&ocirc;te d'Ivoire/ ;
    $country2 =~ s/Serbia/republic of serbia/ ;
    $country2 =~ s/Lao People's Democratic Republic/Laos/ ;


    push @csv_countries, "$country2,$code,$requests_this_country2,$population,$connected,$perc_connected,$requests_per_connected_person,$perc\n" ;

    $population2 = &i2KM2 ($population) ;
    $connected2  = &i2KM2 ($connected) ;
    $requests_this_country2 = &i2KM2 ($requests_this_country2) ;

    if ($population_tot > 0)
    { $perc_population = &Percentage ($population / $population_tot) ; }

   # if ($perc_population =~ /\.0\d/)
   # { $perc_population = "<font color=#CCC><small>$perc_population</small></font>" ; }

    $html .= "<tr><th class=rh3><a id='$country' name='$country'></a>$link_country $icon</td>" .
                 "<td>$region_name</td>" .
                 "<td>$north_south_name</td>" .
                 "<td>$population2</td>" . # <td>$requests_per_person</td>" .
                 "<td>$perc_population</td>" . # <td>$requests_per_person</td>" .
                 "<td>$connected2</td>" .
                 "<td>$perc_connected</td>" .
                 "<td>$requests_this_country2</td>" .
                 "<td>$requests_per_connected_person</td>" .
                 "<td>$perc_share_total</td>" .
                 "<td class=l>$bar</td></tr>\n" ;

  #  if (($region_code eq 'AF') || ($region_code eq 'AS') || ($region_code eq 'EU'))
  #  { $icon = "<sub><sub>$icon</sub></sub>" ; }
    
    $link_country =~ s/<\/?a[^>]*>//g ;
    $link_country =~ s/alt=['"]+ // ;
    $link_country =~ s/Democratic Republic of the Congo/Congo Dem. Rep./ ;
    
    if ($verbose)
    { push @index_countries, "<a href=#$country>$country ($perc)</a>\n " ; }
    else
    { push @index_countries, "<a href=#$country>$country</a>\n " ; }
  }

  $requests_per_person_tot =  '..' ;

  if ($population_tot > 0)
  { $requests_per_person_tot = sprintf ("%.0f", $requests_tot / $population_tot) ; }

  if ($connected_tot > 0)
  {
    if ($views_edits =~ /edit/i)
    { $requests_per_connected_person_tot = sprintf ("%.4f", $requests_tot / $connected_tot) ; }
    else
    { $requests_per_connected_person_tot = sprintf ("%.1f", $requests_tot / $connected_tot) ; }
  }
  
  $perc_connected_tot = ".." ;
  if ($population_tot > 0)
  { $perc_connected_tot = sprintf ("%.0f", 100 * $connected_tot / $population_tot) .'%' ; }

  push @csv_countries, "world,*,$requests_tot,$population_tot,$connected_tot,$perc_connected_tot,$requests_per_connected_person_tot,100%\n" ;

  $requests_tot2   = &i2KM2 ($requests_tot) ;
  $population_tot2 = &i2KM2 ($population_tot) ;
  $connected_tot2  = &i2KM2 ($connected_tot) ;

  $html_total = "<tr><th class=rh3>All countries in</td>" .
                    "<td><b>World</b></td>" .
                    "<td>&nbsp;</td>" .
                    "<td>$population_tot2</td>" .
                    "<td>100%</td>" .
                    "<td>$connected_tot2</td>" .
                    "<td>$perc_connected_tot</td>" .
                    "<td>$requests_tot2</td>" .
                    "<td>$requests_per_connected_person_tot</td>" .
                    "<td>100%</th>" .
                    "<td class=l>&nbsp;</td></tr>\n" ;
  $html_total .= "<tr><td colspan=99>&nbsp;</td></tr>" ;


  $html_regions = '' ;
  foreach $key (qw (N S AF AS EU CA NA SA OC XX))
  {
    $region = $key ;
    $region2 = $region ;

    $region =~ &RegionCodeToText ($region) ; # e.g. $region =~ s/^N$/<font color=#000BF7><b>Global North<\/b><\/font>/ ;

    $population_region = $population_per_region {$key} ;
    $connected_region  = $connected_per_region  {$key} ;
    $requests_region   = $requests_per_region   {$key} ;
    $requests_region2  = $requests_per_region2  {$key} ; # qqq

    $perc_connected_region = ".." ;
    if ($population_region > 0)
    { $perc_connected_region = sprintf ("%.0f", 100 * $connected_region / $population_region) .'%' ; }

    $perc_share_total = '..' ;
    if ($requests_recently_all > 0)
    { $perc_share_total = &Percentage ($requests_region / $requests_recently_all) ; }

    $perc_population_region = ".." ;
    if ($population_region > 0)
    { $perc_population_region = &Percentage ($population_region / $population_tot) ; }

 #  $requests_region2 = int ($requests_region * 1000 / $months_recently) ;

    $requests_per_connected_person = '..' ;
    if ($connected_region > 0)
    {
      if ($views_edits =~ /edit/i)
      { $requests_per_connected_person = sprintf ("%.4f", $requests_region2 / $connected_region) ; }
      else
      { $requests_per_connected_person = sprintf ("%.0f", $requests_region2 / $connected_region) ; }
    }

    $population_region = &i2KM2 ($population_region) ;
    $connected_region  = &i2KM2 ($connected_region) ;
    $requests_region   = &i2KM2 ($requests_region) ;
    $requests_region2  = &i2KM2 ($requests_region2) ;

    $bar = "&nbsp;" ;
  # if ($perc_share_total > 0)
    if (int ($perc_share_total * 3) > 0)
    { $bar = "<img src='bluebar_hor.gif' width=" . (int ($perc_share_total * 3)) . " height=15>" ; }

 #  $html_regions .= &WriteReportPerCountryOverviewLine ("All countries in", $region, '', $requests, $population) ;

    if ($key ne 'XX')
    {
      $html_regions .= "<tr><th>All countries in</th>" .
                       "</td><td>$region</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>$population_region</td>" .
                       "<td>$perc_population_region</td>" .
                       "<td>$connected_region</td>" .
                       "<td>$perc_connected_region</td>" .
                       "<td>$requests_region2</td>" .
                       "<td>$requests_per_connected_person</td>" .
                       "<td>$perc_share_total</th>" .
                       "<td class=l>$bar</td></tr>\n" ;
    }
    else
    {
      $html_regions .= "<tr><th>Remainder</th>" .
                       "</td><td>$region</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>$requests_region2</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>$perc_share_total</th>" .
                       "<td class=l>$bar</td></tr>\n" ;
    }

    if (($key eq 'S') || (($key eq 'XX')))
    { $html_regions .= "<tr><td colspan=99>&nbsp;</td></tr>" ; }
  }


  $html .= "</tbody>\n</table>" ;
  $html .= "<br>$views_edits_lcf by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " ;
  $html .= "Country meta data collected from English Wikipedia (<a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>population</a>, <a href='//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>internet users</a>)). " ;
# $html .= "<br>Monthly $views_edits_lc per person is calculated over total population, regardless of age and internet connectivity" ; # how come, misplaced here ?!

  $html .= &HtmlSortTableColumns; ;
  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;
  $html =~ s/TOTAL/$html_total/ ;
  $html =~ s/REGIONS/$html_regions/ ;

  &PrintHtml ($html, "$path_reports/$file_html_per_country_overview") ;
}

# input for http://gunn.co.nz/map/
sub WriteCsvFilePerCountryDensity
{
  my ($views_edits, $period, $ref_requests_per_period_per_country, $max_requests_per_connected_us, $desc_animation, $sample_rate) = @_ ;

  &LogSub ("WriteCsvFilePerCountryDensity (input for input for //gunn.co.nz/map/) $views_edits\n\n") ;

  my %requests_per_country_code = %{$ref_requests_per_period_per_country -> {$period}} ;

  my $description = $descriptions_per_period {$period} ;
  my $postfix     = $descriptions_per_period {$period} ;
# $test = join '', sort values %requests_per_country_code ;
# print $test . "\n\n" ;

  my ($link_country,$country,$code,$population,$connected,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot,$requests_max,$requests_this_country,$requests_this_country2) ;
  my (@index_countries,@csv_countries,%svg_groups,%percentage_of_total_pageviews,%requests_per_connected_persons) ;

  undef @csv_countries ;
  $header_csv_countries = "# Wikimedia Traffic Analysis Report - Wikipedia $views_edits Per Country Per Internet User\n" .
                          "# Data file is input for //gunn.co.nz/map/\n" .
                          "# See also //infodisiac.com/blog/2012/02/wikipedia-readers/\n" .
                          "country,requests,population,monthly views per inhabitant,internet users,%connected,requests per user\n" ;
                        # "country,code,views,population,internet users,%connected,views per user,%global views\n" ;

  $requests_tot = 0 ;
  undef %fills ;

#  # normalize to 100% average
#  $requests_cnt = 0 ;
#  $requests_tot = 0 ;
#  foreach $country_code (keys %requests_per_country_code)
#  {
#    $requests_cnt ++ ;
#    $requests_tot += $requests_per_country_code {$country_code} ;
#  }

#  abort ("\$requests_cnt == 0") if $requests_cnt == 0 ;
#  $requests_avg = $requests_tot / $requests_cnt ;
#  print "requests cnt: $requests_cnt, tot: $requests_tot, avg: $requests_avg\n" ;

#  abort ("\$requests_avg == 0") if $requests_avg == 0 ;
#  foreach $country_code (keys %requests_per_country_code)
#  { $requests_per_country_code {$country_code} *= 100/$requests_avg ; }
#  # normalize complete

# print "$code, $country: $requests_this_country\n" ;
  $requests_this_country  = $requests_per_country_code {$country_code} ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_per_country_code)
  {
    ($country,$code) = split ('\|', $country_code) ;

    $country =~ s/Korea, Republic of/South Korea/ ;

    if ($country =~ /korea/i)
    { $a = 1 ; }
    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

    $requests_this_country  = $requests_per_country_code {$country_code} ;

    $requests_this_country  = &CorrectForMissingDays ($period, $requests_per_country_code {$country_code} * 1000, $code, "\$requests_this_country") ;

    $requests_this_country  = sprintf ("%.1f", $requests_this_country) ; # quarterly -> monthly average
    $requests_tot += $requests_this_country ;

    $requests_per_person = ".." ;
    if ($population > 0)
    { $requests_per_person    = sprintf ("%.4f", $requests_this_country / $population) ; }

    $requests_per_connected_person = ".." ;
    if ($connected > 0)
    {
    # if ($requests_this_country / $connected >= 1.95)
    # { $requests_per_connected_person = sprintf ("%.0f", $requests_this_country / $connected) ; }
    #  else
    #  { $requests_per_connected_person = sprintf ("%.1f", $requests_this_country / $connected) ; }
      $requests_per_connected_person = sprintf ("%.4f", $requests_this_country / $connected) ;
    }

    $perc = '0.0' ;
    $requests_all = &CorrectForMissingDays ($period, $requests_all_per_period {$period} * 1000, $code, "\$requests_all") ;
    if ($requests_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_all) ; }
    $perc_tot += $perc ;

    $perc_connected = ".." ;
    if ($population > 0)
    { $perc_connected = sprintf ("%.1f", 100 * $connected / $population) .'%' ; }

    # now use country names that are suitable for //gunn.co.nz/map/
    $country =~ s/UAE/United Arab Emirates/ ;                                                 # http://gunn.co.nz/map/
    $country =~ s/Congo Dem. Rep./Democratic Republic of the Congo/ ;                         # http://gunn.co.nz/map/
  # $country =~ s/^Congo$/Republic of the Congo/ ;                                            # http://gunn.co.nz/map/
  # $country =~ s/Cote d'Ivoire/Côte d'Ivoire/ ;                                              # http://gunn.co.nz/map/
    $country =~ s/Serbia/Republic of Serbia/ ;                                                # http://gunn.co.nz/map/

  # $country =~ s/Moldova, Republic of/Moldova/ ;
  # $country =~ s/Korea, Republic of/South Korea/ ;
  # $country =~ s/Korea, Democratic People's Republic of/North Korea/ ;
  # $country =~ s/Iran, Islamic Republic of/Iran/ ;
  # $country =~ s/UAE/United Arab Emirates/ ;
  # $country =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
 ## $country =~ s/^Congo$/Republic of the Congo/ ;
  # $country =~ s/Syrian Arab Republic/Syria/ ;
  # $country =~ s/Tanzania, United Republic of/Tanzania/ ;
  # $country =~ s/Libyan Arab Jamahiriya/Libya/ ;
 ## $country =~ s/Cote d'Ivoire/Côte d'Ivoire/ ;
  # $country =~ s/Serbia/republic of serbia/ ;
  # $country =~ s/Lao People's Democratic Republic/Laos/ ;
  #  $country =~ s/,/./g ;

#Missing values for large countries (large as visible on http://gunn.co.nz/map/)
#Democratic Republic of the Congo,372000.0,..,..,..,..
#Sudan,1917000.0,30894000,..,0.0%,..
#Somalia,35000.0,9557000,..,0.0%,..
#Republic of the Congo,114000.0,4140000,..,0.0%,..
#Myanmar,663000.0,48337000,..,0.0%,..
#North Korea,10000.0,..,..,..,..
#South Korea,61397000.0,48219000,..,0.0%,..
#Sierra Leone,65000.0,5997000,..,0.0%,..

  # push @csv_countries, "\"$country\",$code,$requests_this_country,$population,$connected,$perc_connected,$requests_per_connected_person,$perc,$requests_svg,$ratio_svg,$fill_svg\n" ;
    # for http://gunn.co.nz/map/
    push @csv_countries,"$country,$requests_this_country,$population,$requests_per_person,$connected,$perc_connected,$requests_per_connected_person\n" ;

    $requests_per_connected_persons {lc $code} = $requests_per_connected_person ;
    $requests_per_persons           {lc $code} = $requests_per_person ;
    $percentage_of_total_pageviews  {lc $code} = $perc ;
  }

  $requests_per_person_tot =  '..' ;

  if ($population_tot > 0)
  { $requests_per_person_tot = sprintf ("%.1f", $requests_tot / $population_tot) ; }

  if ($connected_tot > 0)
  { $requests_per_connected_person_tot = sprintf ("%.1f", $requests_tot / $connected_tot) ; }

  $perc_connected_tot = ".." ;
  if ($population_tot > 0)
  { $perc_connected_tot = sprintf ("%.1f", 100 * $connected_tot / $population_tot) .'%' ; }

# push @csv_countries, "world,*,$requests_tot,$population_tot,$connected_tot,$perc_connected_tot,$requests_per_connected_person_tot,100%\n" ;
  &LogDetail ("$period $requests_tot\n") ;

  &PrintCsv  ($header_csv_countries . join ('', sort @csv_countries), "$path_csv/$file_csv_per_country_density") ;
}

sub WriteReportPerCountryBreakdown
{
  &LogSub ("WriteReportPerCountryBreakDown\n") ;

  &AddExtraCountryNames_iso3 ;

  my @index_countries ;
  my $views_edits_lc = lc $views_edits ;

  if ($sample_rate == 1) # edits
  { $report_version = '' ; }
  else
  {
    if ($show_logcount)
    { $report_version = "<p>Showing even small percentages (> $cutoff_percentage\%). " .
               "Switch to <a href='$file_html_per_country_breakdown'>concise version</a>" ; }
    else
    { $report_version = "<p>Showing only only major percentages (> $cutoff_percentage\%). " .
               " Switch to <a href='$file_html_per_country_breakdown_huge'>detailed version</a>" ; }
  }     

  $html  = $header ;  

  $folder_scripts = "//stats.wikimedia.org/wikimedia/squids/scripts/" ;
  $html =~ s/WORLDMAP_D3/<script src="$folder_scripts\/d3.min.js"><\/script>\n<script src="$folder_scripts\/topojson.min.js"><\/script>\n<script src="$folder_scripts\/datamaps.world.hires.min.js"><\/script>\n<script src="$folder_scripts\/options.js"><\/script>\n/ ;

  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS/$links/ ;
  $html =~ s/ALSO/$report_version/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (22) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  $html .= &HtmlWorldMapsFixed ;

  my $anomaly_found ;

  foreach $country (keys_sorted_by_value_num_desc %requests_recently_per_country)
  {
    # Q&D fix, if condition is enabled prints just 2 countries in SquidReportPageEditsPerCountryBreakdown.htm
    # now that we returned to sampled edits

    # next if $requests_recently_per_country {$country} < $cutoff_requests ;
    
    %requests_per_language = %{$requests_recently_per_country_per_language {$country}} ;
    @languages = keys_sorted_by_value_num_desc %requests_per_language ;

    $requests_this_country  = $requests_recently_per_country {$country} ;

#   $country_name = $country_names {$country_code} ;
#   $country_meta = $country_meta_info {$country_name} ;
    $country_meta = $country_meta_info {$country} ;

    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;
    $population  =~ s/_//g ;
    $connected   =~ s/_//g ;
    $population2 = &i2KM1 ($population) ;
    $requests_this_country2 = &i2KM1 ($requests_this_country * 1000) ; # input is in 1000's 
    $connected2  = '--' ;
    $requests_per_capita = '--' ;
     
    if ($population> 0)
    { 
      $connected2 = sprintf ("%.0f", 100*$connected/$population) .'%' ; 
      $requests_per_capita = &i2SigDec ($requests_this_country * 1000 / $population) ;
    } 

    $perc = 'n.a.' ;
    if ($requests_recently_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_recently_all) ; }

    ($link_country,$icon,$population) = &CountryMetaInfo ($country) ;

    $code_iso3 = $country_names_iso3 {$country} ;
    if ($code_iso3 eq '')
    { 
      print "no iso3166 code for '$country'\n" ; 
      $code_iso3 = 'XXX' ; 
    }
    
    # print "country $country -> $code_iso3\n" ;

    $icon =~ s/"/'/g ;
 
    $html .= "<tr><th colspan=99 class=lh3><a id='$country' name='$country'></a><br>$icon $link_country <small> $population2 people ($connected2 with internet) issued $requests_this_country2 requests ($perc of world total), or $requests_per_capita per person per month</small></th></tr>\n" ;

    $perc_tot = 0;
    $requests_used = 0 ;
    for ($l = 0 ; $l < 50 ; $l++)
    {
      $requests_this_language = $requests_recently_per_country_per_language {$country} {$languages [$l]} ;
      $requests_all_languages = $requests_recently_per_country              {$country} ;

      last if $requests_this_language == 0 ;

      $requests_used += $requests_this_language ;

      $perc = 0 ;
      if ($requests_recently_all > 0)
      {
        $perc = &Percentage ($requests_this_language / $requests_all_languages) ;

        last if $perc < $cutoff_percentage ;

        $perc_tot += $perc ;
      }

      $language = $languages [$l] ;
      if ($out_languages {$language} ne "")
      { $language = $out_languages {$language} ; }
      if (length ($language) > 20)
      { $language =~ s/ .*$// ; }
      $bar_width  = int ($perc * $perc2bar) ;
      $bar_width2 = int ($perc * $perc2bar2) ;
      if ($bar_width2 < 1)
      { $barwidth2 = 1 ; }

      if (($country eq "Australia") && ($language eq "Japanese") && ($perc > $perc2bar))
      { $language .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}

      $bar_100 = "" ;
      if ($bars++ == 0)
      {
        $bar_width_100 = 600 - $bar_width ;
        $bar_100 = "<img src='white.gif' width=$bar_width_100 height=15>" ;
        $bar_100 = '' ; # until gif is added
      }

      if ($language !~ /Portal/)
      { $language .= " Wp" ; }

      $perc =~ s/(\.\d)0/$1/ ; # 0.10% -> 0.1%
      if ($show_logcount && ($requests_this_language < 5 * $months_recently)) # show in grey to discuss threshold on foundation-l
      { $perc = "<font color=#800000>$perc</font>" ; }

      ($language2 = $language) =~ s/ Wp// ;

      $html .= "<tr><th class=l class=small nowrap>$language</th>" .
               ($show_logcount ? "<td class=r>$requests_this_language</td>" : "") .
               "<td class=c>$perc</td>" .
               "<td class=l><img src='yellowbar_hor.gif' width=$bar_width height=15>$bar_100</td></tr>\n" ;
    }

    if ($perc_tot > 100) { $perc_tot = 100 ; }
    $requests_other = $requests_all_languages - $requests_used ;
    $perc_other = sprintf '%.1f', 100 - $perc_tot ;
    if (($requests_other > 0) && ($perc_other > 0))
    {
      $bar_width = $perc_other * $perc_2bar ;
      $bar_width2 = int ($perc_other * * $perc2bar2) ;
      if ($bar_width2 < 1)
      { $barwidth2 = 1 ; }

      $html .= "<tr><th class=l class=small nowrap>Other</th>" .
               ($show_logcount ? "<td class=r>$requests_other</td>" : "") .
               "<td class=c>$perc_other%</td>" .
               "<td class=l><img src='yellowbar_hor.gif' width=$bar_width height=15></td></tr>\n" ;
    }

    if ($verbose)
    { push @index_countries, "<a href='#$country'>$country ($perc)</a> " ; }
    else
    { push @index_countries, "<a href='#$country'>$country</a> " ; }

  # print "\n" ;
  # $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  }
 
 
  $html .= "</table>" ;

#  $html .= "<p><a name='more' id='more'></a><b>Share<\/b> is the percentage of requesting ip addresses (out of the world total) which originated from this country" .
#           "<br>&nbsp;Further percentages show per country share of $views_edits_lc per Wikipedia visited" ;
  if ($sample_rate > 1)
  { $html .= "<p>Countries are only included if the number of requests in the period exceeds " . ($cutoff_requests * $sample_rate) . "\n" ; } 
# . "($cutoff_requests matching records in 1:$sample_rate sampled log)" ; }
  $html .= "<p>Wikipedia languages are only listed for some country if the share of requests from that particular country to that specific Wikipedia exceeds $cutoff_percentage\%." ;
  if ($show_logcount)
  {
    $html .= "<p>The second column displays the actual <b>numbers of records</b> found in the 1:$sample_rate sampled log on which the percentage is based." ;
    if ($sample_rate > 1)
    { $html .= "<br>Multiply by $sample_rate for actual $views_edits_lc over the whole period of $months_recently months." ; }
    $html .= "<br>If the number of records in the sampled log does not reach the (arbitrary) number of 5 per sampled month, the percentage is flagged dark red to extra emphasize high inaccuracy." ;
  }

  $html .= "<p>Page requests by search engine crawlers (aka bots) are not included.\n" . 
           "Country meta data collected from <a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>English Wikipedia</a>. " .
           "'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a>" ;
# if ($anomaly_found)
# { $html .= "<p><a id='anomaly' name='anomaly'>Probably anomaly caused by outdated <a href='//en.wikipedia.org/wiki/Regional_Internet_Registry'>Regional Internet Registry</a> administration.\n" ; }

  
  $html .= $colophon_ez ;
  $html =~ s/<a id='errata'.*?from now on.<\/font><p>// ; # Q&D fix: errata not on this report, which is not about historic data
# $html =~ s/<body bgcolor='#FFFFDD'>/<body>/ ; # Q#D fix: abandon Wikistats page coloring for reports to be continued after 2016  

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;
  $html =~ s/http://g ;

  if (! $show_logcount)
  { &PrintHtml ($html, "$path_reports/$file_html_per_country_breakdown") ; }
  else
  { &PrintHtml ($html, "$path_reports/$file_html_per_country_breakdown_huge") ; }
}

sub WriteReportPerCountryTrends
{
  exit ; # deprecated, too unreliable

  &LogSub ("WriteReportPerCountryTrends\n") ;

  my ($title,$views_edits,$links) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my @index_languages ;
  my $views_edits_lc = lc $views_edits ;

  $html  = $header ;
  $html =~ s/WORLDMAP_D3// ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS/$links/ ;
  $html =~ s/ALSO// ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_start - $requests_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html =~ s/\(last 12 months\)// ; # only report for all known months

  if ($views_edits eq 'Page Views')
  {
    $html .= "<p><font color=#800000>Nov 2011: For some countries the share of page views on the English Wikipedia was significantly higher in 2010 than in 2009 and 2011,<br>" .
           "especially in Q1 and Q2. We don't know yet what caused this, this might be an artifact. Please be cautious to draw conclusions from this.</font>" ;
  }

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (24) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  $html .= &HtmlWorldMapsFixed ;

  foreach $country (keys_sorted_by_value_num_desc %requests_per_country)
  {
    next if $requests_per_country {$country} < 50 * ($#quarters + 1) ;

    %requests_per_language = %{$requests_per_country_per_language {$country}} ;
    @languages = keys_sorted_by_value_num_desc %requests_per_language ;

    ($link_country,$icon,$population) = &CountryMetaInfo ($country) ;

    $html .= "<tr><th colspan=99 class=lh3><a id='$country' name='$country'></a><br>$icon $link_country</th></tr>\n" ;

    if ($views_edits eq 'Page Edits')
    { $rowspan = $#quarters+2 ; }
    else
    { $rowspan = $#quarters+3 ; }

    $html .= "<tr><th class=small>Quarter</th>[<th class=small>Total</th>]<th class=small>Share</th><th rowspan=$rowspan>&nbsp;</th>\n" ;
    for ($l = 0 ; $l < 10 ; $l++)
    {
      $language = $languages [$l] ;
      if ($out_languages {$language} ne "")
      { $language = $out_languages {$language} ; }
      if (length ($language) > 20)
      { $language =~ s/ .*$// ; }
      $html .= "<th class=c class=small>$language</th>\n" ;
      # print " [$language] " ;
    }
    $html .= "<th>other</th>\n" ;
    $html .= "</tr>\n" ;
    # print "\n" ;

    my $lines = 0 ;
    foreach $quarter (reverse @quarters)
    {
      next if $views_edits eq 'Page Edits' and $quarter =~ /2009.*?Q3/ ; # strange results, to be researched

      $line1 = "<tr>\n" ;
      $line2 = "<tr>\n" ;

      my $requests_this_country  = $requests_per_quarter_per_country {$quarter} {$country} ;
      my $requests_all_countries = $requests_per_quarter            {$quarter} ;

      $perc = 'n.a.' ;
      if ($requests_all_countries > 0)
      {
        $perc = &Percentage ($requests_this_country / $requests_all_countries) ;
        # print "$quarter: " . sprintf ("%9d", $requests_this_country) . " = $perc\% $country\n" ;
        $line1 .= "<th class=c nowrap>&nbsp;$quarter&nbsp;</th>[<td align=right>$requests_this_country</td>]<td align=center>$perc</td>" ;
        $line2 .= "<th nowrap>&nbsp;$quarter&nbsp;</th>[<td align=right>$requests_this_country</td>]<td align=center>$perc</td>" ;
      }

      $perc_tot = 0;
      for ($l = 0 ; $l < 10 ; $l++)
      {
        my $requests_this_language = $requests_per_quarter_per_country_per_language {$quarter} {$country} {$languages [$l]} ;
        my $requests_all_languages = $requests_per_quarter_per_country              {$quarter} {$country} ;
        $perc = 0 ;
        if ($requests_all_languages > 0)
        {
          $perc = &Percentage ($requests_this_language / $requests_all_languages) ;
          $perc_tot += $perc ;
        }
        # print "[" . sprintf ("%9d", $requests_this_language) . " = $perc\%]" ;
        if ($perc != 0)
        { $line2 .= "<td class=c><img src='yellowbar_hor.gif' width=$perc height=15></td>" ; }
        else
        { $line2 .= "<td class=l>&nbsp;</td>" ; }

        if (($country eq "Australia") && (($perc < 50) && ($perc > 5)))
        { $perc .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}
        $line1 .= "<td class=c>[$requests_this_language]$perc</td>" ;
      }
      if ($perc_tot > 100) { $perc_tot = 100 ; }
      $perc_other = sprintf '%.1f', 100 - $perc_tot ;
      $line1 .= "<td class=c>$perc_other%</td>" ;

      $line1 .= "</tr>\n" ;
      $line2 .= "</tr>\n" ;
      $html .= $line1 ;
      if ($lines++ == $#quarters)
      { $html .= $line2 ; } # only for last quarter
    }

    if ($verbose)
    { push @index_countries, "<a href='#$country'>$country ($perc)</a> " ; }
    else
    { push @index_countries, "<a href='#$country'>$country</a> " ; }

  # print "\n" ;
  # $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  }
  $html .= "</table>" ;
  $html .= "<p><b>Share<\/b> is the percentage of requesting ip addresses (out of the world total) which originated from this country" .
           "<br>&nbsp;Further percentages show per country per quarter share of $views_edits_lc per Wikipedia visited" ;
  $html .= "<p>Countries are only included if the number of requests in the period exceeds 100,000 (100 matching records in 1:1000 sampled log)" ;
  $html .= "<br>Page requests by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " .
           "Country meta data collected from <a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>English Wikipedia</a>. " .
           "'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a>" ;
  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;

  &PrintHtml ($html, "$path_reports/$file_html_per_country_trends") ;
}

sub i2KM1
{
  my $v = shift ;

  return ("&nbsp;") if $v == 0 ;
  
     if ($v >= 100000000000) { $v = sprintf ("%.0f",($v / 1000000000)) . "&nbsp;" . $out_billion  ; $v =~ s/(\d+?)(\d\d\d[^\d])/$1,$2/ ; }
  elsif ($v >= 1000000000)   { $v = sprintf ("%.1f",($v / 1000000000)) . "&nbsp;" . $out_billion  ; }
  elsif ($v >= 100000000)    { $v = sprintf ("%.0f",($v / 1000000))    . "&nbsp;" . $out_million  ; $v =~ s/(\d+?)(\d\d\d[^\d])/$1,$2/ ; }
  elsif ($v >= 1000000)      { $v = sprintf ("%.1f",($v / 1000000))    . "&nbsp;" . $out_million  ; }
  elsif ($v >= 10000)        { $v = sprintf ("%.0f",($v / 1000))       . "&nbsp;" . $out_thousand ; }
  elsif ($v >= 1000)         { $v = sprintf ("%.1f",($v / 1000))       . "&nbsp;" . $out_thousand ; }

  return ($v) ;
}

sub i2KM2
{
  my $v = shift ;
  return $v if $v !~ /^\d*$/ ;

  return ("&nbsp;") if $v == 0 ;

     if ($v >= 10000000) { $v = sprintf ("%.0f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000000)  { $v = sprintf ("%.1f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000)     { $v = sprintf ("%.0f",($v / 1000))    . "&nbsp;" . $out_thousand ; }

  return ($v) ;
}

#   format: function(s) { return $.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/\\&nbsp\\;/g,"").replace(/M/i,"000000").replace(/&#1052;/,"000000").replace(/K/i,"000").replace(/&#1050;/i,"000")); },

sub UnLink
{
  my ($links,$index) = @_ ;
  # print "\n\nUnLink $index\n\n" ;
  my @segments = split '(?=<a )', $links ;
  # print "SEGMENT 1 $segments[$index]\n" ;
  $segments [$index] =~ s/^.*?<a .*?>([^<]*)<\/a>/<font color=#008000><b>$1<\/b><\/font>/ ;
  # print "SEGMENT 2 $segments[$index]\n" ;
  $links = join '', @segments ;
  return ($links) ;
}

sub PrintHtml
{
  ($html, $path) = @_ ;

  $html =~ s/and images// ; # all data [and images] onthis page are in the public domain
  open  HTML_OUT, '>', $path ;
  print HTML_OUT $html ;
  close HTML_OUT ;

  $ago = -M $path ;
  &Log ("Html file printed: $path\n") ;

}

sub HtmlHead
{
# substitute      this                                with          this
  $regexp_from1 = '/(\d)(\d\d\d)$/' ;                 $regexp_to1 = '"$1,$2"' ;
  $regexp_from2 = '/(\d)(\d\d\d)(\d\d\d)$/' ;         $regexp_to2 = '"$1,$2,$3"' ;
  $regexp_from3 = '/(\d)(\d\d\d)(\d\d\d)(\d\d\d)$/' ; $regexp_to3 = '"$1,$2,$3,$4"' ;
  $regexp_from4 = '/(\d)(\d\d\d)\&/' ;                $regexp_to4 = '"$1,$2\&"' ;

  my $html = <<__HTML_HEAD__ ;

<!DOCTYPE FILE_HTML PUBLIC '-//W3C//DTD FILE_HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>
<html lang='en'>

<head>

<title>TITLE</title>

<meta http-equiv='Content-type' content='text/html; charset=iso-8859-1'>
<meta name='robots' content='index,follow'>

WORLDMAP_D3

<style type='text/css'>
<!--
body  {font-family:arial,sans-serif; font-size:12px }
h2    {margin:0px 0px 3px 0px; font-size:18px}
table {font-size:12px ;}
td    {font-size:12px ; white-space:wrap; text-align:right; vertical-align:middle ;
       padding-left:2px; padding-right:2px; padding-top:1px; padding-bottom:0px } 

td.hl   {text-align:left;vertical-align:top;}
td.hr   {text-align:right;vertical-align:top;}
td.hc   {text-align:center;vertical-align:top;}
td.r    {text-align:right;  border: inset 1px #FFFFFF}
td.c    {text-align:center; border: inset 1px #FFFFFF}
td.l    {text-align:left;   border: inset 1px #FFFFFF}
td.lt   {text-align:left;   border: inset 1px #FFFFFF ; vertical-align:top}
td.rt   {text-align:right;  border: inset 1px #FFFFFF ; vertical-align:top}
th.lnb  {text-align:left;   border: none; white-space:nowrap}
td.lnb  {text-align:left;   border: none; white-space:nowrap}
td.cnb  {text-align:center; border: none; white-space:nowrap}
td.rnb  {text-align:right;  border: none; white-space:nowrap}
th.cnb  {text-align:center; border: none; white-space:nowrap}

th       {white-space:nowrap; text-align:right; 
          padding-left:2px; padding-right:2px; padding-top:1px; padding-bottom:0px ; 
          font-size:12px ; vertical-align:top ; font-width:bold}
th.small {white-space:wrap; text-align:right; 
          padding-left:2px; padding-right:2px; padding-top:1px; padding-bottom:0px ; 
          font-size:11px ; vertical-align:top ; font-width:bold}
th.c     {text-align:center; border: inset 1px #FFFFFF}
th.l     {text-align:left;   border: inset 1px #FFFFFF}
th.r     {text-align:right;  border: inset 1px #FFFFFF}
th.lh3   {text-align:left;   border: inset 1px #FFFFFF ; font-size:14px}

a:link    {color:blue;    text-decoration:none;}
a:visited {color:#0000FF; text-decoration:none;}
a:active  {color:#0000FF; text-decoration:none;}
a:hover   {color:#FF00FF; text-decoration:underline}

img a:link    {color:#CCCCFF; text-decoration:none;}
img a:visited {color:#CCCCFF; text-decoration:none;}
img a:active  {color:#CCCCFF; text-decoration:none;}
img a:hover   {color:#FF00FF; text-decoration:none}
-->
</style>

<script>

var calls = 0 ;

var show_count_short              = (getCookie ('show_count_short') == 'true') || (getCookie ('show_count_short') == '') ;
var show_count_mode               = (getCookie ('select_period') || 0) ;
var show_count_monthly_normalized = (show_count_mode == 0) ;
var show_count_monthly_raw        = (show_count_mode == 1) ;
var show_count_daily              = (show_count_mode == 2) ;
var show_percentage               = (getCookie ('show_perc') == 'true') ;

var char_million  = 'M' ;
var char_thousand = 'k' ;
var nbsp = '&nbsp;' ;
var checked = false;
var element ;
var index ;

function setCookie (name, value, expires, path, domain, secure)
{
  var curCookie = name + "=" + escape(value) + ((expires) ? "; expires=" + expires.toGMTString() : "") + ((path) ? "; path=" + path : "") + ((domain) ? "; domain=" + domain : "") + ((secure) ? "; secure" : "");
  document.cookie = curCookie;
}

function getCookie (name)
{
  var prefix = name + "=" ;
  var cookieStartIndex = document.cookie.indexOf (prefix);
  if (cookieStartIndex == -1)
  { return "" ; }
  var cookieEndIndex = document.cookie.indexOf (";", cookieStartIndex + prefix.length);
  if (cookieEndIndex == -1)
  { cookieEndIndex = document.cookie.length ; }
  result = document.cookie.substring (cookieStartIndex + prefix.length, cookieEndIndex);
  return unescape (result) ;
}


function refreshPage ()
{
  // alert ('refreshPage') ;
  var element = document.getElementById ('form_select_period');

  if (element.selectedIndex == 3)
  { setCookie ('select_period', (getCookie ('select_period') || 0) + 10) ; }
  else
  { setCookie ('select_period', element.selectedIndex) ; }

  // alert (document.cookie) ;
  window.location.reload();
}

function showCount (count, percentage)
{
  //  if (++ calls == 1)
  // { alert ('showCount() show_count_short '+show_count_short) ; }

  if (days_in_month == 0) // workaround, should not happen 
  { days_in_month = 30 ; }

       if (count == 0)                    { count = '-' ; }
  else if (show_count_daily)              { ; }
  else if (show_count_monthly_normalized) { count *= 30 ; }
  else if (show_count_monthly_raw)        { count *= days_in_month ; }

  if (show_count_short)
  {
         if (count >= 100000000)  { count = Math.round (count/1000000) + nbsp + char_million ; }
    else if (count >= 1000000)    { count = (Math.round  (count/100000) / 10) + nbsp + char_million ; }
    else if (count >= 10000)      { count = Math.round  (count/1000) + nbsp + char_thousand ; }
    else if (count >= 999)        { count = (Math.round  (count/100) / 10) + nbsp + char_thousand ; }
    else                          { count = Math.round (count) ; }

    count += '' ; // make string
    count = count.replace ($regexp_from4,$regexp_to4) ;
  }
  else
  {
    // add 1000 separators
    count += '' ; // make string
    count = count.replace ($regexp_from3,$regexp_to3) ;
    count = count.replace ($regexp_from2,$regexp_to2) ;
    count = count.replace ($regexp_from1,$regexp_to1) ;
  }

  if (show_percentage && percentage != '' && count != '-')
  {
    count = percentage ;
  }

  document.write (count) ;
}

</script>

__HTML_HEAD__
  return ($html) ;
}

sub HtmlBodyTop
{
  my $html = <<__HTML_BODY_TOP__ ;

<table width=100%>
<tr>
<td class=hl>
  <h2>HEADER</h2>
  <b>DATE</b>
<p>LINKS

</td>
<td class=hr>
  <a href='//stats.wikimedia.org/archive/squid_reports'>Archive</a> / 
  <a href='//stats.wikimedia.org'>Wikistats main page</a>
</td>
</tr>
</table>

__HTML_BODY_TOP__

return ($html) ;
}

sub HtmlSortTable
{
  my $html = <<__HTML_SORT_TABLE__ ;

<script src="jquery-1.3.2.min.js" type="text/javascript"></script>
<script src="jquery.tablesorter.js" type="text/javascript"></script>

<script type="text/javascript">
\$.tablesorter.addParser({
  id: "nohtml",
  is: function(s) { return false; },
  format: function(s) { return s.replace(/<.*?>/g,"").replace(/&nbsp;/g,""); },
  type: "text"
});

\$.tablesorter.addParser({
  id: "millions",
  is: function(s) { return false; },
//failed so far to turn 1.2M into 1200000, so figures with decimal point are sorted out of place
//format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/&nbsp;/g,"").replace(/\\.(\\d)M/,$1+"00000").replace(/M/,"000000").replace(/&#1052;/,"000000").replace(/K/,"000").replace(/&#1050;/i,"000")); },
  format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/&nbsp;/g,"").                                replace(/M/,"000000").replace(/&#1052;/,"000000").replace(/K/,"000").replace(/&#1050;/i,"000")); },
  type: "numeric"
});

\$.tablesorter.addParser({
  id: "digitsonly",
  is: function(s) { return false; },
  format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<.*?>/g,"").replace(/&nbsp;/g,"").replace(/,/g,"").replace(/-/,"-1")); },
  type: "numeric"
});

\$.tablesorter.addParser({
  id: "showcount",
  is: function(s) { return false; },
  format: function(s) { return s.replace(/.*\\\(/,"").replace(/,.*/,""); },
  type: "numeric"
});

\$.tablesorter.addParser({
  id: "showcountswitch",
  is: function(s) { return false; },
  format: function(s) { return (show_percentage) ? (s.replace(/.*,\\s'/,"").replace(/%.*/,"").replace(/\\./,"")) : (s.replace(/.*\\\(/,"").replace(/,.*/,"")) ; },
  type: "numeric"
});
</script>

<style type="text/css">
table.tablesorter
{
/*
  font-family:arial;
  background-color: #CDCDCD;
  margin:10px 0pt 15px;
  font-size: 7pt;
  width: 80%;
  text-align: left;
*/
}
table.tablesorter thead tr th, table.tablesorter tfoot tr th
{
/*
  background-color: #99D;
  border: 1px solid #FFF;
  font-size: 8pt;
  padding: 4px;
*/
}
table.tablesorter thead tr .header
{
  background-color: #ffffdd;
  background-image: url(bg.gif);
  background-repeat: no-repeat;
  background-position: center right;
  cursor: pointer;
}
table.tablesorter tbody th
{
/*
  color: #3D3D3D;
  padding: 4px;
  background-color: #CCF;
  vertical-align: top;
*/
}
#table.tablesorter tbody tr th
#{
#  background-color:#eeeeaa;
#  background-image:url(asc.gif);
#}
table.tablesorter tbody tr.odd th
{
  background-color:#eeeeaa;
  background-image:url(asc.gif);
}
table.tablesorter thead tr .headerSortUp
{
  background-color:#eeeeaa;
  background-image:url(asc.gif);
}
table.tablesorter thead tr .headerSortDown
{
  background-color:#eeeeaa;
  background-image:url(desc.gif);
}
table.tablesorter thead tr .headerSorthown, table.tablesorter thead tr .headerSortUp
{
  background-color: #eeeeaa;
}
</style>
__HTML_SORT_TABLE__
  return ($html) ;
}

sub HtmlSortTableColumns
{
  my $html = <<__HTML_SORT_TABLE_COLUMNS__ ;

<script type='text/javascript'>
\$('#table1').tablesorter({
  // debug:true,
  headers:{0:{sorter:'nohtml'},1:{sorter:'nohtml'},2:{sorter:'nohtml'},3:{sorter:'millions'},4:{sorter:'digitsonly'},5:{sorter:'millions'},6:{sorter:'digitsonly'},7:{sorter:'millions'},8:{sorter:'digitsonly'},9:{sorter:'digitsonly'}}
});
</script>
__HTML_SORT_TABLE_COLUMNS__
return ($html) ;
}

sub HtmlIndex
{
  $index = shift ;

  my $html = <<__HTML_INDEX__ ;

<script type="text/javascript">
<!--
function toggle_visibility_index()
{
  var index  = document.getElementById('index');
  var toggle = document.getElementById('toggle');
  if (index.style.display == 'block')
  {
    index.style.display = 'none';
    toggle.innerHTML = 'Show index';
  }
  else
  {
    index.style.display = 'block';
    toggle.innerHTML = 'Hide index';
  }
}
//-->
</script>

<tr><td class=r colspan=99><a href="#" id='toggle' onclick="toggle_visibility_index();">Show index</a></td></tr>
<tr><td class=l colspan=99><span id='index' style="display:none">\n$index\n<hr></span></td></tr>
__HTML_INDEX__

return ($html) ;
}

sub HtmlWorldMapsFixed 
{
my $html_worldmaps_fixed = <<__HTML_WORLD_MAPS__ ;
<tr><td colspan=99 align=center>
<div style="text-align:left"><b>Static maps and chart for added context</b></div>
<table width='100%' style='vertical-align:text-top;' align=center valign='top'>
<td align=left style='background-color:#FFFFDD; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:Countries_and_Dependencies_by_Population_in_2014.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/4/41/Countries_and_Dependencies_by_Population_in_2014.svg' border='1' width='400px' height'205'>
</a>
<br>Countries and Dependencies by population in 2014<br>Based on data from <a href='https://www.cia.gov/library/publications/the-world-factbook/rankorder/2119rank.html'>The World Factbook</a>
<p>See also <a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>Countries by population</a> - English Wikipedia
</small><p>&nbsp;
</td>
<td style='background-color:#FFFFDD; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:InternetPenetrationWorldMap.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/9/99/InternetPenetrationWorldMap.svg' border='1' width='400px'>
</a><br>
Internet users in 2015 as a percentage of a country's population<br>
Source: International Telecommunications Union.
<p>See also <a href='//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>Internet penetration</a> (% of population) - English Wikipedia
</small><p>&nbsp;
</td>
</tr>
<tr>
<td style='background-color:"#EEE"; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:North_South_divide.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/thumb/4/46/North_South_divide.svg/400px-North_South_divide.svg.png' border='1' height='205'>
</a>
<br>World map showing the modern definition of the North-South divide<br>&nbsp;
<p>See also <a href='//en.wikipedia.org/wiki/North-South_divide'>Global North South</a> - English Wikipedia
</small>
</td>
<td style='background-color:"#EEE"; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:Internet_users_per_100_inhabitants_ITU.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/2/29/Internet_users_per_100_inhabitants_ITU.svg' border='1' width='400px' height='205'>
</a><br>
Internet users per 100 inhabitants<br>
Source: International Telecommunications Union.
<p>See also <a href='//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>Internet penetration</a> (% of population) - English Wikipedia
</small>
</td>
</tr>
</table>
</td></tr>
__HTML_WORLD_MAPS__

return $html_worldmaps_fixed ;
}

# yeah, changing a global yet again
sub AddNoticeSurvey
{
  my $report_id = shift ;

if (($quarter_only ne '') && ($quarter_only lt "2015 Q2"))
{
  $html .= "<font color=#080><b><big>Feb 2016: This report has been upgraded, and does now include mobile views. But still is based on pre-hadoop data stream (squid logs)</big></b></font>" ;
}    
else 
{ 
  $html .= "<font color=#030><b><big>Feb 2016: This report has been upgraded, and is now based on Wikimedia Foundations's new hadoop-based infrastructure.<br>Earlier versions of this report have been republished with new data, starting May 2015. Thanks so much for your patience!</font><p>" . 
           "<font color=#030>Mar 2016: Non-regional Wikistats traffic reports which were marked by users in <a href='//www.mediawiki.org/wiki/Analytics/Wikistats/TrafficReports/Future_per_report_B2'>this survey</a> as particularly valuable<br>
have also been migrated to Wikimedia Foundation's new hadoop-based infrastructure. See <a href='//analytics.wikimedia.org/dashboards/browsers/#all-sites-by-os'>here</a><br>&nbsp;<br></font>" .  
           "<font color=#080>Jul 2016: New visualization added: <a href='https://stats.wikimedia.org/wikimedia/animations/wivivi/wivivi.html'>WiViVi</a> is a visual presentation equivalent of the tabular data below.</big></b></font>" ;
}    

}

sub PrepLanguageBubbleDetailsPerCountry 
{
  my ($language,$sample_rate) = @_ ;
  my ($html, $viewfreq_per_country) ; ;

  my %totals_per_country  = %{$requests_recently_per_language_per_country {$language}} ;
  my $totals_per_language = $requests_recently_per_language {$language} * $sample_rate ;

  my $countries = 0 ;
# print "\n\nlang $language\n" ; 
  foreach $country_name (sort {$totals_per_country {$b} <=> $totals_per_country {$a}} keys %totals_per_country)
  {

    $countries ++ ;
    $odd_even = $countries % 2 == 0 ? 'even' : 'odd' ;  
    last if $countries > $d3_csv_rows_max ; # max rows to show in hover box 
    
    $country_meta = $country_meta_info {$country_name} ;
    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;

    $country_code_iso2 = $country_codes_iso2 {$country_name} ;
    $country_code_iso3 = $country_names_iso3 {$country_name} ;

    $region_code      = $region_codes      {$country_code_iso2} ;
    $north_south_code = $north_south_codes {$country_code_iso2} ;

    $requests = $requests_recently_per_language_per_country {$language} {$country_name} * $sample_rate ;
    
    $share_requests = '-' ;
    if ($totals_per_language > 0)
    { $share_requests = &Percentage ($requests / $totals_per_language) ; }
    ($share_requests2 = $share_requests) =~ s/\%// ;

    $requests = i2KM1 ($requests) ;

    $country2 = &ShortenForHoverbox ($country_name) ;

    $html .= "$countries:$country_code_iso3:$country2:$north_south_code:$region_code:$requests:$share_requests|" ;

    $viewfreq_per_country .= "$country_code_iso3:$share_requests2;" ; # qqqq
  }

  $viewfreq_per_country =~ s/;$// ;
  $html =~ s/\|$// ;

  return ($html, $viewfreq_per_country) ;
}

1 ;
