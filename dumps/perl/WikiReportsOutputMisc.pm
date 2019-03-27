#!/usr/bin/perl

  use WikiReportsNoWikimedia ;

# send to disk, and stdout 
# (not quite the Linux way, but most of Wikistats was run on Windows for many years)
sub Log
{
  my $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}

# send to disk, not to screen
sub LogQ
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
      &LogQ (">>\n") ;
      foreach $line (@errors)
      { &LogQ ($line) ; }
      &LogQ ("<<\n\n") ;
    }
    unlink $file_errors ;
    undef @errors ;
  }
}

#Hi Erik;
#I have found a cool script for taking snapshots of webpages. I saw some time ago in your website a gallery with screenshots of Wikipedia mainpages. I loved that, and I have been searching for a script which works in Linux (you used urlbmp.exe, i guess).
#The script is from a bot of RationalWiki.[1] I have tested it in my Linux PC and works fine (I attached you the files). You can run it:
#python snap.py http://en.wikipedia.org --geometry 1024 1 > a.png
#I have installed pyqt4-dev-tools and pyqt-tools with apt-get. It would be nice if you can run it in a cronjob in the WMF servers.
#I will try it in Toolserver, but previously, I have to request to an admin to install those packages.
#Regards,
#emijrp
#[1] http://rationalwiki.org/wiki/User:Capturebot2
#[2] http://rationalwiki.org/wiki/User:Capturebot2/webkit2png.py

