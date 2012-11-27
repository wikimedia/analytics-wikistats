#!/usr/local/bin/perl

# http://svn.wikimedia.org/viewvc/mediawiki/trunk/tools/counter/
# https://wikitech.leuksman.com/view/Squid_log_format:
# $hostname %sn %ts.%03tu %tr %>a %Ss/%03Hs %<st %rm %ru %Sh/%<A %mt %{Referer}>h %{X-Forwarded-For}>h %{User-Agent}>h

  use CGI qw(:all);
  use Getopt::Std ;

  $| = 1; # flush screen output
  $true  = 1 ;
  $false = 0 ;
  $timestart = time ;

  open LOG, ">", "extract.log" ;

  open DATA, "<", "extract.txt" ;


  $GbPrev = -1 ;
  while ($line = <DATA>)
  {
    $lines++ ;
    # if ($lines >= 1000000) { $lines-- ; last ; }
    $bytes += length ($line) ;
    $Gb = int ($bytes/1000000000) ;
    if ($GbPrev < $Gb)
    {
      $time2 = gmtime ($time) ;
      $duration = time - $timestart ;
      if ($duration > 0)
      { $mbsec = sprintf ("%.1f", ($Gb * 1000) / $duration) . " Mb/sec" ; }
      print "Read: $Gb Gb\nTime: $time2 $mbsec\n" ;
    }
    # if ($lines % 10000 == 0)
    # { print "Line: $lines\n" ; }
    $GbPrev = $Gb ;

    if ($line =~ / GET http:\/\/upload.wikimedia.org\//)
    { $get_upload++ ; next ; }

    if ($line =~ /.org\/skins-1.5/)
    { $org_skins++ ; next ; }

    chomp ($line) ;
    @fields  = split (' ', $line, 14) ;
    $action  = $fields [7] ;
    $url     = $fields [8] ;
    $time    = $fields [2] ;
    $referer = $fields [11] ;

    if ($time >= $newday)
    {
      $days   = int ($time / (24 * 60 * 60)) ;
      $newday = ($days + 1) * 24 * 60 * 60 ;
      $time2 = gmtime ($time) ;
      &Log ("Day:  $time2\n") ;
    }

    if ($#fields <= 8)
    { &Log ("Line incomplete:\n'$line'\n\n") ; next ; }

    if ($action ne "GET")
    { next  ; } # { &Log ("Ignore action '$action'\n") ; next ; }

    if ($url =~ /\?/) # wiki article pages do not take parms
    { next ; }

    if ($url !~ /http:\/\//) # not a valid http request
    { next ; }

    @url_parts = split ('\/', substr ($url,7)) ;
    if ($url_parts[1] ne 'wiki')
    { next ; }
    $host = $url_parts [0] ;
   ($page = $url_parts [2]) =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/eg;

#def recordHit(page,timestamp):
#        global aggCounter
#        global aggRange
#        global aggThresh

#        if (max(timestamp,aggRange[1])-aggRange[0] >= aggThresh):
#                for item in aggCounter.items():
#                        (site, pagename) = item[0].split(":", 1)
#                        conn = getConnection()
#                        conn.cursor().execute(
#                                "INSERT INTO hit_counter (hc_tsstart, hc_tsend, hc_site, hc_page, hc_count) VALUES (%s, %s, %s, %s, %s)",
#                                (time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime(aggRange[0])),time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime(aggRange[1])),site, pagename, item[1]))
#                        conn.commit()
#                aggRange=(aggRange[1],aggRange[1])
#                aggCounter.FreeArray()

#        if page in aggCounter:
#                aggCounter[page] += sampleHits
#        else:
#                aggCounter[page] = sampleHits
#        aggRange=(min(timestamp,aggRange[0]),max(timestamp,aggRange[1]))

#   $time = gmtime ($time) ;
#    print "$time $host:$page <= \n$referer\n" ;

  }

  $duration = time - $timestart ;
  if ($duration > 0)
  { $mbsec = " = " . sprintf ("%.1f", ($Gb * 1000) / $duration) . " Mb/sec" ; }
  $time2 = gmtime ($time) ;
  &Log ("Time: $time2 $mbsec\n") ;
  print "\nReady parsing log\n\n" ;
  print "Lines: $lines\n" ;
# print "GET uploads $get_upload\n" ;
# print "ORG skins $org_skins\n" ;
  &Log ("Ready\n") ;
  close LOG ;
  exit ;

sub ParseArguments
{
  my $options ;
  getopt ("ftplt", \%options) ;

  $csv_only = defined (@options {"c"}) ;

# abort ("Specify language code as: -l xx") if (! defined (@options {"l"})) ;

  $from          = @options {"f"} ;
  $till          = @options {"t"} ;
  $project       = @options {"m"} ; # m for 'mode' keep same as wikistats job
  $language      = @options {"l"} ;

  $langcode = uc ($language) ;
  $testmode = ((defined @options {"t"}) ? $true : $false) ;

  if (defined ($from))
  {
  }

# if ($mode eq "")
# { $mode = "wp" ; }
# if ($mode !~ /^(?:wb|wk|wo|wn|wp|wq|ws|wv|wx)$/)
# { abort ("Specify mode as: -m [wb|wk|wn|wo|wp|wq|ws|wv|wx]\n(wp=wikipedia (default), wb=wikibooks, wk=wiktionary, wn=wikinews, wo=wikivoyage, wp=wikipedia, wq=wikiquote, ws=wikisource, wv=wikiversity, wx=wikispecial)") ; }
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print LOG $msg ;
}


