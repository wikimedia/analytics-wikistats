#!/usr/bin/perl

  no warnings 'uninitialized';

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  ez_lib_version (8) ;
  $trace_on_exit = $true ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Net::Domain qw (hostname);
  use Getopt::Std ;

  my %options ;
  getopt ("cl", \%options) ;
  $path_csv     = $options {'c'} ;
  $path_dblists = $options {'l'} ;
  $path_dblists =~ s/\%20/ /g ;  # to be fixed: folder has space in name, here as underscore

  die "specify path to csv files as -c [path]" if ! -d $path_csv ;
  print "Path to csv files: $path_csv\n" ; 
  die "specify path to dblists as -l [path]" if ! -d $path_dblists ;
  print "Path to dblist files: $path_dblists\n" ; 

  $file_namespaces = "$path_csv/csv_mw/StatisticsContentNamespaces.csv" ;
  $file_run_stats  = "StatisticsLog.csv" ;

  # read previous content (so it will be preserved when api call fails) 
  if (-e $file_namespaces)
  {
    open CSV_IN, '<', $file_namespaces || die "Can't open $file_namespaces" ;
    while ($line = <CSV_IN>)
    {
      next if $line !~ /.*?,.*?,/ ;
      chomp $line ;
      $line =~ s/'500',?//g ; # cleanup invalid content from early bug
      ($proj_code,$lang,$namespaces) = split (',', $line,3) ;
      $namespaces =~ s/,+$// ;
      $namespaces {"$proj_code,$lang"} = $namespaces ;
    }
    close CSV_IN ;
  }
  
  &GetNamespaces ('wb','wikibooks') ;
  &GetNamespaces ('wk','wiktionary') ;
  &GetNamespaces ('wn','wikinews') ;
  &GetNamespaces ('wo','wikivoyage') ;
  &GetNamespaces ('wp','wikipedia') ;
  &GetNamespaces ('wq','wikiquote') ;
  &GetNamespaces ('ws','wikisource') ;
  &GetNamespaces ('wv','wikiversity') ;
  &GetNamespaces ('wx','wikimedia') ;

  &ForceExtraContentNamespaces ;
  &SaveNamespaces ;
  print "\nReady\n\n" ;
  exit ;

sub GetNamespaces
{
  my ($proj_code,$proj_name) = @_ ;

  $dblist = $proj_name ;
  if ($dblist eq 'wikimedia')
  { $dblist = 'special' ; }
  $file_dblist  = "$path_dblists/$dblist.dblist" ;  

  open DBLIST, '<', $file_dblist || die "Can't open $file_dblist" ;
  while ($line = <DBLIST>)
  {
    next if $line !~ /^\w+/ ;
    
    chomp $line ;

    if ($line =~ /mediawikiwiki/)
    { $lang = 'mediawiki' ; }
    elsif ($line =~ /wikidatawiki/)
    { $lang = 'wikidata' ; }
    else
    { ($lang=$line) =~ s/wik.*$// ; }
    
    $lang =~ s/_/-/g ;

    $url = "http://$lang.$proj_name.org" ;

    next if $lang eq 'comcom' ;
    next if $lang eq 'tokipona' ;
    next if $lang eq 'sep11' ;

       if ($lang eq 'species')    { $url = 'species.wikipedia.org' ; }
    elsif ($lang eq 'sources')    { $url = 'wikisource.org' ; }
    elsif ($lang eq 'mediawiki')  { $url = 'www.mediawiki.org' ; }
    elsif ($lang eq 'foundation') { $url = 'wikimediafoundation.org' ; }
    elsif ($lang eq 'wikidata')   { $url = 'www.wikidata.org' ; }
    
    $url .= "/w/api.php?action=query&meta=siteinfo&siprop=namespaces" ;

    ($success,$content) = GetPage ($url) ;
    
    next if ! $success ;
    
    if ($content =~ /^\d\d\d$/)
    {
      if ($namespaces {"$proj_code,$lang"} eq '')
      { $namespaces {"$proj_code,$lang"} = "'$content'" ; }
    }

    # print $content ;
    @lines = split "\n", $content ;
    $namespaces {"$proj_code,$lang"} = "0\|" ; # always add ns 0 (api call may fail, e.g. on incubator wiki (e.g. Feb 2014: kr.wikibooks.org) 
    foreach $line (@lines)
    {
      next if $line !~ /ns id=/ ;
      next if $line !~ /content=&quot;&quot;/ ;
      ($ns = $line) =~ s/^.*id=&quot;(\d+)&quot;.*$/$1/ ;
      next if $ns == 0 ; # already added
      if ($ns =~ /^\d+$/)
      { $namespaces {"$proj_code,$lang"} .= "$ns\|" ; }
    }

    $namespaces {"$proj_code,$lang"} =~ s/\|$// ;
    print "$proj_code,$lang," . $namespaces {"$proj_code,$lang"} . "\n" ;
    # return if $lines++ > 3 ;
  }
}

sub ForceExtraContentNamespaces
{
  # force extra content namespaces which may not have been defined in api, but always were countable 
  foreach $key (sort keys %namespaces)
  {
    if ($key =~ /^ws,/)
    {
      if ($namespaces {$key} !~ /102/) 
      { $namespaces   {$key} .= "\|102" ; }
      if ($namespaces {$key} !~ /104/) 
      { $namespaces   {$key} .= "\|104" ; }
      if ($namespaces {$key} !~ /106/) 
      { $namespaces   {$key} .= "\|106" ; }
    }
  }  

  if ($namespaces {"wx,strategy"} !~ /106/) 
  { $namespaces   {"wx,strategy"} .= "\|106" ; }
  if ($namespaces {"wx,commons"} !~ /\|6/) 
  { $namespaces   {"wx,commons"} .= "\|6" ; }
  if ($namespaces {"wx,commons"} !~ /\|14/) 
  { $namespaces   {"wx,commons"} .= "\|14" ; }

  foreach $key (sort keys %namespaces)
  {
    @namespaces = split ('\|', $namespaces {$key}) ; 
    @namespaces = sort {$a <=> $b} @namespaces ;
    $namespaces {$key} = join ('|', @namespaces) ;    
  }
}

sub SaveNamespaces
{
  open CSV_OUT, '>', $file_namespaces || die "Can't open $file_namespaces" ;
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





