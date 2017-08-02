#!/usr/bin/perl

  no warnings 'uninitialized';

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  ez_lib_version (8) ;
  $trace_on_exit = $true ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Net::Domain qw (hostname);
  use URI::Escape ;

  $callsmax     = 100000 ;
  $callsmaxtest = 100000 ;
  $cmlimit      = 500 ;
  $maxlevel     = 4 ; # default

  default_argv "-j \"Nederlands_kunstschilder\"|-d 9|-c \"Nederlands_kunstschilder\"|-p nl.wikipedia.org" ;

  $timestart = time ;

  &ParseArguments ;

  &ScanCategories ;

  exit ;

# arguments checking can be improved, is not fool proof
sub ParseArguments
{
  my $options ;
  getopt ("cdowhx", \%options) ;

  foreach $key (keys %options)
  {
  # print "1: $key ${options {$key}}\n" ;
    $options {$key} =~ s/^\s*(.*?)\s*$/$1/ ;
    $options {$key} =~ s/^'(.*?)'$/$1/ ;
    $options {$key} =~ s/^"(.*?)"$/$1/ ;
    $options {$key} =~ s/\@/\\@/g ;
  # print "2: $key ${options {$key}}\n" ;
  }

  abort ("Specify category as: '-c \"some category\"'")    if (! defined ($options {"c"})) ;
  abort ("Invalid tree depth specified! Specify tree depth for category scan n (n between 1 and 99) as: '-d n'") if (defined ($options {"d"}) && ($options {"d"} !~ /^\d\d*$/)) ;
  abort ("Specify wiki as e.g.: '-w nl.wikipedia.org'") if (! defined ($options {"w"})) ;
  abort ("Specify output folder as : '-o [folder]'") if (! -d $options {"o"}) ;
  
  $category     = $options {"c"} ;
  $depth        = $options {"d"} ;
  $path_out     = $options {"o"} ;
  $path_html    = $options {"h"} ;
  $path_exclude = $options {"x"} ;
  $wiki         = $options {"w"} ;
  $projectcode  = $wiki ;

  $category    = uri_unescape ($category) ;
  $path_html   = uri_unescape ($path_html) ;
  $path_html   = uri_escape   ($path_html) ;
  $path_html   =~ s/\%20/_/g ;
  $path_html   =~ s/\%28/\(/g ;
  $path_html   =~ s/\%29/\)/g ;
  $path_html   =~ s/\%2D/-/g ;
  $path_html   =~ s/\%2F/\//g ;
  $path_html   =~ s/\%3A/:/g ;
  $path_html   =~ s/\%5F/_/g ;

  &ValidateCategory ;

  $projectcode =~ s/wikibooks.*$/b/ ;
  $projectcode =~ s/wikinews.*$/n/ ;
  $projectcode =~ s/wikipedia.*$/z/ ;
  $projectcode =~ s/wikiquote.*$/q/ ;
  $projectcode =~ s/wikisource.*$/s/ ;
  $projectcode =~ s/wikiversity.*$/v/ ;
  $projectcode =~ s/wiktionary.*$/k/ ;
  $projectcode =~ s/wikimedia.*$/m/ ;

# if ($job eq '')
# {
#   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
#   $job = sprintf ("%04d-%02d-%02d %02d-%02d-%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec) ;
#   print "No job id (also target dir) specified: use default '$job'\n" ;
# }

  if ($depth eq '')
  { print "No depth specified for scanning category tree. Using default $maxlevel\n" ; }
  else
  { $maxlevel = $depth ; }

  $path_out = "$path_out/$category" ;

  mkdir ($path_out) ;
  if (! -d $path_out)
  { abort ("Output directory '" . $path_out . "' not found and could not be created") ; }

  if (($path_exclude ne '') and (! -e $path_exclude))
  { abort ("File with categories not to expand '" . $path_exclude . "' not found") ; }

  $file_log             = "$path_out/scan_categories.log" ;
  $file_csv             = "$path_out/scan_categories_found_articles.csv" ;
  $file_categories      = "$path_out/scan_categories_found_tree.txt" ;

  print "\n" ;
  print "Log  $file_log\n" ;
  print "Csv  $file_csv\n" ;
  print "Txt  $file_categories\n" ;
  print "Html $path_html\n" ;

  if (! -d $path_out)
  {
    print "\nDo not expand categories for wiki '$wiki', root category '$category':\n" ; 
    open CSV, '<', $path_exclude ;
    while ($line = <CSV>)
    {
      chomp $line ;	  
    
      my ($wiki_x,$category_root,$category_exclude) = split ('\|', $line) ;
      $category_root    = uri_unescape ($category_root) ;
      $category_exclude = uri_unescape ($category_exclude) ;

      # remove leading and trailing spaces
      $wiki_x           =~ s/^\s*// ;
      $wiki_x           =~ s/\s*$// ;
      $category_root    =~ s/^\s*// ;
      $category_root    =~ s/\s*$// ;
      $category_exclude =~ s/^\s*// ;
      $category_exclude =~ s/\s*$// ;
    
      next if $category_exclude eq '' ;
      next if $wiki_x ne $wiki ;
      next if $category_root ne $category ;
      print "'$category_exclude'\n" ;
      $category_exclude =~ s/\*/.*/g ;
      if ($category_exclude =~ /\*/)
      { $regexps_exclude .= "$category_exclude|" ; }
      $do_not_expand {$category_exclude} ++ ; 
    }
  }  
  print "\n" ;
  $regexps_exclude =~ s/\|$// ;
  print "regexps: $regexps_exclude\n" ; ;
  close CSV ;
}

