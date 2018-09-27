#!/usr/bin/perl

# 2016-07-09 minus reading input files no longer needed after migration from SquidReportArchive.pl

# ReadInputBrowserLanguages
# ReadInputClients
# ReadInputCountriesInfo
# ReadInputCountriesTimed
# ReadInputCrawlers
# ReadInputGoogle
# ReadInputIndexPhp
# ReadInputMethods
# ReadInputMimeTypes
# ReadInputOpSys
# ReadInputOrigins
# ReadInputScripts
# ReadInputSkins
# ReadInputUseragents
# ReadWikipediaCountriesByPopulation
# ReadWikipediaCountriesByInternetUsers
# ReadCountryInfo  
# ReadInputCountriesDaily
# ReadDate

# 2018-04 csv_shorten_demographics: no longer shorten demographics for csv files (still do for html files)  
# csv files are now also post processed into json file, which could benefit from more detailed figures
# so for WiViVi shortening needs to be done in javascript 
# for request data (= page views) shortening still provides some fuzziness on purpose 

# replaced by new ReadCsvGeoInfo
# sub ReadCountryCodes
# {
#   &LogSub ("ReadCountryCodes\n") ;
#
#   my @csv = ReadCsv ("$path_meta/$file_csv_country_codes") ;
#
#   foreach $line (@csv)
#   {
#     if ($line =~ /^[A-Z]/)
#     {
#       chomp ($line) ;
#       ($code,$name) = split (',',$line,2) ;
#       $country_codes {$code} = unicode_to_html ($name) ;
#       # print "$code => $name\n" ;
#     }
#   }
# 
#   $country_codes {'-'}  = 'Unknown3' ;
#   $country_codes {'--'} = 'Unknown4' ;
#   $country_codes {'XX'} = 'Unknown5' ;
#   $country_codes {'-P'} = 'IPv6' ;
#   $country_codes {'-X'} = 'Unknown6' ;
# }

# replaced by new ReadCsvGeoInfo
# sub ReadCountryCodesISO3
# {
#   &LogSub ("ReadCountryCodesISO3\n") ;
#  
#   my @csv = &ReadCsv ("$path_meta/CountryCodesISO3.csv") ;
#
#   foreach $line (@csv)
#   {
#     if ($line =~ /^[A-Z]/)
#     {
#       chomp ($line) ;
#       ($code,$name) = split (',',$line,2) ;
#       $name =~ s/"//g ;
#       $name =~ s/\s+$//g ; # remove trailing spaces
#       $country_codes_iso3 {$code} = $name ;
#       $country_names_iso3 {$name} = $code ;
#     # print "$code => $name\n" ;
#     }
#   }
# }

# replaced by new ReadCsvGeoInfo
# sub AddExtraCountryNames_iso3
# { 
# add entries for country names spelled differently in $file_csv_country_codes 
#   $country_names_iso3 {'Bolivia'}                 = 'BOL' ;
#   $country_names_iso3 {'Brunei'}                  = 'BRN' ;
#   $country_names_iso3 {'Burma'}                   = 'MMR' ;
#   $country_names_iso3 {'Cape Verde'}              = 'CPV' ;
#   $country_names_iso3 {'Caribbean Netherlands'}   = 'XXX' ;
#   $country_names_iso3 {'Congo Dem.Rep.'}          = 'COD' ;
#   $country_names_iso3 {'Congo Rep.'}              = 'COG' ;
#   $country_names_iso3 {"Cote d'Ivoire"}           = 'CIV' ;
#   $country_names_iso3 {'Falkland Islands'}        = 'FLK' ;
#   $country_names_iso3 {'Iran'}                    = 'IRN' ;
#   $country_names_iso3 {'Laos'}                    = 'LAO' ;
#   $country_names_iso3 {'Macedonia'}               = 'MKD' ;
#   $country_names_iso3 {'Micronesia'}              = 'FSM' ;
#   $country_names_iso3 {'Moldova'}                 = 'MDA' ;
#   $country_names_iso3 {'Palestinian Territories'} = 'PSE' ;
#   $country_names_iso3 {'Russia'}                  = 'RUS' ;
#   $country_names_iso3 {'Sint Maarten'}            = 'SXM' ;
#   $country_names_iso3 {'South Korea'}             = 'KOR' ;
#   $country_names_iso3 {'Syria'}                   = 'SYR' ;
#   $country_names_iso3 {'Sao Tome and Principe'}   = 'STP' ;
#   $country_names_iso3 {'Taiwan'}                  = 'TWN' ;
#   $country_names_iso3 {'Tanzania'}                = 'TZA' ;
#   $country_names_iso3 {'United States'}           = 'USA' ;
#   $country_names_iso3 {'Vatican City'}            = 'VAT' ;
#   $country_names_iso3 {'Venezuela'}               = 'VEN' ;
#   $country_names_iso3 {'Vietnam'}                 = 'VNM' ;
#   $country_names_iso3 {'Virgin Islands, UK'}      = 'VGB' ;
#   $country_names_iso3 {'Virgin Islands, US'}      = 'VIR' ;
# }

sub ReadCsv
{
  my $file_in = shift ;
  print "\&ReadCsv '$file_in'\n" ;

  my $lines ;
  my @csv ;
  
  die "Not file specified (path ends on '\/'): in '$file_in'" if $file_in =~ /\/\s*$/ ; 
  die "Input file '$file_in' not found!" if ! -e $file_in ; 
  open  CSV_IN, '<', $file_in || die "File '$file_in' could not be opened" ;
  binmode CSV_IN ;

  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;
    next if $line !~ /,/ ;

    $lines++ ;
    chomp $line ;
    push @csv, $line ;
  }

  die "File '$file_in' contains no valid data lines" if $lines == 0 ;
 
  print "Data lines: $lines\n" ;
  return (@csv) ;
}

