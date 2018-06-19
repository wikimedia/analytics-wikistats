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

sub ReadCountryCodes
{
  &LogSub ("ReadCountryCodes\n") ;

  my @csv = ReadCsv ("$path_meta/$file_csv_country_codes") ;

  foreach $line (@csv)
  {
    if ($line =~ /^[A-Z]/)
    {
      chomp ($line) ;
      ($code,$name) = split (',',$line,2) ;
      $country_codes {$code} = unicode_to_html ($name) ;
      # print "$code => $name\n" ;
    }
  }

  $country_codes {'-'}  = 'Unknown3' ;
  $country_codes {'--'} = 'Unknown4' ;
  $country_codes {'XX'} = 'Unknown5' ;
  $country_codes {'-P'} = 'IPv6' ;
  $country_codes {'-X'} = 'Unknown6' ;
  $country_codes {'AN'} = 'Netherlands Antilles' ; # not yet in MaxMind database
}

sub ReadCountryCodesISO3
{
  &LogSub ("ReadCountryCodesISO3\n") ;
  
  my @csv = &ReadCsv ("$path_meta/CountryCodesISO3.csv") ;

  foreach $line (@csv)
  {
    if ($line =~ /^[A-Z]/)
    {
      chomp ($line) ;
      ($code,$name) = split (',',$line,2) ;
      $name =~ s/"//g ;
      $country_codes_iso3 {$code} = $name ;
      $country_names_iso3 {$name} = $code ;
    # print "$code => $name\n" ;
    }
  }
}

sub AddExtraCountryNames_iso3
{ 
# add entries for country names spelled differently in $file_csv_country_codes 
  $country_names_iso3 {'Bolivia'}                 = 'BOL' ;
  $country_names_iso3 {'Brunei'}                  = 'BRN' ;
  $country_names_iso3 {'Burma'}                   = 'MMR' ;
  $country_names_iso3 {'Cape Verde'}              = 'CPV' ;
  $country_names_iso3 {'Caribbean Netherlands'}   = 'XXX' ;
  $country_names_iso3 {'Congo Dem. Rep.'}         = 'COD' ;
  $country_names_iso3 {'Congo Rep.'}              = 'COG' ;
  $country_names_iso3 {"Cote d'Ivoire"}           = 'CIV' ;
  $country_names_iso3 {'Falkland Islands'}        = 'FLK' ;
  $country_names_iso3 {'Iran'}                    = 'IRN' ;
  $country_names_iso3 {'Laos'}                    = 'LAO' ;
  $country_names_iso3 {'Macedonia'}               = 'MKD' ;
  $country_names_iso3 {'Micronesia'}              = 'FSM' ;
  $country_names_iso3 {'Moldova'}                 = 'MDA' ;
  $country_names_iso3 {'Palestinian Territories'} = 'PSE' ;
  $country_names_iso3 {'Russia'}                  = 'RUS' ;
  $country_names_iso3 {'Sint Maarten'}            = 'SXM' ;
  $country_names_iso3 {'South Korea'}             = 'KOR' ;
  $country_names_iso3 {'Syria'}                   = 'SYR' ;
  $country_names_iso3 {'São Tomé and Príncipe'}   = 'STP' ;
  $country_names_iso3 {'Taiwan'}                  = 'TWN' ;
  $country_names_iso3 {'Tanzania'}                = 'TZA' ;
  $country_names_iso3 {'United States'}           = 'USA' ;
  $country_names_iso3 {'Vatican City'}            = 'VAT' ;
  $country_names_iso3 {'Venezuela'}               = 'VEN' ;
  $country_names_iso3 {'Vietnam'}                 = 'VNM' ;
  $country_names_iso3 {'Virgin Islands, UK'}      = 'VGB' ;
  $country_names_iso3 {'Virgin Islands, US'}      = 'VIR' ;
}

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

sub ReadInputRegionCodes
{
  &LogSub ("ReadInputRegionCodes\n") ;

  my @csv = &ReadCsv ("$path_meta/RegionCodes.csv") ;

  foreach $line (@csv)
  {
    ($country_code,$region_code,$north_south_code) = split (',', $line) ;
    $region_codes      {$country_code} = $region_code ;
    $north_south_codes {$country_code} = $north_south_code ;
  }
}

