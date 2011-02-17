#!/usr/bin/perl

sub WriteTimelines
{
  my $current_revision = shift ;
  my $time      = shift ;
  my $namespace = shift ;
  my $title     = shift ;
  my $user      = shift ;
  my $article   = shift ;

  $user =~ s/,/\&\#44\;/g ;
  $title =~ s/,/\&\#44\;/g ;

  # restore quotes
  $title   =~ s^\#\*\$\@^'^g ;

  $article =~ s^\#\*\$\@^'^g ;
  $article =~ s/\\r/\r/go ;
  $article =~ s/\\n/\n/go ;
  $article =~ s/\\"/"/go ;

  $article =~ s/^.*?<timeline>//is ;
  $article =~ s/<\/timeline>((?:(?!<timeline>).)*)$//is ;
  $article =~ s/<\/timeline>.*?<timeline>/\`/gis ;

  my @md5s ;
  my @timelines = split ('\`', $article) ;
  my @timelines2 ;

  foreach $timeline (@timelines)
  {
    $skip = $false ;

    if ($language eq "cs")
    {
      if ($timeline =~ /Zdroj.{0,5}?ISTAT/i)
      { $skip = $true ; }
    }

    if ($language eq "de")
    {
      if (($timeline =~ /Quelle.{0,5}?ISTAT/i) ||
          ($timeline =~ /width\:350 height\:120.*increment\:\d+000/i) ||
          ($timeline =~ /Einwohnerentwicklung/i) ||
          ($timeline =~ /Einwohner auf dem Gebiet/i))
      { $skip = $true ; }
    }

    if ($language eq "es")
    {
      if ($title =~ /^Demograf.*\//i)
      { $skip = $true ; }
    }

    if ($language eq "fr")
    {
      if ($timeline =~ /source INSEE/i)
      { $skip = $true ; }
    }

    if ($language eq "it")
    {
      if ($title =~ /^Demografia/i)
      { $skip = $true ; }
    }

    if ($language eq "nap")
    {
      if ($timeline =~ /date \'e ll\'ISTAT/i)
      { $skip = $true ; }
    }

    if ($language eq "nl")
    {
      if (($timeline =~ /inwonertal/i) || ($timeline =~ /from\:1960 till\:2010/i))
      { $skip = $true ; }
    }

    if ($skip)
    {
      if ($current_revision)
      { print FILE_TIMELINES_SKIPPED "$title\n" ; }

      next ;
    }

    if (substr ($timeline,0,1) ne "\x0A")
    { $timeline = "\x0A".$timeline ; }

    $md5 = md5_hex($timeline) ;
    push @md5s, $md5 ;

    $timeline =~ s/,/\&\#44\;/g ;
    $timeline =~ s/\|/&pipe;/g ;
    $timeline =~ s/\`/&backtick;/g ;
    $timeline =~ s/\n/`/gs ;
    push @timelines2, $timeline ;
  }

  if ($#md5s == -1)
  { return ; }

  $md5s      = join ('|', @md5s) ;
  $timelines = join ('|', @timelines2) ;
  if ($current_revision)
  { print FILE_TIMELINES "$namespace,$title,$time,C,$title,$user,$md5s,$timelines\n" }
  else
  { print FILE_TIMELINES "$namespace,$title,$time,O,$title,$user,$md5s\n" }
}

sub WriteTimelineOverviews
{
# &TraceMem ;
}

