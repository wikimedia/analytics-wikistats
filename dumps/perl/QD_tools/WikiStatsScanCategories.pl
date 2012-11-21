#!/usr/bin/perl

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Net::Domain qw (hostname);

  $hostname = `hostname` ;
  chomp ($hostname) ;

  $dir  = "." ;
  if ($hostname eq "bayes")
  { $dir = "/home/ezachte/wikistats/viewspercat" ; }

  $false     = 0 ;
  $true      = 1 ;

  require "/home/ezachte/wikistats/WikiReportsDate.pl" ;

  $project      = "en.wikipedia.org" ;
  $category     = "Jazz musicians by genre" ;
  $callsmax     = 10000 ;
  $callsmaxtest = 10000 ;
  $cmlimit      = 500 ;
  $maxlevel     = 10 ;
  $timestart    = time ;

  $file_log        = "$dir/WikiStatsScanCategories.log" ;
  $file_csv        = "$dir/WikiStatsArticles.csv" ;
  $file_categories = "$dir/WikiStatsScanCategories.txt" ;

  &OpenLog ;
  open FILE_CSV,        '>', "$file_csv" ;
  open FILE_CATEGORIES, '>', "$file_categories" ;

  &Log ("\nFetch pages from $project for category $category, max $maxlevel levels deep.\n\n") ;
  print FILE_CATEGORIES "Fetch pages from $project for category $category, max $maxlevel levels deep.\n\n" ;
  print FILE_CATEGORIES "s = subcategories, a = articles\n\n" ;

  &FetchCategoryMembers ($category, 1) ;

  foreach $article (sort keys %results)
  {
    $articles_found ++ ;
    print FILE_CSV "$article\n" ;
  }

  $duration = time - $timestart ;
  print FILE_CATEGORIES "\n$categories_scanned unique categories scanned, with in total $articles_found unique articles (namespace 0), in $duration seconds.\n" ;
  close FILE_CSV ;
  close FILE_CATEGORIES ;
  close FILE_LOG ;

  exit ;

sub FetchCategoryMembers
{
  my $category = shift ;
  my $level    = shift ;
  $indent  = "  " x ($level-1) ;

  if ($level > $maxlevel) { return ; }

  ($category2 = $category) =~ s/([\x80-\xFF]{2,})/&UnicodeToAscii($1)/ge ;

  if ($queried {$category})
  {
    $indent = "  " x  ($level-1) ;
    print FILE_CATEGORIES "$indent $level '$category2' -> already queried\n" ;
    return ;
  }

  my (@categories, @articles) ;
  $categories_scanned++ ;

  $queried {$category}++ ;

  $url = "http://$project/w/api.php?action=query&format=xml&list=categorymembers&cmtitle=Category:$category&cmlimit=$cmlimit" ;
  $continueprev = "" ;
  while ($url ne "")
  {
    $calls ++ ;
    if ($calls > $callsmaxtest) { print FILE_CATEGORIES "Number of api calls exceeds test limit $calls\n" ; last ; }
    if ($calls > $callsmax) { &Abort ("Number of api calls exceeds safety limit $calls") ; }
    $content = "" ;
    ($result, $content) = &GetPage ($category, $level, $url, $true) ;

    &Log2 ("\n\n$url\n$result $content\n\n") ;

  # $content =~ s/([\x80-\xFF]{2,})/&UnicodeToAscii($1)/ge ;

    $continue = "" ;
    if ($content =~ /cmcontinue/)
    {
      $continue = $content ;
      $continue =~ s/^.*?query-continue>(.*?)<\/query-continue>.*$/$1/ ;
      $continue =~ s/^.*?cmcontinue="([^\"]*)".*$/$1/ ;
      &Log ("+++ $indent $level continue with '$continue'\n") ;
      $url = "http://$project/w/api.php?action=query&format=xml&list=categorymembers&cmtitle=Category:$category&cmlimit=$cmlimit&cmcontinue=$continue" ;
    }

    else
    { $url = "" ; }

    if (($continue eq $continueprev) && ($continue ne ""))
    {
      &Log ("$indent $level Loop encountered\n\ncontinue: $continue\n\nprevious string'$continueprev'\n\ncontent: '$content'") ;
      $content = "" ;
      $url = "" ;
    }

    $members = "" ;
    if ($content =~ /categorymembers/)
    {
      $members = $content ;
      $members =~ s/^.*?categorymembers>(.*?)<\/categorymembers>.*$/$1/ ;
      @categories = &GetCategories ($category, $level, $members) ;
      @articles   = &GetArticles   ($members) ;
      foreach $article (@articles)
      {
        $article  =~ s/,/\%2C/g ;
        $category =~ s/,/\%2C/g ;
        $results {"$article,$category"}++ ;
      }
    }
    else
    { $url = "" ; }

    $continueprev = $continue ;
  }

  print FILE_CATEGORIES "$indent $level '$category2' -> s:" . ($#categories+1) . " a:" . ($#articles+1) . "\n" ;
  foreach $subcategory (sort @categories)
  {
    if ($level < $maxlevel)
    { &FetchCategoryMembers ($subcategory, $level+1) ; }
  }
}

sub GetPage
{
  my $category = shift ;
  my $level    = shift ;

  $indent  = "  " x ($level-1) ;

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

  my $file2 = $file ;
  $file2 =~ s/^.*?api/api/ ;
  $file2 =~ s/([\x80-\xFF]{2,})/&UnicodeToAscii($1)/ge ;
  (my $category2 = $category) =~ s/([\x80-\xFF]{2,})/\?/g ;
  print "GET $indent $level $category2" ;
  &Log2 ("\n$indent $level $category -> '$file2'") ;

  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
    if ($requests++ % 2 == 2)
    { sleep (1) ; }

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

# make more flexible some day, now assumes current xml format
sub GetCategories
{
  my $category = shift ;
  my $level    = shift ;
  my $members  = shift ;
  my @categories ;
  my $subcategories ;
  $members =~ s/<cm[^>]*? ns="14" title="([^>"]+)".*?>/($a=$1, $a=~ s#^[^:]+:##, push @categories, $a)/ge ;
#  if ($#categories > -1)
#  {
#    foreach $category (@categories)
#    {
#      $category2 = $category ;
#      $category2 =~ s/,/%2C/g ;
#      $subcategories .= "$category2, " ;
#    }
#    $subcategories =~ s/,$// ;
#    print FILE_CATEGORIES "$level: Category '$category': subcategories\n'$subcategories'\n" ;
#  }
#  else
#  {  print FILE_CATEGORIES "$level: Category '$category': no subcategories\n" ; }
  foreach $category (@categories)
  { $category =~ s/\&\#039;/'/g ; }
  return (@categories) ;
}

# make more flexible some day, now assumes current xml format
sub GetArticles
{
  my $members = shift ;
  my @articles ;
  $members =~ s/<cm[^>]*? ns="0" title="([^"]+)".*?>/(push @articles, $1)/ge ;
  foreach $article (@articles)
  { $article =~ s/\&\#039;/'/g ; }
  return (@articles) ;
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

sub Log
{
  $msg = shift ;
  print FILE_LOG $msg ;
  $msg =~ s/([\x80-\xFF])/("%".sprintf("%02X",$1))/gie ;
  print $msg ;
}

sub Log2
{
  $msg = shift ;
  print FILE_LOG $msg ;
}

sub Abort
{
  $msg = shift ;
  print "Abort script\nError: $msg\n" ;
  print LOG "Abort script\nError: $msg\n" ;
  exit ;
}

