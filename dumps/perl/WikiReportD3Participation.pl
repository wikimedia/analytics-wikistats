#!/usr/bin/perl

# Q&D: fixed paths, to be externalized later
 open IN,      '<', '/home/ezachte/wikistats_data/dumps/csv/csv_wp/Participation.csv' ; # from Wikistats data collection 
 open IN2,     '<', '/home/ezachte/wikistats_data/dumps/csv/participation/speakers_by_continent_global_languages.csv' ; # from manual data scraping see also thorium htdocs/wikimedia/participations/speakers_by_continent_global_languages.xlsx 
 open OUT,     '>', '/home/ezachte/wikistats_data/dumps/html/d3_participation_wp.txt' ; 
 open OUT_JS,  '>', '/home/ezachte/wikistats_data/dumps/html/d3_participation_wp.js' ; 
 open OUT_CSV, '>', '/home/ezachte/wikistats_data/dumps/csv/csv_wp/d3_participation_wp.csv' ; 

 print OUT_CSV "lang_code,lang_name,speakers,participation\n";
 # csv file no longer used, as I had problems to get this to work in D3 env, see .js file instead

while ($line = <IN2>)
{
  chomp $line ;

  ($lang_code,$lang_name,$speakers) = split (',', $line,3) ;
# print "$lang_code speakers '$speakers'\n";
# $speakers =~ s/[0x00-0x1F]//g ; 
  next if length ($lang_code) != 2 ;
  $speakers =~ s/\"//g ;
  $speakers {uc ($lang_code)} = $speakers ;
}

while ($line = <IN>)
{
# print $line ;
  $lines++ ;
  next if $line =~ /^\s*$/ ; # skip empty lines 

  chomp $line ;
  my ($lang_code,$lang_name,$speakers,$active_editors,$participation,$continents) = split (',', $line) ;

  $continents =~ s/^;+// ; # remove leading hashes 

  if ($continents !~ /[A-Z]+(;[A-Z]+)*$/)
  { print "Invalid list of continents for language code '$lang_code': '$continents' -> skip\n" ; next } 

  @continents = split (';', $continents) ;
  $continent = $continents [0] ;
  $continent =~ s/[^A-Z]//g ; # drop strange characters
  
  if ($continent !~ /^(?:AA|AL|AF|AS|EU|OC|NA|SA)$/)
  { print "Invalid continent for language code '$lang_code': '$continent' -> skip\n" ; next } 

  next if $active_editors < 1 ;  
  next if $speakers       < 0.01 ;  
  next if $lang_code eq 'simple';

  if ("'en'es'ru'fr'ar'pt'" =~ /'$lang_code'/) # across continents 
  { $continent = 'AA' ; } # AA stands for 'all continents'

  if ($speakers >= 10)
  { $speakers      = sprintf ("%.0f", $speakers) ; }
      
  if ($participation > 9.9) 
  { $participation = sprintf ("%.0f", $participation) ; }
  elsif ($participation > 0.99) 
  { $participation = sprintf ("%.1f", $participation) ; }
  else  
  { $participation = sprintf ("%.2f", $participation) ; }

  if ($speakers > 9.9)
  { $speakers = sprintf ("%.0f", $speakers) ; }
  elsif ($speakers > 0.99)
  { $speakers = sprintf ("%.1f", $speakers) ; }
  else  
  { $speakers = sprintf ("%.2f", $speakers) ; }

  $lang_code = uc ($lang_code) ; 
  $lang_code =~ s/_/ /g ;

  $line = "{ \"lang_code\": \"$lang_code\", " . 
            "\"lang_name\": \"$lang_name\", " . 
            "\"participation\":$participation, ".  
            "\"speakers\": $speakers },\n" ;  

  $data   {$continent} .= $line ;
  $totals {$continent} += $speakers ;

  # add totals per continent for global languages from IN2
  if ($continent eq 'AA') # languages spoken across continents
  {
    @speakers = split (',', $speakers {$lang_code}) ;
    $global_speakers = 0 ;
    foreach $continent (qw (AF AS EU NA OC SA)) 
    {
      my $speakers = shift @speakers ;
      $speakers = sprintf ("%.0f", $speakers / 1000000) ;
      next if $speakers < 0.1 ;
      $global_speakers += $speakers ;

     print "AA $lang_code $continent $speakers $global_speakers\n";
  
      $lang_code = uc ($lang_code) ; 
      $lang_code =~ s/_/ /g ;

      $line =  "{ \"lang_code\": \"$lang_code\", " . 
                 "\"lang_name\": \"$lang_name\", " . 
                 "\"participation\":$participation, ".
                 "\"speakers\": $speakers },\n" ;  

      $data   {$continent} .= $line ;
      $totals {$continent} += $speakers ;
    }

    $line = "{ \"lang_code\": \"$lang_code\", " . 
              "\"lang_name\": \"$lang_name\", " . 
              "\"participation\":$participation, ".  
              "\"speakers\": $global_speakers },\n" ;  

    $speakers       = $global_speakers ;
  }

  $data   {'ZZ'} .= $line ;
  $totals {'ZZ'} += $speakers ;

  print OUT ',' if $lines > 1 ;
  print OUT "\n" ;
  print OUT_CSV "$lang_code,$lang_name,$speakers,$participation\n" ;   
}

foreach $continent (sort keys %data)
{
# debug only:
# print        "\n\nvar data_" . $continent . " = {\n" ;
# next ;

  print OUT_JS "\n\nvar data_" . $continent . " = {\n" ;
  print OUT_JS "\"name\": \"\",\n";
  print OUT_JS "\"children\": [\n";
  $data {$continent} =~ s/,$// ; # remove last comma
  print OUT_JS $data {$continent} ;
  print OUT_JS "]\n";
  print OUT_JS "};\n";

  print "total $continent: " . sprintf ("%.0f", $totals {$continent}) . "\n";
}

print "\nReady\n";
