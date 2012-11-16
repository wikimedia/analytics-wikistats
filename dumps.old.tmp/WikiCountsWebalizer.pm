#!/usr/bin/perl

sub GetWebalizerPages
{
  my $year  = substr($dumpdate,0,4) ;
  my $month = substr($dumpdate,4,2) ;
  my $notfound   = 0 ;
  my $months_ago = 0 ;
  &Log ("\n") ;
  &LogTime ;
  &Log ("\nFetch Webalizer pages\n") ;
  while ((($mode eq "wp") && ($notfound < 5)) ||
         (($mode ne "wp") && ($notfound < 1))) # 36 ?
  {
    my $file = "usage_" . sprintf ("%04d%02d.html", $year, $month) ;

    if ($mode eq "wb")
    { $url = "http://wikimedia.org/stats/$language.wikibooks.org/$file" ; }
    if ($mode eq "wk")
    { $url = "http://wikimedia.org/stats/$language.wiktionary.org/$file" ; }
    if ($mode eq "wn")
    { $url = "http://wikimedia.org/stats/$language.wikinews.org/$file" ; }
    if ($mode eq "wp")
    { $url = "http://wikimedia.org/stats/$language.wikipedia.org/$file" ; }
    if ($mode eq "wq")
    { $url = "http://wikimedia.org/stats/$language.wikiquote.org/$file" ; }
    if ($mode eq "ws")
    { $url = "http://wikimedia.org/stats/$language.wikisource.org/$file" ; }
    if ($mode eq "wv")
    { $url = "http://wikimedia.org/stats/$language.wikiversity.org/$file" ; }

    $file_html_webalizer_save = $path_webalizer . $file ;

    $get = $false ;
    if (! (-e $file_html_webalizer_save))
    { $get = $true ; }
    elsif ($months_ago < 2) # always retrieve 2 most recent months
    {                        # unless done very recently
      $file_age = -M $file_html_webalizer_save ;
      if ($file_age > 0.5)
      { $get = $true ; }
    }

    if ($get)
    {
      if (&GetWebalizerPage ($url))
      {
        $notfound = 0 ;

        open "FILE_IN", "<", $file_html_webalizer ;
        my (@html) = <FILE_IN> ;
        close "FILE_IN" ;

        open "FILE_OUT", ">", $file_html_webalizer_save || return ;
        print FILE_OUT @html ;
        close "FILE_OUT" ;
      }
      else
      { $notfound ++ ; }
    }
    if ($month > 1)
    { $month -- ; }
    else
    { $month = 12 ; $year -- ; }
    $months_ago ++ ;
  }

  &Log ("Ready fetching Webalizer pages\n\n") ;
  undef (@html) ;
}

sub GetWebalizerPage
{
  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  my $raw_url = shift ;
  my ($content, $attempts) ;

  unlink $file_html_webalizer ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  # &Log ("Fetch $raw_url") ;

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikipedia Wikicounts job");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://www.wikipedia.org");

  my $succes = $false ;

  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { ; } # { &Log (" -> 404\n") ; }
      else
      { &Log ("Webalizer stats could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
      return ($false) ;
    }
    # else
    # { &Log ("\n") ; }

    $content = $response->content();
    if (! ($content =~ /Webalizer Version/))
    {
#     &Log ("Webalizer stats page does not contain valid data:\n  '$raw_url'\n") ;
      return ($false) ;
    }

    if (! ($content =~ m/<\/html>/i))
    {
      &Log ("Webalizer stats page is incomplete:\n  '$raw_url'\n") ;
      next ;
    }

    $succes = $true ;
  }

  if ($succes)
  {
    open "FILE_OUT", ">", $file_html_webalizer || return ;
    print FILE_OUT $content ;
    close "FILE_OUT" ;
  }
  else
  { &Log ("\nWebalizer stats page not retrieved after " . (--$attempts) . " attempts !!\n\n") ; }

  return ($succes) ;
}

