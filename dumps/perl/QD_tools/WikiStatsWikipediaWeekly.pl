#!/usr/bin/perl

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;

  $false     = 0 ;
  $true      = 1 ;

  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  print "\nWikiStatsWikipediaWeekly started at " . sprintf ("%2d/%2d/%4d %2d:%2d:%2d", $mday, $mon+1, $year+1900, $hour, $min, $sec) . "\n" ;

  $file_log  = "WikipediaWeekly.log" ;
  $file_data = "WikipediaWeekly.txt" ;
  $file_csv  = "WikipediaWeekly.csv" ;
  $file_html_c = "WikipediaWeekly.htm" ;
  $file_html_v = "WikipediaWeeklyVerbose.htm" ;

  if (-d "/mnt/htdocs")
  {
    print "Job runs on bayes\n" ;
    require "/home/ezachte/wikistats/WikiReportsDate.pl" ;
    $file_log    = "/tmp/wikistats/WikipediaWeekly.log" ;
    $file_data   = "/tmp/wikistats/WikipediaWeekly.txt" ;
    $file_csv    = "/mnt/htdocs/EN/WikipediaWeekly.csv" ;
    $file_html_c = "/mnt/htdocs/EN/WikipediaWeekly.htm" ;
    $file_html_v = "/mnt/htdocs/EN/WikipediaWeeklyVerbose.htm" ;
  }
  else
  {
    print "Job does not run bayes\n" ;
    require "WikiReportsDate.pl" ;
  }

  &OpenLog ;
  &FetchPages ;
  &AnalyzeContent ;
  close "FILE_LOG" ;
  exit ;

