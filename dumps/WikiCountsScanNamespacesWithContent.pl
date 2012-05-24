#!/usr/bin/perl

  no warnings 'uninitialized';

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  ez_lib_version (8) ;
  $trace_on_exit = $true ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Net::Domain qw (hostname);

  $file_namespaces = "StatisticsContentNamespaces.csv" ;
  # die "File $file_namespaces could not be found" if ! -e $file_namespaces ;
  open CSV_IN, '<', $file_namespaces ;
  while ($line = <CSV_IN>)
  {
    next if $line !~ /.*?,.*?,/ ;
    chomp $line ;
    ($proj_code,$lang,$namespaces) = split (',', $line,3) ;
    $namespaces =~ s/,+$// ;
    $namespaces {"$proj_code,$lang"} = $namespaces ;
  }
  close CSV_IN ;

  &GetNamespaces ('wb','wikibooks') ;
  &GetNamespaces ('wk','wiktionary') ;
  &GetNamespaces ('wn','wikinews') ;
  &GetNamespaces ('wp','wikipedia') ;
  &GetNamespaces ('wq','wikiquote') ;
  &GetNamespaces ('ws','wikisource') ;
  &GetNamespaces ('wv','wikiversity') ;
  &GetNamespaces ('wx','wikimedia') ;

  &SaveNamespaces ;
  print "\nReady\n\n" ;
  exit ;

sub GetNamespaces
{
  my ($proj_code,$proj_name) = @_ ;

  if ($job_runs_on_production_server)
  { $file_csv_in = "/a/wikistats/csv_$proj_code/StatisticsLog.csv" ; }
  else
  { $file_csv_in = "w:/# Out Bayes/csv_$proj_code/StatisticsLog.csv" ; }

  open CSV_IN, '<', $file_csv_in ;
  while ($line = <CSV_IN>)
  {
    next if $line !~ /^\w+/ ;
    ($lang) = split (',', $line) ;
    $lang =~ s/_/-/g ;
    $url = "http://$lang.$proj_name.org" ;

    next if $lang eq 'comcom' ;
    next if $lang eq 'tokipona' ;

    if ($proj_code eq 'wx')
    {
       next if $lang eq 'sep11' ;
       next if $lang eq 'dewikiversity' ;

         if ($lang eq 'species')    { $url = 'species.wikipedia.org' ; }
      elsif ($lang eq 'sources')    { $url = 'wikisource.org' ; }
      elsif ($lang eq 'mediawiki')  { $url = 'www.mediawiki.org' ; }
      elsif ($lang eq 'foundation') { $url = 'wikimediafoundation.org' ; }
    }
    $url .= "/w/api.php?action=query&meta=siteinfo&siprop=namespaces" ;

    ($success,$content) = GetPage ($url) ;
    if ($content =~ /^\d\d\d$/)
    {
      if ($namespaces {"$proj_code,$lang"} eq '')
      { $namespaces {"$proj_code,$lang"} = "'$content'" ; }
    }
    next if ! $success ;

    # print $content ;
    @lines = split "\n", $content ;
    $namespaces {"$proj_code,$lang"} = '' ;
    foreach $line (@lines)
    {
      next if $line !~ /ns id=/ ;
      next if $line !~ /content=&quot;&quot;/ ;
      ($ns = $line) =~ s/^.*id=&quot;(\d+)&quot;.*$/$1/ ;
      if ($ns =~ /^\d+$/)
      { $namespaces {"$proj_code,$lang"} .= "$ns," ; }
    }
    $namespaces {"$proj_code,$lang"} =~ s/,+$// ;
    print "$proj_code,$lang," . $namespaces {"$proj_code,$lang"} . "\n" ;
    # return if $lines++ > 3 ;
  }
  &SaveNamespaces ;
}


sub SaveNamespaces
{
  open CSV_OUT, '>', $file_namespaces ;
  foreach $key (sort keys %namespaces)
  { print CSV_OUT "$key," . $namespaces {$key} . "\n" ; }
  close CSV_OUT ;
}

sub GetPage
{
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
  $ua->timeout(5);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  my $succes = $false ;

  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
  #  if ($requests++ % 2 == 0)
  # { sleep (1) ; }

    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { print "$raw_url -> 404\n" ; return ($false,'404') ; }
      else
      {
        print "$raw_url -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n" ;
        if ($response->status_line =~ /500/)
        { return ($false,'500') ; }
      }
      return ($false) ;
    }

    $content = $response->content();

    $succes = $true ;
  }

  if (! $succes)
  { print "$raw_url -> error: \nPage not retrieved after " . (--$attempts) . " attempts !!\n\n" ; }

  return ($succes,$content) ;
}




