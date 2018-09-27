#!/usr/bin/perl
# periodically harvest updated metrics from
# '//en.wikipedia.org/wiki/List_of_countries_by_population'
# '//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'

# derived from stat1005:/a/wikistats_git/squids/perl/SquidReportArchive.pl
# but with different file names and cleaner content (less format details)

  use strict 'subs' ;
# use strict 'vars' ;

  $| = 1; # Flush output

  use Time::Local ;
  use Cwd;
# use LWP::Simple qw($ua get);
  use LWP::UserAgent;
  use HTTP::Request ;
  use HTTP::Response ;
  use URI::Heuristic ;

  my $true = 1 ;

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  our $trace_on_exit = $true ;
  ez_lib_version (2) ;
  
  my (%options, %countries) ;

  getopt ("m", \%options) ;

  our $path_meta = $options {"m"} ; 
# our $file_csv_country_meta_info = "CountryInfo.csv" ;
  our $file_csv_country_meta_info = "GeoInfo.csv" ;

  our $comma = '%2C' ; # avoid commas in data in csv file

  die ("Specify meta folder as -m [..]")      if not defined $path_meta ;
  die ("Meta folder not found: '$path_meta'") if ! -d $path_meta ;

  my $ua = LWP::UserAgent->new();
  $ua->proxy(["http", "https"], $ENV{"http_proxy"}); 
  $ua->agent('Wikimedia Perl job / EZ');
  $ua->timeout(60);

  &ArchiveCountryInfo ;
  &ReadWikipediaCountriesByPopulation ;
  &ReadWikipediaCountriesByInternetUsers ;
  &ReadCountryInfo ;
  &WriteCountryInfo ;

  print "\n\nReady\n\n" ;
  exit ;

sub ArchiveCountryInfo
{
  print "\&ArchiveFileCountryInfo\n" ;

  my ($file_in,$file_out) ;
  my ($line,$lines,$date) ;

  my ($sec,$min,$hour,$day,$month,$year) = localtime(time); 
  $date = sprintf ("%4d-%02d-%02d", $year+1900, $month+1, $day) ;

  $file_in  = "$path_meta/$file_csv_country_meta_info" ;
  $file_out = "$path_meta/archive/$file_csv_country_meta_info" ;
  $file_out =~ s/\.csv/-$date.csv/ ;
 
  print "Move '$file_in'\n->   '$file_out\n" ;

  open IN,  '<', $file_in ;
  open OUT, '>', $file_out || die "Could not create file '$file_out'" ;

  while ($line = <IN>)
  { 
    $lines++ ;
    print OUT $line ; 
  }

  die "Archiving '$file_in' failed: no lines copied" if $lines == 0 ;

  print "Move done, $lines lines copied\n" ;

  close OUT ;
  close IN ;
}