# replaced by new ReadCsvGeoInfo
# sub ReadInputRegionCodes
# {
#   &LogSub ("ReadInputRegionCodes\n") ;
#
#   my @csv = &ReadCsv ("$path_meta/RegionCodes.csv") ;
# 
#   foreach $line (@csv)
#   {
#     ($country_code,$region_code,$north_south_code) = split (',', $line) ;
#     $region_codes      {$country_code} = $region_code ;
#     $north_south_codes {$country_code} = $north_south_code ;
#   }
# }

# replaced by new ReadCsvGeoInfo
# sub ReadInputCountryNames
# {
#   &LogSub ("ReadInputCountryNames\n") ;
#
#   my @csv = &ReadCsv ("$path_meta/CountryCodes.csv") ;
#
#   $country_names {'-'}  = 'Unknown7' ;
#   $country_names {'--'} = 'Unknown8' ;
#   $country_names {'-P'} = 'IPv6' ;
#   $country_names {'-X'} = 'Unknown9' ;
#   $country_names {"XX"} = "Unknown10" ;
#
#   foreach $line (@csv)
#   {
#     chomp $line ;
#
#     next if $line =~ /^#/ ;
#
#     $line =~ s/\"//g ;
#
#     $line =~ s/[\x00-\x1f]//g ;
#     $line =~ s/UNDEFINED/Undefined/g ;
#     $line =~ s/territories/Territories/ ;
#
#     $line =~ s/(Falkland Islands).*$/$1/g ; # - (Malvinas)
#     $line =~ s/Reunion/Réunion/ ;
#     $line =~ s/Aland Islands/Åland Islands/ ;
#     $line =~ s/Bonaire, Saint Eustatius and Saba/Caribbean Netherlands/ ;
#     $line =~ s/Congo, The Democratic Republic of the/Congo Dem. Rep./ ;
#     $line =~ s/Congo$/Congo Rep./ ;
#     $line =~ s/Curacao/Curaçao/ ;
#     $line =~ s/Brunei Darussalam/Brunei/ ;
#     $line =~ s/Holy See.*$/Vatican City/ ;
#     $line =~ s/Iran, Islamic Republic of/Iran/ ;
#     $line =~ s/Korea, Democratic People's Republic of/North Korea/ ;
#     $line =~ s/Korea, Republic of/South Korea/ ;
#     $line =~ s/Lao People's Democratic Republic/Laos/ ;
#     $line =~ s/Libyan Arab Jamahiriya/Libya/ ;
#     $line =~ s/Micronesia, Federated States of/Micronesia/ ;
#     $line =~ s/Moldova, Republic of/Moldova/ ;
#     $line =~ s/Myanmar/Burma/ ;
#     $line =~ s/Palestinian Territory/Palestinian Territories/ ;
#     $line =~ s/Pitcairn/Pitcairn Islands/ ;
#     $line =~ s/Russian Federation/Russia/ ;
#     $line =~ s/American American Samoa/American Samoa/ ;
#     $line =~ s/Saint Bartelemey/Saint Barthélemy/ ;
#     $line =~ s/Sao Tome and Principe/São Tomé and Príncipe/ ;
#     $line =~ s/Syrian Arab Republic/Syria/ ;
#     $line =~ s/Tanzania, United Republic of/Tanzania/ ;
#     $line =~ s/Virgin Islands, British/Virgin Islands, UK/ ;
#     $line =~ s/Virgin Islands, U.S./Virgin Islands, US/ ;
#    
#     # ($country_code,$region_code,$north_south_code,$country_name) = split (',', $line,4) ;
#     ($country_code,$country_name) = split (',', $line,2) ;
#
#     $country_name =~ s/"//g ;
#
#     # next if $country_name eq "Anonymous Proxy" ;
#     # next if $country_name eq "Satellite Provider" ;
#     # next if $country_name eq "Other Country" ;
#     # next if $country_name eq "Asia/Pacific Region" ;
#     # next if $country_name eq "Europe" ;
#
# #    if ($country_meta_info {$country}  eq "")
# #    {
# #      if ($country_meta_info_not_found_reported {$country} ++ == 0)
# #      { print "Meta info not found for country '$country'\n" ; }
# #    }
#
#     $country_names_found {$country_name} ++ ;
#     $country_names       {$country_code} = $country_name ;
#     $country_codes_all   {"$country_name|$country_code"} ++ ;
#   }
# }