sub UpdateWebalizerStats
{
# if (! $webalizer) { return ; }
  if (! (-e $file_html_webalizer))
  { return ; }

  undef @webalizer_links ;

  &ReadFileCsvAll ($file_csv_webalizer_monthly) ;
  &ReadWebalizerYearPage ;
  @csv2 = sort {&csvkey_lang_date_val10 ($a) cmp &csvkey_lang_date_val10 ($b)} @csv ;
  undef (@csv) ;

  my $prev_wp    = "" ;
  my $prev_year  = "" ;
  my $prev_month = "" ;
  my $prev_line  = "" ;
  my ($wp, $year, $month) ;

  foreach $line (@csv2)
  {
    ($wp, $date) = split (",", $line) ;
    $year  = substr ($date,6,4) ;
    $month = substr ($date,0,2) ;
    if ($prev_wp ne "")
    {
      if (($wp ne $prev_wp) || ($year ne $prev_year) || ($month ne $prev_month))
      { push @csv, $prev_line ; }
    }
    $prev_wp    = $wp ;
    $prev_year  = $year ;
    $prev_month = $month ;
    $prev_line  = $line ;
  }
  push @csv, $prev_line ;
  undef (@csv2) ;
  &WriteFileCsv ($file_csv_webalizer_monthly) ;

  foreach $page (@webalizer_links)
  {
    chomp ($page) ;
    $file_html_webalizer_save = $path_webalizer . $page ;
    if (! -e $file_html_webalizer_save)
    {
      if (&GetWebalizerPage ("http://$language.wikipedia.org/stats/" . $page))
      {
        open "FILE_IN", "<", $file_html_webalizer ;
        my (@html) = <FILE_IN> ;
        close "FILE_IN" ;

        open "FILE_OUT", ">", $file_html_webalizer_save || return ;
        print FILE_OUT @html ;
        close "FILE_OUT" ;
      }
    }
  }
  undef (@html) ;
}

sub ReadWebalizerYearPage
{
  my $link ;

  $getval = 0 ;
  $line_csv = "" ;
  open "FILE_IN", "<", $file_html_webalizer ;
  while ($line = <FILE_IN>)
  {
    if ($getval > 0)
    {
      $line =~ s/\<[^\>]*\>//g ;
      $line_csv .= &csv ($line) ;
      $getval ++ ;
      if ($getval > 10)
      {
        $getval = 0 ;
        $line_csv =~ s/\,$// ;
        push @csv, $line_csv ;
      }
    }
    if ($line =~ m/\<TITLE\>/)
    {
      $line =~ s/\.wikipedia\.org.*$// ;
      $line =~ s/.* (.*)$/$1/ ;
      $wp = $line ;
      if ($wp =~ /www/) { $wp = "en" ; }
    }
    if ($line =~ m/Generated:/)
    {
      $line =~ s/.*Generated\: // ;
      $day = substr ($line,0,2) ;
    }
    if ($line =~ m/usage\_\d{6,6}\.html/)
    {
      $link = $line ;
      $link =~ s/^.*(usage.*html).*$/$1/ ;
      push @webalizer_links, $link ;

      $line   =~ s/.*usage\_(\d{6,6})\.html.*$/$1/ ;
      $date   = $line ;
      $year   = substr ($date,0,4) ;
      $month  = substr ($date,4,2) ;
      if ($day == -1)
      { $day = days_in_month ($year, $month) ; }
      $line_csv = &csv ($wp) . &csv (sprintf ("%02d/%02d/%04d", $month,$day,$year)) ;
      $day = -1 ;
      $getval = 1 ;
    }
  }
  close $FILE_IN ;
}