sub ReadInputCountryNames
{
  &LogSub ("ReadInputCountryNames\n") ;

  my @csv = &ReadCsv ("$path_meta/CountryCodes.csv") ;

  $country_names {'-'}  = 'Unknown7' ;
  $country_names {'--'} = 'Unknown8' ;
  $country_names {'-P'} = 'IPv6' ;
  $country_names {'-X'} = 'Unknown9' ;
  $country_names {'AN'} = 'Netherlands Antilles' ; # not yet in MaxMind database
  $country_names {"XX"} = "Unknown10" ;

  foreach $line (@csv)
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
    $line =~ s/Myanmar/Burma/ ;
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

    # next if $country_name eq "Anonymous Proxy" ;
    # next if $country_name eq "Satellite Provider" ;
    # next if $country_name eq "Other Country" ;
    # next if $country_name eq "Asia/Pacific Region" ;
    # next if $country_name eq "Europe" ;

#    if ($country_meta_info {$country}  eq "")
#    {
#      if ($country_meta_info_not_found_reported {$country} ++ == 0)
#      { print "Meta info not found for country '$country'\n" ; }
#    }

    $country_names_found {$country_name} ++ ;
    $country_names       {$country_code} = $country_name ;
    $country_codes_all   {"$country_name|$country_code"} ++ ;
  }
}

sub ReadWorldBankDemographics
{
  my $file_json_demographics = shift ;
  print "\n\nReadWorldBankDemographics, read from \n$file_json_demographics\n\n";

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
    my $name = $data -> {'countries'} {$iso2} {'names'} {'en'} ;
    if ((! defined $name) || ($name eq ''))
    { print "Name missing for iso2 $iso2\n" ; next ; }

    $population     {$name} = $data -> {'countries'} {$iso2} {'years'} {'latest'} {'population'} ;
    $connected_perc {$name} = $data -> {'countries'} {$iso2} {'years'} {'latest'} {'internet users per 100'} ;
    $connected      {$name} = sprintf ("%.1f",($connected_perc {$name} / 100) * $population {$name}) ;
   
    print "$iso2: $name " . $population {$name} . ", " . $connected {$name} . "\n"; # debug only
  }
}