sub ReadGeoInfoWikimedia
{
  &LogSub ("ReadGeoInfoWikimedia\n") ;

  my ($iso2,$iso3,$region_code,$north_south_code,$country_name,$article_title,$width,$height) ;

  die ("Could not open '$path_meta/$file_csv_geocodes'") if ! -e "$path_meta/$file_csv_geocodes" ;

  open CSV_GEOINFO, '<', "$path_meta/$file_csv_geocodes" ;

  while ($line = <CSV_GEOINFO>)
  {
    next if $line =~ /^\#/ ; # skip comments
    chomp $line ;

    if ($line =~ /^C/) # country info # June 2018 only record type in the file
    {
      ($rectype,$iso2,$iso3,$region_code,$north_south_code,$country_name,$population,$connected,$article_title,
                                                                                          $icon,$width,$height) = split (',', $line) ;
# print "A $iso2: $icon $width $height\n" if $icon =~ /src.*img/ ; 
print "A $iso2: $icon $width $height\n" ; 

      $iso2_codes {$iso2} ++ ;
      $iso3_codes {$iso3} ++ ;

      $country_name  =~ s/\%2C/,/g ;

      $country_names            {$iso2}         = $country_name ;
    # $country_names_iso3       {$country_name} = $iso3 ;
      $country_iso2_from_name   {$country_name} = $iso2 ;
      $country_iso3             {$iso2}         = $iso3 ;
      $region_codes             {$iso2}         = $region_code ;
      $north_south_codes        {$iso2}         = $north_south_code ;
      $connected_perc = '--' ;
      if (($population > 0) && ($connected > 0))
      { $connected_perc = sprintf ("%.2f", 100 * $connected / $population) ; } ;
      $connected_perc_wikipedia {$iso2} = $connected_perc ;

      $article_url = "<a href='://en.wikipedia.org/wiki/$article_title'>$country_name<\/a>" ; 
      $icon        = "<img src='//upload.wikimedia.org/wikipedia/$icon' $width $height border=1>" ;
      $country_meta_info = "$article_title,$icon,$population,$connected";

    # $country_meta_info {$country_name} = $country_meta_info ;
      $country_meta_info {$iso2}         = $country_meta_info ;
print "B: $iso2 $country_meta_info\n" if $icon =~ /src.*img/ ; 

      print "$iso2: no country name\n"                     if $country_name     =~ /^\-?$/ ;
      print "$iso2: '$country_name' No iso3 code\n"        if $iso3             =~ /^\-?$/ ;
      print "$iso2: '$country_name' No region code\n"      if $region_code      =~ /^\-?$/ ;
      print "$iso2: '$country_name' No north/south code\n" if $north_south_code =~ /^\-?$/ ;
      print "$iso2: '$country_name' No population\n"       if $population       =~ /^\-?$/ ;
      print "$iso2: '$country_name' No connected\n"        if $connected        =~ /^\-?$/ ;
    }
  }
  close CSV_GEOINFO ;
}

sub ReadGeoInfoWorldBank
{
  &LogSub ("ReadGeoInfoWorldBank\n") ;

  my $file_json_demographics = shift ;
  print "Read from '$file_json_demographics'\n";

  my $json_text_demographics = do
  {
    open (my $json_fh, "<:encoding(UTF-8)", $file_json_demographics) or die ("Can't open \$file_json_demographics\ $!\n");
    local $/;
    <$json_fh>
  };
  $json_text_demographics =~ s/[^\x00-\x7f]//g ; # drop 'wide characters'

  my $json = JSON->new ;
  my $data = $json->decode ($json_text_demographics) ;

  foreach my $iso2 (sort keys %{$data -> {'countries'}})
  { 
    next if $iso2 !~ /^[A-Z0-9]{2,2}$/ ; # invalid entries ? like '_ China', '_OSS', 'iso3166_1_a2' -> check&fix !!!

    $iso2_codes {$iso2} ++ ;
    $iso3_codes {$iso3} ++ ;

    my $country_name = $data -> {'countries'} {$iso2} {'names'} {'en'} ;
    $country_name =~ s/,/./g ; 
    if ((! defined $country_name) || ($country_name eq ''))
    { print "Name missing for iso2 $iso2\n" ; next ; }

  # $population_worldbank     {$country_name} = $data -> {'countries'} {$iso2} {'years'} {'latest'} {'population'} ;
  # $connected_perc_worldbank {$country_name} = $data -> {'countries'} {$iso2} {'years'} {'latest'} {'internet users per 100'} ;
  # $connected_worldbank      {$country_name} = sprintf ("%.0f",($connected_perc_worldbank {$country_name} / 100) *
  #                                             $population_worldbank {$country_name}) ;

    $data_from_year_worldbank {$iso2} = $data -> {'countries'} {$iso2} {'years'} {'latest'} {'year'} ;
    $population_worldbank     {$iso2} = $data -> {'countries'} {$iso2} {'years'} {'latest'} {'population'} ;
    $connected_perc_worldbank {$iso2} = $data -> {'countries'} {$iso2} {'years'} {'latest'} {'internet users per 100'} ;
    $connected_worldbank      {$iso2} = sprintf ("%.0f",($connected_perc_worldbank {$iso2} / 100) *
                                                $population_worldbank {$iso2}) ;
   
  # if ($population_worldbank {$country_name} eq '')
  # { $population_worldbank {$country_name} = "--" ; }
  # if ($connected_worldbank  {$country_name} eq '')
  # { $connected_worldbank  {$country_name} = "--" ; }
  # if ($connected_perc_worldbank  {$country_name} eq '')
  # { $connected_perc_worldbank {$country_name} = "--" ; }

    if ($population_worldbank {$iso2} eq '')
    { $population_worldbank {$iso2} = "--" ; }
    if ($connected_worldbank  {$iso2} eq '')
    { $connected_worldbank  {$iso2} = "--" ; }
    if ($connected_perc_worldbank  {$iso2} eq '')
    { $connected_perc_worldbank {$iso2} = "--" ; }

  # my $line = "$iso2: '$country_name': " . "pop. " . $population_worldbank     {$country_name} . ", " . 
  #                                         "conn. " . $connected_worldbank      {$country_name} . " = " . 
  #                                         $connected_perc_worldbank {$country_name} . "%\n"; # debug only
  
    my $line = "$iso2: '$country_name': " . "pop. " . $population_worldbank     {$iso2} . ", " . 
                                            "conn. " . $connected_worldbank      {$iso2} . " = " . 
                                            $connected_perc_worldbank {$iso2} . "%\n"; # debug only

    print $line if $line =~ /\-\-/ or $line =~ / 0 / or $line =~/0\.0/ ; # debug only
  }
}

