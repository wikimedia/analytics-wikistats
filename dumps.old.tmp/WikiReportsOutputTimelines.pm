#!/usr/bin/perl

sub GenerateTimelinePages
{
  if (! $mode_wp)
  { return ; }

  &LogT ("\nGenerate Timeline Indexes") ;
  my (@timelines, $out_table) ;
  &ReadFileCsv ($file_csv_timelines, "") ;

  my $out_html_date = "" ;
  my $dumpdate ;

  if (defined ($dumpdate_hi))
  {
    $dumpdate2 = timegm (0,0,0,
                         substr ($dumpdate_hi,6,2),
                         substr ($dumpdate_hi,4,2)-1,
                         substr ($dumpdate_hi,0,4)-1900) ;
    $out_explanation = &GetDate ($dumpdate2) ;
  }

  $out_crossref = &GenerateCrossReference ("") ;

  my $out_page_title    = "Gallery of graphical timelines" ;
  my $out_page_subtitle = "Timelines per wikipedia" ;
  my $out_html_title    = $out_page_title ;

  $out_html = "" ;
  my $out_msg = "" ;

  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      "", "", "", $out_crossref, $out_msg) ;

  $out_html2 = $out_html ;

  $out_page_title    = "Selected graphical timelines" ;
# $out_page_subtitle = "Major timelines on all wikipedias" ;
  $out_page_subtitle = "All timelines on all wikipedias" ;
  $out_html_title    = $out_page_title ;

  $out_html = "" ;
  &GenerateHtmlStart ($out_html_title,  "" , "",
                      $out_page_title,  $out_page_subtitle, $out_explanation,
                      "", "", "", $out_crossref, $out_msg) ;

  $out_html  .= "{{1}}" ;
  $out_html2 .= "{{1}}" ;

  @csv = sort {&csvkey_lang_timegm ($a) cmp &csvkey_lang_timegm ($b)} @csv ;

  my $wp_prev = "" ;
  foreach $line (@csv)
  {
    my ($wp, $time1, $time2, $ns, $md5, $user, $title) = split (",", $line) ;
    my @md5 = split ('\|', $md5) ;

    $ns = substr ($title,0,2) ;
    if (($ns ne "00") && ($ns ne "10")) { next ; }

    if ($#md5 > 0)
    { $q = "?" ; }
    else
    { $q = "" ; }

    if ($wp ne $wp_prev)
    {
      $out_html .= "<p><hr size='2' color='green'>" ;
      $out_html .= "<hr size='2' color='green'>" ;

      if ($wp_prev ne "")
      { &GenerateTimelinePagesAddUsers ; }

      $out_html .= "<a id='$wp' name='$wp'></a><h2>" . $out_languages {$wp} . " Wikipedia</h2>\n" ;
      $out_html .= "{{2}}" ;
      undef (%firstedits) ;
    }
    else
    { $out_html .= "<hr>" ; }

    $firstedits {$user} ++ ;

    $title  = substr ($title,3) ;
    $title2 = $title ;
    $title2 =~ s/_/ /g ;
    $title  = encode_url ($title) ;
    $title2 = convert_unicode ($title2) ;
    $user2  = $user ;
    $user   = encode_url ($user) ;
    $user2  = convert_unicode ($user2) ;

    if ($ns eq "00")
    { $link_title = "<a href='http://$wp.wikipedia.org$out_wikipage$title'>$title2</a>" ; }
    elsif ($ns eq "10")
    { $link_title = "<a href='http://$wp.wikipedia.org$out_wikipageTemplate:$title'>Template:$title2</a>" ; }
    else
    { $link_title = "<a href='http://$wp.wikipedia.org$out_wikipageTemplate:$title'>$ns: $title2</a>" } ;

    $link_user = "<a href='http://$wp.wikipedia.org$out_wikipage" . $out_userpages {$wp} . ":" . $user .
                 "'>$user2</a>" ;

    $date1 = &GetDateEnglish($time1) ;
    $date2 = &GetDateEnglish($time2) ;

    $out_html .= "<p><table border='0' width='100%' summary='Article reference'><tr><td><b>$wp $link_title</b>\n" ;
    $out_html .= "<td align='right'><small><a href=\'Timelines" . uc ($wp) .
                 ".htm\#" . $md5[0] . "\'>Script</a></small></td></tr></table>\n" ;
    if ($date1 eq $date2)
    {  $out_html .= "<p><small>First version by $link_user $q on $date1</small>\n" ; }
    else
    {  $out_html .= "<p><small>First version by $link_user $q on $date1, last update on $date2</small>\n" ; }

    foreach $md5b (@md5)
    {
      $out_html .= "<p><img src=\'http://$wp.wikipedia.org/upload/timeline/$md5b.png\'></td>\n" ;
      $timelines {$wp} ++ ;
      if ($time2 > $timeline_last {$wp})
      { $timeline_last {$wp} = $time2 ; }
    }

    $wp_prev = $wp ;
  }

  &GenerateTimelinePagesAddUsers ;

  $out_table = "<table border='1' cellpadding='0' cellspacing='0' summary='Timeline'>\n" ;
  $out_table .= "<tr><td class=cb>&nbsp;</td>" .
                    "<td class=lb>&nbsp;Language&nbsp;</td>" .
                    "<td class=rb>&nbsp;Count&nbsp;</td>" .
                    "<td class=rb>&nbsp;Last update&nbsp;</td>" .
                    "<td class=cb>&nbsp;Gallery&nbsp;</td></tr>\n" ;
  my $total = 0 ;
  my $last = 0 ;

  foreach $wp (keys %timelines)
  { $total += $timelines {$wp} ; }

  foreach $wp (keys %timeline_last)
  {
    if ($timeline_last {$wp} > $last)
    { $last = $timeline_last {$wp} ; }
  }
  $last = &GetDateEnglish ($last) ;

  $out_table .= "<tr><td class=lb>&nbsp;&Sigma;&nbsp;</td>" .
                    "<td class=lb>&nbsp;<a href='http://www.wikipedia.org'>$out_all_languages</a>&nbsp;</td>" .
                    "<td class=rb>&nbsp;$total&nbsp;</td>" .
                    "<td class=rb>&nbsp;$last&nbsp;</td>" .
                    "<td class=cb>&nbsp;</td></tr>\n" ;

  foreach $wp (sort keys %timelines)
  { $out_table .= "<tr><td class=lb>&nbsp;$wp&nbsp;</td>" .
                      "<td class=lb>&nbsp;<a href='\#$wp'>" . $out_languages {$wp} . "</a>&nbsp;</td>" .
                      "<td class=rb>&nbsp;" . $timelines {$wp} . "&nbsp;</td>" .
                      "<td class=rb>&nbsp;" . &GetDateEnglish ($timeline_last {$wp}) . "&nbsp;</td>" .
                      "<td class=cb>&nbsp;<a href='Timelines" . uc ($wp) . ".htm'>Images/Scripts</a>&nbsp;</td>" .
                      "</tr>\n" ; }
  $out_table .= "</table>\n" ;

  $out_html  =~ s/\{\{1\}\}/$out_table/ ;
  $out_table =~ s/<a href\=\'\#[^>]*>([^<]*)<\/a>/$1/g ; # remove local links
  $out_html2 =~ s/\{\{1\}\}/$out_table/ ;

  my $out_footer = "<p><small>Note: only timelines on article and template pages have been counted. " .
                   "Timelines on discussion pages, user pages, etc are ignored.</small>\n" .
                   "<hr><small>Generated on " . &GetDateEnglish (time) . " from recent <a href='http:/download.wikimedia.org'>database dump files</a>.<br>" .
                   "Data processed up to " . &GetDateEnglish ($dumpdate) . "</small>\n" ;

  $out_html  .= "<p><hr>$out_footer</body></html>" ;
  $out_html2 .= "$out_footer</body></html>" ;

  $file_html = $path_out_timelines . "TimelinesOverview.htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html) ; # convert_unicode ($out_html)) ;
  close "FILE_OUT" ;

  $file_html = $path_out_timelines . "TimelinesIndex.htm" ;
  open "FILE_OUT", ">", $file_html ;
  print FILE_OUT &AlignPerLanguage ($out_html2) ;
  close "FILE_OUT" ;

  # temp copy till this is sorted out
  # $file_html = $path_out_timelines . "TimeLinesIndex.htm" ;
  # open "FILE_OUT", ">", $file_html ;
  # print FILE_OUT &AlignPerLanguage ($out_html2) ;
  # close "FILE_OUT" ;
}

