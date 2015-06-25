#!/usr/bin/perl

# to do: bash file filenamen aanpassen ../AllWikis2 etc
# find entries for user with userid 0 after patching (..AllWisi3.tsv before patching)
# stat1002:/a/wikistats_git/dumps/csv/csv_mw> grep -P "wb\tms" EditsPerUserMonthNamespaceAllWikis4.tsv | grep -P "\t0\t20"

  use Time::Local ;
  use Getopt::Std ;

  $| = 1; # Flush output
  $verbose = 0 ;
  $time_start = time ;

  my %options ;
  getopt ("cfop", \%options) ;
  $path_csv  = $options {'c'} ;
  $file_fix  = $options {'f'} ; 
  $file_out  = $options {'o'} ;
  $file_proj = $options {'p'} ;
  

  our $phase ; # merge csv files into tsv file
  if ($options {'1'})
  { $phase = 1 ; } # merge csv files into tsv file
  elsif ($options {'2'})
  { $phase = 2 ; } # fix tsv file after sort step
  elsif ($options {'3'})
  { $phase = 3 ; } # fix tsv file after sort step
  else
  { die "Specify phase as -1, -2, or -3" ; }

  print "Phase $phase\n\n" ;

  if ($phase == 1) 
  { &PhaseMerge ; }
  elsif ($phase == 2) 
  { &PhaseFixUserids ; }  # sometimes userid 0 can be fixed as same username also appears with valid userid
  else
  { &PhaseFixDuplicates ; } # after patching records with valid userid, and resort, merge edit counts for same user/month/project/wiki/namespace

  print "Processing took " . ddhhmmss (time - $time_start) . "\n" ;
  print "\nReady\n" ;
  exit ;
    
sub PhaseMerge
{  
  print "PhaseMerge\n\n" ;

  our $file_whitelist_wikis = "WhiteListWikis.csv" ;
  
  die "Specify path to csv files as: -c [path]" if ! -d $path_csv ;
  print "Path to csv files: $path_csv\n" ;

  $file_out2 = $file_out ;
  $file_out2 =~ s/\./b./ ;
  die "Specify output file as: -o [path/file]" if $file_out eq '' ;
  print "Output file: $file_out\n" ;
  print "Output file: $file_out2\n" ;

  die "Specify projects file as: -p [path/file]" if $file_proj eq '' ;
  print "Projects file: $file_proj\n" ;

  open  TSV_OUT, '>', $file_out || die "Could not open $file_out" ;
  binmode TSV_OUT ;
  print TSV_OUT "project\tlang\tuser_name\tuser\tperiod\tnamespace\tedits\n" ;
  
  open  TSV_OUT2, '>', $file_out2 || die "Could not open $file_out2" ;
  binmode TSV_OUT2 ;
  
  open  CSV_PROJECTS, '>', $file_proj || die "Could not open $file_proj" ;
  print CSV_PROJECTS "projectcode,language,projectname,users,lines\n" ;
  
  my $test = 0 ;

  &ProcessFiles ($path_csv,wb) ;
  &ProcessFiles ($path_csv,wk) unless $test ;
  &ProcessFiles ($path_csv,wn) unless $test ;
  &ProcessFiles ($path_csv,wo) unless $test ;
  &ProcessFiles ($path_csv,wp) unless $test ;
  &ProcessFiles ($path_csv,wq) unless $test ;
  &ProcessFiles ($path_csv,ws) unless $test ;
  &ProcessFiles ($path_csv,wx) unless $test ;
  &ProcessFiles ($path_csv,wv) ;

  close TSV_OUT ;
  close TSV_OUT2 ;
  close CSV_PROJECTS ;

  # delete debug file if only header 
  if (-s $file_out2 < 100)
  { unlink $file_out2 ; }
}

