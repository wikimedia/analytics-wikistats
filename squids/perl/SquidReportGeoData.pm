  &SetRegionNames ;

sub ReadCountryNames
{
  ($file_csv_country_codes) = @_ ;
  print "ReadCountryNames from $file_csv_country_codes\n" ;
  if (! -e $file_csv_country_codes) { abort ("Input file $file_csv_country_codes not found!") ; }

  open    CSV_COUNTRY_CODES, '<', $file_csv_country_codes ;
  binmode CSV_COUNTRY_CODES ;

  $country_names {"--"} = "Unknown" ;
  while ($line = <CSV_COUNTRY_CODES>)
  {
    chomp $line ;

    next if $line =~ /^#/ ;

    $line =~ s/\"//g ;

    $line =~ s/[\x00-\x1f]//g ;
    $line =~ s/UNDEFINED/Undefined/g ;
    $line =~ s/territories/Territories/ ;
    $line =~ s/(Falkland Islands).*$/$1/g ; # - (Malvinas)
    $line =~ s/Reunion/Réunion/ ;
    $line =~ s/Aland Islands/Åland Islands/ ;
    $line =~ s/Bonaire, Saint Eustatius and Saba/Caribbean Netherlands/ ;
    $line =~ s/Congo, The Democratic Republic of the/Congo Dem. Rep./ ;
    $line =~ s/Congo$/Congo Rep./ ;
    $line =~ s/Curacao/Curaçao/ ;
    $line =~ s/Brunei Darussalam/Brunei/ ;
    $line =~ s/Holy See.*$/Vatican City/ ;
    $line =~ s/Iran, Islamic Republic of/Iran/ ;
    $line =~ s/Korea, Democratic People's Republic of/North Korea/ ;
    $line =~ s/Korea, Republic of/South Korea/ ;
    $line =~ s/Lao People's Democratic Republic/Laos/ ;
    $line =~ s/Libyan Arab Jamahiriya/Libya/ ;
    $line =~ s/Micronesia, Federated States of/Micronesia/ ;
    $line =~ s/Moldova, Republic of/Moldova/ ;
    $line =~ s/Palestinian Territory/Palestinian Territories/ ;
    $line =~ s/Pitcairn/Pitcairn Islands/ ;
    $line =~ s/Russian Federation/Russia/ ;
    $line =~ s/American American Samoa/American Samoa/ ;
    $line =~ s/Saint Bartelemey/Saint Barthélemy/ ;
    $line =~ s/Sao Tome and Principe/São Tomé and Príncipe/ ;
    $line =~ s/Syrian Arab Republic/Syria/ ;
    $line =~ s/Tanzania, United Republic of/Tanzania/ ;
    $line =~ s/Virgin Islands, British/Virgin Islands, UK/ ;
    $line =~ s/Virgin Islands, U.S./Virgin Islands, US/ ;

    # ($country_code,$region_code,$north_south_code,$country_name) = split (',', $line,4) ;
    ($country_code,$country_name) = split (',', $line,2) ;

    $country_name =~ s/"//g ;

    next if $country_name eq "Anonymous Proxy" ;
    next if $country_name eq "Satellite Provider" ;
    next if $country_name eq "Other Country" ;
    next if $country_name eq "Asia/Pacific Region" ;
    next if $country_name eq "Europe" ;

#    if ($country_meta_info {$country}  eq "")
#    {
#      if ($country_meta_info_not_found_reported {$country} ++ == 0)
#      { print "Meta info not found for country '$country'\n" ; }
#    }

    $country_names_found {$country_name} ++ ;
    $country_names       {$country_code} = $country_name ;
    $country_codes_all   {"$country_name|$country_code"} ++ ;
  }

  close CSV_COUNTRY_CODES ;
}

sub ReadRegionCodes
{
  ($file_csv_region_codes) = @_ ;
  print "ReadRegionCodes from $file_csv_region_codes\n" ;
  if (! -e $file_csv_region_codes) { abort ("Input file $file_csv_region_codes not found!") ; }

  open    CSV_REGION_CODES, '<', $file_csv_region_codes ;
  binmode CSV_REGION_CODES ;

  while ($line = <CSV_REGION_CODES>)
  {
    chomp $line ;

    next if $line =~ /^#/ ;

    ($country_code,$region_code,$north_south_code) = split (',', $line) ;
    $region_codes      {$country_code} = $region_code ;
    $north_south_codes {$country_code} = $north_south_code ;

       if ($north_south_code eq 'N') { $country_codes_N {$country_code} ++ ; }
    elsif ($north_south_code eq 'S') { $country_codes_S {$country_code} ++ ; }
    else                             { $country_codes_U {$country_code} ++ ; }


    $country_name = $country_names {$country_code} ;

       if ($north_south_code eq 'N') { $country_names_N {$country_name} ++ ; }
    elsif ($north_south_code eq 'S') { $country_names_S {$country_name} ++ ; }
    else                             { $country_names_U {$country_name} ++ ; }
  }

  close CSV_REGION_CODES ;
}