#sub LogArguments
#{
#  my $arguments ;
#  foreach $arg (sort keys %options)
#  { $arguments .= " -$arg " . $options {$arg} . "\n" ; }
#  &Log ("\nArguments\n$arguments\n") ;
#}

sub ValidateCategory
{
  $url = "http://$wiki/w/api.php?action=query&format=xml&list=categorymembers&cmtitle=Category:$category&cmlimit=1" ;
  ($result, $content) = &GetPage ($category, $level, $url, $true) ;
  print "Test url '$url'\n" ;
  if ($content =~ /<categorymembers \/>/)
  {
    print "Category '$category' not found or empty on wiki '$wiki'\n" ;
    exit ;
  }

# if ($category =~ /WikiProject/i)
# { $redirect_from_talk_page = $true ; }
# else
# { $redirect_from_talk_page = $false ; }

  $redirect_from_talk_page = $true ; # make this command line flag?
}

sub ScanCategories
{
  &OpenLog ;
  open FILE_CSV,             '>', $file_csv ;
  open FILE_CATEGORIES,      '>', $file_categories ;
  open FILE_CATEGORIES_HTML, '>', $path_html ;

  print FILE_CATEGORIES_HTML &HtmlHeader ;

  &Log ("\nFetch pages from $wiki ($projectcode) for category $category, max $maxlevel levels deep.\n\n") ;
  print FILE_CATEGORIES "Fetch pages from $wiki for category $category, max $maxlevel levels deep.\n\n" ;
  print FILE_CATEGORIES "s = subcategories, a = articles\n\n" ;

  ($path_pageviews = $path_html) =~ s/categories/pageviews/ ;
  $path_pageviews =~ s/^.*\/// ;

  print FILE_CATEGORIES_HTML "Switch to <a href=\"$path_pageviews\">page views report</a><p>\n" ;
  print FILE_CATEGORIES_HTML "<h3>Subcategories on $wiki for category $category, max $maxlevel levels deep:</h3><p>\n" ;

  @do_not_expand = sort keys %do_not_expand ;
  if ($#do_not_expand > -1)
  {
    print FILE_CATEGORIES_HTML "Subcategories which were not expanded as they have too much content outside the topic at hand:<p>\n" ;
    foreach $subcat (@do_not_expand)
    {
      ($subcat2 = $subcat) =~ s/([\x80-\xFF]{2,2})/&UnicodeToAscii($1)/ge ;
      print FILE_CATEGORIES_HTML "<a href=\"http://$wiki/wiki/category:$subcat2\">$subcat2</a><br>\n" ;
    }	    
    print FILE_CATEGORIES_HTML "<br>\n" ;
  }

# print FILE_CATEGORIES_HTML "s = subcategories, a = articles<p>" ;
  
  &FetchCategoryMembers ($category, 1) ; 

  print FILE_CSV "# wiki:$wiki\n" ;
  print FILE_CSV "# category:$category\n" ;
  print FILE_CSV "# depth:$maxlevel\n" ;
  print FILE_CSV "# job:$job\n" ;

  foreach $article (sort keys %results)
  {
    $articles_found ++ ;
    $categories = $results {$article} ;
    $categories =~ s/\|$// ;
    print FILE_CSV "$projectcode,$article,$categories\n" ;
  }

  $duration = time - $timestart ;
  print FILE_CATEGORIES      "\n$categories_scanned unique categories scanned, with in total $articles_found unique articles (namespace 0), in $duration seconds.\n" ;
  print FILE_CATEGORIES_HTML "\n<p>$categories_scanned unique categories scanned, with in total $articles_found unique articles (namespace 0), in $duration seconds.\n" ;
  close FILE_CATEGORIES ;

  print FILE_CATEGORIES_HTML &HtmlFooter ;
  close FILE_CATEGORIES_HTML ;

  close FILE_CSV ;
  close FILE_LOG ;
}

sub FetchCategoryMembers
{
  my $category = shift ;
  my $level    = shift ;
  $indent       = "  " x ($level-1) ;
  $indent_html  = "&nbsp;&nbsp;&nbsp; " x ($level-1) ;

  if ($level > $maxlevel) { return ; }

  ($category2 = $category) =~ s/([\x80-\xFF]{2,2})/&UnicodeToAscii($1)/ge ;
  return if $category2 =~ /^\s*$/ ;
 
  if ($do_not_expand {$category})
  {
    $indent       = "  " x  ($level-1) ;
    $indent_html  = "&nbsp;&nbsp;&nbsp; " x ($level-1) ;
    print FILE_CATEGORIES      "$indent $level '$category2' -> do not expand, on exclusion list\n" ;
    print FILE_CATEGORIES_HTML "$indent_html $level <a href=\"http://$wiki/wiki/category:$category2\">$category2</a> -> do not expand, on exclusion list<br>\n" ;
    return ;
  }

  if ($category =~ /^$regexps_exclude$/i)
  {
    $indent       = "  " x  ($level-1) ;
    $indent_html  = "&nbsp;&nbsp;&nbsp; " x ($level-1) ;
    print FILE_CATEGORIES      "$indent $level '$category2' -> do not expand, on exclusion list (regexp)\n" ;
    print FILE_CATEGORIES_HTML "$indent_html $level <a href=\"http://$wiki/wiki/category:$category2\">$category2</a> -> do not expand, on exclusion list<br>\n" ;
    return ;
  }

  if ($queried {$category})
  {
    $indent       = "  " x  ($level-1) ;
    $indent_html  = "&nbsp;&nbsp;&nbsp; " x ($level-1) ;
    print FILE_CATEGORIES      "$indent $level '$category2' -> already queried\n" ;
    print FILE_CATEGORIES_HTML "$indent_html $level <a href=\"http://$wiki/wiki/category:$category2\">$category2</a> -> already queried<br>\n" ;
    return ;
  }

  my (@categories, @articles) ;
  $categories_scanned++ ;

  $queried {$category}++ ;

  $url = "http://$wiki/w/api.php?action=query&format=xml&list=categorymembers&cmtitle=Category:$category&cmlimit=$cmlimit" ;
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
      $url = "http://$wiki/w/api.php?action=query&format=xml&list=categorymembers&cmtitle=Category:$category&cmlimit=$cmlimit&cmcontinue=$continue" ;
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
        $article  =~ s/ /_/g ;
        $category =~ s/,/\%2C/g ;
        $category =~ s/ /_/g ;
      # $results {"$article,$category"}++ ;
	$results {$article} .= "$category|" ; 
      }
    }
    else
    { $url = "" ; }

    $continueprev = $continue ;
  }

  my $subcats ;
  print FILE_CATEGORIES      "$indent $level '$category2' -> subcats:" . ($#categories+1) . " articles:" . ($#articles+1) . "\n" ;
  
  if ($#categories < 0) 
  { $subcats = '' ; } 
  elsif ($#categories == 0) 
  { $subcats = "1 subcat, " ; }
  else
  { $subcats = ($#categories+1) . " subcats, " ; }
  
  if ($#articles < 0) 
  { $articles = 'no articles' ; } 
  elsif ($#articles == 0) 
  { $articles = "1 article" ; }
  else
  { $articles = ($#articles+1) . " articles" ; }

  print FILE_CATEGORIES_HTML "$indent_html $level <a href=\"http://$wiki/wiki/category:$category2\">$category2</a> -> $subcats$articles<br>\n" ;
  foreach $subcategory (sort @categories)
  {
    if (($level < $maxlevel) && ($subcategory !~ /(?:National_Inventors_Hall_of_Fame_inductees|Inventors|Directors)/))
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
# $ua->proxy(["http"], $ENV{"http_proxy"}) ;
  $ua->proxy(["https"], $ENV{"https_proxy"}) ;
  $ua->agent("Wikimedia Perl job / EZ");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  my $succes = $false ;

  my $file2 = $file ;
  $file2 =~ s/^.*?api/api/ ;
  $file2 =~ s/([\x80-\xFF]{2,})/&UnicodeToAscii($1)/ge ;
  (my $category2 = $category) =~ s/([\x80-\xFF]{2,})/\?/g ;
  print "$categories_scanned $indent $level $category2" ;
  &Log2 ("\n$indent $level $category -> '$file2'") ;

  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
    # pacer not needed? 	  
    # if ($requests++ % 2 == 2)
    # { sleep (1) ; }

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
  $members =~ s/<cm[^>]*? ns="\d+" title="([^"]+)".*?>/(push @articles, $1)/ge ;
  foreach $article (@articles)
  { 
    $article =~ s/\&\#039;/'/g ; 
    $article =  uri_escape ($article) ;
    $article =~ s/\%20/_/g ;
    $article =~ s/\%28/(/g ;
    $article =~ s/\%29/)/g ;
    $article =~ s/\%2D/-/g ;
    $article =~ s/\%2F/\//g ;
    $article =~ s/\%3A/:/g ;
    $article =~ s/\%5F/_/g ;

    if ($redirect_from_talk_page)
    {
      $article =~ s/^Talk://i ;
      $article =~ s/[_ ]?Talk:/:/i ; 
    }
  }
  return (@articles) ;
}

sub HtmlHeader
{
my $html = <<__HTML_HEADER__ ;
<html>
<header>
<title>Subcategories $wiki $category</title> 
<style type="text/css">
<!--
body    {font-family:arial,sans-serif; font-size:12px }

a:link { color:blue;text-decoration:none;  }
a:visited {color:#0000FF;text-decoration:none; }
a:active  {color:#0000FF;text-decoration:none;  }
a:hover   {color:#FF00FF;text-decoration:underline}
-->
</style>

</header>
<body>
__HTML_HEADER__

return $html ;
}

sub HtmlFooter
{
my $html = <<__HTML_FOOTER__ ;
</body>
</html>
__HTML_FOOTER__

return $html ;
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
  &Log ("\n\n===== Scan Wikipedia Categories / " . date_time_english (time) . " =====\n\n") ;
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

