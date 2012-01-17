#!/usr/bin/perl

  use Time::Local ;
  use Compress::Zlib;
  use Getopt::Std ;

  my $options ;
  getopt ("d", \%options) ;
  $date = $options {"d"} ;

  die "Specify date as yyyy/mm/dd" if $date !~ /^\d\d\d\d\/\d\d\/\d\d$/ ;
  ($year,$month,$day) = split ('\/', $date) ;

  $date1  = sprintf ("%04d%02d%02d", $year, $month, $day) ;
  $time = timegm (0,0,0,$day,$month-1,$year-1900) ;
  ($sec,$min,$hour,$day2,$month2,$year2) = gmtime ($time+24*3600) ;
  $date2  = sprintf ("%04d%02d%02d", $year2+1900, $month2+1, $day2) ;

  if (-d "/a/ezachte")
  {
    $dir_in  = "/a/squid/archive" ;
    $dir_out = "/a/ezachte" ;
  }
  else
  {
    print "Test on Windows\n" ;
    use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ; # install IO-Compress-Zlib
    use IO::Compress::Gzip     qw(gzip   $GzipError) ;   # install IO-Compress-Zlib

    $dir_in  = "." ;
    $dir_out = "." ;
  }

  $dir_out .= "/" . sprintf ("%04d-%02d", $year, $month) ;

  if (! -d $dir_out)
  {
    print "mkdir $dir_out\n" ;
    mkdir ($dir_out) || die "Unable to create directory $dir_out\n" ;
  }

  $dir_out .= "/" . sprintf ("%04d-%02d-%02d", $year, $month, $day) ;
  if (! -d $dir_out)
  {
    print "mkdir $dir_out\n" ;
    mkdir ($dir_out)           || die "Unable to create directory $dir_out\n" ;
    print "mkdir $dir_out/private\n" ;
    mkdir ("$dir_out/private") || die "Unable to create directory $dir_out/private\n" ;
    print "mkdir $dir_out/public\n" ;
    mkdir ("$dir_out/public" ) || die "Unable to create directory $dir_out/public\n" ;
  }

  &CollectEdits ($date1,$date2) ;
# &CollectViews ($date1,$date2) ; # moved to SquidCountArchive.pl

  print "\n\nReady\n\n" ;
  exit ;

sub CollectEdits
{
  my ($date1,$date2) = @_ ;

  $file_date1 = "$dir_in/edits.log-$date1.gz" ;
  $file_date2 = "$dir_in/edits.log-$date2.gz" ;
  $file_out   = "$dir_out/private/SquidDataEditsVizDoNotPublish-$date1.gz" ;

  die ("File not found: $file_date1\n") if (! -e $file_date1) ;
  die ("File not found: $file_date2\n") if (! -e $file_date2) ;

# open OUT, '>', "$dir_out/edits-$date1.txt" ;
  $gz_out = gzopen ($file_out, "wb") || die "Unable to write $file_out $!\n" ;
  &FilterRequests ($file_date1,$date1,$date2) ;
  &FilterRequests ($file_date2,$date1,$date2) ;
  $gz_out->gzclose();
# close OUT ;
}

sub CollectViews
{
  my ($date1,$date2) = @_ ;

  $file_date1 = "$dir_in/sampled-1000.log-$date1.gz" ;
  $file_date1 = "$dir_in/sampled-1000.log-$date2.gz" ;
  $file_out   = "$dir_out/viz-edits-$date1.gz" ;

  die ("File not found: $file_date1\n") if (! -e $file_date1) ;
  die ("File not found: $file_date2\n") if (! -e $file_date2) ;

# open OUT, '>', "$dir_out/edits-$date1.txt" ;
  $gz_out = gzopen ($file_out, "wb") || die "Unable to write $file_out $!\n" ;
  &FilterRequests ($file_date1,$date1,$date2) ;
  &FilterRequests ($file_date2,$date1,$date2) ;
  $gz_out->gzclose();
# close OUT ;
}