# combine meta data from local file (article url, flag icon) with data from worldbank (population, connected)
sub MergeMetaInfo
{
  &LogSub ("MergeMetaInfo\n") ;

  my ($iso2, $country_name, $country_meta_info) ;

  # Wikipedia dempgraphics originally come from 
  # http://en.wikipedia.org/wiki/List_of_countries_by_population
  # http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users

  # Show differences between figures from Wikipedia and from World Bank (population and perc connected)
  open DIFF,'>',"$path_meta/DifferenceWikipediaWorldBank.csv" ;  

  $line = "iso2,country name,pop. wikipedia,pop. world bank,pop. % diff,,conn. wikipedia,conn. perc. wikipedia,conn. world bank,conn. perc. worldbank,conn. % diff,,worldbank data for year\n";  

  print DIFF $line ;
  print      $line ;

# foreach $iso2 (sort keys %country_names)
  foreach $iso2 (sort keys %iso2_codes)
  {
    $country_name = $country_names {$iso2} ;
  # $country_meta_info = $country_meta_info {$country_name} ;
    $country_meta_info = $country_meta_info {$iso2} ;

    if ($country_meta_info eq '') 
    { 
      $no_meta_info .= "$iso2,";
      next ;
    }

    ($article_url,$icon,$population_wikipedia,$connected_wikipedia) = split (',', $country_meta_info) ;
print "1 icon $icon\n" if $icon =~ /src.*img/ ; 



    $connected_wikipedia =~ s/\-/--/g ;

    # 2018 June
    # from now on use json file with world bank data for population and %connected (=internet users per 100)

  # $icon = "<img src='$icon_url' width=$icon_width height=$icon_height border=1>" ;

    $population_wikipedia =~ s/\_//g ; # remove interpunction
    $connected_wikipedia  =~ s/\_//g ;

  # my $population_worldbank = $population_worldbank {$country_name} ;
  # my $connected_worldbank  = $connected_worldbank  {$country_name} ;
    
    my $population_worldbank     = $population_worldbank {$iso2} ;
    my $connected_worldbank      = $connected_worldbank  {$iso2} ;
    my $data_from_year_worldbank = $data_from_year_worldbank {$iso2} ; 
    
    my $population = $population_wikipedia ;
    my $connected  = $connected_wikipedia ;

    my $diff_perc_population = '--';    
    my $diff_perc_connected  = '--';    

    if ($population_worldbank > 0)
    { $diff_perc_population = sprintf ("%.1f", 100 * $population_wikipedia / $population_worldbank) ; }

    if ($connected_worldbank > 0)
    { $diff_perc_connected  = sprintf ("%.1f", 100 * $connected_wikipedia / $connected_worldbank) ; }

    $connected_perc_wikipedia = $connected_perc_wikipedia {$iso2} ;
    $connected_perc_worldbank = $connected_perc_worldbank {$iso2} ;

    my $line = "$iso2,$country_name,$population_wikipedia,$population_worldbank,$diff_perc_population\%,," . 
               "$connected_wikipedia,$connected_perc_wikipedia,$connected_worldbank,$connected_perc_worldbank,$diff_perc_connected\%,,$data_from_year_worldbank\n" ;

    # $line = "$iso2,$population_wikipedia,$population_worldbank,$diff_perc_population\n" ; # debug
    # $line = "$iso2,$connected_wikipedia,$connected_worldbank,$diff_perc_connected\n" ;    # debug

    print DIFF $line ;
    print      $line ;

  # $country_meta_info {$country_name} = "$article_url,$icon,$population,$connected" ;
    $country_meta_info {$iso2}         = "$article_url,$icon,$population,$connected" ;

print "2 icon $icon\n" if $icon =~ /src.*img/ ; 

  # AddCountryAlias ($country_name,$article_url,$icon,$population,$connected) ; # no longer needed ?
  }

  close DIFF ;

  # &ValidateCountryNames ; # obsolete ?

  if ($ip_connections_unknown ne '')
  {
    $ip_connections_unknown =~ s/,\s*$// ;
    &LogDetail ("\n\nip connections unknown for:\n$ip_connections_unknown\n\n") ;
  }

  &LogDetail ("\nNo meta info in \$country_meta_info for iso2 codes:\n$no_meta_info\n\n") ;

  if ($iso3_code_unknown ne '')
  {
    $iso3_code_unknown =~ s/,\s*$// ;
    &LogDetail ("\nNo iso3 code for:\n$iso3_code_unknown\n\n") ;
  }
}