sub ReadCountryMetaData
{
  ($file_csv_country_metadata) = @_ ;
  print "ReadCountryNames from $file_csv_country_metadata\n" ;
  if (! -e $file_csv_country_metadata) { abort ("Input file $file_csv_country_metadata not found!") ; }

  # http://en.wikipedia.org/wiki/List_of_countries_by_population
  # http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users

  open    COUNTRY_META_INFO, '<', "$file_csv_country_metadata" ;
  binmode COUNTRY_META_INFO ;

  while ($line = <COUNTRY_META_INFO>)
  {
    chomp $line ;
    $line =~ s/[\x00-\x1f]//g ;

    ($country,$link,$population,$connected,$icon) = split ',', $line ;
    # print "COUNTRY $country\nLINK $link\nPOPULATION $population\nCONNECTED $connected\n\n" ;
    $country =~ s/&comma;/,/g ;

    $country =~ s/territories/Territories/ ;
    $country =~ s/American American Samoa/American Samoa/ ;
    $country =~ s/C..?te d'Ivoire/Cote d'Ivoire/g ;
    $country =~ s/Democratic Republic of the Congo/Congo Dem. Rep./ ;
    $country =~ s/^Republic of the Congo/Congo Rep./ ;
    $country =~ s/East timor/Timor-Leste/ ;
    $country =~ s/Guyane/French Guiana/ ;
    $country =~ s/Ivory Coast/Cote d'Ivoire/ ;
    $country =~ s/^.*Micronesia/Micronesia/ ; # - Federated States of
    $country =~ s/Macau/Macao/ ;
    $country =~ s/Saint Helena.*$/Saint Helena/ ;  # - , Ascension and Tristan da Cunha
    $country =~ s/United States Virgin Islands/Virgin Islands, US/ ;
    $country =~ s/British Virgin Islands/Virgin Islands, UK/ ;

    if ($connected eq 'connected')
    { $ip_connections_unknown .= "$country, " ; }

    $connected =~ s/connected/../g ;

    $country_meta_info {$country} = "$link,$population,$connected,$icon" ;
    if ($country eq "United States")
    { ($connected_us = $connected) =~ s/_//g  ; }
  }

  close COUNTRY_META_INFO ;

  if ($ip_connections_unknown ne '')
  {
    $ip_connections_unknown =~ s/, $// ;
    &Log ("\nIP connections unknown for:\n$ip_connections_unknown\n\n") ;
  }

  &ValidateCountryNames ;
}

sub ValidateCountryNames
{
  print "ValidateCountryNames\n" ;

  print "\nCompare country names in two hash arrays:\n" ;
  print "\nCountries in \%country_names_found not found in \%country_meta_info:\n\n" ;
  foreach $country (sort keys %country_names_found)
  {
    if ($country_meta_info {$country} eq '')
    { print "$country\n" ; }
  }

  print "\n\nCountries in \%country_meta_info not found in \%country_names_found:\n\n" ;
  foreach $country (sort keys %country_meta_info)
  {
    if ($country_names_found {$country} eq '')
    { print "$country\n" ; }
  }
  print "\n" ;
}

sub PrintListOfGlobalNorthSouth
{
  print "\nGlobal North countries:\n\n" ;
  foreach $country (sort keys %country_names_N)
  {
    if (length ($line) > 80) { print "$line\n" ; $line = '' ; }
    $line .= "$country, " ;
    $line_global_N .= "$country|" ;
  }
  $line =~ s/,\s*$// ;
  $line_global_N =~ s/\|\s*$// ;
  $line_global_N =~ s/,/;/g ;
  print $line ;

  $line = '' ;
  print "\n\nGlobal South countries:\n\n" ;
  foreach $country (sort keys %country_names_S)
  {
    if (length ($line) > 80) { print "$line\n" ; $line = '' ; }
    $line .= "$country, " ;
    $line_global_S .= "$country|" ;
  }
  $line =~ s/,\s*$// ;
  $line_global_S =~ s/\|\s*$// ;
  $line_global_S =~ s/,/;/g ;
  print $line ;

  $line = '' ;
  print "\n\nUnclassified countries:\n\n" ;
  foreach $country (sort keys %country_names_U)
  {
    if (length ($line) > 80) { print "$line\n" ; $line = '' ; }
    $line .= "$country, " ;
    $line_global_U .= "$country|" ;
  }
  $line =~ s/,\s*$// ;
  $line_global_U =~ s/\|\s*$// ;
  $line_global_U =~ s/,/;/g ;
  print $line ;

  print "\n\n" ;
}

sub RegionName
{
  my ($code) = @_ ;
  my $name = $region_names {$code} ;

  if ($name eq '')
  { $name = "Other ($code)" ; }

  return $name ;
}

sub SetRegionNames
{
  %region_names =
  (
  N=>"North",
  S=>"South",
  U=>"Unknown",
  AF=>"Africa",
  AS=>"Asia",
  AU=>"Australia",
  CA=>"Central America",
  EU=>"Europe",
  NA=>"North America",
  OC=>"Oceania",
  SA=>"South America"
  ) ;
}

1 ;
