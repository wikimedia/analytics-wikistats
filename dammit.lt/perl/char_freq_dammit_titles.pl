#!/usr/bin/perl

$| = 1 ;

$lines_max = 100000 ;

open TXT, '<', "/a/dammit.lt/pagecounts/temp/x22" ;
open OUT, '>', "/home/ezachte/char_freq_dammit_titles2.txt" ;
push @percents, "\n\n50 first occurences of '\%' after eliminating \%[0-1A-F]{2}\n\n" ;

print OUT "char frequency in first $lines_max lines of unzipped 'pagecounts-2014-08-01.bz2'\n\n" ;
print     "char frequency in first $lines_max lines of unzipped 'pagecounts-2014-08-01.bz2'\n\n" ;

while ($line = <TXT>)
{
# print "$line" ;
  last if $lines == $lines_max ;
  chomp $line ;
  ($lang,$title,$count) = split (' ', $line) ;
  $title =~ s/(\%[0-9A-F]{2})/$chars{$1}++/ge ; 

if ($title =~ /\%/)
{
  if ($title_percents++ < 50)
  { push @lines_with_percent, "$title\n" ; } 
} 
  $title =~ s/(.)/$chars{$1}++/ge ;  
  $lines++ ;
}

print OUT "$lines lines read\n" ;
print     "$lines lines read\n" ;

for ($i=0 ; $i <= 255 ; $i++)
{
  $char = chr ($i) ; 
  $code = '%' . sprintf  ("%.2X",$i) ;
  $count_char = sprintf ("%8s",0+$chars {$char}) ;  
  $count_code = sprintf ("%8s",0+$chars {$code}) ;  
  $count_both = $count_char + $count_code ;
  $perc_char  = '  - ' ;
  $perc_code  = '  - ' ;
  if ($count_both > 0)
  { 
    $perc_char = sprintf ("%4s", sprintf ("%.0f",100 * $count_char / $count_both) . '%') ; 
    $perc_code = sprintf ("%4s", sprintf ("%.0f",100 * $count_code / $count_both) . '%') ; 
  }
  if ($i < 32)
  { $char = "'' " ; }
  else
  { $char = "'$char'" ; }
  
  $line_out = sprintf ("%3s",$i) . " $char: $count_char = $perc_char | '$code':$count_code = $perc_code\n" ; 
  
  print OUT $line_out ;
  print     $line_out ;
}

$line_out = "\nFirst 50 lines with percent sign, not part of encoded char:\n\n" ;
print OUT $line_out ;
print     $line_out ;
print OUT @lines_with_percent ;
print     @lines_with_percent ;

 