sub GenerateTimelinePagesAddUsers
{
  if (! $mode_wp)
  { return ; }

  my ($user, @firstedits2) ;
  $out_table = "<table border='1' cellspacing='0' cellpadding='0' summary='Users'>\n" ;
  $out_table .= "<tr><th align='left'>&nbsp;<small>User</small>&nbsp;</th><th>&nbsp;<small>Timelines</small>&nbsp;</th></tr>\n" ;

  foreach my $user (keys %firstedits)
  { push @firstedits2, sprintf ("%3d", $firstedits {$user}) . "," . $user ; }
  @firstedits2 = sort { $b <=> $a } @firstedits2 ;

  foreach $line (@firstedits2)
  {
    ($count, $user) = split (",", $line) ;
     $out_table .= "<tr><td class=cb>&nbsp;<small>$user</small>&nbsp;</td>" .
                       "<td class=cb>&nbsp;<small>$count</small>&nbsp;</td></tr>\n" ;
  }

  $out_table .= "</table><p><hr>\n" ;
  $out_html =~ s/\{\{2\}\}/$out_table/ ;
}

# move pages produced in WikiCounts job to folder that is always publicly available
sub MoveTimelinePages
{
  if (! $mode_wp)
  { return ; }

  my ($file_in, $file_out) ;
  my $path_in_timelines = $path_in . "Timelines" ;

  &LogT ("\nMove Timeline Pages") ;
  opendir (DIR, $path_in_timelines) or &Log ("Could no open dir $path_in_timelines"), exit ;
  while ($file = readdir (DIR))
  {
    if ($file =~ /^Timelines.*\.htm$/)
    {
      $file_in  = $path_in_timelines  . "/" . $file ;
      $file_out = $path_out_timelines . "/" . $file ;

      &Log2 ("\nMove $file_in") ;

      open FILE_TIMELINE, "<", $file_in ;
      @timeline = <FILE_TIMELINE> ;
      close FILE_TIMELINE ;

      open FILE_TIMELINE, ">", $file_out ;
      print FILE_TIMELINE @timeline ;
      close FILE_TIMELINE ;
      unlink $file_in ;
    }
  }
  closedir (DIR) ;
}

1;