sub FilterRequests
{
  my ($file,$date1,$date2) = @_ ;

  $date1 = substr ($date1,0,4) . '-' . substr ($date1,4,2) . '-' . substr ($date1,6,2) ;
  $date2 = substr ($date2,0,4) . '-' . substr ($date2,4,2) . '-' . substr ($date2,6,2) ;

  print "\n\nFilterRequests $file $date1 $date2\n\n" ;

  # open IN,"-|", "gzip -dc $file" ;
  $gz_in = gzopen ($file, "r") || die "Unable to read $file $!\n" ;
# open IN,"<", $file ;

# while ($line = <IN>)
  my $lines  = 0 ;
  my $lines2 = 0 ;
  while ($gz_in->gzreadline ($line) > 0)
  {
    @fields = split ' ', $line ;
    $time   = $fields [2] ;
    $ip     = $fields [4] ;
    $action = $fields [5] ;
    $url    = $fields [8] ;
    $agent  = lc ($fields [13]) ;

    if ($lines++ % 10000 == 0)
    { print "$time\n" ; }

    last if $time =~ /^$date2/ ;  # many lines for subsequent data on second file
    next if $time !~ /^$date1/ ;  # many lines for previous day on first file

    if ($lines2++ == 0)
    {
      print "\n\nStart copying...\n\n" ;
      print "$time\n" ;
    }

    next if $url !~ /action=submit/ ;
    next if $action ne "TCP_MISS/302" ;

    if (($agent =~ /bot/i) || ($agent =~ /https?:\/\//))
    { $bot = 'B' ; }
    else
    { $bot = 'M' ; }

    $url =~ s/^.*?\/\/// ;
    ($domain,$location) = split ('\/',$url,2) ;
    $domain  = &Abbreviate ($domain) ;
    if (($domain =~ /\./o) ||
        ($domain !~ /^[\*\@\%]?!(wb|wn|wp|wq|ws|wv|wk|wx|xx|wm|mw|wmf)\:/o))
    {
      $unrecognized_domains {$domain_original} ++ ;
      $domain = 'other' ;
    }
    $domain  =~ s/!//o ; # not sure why this happens after Abbreviate, kept inline with SquidCountArchiveProcessLogRecord.pm

    $time = substr ($time,0,19) ; # omit msec
    $line = "$time,$ip,$domain,$bot\n" ;
    $gz_out->gzwrite($line) || die "Zlib error writing to $gzfile: $gz_out->gzerror\n" ;
  }

  print "$time\n" ;

  $gz_in->gzclose();
}

sub Abbreviate  # copied from SquidCountArchiveProcessLogrecord, someday make it separate module
{
  my $domain = shift ;

  $domain =~ s/www\.([^\.]+\.[^\.]+\.[^\.]+)/$1/o ;
  $domain =~ s/\.com/\.org/o ;
  $domain =~ s/^([^\.]+\.org)/www.$1/o ;

  if ($domain !~ /\.org/o)
  { $domain =~ s/www\.(wik[^\.\/]+)\.([^\.\/]+)/$2.$1.org/o ; }

# $legend  = "# wx = wikispecial (commons|mediawiki|meta|foundation|species)\n" ;
# $legend .= "# xx:upload = upload.wikimedia.org\n" ;
  $domain =~ s/commons\.wikimedia\.org/!wx:commons/o ;
  $domain =~ s/www\.mediawiki\.org/!wx:mediawiki/o ;
  $domain =~ s/meta\.wikipedia\.org/!wx:meta/o ;
  $domain =~ s/meta\.wikimedia\.org/!wx:meta/o ;
  $domain =~ s/foundation\.wikimedia\.org/!wx:foundation/o ;
  $domain =~ s/species\.wikimedia\.org/!wx:species/o ;
  $domain =~ s/upload\.wikimedia\.org/!xx:upload/o ;

# $legend .= "# wmf = wikimediafoundation\n" ;
# $legend .= "# wb  = wikibooks\n" ;
# $legend .= "# wn  = wikinews\n" ;
# $legend .= "# wp  = wikipedia\n" ;
# $legend .= "# wq  = wikiquote\n" ;
# $legend .= "# ws  = wikisource\n" ;
# $legend .= "# wv  = wikiversity\n" ;
# $legend .= "# wk  = wiktionary\n" ;
# $legend .= "# wm  = wikimedia\n" ;
# $legend .= "# mw  = mediawiki\n" ;
# $legend .= "# \@   = .mobile.\n" ;
# $legend .= "# \*   = .wap.\n" ;
# $legend .= "# \%   = .m.\n" ;

  $domain =~ s/wikimediafoundation/!wmf/o ;
  $domain =~ s/wikibooks/!wb/o ;
  $domain =~ s/wikinews/!wn/o ;
  $domain =~ s/wikipedia/!wp/o ;
  $domain =~ s/wikiquote/!wq/o ;
  $domain =~ s/wikisource/!ws/o ;
  $domain =~ s/wikiversity/!wv/o ;
  $domain =~ s/wiktionary/!wk/o ;
  $domain =~ s/wikimedia/!wm/o ;
  $domain =~ s/mediawiki/!mw/o ;

  $domain =~ s/\.mobile\./.@/o ;
  $domain =~ s/\.wap\./.*/o ;
  $domain =~ s/\.m\./.%/o ;

# if ($domain =~ /^error:/o)
#  { $domain_errors {$domain}++ ; }
# $domain =~ s/error:.*$/!error:1/o ;

  $domain =~ s/^([^\.\/]+)\.([^\.\/]+)\.org/$2:$1/o ;

  $domain =~ s/\s//g ;

  return ($domain) ;
}