sub ReadInputCountryInfo
{
  &LogSub ("\&ReadInputCountryInfo\n") ;

  # http://en.wikipedia.org/wiki/List_of_countries_by_population
  # http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users

  my @csv = &ReadCsv ("$path_meta/CountryInfo.csv") ;
  open PERC,'>',"$path_meta/DifferenceWikipediaWorldBank.csv" ;  
  print PERC "country,pop. wikipedia,pop. world bank, pop. diff,,connected wikipedia,connected world bank,connected diff\n";  

  foreach $line (@csv)
  {
    chomp $line ;
    $line =~ s/[\x00-\x1f]//g ;

    my ($country,$population_wikipedia,$connected_wikipedia,$article_url,$icon_url,$icon_width,$icon_height) = split ',', $line ;
  # $icon =~ s/\/\/upload.wikimedia.org\/wikipedia\/commons\/thumb///upload.wikimedia.org/wikipedia/commons/thumb/g ;
  # $icon =~ s/\/\/upload.wikimedia.org\/wikipedia\/en\/thumb///upload.wikimedia.org/wikipedia/en/thumb/g ;

    $country =~ s/\%2C/,/g ;

    if ($connected_wikipedia eq '-')
    { 
      $ip_connections_unknown .= "$country, " ; 
      $ip_connections_unknown .= "$country, " ; 
      # print "internet connections unknown: $country\n" ; 
    }

    $connected_wikipedia =~ s/\-/../g ;

    # 2018 June
    # from now on use json file with world bank data for population and %connected (=internet users per 100)

    $icon = "<img src='$icon_url' width=$icon_width height=$icon_height border=1>" ;

    $population_wikipedia =~ s/\_//g ; # remove interpunction
    $connected_wikipedia  =~ s/\_//g ;

    my $population_world_bank = $population {$country} ;
    my $connected_world_bank  = $connected  {$country} ;
    
    my $population = $population_wikipedia ;
    my $connected  = $connected_wikipedia ;

    my $perc_population = '..';    
    my $perc_connected  = '..';    

    if ($population_world_bank > 0)
    { $perc_population = sprintf ("%.1f", 100 * $population_wikipedia / $population_world_bank) ; }
    if ($connected_world_bank > 0)
    { $perc_connected = sprintf ("%.1f", 100 * $connected_wikipedia / $connected_world_bank) ; }

    print PERC "$country,$population_wikipedia,$population_world_bank,$perc_population\%,,$connected_wikipedia,$connected_world_bank,$perc_connected\%\n" ;
    print "$country,$population_wikipedia,$population_world_bank,$perc_population\%,,$connected_wikipedia,$connected_world_bank,$perc_connected\%\n" ;

    $country_meta_info {$country} = "$article_url,$icon,$population,$connected" ;

    $country_alias = '' ;
 
    # name on wiki page                  # name on datamaps viz.
       if ($country eq 'The Gambia')     { $country_alias = 'Gambia' ; }
    elsif ($country eq 'The Bahamas')    { $country_alias = 'Bahamas' ; }
    elsif ($country eq 'Samoa')          { $country_alias = 'American Samoa' ; }
    elsif ($country eq 'American Samoa') { $country_alias = 'Samoa' ; }
    elsif ($country eq 'American American Samoa')         { $country_alias = 'American Samoa' ; }
    elsif ($country eq 'East Timor')     { $country_alias = 'Timor-Leste' ; }
    elsif ($country eq 'Macau')          { $country_alias = 'Macao' ; }
    elsif ($country =~ '^R..?union')     { $country_alias = 'Réunion' ; }

    if ($country_alias ne '')
    { $country_meta_info {$country_alias} = "$article_url,$icon,$population,$connected" ; }
   
    $code = $country_names_iso3 {$country} ;
    if ($code eq '')
    { 
      $iso3_code_unknown .= "$country, " ; 
      # print "No ISO3 code for country $country\n" ; 
    }

    if ($country eq "United States")
    { ($connected_us = $connected) =~ s/_//g  ; }
  }

  if ($ip_connections_unknown ne '')
  {
    $ip_connections_unknown =~ s/, $// ;
    &LogDetail ("\nip connections unknown for:\n$ip_connections_unknown\n\n") ;
  }

  if ($iso3_code_unknown ne '')
  {
    $iso3_code_unknown =~ s/, $// ;
    &LogDetail ("\nno iso3 code for:\n$iso3_code_unknown\n\n") ;
  }

  close PERC ;

  &ValidateCountryNames ;
}

sub ValidateCountryNames
{
  &LogSub ("ValidateCountryNames\n") ;

  &LogDetail ("Compare country names in two hash arrays:\n\n") ;
  &LogDetail ("Countries in \%country_names_found not found in \%country_meta_info:\n\n") ;

  &LogBreak ;
  foreach $country (sort keys %country_names_found)
  {
    if ($country_meta_info {$country} eq '')
    { &LogList ("$country\n") ; }
  }
  &LogBreak ;

  &LogDetail ("Countries in \%country_meta_info not found in \%country_names_found:\n\n") ;
  &LogBreak ;
  foreach $country (sort keys %country_meta_info)
  {
    if ($country_names_found {$country} eq '')
    { &LogList ("$country\n") ; }
  }
  &LogBreak ;
}

sub CollectRegionCounts
{
  &LogSub ("CollectRegionCounts\n") ;

  my ($country_code, $region_code, $north_south_code, $country_name) ;
  foreach $country_code (keys %country_names)
  {
    $country_name = $country_names {$country_code} ;
    $country_meta = $country_meta_info {$country_name} ;

    next if $link =~ /^\*$/ ;
    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;

  # debug only:
  # &LogList ("code $country_code\n") ;
  # &LogList ("name $country_name\n") ;
  # &LogList ("meta $country_meta\n") ;

    $region_code      = $region_codes      {$country_code} ;
    $north_south_code = $north_south_codes {$country_code} ;

    $population =~ s/_//g ;
    $connected  =~ s/_//g ;

    $population_tot += $population ;
    $connected_tot  += $connected ;

    $population_per_region {$region_code}      += $population ;
    $connected_per_region  {$region_code}      += $connected ;

    $population_per_region {$north_south_code} += $population ;
    $connected_per_region  {$north_south_code} += $connected ;

    # print "CODE $country_code NAME $country_name POP $population, $CONN $connected REGION $region_code NS $north_south_code PPR ${population_per_region {$region_code}}\n" ;
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
    { &LogList ("country name not specified for $code\n") ; }

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
  &LogSub ("\&ReadLanguageInfo\n") ;

  my @csv = &ReadCsv ("$path_meta/LanguageInfo.csv") ;

  foreach $line (@csv)
  {
    next if $line =~ /^#/ ; # comments
    next if $line !~ /,/ ;

    chomp $line ;
    $line =~ s/ /\&nbsp;/g ;

    ($code,$name,$url,$speakers,$regions,$comment) = split (',', $line) ;

    $out_urls      {$code} = $url ;
    $out_languages {$code} = $name ;
    $out_article   {$code} = "://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
    $out_article   {$code} =~ s/ /_/g ;
    $out_speakers  {$code} = $speakers ;
    $out_regions   {$code} = $regions ;
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
 
sub CountryMetaInfo
{
  my $country = shift ;
  $country =~ s/"//g ;

  my ($link_country,$icon,$population) ;

  if ($country_meta_info {$country}  eq "")
  {
    $country_meta_info_not_found_reported {$country} ++ ;
    if ($country_meta_info_not_found_reported {$country} == 1)
    { &LogDetail ("Meta info not found for country $country\n") ; }
 
    return ($country,'','..','..') ;
  }
  else
  {
    ($link_country,$icon,$population,$connected) = split ',', $country_meta_info {$country} ;

    $population =~ s/_//g ;
    $connected =~ s/_//g ;
 
    $link_country =~ s/\%2C/,/g ;
    $icon         =~ s/\%2C/,/g ;

    return ($link_country,$icon,$population,$connected) ;
  }
}

1 ;
