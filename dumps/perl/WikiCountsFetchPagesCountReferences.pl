#!/usr/bin/perl

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;

  $false     = 0 ;
  $true      = 1 ;

  $file_titles = "Wiki-Studie 100 Wirkstoffe.txt" ;
  $file_csv    = "Wiki-Studie 100 Wirkstoffe.csv" ;
  $file_html   = "Wiki-Studie 100 Wirkstoffe.html" ;

  &ReadTitles ($file_titles) ;
  &FetchPages ($file_csv, $file_html) ;
  exit ;

sub ReadTitles
{
  my ($file_titles) = @_ ;
  die "File $file_titles not found" if ! -e $file_titles ;
  open TXT, '<', $file_titles ;
  while ($line = <TXT>)
  {
    print $line ;
    chomp $line ;

    next if $line =~ /^\s*$/ ;

    push @lines, $line ;
  }
}

sub FetchPages
{
  my ($file_csv, $file_html) = @_ ;

  open CSV,  '>', $file_csv ;
  open HTML, '>', $file_html ;
  print HTML "<html><body><h3>References</h3>\n" ;

  foreach $line (@lines)
  {
    $titles++ ;
    $url = "http://de.wikipedia.org/w/index.php?title=$line&action=raw" ;
    $content = "" ;
    ($result, $content) = &GetPage ($url, $false) ; # false is 'no html'
  # print "url $url\n\n" ;
  # print "result $result\n\n" ;
    $references = 0 ;
    undef %tags ;
  # print "content $content\n\n" ;
    $content =~ s/<ref[^>]*?name=\"([^\"]*)\"/(&CountRef ($1), '<XXXXXXXXX')/gie ;
    $content =~ s/<ref[^>]*?name=\'([^\']*)\'/(&CountRef ($1), '<XXXXXXXXX')/gie ;
    $content =~ s/<ref[^>]*?name=(\w+)/(&CountRef ($1), '<YYYYYYYYY')/gie ;
    $content =~ s/<ref>/(&CountRef (''), '<ZZZZZZZZZZ')/ge ;
  # print "content $content\n\n" ;

    if (! $result)
    { $references = '??' ; }
    print CSV "$titles,$line,$references\n" ;
    if (! $result)
    { $references = '<font color=#F00>Not found</font>' ; }
    print HTML "<a href='http://de.wikipedia.org//w/index.php?title=$line'>$line</a> $references<br>\n" ;
    print "$line:$references\n" ;
  }

  print HTML "</body></html>\n" ;
  close HTML ;
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

  print "\nFetch '$file'" ;
  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { print " -> 404\n" ; }
      else
      { print " -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n" ; }
      return ($false) ;
    }

    $content = $response->content();

    if ($is_html && ($content !~ m/<\/html>/i))
    {
      print "Page is incomplete:\n  '$raw_url'\n" ;
      next ;
    }

    $succes = $true ;
  }

  if (! $succes)
  { print " -> error: \nPage not retrieved after " . (--$attempts) . " attempts !!\n\n" ; }
  else
  { print " -> OK\n" ; }

  return ($succes,$content) ;
}

sub CountRef
{
  my ($tag) = @_ ;

  if ($tag eq '')
  { $references ++ ; }
  else
  {
    if (not defined $tags {$tag})
    { $references ++ ; }
    $tags {$tag}++ ;
  }
  print "Count ref tag $tag $references\n" ;
}