# replaced by MergeMetaInfo
# sub ReadInputCountryInfo
# {
#   &LogSub ("\&ReadInputCountryInfo\n") ;
# 
#   # http://en.wikipedia.org/wiki/List_of_countries_by_population
#   # http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users
#
#   my @csv = &ReadCsv ("$path_meta/CountryInfo.csv") ;
#
#   open PERC,'>',"$path_meta/DifferenceWikipediaWorldBank.csv" ;  
#   print PERC "country,pop. wikipedia,pop. world bank, pop. diff,,connected wikipedia,connected world bank,connected diff\n";  
#
#   foreach $line (@csv)
#   {
#     chomp $line ;
#     $line =~ s/[\x00-\x1f]//g ;
#
#     my ($country,$population_wikipedia,$connected_wikipedia,$article_url,$icon_url,$icon_width,$icon_height) = split ',', $line ;
#   # $icon =~ s/\/\/upload.wikimedia.org\/wikipedia\/commons\/thumb///upload.wikimedia.org/wikipedia/commons/thumb/g ;
#   # $icon =~ s/\/\/upload.wikimedia.org\/wikipedia\/en\/thumb///upload.wikimedia.org/wikipedia/en/thumb/g ;
#
#     $country =~ s/\%2C/,/g ;
#
#     if ($connected_wikipedia eq '-')
#     { 
#       $ip_connections_unknown .= "* $country\n" ; 
#       # print "internet connections unknown: $country\n" ; 
#     }
#
#     $connected_wikipedia =~ s/\-/--/g ;
#
#     # 2018 June
#     # from now on use json file with world bank data for population and %connected (=internet users per 100)
# 
#     $icon = "<img src='$icon_url' width=$icon_width height=$icon_height border=1>" ;
# 
#     $population_wikipedia =~ s/\_//g ; # remove interpunction
#     $connected_wikipedia  =~ s/\_//g ;
# 
#     my $population_worldbank = $population_worldbank {$country} ;
#     my $connected_worldbank  = $connected_worldbank  {$country} ;
#     
#     my $population = $population_wikipedia ;
#     my $connected  = $connected_wikipedia ;
# 
#     my $perc_population = '--';    
#     my $perc_connected  = '--';    
# 
#     if ($population_worldbank > 0)
#     { $perc_population = sprintf ("%.1f", 100 * $population_wikipedia / $population_worldbank) ; }
#     if ($connected_worldbank > 0)
#     { $perc_connected = sprintf ("%.1f", 100 * $connected_wikipedia / $connected_worldbank) ; }
#
#     print PERC "$country,$population_wikipedia,$population_worldbank,$perc_population\%,,$connected_wikipedia,$connected_worldbank,$perc_connected\%\n" ;
#     print "$country,$population_wikipedia,$population_worldbank,$perc_population\%,,$connected_wikipedia,$connected_worldbank,$perc_connected\%\n" ;
# 
#     $country_meta_info {$country} = "$article_url,$icon,$population,$connected" ;
#
#     AddCountryAlias ($country,$article_url,$icon,$population,$connected) ; # no longer needed ?
#   }
#   
#   close PERC ;
#
# # &ValidateCountryNames ; # obsolete ?
# 
#   if ($ip_connections_unknown ne '')
#   {
#     $ip_connections_unknown =~ s/,\s*$// ;
#     &LogDetail ("\n\nip connections unknown for:\n$ip_connections_unknown\n\n") ;
#   }
#
#   if ($iso3_code_unknown ne '')
#   {
#     $iso3_code_unknown =~ s/,\s*$// ;
#     &LogDetail ("\nno iso3 code for:\n$iso3_code_unknown\n\n") ;
#   }
# }

