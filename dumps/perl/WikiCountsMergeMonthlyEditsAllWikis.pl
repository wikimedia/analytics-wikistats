#!/usr/bin/perl

  use Time::Local ;
  use Getopt::Std ;

  $| = 1; # Flush output
  $verbose = 0 ;
  $time_start = time ;

  my %options ;
  getopt ("cop", \%options) ;
  $path_csv  = $options {'c'} ;
  $file_out  = $options {'o'} ;
  $file_proj = $options {'p'} ;
  
  $file_out2 = $file_out ;
  $file_out2 =~ s/\./2./ ;
  our $file_whitelist_wikis = "WhiteListWikis.csv" ;

  die "Specify path to csv files as: -c [path]" if ! -d $path_csv ;
  print "Path to csv files: $path_csv\n" ;

  die "Specify output file as: -o [path/file]" if $file_out eq '' ;
  print "Output file: $file_out\n" ;
  print "Output file: $file_out2\n" ;

  die "Specify projects file as: -p [path/file]" if $file_proj eq '' ;
  print "Projects file: $file_proj\n" ;

  open  CSV_OUT, '>', $file_out || die "Could not open $file_out" ;
  binmode CSV_OUT ;
  print CSV_OUT "project\tlang\tuser_name\tuser_id\tperiod\tnamespace\tedits\n" ;
  
  open  CSV_OUT2, '>', $file_out2 || die "Could not open $file_out2" ;
  binmode CSV_OUT2 ;
  
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

  close CSV_OUT ;
  close CSV_PROJECTS ;

  print "Processing took " . ddhhmmss (time - $time_start) . "\n" ;
  print "\nReady\n" ;
  exit ;

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
    print CSV_OUT  "$project_name\t$language\t$user\t$userid\t$period\t$ns\t$edits\n" ;   
    print CSV_OUT2 "$user\t$userid\t$month\t$project_code\t$language\t$ns\t$edits\n" ;   
  }
   
  print CSV_PROJECTS "$project_code,$language,$project_name,$users_out,$lines_out\n" ;
# print              "$project_code,$language,$project_name,$users_out,$lines_out\n" ;
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


