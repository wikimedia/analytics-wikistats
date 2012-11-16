#!/usr/bin/perl

# &Split ("D:/WikiStats/# Out Bayes/csv_wp/") ;
 &Split ("/home/ezachte/wikistats/csv_wb") ;
 &Split ("/home/ezachte/wikistats/csv_wk") ;
 &Split ("/home/ezachte/wikistats/csv_wn") ;
 &Split ("/home/ezachte/wikistats/csv_wp") ;
 &Split ("/home/ezachte/wikistats/csv_wq") ;
 &Split ("/home/ezachte/wikistats/csv_ws") ;
 &Split ("/home/ezachte/wikistats/csv_wv") ;
 &Split ("/home/ezachte/wikistats/csv_wx") ;

  exit ;

sub Split
{
  $dir = shift ;
  chdir $dir || die "Could not change to $dir\n" ;
  $file = "StatisticsEditsPerArticle.csv" ;
  if (! -e $file) { die "File $file not found\n" ; }
  print "Split $dir/$file\n" ;

  $langprev = "" ;
  open IN, '<', $file ;
  while ($line = <IN>)
  {
    ($lang) = split (',', $line) ;
    if ($lang ne $langprev)
    {
      if ($langprev ne "")
      {
        print "$langprev: " . @lines {$langprev} . "\n" ;
        close OUT ;
        $skip = 0 ;
        $file_out = "EditsPerArticle" . uc($lang) . ".csv" ;
        if (-e $file_out)
        { $skip = 1 ; print "Skip $file_out\n" ;}
        else
        { open OUT, '>', $file_out ; }
      }
    }
    if ((++@lines {$lang} <= 5000) && (! $skip))
    { print OUT $line ; }
    $langprev = $lang ;
  }

  close IN ;
  close OUT ;
}