# no longer needed ?
sub AddCountryAlias
{
  return ;
  my ($country_name,$article_url,$icon,$population,$connected) = @_ ;

  my ($iso2,$iso3,$country_alias) ;
 
  # name on wiki page                  # name on datamaps viz.
     if ($country_name eq 'The Gambia')     { $country_alias = 'Gambia' ; }
  elsif ($country_name eq 'The Bahamas')    { $country_alias = 'Bahamas' ; }
  elsif ($country_name eq 'Samoa')          { $country_alias = 'American Samoa' ; }
  elsif ($country_name eq 'American Samoa') { $country_alias = 'Samoa' ; }
  elsif ($country_name eq 'American American Samoa')         { $country_alias = 'American Samoa' ; }
  elsif ($country_name eq 'East Timor')     { $country_alias = 'Timor-Leste' ; }
  elsif ($country_name eq 'Macau')          { $country_alias = 'Macao' ; }
  elsif ($country_name =~ '^R..?union')     { $country_alias = 'Reunion' ; }

  if ($country_alias ne '')
  { $country_meta_info {$country_alias} = "$article_url,$icon,$population,$connected" ; }
   
# $iso3 = $country_names_iso3 {$country_iso2_from_name {$country}} ;
  $iso3 = $country_iso3 {$country_iso2_from_name {$country}} ;

  if ($iso3 eq '')
  { 
    $iso3_code_unknown .= "* $country_name, " ; 
    # print "No ISO3 code for iso2 $iso2, country $country_name\n" ; 
  }

  if ($country eq "United States")
  { ($connected_us = $connected) =~ s/_//g  ; }
}

# sub ValidateCountryNames
# {
#   &LogSub ("ValidateCountryNames\n") ;
# 
#   &LogDetail ("Compare country names in two hash arrays:\n\n") ;
#   &LogDetail ("Countries in \%country_names_found not found in \%country_meta_info:\n\n") ;
# 
#   &LogBreak ;
#   foreach $country (sort keys %country_names_found)
#   {
#     if ($country_meta_info {$country} eq '')
#     { &LogList ("$country\n") ; }
#   }
#   &LogBreak ;
# 
#   &LogDetail ("Countries in \%country_meta_info not found in \%country_names_found:\n\n") ;
#   &LogBreak ;
#   foreach $country (sort keys %country_meta_info)
#   {
#     if ($country_names_found {$country} eq '')
#     { &LogList ("$country\n") ; }
#   }
#   &LogBreak ;
# }

sub CollectRegionCounts
{
  &LogSub ("CollectRegionCounts\n") ;

# my ($country_code, $region_code, $north_south_code, $country_name) ;
  my ($iso2, $region_code, $north_south_code, $country_name) ;
# foreach $country_code (keys %country_names)
  foreach $iso2 (sort keys %iso2_codes)
  {
  # $country_name = $country_names {$country_code} ;
  # $country_meta = $country_meta_info {$country_name} ;

    $country_name = $country_names {$iso2} ;
    $country_meta = $country_meta_info {$iso2} ;

    next if $link =~ /^\*$/ ;
    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;

  # debug only:
  # &LogList ("code $country_code\n") ;
  # &LogList ("name $country_name\n") ;
  # &LogList ("meta $country_meta\n") ;

  # $region_code      = $region_codes      {$country_code} ;
  # $north_south_code = $north_south_codes {$country_code} ;
    $region_code      = $region_codes      {$iso2} ;
    $north_south_code = $north_south_codes {$iso2} ;

    $population =~ s/_//g ;
    $connected  =~ s/_//g ;

    $population_tot += $population ;
    $connected_tot  += $connected ;

    $population_per_region {$region_code}      += $population ;
    $connected_per_region  {$region_code}      += $connected ;

    $population_per_region {$north_south_code} += $population ;
    $connected_per_region  {$north_south_code} += $connected ;

    ## print "CODE $country_code NAME $country_name POP $population, $CONN $connected REGION $region_code NS $north_south_code PPR ${population_per_region {$region_code}}\n" ;
    # print "CODE $iso2 NAME $country_name POP $population, $CONN $connected REGION $region_code NS $north_south_code PPR ${population_per_region {$region_code}}\n" ;
  }

  if ($population_tot == 0)
  { print "No valid data found: population_tot = 0 for country $country_code = $country_name!\n" ; }
}

sub ReadInputCountriesMonthly
{
  &LogSub ("ReadInputCountriesMonthly\n") ;

  my $project_mode = shift ;

  undef %yyyymm_ ;
  undef %quarters ;
  undef %requests_unknown_per_quarter ;
# undef %country_codes ;
  undef %requests_all ;
  undef %requests_all_per_period ;
  undef %requests_per_quarter ;
  undef %requests_per_country ;
  undef %requests_per_quarter_per_country ;
  undef %requests_per_country_per_language ;
  undef %requests_per_language_per_country ;
  undef %requests_per_quarter_per_country_per_language ;
  undef %requests_per_month_per_country_code ;
  undef %requests_per_month_us ;
  undef %descriptions_per_period ;
  undef %requests_recently_all ;
  undef %requests_recently_per_country_code ;
  undef %requests_recently_per_country ;
  undef %requests_recently_per_country_per_language ;
  undef %requests_recently_per_language_per_country ;
  undef %requests_recently_per_language ;
  undef %months_recently ;

  $requests_recently_start = "999999" ;
  $requests_recently_stop  = "000000" ;
  $requests_start          = "999999" ;
  $requests_stop           = "000000" ;

  $requests_all            = 0 ;
  $requests_recently_all   = 0 ;

  # global reportmonth and local report_month is a bit confusing, to be fixed
  if ($reportmonth ne '')
  {
    &LogDetail ("Month $reportmonth specified as cmd line argument\n") ;
    $report_year  = substr ($reportmonth,0,4) ;	  
    $report_month = substr ($reportmonth,5,2) ;	  
  }
  else
  {
    my ($sec,$min,$hour,$day,$report_month,$report_year) = localtime (time) ;
    $report_year  += 1900 ;
  # $report_month ++ ;
    if ($report_month == 0) # EZ 10/2012 report till end of last month
    {
      $report_month = 12 ;
      $report_year-- ;
    }
  }   

  &LogDetail ("Read monthly data (year $report_year, month $report_month) for project $project_mode (wp=Wikipedia, etc) from $path_csv_counts_monthly\n") ;

  $date_first = '9999-99' ;
  $date_last  = '0000-00' ;

  $invalid_country_codes = 0 ;
  $discarded_input = 0 ;

  my $lines = 0 ;
  &LogBreak ;
  &Log ("read from '$path_csv_counts_monthly'\n") ;

  open CSV_IN, '<', $path_csv_counts_monthly ;
  while ($line = <CSV_IN>)
  {
    $lines++ ;
    if ($lines % 200000 == 0)
    { &LogList ("lines: $lines\n") ; }

    chomp $line ;
    $line =~ s/,\s+/,/g ;
    $line =~ s/\s+,/,/g ;
    ($yyyymm,$project,$language,$code,$bot,$count) = split (',', $line) ;

    ($code,$language) = &NormalizeLanguageCodes ($code,$language) ;

    # next if $country =~ /\?/ ;
    next if &DiscardInput ($bot,$project,$project_mode,$code,$language) ;

    $country = &GetCountryName ($code) ;
    if ($country =~ /invalid/) # frequent parsing error in earlier years
    {
      $reason_discard {'$country =~ /invalid/'} ++ ;
      $discarded_input ++ ;
      next ;
    }

  #  $yyyymm = "2009-12" ;
    $yyyymm_ {$yyyymm} ++ ;

    $year    = substr ($yyyymm,0,4) ;
    $month   = substr ($yyyymm,5,2) ;

    $recently = $false ;

       if ($month <= 3) { $quarter = $year . ' Q1' ; }
    elsif ($month <= 6) { $quarter = $year . ' Q2' ; }
    elsif ($month <= 9) { $quarter = $year . ' Q3' ; }
    else                { $quarter = $year . ' Q4' ; }

    if ($quarter_only ne '')
    {
      next if $quarter ne $quarter_only ;
      $recently = $true ;
      $recently_desc = $quarter_only ;
    }
    else
    {
    # Dec 2013: quarterly report used to be avg monthly counts for last full 12 months, now it is data for one month 	    
    # if ((($year == $report_year) && ($month <= $report_month)) or # EZ 10/2012, skip current month
    #     (($year == $report_year - 1) && ($month > $report_month)))
      if (($year == $report_year) && ($month == $report_month))
      { 
        $recently = $true ; 
        $recently_desc = "$year-$month" ;
      }
      else
      { next ; }
      # if ($lines % 1000 == 0) # debug only
      # {  print "year $year, month $month, report_year $report_year, report_month $report_month\n" ; }	    
    }
    $lines_selected ++ ;

    # if ($views_edits eq 'Page Edits')

    $quarters {$quarter} ++ ;

# parse country data # qqq 

    if (($country =~ /\?/) || ($country =~ /unknown/i))
    { $requests_unknown_per_quarter {$quarter} += $count ; }

    $country_codes {"$country|$code"}++ ;
    $requests_all                                                                     += $count ;
    $requests_all_per_period                       {$yyyymm}                          += $count ;
    $requests_per_quarter                          {$quarter}                         += $count ;
    $requests_per_country                                     {$country}              += $count ;

    $requests_per_quarter_per_country              {$quarter} {$country}              += $count ;
    $requests_per_country_per_language                        {$country}  {$language} += $count ;
    $requests_per_language_per_country                        {$language} {$country}  += $count ;
    $requests_per_quarter_per_country_per_language {$quarter} {$country}  {$language} += $count ;
    $requests_per_month_per_country_code           {$yyyymm}  {"$country|$code"}      += $count ;

    if ($code eq "US")
    {$requests_per_month_us                        {$yyyymm}                          += $count ; }

    $descriptions_per_period {$yyyymm} = $yyyymm ;
    if ($yyyymm lt $requests_start) { $requests_start = $yyyymm ; }
    if ($yyyymm gt $requests_stop)  { $requests_stop  = $yyyymm ; }

    if ($yyyymm lt $date_first)
    { $date_first = $yyyymm ; }
    if ($yyyymm gt $date_last)
    { $date_last = $yyyymm ; }

    if ($recently)
    {
      if ($yyyymm lt $requests_recently_start) { $requests_recently_start = $yyyymm ; }
      if ($yyyymm gt $requests_recently_stop)  { $requests_recently_stop  = $yyyymm ; }

      $months_recently {$yyyymm}++ ;
      $requests_recently_all                                                         += $count ;
      $requests_recently_per_country_code                    {"$country|$code"}      += $count ;
      $requests_recently_per_country                         {$country}              += $count ;
      $requests_recently_per_country_per_language            {$country}  {$language} += $count ;
      $requests_recently_per_language_per_country            {$language} {$country}  += $count ;
      $requests_recently_per_language                        {$language}             += $count ;
    }
  }
  close CSV_IN ;

  if ($lines_selected == 0)
  { abort ("No lines selected from $path_csv_counts_monthly.\nRun step 'collect_country_stats' to add data for requested month.") ; }

  if ($lines > 0)
  {
    $perc_invalid_country_codes = sprintf ("%.1f", 100 * $invalid_country_codes / $lines) ;
    $perc_discarded_input       = sprintf ("%.1f", 100 * $discarded_input / $lines) ;
  }
  &LogList ("lines: $lines invalid country codes: $invalid_country_codes ($perc_invalid_country_codes\%), " . 
            "discard input: $discarded_input ($perc_discarded_input\%)\n") ;


  &LogList ("\nReasons for discarding input:\n") ;
  foreach $key (sort keys %reason_discard)
  { &LogList (sprintf ("%8s", $reason_discard {$key}) . ": $key\n") ; }

  &LogList ("\nTop 10 most found invalid country codes:\n") ;
  $codes_reported = 0 ;
  foreach $code (sort {$country_code_not_specified_reported {$b} <=> $country_code_not_specified_reported {$a}} keys %country_code_not_specified_reported)
  {
    &LogList ("Code $code: ${country_code_not_specified_reported {$code}}\n") ;
    last if $codes_reported++ == 10 ;
  }
  &LogBreak () ;
  &LogDetail ((0 + $lines) . " lines read from '$path_csv_counts_monthly'\n") ;

  if ($lines == 0)
  { abort ("No lines read from '$path_csv_counts_monthly'\n") ; }

  @quarters = keys_sorted_alpha_asc %quarters ;
  &LogBreak ;
  foreach $quarter (@quarters)
  {
    my $quarter2 = substr ($quarter,0,4) . 'q' . substr ($quarter,4,1) ;
    &LogList ("quarter $quarter: requests: " . (0+$requests_per_quarter {$quarter}) . "\n") ;

    if ($requests_per_quarter {$quarter} == 0)
    { abort ("No known requests found for quarter $quarter") ; }
  }
  &LogBreak ;

  $months_recently = keys %months_recently ;

  $requests_recently_start = substr ($requests_recently_start,0,4) . '/' . substr ($requests_recently_start,5,2);
  $requests_recently_stop  = substr ($requests_recently_stop ,0,4) . '/' . substr ($requests_recently_stop ,5,2) ;
  $requests_start          = substr ($requests_start,0,4)          . '/' . substr ($requests_start,5,2) ;
  $requests_stop           = substr ($requests_stop ,0,4)          . '/' . substr ($requests_stop ,5,2) ;

  foreach $yyyymm (keys %$yyyymm)
  {
    if ($requests_per_month_us {$week} > $max_requests_per_month_us)
    { $max_requests_per_month_us = $requests_per_month_us {$week} ; }
  }

  if ($connected_us > 0)
  { $max_requests_per_connected_us_month = sprintf ("%.1f", $max_requests_per_month_us / $connected_us) ; }
}

sub NormalizeLanguageCodes
{
  # &LogSub ("NormalizeLanguageCodes\n") ;

  my ($code,$language) = @_ ;

  if ($language eq "jp") { $language = "ja" ; }
  if ($language eq "cz") { $language = "cs" ; }

  # following are part of France, according to Wikipedia, List_of_countries_by_population
  if ($code eq 'BL') { $code = 'FR' ; } # Saint Barthélemy
  if ($code eq 'MF') { $code = 'FR' ; } # Saint Martin
  if ($code eq 'MQ') { $code = 'FR' ; } # Martinique
  if ($code eq 'NC') { $code = 'FR' ; } # New Caledonia
  if ($code eq 'PF') { $code = 'FR' ; } # French Polynesia
  if ($code eq 'PM') { $code = 'FR' ; } # Saint Pierre and Miquelon
  if ($code eq 'WF') { $code = 'FR' ; } # Wallis and Futuna
  if ($code eq 'YT') { $code = 'FR' ; } # Mayotte

  return ($code,$language) ;
}

sub DiscardInput
{
  # &LogSub ("DiscardInput\n") ;

  my ($bot,$project,$project_mode,$code,$language) = @_ ;

  $project =~ s/[^a-z\-\_]//g ; # remove %@ encoding for mobile etc
# print "$bot,$project,$project_mode,$code,$language\n" ;

  if ($bot ne "U") 
  {
    $reason_discard {"field bot not 'U' for 'user'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($project ne $project_mode)
  {
    $reason_discard {"project ne '$project_mode'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($language eq 'upload')
  {
    $reason_discard {"language eq 'upload'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($language =~ /mobile/i)
  {
    $reason_discard {"language =~ 'mobile'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($code =~ /deflate|520-18|sdch/)
  {
    $reason_discard {'$code =~ /deflate|520-18|sdch/'} ++ ;
    $discarded_input ++ ;
    return true ;
  }
   # $code eq "A1" or # Anonymous Proxy
   # $code eq "A2" or # Satellite Provider
   # $code eq "AP" or # Asia/Pacific Region
   # $code eq "EU")   # Europe

  return ($false) ;
}

sub GetCountryName
{
  my $code = shift ;
  if ($country_names {$code} eq "")
  {
    if ($code =~ /(?:=|Mozilla)/) # known frequent parsing error in earlier years, do not report
    { return ('country name invalid') ; }

    $country = "?? (code $code)" ;
    if ($country_code_not_specified_reported {$code}++ == 0)  
    { &LogList ("country name not specified for iso2 $code\n") ; }

    $invalid_country_codes++ ;
  }
  else
  { $country = $country_names {$code} ; }

  return ($country) ;
}

sub CorrectForMissingDays
{
  my ($period, $count, $code, $var) = @_ ;

  if ($missing_days {$period} > 0)
  {
    my $count_prev = $count ;
    $count = int (0.5 + $count * $correct_for_missing_days {$period}) ;
    if ($code =~ /us/i)
    { print "\nperiod $period: correct for ${missing_days {$period}} missing days = * ${correct_for_missing_days {$period}}, " .
            " e.g. for $code: $var $count_prev -> $count\n\n" ; }
  }
  return ($count) ;
}

sub Normalize
{
  my $count = shift ;
  $count *= $multiplier ;
# if ($count < 1) { $count = 1 ; } -> do this at FormatCount
  return (sprintf ("%.2f", $count)) ;
}

sub ReadLanguageInfo
{
  &LogSub ("ReadLanguageInfo\n") ;

  my @csv = &ReadCsv ("$path_meta/LanguageInfo.csv") ;

  foreach $line (@csv)
  {
    next if $line =~ /^#/ ; # comments
    next if $line !~ /,/ ;

    chomp $line ;
    $line =~ s/ /\&nbsp;/g ;

    ($lang_code,$name,$url,$speakers,$regions,$comment) = split (',', $line) ;

    $out_urls      {$lang_code} = $url ;
    $out_languages {$lang_code} = $name ;
    $out_article   {$lang_code} = "://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
    $out_article   {$lang_code} =~ s/ /_/g ;
    $out_speakers  {$lang_code} = $speakers ;
    $out_regions   {$lang_code} = $regions ;
  }

  $out_languages {"www"} = "Portal" ;
}

sub GetLanguageInfo
{
  my $language = shift ;
  my ($language_name,$anchor_language) ;
  $language_name = "$language (?)" ;
  if ($out_languages {$language} ne "")
  { $language_name = $out_languages {$language} ; }
  ($anchor_language = $language_name) =~ s/ /_/g ;
  return ($language_name,$anchor_language) ;
}
 
# previously called with country name, now with iso2 code 
# (but cater for old invocation until all code is migrated)
sub CountryMetaInfo
{
  my $country = shift ;

  my ($link_country,$icon,$population,$iso2) ;

  if (length ($country) > 2)
  { 
    $country =~ s/"//g ;
    $iso2 = $country_iso2_from_name {$country} ;
  }
  else 
  { $iso2 = $country ; }

# if ($country_meta_info {$country}  eq "")
  if ($country_meta_info {$iso2}  eq "")
  {
  # $country_meta_info_not_found_reported {$country} ++ ;
  # if ($country_meta_info_not_found_reported {$country} == 1)
  # { &LogDetail ("Meta info not found for country $country\n") ; }
  
    $country_meta_info_not_found_reported {$iso2} ++ ;
    if ($country_meta_info_not_found_reported {$iso2} == 1)
    { &LogDetail ("Meta info not found for iso2 code $iso2\n") ; }
    $country = $country_names {$iso2} ; 
    return ($country,'','--','--') ;
  }
  else
  {
  # ($link_country,$icon,$population,$connected) = split ',', $country_meta_info {$country} ;
    ($link_country,$icon,$population,$connected) = split ',', $country_meta_info {$iso2} ;

    $population =~ s/_//g ;
    $connected =~ s/_//g ;
 
    $link_country =~ s/\%2C/,/g ;
    $link_country =~ s/_/ /g ;
    $link_country = "<a href='http://en.wikipedia.org/wiki/$link_country'>$link_country</a>" ; 

    $icon         =~ s/\%2C/,/g ;

    return ($link_country,$icon,$population,$connected) ;
  }
}

1 ;