sub CountWebalizerStats
{
  undef (@web_requests_daily) ;
  undef (@web_visits_daily) ;
  undef (@web_monthly) ;

  my ($start, $day, $days) ;
  my ($pages_monthly, $visits_monthly) ;
  my ($month_prev, $year_prev) ;

  my $month = 1 ;
  my $year = 2001 ;
  my $dump_year  = substr($dumpdate,0,4) ;
  my $dump_month = substr($dumpdate,4,2) ;
  my $older_file_found = $false ;
  my $dump_day  = substr ($dumpdate,6,2) ;

  while (($year < $dump_year) ||
         (($year == $dump_year) && ($month <= $dump_month)))
  {
    my $file = "usage_" . sprintf ("%04d%02d.html", $year, $month) ;
    my $file_html_webalizer = $path_webalizer . $file ;

    if (-e $file_html_webalizer)
    {
      if (! $older_file_found)
      {
        $month_prev = $month - 1 ;
        $year_prev  = $year ;
        if ($month_prev == 0)
        { $month_prev = 12 ; $year -- ; }
        $days = days_in_month ($year_prev, $month_prev) ;

        for ($day = $days - 5 ; $day <= $days ; $day ++)
        {
          push @web_requests_daily,
               &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month_prev, $day, $year_prev)) . "-1" ;
          push @web_visits_daily,
               &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month_prev, $day, $year_prev)) . "-1" ;
        }
      }
      $older_file_found = $true ;

      undef (@html) ;

      &Log ("Parse $file\n") ;
      open "FILE_IN", "<", $file_html_webalizer ;
      @html = <FILE_IN> ;
      close "FILE_IN" ;

      $start = $false ;
      $day   = -1 ;
      $pages_monthly = 0 ;
      $visits_monthly   = 0 ;
      $days = 0 ;
      $prev_day = 0 ;

      foreach $line (@html)
      {
        chomp ($line) ;
        if ($line =~ m/NAME=\"DAYSTATS/)
        { $start = $true ; }
        if (! $start) { next ; }
        if ($line =~ m/NAME=\"HOURSTATS/)
        { last ; }
        if ($line =~ m/<TD ALIGN=center>/)
        {
          $line =~ s/^.*<B>(\d+)<\/B>.*$/$1/ ;
          $day = $line ;

          if (($year == $dump_year) && ($month == $dump_month) && ($day >= $dump_day)) { last ; }

          $count = 0 ;
          $days ++ ;

          if ($day > $prev_day + 1)
          {
            for ($day2 = $prev_day + 1 ; $day2 < $day ; $day2++)
            {
              push @web_requests_daily,
                   &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day2, $year)) . "-1" ;
              push @web_visits_daily,
                   &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day2, $year)) . "-1" ;
            }
          }
          $prev_day = $day ;
        }
        if ($line =~ m/<B>\d+<\/B>/)
        {
          $line =~ s/^.*<B>(\d+)<\/B>.*$/$1/ ;
          $val  = $line ;
          $count++ ;
          if ($count == 3)
          { push @web_requests_daily,
                 &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day, $year)) . $val ;
            $pages_monthly += $val ;
          }
          if ($count == 4)
          { push @web_visits_daily,
                 &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day, $year)) . $val ;
            $visits_monthly += $val ;
          }
        }
      }

      if (($year < $dump_year) || (($year == $dump_year) && ($month < $dump_month)))
      { $day_till = days_in_month ($year, $month) ; }
      else
      { $day_till = $dump_day - 1 ; }

      for ($day2 = $day + 1 ; $day2 <= $day_till ; $day2++)
      {
        push @web_requests_daily,
             &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day2, $year)) . "-1" ;
        push @web_visits_daily,
             &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day2, $year)) . "-1" ;
      }

      if ($days > 0)
      {
        push @web_monthly, &csv($language) .
                           &csv (sprintf ("%02d/%02d/%04d", $month, days_in_month($year,$month), $year)) .
                           &csv (sprintf ("%.0f", ($pages_monthly/$days))) .
                           sprintf ("%.0f", ($visits_monthly/$days)) ;
      }
    }
    else
    {
      if ($older_file_found) # fill gaps only
      {
        for ($day = 1 ; $day <= days_in_month ($year, $month) ; $day ++)
        {
           push @web_requests_daily,
                   &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day, $year)) . "-1" ;
           push @web_visits_daily,
                   &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, $day, $year)) . "-1" ;
           push @web_monthly,
                   &csv($language) . &csv (sprintf ("%02d/%02d/%04d", $month, days_in_month($year,$month), $year)) . "0,0" ;
        }
      }
    }

    $month++ ;
    if ($month > 12)
    { $month = 1 ; $year ++ ; }
  }

  # skip partial days
  for ($w = 0 ; $w < $#web_requests_daily ; $w++)
  {
    if ($web_requests_daily [$w+1] =~ /\-1/)
    { $web_requests_daily [$w] =~ s/,[^,]*$/,-1/ ; }
  }
  for ($w = $#web_requests_daily ; $w > 0 ; $w--)
  {
    if ($web_requests_daily [$w-1] =~ /\-1/)
    { $web_requests_daily [$w] =~ s/,[^,]*$/,-1/ ; }
  }
  for ($w = 0 ; $w < $#web_visits_daily ; $w++)
  {
    if ($web_visits_daily [$w+1] =~ /\-1/)
    { $web_visits_daily [$w] =~ s/,[^,]*$/,-1/ ; }
  }
  for ($w = $#web_requests_daily ; $w > 0 ; $w--)
  {
    if ($web_visits_daily [$w-1] =~ /\-1/)
    { $web_visits_daily [$w] =~ s/,[^,]*$/,-1/ ; }
  }

  # remove last entry (probably incomplete day)
  pop (@web_requests_daily) ;
  pop (@web_visits_daily) ;

  &ReadFileCsv ($file_csv_web_requests_daily) ;
  foreach $line (@web_requests_daily)
  { push @csv, $line ; }
  &WriteFileCsv ($file_csv_web_requests_daily) ;

  &ReadFileCsv ($file_csv_web_visits_daily) ;
  foreach $line (@web_visits_daily)
  { push @csv, $line ; }
  &WriteFileCsv ($file_csv_web_visits_daily) ;

  &ReadFileCsv ($file_csv_web_monthly) ;
  foreach $line (@web_monthly)
  { push @csv, $line ; }
  &WriteFileCsv ($file_csv_web_monthly) ;

  undef (@web_requests_daily) ;
  undef (@web_visits_daily) ;
  undef (@web_monthly) ;
  undef (@html) ;
}

1;