sub WriteHeadersFilesTimelines
{
  print FILE_TIMELINES
        "<html><head><title>Wikipedia Timelines $wikipedia</title></head>\n" .
        "<body bgcolor='#FFFFDD'>\n<a id='top' name='top'></a>\n" .
        "<table border='0' width='100%'><tr>\n" .
        "<td align='left'>" .
        "<h2>Graphical Timelines on {{wikipedia}} Wikipedia</h2>" .
        "{{intro}}" .
        "</td>\n<td align='right'>" .
        "<h2>" . &GetDate ($dumpdate_gm) . "</h2>\n" .
        "<a href='TimelinesIndex.htm'>index</a>" .
        "</td></tr></table>\n" .
        "<p>Feel feel to ask <a href='http://infodisiac.com'>Erik Zachte</a>, the author of EasyTimeline, for help or advice at his " .
        " <a href='http://en.wikipedia.org/wiki/User_talk:Erik_Zachte'>Wikipedia user page</a>" .
        "<p>See also " .
        "<a href='http://meta.wikipedia.org/wiki/EasyTimeline'>Introduction to EasyTimeline</a>" .
        " / <a href='http://meta.wikipedia.org/wiki/Help:EasyTimeline_syntax'>Syntax</a>\n{{toc}}" ;
  print FILE_TIMELINES_SKIPPED
        "<html><head><title>Wikipedia Timelines $wikipedia</title></head>\n" .
        "<body bgcolor='#FFFFDD'>\n" ;
}

