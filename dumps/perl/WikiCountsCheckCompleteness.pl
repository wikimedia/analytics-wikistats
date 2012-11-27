#!/usr/local/bin/perl

$dir_old = "D:/Wikistats/# out zwinger/" ;
$dir_new = "D:/Wikistats/# out bayes/" ;
&Check ("csv_wb") ;
print "\nReady" ;
exit ;

sub Check
{
  $project = shift ;
  open OLD, '<', "$dir_old$project/StatisticsMonthly.csv" ;
  while ($line = <OLD>)
  {
    if ($line =~ /^[^,]+,05\/31\/2008/)
    {
      ($lang,$date,$c1,$c2,$c3,$c4,$articles) = split (',', $line) ;
      @old {$lang} = $articles ;
    }
  }
  close OLD ;

  open NEW, '<', "$dir_new$project/StatisticsMonthly.csv" ;
  while ($line = <NEW>)
  {
    if ($line =~ /^[^,]+,05\/31\/2008/)
    {
      ($lang,$date,$c1,$c2,$c3,$c4,$articles) = split (',', $line) ;
      @new {$lang} = $articles ;
    }
  }
  close NEW ;

  foreach $lang (sort keys %new)
  {
    if ($new{$lang} == 0)
    { $perc = "..%" ; }
    else
    { $perc = sprintf ("%.0f", 100 * $old{$lang} / $new{$lang}) ; }
    print "$perc $lang: " . ($old{$lang}+0) . " - " . ($new{$lang}+0). "\n" ;
  }
}