sub ReadWikipediaCountriesByPopulation
{
  print "\n\&ReadWikipediaCountriesByPopulation\n" ;

  my ($html,$line,$url,$icon,$icon_url,$icon_width,$icon_height,$country,$title,$population,$article_url) ;
  my @cells ;

# $url = 'http://en.wikipedia.org/wiki/List_of_countries_by_population';
# $html = get $url || abort ("Timed out!") ;
  $url = URI::Heuristic::uf_urlstr('http://en.wikipedia.org/wiki/List_of_countries_by_population');
  $req = HTTP::Request->new(GET => $url) ;
  $req->referrer ('Wikimedia Perl job / EZ') ;  
  $response = $ua->request($req) ;
  $html = $response->content();

  # split file on <tr>'s, remove everything after </tr>
  $html =~ s/\n/\\n/gs ;
  foreach $line (split "(?=<tr)", $html)
  {
    next if $line !~ /^<tr/ ;
    next if $line !~ /class=\"flagicon\"/ ;

    $line =~ s/(?<=<\/tr>).*$// ;
  # print "$line\n\n" ;

    @cells = split "(?=<td)", $line ;
   # foreach $cell (@cells)
   # { print "CELL $cell\n" ; }

    if ($cells [2] =~ /<img /)
    {
 
      $icon = $cells [2] ;
     ($icon_url    = $icon) =~ s/^.*?src="([^"]*)".*$/$1/ ; 
     ($icon_width  = $icon) =~ s/^.*? width="(\d+)".*$/$1/ ;
     ($icon_height = $icon) =~ s/^.*? height="(\d+)".*$/$1/ ;
      $icon_url =~ s/https?:/:/g ; 
    # print "\nICON url '$icon_url',\nwidth '$icon_width',\nheight '$icon_height' \n" ;
    }
    else
    { 
      $icon_url    = "-" ; 
      $icon_width  = "-" ; 
      $icon_height = "-" ; 
    }

    if ($cells [2] =~ /title/)
    {
      $country = $cells [2] ;
      $country =~ s/^.*?<a [^>]*>([^<]*)<.*$/$1/ ;
      # print "COUNTRY '$country'\n" ;
    }
    else
    { $title = "n.a." ; }

    if ($cells [2] =~ /<a /)
    {
      $article_url = $cells [2] ;
      $article_url =~ s/\s*title="[^"]*"// ;
      $article_url =~ s/^.*?(<a [^>]*>.*?<\/a>).*$/$1/ ;
      $article_url =~ s/\/wiki/:\/\/en.wikipedia.org\/wiki/ ;
      $article_url =~ s/"/'/g ;
    # print "\nARTICLE URL '$article_url'\n" ;
    }
    else
    { $title = "n.a." ; }

    ($population = $cells [3]) =~ s/<td[^>]*>(.*?)<.*$/$1/, $population =~ s/,/_/g ;
    $population =~ s/_//g ;

  # print "\nPOP $population\n\n" ;

    $country  =~ s/,/$comma/g ;
    $article_url     =~ s/,/$comma/g ;
    $icon_url =~ s/,/$comma/g ;

    $country = &NormalizeCountryName ($country) ;
  # print "country: $country\nlink: $article_url\npopulation: $population\nconnected: $connected\nicon: $icon\n\n" ;
    $countries  {$country} = "$country,$population,connected,$article_url,$icon_url,$icon_width,$icon_height\n" ;
    $population {$country} = $population ;
  }
}

sub ReadWikipediaCountriesByInternetUsers
{
  print "\n\&ReadWikipediaCountriesByInternetUsers\n" ;

  my ($html,$line,$url,$country,$data,$connected) ;
  my @cells ;

# $url = 'http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users';
# $html = get $url || abort ("Timed out!") ;

  $url = URI::Heuristic::uf_urlstr('http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users');
  $req = HTTP::Request->new(GET => $url) ;
  $req->referrer ('Wikimedia Perl job / EZ') ;  
  $response = $ua->request($req) ;
  $html = $response->content();

  # split file on <tr>'s, remove all behind </tr>
  $html =~ s/\n/\\n/gs ;
  foreach $line (split "(?=<tr)", $html)
  {
    next if $line !~ /^<tr/ ;
    next if $line !~ /class=\"flagicon\"/ ;

    $line =~ s/(?<=<\/tr>).*$// ;
  # print "$line\n\n" ;

    @cells = split "(?=<td)", $line ;

    if ($cells [1] =~ /title/)
    {
      $country = $cells [1] ;
      $country =~ s/^.*?title=\"([^\"]+)".*$/$1/ ;
    # print "COUNTRY '$country'\n" ;
    }
    else
    { $country = "n.a." ; }

    $country = &NormalizeCountryName ($country) ;

    $connected = $cells [2] ;
    $connected =~ s/<td[^>]*>(.*?)<.*$/$1/, $connected =~ s/,/_/g ;
    $connected =~ s/_//g ;
    # print "POP $population\n\n" ;

    # print "Country: $country\nconnected: '$connected'\n\n" ;

    $countries {$country} =~ s/connected/$connected/ ;
    $connected {$country} = $connected ;
  }

  foreach $country (sort keys %countries)
  {
    $data = $countries {$country} ;

    if ($data =~ /connected/)
    { 
      print "Metric 'connected' unknown for: $country\n" ;
      $countries {$country} =~ s/connected/-/ ; 
    }
  }
}