sub ProcessFiles
{
  my ($path_csv,$project_code) = @_ ;

  $path_csv .= "/csv_$project_code" ;

  print "\nProcessFiles $path_csv\n\n" ;

  @languages = &ReadLanguagesCodes ($path_csv) ;

  foreach $language (@languages)
  {
    &ProcessFile ($path_csv, $project_code, $language) ;	  
  }

}


sub ProcessFile
{
  my ($path_csv,$project_code,$language) = @_ ;

  my $file_in = "$path_csv/EditsPerUserPerMonthPerNamespace" . uc ($language) . ".csv" ;
  $file_in =~ s/-/_/g ;

  if (! -e $file_in)
  {
    print "\n Input not found: '$file_in'\n\n" ;
    return ;    
  }	  

  my $project_name = &ProjectName ($project_code,$language) ;
  my $lines_out = 0 ;
  my $users_out = 0 ;
  my $userid = 0 ;

  open CSV_IN, '<', $file_in || die "Could not open '$file_in'" ;
  binmode CSV_IN ;
    
  my $user_prev = '' ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;	  
    chomp $line ;

    my ($user,$userid,$month,$ns,$edits) = split (',', $line) ;
    $user =~ s/\&comma;/,/gi ; # introduced earlier in Wikistats 
    
    next if $user =~ /\..*\..*\./ ; # no anons (also filters all an.on.ym.ous 
    next if $user =~ /\:.*\:.*\:/ ; # no anons

#   my $period = &FormatMonth ($month) ;
    my $period = $month ;

    $lines_out ++ ;
    if ($user ne $user_prev)
    { 
      $users_out ++ ; 
      $user_prev = $user ;
    }
  # for csv, format not for tsv files
  # $user =~ s/ /_/g ;
  # $user =~ s/"/%22/g ;
  # $user =~ s/'/%27/g ;
  # $user =~ s/,/%2C/g ;
    print TSV_OUT  "$user\t$userid\t$month\t$project_code\t$language\t$ns\t$edits\n" ;   
  # for debugging: same data, difference sequence
  # print TSV_OUT2 "$project_name\t$language\t$user\t$userid\t$period\t$ns\t$edits\n" ;   
  }
   
  print CSV_PROJECTS "$project_code,$language,$project_name,$users_out,$lines_out\n" ;
# print              "$project_code,$language,$project_name,$users_out,$lines_out\n" ;
}  

