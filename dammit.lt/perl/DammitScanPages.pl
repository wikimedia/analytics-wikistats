#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  ez_lib_version (8) ;
  use WikiReportsConversions ;
  $trace_on_exit = $true ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Net::Domain qw (hostname);
  use URI::Escape ;
  use Digest::MD5 qw (md5 md5_hex);

#$file="%D8%A7%D9%84%D8%AD%D8%A7%D9%8A%D9%83_%D9%88_%D8%A7%D9%84%D8%B3%D9%81%D8%B3%D8%A7%D8%B1%D9%8A_001.jpg";
#$file =~ s/\%([0-9A-F]{2})\%/chr(hex($1))/ge ;

#print md5_hex ($file) ;
#print "xxx\n" ;
#print md5 ($file) ;
#exit ;
  $file_in   = "/a/dammit.lt/pagecounts/categorized/data/wm-commons/2016-09/Images_from_Wiki_Loves_Monuments_2016/scan_categories_found_articles.csv" ;
  $file_out  = "/a/dammit.lt/pagecounts/categorized/data/wm-commons/2016-09/Images_from_Wiki_Loves_Monuments_2016/WLM_uploaders.csv" ;
  $file_html = "/a/dammit.lt/pagecounts/categorized/data/wm-commons/2016-09/Images_from_Wiki_Loves_Monuments_2016/WLM_uploaders.html" ;
  open (IN,  '<', $file_in   || die "file in not found: $file_in not found") ; 
  open (OUT, '>', $file_out  || die "file in not found: $file_out could not be created") ; 
  open (HTML,'>', $file_html || die "file in not found: $file_html could not be created") ; 
  while ($line = <IN>)
  {
    next if $line !~ /commons/ ;
    next if $line !~ /File:/i ;

    chomp $line ;
    ($wiki,$image,$category) = split (',', $line) ;
    $image =~ s/File:// ; 
    ($image2=$image) =~ s/\%26quot\%3B/"/g ;
    # print "$image\n" ;
    $url = "https://commons.wikimedia.org/w/api.php?action=query&titles=File:$image&prop=imageinfo&iiprop=user|url" ;    
    ($result, $content) = &GetPage ($url, $true) ;
  #  sleep (1) ;

    if ($result)
    { 
    # print "$content\n\n" ; 
      @lines = split ("\n", $content) ;


      foreach $line_html (@lines)
      {
        $line  =~ s/\&quot;/'/g ; 
        if ($line_html =~ /\&quot;user\&quot;/)
        {
          $line_html =~ s/<span.*?span>// ;   
          $line_html =~ s/<span.*?span>// ;   
          $line_html =~ s/<[^>]*>//g ;   
          $line_html =~ s/\&quot;//g ;   
          $line_html =~ s/^\s*// ;   
          $line_html =~ s/\s*$// ;   
          $line_html =~ s/,$// ;   
          $user = $line_html ;
          print "$image user $user\n" ;  
          print OUT "$image2,$user\n" ;  
          $users {$user}++ ;
        }
        if ($line_html =~ /\&quot;url\&quot;/)
        {
          $line_html =~ s/<span.*?span>// ;   
          $line_html =~ s/<span.*?span>// ;   
          $line_html =~ s/<[^>]*>//g ;   
          $line_html =~ s/\&quot;//g ;   
          $line_html =~ s/^\s*// ;   
          $line_html =~ s/\s*$// ;   
          $line_html =~ s/,$// ;   
          $url= $line_html ;
          $url2 = $url ;
          $url2 =~ s/^.*\/// ;       
          $url_thumb="$url/100px-$url2" ;
          $url_thumb =~ s/\/commons\//\/commons\/thumb\// ; 
        # print "'$url_thumb'\n" ;
          if ($users {$user} <= 3)
          { $images {$user} .= $users {$user} . "\n<a href='https://commons.wikimedia.org/wiki/File:$image2'>\n<img src='$url_thumb'></a> \n" ; }
          else         
          { $images {$user} .= "<a href='https://commons.wikimedia.org/wiki/File:$image2'>\n". $users {$user} . "</a>&nbsp;\n" ; }
        } 
      }
    }

  # last if ++ $imagecnt >= 20 ;
  }

  print OUT "\n" ;
  foreach $user (sort {$users {$b} <=> $users {$a}} keys %users)
  { print OUT $users {$user} . ",$user\n" ; }

print HTML 
"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>\n" .
"<html lang='en'>\n" .
"<head>\n" .
"<title>Wikipedia Statistics - Tables - All&nbsp;languages</title>\n" .
"<meta http-equiv='Content-type' content='text/html; charset=iso-8859-1'>\n" .
"<meta name='robots' content='noindex,nofollow'>\n\n" ;
"</head>\n" . 
"<body>\n\n" ;

  @uploaders = keys %users ;
  $uploaders_cnt = $#uploaders + 1 ;

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $now = sprintf ("%2d/%02d/%4d %2d hrs\n", $mday,$mon+1,$year+1900,$hour) ; 
  print HTML "<h3>Number of users who uploaded one or images to Wiki Loves Africa 2015 up till $now GMT is $uploaders_cnt</h3>\n\n" ;  
  foreach $user (sort {$users {$b} <=> $users {$a}} keys %users)
  { 
    print HTML "<h3>" . $users{$user}. " image uploads: user <a href='https://commons.wikimedia.org/wiki/user:$user'>$user</a></h3>" . $images {$user} . "\n" ;
    $total_uploads += $users{$user} ;
  }

print HTML 
"<p>Total uploads: $total_uploads\n" .
"</body>\n" .
"</html>\n" ;

  print "\nready\n\n" ;
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

  if (! -e $path_exclude)
  { abort ("File with categories not to expand '" . $path_exclude . "' not found") ; }

  $file_log             = "$path_out/scan_categories.log" ;
  $file_csv             = "$path_out/scan_categories_found_articles.csv" ;
  $file_categories      = "$path_out/scan_categories_found_tree.txt" ;

  print "\n" ;
  print "Log  $file_log\n" ;
  print "Csv  $file_csv\n" ;
  print "Txt  $file_categories\n" ;
  print "Html $path_html\n" ;

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
  print "\n" ;
  $regexps_exclude =~ s/\|$// ;
  print "regexps: $regexps_exclude\n" ; ;
  close CSV ;
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
  $ua->proxy(["http", "https"], $ENV{"http_proxy"}) ;
  $ua->agent("Wikimedia Perl job / EZ");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  my $succes = $false ;

  my $file2 = $file ;
  $file2 =~ s/^.*?api/api/ ;
  $file2 =~ s/([\x80-\xFF]{2,})/&UnicodeToAscii($1)/ge ;
  (my $category2 = $category) =~ s/([\x80-\xFF]{2,})/\?/g ;

  my $response = $ua->request($req);
  if ($response->is_error())
  {
    if (index ($response->status_line, "404") != -1)
    { &Log (" -> 404\n") ; }
    else
    { &Log (" -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
    return ($false) ;
  }

  $content = $response->content();
  $succes = $true ;

  if (! $succes)
  { &Log (" -> error: \nPage not retrieved after " . (--$attempts) . " attempts !!\n\n") ; }
  else
  { &Log (" -> OK\n") ; }

  return ($succes,$content) ;
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
  $msg =~ s/([\x80-\xFF])/("%".sprintf("%02X",$1))/gie ;
  print $msg ;
}


