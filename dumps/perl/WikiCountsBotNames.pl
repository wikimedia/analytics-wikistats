#!/usr/bin/perl
#
&ReadBots ;
&ReadNonBots ;

sub ReadBots
{
  open IN,  '<', "/a/wikistats_git/dumps/csv/csv_wp/BotsAll.csv" ; 
  open OUT, '>', "/a/wikistats_git/dumps/csv/csv_wp/BotsAllUnique.csv" ; 
  binmode IN ;
  binmode OUT ;

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

  $botcnt = 0 ;
  print OUT "index,name,#wikis\n" ;
  foreach $bot (sort keys %bots)
  {
    $botcnt++ ;	  
    print     "$botcnt: $bot in ${bots{$bot}} lang\n" ;	  
    print OUT "$botcnt,$bot,${bots{$bot}}\n" ;	  
  }
  close IN ;
  close OUT ;
}

sub ReadNonBots
{
 #open IN, '<', "/a/wikistats_git/dumps/csv/csv_wp/EditsPerUserPerMonthPerNamespaceAllProjects.csv" ; 
  open IN,  '<', "/a/wikistats_git/dumps/csv/csv_wp/EditsPerUserPerMonthPerNamespaceAllWikis.csv" ; 
  open OUT, '>', "/a/wikistats_git/dumps/csv/csv_wp/BotsNotReally.csv" ;
  binmode IN ;
  binmode OUT ;

  $user_prev = '' ;
  print OUT "index,name\n" ;
  while ($line = <IN>)
  {
    ($user,@remainder) = split (',', $line) ;

    next if $user eq $user_prev ;
    $usercnt++ ;
    $user_prev = $user ;  

    next if $user !~ /bot/i ;
    $usercntbot ++ ;  

    if ($bots {$bot})
    {
      $usercntinbothfiles ++ ; # occurs in BotsAll.csv and EditsPerUserPerMonthPerNamespaceAllWikis.csv
      print "$bots occurs in both files\n" ;
    }

    if (($user =~ /bot\b/i) || ($user =~ /_bot_/i))
    {
      next ;	  
      #if ($user !~ /(?:Paucabot|Niabot|Marbot)\b/i)
      #{
      #  next ;
      #}
    } 
    $usercntbotfalsepositive ++ ;

    print "Not a bot: $user\n" ; 
    print OUT "$usercntbotfalsepositive,$user\n" ; 

    if ($usercnt % 1000 == 0)
    { print "$usercnt: $user\n" ; }
  }
  close IN ;
  close OUT ;

  print "\n" ;
  print "Total users: $usercnt\n" ;
  print "Total users with 'bot' in name: $usercntbot, " . sprintf ("%.1f", 100*$usercntbot/$usercnt) . "%\n" ;
  print "Total users with 'bot' in name, but not a bot: $usercntbotfalsepositive, " . sprintf ("%.1f", 100*$usercntbotfalsepositive/$usercntbot) . "%\n" ;
  print "Total users which occur on both files: $usercntinbothfiles" ; #  . sprintf ("%.1f", 100*$usercntbotfalsepositive/$usercntbot) . "%\n" ;
}