sub CollectTimelines
{
  if ($mode ne "wp")
  { return ; }

  my $namespace = shift ;
  my $title     = shift ;
  my $article   = shift ;
  my $user      = shift ;
  my $time      = shift ;

  my $hr   = $true ;
  my $skip = $false ;

  if ($article !~ /<\/timeline>/i)
  { return ; }

  $user =~ s/,/\&\#44\;/g ;
  $title =~ s/,/\&\#44\;/g ;

  # restore quotes
  $title   =~ s^\#\*\$\@^'^g ;
  $article =~ s^\#\*\$\@^'^g ;
  $article =~ s/\\r/\r/go ;
  $article =~ s/\\n/\n/go ;
  $article =~ s/\\"/"/go ;
  $article =~ s/^.*?<timeline>//is ;
  $article =~ s/<\/timeline>((?:(?!<timeline>).)*)$//is ;
  $article =~ s/<\/timeline>.*?<timeline>/\`/gis ;
  my @md5s ;
  my @timelines = split ('\`', $article) ;

  foreach $timeline (@timelines)
  {
    $skip = $false ;

    if ($language eq "cs")
    {
      if ($timeline =~ /Zdroj.{0,5}?ISTAT/i)
      { $skip = $true ; }
    }

    if ($language eq "de")
    {
      if (($timeline =~ /Quelle.{0,5}?ISTAT/i) ||
          ($timeline =~ /width\:350 height\:120.*increment\:\d+000/i))
      { $skip = $true ; }
    }

    if ($language eq "es")
    {
      if ($title =~ /^Demograf.*\//i)
      { $skip = $true ; }
    }

    if ($language eq "it")
    {
      if ($title =~ /^Demografia/i)
      { $skip = $true ; }
    }

    if ($language eq "nl")
    {
      if (($timeline =~ /inwonertal/i) || ($timeline =~ /from\:1960 till\:2010/i))
      { $skip = $true ; }
    }

    if ($skip)
    {
      $timelines_skipped++ ;

      $title3 = $title ;
      $title3 =~ s/_/ /g ;
      $title3 = convert_unicode ($title3) ;
      $title4 = $title ;
      $title4 = encode_url ($title4) ;
      if ($namespace == 0)
      { $link_title = "<a href='http://$language.wikipedia.org/wiki/$title4'>$title3</a>" ; }
      elsif ($namespace == 10)
      { $link_title = "<a href='http://$language.wikipedia.org/wiki/Template:$title4'>Template:$title3</a>" ; }

      print FILE_TIMELINES_SKIPPED "$link_title<br>\n" ;

      next ;
    }

    if ($hr)
    {
      print FILE_TIMELINES "\n<hr>\n" ;
      $hr = $false ;
    }

    if (substr ($timeline,0,1) ne "\x0A")
    { $timeline = "\x0A".$timeline ; }
    $md5 = md5_hex($timeline) ;
    push @md5s, $md5 ;

    $timeline = convert_unicode ($timeline) ;

    if (($namespace == 0) || ($namespace == 10))
    {
      print FILE_TIMELINES "<a id='$md5' name='$md5'></a><a id='$scriptcnt' name='$scriptcnt'></a>\n" ;
      $title3 = $title ;
      $title3 =~ s/_/ /g ;
      $title3 = convert_unicode ($title3) ;
      $title4 = $title ;
      $title4 = encode_url ($title4) ;
      if ($namespace == 0)
      { $link_title = "<a href='http://$language.wikipedia.org/wiki/$title4'>$title3</a>" ; }
      elsif ($namespace == 10)
      { $link_title = "<a href='http://$language.wikipedia.org/wiki/Template:$title4'>Template:$title3</a>" ; }

      push @timelinesTOC, "<a href='\#$md5'>$title3</a>" ;

      print FILE_TIMELINES "<table border='0' width='100%'>\n<tr><td><b>$link_title</b></td>\n" ;

      $scriptcnt ++ ;
      if ($scriptcnt > 1)
      { print FILE_TIMELINES "<td align='right'><a href='\#top'>top</a>&nbsp;&nbsp;<a href='\#$scriptcnt'>next</a></td></tr></table>\n" ; }
      else
      { print FILE_TIMELINES "<td align='right'><a href='\#$scriptcnt'>next</a></td><tr></table>\n" ; }

      print FILE_TIMELINES "<p><img src=\'http://$language.wikipedia.org/upload/timeline/$md5.png\'>\n" ;
      print FILE_TIMELINES "{{$md5}}" ;
      print FILE_TIMELINES "<br><div style='background-color: #FFDEAD'><pre>\n$timeline\n</pre></div>\n" ;
    }
  }

  $md5 = join ('|', @md5s) ;

  my $ns = sprintf ("%02d", $namespace) ;
  $ns_title =  "$ns.$title" ;

  @timelines_info {$ns_title} = &csv ($time) . &csv ($time) . &csv ($ns) . &csv($md5) . $user ;
  @timelines_md5  {$ns_title} = $md5 ;
}

sub ChecksumTimelines
{
  if ($mode ne "wp")
  { return ; }

  my $namespace = shift ;
  my $title = shift ;
  my $article = shift ;

  if ($article !~ /<\/timeline>/i)
  { return ("","") ; }

  $title   =~ s/,/\&\#44\;/g ;
  $title   =~ s^\#\*\$\@^'^g ;
  $article =~ s^\#\*\$\@^'^g ;
  $article =~ s/\\r/\r/go ;
  $article =~ s/\\n/\n/go ;
  $article =~ s/\\"/"/go ;
  $article =~ s/^.*?<timeline>//is ;
  $article =~ s/<\/timeline>((?:(?!<timeline>).)*)$//is ;
  $article =~ s/<\/timeline>.*?<timeline>/\`/gis ;
  my @md5s ;
  my @timelines = split ('\`', $article) ;

  foreach $timeline (@timelines)
  {
    $md5 = md5_hex($timeline) ;
    push @md5s, $md5 ;
  }

  $md5 = join ('|', @md5s) ;

  my $ns = sprintf ("%02d", $namespace) ;
  $ns_title =  "$ns.$title" ;

  return ($ns_title, $md5) ;
}

sub UpdateTimelineCounts
{
  if ($mode ne "wp")
  { return ; }

  my $ns_title = shift ;
  my $md5  = shift ;
  my $user = shift ;
  my $time = shift ;

  $user =~ s/,/\&\#44\;/g ;

  $timeline_info = @timelines_info {$ns_title} ;
  my ($firstedit, $lastedit, $ns, $md5_current, $initiator) = split (',', $timeline_info) ;

  if ($md5_current eq $md5) # find timestamp when current revision of timeline was edited
  {
    if ($time < $lastedit)
    { $lastedit = $time ; }
  }

  if ($time < $firstedit)  # find initiator of first timeline in this article
  {
    $firstedit = $time ;
    $initiator = $user ;
  }

  $timeline_info = join (',', ($firstedit, $lastedit, $ns, $md5_current, $initiator)) ;
  @timelines_info {$ns_title} = $timeline_info ;
}

1;
