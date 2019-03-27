#!/usr/bin/perl
# https://en.wikipedia.org/wiki/Daylight_saving_time_by_country

  $path_in  = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/EditsTimestampsTitles/" ;
  $path_out = $path_in ;

  $mode_edits_timestamps        = 0 ;
  $mode_edits_timestamps_titles = 1 ;

  $lang = 'EN' ;
  $mode = $mode_edits_timestamps_titles ;

  &Count  ($mode)  ;
  &WriteCounts ;

  print "\nReady\n" ;

sub Count
{
  $mode = shift ;
  
  if ($mode == $mode_edits_timestamps)
  { open IN,  '<', "$path_in/EditsTimestamps${lang}.csv" ; }
  elsif ($mode == $mode_edits_timestamps_titles)
  { open IN,  '<', "$path_in/EditsTimestampsTitles${lang}.csv" ; }
  else 
  { die ("Invalid mode") ; }

  $yyyy_max = 0 ; 

  while ($line = <IN>)
  {
    chomp $line ;
    
  # n=namespace, t=title, e=edit, R=registered user, B=bot. A=anonymous  
    
	if ($mode == $mode_edits_timestamps)
	{
	  if ($line =~ /^t/)
      { ($record_type,$title) = split (',',$line,2) ; }
      ($record_type,$editor_type,$timestamp,$user) = split (',', $line) ;
	  # print "record type '$record_type', editor type '$editor_type', timestamp '$timestamp', title '$title'\n" ;
	}  
	elsif ($mode == $mode_edits_timestamps_titles)
	{
      ($wiki,$record_type,$editor_type,$timestamp,$timestamp2,$namespace,$namespace_text,$title,$user) = split (',', $line) ;
	  # print "record type '$record_type', editor type '$editor_type', timestamp '$timestamp', title '$title'\n" ;
	}  

    next if $editor_type eq 'B' ;
    next if $namespace != 0 ;

    # next if ++$lines > 20 ;
    $yyyy = substr ($timestamp,0,4) ;  # years
    $mm   = substr ($timestamp,5,2) ;  # months
    $dd   = substr ($timestamp,8,2) ;  # minutes
    $hh   = substr ($timestamp,11,2) ; # hours
    $nn   = substr ($timestamp,14,2) ; # minutes 
  
    next if $mm < 4 ;
    next if $mm > 9 ;

    print "." if (++$lines % 100000 == 0) ;
    if ($lines % 1000000 == 0) 
    {  print " " . int ($lines / 1000000) . " '$title'\n" ; }
	
    $tt = 4 * $hh + int ($nn / 15) ; # 15 minute periods since start of day (starts with 0)
  # print "$yyyy $mm $dd $hh $nn - $t $tt\n" ;
  
    $edits {$yyyy} {$tt} ++ ;
  # print "$yyyy $tt " . $edits {$yyyy} {$tt} . "\n" ;

    if ($yyyy > $yyyy_max)
    { $yyyy_max = $yyyy ; }
  }
  print "\n$lines lines read\n" ;

  close IN ;
}  

sub WriteCounts
{
  if ($mode == $mode_edits_timestamps)
  { open OUT,  '>', "$path_out/TimestampsDistributionFromEditsTimestampsNoBotsAprSepNS0${lang}.csv" ; }
  elsif ($mode == $mode_edits_timestamps_titles)
  { open OUT,  '>', "$path_out/TimestampsDistributionFromEditsTimestampsTitlesNoBotsAprSepNS0${lang}.csv" ; }

  print OUT "Percentages\n" ;

  $headers = "year," ;
  for ($hh = 0 ; $hh <= 23 ; $hh++)
  { $headers .= "$hh:00,$hh:15,$hh:30,$hh:45," ; }
  $headers .= "\n" ;

  print OUT $headers ;

  for ($yyyy = 2001 ; $yyyy <= $yyyy_max ; $yyyy++)
  {
    $peak_edits = 0 ;
    for ($tt = 0 ; $tt <= 96 ; $tt++)
    {  
      $edits = $edits {$yyyy}{$tt} ;
  	#  print "$tt: $edits\n" ;
      if ($edits > $peak_edits)
	  { $peak_edits = $edits ; }	
    }
    print OUT "$yyyy," ;
    for ($tt = 0 ; $tt < 96 ; $tt++)
    {
      $edits = $edits {$yyyy}{$tt} ;
	  $perc = 0 ;
	  if ($peak_edits > 0)
	  { $perc  = sprintf ("%.0f", 100 * $edits / $peak_edits) ; }
	  print OUT ($perc+0) . "," ;
    }
    print OUT "\n" ;
  }

  print OUT "\n\nAbsolute numbers\n" ;
  print OUT $headers ;
  
  for ($yyyy = 2001 ; $yyyy <= $yyyy_max ; $yyyy++)
  {
    $peak_edits = 0 ;
    for ($tt = 0 ; $tt <= 96 ; $tt++)
    {  
      $edits = $edits {$yyyy}{$tt} ;
      # print "$tt: $edits\n" ;
	  if ($edits > $peak_edits)
	  { $peak_edits = $edits ; }
    }
    print OUT "$yyyy," ;
    for ($tt = 0 ; $tt < 96 ; $tt++)
    {
      $edits = $edits {$yyyy}{$tt} ;
  	  print OUT ($edits+0) . "," ;
    }
    print OUT "\n" ;
  }

  close OUT ;
}  