sub FetchPages
{
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $lastmonth = $mon+ 1 ;
  $lastyear  = $year + 1900 ;
  $lastdate  = sprintf ("%04d/%02d", $lastyear, $lastmonth) ;

  open FILE_DATA, '>', $file_data ;

  &Log ("\nFetch pages from 2006/10 till $lastdate\n\n") ;

  $currmonth = 10 ;
  $curryear = 2006 ;
  $currdate = sprintf ("%04d/%02d", $curryear, $currmonth) ;

  while (($curryear < $lastyear) || (($curryear == $lastyear) && ($currmonth <= $lastmonth)))
  {
    $url = "http://wikipediaweekly.org/" . sprintf ("%04d/%02d", $curryear, $currmonth) ;
    $content = "" ;
    ($result, $content) = &GetPage ($url, $true) ;

     $currdate = sprintf ("%04d/%02d", $curryear, $currmonth) ;
     my @lines = split ("\n", $content) ;
     &Log ("Lines: " . $#lines . "\n\n") ;
     foreach $line (@lines)
     { print FILE_DATA "$currdate $line\n" ; }
    $currmonth++ ;
    if ($currmonth > 12)
    {
      $currmonth = 1 ;
      $curryear  ++ ;
    }
  }
  close FILE_DATA ;
}

sub GetPage
{
  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  my $raw_url = shift ;
  my $is_html = shift ;
  my ($success, $content, $attempts) ;
  my $file = $raw_url ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikimedia Perl job / EZ");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  my $succes = $false ;

  &Log ("\nFetch '$file'") ;
  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { &Log (" -> 404\n") ; }
      else
      { &Log (" -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
      return ($false) ;
    }
    # else
    # { &Log ("\n") ; }

    $content = $response->content();

    # if ($is_html && ($content !~ m/<\/html>/i))
    # {
    #   &Log ("Page is incomplete:\n  '$raw_url'\n") ;
    #   next ;
    # }

    $succes = $true ;
  }

  if (! $succes)
  { &Log (" -> error: \nPage not retrieved after " . (--$attempts) . " attempts !!\n\n") ; }
  else
  { &Log (" -> OK\n") ; }

  return ($succes,$content) ;
}

sub AnalyzeContent
{
  my $year    = shift ;
  my $month   = shift ;
  my $content = shift ;

  open FILE_DATA,   '<', $file_data ;
  open FILE_CSV,    '>', $file_csv ;
  open FILE_HTML_C, '>', $file_html_c ;
  open FILE_HTML_V, '>', $file_html_v ;

  $language = "en" ;
  $header = "<!DOCTYPE FILE_HTML PUBLIC '-//W3C//DTD FILE_HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>\n" .
            "<html lang='en'>\n" .
            "<head>\n" .
            "<title>Wikipedia Weekly statistics</title>\n" .
            "<meta http-equiv='Content-type' content='text/html; charset=iso-8859-1'>\n" .
            "<meta name='robots' content='index,follow'>\n" .
            "<script language='javascript' type='text/javascript' src='../WikipediaStatistics13.js'></script>\n" .
            "<style type='text/css'>\n" .
            "<!--\n" .
            "body {font-family:arial,sans-serif; font-size:12px }\n" .
            "h2   {margin:0px 0px 3px 0px; font-size:18px}\n" .
            "td   {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top}\n" .
            "th   {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top ; font-width:bold}\n" .
            "td.h {text-align:left;}\n" .
            "td.r {text-align:right;  border: inset 1px #FFFFFF}\n" .
            "td.c {text-align:center; border: inset 1px #FFFFFF}\n" .
            "td.l {text-align:left;   border: inset 1px #FFFFFF}\n" .
            "th.c {text-align:center; border: inset 1px #FFFFFF}\n" .
            "th.l {text-align:left;   border: inset 1px #FFFFFF}\n" .
            "a:link { color:blue;text-decoration:none;}\n" .
            "a:visited {color:#0000FF;text-decoration:none;}\n" .
            "a:active  {color:#0000FF;text-decoration:none;}\n" .
            "a:hover   {color:#FF00FF;text-decoration:underline}\n" .
            "-->\n" .
            "</style>\n" .
            "<body bgcolor='\#FFFFDD'>\n<table width=100%>\n<tr><td class=h>\n<h2><a href='http://wikipediaweekly.org/'>Wikipedia Weekly</a> statistics</h2>\n</td>\n<td>" .
            "<input type='button' value=' Wikimedia Statistics ' onclick='window.location=\"http://stats.wikimedia.org\"'><br>LINK" .
            "</td></tr>\n</table><hr>\nPRE\n" ;

  # to be localized some day like any reports
  $out_license      = "All data and images on this page are in the public domain." ;
  $out_generated    = "Generated on " ;
  $out_author       = "Author" ;
  $out_mail         = "Mail" ;
  $out_site         = "Web site" ;
  $out_home         = "Home" ;
  $out_sitemap      = "Site map";
  $out_myname = "Erik Zachte" ;
  $out_mymail = "ezachte@### (no spam: ### = wikimedia.org)" ;
  $out_mysite = "http://infodisiac.com/" ;

  $colophon = "<p><small>\n" .
               $out_generated . &GetDate (time) . "\n<br>" .
               $out_author . ":" . $out_myname .
               " (<a href='" . $out_mysite . "'>" . $out_site . "</a>)\n<br>" .
               "$out_mail: $out_mymail<br>\n" .
               "$out_license" .
               "</small>\n" ;

  $html_c = $header ;
  $html_v = $header ;

  $html_c =~ s/LINK/<p>Also available: <a href='WikipediaWeeklyVerbose.htm'>verbose version<\/a> (with comments), <a href='WikipediaWeekly.csv'>csv version<\/a>/ ;
  $html_c .= "<table border=1>\n" ;
  $html_v =~ s/LINK/<p>Also available: <a href='WikipediaWeekly.htm'>concise version<\/a> (just counts), <a href='WikipediaWeekly.csv'>csv version<\/a>/ ;
  $html_v .= "<table border=1 width=1000>\n" ;

  $html_c .= "<tr><th class=l valign=top>Post</th><th class=l>Month</th><th class=l>Podcast<br>duration</th><th class=r>Downloaded<br>Mp3's</th><th class=r>Downloaded<br>Ogg's</th><th class=l>Episode</th></tr>\n" ;
  $html_v .= "<tr><th class=l valign=top>Post</th><th class=l>Month</th><th class=l>Podcast<br>duration</th><th class=r>Downloaded<br>Mp3's</th><th class=r>Downloaded<br>Ogg's</th><th class=l>Episode</th></tr>\n" ;

  $get_text = $false ;
  while ($line = <FILE_DATA>)
  {
    chomp ($line) ;
    $date = substr ($line,0,7) ;
    $line = substr ($line,7) ;

    if ($line =~ /<h3 /)
    {

      if ($post ne "")
      {
        if ($prevdate eq "")
        { $prevdate = $date ; }
        @data {$post} = "$post|$prevdate|$length|$sec|$downloads_mp3|$downloads_ogg|$episode|$comments\n" ;
        $comments = "" ;
        $downloads_mp3 = "     " ;
        $downloads_ogg = "     " ;
        $prevdate = $date ;
      }
      ($post = $line) =~ s/^.*?(<h3[^>]*>).*$/$1/ ;
      $post =~ s/^.*?post-(\d+).*$/$1/ ;
      $post = sprintf ("%4d", $post) ;

      ($episode = $line) =~ s/^.*?title="Permanent Link:\s*(?:Wikipedia Weekly)?\s*([^\"]+).*$/$1/ ;
      $episode =~ s/Episode // ; # at least on Episode 2
      $episode =~ s/^: // ; # at least on Episode 13-16
      $episode =~ s/^(\d+)\:\s*/$1 / ;
      $episode =~ s/^(\d+)\s*\-\s*/$1 / ;
      $episode =~ s/&#?8217;/'/g ;
      $length = "        " ;
      $sec    = "    " ;
    }

    #   if ($line =~ /Wikipedia Weekly.*?\[\d+\:\d+m\]/)
    if ($line =~ /\[\d+\:\d+m\]/)
    {
      ($length = $line) =~ s/^.*?(\[\d+\:\d+m\]).*$/$1/ ;
      $length =~ s/\[(\d):/[0$1:/ ; # post 112
      ($min,$sec) = split ('\:', $length) ;
       $min =~ s/[^\d]//g ;
       $sec =~ s/[^\d]//g ;
      $sec = sprintf ("%4d", $min * 60 + $sec) ;
    }

    if ($line =~ /audio_mp3_button.png/)
    {
      ($downloads_mp3 = $line) =~ s/.*?>download\s*<\/a>//i ;
      $downloads_mp3 =~ s/.*?\((\d+).*$/$1/ ;
      $downloads_mp3 = sprintf ("%5d", $downloads_mp3) ;
      if ($downloads_mp3 > $downloads_mp3_max)
      { $downloads_mp3_max = $downloads_mp3 ; }
    }
    if ($line =~ /audio_ogg_button.png/)
    {
      ($downloads_ogg = $line) =~ s/.*?>download\s*<\/a>//i ;
      $downloads_ogg =~ s/.*?\((\d+).*$/$1/ ;
      $downloads_ogg = sprintf ("%5d", $downloads_ogg) ;
      if ($downloads_ogg > $downloads_ogg_max)
      { $downloads_ogg_max = $downloads_ogg ; }
    }

    if ($line =~ /<div /)
    { $get_text = $false ; }
    if ($get_text)
    {
      # $line =~ s/^.*?<p>([^<]+)/$1/ ;
      # print "LINE $line\n" ;
      $comments .= "$line\n" ;
    }
    if ($line =~ /Filed under/)
    { $get_text = $true ; }

  }

  @data {$post} = "$post|$prevdate|$length|$sec|$downloads_mp3|$downloads_ogg|$episode|$comments\n" ;

  print FILE_CSV "\"post\",\"date\",\"length\",\"seconds\",\"downloads_mp3\",\"downloads_ogg\",\"episode\"\n" ;
  foreach $key (sort {$a <=> $b} keys %data)
  {
    ($post,$date,$length,$sec, $downloads_mp3,$downloads_ogg,$episode,$comments) = split ('\|',@data {$key}) ;
    &Log ("$post $date $length $sec $downloads_mp3 $downloads_ogg - $episode\n") ;
    $year = substr ($date,0,4) ;
    $downloads_mp3_tot {$year} += $downloads_mp3 ;
    $downloads_ogg_tot {$year} += $downloads_ogg ;
    $downloads_mp3_tot {'total'} += $downloads_mp3 ;
    $downloads_ogg_tot {'total'} += $downloads_ogg ;
    $seconds_tot {$year} += $sec ;
    $seconds_tot {'total'} += $sec ;

    print FILE_CSV "\"$post\",\"$date\",\"$length\",$sec,$downloads_mp3,$downloads_ogg,\"$episode\"\n" ;

    if ($length =~ /^\s*$/)
    { $length = "&nbsp;" ; }
    if ($downloads_mp3 =~ /^\s*$/)
    { $downloads_mp3 = "&nbsp;" ; }
    if ($downloads_ogg =~ /^\s*$/)
    { $downloads_ogg = "&nbsp;" ; }
    $length =~ s/^\[(\d+\:\d+)m\]/$1/ ;

    $date2 = $date ;
    if ($date ne $dateprev)
    { $date2 = "<a href='http://wikipediaweekly.org/$date'>$date</a>" ; }
    if ($downloads_mp3 == $downloads_mp3_max)
    { $downloads_mp3 = "<b>$downloads_mp3</b>" ; }
    if ($downloads_ogg == $downloads_ogg_max)
    { $downloads_ogg = "<b>$downloads_ogg</b>" ; }

    $html_c .= "<tr><td class=c>$post</td><td class=c>$date2</td><td class=c>$length</td><td class=r>$downloads_mp3</td><td class=r>$downloads_ogg</td><td class=l>$episode</td></tr>\n" ;
    $html_v .= "<tr><td class=c>$post</td><td class=c>$date2</td><td class=c>$length</td><td class=r>$downloads_mp3</td><td class=r>$downloads_ogg</td><td class=l>$episode</td></tr>\n" .
               "<tr><td colspan=99 class=l wrap>$comments</td></tr>\n" ;
    $dateprev = $date ;
  }
  $html_c .= "</table>\n\n" ;
  $html_v .= "</table>\n\n" ;

  &Log ("\n") ;
  $htmlpre .= "<pre>\n" ;
  foreach $year (sort {$a <=> $b} keys %seconds_tot)
  {
    if ($year !~ /^\d\d\d\d$/) { next ; }
    &Log ("$year:  " . sprintf ("%6d", $downloads_mp3_tot {$year}) . " mp3 downloads, " .  sprintf ("%6d", $downloads_ogg_tot {$year}) . " ogg downloads, " . sprintf ("%4.0f", $seconds_tot {$year} /60) . " minutes podcast \n") ;
    $htmlpre .= "$year:  " . sprintf ("%6d", $downloads_mp3_tot {$year}) . " mp3 downloads, " .  sprintf ("%6d", $downloads_ogg_tot {$year}) . " ogg downloads, " . sprintf ("%4.0f", $seconds_tot {$year} /60) . " minutes podcast \n" ;
  }
  &Log ("\ntotal: " . sprintf ("%6d", $downloads_mp3_tot {'total'}) . " mp3 downloads, " .  sprintf ("%6d", $downloads_ogg_tot {'total'}) . " ogg downloads, " . sprintf ("%4.0f", $seconds_tot {'total'} /60) . " minutes podcast \n") ;
  $htmlpre .= "\ntotal: " . sprintf ("%6d", $downloads_mp3_tot {'total'}) . " mp3 downloads, " .  sprintf ("%6d", $downloads_ogg_tot {'total'}) . " ogg downloads, " . sprintf ("%4.0f", $seconds_tot {'total'} /60) . " minutes podcast \n" ;
  $htmlpre .= "</pre>\n" ;
  $html_c =~ s/PRE/$htmlpre/ ;
  $html_v =~ s/PRE/$htmlpre/ ;

  close FILE_CSV ;

  $html_c .= "$colophon</body>\n</html>\n" ;
  $html_v .= "$colophon</body>\n</html>\n" ;

  print FILE_HTML_V $html_v ;
  close FILE_HTML_V ;

  print FILE_HTML_C $html_c ;
  close FILE_HTML_C ;
}

sub ConvertDate
{
  my $date = shift ;
  my $time = substr ($date,0,5) ;
  my $hour = substr ($time,0,2) ;
  $date =~ s/^[^\s]* // ;
  ($day,$month,$year) = split (' ',$date) ;

     if ($month =~ /^january$/i)    { $month = 1 ; }
  elsif ($month =~ /^february$/i)   { $month = 2 ; }
  elsif ($month =~ /^march$/i)      { $month = 3 ; }
  elsif ($month =~ /^april$/i)      { $month = 4 ; }
  elsif ($month =~ /^may$/i)        { $month = 5 ; }
  elsif ($month =~ /^june$/i)       { $month = 6 ; }
  elsif ($month =~ /^july$/i)       { $month = 7 ; }
  elsif ($month =~ /^august$/i)     { $month = 8 ; }
  elsif ($month =~ /^september$/i)  { $month = 9 ; }
  elsif ($month =~ /^october$/i)    { $month = 10 ; }
  elsif ($month =~ /^november$/i)   { $month = 11 ; }
  elsif ($month =~ /^december$/i)   { $month = 12 ; }
  else { &Log ("Invalid month '$month' encountered\n") ; exit ; }

  $date = sprintf ("%04d/%02d/%02d",$year,$month,$day) ;
  $date2 = sprintf ("=date(%04d,%02d,%02d)",$year,$month,$day) ; # excel

  if ("$date $time" gt $date_time_max)
  { $date_time_max = "$date $time" ; }
  return ($date,$date2,$time,$hour) ;
}

sub GetDateTimeEnglishShort
{
  my @weekdays_en = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
  my @months_en   = qw (January February March April May June July
                        August September October November December);
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  return (substr ($weekdays_en[$wday],0,3) . ", " .
          substr ($months_en[$mon],0,3) . " " .
          $mday . ", " .
          (1900 + $year) .
          " " . sprintf ("%2d:%02d", $hour, $min)) ;
}

sub OpenLog
{
  $fileage  = -M $file_log ;
  if ($fileage > 5)
  {
    open "FILE_LOG", "<", $file_log || abort ("Log file '$file_log' could not be opened.") ;
    @log = <FILE_LOG> ;
    close "FILE_LOG" ;
    $lines = 0 ;
    open "FILE_LOG", ">", $file_log || abort ("Log file '$file_log' could not be opened.") ;
    foreach $line (@log)
    {
      if (++$lines >= $#log - 5000)
      { print FILE_LOG $line ; }
    }
    close "FILE_LOG" ;
  }
  open "FILE_LOG", ">>", $file_log || abort ("Log file '$file_log' could not be opened.") ;
  &Log ("\n\n===== Scan Wikipedia Weekly Pages / " . &GetDateTimeEnglishShort (time) . " =====\n\n") ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}


