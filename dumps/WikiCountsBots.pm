#!/usr/bin/perl

sub ReadBots
{
  &LogT ("ReadBots\n") ;

  if ($file_in_sql_usergroups =~ /enwiki/)
  { $file_in_sql_usergroups =~ s/20100130/20100116/g ; } # Q&D fix for empty enwiki file

  &ReadStoredBotCount ;

  $read_stored_bots = $false ;
  &LogT ("Read users: '$file_in_sql_users'\n") ;
  &LogT ("Read user groups: '$file_in_sql_usergroups'\n") ;
  if (($file_in_sql_users      eq "") ||
      ($file_in_sql_usergroups eq ""))
  {
    $read_stored_bots = $true ;
    &ReadStoredBots ;
    return ;
  }

  if (! -e $file_in_sql_usergroups)
  { abort ("ReadBots \$file_in_sql_usergroups '$file_in_sql_usergroups' not found.\n") ; }
  if (! -e $file_in_sql_users)
  { abort ("ReadBots \$file_in_sql_users '$file_in_sql_users' not found.\n") ; }

  if ($file_in_sql_usergroups =~ /\.gz$/)
  { open "GROUPS", "-|", "gzip -dc \"$file_in_sql_usergroups\"" || abort ("Input file '" . $file_in_sql_usergroups . "' could not be opened.") ; }
  elsif ($file_in_sql_usergroups =~ /\.bz2$/)
  { open "GROUPS", "-|", "bzip2 -dc \"$file_in_sql_usergroups\"" || abort ("Input file '" . $file_in_sql_usergroups . "' could not be opened.") ; }
  elsif ($file_in_sql_usergroups =~ /\.7z$/)
  { open "GROUPS", "-|", "./7za e -so \"$file_in_sql_usergroups\"" || abort ("Input file '" . $file_in_sql_usergroups . "' could not be opened.") ; }
  else
  { open "GROUPS", "<", $file_in_sql_usergroups || abort ("Input file '" . $file_in_sql_usergroups . "' could not be opened.") ; }

  binmode "GROUPS" ;

  my $lines = 0 ;
  my $bots  = 0 ;
  while ($line = <GROUPS>)
  { $line =~ s/\((\d+),'bot'\)/($bots++,$botsndx{$1}=1)/ge ; $lines++ ; }
  close "GROUPS" ;
  &LogT ("$lines lines read from user groups file -> $bots bot definitions found\n") ;

  if ($file_in_sql_users =~ /\.gz$/)
  { open "USERS", "-|", "gzip -dc \"$file_in_sql_users\"" || abort ("Input file '" . $file_in_sql_users . "' could not be opened.") ; }
  elsif ($file_in_sql_users =~ /\.bz2$/)
  { open "USERS", "-|", "bzip2 -dc \"$file_in_sql_users\"" || abort ("Input file '" . $file_in_sql_users . "' could not be opened.") ; }
  elsif ($file_in_sql_users =~ /\.7z$/)
  { open "USERS", "-|", "./7za e -so \"$file_in_sql_users\"" || abort ("Input file '" . $file_in_sql_users . "' could not be opened.") ; }
  else
  { open "USERS", "<", $file_in_sql_users || abort ("Input file '" . $file_in_sql_users . "' could not be opened.") ; }

  binmode "USERS" ;

  $lines = 0 ;
  while ($line = <USERS>)
  {
    if ($line =~ /ALTER TABLE.*?ENABLE KEYS/) { last ; }
    if ($line !~ /^INSERT INTO/) { next ; }
    $line =~ s/\((\d+),'([^']*)'/&TestBot($1,$2)/ge ; # '
    $lines ++ ;
  }
  close "USERS" ;
  &LogT ("$lines lines read from users file\n") ;

  my @bots2 = (sort {$a cmp $b} keys %bots) ;
  $registered_bots = $#bots2 + 1 ;
  if ($#bots2 > -1)
  {
    # &LogT ("\n$registered_bots registered bots: " . join (', ', @bots2) . "\n\n") ;
    $line = "" ;
    $list_previous_bots = " \n" ;

    foreach $name (@bots2)
    {
      $list_entry = "$name, " ;
      if (length ($line . $list_entry) > 90)
      {
        $list_previous_bots .= "\n" ;
        $line = "" ;
      }
      $list_previous_bots .= $list_entry ;
      $line              .= $list_entry ;
    }
  }
  $list_previous_bots =~ s/,\s*$// ;

  if ($#bots2 > -1)
  { &LogT ("\n$registered_bots registered bots:\n\n$list_previous_bots\n") ; }
  else
  { &LogT ("\nNo registered bots found\n") ; }

  if ($file_in_sql_usergroups !~ /20100730/)
  {
    if (($stored_bots_prev_run > 10) && ($registered_bots == 0))
    { abort ("No registered bots found, while $stored_bots_prev_run found on previous run. Error expected -> abort.\n") ; }
  }
  else
  {
    &Log ("For once ignore empty user group file and reuse 6 months old data\n") ; 
  }
}

sub ReadStoredBotCount
{
  &LogT ("ReadStoredBotCount: ") ;
  $stored_bots_prev_run = 0 ;

  &ReadFileCsvOnly ($file_csv_bots) ;

  my ($wp,$bots) = split (',', $csv [0], 2) ;
  if ($wp eq $language)
  {
    my @bots2 = split ('\|', $bots) ;
    $stored_bots_prev_run = $#bots2 + 1 ;
  }

  &Log ("$stored_bots_prev_run bots stored on previous run.\n\n") ;
}

sub ReadStoredBots
{
  &LogT ("ReadStoredBots\n") ;
  undef (%bots) ;

  &ReadFileCsvOnly ($file_csv_bots) ;

  my ($wp,$botlist) = split (',', $csv [0], 2) ;

  if ($wp ne $language)
  {
    &LogT ("\nNo previously stored bot data found\n") ;
    return ;
  }

  foreach $bot (split ('\|', $botlist))
  { $bots {$bot} ++ ; }

  @bots2 = (sort {$a cmp $b} keys %bots) ;
# $botlist =  join (', ', @bots2) ;

  if ($#bots2 > -1)
  {
    $line = "" ;
    $list_previous_bots = " \n" ;

    &Log2 ("\n\nPreviously registered bots on all projects:\n") ;
    foreach $name (@bots2)
    {
      $list_entry = "$name, " ;
      if (length ($line . $list_entry) > 90)
      {
        $list_previous_bots .= "\n" ;
        $line = "" ;
      }
      $list_previous_bots .= $list_entry ;
      $line              .= $list_entry ;
    }
  }
  $list_previous_bots =~ s/,\s*$// ;

  if ($#bots2 > -1)
# { &LogT ("\nUse previously registered bots: \n$botlist\n\n") ; }
  { &LogT ("\nUse previously registered bots: \n\n$list_previous_bots\n\n") ; }
  else
  { &LogT ("\nNo previously registered bots found\n") ; }
}

# when a user is registered as bot on 10+ wikis it is probably a bot here as well
sub AssumeBots
{
  my (%bots3, @botnames) ;

  if (($mode eq "wp") && ($language eq "en"))
  {
    # harvested from http://en.wikipedia.org/wiki/Wikipedia:List_of_Wikipedians_by_number_of_edits/Unflagged_bots
    $unflaggedbots = ".anacondabot,AFD Bot,AntiSpamBot,AntiVandalBot,BetacommandBot,Bluebot,BryanBot,COBot,Chris G Bot 3,CounterVandalismBot,Crypticbot,Curpsbot-unicodify,DHN-bot,DOI bot,Eskimbot,EssjayBot,Guanabot,HBC AIV helperbot,JoeBot,KevinBot,KnightRider,Lightbot,MTSbot,Mairibot,Margosbot,MarshBot,MartinBot,NetBot,Pageview bot,Peelbot,Pegasusbot,PseudoBot,RobotE,RoryBot,SEWilcoBot,SQLBot-Hello,Scepbot,Sethbot,Shadowbot3,SpellingBot,Syrcatbot,TPO-bot,Tawkerbot2,Tawkerbot4,Uncle G's 'bot,Uncle G's major work 'bot,VoABot II,Wherebot,Wherebot,Wikinews Importer Bot,XLinkBot,Xqbot,^demonBot2" ;
    &LogT ("Add unflagged bots, known to disrespect or to no longer use bot flag: $unflaggedbots\n\n") ;
    foreach $bot (split (',', $unflaggedbots))
    { $bots {$bot} ++ ; }
  }

  &LogT ("Also assume certain accounts are bots, based on previously stored bots for all projects\n") ;

  &ReadFileCsvAll ($file_csv_bots) ;

  foreach $line (@csv)
  {
    my ($wp,$bots) = split (',', $line, 2) ;
    my @bots2 = split ('\|', $bots) ;
    foreach $bot (@bots2)
    { $bots3 {$bot} ++ ; }
  }

  @botnames = (sort {$bots3 {$b} <=> $bots3 {$a}} keys %bots3) ;
  $line = "" ;
  $list_assumed_bots = " \n" ;
  if ($#botnames > -1)
  {
    &Log2 ("\n\nPreviously registered bots on all projects:\n") ;
    foreach $name (@botnames)
    {
      if ($bots3 {$name} < 10) { last ; } # occurs on 10 or more wikis ?
      if ($bots  {$name} > 0)  { next ; } # already found for this wiki ?
      $bots {$name} = 1 ;
      $list_entry = "$name [" . $bots3 {$name} . "], " ;
      if (length ($line . $list_entry) > 90)
      {
        $list_assumed_bots .= "\n" ;
        $line = "" ;
      }
      $list_assumed_bots .= $list_entry ;
      $line              .= $list_entry ;
      $assumed_bots++ ;
    }

  }
  $list_assumed_bots =~ s/,\s*$// ;
  &LogT ("\n$assumed_bots previously stored bots for all projects are registered on 10 or more wikis -> treat as bot here as well:\n\n$list_assumed_bots\n\n") ;

  #---

  $line = "" ;
  $list_assumed_bots = " \n" ;
  foreach my $name (sort keys %sounds_like_bot)
  {
    if ($bots {$name} == 0)
    {
      $bots {$name} = 1 ;
      $list_entry = "$name, " ;
      if (length ($line . $list_entry) > 90)
      {
        $list_assumed_bots .= "\n" ;
        $line = "" ;
      }
      $list_assumed_bots .= $list_entry ;
      $line              .= $list_entry ;
      $assumed_bots2++ ;
    }
  }
  $list_assumed_bots =~ s/,\s*$// ;
  &LogT ("\n$assumed_bots2 user names added to bot list because they sounded like one -> treat as bot here as well:\n\n$list_assumed_bots\n\n") ;
}

sub TestBot
{
  my $index = shift ;
  my $name  = shift ;
  $name =~ s/\|/&pipe;/g ;
  if ($botsndx {$index} > 0)
  { $bots {$name} = 1 ; }
  if (($name =~ /bot\b/) && ($name !~ /(?:Paucabot|Niabot|Marbot)\b/i)) # name(part) ends on bot, Paucabot is verified real user
  { $sounds_like_bot {$name} = 1 ; }
}

1;
