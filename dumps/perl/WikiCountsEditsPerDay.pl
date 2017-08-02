#!/usr/bin/perl
# Q&D ad hoc script  
&ReadBots ;
&ReadEdits ;
&WriteCounts ;

print "Ready" ;
exit ;

sub ReadBots
{
  open IN,  '<', "/a/wikistats_git/dumps/csv/csv_wp/BotsAll.csv" ; 
  binmode IN ;

  while ($line = <IN>)
  {
    chomp $line ;	  
    ($lang,$bots) = split (',', $line) ;
    @bots = split ('\|', $bots) ;
    foreach $bot (@bots)
    {
      $bots {$bot} ++ ;
    }  
  }
  close IN ;
}

# count content of edits_XX.txt
# stat10055555t/data/xmldatadumps/public/fywiki/20160203> zgrep -P "<timestamp>|<username>|<ip>" fywiki-*-stub-meta-history.xml.gz > ~/edits_FY.txt

sub ReadEdits
{
  open IN,  '<', "/home/ezachte/edits_EN.txt" ; 
  binmode IN ;

  while ($line = <IN>)
  {
    chomp $line ;
    if ($line =~ /<timestamp>/)
    {
      ($yyyymmdd = $line) =~ s/^\s*<timestamp>(\d\d\d\d\-\d\d\-\d\d).*$/$1/ ;
       $days {$yyyymmdd}++ ;
      # print "$yyyymmdd\n" ; 
    }
    if ($line =~ /<ip>/)
    { $edits {'A'} {$yyyymmdd} ++ ; }
    elsif ($line =~ /<username>/)
    {
      ($user = $line) =~ s/^\s*<username>([^<]*)<.*$/$1/ ;
       if ($bots {$user})
       { $edits {'B'} {$yyyymmdd} ++ ; }
     # { print "B '$user'\n" ; }
       else
       { $edits {'U'} {$yyyymmdd} ++ ; }
     # { print "U '$user'\n" ; }
    }
  }
  close IN ;
}

sub WriteCounts
{
  open CSV,  '>', "/a/wikistats_git/dumps/csv/csv_wp/EditsPerDaysEN.csv" ; 
  print CSV "date,user,anon,bot,perc user\n" ;
  foreach $yyyymmdd (sort keys %days)
  {
    $users = (0+$edits {'U'} {$yyyymmdd}) ;
    $anons = (0+$edits {'A'} {$yyyymmdd}) ;
    $bots  = (0+$edits {'B'} {$yyyymmdd}) ;
    $reg = $users + $bots ;
    if ($reg == 0)
    { $perc = '0%' ; } 
    else
    { $perc = sprintf ("%.0f", 100 * $users / $reg) . '%' ; }

    print CSV "$yyyymmdd,$users,$anons,$bots,$perc\n" ;
    print     "$yyyymmdd,$users,$anons,$bots,$perc\n" ;
  }
  close CSV ;
}