sub PhaseFixUserids
{
  print "PhaseFixUserids\n\n" ;

  my ($user, $userid, $project, $lang, $ns, $edits) ; 
  my ($user_prev, $userid_prev, $project_prev, $lang_prev) ; 
  
  die "File to fix not found: '$file_fix'" if ! -e $file_fix ;
  print "File to fix: $file_fix\n" ;
 
  die "Specify output file as: -o [path/file]" if $file_out eq '' ;
  print "Output file: $file_out\n" ;

  open    TSV_IN, '<', $file_fix ; 
  binmode TSV_IN ;

  open    TSV_OUT, '>', $file_out || die "Could not open $file_out" ;
  binmode TSV_OUT ;
  print   TSV_OUT "user\tuserid\tmonth\tproject\tlang\tperiod\tnamespace\tedits\n" ;
   
  $user_prev = '' ; 
  while ($line = <TSV_IN>)
  {
    $lines_in_input ++ ;
    
    chomp $line ;
    ($user, $userid, $month, $project, $lang, $ns, $edits) = split ('\t', $line) ;

     if ($userid == 0)
     { 
       $userid_zero {"$project,$lang,$month"} ++ ; 
       $userid_zero ++ ; 
       
       if (($userid_prev != 0) &&
           ($user    eq $user_prev) &&
           ($lang    eq $lang_prev) &&
           ($project eq $project_prev))
       {
         $userid_zero_fixed {"$project,$lang,$month"} ++ ; 
         $userid_zero_fixed_per_month {$month} ++ ; 
         $userid_zero_fixed ++ ; 
         $userid = $userid_prev ;
         # print "\n\n1$line_prev\n2$line\n$user\t$userid\t$month\t$project\t$lang\t$ns\t$edits\n" ;
         # print "$line\n" ;
       } 
       else
       { $users_id_zero_not_patched {"$project,$lang"} {$user} ++ ; }
     }

   # print         "project $project\tlang $lang\tuser $user\tuserid $userid\tmonth $month\tns $ns\tedits $edits\n" ;
     print TSV_OUT "$user\t$userid\t$month\t$project\t$lang\t$ns\t$edits\n" ;
     
     $project_prev = $project ;
     $lang_prev    = $lang ;
     $user_prev    = $user ;
     $userid_prev  = $userid ;
     $line_prev    = $line ;
  }
  close TSV_IN ;
  close TSV_OUT ;

  if (($lines_in_input > 0) && ($userid_zero > 0))
  {  
    print "Lines in merged editor file: $lines_in_input\n" ; 
    print "Lines with user id 0: $userid_zero (" . sprintf ("%.1f", 100 * $userid_zero / $lines_in_input) . "\% of total), " . 
          "of which " . $userid_zero_fixed . " (" . sprintf ("%.1f", 100 * $userid_zero_fixed / $userid_zero) . "\%) could be fixed from same name in same wiki with non zero user id\n" ; 

    print "Lines fixed per month: \n" ; 
    foreach $month (sort keys %userid_zero_fixed_per_month)
    { print "$month: " .  $userid_zero_fixed_per_month {$month} . "\n" ; }

    foreach $project_lang (sort keys %users_id_zero_not_patched)
    {
      %users = %{$users_id_zero_not_patched {$project_lang}} ;
      @users = sort {$users {$b} <=> $users {$a}} keys %users ;
      
      if ($#users > 0)
      { 
        print "$project_lang: " . ($#users+1) . " users" ;
        $users = join (' | ', @users) ; 
        if (length ($users) < 80)
        { print ": $users\n" ; }
        else
        { print ": " . substr ($users,0,80) . " (etc)\n" ; }    
      }
    }
  }
}
  
# after patching records with valid userid, and resort, merge edit ocunts for same user/month/project/wiki/namespace
sub PhaseFixDuplicates
{
  print "PhaseFixDuplicates\n\n" ;

  die "File to fix not found $file_fix" if ! -e $file_fix ;
  print "File to fix: $file_fix\n" ;

  die "Specify output file as: -o [path/file]" if $file_out eq '' ;
  print "Output file: $file_out\n" ;

  open    TSV_IN, '<', $file_fix ;
  binmode TSV_IN ;

  open    TSV_OUT, '>', $file_out || die "Could not open $file_out" ;
  binmode TSV_OUT ;
  print   TSV_OUT "user\tuserid\tmonth\tproject\tlang\tperiod\tnamespace\tedits\n" ;

  my ($user,$userid,$month,$project,$lang,$ns,$edits) ;
  my ($user_prev,$userid_prev,$month_prev,$project_prev,$lang_prev,$ns_prev) ;
  my ($tot_edits) ;

  $line = <TSV_IN> ; # skip header line
  while ($line = <TSV_IN>)
  {
    chomp $line ;
    ($user, $userid, $month, $project, $lang, $ns, $edits) = split ('\t', $line) ;
    
    if ($user    ne $user_prev    or 
        $month   ne $month_prev   or
        $project ne $project_prev or
        $lang    ne $lang_prev    or
        $ns      ne $ns_prev)
    {
      print TSV_OUT "$user_prev\t$userid_prev\t$month_prev\t$project_prev\t$lang_prev\t$ns_prev\t$tot_edits\n" ;
      $tot_edits = 0 ;
    }

    $tot_edits   += $edits ;

    $user_prev    = $user ;
    $userid_prev  = $userid ;
    $month_prev   = $month ;
    $project_prev = $project ;
    $lang_prev    = $lang ;
    $ns_prev      = $ns ;
  }
  print TSV_OUT "$user_prev\t$userid_prev\t$month_prev\t$project_prev\t$lang_prev\t$ns_prev\t$tot_edits\n" ;

  close TSV_IN ;
  close TSV_OUT ;
}


sub ProjectName
{
  my ($project_code,$language) = @_ ;	
  my $project_name ;
     if ($project_code eq 'wb')  { $project_name = $language . 'wikibooks' ; }
  elsif ($project_code eq 'wk')  { $project_name = $language . 'wiktionary' ; }
  elsif ($project_code eq 'wn')  { $project_name = $language . 'wikinews' ; }
  elsif ($project_code eq 'wo')  { $project_name = $language . 'wikivoyage' ; }
  elsif ($project_code eq 'wp')  { $project_name = $language . 'wiki' ; }
  elsif ($project_code eq 'wq')  { $project_name = $language . 'wikiquote' ; }
  elsif ($project_code eq 'ws')  { $project_name = $language . 'wikisource' ; }
  elsif ($project_code eq 'wv')  { $project_name = $language . 'wikiversity' ; }
  elsif ($project_code eq 'wx')  { $project_name = $language . 'wiki' ; }
  else                           { $project_name = '????' ; }
  return ($project_name) ; 
}

sub FormatMonth
{
  my ($yyyymm) = @_ ;	
  my $yyyy = substr ($yyyymm,0,4) ;
  my $mm   = substr ($yyyymm,5,2) ;

# my $date_from = "$yyyymm-01" ;
  $mm ++ ;
  if ($mm > 12) { $mm = '01' ; $yyyy ++ ; }

  my $date_to = $yyyy. '-' . sprintf ('%02d',$mm) . '-01' ;
# my $time_range = "[$date_from 00:00:00,$date_to 00:00:00]" ;
# return ($time_range) ; 
  return ($date_to) ; 
}

sub ReadLanguagesCodes
{
  my ($path_csv) = @_ ;
  
  if (! -e "$path_csv/$file_whitelist_wikis")
  { die "Could not find '$path_csv/$file_whitelist_wikis'" ; }
  
  my @whitelist ;
  open CSV_IN, '<', "$path_csv/$file_whitelist_wikis" || die "Could not open '$path_csv/$file_whitelist_wikis'" ;
  @whitelist = <CSV_IN> ;
  close CSV_IN ;
  
  my @languages ;
  foreach $line (@whitelist)
  {
    chomp $line ;	  
    ($wiki,$language) = split (',', $line) ;
    if ($language ne '')
    { push @languages, $language ; }    
  }	  

  print "\n$path_csv: " . join (',', @languages) . "\n" ;
  return @languages ;
}

# overcomplete function snatched else where
sub ddhhmmss
{
  my $seconds = shift ;
  my $format  = shift ;

  $days = int ($seconds / (24*3600)) ;
  $seconds -= $days * 24*3600 ;
  $hrs = int ($seconds / 3600) ;
  $seconds -= $hrs * 3600 ;
  $min = int ($seconds / 60) ;
  $sec = $seconds % 60 ;

  if ($format eq '')
  {
    $days = ($days > 0) ? (($days > 1) ? "$days days, " : "$days day, ") : "" ;
    $hrs  = (($days + $hrs > 0) ? (($hrs > 1) ? "$hrs hrs" : "$hrs hrs") : "") . ($days + $hrs > 0 ? ", " : ""); # 2 hrs/1 hr ?
    $min  = ($days + $hrs + $min > 0) ? "$min min, " : "" ;
    $sec  = "$sec sec" ;
    return ("$days$hrs$min$sec") ;
  }
  else
  {
    return sprintf ($format,$days,$hrs,$min,$sec) if $format =~ /%.*%.*%.*%/ ;
    return sprintf ($format,      $hrs,$min,$sec) if $format =~ /%.*%.*%/ ;
    return sprintf ($format,           $min,$sec) if $format =~ /%.*%/ ;
    return sprintf ($format,                $sec) ;
  }
}


