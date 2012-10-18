#!/usr/bin/perl

# bash file for daily generation and copy
# blank article title ?!

# no warnings 'uninitialized';

  use lib "/home/ezachte/lib" ;       # general routines
  use lib "/home/ezachte/wikistats" ; # WikiReports*.pm modules
  use lib "W:/! Perl/Wikistats" ;     # test env

  use EzLib ;
  ez_lib_version (8) ;
  $trace_on_exit = $true ;

#  use Time::Local ;
#  use Net::Domain qw (hostname);

  use WikiReportsDate ;
  use WikiReportsLiterals ;
  use WikiReportsOutputMisc ;
  use WikiReportsScripts ;
  use WikiReportsNoWikimedia ;
  use WikiReportsLocalizations ;
  use WikiReportsHtml ;

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

  &SetMonths ;
  &SetLiterals ;
  &SetScripts ;

  &CountMostViewedPages ($this_month) ;
  if ($mday <= 5)
  { &CountMostViewedPages ($prev_month) ; }

  exit ;

sub SetMonths
{
  $mon ++ ;
  $year += 1900 ;
  $this_month = sprintf ("%04d-%02d", $year, $mon) ;
  if (-- $mon == 0) { $mon = 12 ; $year-- ; }
  $prev_month = sprintf ("%04d-%02d", $year, $mon) ;
  if (-- $mon == 0) { $mon = 12 ; $year-- ; }
  $prev_prev_month = sprintf ("%04d-%02d", $year, $mon) ;
}