sub ReadCountryInfo
{
  print "\n\&ReadCountryInfo\nRead $path_meta/$file_csv_country_meta_info\n\n" ;

  open IN, '<',"$path_meta/$file_csv_country_meta_info" ;
  while ($line = <IN>)
  {
    if ($line !~ /^C/) # record with country info ?
    {
      push @lines, $line ; 
      next ;
    }

    my ($rectype, $iso2, $iso3, $region, $north_south, $country, $population, $connected, $remainder) = split (',', $line, 9) ;

    if ($population {$country} ne '')
    { $population = $population {$country} ; } 
  
    if ($connected {$country} ne '')
    { $connected = $connected {$country} ; } 
  
    $line = "$rectype,$iso2,$iso3,$region,$north_south,$country,$population,$connected,$remainder" ;
    push @lines, $line ; 
  }

  close IN ;
}

sub WriteCountryInfo
{
  print "\n\&WriteCountryInfo\nWrite $path_meta/$file_csv_country_meta_info\n\n" ;

  my $country ;

  open OUT, '>', "$path_meta/$file_csv_country_meta_info" ;

  foreach $line (@lines)
  { 
    print OUT $line ; 
  }

  close OUT ;
}

sub NormalizeCountryName 
{
  my $country = shift ;

  $country =~ s/American American Samoa/American Samoa/ ;
  $country =~ s/Bahamas, The/The Bahamas/ ;
  $country =~ s/Bosnia-Herzegovina/Bosnia and Herzegovina/ ;
  $country =~ s/British Virgin Islands/Virgin Islands, UK/ ;
  $country =~ s/C.*.+te d'Ivoire/Cote d'Ivoire/ ;
  $country =~ s/C..?te d'Ivoire/Cote d'Ivoire/ ;
  $country =~ s/Congo, Democratic Republic of/Democratic Republic of the Congo/ ;
  $country =~ s/Congo, Republic of/Republic of the Congo/ ;
  $country =~ s/Democratic Republic of the Congo/Congo Dem. Rep./ ;
  $country =~ s/East timor/Timor-Leste/ ;
  $country =~ s/Gambia, The/Gambia/ ;
  $country =~ s/Georgia_.*country.*/Georgia/ ;
  $country =~ s/Guyane/French Guiana/ ;
  $country =~ s/Ivory Coast/Cote d'Ivoire/ ;
  $country =~ s/Korea, South/South Korea/ ;
  $country =~ s/Macedonia, Republic of/Republic of Macedonia/ ;
  $country =~ s/Myanmar/Burma/ ;
  $country =~ s/Palestin.*/Palestinian Territories/ ;
  $country =~ s/Republic of Ireland/Ireland/ ;
  $country =~ s/Saint Helena.*$/Saint Helena/ ;  # - , Ascension and Tristan da Cunha
  $country =~ s/Samoa/American Samoa/ ;
  $country =~ s/Timor Leste/Timor-Leste/ ;
  $country =~ s/UAE/United Arab Emirates/ ;
  $country =~ s/United States Virgin Islands/Virgin Islands, US/ ;
  $country =~ s/^.*Micronesia/Micronesia/ ; # - Federated States of
  $country =~ s/^Republic of the Congo/Congo Rep./ ;
  $country =~ s/territories/Territories/ ;
# $country =~ s/Congo, Democratic Republic of/Dem. Rep. Congo/ ;
# $country =~ s/Congo, Republic of/Rep. Congo/ ;

  $country =~ s/,/$comma/g ;

  return ($country) ;
}