sub GenerateGallery
{
  &LogT ("\nGenerate Gallery, mode $mode\n") ;
  &LogT ("In:  $path_in\n") ;
  &LogT ("Out: $path_out\n") ;

  my $languages = @languages - 1 ; # minus 'zz'
  my $date = &GetDate(time) ;

  my $mode2 = ucfirst ($mode) ;
  my $out_publication2 = $out_publication ;

  if ($mode_wx)
  { $out_publication2 = "Wikimedia Miscellaneous Projects" ; }

  my $description = " Screenshots of $languages $out_publication2 main pages, collected on $date, sorted by average page views per project</a>. See <a href='index.html'><font color=#A0A0D0>more screenshots</font></a>" ;
  my $footer  = "<small><font color=#A0A0A0> Screenshots collected with <a href='http://www.pixel-technology.com/freeware/url2bmp/'><font color=#A0A0D0>url2bmp.exe</font></a> (Windows freeware)<br>\n" .
                " Please note: on a few pages javascript errors may have influenced page rendition<br>" .
                " Script author: <a href='http://infodisiac.com'><font color=#A0A0D0>Erik Zachte</font></a></font></small>" ;
  my $out_html = "<html><head><title>$out_publication2 Main Page Gallery - screen shots taken $date</title></head>\n\n$out_tracker_code\n\n" .
                 "<body bgcolor=black><small><font color=#C0C0C0>$description</font></small>" .
                 "<table summary='Gallery'><tr>\n" ;
  my $out_html_40 = "<html><head><title>$out_publication2 Main Page Gallery - screen shots taken $date</title></head>\n\n$out_tracker_code\n\n" .
                 "<body bgcolor=black><small><font color=#C0C0C0>$description</font></small>" .
                 "<table summary='Gallery'><tr>\n" ;
  my $out_html_1024_768 = "<html><head><title>$out_publication2 Main Page Gallery - screen shots taken $date</title></head>\n\n$out_tracker_code\n\n" .
                 "<body bgcolor=black><small><font color=#C0C0C0>$description</font></small>" .
                 "<table summary='Gallery'><tr>\n" ;
  my $out_html_768_1024 = "<html><head><title>$out_publication2 Main Page Gallery - screen shots taken $date</title></head>\n\n$out_tracker_code\n\n" .
                 "<body bgcolor=black><small><font color=#C0C0C0>$description</font></small>" .
                 "<table summary='Gallery'><tr>\n" ;

  foreach $wp (@languages)
  {
    if ($wp eq "zz") { next ; }

    $gallery_image_list .= "'wp_$wp.png', // " . $out_languages {$wp} . "\n" ;

    my $base = &GetProjectBaseUrl ($wp) ;
    &LogT ("Base: " . sprintf ("%-10s", $wp) . " -> $base\n") ;

    ($wp2 = $wp) =~ s/_/-/g ;
    $url2bmp++ ;
    $wait1 = '' ;
    $wait2 = '' ;
    if ($url2bmp % 3 == 0)
    { $wait1 = "wait 1" ; }

    # Q&D: download twice until bath image resize figured out with either convert.exe or nconvert.exe
    $out_bat .= "rem url2bmp.exe -url \"$base?country=xx\" -file \"${mode}_$wp2.png\"      -format PNG -wx 1000 -wy 3000 -bx 1000 -by 3000 $wait1 -notinteractive\nrem $url2bmp/$languages\n" .
                "rem url2bmp.exe -url \"$base?country=xx\" -file \"${mode}_${wp2}_40.png\" -format PNG -wx 1000 -wy 3000 -bx  250 -by 1200 $wait2 -notinteractive\nrem $url2bmp/$languages\n" .
                "    url2bmp.exe -url \"$base?country=xx\" -file \"${mode}_$wp2_768_1024.png\"      -format PNG -wx 1024 -wy  768 -bx 1024 -by  768 $wait1 -notinteractive\nrem $url2bmp/$languages\n" .
                "    url2bmp.exe -url \"$base?country=xx\" -file \"${mode}_$wp2_1024_768.png\"      -format PNG -wx  768 -wy 1024 -bx  768 -by 1024 $wait1 -notinteractive\nrem $url2bmp/$languages\n" ;
                # "nconvert.exe -resize 40% 40% -o wx_commons_40.png wx_commons.png >> nconvert.txt 2>> nconvert2.err\n\n" ;
    $out_html .= "<td align='center' valign='top'>\n" .
                 "<small><b><font color='#AAAAAA'>" . uc($wp2) . "</font>" .
                 "&nbsp;&nbsp;&nbsp;" .
                 "<a href='$base'><font color='#AAAAAA'>" . $out_languages {$wp} . "</font></a></small></b><p>" .
                 "<img src='${mode}_$wp2.png'></td>\n" ;
    $out_html_40 .= "<td align='center' valign='top'>\n" .
                 "<small><b><font color='#AAAAAA'>" . uc($wp2) . "</font>" .
                 "&nbsp;&nbsp;&nbsp;" .
                 "<a href='$base'><font color='#AAAAAA'>" . $out_languages {$wp} . "</font></a></small></b><p>" .
                 "<img src='${mode}_${wp2}_40.png'></td>\n" ;
    $out_html_1024_768 .= "<td align='center' valign='top'>\n" .
                 "<small><b><font color='#AAAAAA'>" . uc($wp2) . "</font>" .
                 "&nbsp;&nbsp;&nbsp;" .
                 "<a href='$base'><font color='#AAAAAA'>" . $out_languages {$wp} . "</font></a></small></b><p>" .
                 "<img src='${mode}_${wp2}_1024_768.png'></td>\n" ;
    $out_html_768_1024 .= "<td align='center' valign='top'>\n" .
                 "<small><b><font color='#AAAAAA'>" . uc($wp2) . "</font>" .
                 "&nbsp;&nbsp;&nbsp;" .
                 "<a href='$base'><font color='#AAAAAA'>" . $out_languages {$wp} . "</font></a></small></b><p>" .
                 "<img src='${mode}_${wp2}_768_1024.png'></td>\n" ;
  }
  $out_html .= "</tr></table>\n<p>$footer</body>" ;
  $out_html_40 .= "</tr></table>\n<p>$footer</body>" ;

  open "FILE_OUT", ">", $path_out . "Gallery_$mode2.bat" ;
  print FILE_OUT $out_bat ;
  close "FILE_OUT" ;

  open "FILE_OUT", ">", $path_out . "Gallery_$mode2.htm" ;
  print FILE_OUT $out_html ;
  close "FILE_OUT" ;

  open "FILE_OUT", ">", $path_out . "Gallery_${mode2}_40.htm" ;
  print FILE_OUT $out_html_40 ;
  close "FILE_OUT" ;

  open "FILE_OUT", ">", $path_out . "Gallery_${mode2}_1024_768.htm" ;
  print FILE_OUT $out_html_1024_768 ;
  close "FILE_OUT" ;

  open "FILE_OUT", ">", $path_out . "Gallery_${mode2}_768_1024.htm" ;
  print FILE_OUT $out_html_768_1024 ;
  close "FILE_OUT" ;

  open "FILE_OUT", ">", $path_out . "Gallery_ImageList_${mode2}.txt" ;
  print FILE_OUT $gallery_image_list ;
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
    if ($region eq 'artificial')
    {
      $out_html_title .= " Languages" ;
      $out_page_title .= " Languages" ;
    }
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

# $out_msg = "<b><font color=red>January 2014: Unfortunately monthly database dump generation is delayed for many wikis. Reports will appear later than usual. Our sincere apologies for any inconvenience caused.</font><font color=#080><br>Upd. March 2: Dump generation was restarted on February 12. All dumps are up to date now for December, some not for January, some days to go. This is an intermediate update.</font></b>" ;

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
    { $out_more_tables = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small>See bottom of  page for <a href='#comparisons'><b>language comparisons</b></a> / <a href='#see_also'><b>other reports</b></a>&nbsp;&nbsp;&nbsp;See also the <a href='TablesCurrentStatusVerbose.htm'>expanded version of this report.</small>" ; }
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
      $out_html .= "<table border=0>" . 
                   "<tr><td><h2>$out_publications</h2></td><td><h3>$out_more_tables</h3></td>" .
                 # "<td><b>&nbsp;&nbsp;&nbsp;<img src='../Tables.png'>&nbsp;=&nbsp;$out_btn_tables&nbsp;<img src='../BarCharts.png'>&nbsp;=&nbsp;$out_btn_charts</b></td>" .
                 # "<td>&nbsp;&nbsp;&nbsp;&nbsp;<b><font size=+1 color='#0000A0' face=\'Times'>W</font> = Wikipedia Article&nbsp;&nbsp;&nbsp;<img src='../BarCharts.png'>&nbsp;=&nbsp;$out_btn_charts</b></td>" .
                   "</tr></table>\n" ;
    }
    else
    { $out_html .= "<h2>$out_publications</h2>\n" ; }
 
   if ($mode_wp)
   { $out_html .= "<p><font color=#080>Mar 2016</font>: Want to bookmark this page with default sort column? Now you can!<br>" . 
                  "Add url argument 'sortcol=x' (where x is 4-6|8-18), add D for descending sort. E.g. 'Sitemap.htm?sortcol=14D'" ; }

    if ($wikimedia)
    {
      if ($mode_wb) { $out_url_all = "http://wikibooks.org" ; }
      if ($mode_wk) { $out_url_all = "http://wiktionary.org" ; }
      if ($mode_wn) { $out_url_all = "http://wikinews.org" ; }
      if ($mode_wo) { $out_url_all = "http://wikivoyage.org" ; }
      if ($mode_wp) { $out_url_all = "http://wikipedia.org" ; }
      if ($mode_wq) { $out_url_all = "http://wikiquote.org" ; }
      if ($mode_ws) { $out_url_all = "http://wikisource.org" ; }
      if ($mode_wv) { $out_url_all = "http://wikiversity.org" ; }
      if ($mode_wx) { $out_url_all = "http://wikimedia.org" ; }
    }

    $out_html .= "<p>" . 
                 blank_text_after ("01/10/2017", " <font color=#008000><b>June 2017 !New!</b></font> ") .
                 "Column added: 'Months since 3 or more active editors'. " . 
                 "Sort by <a href='Sitemap.htm?sortcol=10D'>duration of inactivity</a>" .
                 "<br><b>ACTIVEWIKIS1 out of LISTEDWIKIS listed wikis were active (3+ active editors) in last month</b>, " . 
                 "<font color=#888888>ACTIVEWIKIS3 in last 3 months, </font><font color=#CCCCCC>ACTIVEWIKIS12 in last 12 months.</font> " . 
                 "See also <a href='//stats.wikimedia.org/EN/ProjectTrendsActiveWikis.html'>activity charts</a>. " ; 

    $out_html .= "<table border=1 cellspacing=0 id=table2 style='' summary='Tables and charts' class=tablesorter>\n" ;

    if ($sitemap_new_layout)
    {
      $background_color1 = '#FDFDBB' ;
      $background_color2 = '#ECECAA' ;

      $out_html .= "<colgroup>" . 
                   "<col span=1 style='background-color:$background_color1'>" . # Data 
                   "<col span=5 style='background-color:$background_color1'>" . # Languages 
                   "<col span=1 style='background-color:$background_color1'>" . # Regions
                   "<col span=3 style='background-color:$background_color2'>" . # Participation
                   "<col span=5 style='background-color:$background_color1'>" . # Active Editors
                   "<col span=2 style='background-color:$background_color2'>" . # Edits
                   "<col span=1 style='background-color:$background_color1'>" . # Usage
                   "<col span=1 style='background-color:$background_color2'>" . # Content
                   "</colgroup>" ; 


      $out_html .= "<thead>\n" ;

    # $out_html .= &tr ($mode_wp ? &tdcbt5 (&b ("Languages")) : &tdcbt4 (&b ("Languages")) .
      $out_html .= &tr (&tdcbt  (&b ("Data")) .
                        &tdcbt5 (&b ("Languages")) .
                        &tdcbt  (&b ("Regions")) .
                        &tdcbt3 (&b ("Participation")) .
                        &tdcbt5 (&b ("Active editors")) .
                        &tdcbt2 (&b ("Edits")) .
                        &tdcbt  (&b ("Usage")) .
                        &tdcbt  (&b ("Content"))) ;
                      # &tdcbt  (&b ($out_site)) .

#     $out_html .= &tr (&tdcbt ("<small>&rArr; Article<br>&rArr; $out_btn_charts</small>") .
#                       (&tdcbt ("<small>Code<br>&rArr; Project</small>")) .
#                       (&tdlbt ("<small>Name<br>&rArr; $out_btn_tables</small>")) .
#                       $out_participation {"header"} .
#                       &tdcbt ("<small>Views<br>per hour</small>") .
#                       &tdcbt ("<small>Article<br>count</small>")) ;
      $out_html .= &tr (&tdcbt  ("<small>Month</small>") .
                        &tde . &tde . &tde .
                        (&tdcbt ("<small>Code<br>&rArr; Project<br>Main Page</small>")) .
                        (&tdlbt ("<small>Language<br>&rArr; Wikipedia article</small>")) .
                        $out_participation {"header"} .
                        &tdcbt("<small>Months<br>since<br>3 or more<br><a href='//stats.wikimedia.org/EN/ProjectTrendsActiveWikis.html'>active<br>editors</a></small>") .
                        &tdcbt("<a href='TablesWikipediansEditsGt5.htm'><small>5+ edits<br>&nbsp;p/month&nbsp;</small></a><br><small>(3m avg)</small>") .
                        &tdcbt("<a href='TablesWikipediansEditsGt100.htm'><small>100+ edits<br>&nbsp;p/month&nbsp;</small></a><br><small>(3m avg)</small>") .
                        &tdcbt("<small>Admins</small>") .
                        &tdcbt("<small>Bots</small>") .
                        &tdcbt ("<small><a href='BotActivityMatrixEdits.htm'>Bot<br>edits</a></small>") .
                        &tdcbt ("<small>Human<br>edits<br>by unreg.<br>users</small>") .
                        &tdcbt ("<small>Views<br>per hour</small>") .
                        &tdcbt ("<small>Article<br>count</small>")) ;
#     $out_html .= &tr (&tde . &tde . &tde . &tde . &the . &the . &the . &the . &the . &the . &the . &the . &the) ;
      $the1 = "<th class=cb style='background-color:$background_color1'>&nbsp;</th>" ; 
      $the2 = "<th class=cb style='background-color:$background_color2'>&nbsp;</th>" ; 
      $out_html .= &tr ($the1 . $the1 . $the1 . $the1 . $the1 . $the1 . $the1 . $the2 . $the2 . $the2 . $the1 . $the1 . $the1 . $the1 . $the1 . $the2 . $the2 . $the1 . $the2) ;
    # $out_html .= &tr (&tdimg ("<a href='TablesWikipediaZZ.htm'><img src='../Tables.png'></a> <a href='ChartsWikipediaZZ.htm'><img src='../BarCharts.png'></a>") .

      if ($region eq '')
      {
        $out_html .= &tr (
                        # &tdimg ("<font size=+1 color='#FFFFDD' face=\'Times'>W</font><a href='ChartsWikipediaZZ.htm'><img src='../BarCharts.png'></a>&nbsp;") .
                        # &tdimg ("<a href='ChartsWikipediaZZ.htm'><img src='../BarCharts.png'></a>&nbsp;") .
                          &tde . &tde .
                          &tdcb (&w("<a href='TablesWikipediaZZ.htm'> " . $out_btn_tables . " </a>")) .
                          &tdcb (&w("<a href='ChartsWikipediaZZ.htm'> " . $out_btn_charts . " </a>")) .
                          &tdcbt ("<a href='$out_url_all'>&Sigma;</a>") .
                         (&tdlbt ("<a href='TablesWikipediaZZ.htm'>" . $out_languages {"zz"} . "</a>")) . # &nbsp;(" . $#languages . ")")) .
                          &tdlbt ("<small><small><small>" .
                                  "<font color=#008800><span title='Africa'>AF<\/span><\/font> " .
                                  "<font color=#DD0000><span title='Asia'>AS<\/span><\/font> " .
                                  "<font color=#0000CC><span title='Europe'>EU<\/span><\/font> " .
                                  "<font color=#CC00CC><span title='North America'>NA<\/span><\/font> " .
                                  "<font color=#FFAA00><span title='South America'>SA<\/span><\/font> " .
                                  "<font color=#00AAD4><span title='Oceania'>OC<\/span><\/font> " .
                                  "<font color=#000000><span title='Constructed Language'>CL<\/span><\/font> " .
                                  "<font color=#000001><span title='World Language'>W<\/span><\/font></small></small></small>") .
                          &tde . &tde . &tde . &tde . &tde . &tde . &tde . &tde . &tde . &tde . &tde . &tde) ;
                        # &tdcbt ("<a href='$out_url_all'>" . &w( $out_site) . "</a>") .
      }
      $out_html .= "</thead>\n<tbody>\n" ;
    }

    my @languages2 = @languages ;
    if ($sitemap_new_layout)
    {
      @languages2 = @languages_speakers ;
    }

    foreach $wp (@languages2)
    {
      if ($skip {$wp}) { next ; }

      $last_month_active = 'n.a.' ;
      $months_ago_last_active = 'n.a.' ;
      if (defined $last_month_active {$wp})
      {
        my $year  = substr ($lastdump {"zz"},0,4) ; 
        my $month = substr ($lastdump {"zz"},4,2) ; 
        my $dumpdate_ord = ord (&yyyymm2b ($year,$month)) ;

        $last_month_active = &m2mmmyyyy ($last_month_active {$wp}) ; # 3 -> 8 -> 21 = Fibonacci numbers
        $months_ago_last_active = $dumpdate_ord - $last_month_active {$wp} ;
        if    ($months_ago_last_active > 21) { $last_month_active = "<font color=#FFBBBB>$last_month_active</font>" ; } 
        elsif ($months_ago_last_active >  8) { $last_month_active = "<font color=#DD8888>$last_month_active</font>" ; } 
        elsif ($months_ago_last_active >  3) { $last_month_active = "<font color=#882222>$last_month_active</font>" ; } 
      }

      $listed_wikis++ ;
      if ($months_ago_last_active ==  0) # active in last month 
      { $active_wikis1 ++ ; }
      if ($months_ago_last_active <=  2) # active in last three months 
      { $active_wikis3 ++ ; }
      if ($months_ago_last_active <=  11) # active in last twelve months 
      { $active_wikis12 ++ ; }
 
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
                              &tdcb ('Last active') . 
                              ($wikimedia ? &tdcb ("&Sigma;") : &tdlb ("&Sigma;")) .
                            # ($wikimedia ? &tdlb ($out_languages {$wpc} . "&nbsp;(" . $#languages . ")") : "") .
                            # June 2017, no longer show languages count in this cell
                            # instead show count for recenty active wikis above the table
                              ($wikimedia ? &tdlb ($out_languages {$wpc}) : "") .
                              &tdcb ("<a href='$out_url_all'>" . &w($out_site) . "</a>") .
                              &tde.
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

	  if ($mode_wo)
	  { $views = 0 ; } # not yet available

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
  
        $months_ago_last_active = &tdrb ($months_ago_last_active) ;
        $editors_ge_5   = &tdrb (@MonthlyStats {$wp.$c[2].'avg3'}) ;
        $editors_ge_100 = &tdrb (@MonthlyStats {$wp.$c[3].'avg3'}) ;
        $access_sysop   = &tdrb (@access {"$wp|sysop"}) ;
        $access_bots    = &tdrb (@access {"$wp|bot"}) ;
        $editors = $months_ago_last_active . $editors_ge_5 . $editors_ge_100 . $access_sysop . $access_bots ;

        $edits_anonymous = sprintf ("%.0f", 100 * $edits_total_ip {$wp} / ($edits_total {$wp} - $BotEditsArticlesPerWiki {$wp})) . "%" ;
        $cnt = @MonthlyStats {$wp.$c[11].'tot'} ;
        if ($cnt > 0)
        { $edits_bot = sprintf ("%.0f", 100 * $BotEditsArticlesPerWiki {$wp} / $cnt) . "%" ; }
        else
        { $edits_bot = "0%" ; }
        if (($wp eq "en") && ($BotEditsArticlesPerWiki {$wp} == 0))
        { $edits_bot = "" ; } # no data yet
        $edits = &tdrb ($edits_bot) . &tdrb ($edits_anonymous) ;    

        $code_website = "<a href='${out_urls {$wpc}}'>$wpc3</a>" ;

        if ($sitemap_new_layout)
        {
        # $out_html .= &tr (&tdimg ("<a href='TablesWikipedia" . uc($wpc) . ".htm'><img src='../Tables.png'></a> " .
        # $out_language_article = "<a href='" . $out_article {$wpc} . "'><b><font size=+1 color='#0000A0' face=\'Times'>W</font></b></a>" ;
        # $out_language_article = "[<a href='" . $out_article {$wpc} . "'>?</a>]" ;
          $out_language_article = "<a href='" . $out_article {$wpc} . "'>?</a> |" ;

          $dir_all_languages = '' ;
          if ($region ne '')
          { $dir_all_languages = '../EN/' ; }

          # build one row in main table on Sitemap page, e.g. https://stats.wikimedia.org/EN/Sitemap.htm
          $out_html .= &tr (
                          # &tdcb ($out_language_article .
                          # "<a href='ChartsWikipedia" . uc($wpc) . ".htm'><img src='../BarCharts.png'></a>") .
                            &tdcb (&w($lastdump_short_month {$wp})) .
                            &tdcb (&w("<a href='../../EN/Summary" . uc($wpc) . ".htm'> " . $out_summary . " </a>")) .
                            &tdcb (&w("<a href='${dir_all_languages}TablesWikipedia" . uc($wpc) . ".htm'> " . $out_btn_tables . " </a>")) .
                            &tdcb (&w("<a href='${dir_all_languages}ChartsWikipedia" . uc($wpc) . ".htm'> " . $out_btn_charts . " </a>")) .
                          # &tdcb ("<a href='ChartsWikipedia" . uc($wpc) . ".htm'><img src='../BarCharts.png'></a>") .
                            (($wikimedia && (!$mode_wx)) ? &tdcb ($code_website) : &tdlb ($code_website)) .
                          # (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name . ' ' . $out_language_article) : "") : "") .
                          # (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ("$out_language_article $out_language_name") : "") : "") .
                            (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ("<a href='" . $out_article {$wpc} . "'>$out_language_name</a>") : "") : "") .
                            $out_participation {$wpc2} .
                            $editors .
                            $edits .
                            $views .
                            &tdrb (&w ($totarticles))) ;
                          # &tdcb ("<a href='" . $out_urls {$wpc} . "'>" . &w($out_site) . "</a>") .
        }
        else
        {
          $out_html .= &tr ($views .
                            &tdrb (&w ($totarticles)) .
                            &tdrb (&w ($last_month_active)) . 
                            (($wikimedia && (!$mode_wx)) ? &tdcb ($wpc2) : &tdlb ($wpc2)) .
                            (((! $mode_wx) && (! $singlewiki)) ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") .
                            (  $mode_wx ? ($wikimedia ? &tdlb ($out_language_name) : "") : "") .
                            &tdcb ("<a href='" . $out_urls {$wpc} . "'>" . &w($out_site) . "</a>") .
                          # &tdcb (&w("<a href='../../EN/Summary" . uc($wpc) . ".htm'> " . $out_summary . " </a>")) .
                            &tdcb (&w("<a href='Summary" . uc($wpc) . ".htm'> " . $out_summary . " </a>")) .
                            &tdcb (&w("<a href='TablesWikipedia" . uc($wpc) . ".htm'> " . $out_btn_tables . " </a>")) .
                            &tdcb (&w("<a href='ChartsWikipedia" . uc($wpc) . ".htm'> " . $out_btn_charts . " </a>"))) ;
        }
     }
    }
    $out_html .= "</tbody>\n" ;
    
    if ($out_included ne '')
    { 
      if ($sitemap_new_layout)
      { $out_included =~ s/\<br\>//g ; }

      $out_html .= &tr ("<td class=l width=600 colspan=99>$out_included</td>") ; 
    }

    $out_html .= "</table>\n" ;

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

  $out_html .= "<a id='see_also' name='see_also'></a><table class='l' border=1 cellspacing=0 id=table3 style='' summary=''>\n" ;

  if ((! $mode_wx) && (! $singlewiki))
  {
    $out_html .= &tr (&tdlb   (&w ($out_report_descriptions [$#report_names])) .
                      &tdlb2b (&w ("<a href='Tables" . $report_names [$#report_names]. ".htm'>".
                                    $out_btn_tables . " &amp; " . $out_btn_charts . "</a>"))) ;

    if ($wikimedia)
    {
      if ($mode_wp)
      { $tables_pageviews = 'TablesPageViewsMonthlyCombined.htm' ; }
      else
      { $tables_pageviews = 'TablesPageViewsMonthly.htm' ; }
	      
      if ($region eq '')
      { $out_html .= &tr (&tdlb   (&w ($out_pageviews)) .
                          &tdlb2b (&w ("<a href='../EN/$tables_pageviews'>$out_btn_tables</a> " . blank_text_after ("31/03/2009", " <font color=#008000><b>NEW</b></font>")))) ; }
      else
      {
        my $region_uc = ucfirst ($region) ;
        $out_html .= &tr (&tdlb   (&w ($out_pageviews)) .
                          &tdlb2b (&w ("<a href='../EN/$tables_pageviews'>All languages</a><br>" .
                                       "<a href='../EN_$region_uc/$tables_pageviews'>$region_uc</a>"
                          ))) ;
      }
    }

    if ($growth_summary_generated)
    { $out_html .= &tr (&tdlb   (&w ($out_creation_history)) .
                        &tdlb2b (&w ("<a href='TablesWikipediaGrowthSummaryContributors.htm'>$out_btn_tables</a>"))) ; }

    $out_html .= &tr (&tdlb   (&w ($out_report_description_current_status)) .
                      &tdlb2b (&w ("<a href='TablesCurrentStatusVerbose.htm'>$out_btn_tables</a> "))) ;
    $out_html .= &tr (&tdlb   (&w ("$out_botactivity article editing")) .
                      &tdlb2b (&w ("<a href='../EN/BotActivityMatrixEdits.htm'>$out_btn_tables</a>"))) ;
    $out_html .= &tr (&tdlb   (&w ("$out_botactivity article creation")) .
                      &tdlb2b (&w ("<a href='../EN/BotActivityMatrixCreates.htm'>$out_btn_tables</a>" . blank_text_after ("31/03/2012", " <font color=#008000><b>NEW</b></font>")))) ;
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
                    &tdlb (&w ("<a href='Tables" . $report . ".htm'>" . $out_btn_tables . "</a>")) ;
      # if (($r == 1) || (($r >= 3) && ($r <= 6)) || ($r == 12) || ($r == 13) || ($r == 15) || ($r == 16) || (($mode_wp) && ($r == 21))) # April 2010: less trivia
        if (! $mode_wo) # do not add old charts for wikivoyage, they were never generated for that project
        {	
          if (($r == 1) || (($r >= 3) && ($r <= 6)) || ($r == 12) || (($mode_wp) && ($r == 21)))
          { $out_line .= &tdcb (&w ($out_btn_charts . "&nbsp;&nbsp;" .
                                    "<a href='PlotsPng" . $report . ".htm'>PNG</a>&nbsp;&nbsp;" .
                                    "<a href='PlotsSvg" . $report . ".htm'>SVG</a>")) ; }
          else
          { $out_line .= &tdeb ; }
        }

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

  $out_html =~ s/LISTEDWIKIS/$listed_wikis/ ;
  $out_html =~ s/ACTIVEWIKIS1/$active_wikis1/ ;
  $out_html =~ s/ACTIVEWIKIS3/$active_wikis3/ ;
  $out_html =~ s/ACTIVEWIKIS12/$active_wikis12/ ;

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
    # $out_html .= &tr (&tdlb2 ("Combined activity on all projects (*) <a href='http://stats.wikimedia.org/EN/TablesWikimediaAllProjectsWeighted.htm'>Weighted</a> / <a href='http://stats.wikimedia.org/EN/TablesWikimediaAllProjects.htm'>Unweighted</a>" . blank_text_after ("31/10/2012", " <font color=#008000><b>NEW</b></font><br>Activity = edits + uploads to Commons"))) ;
      $out_html .= &tr (&tdlb2 ("<a href='http://stats.wikimedia.org/EN/TablesWikimediaAllProjects.htm'>Combined activity on all projects</a>" . blank_text_after ("31/12/2012", " <font color=#008000><b>NEW</b></font>") . "<br>Activity = article edits + uploads to Commons")) ;
      if (! $mode_wb)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikibooks/$langcode/Sitemap.htm'>" . $out_wikibooks .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wikibooks/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_wk)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wiktionary/$langcode/Sitemap.htm'>" . $out_wiktionaries .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wiktionary/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_wn)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikinews/$langcode/Sitemap.htm'>" . $out_wikinews .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wikinews/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_wo)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikivoyage/$langcode/Sitemap.htm'>" . $out_wikivoyage .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wikivoyage/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/03/2013", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_wp)
      { $out_html .= &tr (&tdlb ("$more_stats <a href='http://stats.wikimedia.org/$langcode/Sitemap.htm'>" . $out_wikipedias .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_wq)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikiquote/$langcode/Sitemap.htm'>" . $out_wikiquotes .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wikiquote/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_ws)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikisource/$langcode/Sitemap.htm'>" . $out_wikisources .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wikisource/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_wv)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikiversity/$langcode/Sitemap.htm'>" . $out_wikiversities .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wikiversity/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
      if (! $mode_wx)
      { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/wikispecial/$langcode/Sitemap.htm'>" . $out_wikispecial .  "</a>") .
                          &tdlb("<a href='http://stats.wikimedia.org/wikispecial/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }
    }

    if ($mode_wp && ($region ne ''))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/$langcode/Sitemap.htm'>" . $out_wikipedias .  ", all languages</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN/ReportCardTopWikis.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($mode_wp && ($region ne 'africa'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Africa/Sitemap.htm'>" . $out_wikipedias .  ", region Africa</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN_Africa/ReportCardAfrica.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($mode_wp && ($region ne 'asia'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Asia/Sitemap.htm'>" . $out_wikipedias .  ", region Asia</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN_Asia/ReportCardAsia.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($mode_wp && ($region ne 'america'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_America/Sitemap.htm'>" . $out_wikipedias .  ", region America's</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN_America/ReportCardAmerica.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($mode_wp && ($region ne 'europe'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Europe/Sitemap.htm'>" . $out_wikipedias .  ", region Europe</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN_Europe/ReportCardEurope.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($mode_wp && ($region ne 'india'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_India/Sitemap.htm'>" . $out_wikipedias .  ", region India</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN_India/ReportCardIndia.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($mode_wp && ($region ne 'oceania'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Oceania/Sitemap.htm'>" . $out_wikipedias .  ", region Oceania</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN_Oceania/ReportCardOceania.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($mode_wp && ($region ne 'artificial'))
    { $out_html .= &tr (&tdlb ("$out_stats_for <a href='http://stats.wikimedia.org/EN_Artificial/Sitemap.htm'>" . $out_wikipedias .  ", artificial languages</a>"). &tdlb("<a href='http://stats.wikimedia.org/EN_Artificial/ReportCardArtificial.htm'>Summary</a>" . blank_text_after ("30/11/2011", " <font color=#008000><b>NEW</b></font>"))) ; }

    if ($region eq '')
    {
      if ((! $mode_wx) && ($growth_summary_generated))
      { $out_html .= &tr (&tdlb   (&w ("<a href='TablesWikipediaGrowthSummary.htm'>$out_creation_history</a>") . &tde)) ; }

      if ($mode_wx)
      {
        $out_html .= &tr (&tdlb (&w ("<a href='TablesCurrentStatusVerbose.htm'>$out_report_description_current_status</a> ") . &tde)) ;
      }
      $out_html .= &tr (&tdlb ("<a href='../EN/CategoryOverviewIndex.htm'>$out_categories</a>") . &tde) ;
    # $out_html .= &tr (&tdlb ("<a href='../EN/BotActivityMatrix.htm'>$out_botactivity</a>")) ;

      if ($mode_wp)
      { $out_html .= &tr (&tdlb ("<font color=#808080>$out_easytimeline</font>") . &tde) ; }
    # { $out_html .= &tr (&tdlb ("<a href='../EN/TimelinesIndex.htm'>$out_easytimeline</a>")) ; }

      if ($mode_wb || $mode_wv)
      { $out_html .= &tr (&tdlb ("<a href='../EN/WikiBookIndex.htm'>$out_stats_per $out_wikibook</a>") . &tde) ; }

      $out_html .= &tr (&tdlb ("Top 100 articles ranked <a href='http://stats.wikimedia.org/EN/TableRankArticleHistoryByArchiveSize.html'>by archive size</a>" .
                               blank_text_after ("30/04/2009", " <font color=#008000><b>NEW</b></font>") . "&nbsp;&nbsp;" .
                               "<a href='http://stats.wikimedia.org/EN/TableRankArticleHistoryByTotalEdits.html'>by edit count</a>" .
                               blank_text_after ("30/04/2009", " <font color=#008000><b>NEW</b></font>") ) . &tde) ;
      $out_html .= &tr (&tdlb ("<a href='http://meta.wikimedia.org/wiki/Template:Wikimedia_Growth'>Wikimedia growth</a>") . &tde) ;
      $out_html .= &tr (&tdlb ("Mailing list activity: <a href='https://stats.wikimedia.org/mail-lists/'>All lists</a>&nbsp;/&nbsp;".
                              "<a href='https://stats.wikimedia.org/mail-lists/_PowerPosters.html'>Power posters</a>") . &tde) ;

      $out_html .= &tr (&tdlb ("Job progress: <a href='http://www.infodisiac.com/cgi-bin/WikimediaDownload.pl'>Database dumps</a>&nbsp;/&nbsp;" .
                               "<a href='http://stats.wikimedia.org/WikiCountsJobProgress.html'>Data gathering</a> " . blank_text_after ("31/03/2009", " <font color=#008000><b>NEW</b></font>")) . &tde) ;
# Jan 31, 2019
#     $out_html .= &tr (&tdlb ("Raw data: <a href='http://dumps.wikimedia.org/other/wikistats_1'>csv zip files</a> (doc: <a href='http://meta.wikimedia.org/wiki/Wikistat_csv'>meta</a>)") . &tde) ;
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
  if ($mode_wo)  { $out_html .= "<h2>" . $out_wikivoyage .   "</h2>\n" ; }
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
                        &tdl ($out_languages {$wp}) . # "&nbsp;(" . $#languages . ")") .
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
  my $deep_link_wikistats2 = shift ;

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

# $out_msg = "<b><font color=red>January 2014: Unfortunately monthly database dump generation is delayed for many wikis. Reports will appear later than usual. Our sincere apologies for any inconvenience caused.</font><font color=#080><br>Upd. March 2: Dump generation was restarted on February 12. All dumps are up to date now for December, some not for January, some days to go. This is an intermediate update.</font></b>" ;

  &GenerateHtmlStart ($out_html_title,  $out_zoom_buttons,  $out_options,
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      $out_button_prev, $out_button_next,   $out_button_switch,
                      $out_crossref,    $out_msg) ;
  
  $out_html =~ s/<\/td><\/tr><\/table>/$deep_link_wikistats2<\/td><\/tr><\/table>/ ;
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
#  &LogT ("\nGenerateHtmlStartComparisonTables\n") ;

  if ($pageviews)
  {
    my ($dummy, $normalized) = @_ ;

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
    { $out_html_title = "$out_pageviews for <font color=#008000>$out_wikimedia, All Projects</font>" ; }
    else
    { $out_html_title = "$out_pageviews for <font color=#008000>$out_publication</font>" ; }

    if ($region ne "")
    { $out_html_title .= " for <font color=#008000>" . ucfirst ($region) . "</font>"; }

    if ($mode_wp)
    {
      if ($pageviews_non_mobile)
      { $out_html_title .= "<font color=#008000>, Non-mobile site</font>" ; }
      elsif ($pageviews_mobile)
      { $out_html_title .= "<font color=#008000>, Mobile site</font>" ; }
      elsif ($pageviews_combined)
      { $out_html_title .= "<font color=#008000>, Both sites</font>" ; }
    }

    if ($normalized)
    { $out_html_title .= "<font color=#008000>, Normalized</font>" ; }
    else
    { $out_html_title .= "<font color=#008000>, Raw data</font>" ; }

    $out_page_title  = $out_html_title ;
    $out_page_title2 = $out_html_title ;
    $out_html_title  =~ s/<[^>]*>//g ;

    if (defined ($dumpdate_hi))
    {
      $dumpdate2 = timegm (0,0,0,
                           substr ($dumpdate_hi,6,2),
                           substr ($dumpdate_hi,4,2)-1,
                           substr ($dumpdate_hi,0,4)-1900) ;
      $out_page_title2 .= "<br><b>" . &GetDate ($dumpdate2) . "<\/b>" ;
    }

  #  $out_crossref = &GenerateCrossReference ($language) ;

  #  &ReadLog ($language) ;

    &GenerateHtmlStart ($out_html_title,   $out_zoom,          $out_options,
                        $out_page_title2,  $out_page_subtitle, $out_explanation,
                        $out_button_prev,  $out_button_next,   $out_button_switch,
                        $out_crossref,     $out_msg) ;

    return ($out_page_title) ;
  }

  my $ndx_report = shift ;
  my $out_html_language = $language ;

  my $out_page_title    = $out_statistics ;
  my $out_page_subtitle = $out_report_descriptions [$ndx_report] ;

  print " report id $ndx_report: '$out_page_subtitle'\n" ;

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

  return $out_html_title ;
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
               $out_tracker_code .
               "</head>\n\n" .
               "<body bgcolor='#FFFFDD'>\n" .
               $out_page_header2 . $out_msg . "<hr class=b>$out_special_msg\n" ;
  if (($language eq "ja") || ($language eq "zh"))
  { $out_html =~ s/<\/?b>//g ; }

  if (! $pageviews)
  {
    my $sp2 = "&nbsp;&nbsp;" ;

    $link_wikistats_2 = "<a href='https://stats.wikimedia.org/v2/#/all-projects'>Wikistats 2</a>" ;
    $link_survey      = "<a href='https://www.mediawiki.org/wiki/Analytics/Wikistats/DumpReports/Future_per_report'>survey</a>" ;

# Jan 31, 2019
#   $link_feedback    = "<a href='https://wikitech.wikimedia.org/wiki/Talk:Analytics/Systems/Wikistats'>feedback and suggestions</a>" ; 
    $link_feedback    = "<a href='https://wikitech.wikimedia.org/wiki/Talk:Analytics/Systems/Wikistats'>feedback and suggestions</a>" ; 



# Jan 31, 2019
#$out_announcement = 
#   "<table width=1000><tr><td colspan=999 style='background-color:#DD8;text-align:left'>" .
#   "<font color=#107000>&nbsp;<br>$sp2" .
#   "<b>Jan 31, 2019: This the final release of Wikistats 1 dump-based reports. " . 
#   "Some of these data are available in the first release of Wikistats 2. " .  
#   "Read more <a href='http://stats.wikimedia.org/final_release_Wikistats_1'>here</a>" .           
#   "</td></tr></table>$sp2<br>" ;
#  "Erik Zachte, the author, has retired from WMF and no longer maintains these reports." . 
   #              "Maintenance of the scripts by others has never been seen as feasible: " . 
   #              "the scripts date from a different era (oldest are from 2002) and were designed for a totally different environment at that time. ". 
   #              "Continued publication of uncurated reports is a liability and not an option.<p>" .     
   #                 "<b>Dec 2017: WMF Analytics Team is happy to announce the first release of $link_wikistats_2</font></b>$sp2<p>" .
   #             "<p>${sp2}Wikistats has been redesigned for architectural simplicity, faster data processing, " . 
   #             "and a more dynamic and interactive user experience. The data used in the reports will also be made available for external processing.${sp2}" . 
   #             "<p>${sp2}First goal is to match the numbers of the current system, and to provide the most important reports, " . 
   #             "as decided by the Wikistats community (see $link_survey).${sp2}".
   #              "<br>${sp2}Over time, we will continue to migrate reports and add new ones that you find useful. " . 
   #              "We can also analyze the data in new and interesting ways, " . 
   #              "and look forward to hearing your $link_feedback.${sp2}" .
    $out_html .= $out_announcement ;

# request for comments banner shown March 2017-November 2017

#    $out_html .= "<table><tr><td colspan=999 style='background-color:#CC8;text-align:left'>" .
#                 "<font color=#000000>&nbsp;<br>$sp2" .
#                 "<b>May 2016: The major overhaul of Wikistats reports has entered a new phase.</b>$sp2<p>" .
#                 "${sp2}First phase focused on migrating the traffic analysis reports to our new infrastructure. Those are operational now.$sp2<br> " .
#                 "${sp2}The Analytics Team will now proceed to also migrate data collection and reporting about wiki content and contributors.$sp2<br> " .
#                 "${sp2}First results are expected later this year.$sp2<p>" .
#                 "${sp2}More info at <a href='http://infodisiac.com/blog/2016/05/wikistats-days-will-be-over-soon-long-live-wikistats-2-0/'>this announcement</a><br>" .
#                 "${sp2}You can see the first wireframes for Wikistats 2.0 and " .h
#                 "<a href='https://www.mediawiki.org/wiki/Wikistats_2.0_Design_Project/RequestforFeedback/Round1'>comment on the design here.</a></font>$sp2" .
#                 "</td></tr></table>$sp2<br>" ;

# survey banner shown September 2016 - February 2017

# survey banner shown September 2016 - February 2017
# "${sp2}You can still tell us which reports you want to see preserved, in this " .
# "<a href='https://www.mediawiki.org/wiki/Analytics/Wikistats/DumpReports/Future_per_report'>survey.</a></font>$sp2" .
# "</td></tr></table>$sp2<br>" ;

# original banner shown in 2016 May-Aug

#   $out_html .= "<table><tr><td colspan=999 style='background-color:#000;text-align:left'>" . 
#                "<font color=#00FF00>&nbsp;<br><h3><big>&nbsp;&nbsp;May 2016: Wikistats' days will be over soon. A successor is in the works.&nbsp;</h3></big></h3><br>&nbsp;&nbsp;" .
#                "<b>Read more at <a href='http://infodisiac.com/blog/2016/05/wikistats-days-will-be-over-soon-long-live-wikistats-2-0/'><font color=#A0A0FF>this announcement</font></a>. " . 
#                "Please tell us which reports you want to see preserved, in this <a href='https://www.mediawiki.org/wiki/Analytics/Wikistats/DumpReports/Future_per_report'><font color='#A0A0FF'>survey.</font></a></b></font>" . 
#                 "<br>&nbsp;</td></tr></table>" ;   
  }
}

sub GenerateColophon
{
  my ($comparison, $ploticus, $r, $dumpdetails) = @_ ;

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
    $out_sort_order3 = $out_sort_order2 . "<br>" . $out_included ;
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

  $path_about = "http://stats.wikimedia.org/index.html#fragment-14" ;

# if ($out_delay ne "")
# { $out_delay = "$out_delay<p>" ; }

  ($sec,$min,$hour) = gmtime(time);
  $out_generated_at = &GetDate (time) . ' ' . sprintf ("%02d:%02d",$hour,$min) ;

# Jan 31 2019
  if ($wikimedia)
  { $out_generated_at .= ' <font color=red><b>(final run)</b></font>' ; }

# obsolete SP001
# if ($squidslog)
# {
#   $out_myname = "Stefan Petrea" ;
#   $out_mymail = "stefan.petrea@### (no spam: ### = gmail.com)" ;
#   $out_mysite = "" ;
#   $out_squidslog = " from 1:1000 sampled squid logs" ;
# }  

  $out_unnormalized = "No data on this page have been normalized to 30 day months (as WMF does on certain traffic reports).<br>" ; 	

  $out_html .= "<p><small>\n" .
#              ($wikimedia ? $out_sort_order3 : "") .
#              $out_unnormalized . "\n" . # Nov 2015: also appears on traffic reports which can be normalized, investigate
               $out_history . "\n" .
               $out_sort_order3 .
               (($sitemap_new_layout) ? $participation {"intro"} : "") .
               $out_comparison2 .

               $out_generated . $out_generated_at . " " .

             # obsolete SP001    
             # ($squidslog ? "$out_squidslog<p>" :
               ($false ? "$out_squidslog<p>" :
	       ($dumpdetails ne '' ? "<p>$dumpdetails<p>" : ($pageviews ? $out_pageviewfiles : $out_sqlfiles) . &GetDate ($dumpdate2) . "\n<p>")) .


# Jan 31 2019: delay message no longer needed as reports are phased out
#              (! $pageviews ? $out_delay : "") . 

               (! $wikimedia ? "$out_no_wikimedia<br>" : "") .
             # $out_version . $version . "\n<br>" . # version id not updated in years
               $out_author . ":" . $out_myname . " (2002-Jan 2019)" .
               " (<a href='" . $out_mysite . "'>" . $out_site . "</a>)\n<br>" .
               ($wikimedia ? $out_mail . ":" . $out_mymail . "<br>\n" : "") .
               ($wikimedia ? "$out_documentation / $out_scripts / $out_csv_files" . ": <a href='$path_about'>About WikiStats</a>\n" : "") .
               $out_translator . "\n" .
               $out_ploticus2 . $out_r . "\n" .
               ((! $wikimedia && $mail ne "") ? "<p>" .$siteadmin . "\n" . $mail . "\n" : "") .
               $out_index_timelines . "\n<br><br>" .
               ($wikimedia ? "<p>". $out_download_reports : "") .
               ($wikimedia ? "<br>". $out_download_data : "") .
   
               ($wikimedia ? "<p>"  .$out_license : "") .
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