sub CountMostViewedPages
{
  my $month = shift ;
  ($month2 = $month) =~ s/-// ;

  undef %views ;

  &LogT ("Count pages for $month\n\n") ;

  if ($job_runs_on_production_server)
  {
    &LogT ("Job runs on production server\n") ;
    $path_in  = "/a/dammit.lt/filtered" ;
    $path_out = "/mnt/htdocs/page_views" ;
  }
  else
  {
    &LogT ("Job runs on local test server\n") ;
    $path_in  = "w:/! Perl/Dammit/Page Requests Staff Wikis" ;
    $path_out = "w:/! Perl/Dammit/Page Requests Staff Wikis" ;
  }

  &LogT ("Path in:  $path_in\n") ;
  &LogT ("Path out: $path_out\n") ;
  chdir $path_in ;
  my @files = glob "*" ; # glob on qualified dir on Windows gives problems, hence chdir ??

  $first  = "" ;
  $last   = "" ;
  foreach $file (sort @files)
  {
    next if $file !~ /pagecounts-$month2\d\d.txt/ ;
    &LogT ("$file\n") ;

    if ($first eq "")
    { ($first = $file) =~ s/[^\d]//g ; }
    ($last = $file) =~ s/[^\d]//g ;
    $first =~ s/(\d\d\d\d)(\d\d)(\d\d)/$1-$2-$3/ ;
    $last  =~ s/(\d\d\d\d)(\d\d)(\d\d)/$1-$2-$3/ ;
    $first_day = substr ($first,8,2) ;
    $last_day  = substr ($last ,8,2) ;

    open IN, '<', $file ;
    while ($line = <IN>)
    {
      chomp $line ;
      ($project, $article, $counts) = split (' ', $line) ;

      next if $article =~ /^\s*$/ ;
      next if $project eq "quality.m" ; # obsolete
      next if $article =~ /:\/\// ; # e.g. http://
      next if $article =~ /\.php/ ;

      $article =~ s/^[\/\\]*// ;
      $article = ucfirst $article ;
      $project =~ s/\.m$// ;
      $project = ucfirst $project ;
      $projects {$project} ++ ;

      ($daytotal = $counts) =~ s/^(\d+).*$/$1/ ;
      $views {$project} {$article} += $daytotal ;

      # if ($article =~ /China/)
      # { print "$project $article + $daytotal -> " . $views {$project} {$article} . "\n" ; }
    }
  }

  $month_eng = month_english_short (substr($month,5,2) - 1) . ' ' . substr ($month,0,4) ;

  $period = 'day ' . (substr ($first,8,2)+0) . '-' . (substr ($last,8,2)+0) ;

  foreach $project (sort keys %projects)
  {
    &LogT ("\nWrite totals for project $project for month $month (day $first_day - $last_day)\n\n") ;

    # === Sort by title ===

    @articles = sort keys %{$views {$project}} ;
    next if $#articles == -1 ;

    open TXT, '>', "$path_out/PageViews${project}-$month-ByTitle.txt" ;
    open CSV, '>', "$path_out/PageViews${project}-$month-ByTitle.csv" ;

    print TXT "title,views (period: $first - $last)\n" ;
    print CSV "views,title,period: $first - $last\n" ;

    foreach $article (@articles)
    {
      ($article2 = $article) =~ s/\%([0-9A-F]{2})/chr(hex($1))/ge ;
      print TXT "$article2,${views {$project} {$article}}\n" ;

      $article2 = $article ;
      if ($article2 =~ /,/)
      { $article2 = "\"$article2\"" ; }
      print CSV "${views {$project} {$article}},$article2\n" ;
    }
    close TXT ;
    close CSV ;

    # === Sort by views ===

    if ($month eq $this_month)
    {
      $url_prev = "PageViews${project}-$prev_month-ByViews.html" ;
      $url_next = "" ;
      $out_button_prev = &btn (" < ", $url_prev) ;
      $out_button_next = "" ;
    }
    elsif ($month eq $prev_month)
    {
      $url_prev = "PageViews${project}-$prev_prev_month-ByViews.html" ;
      $url_next = "PageViews${project}-$this_month-ByViews.html" ;
      $out_button_prev = &btn (" < ", $url_prev) ;
      $out_button_next = &btn (" > ", $url_next) ;

      if (! -e $url_prev)
      { $out_button_prev = "" ; }
    }

    my $out_zoom = "" ;
    my $out_options = "" ;
    my $out_explanation = "" ; #Based on Domas' <a href='http://dammit.lt/wikistats/'>page view files</a>" ;
    my $out_page_subtitle = "" ;
    my $out_crossref = "" ;
    my $out_description = "" ;
    my $out_button_switch = "" ;
    my $out_msg = "<b>$month_eng ($period)</b>" ;
    my $lang = "en" ;

    my $out_html_title = "$project wiki page views" ;
    my $out_page_title = "$project wiki page views" ;

    $out_scriptfile = "<script language=\"javascript\" type=\"text/javascript\" src=\"WikipediaStatistics14.js\"></script>\n" ;
    $out_style      =~ s/td/td {font-size:12px}\nth {font-size:12px}\ntd/ ; # script definition needs clean up

    $out_options = &opt ("PageViews${project}-$month-ByViews.html", $project) ;
    foreach $project2 (keys %projects)
    {
      if ($project2 ne $project)
      {  $out_options .= &opt ("PageViews${project2}-$month-ByViews.html", $project2) ; }
    }

    $unicode = $true ;
    &GenerateHtmlStart ($out_html_title,  $out_zoom,          $out_options,
                        $out_page_title,  $out_page_subtitle, $out_explanation,
                        $out_button_prev, $out_button_next,   $out_button_switch,
                        $out_crossref,    $out_msg) ;

    $out_html =~ s/Sitemap.htm/http:\/\/stats.wikimedia.org/ ; # Q&D patch
    $out_html =~ s/ Home / stats.wikimedia.org / ; # Q&D patch

    @articles = sort {$views {$project}{$b} <=> $views {$project}{$a}} keys %{$views {$project}} ;

    open TXT, '>', "$path_out/PageViews${project}-$month-ByViews.txt" ;
    open CSV, '>', "$path_out/PageViews${project}-$month-ByViews.csv" ;

    print TXT "title,views (period: $first - $last)\n" ;
    print CSV "views,title,period: $first - $last\n" ;

    $out_html .= "<p><b>Other formats</b>: " ;
    $out_html .= "ordered by views: <a href='PageViews${project}-$month-ByViews.txt'>text file</a> / <a href='PageViews${project}-$month-ByViews.csv'>csv file</a>, " ;
    $out_html .= "ordered by title: <a href='PageViews${project}-$month-ByTitle.txt'>text file</a> / <a href='PageViews${project}-$month-ByTitle.csv'>csv file</a><p>" ;
    $out_html .= "<table border=1>\n" ;
    $out_html .= "<tr><th class=cb>Rank</th><th class=cb>Views</th><th class=lb>Title</th></tr>\n" ;

    $lines = 0 ;
    foreach $article (@articles)
    {
      ($article2 = $article) =~ s/\%([0-9A-F]{2})/chr(hex($1))/ge ;
      print TXT "$article2,${views {$project} {$article}}\n" ;

      $article2 =~ s/_/ /g ;
      if (++$lines <= 1000)
      { $out_html .= "<tr><td class=c>$lines</td><td class=r>${views {$project} {$article}}</td><td class=l><a href='http://$project.wikimedia.org/wiki/$article'>$article2</a></td></tr>\n" ; }

      $article2 = $article ;
      if ($article2 =~ /,/)
      { $article2 = "\"$article2\"" ; }
      print CSV "${views {$project} {$article}},$article2\n" ;
    }

    $out_html .= "</table>\n" ;

    close TXT ;
    close CSV ;

    $out_html .= "<p><small>Counts based on <a href='http://dammit.lt/wikistats/'>Domas' hourly pagecount files</a><br>" .
                 "File generated on  " . date_time_english (time) . "<br>Author: Erik Zachte</small>" ;

    open HTML, '>', "$path_out/PageViews${project}-$month-ByViews.html" ;
    print HTML $out_html ;
    close HTML ;

    if ($month eq $this_month) # static url
    {
      open HTML, '>', "$path_out/PageViews${project}.html" ;
      print HTML $out_html ;
      close HTML ;
    }
  }
}

# translates one unicode character into plain ascii
sub UnicodeToAscii {
  my $unicode = shift ;

  my $char = substr ($unicode,0,1) ;
  my $ord = ord ($char) ;
  my ($c, $value, $html) ;

  if ($ord < 128)         # plain ascii character
  { return ($unicode) ; } # (will not occur in this script)
  else
  {
    if    ($ord >= 252) { $value = $ord - 252 ; }
    elsif ($ord >= 248) { $value = $ord - 248 ; }
    elsif ($ord >= 240) { $value = $ord - 240 ; }
    elsif ($ord >= 224) { $value = $ord - 224 ; }
    else                { $value = $ord - 192 ; }

    for ($c = 1 ; $c < length ($unicode) ; $c++)
    { $value = $value * 64 + ord (substr ($unicode, $c,1)) - 128 ; }

    if ($value < 256)
    { return (chr ($value)) ; }

    # $unicode =~ s/([\x80-\xFF])/("%".sprintf("%02X",$1))/gie ;
    return ($unicode) ;
  }
}


