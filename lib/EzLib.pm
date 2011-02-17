# Erik Zachte - general purpose routines
# subroutines in this module have names in lowercase (I usually name own routines mixed case, though not consistently (yet)

no warnings 'uninitialized';

#use POSIX qw (locale_h);
#$old_locale = setlocale(LC_LANGUAGE) ;
#print "old locale LC_LANGUAGE $old_locale\n" ;
#$new_locale = setlocale(LC_LANGUAGE, "en_US.UTF-8");
#print "new locale LC_LANGUAGE $new_locale\n" ;

$ez_lib_version = 14 ;

sub ez_lib_version
{
  $ez_lib_version_required = shift ;
  if ($ez_lib_version <  $ez_lib_version_required)
  { print "EzLib out of date: version $ez_lib_version_required required" ; exit ;}
}

use lib "/home/ezachte/lib" ;

use Time::HiRes ;
use Time::Local ;
use Getopt::Std ;
use Carp ;
use Net::Domain qw (hostname);
use Digest::MD5 qw (md5_hex);
use Cwd ;
use Benchmark qw (timesum timediff timestr timethis timethese cmpthese) ;
use POSIX ;

sub date_time_english ($) ;

$true  = 1 ;
$false = 0 ;

($app_start_user,$app_start_system) = times ;

# Get host name
$hostname = `hostname` ;
chomp ($hostname) ;

$os = $^O ;
$os_linux   = $true if $os =~ /linux/i ;
$os_windows = $true if $os =~ /win32/i ;

$path_program = $0 ;
$path_program = Win32::GetLongPathName ($path_program) if $os_windows ;
($path_program,$name_program) = split '[\\\/](?=[^\\\/]*$)', $path_program ;

die "Operating system '$os' not supported" if (! $os_linux and ! $os_windows) ;

if ($os_linux) #  && (-d "/home/ezachte")) # runs on server, to be refined
{
  $job_runs_on_production_server = $true ;
  $path_home = "/home/ezachte" ;
}
else
{ $path_home = getcwd () ; }

$trace_on_exit         = $false ; # shorthand for $trace_on_exit_concise
$trace_on_exit_concise = $false ;
$trace_on_exit_verbose = $false ;
$trace_on_exit_libs    = $false ;

# emulate new perl 5.10 function
sub say
{ $msg = shift ; print "$msg\n" ; }

# if no explicit parameters specified use these defaults (mainly for tests)
sub default_argv
{
  my $argv = shift ;
  if (($#ARGV == -1) && (! $job_runs_on_production_server))
  {
    $argv =~ s/('[^'|]+')/($a=$1,$a=~s# #``#g,$a)/ge ;
    $argv =~ s/("[^'|]+")/($a=$1,$a=~s# #``#g,$a)/ge ;
    $argv =~ s/\s*\|/ /g ;
    $argv =~ s/\|\s*/ /g ;
  # @ARGV = split '\|', $argv ;
    @ARGV = split ' ', $argv ;
    foreach $arg (@ARGV)
    { $arg =~ s/``/ /g ; }
    $argv =~ s/``/ /g ;
  }
  else
  { $argv = join ' | ', @ARGV ; }
  print "\nScript $name_program started at " . date_time_english (time) . "\n" ;
  print "Arguments: $argv\n" ;
  print "\n" . '=' x 80 . "\n\n" ;
  @ARGV_BAK = @ARGV ;
}

# Get file time
sub file_time ($)
{
  my $path = shift ;

  if (! -e $path)
  { return '?' ; }
  else
  { return (time - (-M $path) * 24 * 60 * 60) ; }
}

# Get last modification of this file
sub trace_ez_lib
{
  $file_pm = 'EzLib.pm' ;
  $path_pm = "/home/ezachte/lib/$file_pm" ;
  print "File $path_pm not found" unless -e $path_pm ;
  $path_pm_age = time - ((-M $path_pm) * 24 * 60 * 60 ) ;
  print "\n$file_pm last modified: " . date_time_english ($path_pm_age) . "\n\n" ;
}

# Print current file and line number
# print "File: ", __FILE__, " Line: ", __LINE__, "\n";

# Flush output
$| = 1;

# prototype (\%) forces supplying one variable argument, which also is auto converted to reference
# Pro Perl page 226: Requiring Variabloe Rather Than Values

# invocation: @array = keys_sorted_by_value_alpha_asc (%hash) ;
# replaces:   @array = sort {$hash{$a} cmp $hash{$b}} keys %hash ;
sub keys_sorted_by_value_alpha_asc (\%)
{
  my $hashref = shift ;
  return (sort {$hashref->{$a} cmp $hashref->{$b}} keys %$hashref) ;
}

# invocation: @array = keys_sorted_by_value_alpha_desc (%hash) ;
# replaces:   @array = sort {$hash{$b} cmp $hash{$a}} keys %hash ;
sub keys_sorted_by_value_alpha_desc (\%)
{
  my $hashref = shift ;
  return (sort {$hashref->{$b} cmp $hashref->{$a}} keys %$hashref) ;
}

# invocation: @array = keys_sorted_by_value_num_asc (%hash) ;
# replaces:   @array = sort {$hash{$a} <=> $hash{$b}} keys %hash ;
sub keys_sorted_by_value_num_asc (\%)
{
  my $hashref = shift ;
  return (sort {$hashref->{$a} <=> $hashref->{$b}} keys %$hashref) ;
}

# invocation: @array = keys_sorted_by_value_num_desc (%hash) ;
# replaces:   @array = sort {$hash{$b} <=> $hash{$a}} keys %hash ;
sub keys_sorted_by_value_num_desc (\%)
{
  my $hashref = shift ;
  return (sort {$hashref->{$b} <=> $hashref->{$a}} keys %$hashref) ;
}

# almost trivial but to match keys_sorted_by_value_... subroutines
# invocation: @array = keys_sorted_alpha_asc (%hash) ;
# replaces:   @array = sort {$a cmp $b} keys %hash ;
sub keys_sorted_alpha_asc (\%)
{
  my $hashref = shift ;
  return (sort {$a cmp $b} keys %$hashref) ;
}

# almost trivial but to match keys_sorted_by_value_... subroutines
# invocation: @array = keys_sorted_alpha_desc (%hash) ;
# replaces:   @array = sort {$a cmp $b} keys %hash ;
sub keys_sorted_alpha_desc (\%)
{
  my $hashref = shift ;
  return (sort {$b cmp $a} keys %$hashref) ;
}

# almost trivial but to match keys_sorted_by_value_... subroutines
# invocation: @array = keys_sorted_num_asc (%hash) ;
# replaces:   @array = sort {$a <=> $b} keys %hash ;
sub keys_sorted_num_asc (\%)
{
  my $hashref = shift ;
  return (sort {$a <=> $b} keys %$hashref) ;
}

# almost trivial but to match keys_sorted_by_value_... subroutines
# invocation: @array = keys_sorted_num_desc (%hash) ;
# replaces:   @array = sort {$b <=> $a} keys %hash ;
sub keys_sorted_num_desc (\%)
{
  my $hashref = shift ;
  return (sort {$b <=> $a} keys %$hashref) ;
}

# for mulilingual version see wikiReportsDate.pl / sub GetDate
sub date_time_english ($)
{
  my @weekdays_en = qw (Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
  my @months_en   = qw (January February March April May June July
                        August September October November December);
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  return (substr ($weekdays_en[$wday],0,3) . ", " .
          substr ($months_en[$mon],0,3) . " " .
          $mday . ", " .
          (1900 + $year) .
          " " . sprintf ("%2d:%02d", $hour, $min)) ;
}

# for mulilingual version see wikiReportsDate.pl / sub GetMonthShort
sub month_english_short ($)
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $month = shift ;
  if ($month !~ /^\d+$/)
  { return ("?") ; }

  return ($months_en [$month % 12]) ;
}

sub month_year_english_short ($)
{
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  my $month = shift ;
  if ($month !~ /^\d+$/)
  { return ("?") ; }
  $month-- ;

  return ($months_en [$month % 12] . " " . (2000 + int ($month / 12)) ) ;
}

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

sub yyyymmddThhmmssDiff
{
  my ($time_till, $time_from) = @_ ;
  my ($yy1,$mm1,$dd1,$hh1,$nn1,$ss1) = $time_till =~ /(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)/ ;
  my ($yy2,$mm2,$dd2,$hh2,$nn2,$ss2) = $time_from =~ /(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)/ ;
  $time_till = timegm ($ss1,$nn1,$hh1,$dd1, $mm1-1, $yy1) ;
  $time_from = timegm ($ss2,$nn2,$hh2,$dd2, $mm2-1, $yy2) ;
  return ($time_till - $time_from) ;
}

sub yyyymmddhhmmssDiff
{
  my ($time_till, $time_from) = @_ ;
  my ($yy1,$mm1,$dd1,$hh1,$nn1,$ss1) = $time_till =~ /(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/ ;
  my ($yy2,$mm2,$dd2,$hh2,$nn2,$ss2) = $time_from =~ /(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/ ;
  $time_till = timegm ($ss1,$nn1,$hh1,$dd1, $mm1-1, $yy1) ;
  $time_from = timegm ($ss2,$nn2,$hh2,$dd2, $mm2-1, $yy2) ;
  return ($time_till - $time_from) ;
}

sub yyyymmddDiffDays
{
  my ($time_till, $time_from) = @_ ;
  my ($yy1,$mm1,$dd1) = $time_till =~ /(\d\d\d\d)-(\d\d)-(\d\d)/ ;
  my ($yy2,$mm2,$dd2) = $time_from =~ /(\d\d\d\d)-(\d\d)-(\d\d)/ ;
  $time_till = timegm (0,0,0,$dd1, $mm1-1, $yy1) ;
  $time_from = timegm (0,0,0,$dd2, $mm2-1, $yy2) ;
  return (($time_till - $time_from) / (24 * 60 * 60));
}

sub yyyymmDiffDays
{
  my ($time_till, $time_from) = @_ ;
  my ($yy1,$mm1) = $time_till =~ /(\d\d\d\d)-(\d\d)/ ;
  my ($yy2,$mm2) = $time_from =~ /(\d\d\d\d)-(\d\d)/ ;
  $mm1++ ;
  if ($mm1 > 12) { $mm1 = 1 ; $yy++ ; }
  $time_till = timegm (0,0,0,1, $mm1-1, $yy1) ;
  $time_from = timegm (0,0,0,1, $mm2-1, $yy2) ;
  return (($time_till - $time_from) / (24 * 60 * 60)) ;
}

sub days_in_month
{
  my $year = shift ;
  my $month = shift ;
  my $days = $days_in_month_cached {"$year $month"} ;
  return $days if $days > 0 ;

  my $month2 = $month+1 ;
  my $year2  = $year ;
  if ($month2 > 12)
  { $month2 = 1 ; $year2++ }

  my $timegm1 = timegm (0,0,0,1,$month-1,$year-1900) ;
  my $timegm2 = timegm (0,0,0,1,$month2-1,$year2-1900) ;
  $days = ($timegm2-$timegm1) / (24*60*60) ;

  $days_in_month_cached {"$year $month"} = $days ;
  return ($days) ;
}


sub abort
{

  $msg = shift ;
  confess ("\nAbort: $msg\n\n") ;
  exit ;
}


# test on each run of script whether message should still be displayed, e.g. "New feature"
sub blank_text_after
{
  my $date = shift ;
  my $text = shift ;
  my ($day,$month,$year) = $date =~ /(\d+).*?(\d+).*?(\d+)/ ;
  my $till = timegm (0,0,0,$day,$month-1,$year-1900) ;
  if (time > $till)
  { return ("") ; }
  else
  { return ($text) ; }
}

# test for four triplets and optional port number
sub is_valid_ip_address
{
  my $address = shift ;
  return ($address =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?:\:\d+)?$/) ;
}

# store elapsed high resolution time, gor benchmarking
sub code_started
{ return Time::HiRes::time() ; }

sub code_complete
{
  my ($label, $start) = @_ ;
  $code_passes {$label} ++ ;
  $code_time_spent  {$label} += Time::HiRes::time - $start ;
}

# only protect division against runtime error
sub divide_if_allowed
{
  my $x = shift ;
  my $y = shift ;
  if ($y == 0)
  { return () ; }
  else
  { return ($x/$y) ; }
}

# use Encode qw(encode);
# $eckey=encode('utf8',$key);
sub encode_url
{
  my $url = shift ;
  $url =~ s/([^0-9a-zA-Z\%\:\/\.])/"%".sprintf ("%X",ord($1))/ge ;
  return ($url) ;
}

sub encode_non_ascii
{
  my $msg = shift ;
  $msg =~ s/([\x80-\xFF]{2,})/"%".sprintf ("%X",ord($1))/ge ;
  return ($msg) ;
}

sub convert_unicode
{
  my $string  = shift ;
  my $input_unicoded = ($string =~ m/[\xc0-\xdf][\x80-\xbf]|
                                     [\xe0-\xef][\x80-\xbf]{2}|
                                     [\xf0-\xf7][\x80-\xbf]{3}/x) ;


  # unicode -> html character codes &#nnnn;
  if ($input_unicoded)
  { $string =~ s/([\x80-\xFF]+)/unicode_to_html($1)/ge ; }
  return ($string) ;
}

sub unicode_to_html
{
  my $text  = shift ;
  my $html = "" ;
  my ($c, $len, $byte, $ord, $unicode, $bytes) ;

  $len = length ($text) ;
  for ($c = 0 ; $c < $len ; $c++)
  {
    $byte = substr ($text,$c,1) ;
    $ord = ord ($byte) ;
    if ($ord < 128)      # plain ascii character
    { $html .= $byte ; } # (will not occur in this script)
    else
    {
      # single byte left >= 0x80 ? should never occur but does a few times
      # treat as pre-unicode high ascii character
      if ($c == $len - 1)
      {
        $html = "\&\#". $ord . ";" ;
        # print FILE_ERR $title .":invalid unicode char ".$text. "\n"
      }
      else
      {
        if ($ord < 224)
        { $bytes = 2 ; }
        elsif ($ord < 240)
        { $bytes = 3 ; }
        elsif ($ord < 248)
        { $bytes = 4 ; }
        elsif ($ord < 252)
        { $bytes = 5 ; }
        else
        { $bytes = 6 ; }
        $unicode = substr ($text,$c,$bytes) ;
        $html .= unicode_to_html_tag ($unicode) ;
        $c += $bytes - 1 ;
      }
    }
  }
  return ($html) ;
}


sub unicode_to_html_tag
{
  my $unicode = shift ;
  my $char = substr ($unicode,0,1) ;
  my $ord = ord ($char) ;
  my ($c, $value, $html) ;

  if ($ord < 128)         # plain ascii character
  { return ($unicode) ; } # (will not occur in this script)
  else
  {
    if ($ord >= 252)
    { $value = $ord - 252 ; }
    elsif ($ord >= 248)
    { $value = $ord - 248 ; }
    elsif ($ord >= 240)
    { $value = $ord - 240 ; }
    elsif ($ord >= 224)
    { $value = $ord - 224 ; }
    else
    { $value = $ord - 192 ; }
    for ($c = 1 ; $c < length ($unicode) ; $c++)
    { $value = $value * 64 + ord (substr ($unicode, $c,1)) - 128 ; }
    $html = "\&\#" . $value . ";" ;

    return ($html) ;
  }
}




BEGIN
{
}

# optionally print program meta data when program sends
END
{
# if ($os_windows)
# { use Win32 ; }

  my ($time, $path,$program) ;

  if ($trace_on_exit || $trace_on_exit_verbose || $trace_on_exit_concise)
  {
    $time_elapsed_total = time - $^T ; # $^T is program start time
    ($app_end_user,$app_end_system) = times ;

    $time_active_user_processes   = $app_end_user   - $app_start_user ;
    $time_active_system_processes = $app_end_system - $app_start_system ;
    $time_active_total             = $time_active_user_processes + $time_active_system_processes ;

  # print "\n" . '=' x (length ($msg) -1) . "\n\n$msg\n\n" ;
    print "\n" . '=' x 80 . "\n\n$msg\n\n" ;
  }

  if ($trace_on_exit || $trace_on_exit_verbose)
  {
    print "Prog: $name_program\n" ;
    print "Path: $path_program\n" ;
    if ($job_runs_on_production_server)
    { print "Host: $hostname (production)\n\n" ; }
    else
    { print "Host: $hostname (test run)\n\n" ; }
    print "Args:\n\n", map {"      $_\n"} @ARGV_BAK ;
  # print "Host: $hostname\n" ;
    print "OS:   $os\n" ;
    print "Perl: " . ($a = sprintf ("%.9f",$^V), $a =~ s/\_/_/g,$a) . "\n" ; # perl version
    print "Perl: $^X\n" ;  # perl exe path
    print "EzLib: $ez_lib_version\n" ;  # perl exe path
  }

  if ($trace_on_exit || $trace_on_exit_verbose || $trace_on_exit_libs)
  {
    # Get library paths
    print "\nLibs:\n", map {"      $_\n"} @INC ;

    $cwd = cwd () ;
    foreach (grep {$_ =~ /home|wiki/i} values %INC) # own modules
  # foreach (values %INC) # all modules
    {
      $file = $_ ;
      if ($file !~ /[\\\/]/)
      { $file = "$cwd/$file" ; }
      $time = file_time ($file) ;
      # $file = Win32::GetLongPathName ($_) if $os_windows ;
      push @own_modules, "$time|$file" ;
    }

    @own_modules = sort {$b <=> $a} @own_modules ;
    print "\nOwn modules (d/m/y h:m):\n" ;
    foreach (@own_modules)
    {
      ($time,$path) = split '\|', $_ ;
      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
      print sprintf ("      %2d/%02d/%4d %2d:%02d %s\n", $mday,$mon+1,$year+1900,$hour,$min, $path) ;
    }
    print "\n\n" ;
  }

  $lines = 0 ;
  foreach $key (sort keys %code_passes)
  {
    if ($lines++ == 0)
    { print "Executing times:\n" ; }
    print sprintf ("      %-26s","$key:") . ddhhmmss($code_time_spent{$key},'%3d min, %2d sec') . " / " .
            sprintf ("%10d",$code_passes{$key}) . " calls = " . sprintf ("%6f",  divide_if_allowed ($code_time_spent{$key}, $code_passes {$key})) . " sec/pass\n" ;
  }
  print "\n" ;

# $locale = setlocale(LC_LANGUAGE, $old_locale);
# print "locale LC_LANGUAGE back to $locale\n" ;

  if ($time_elapsed_total < 5)
  { $msg = "Ready in " . ddhhmmss ($time_elapsed_total) . "\n" ; }
  else
  {
    $perc_active_user_processes   = sprintf ("%4.1f", 100 *$time_active_user_processes/$time_elapsed_total) ;
    $perc_active_system_processes = sprintf ("%4.1f", 100 *$time_active_system_processes/$time_elapsed_total) ;
    $perc_active_total            = sprintf ("%4.1f", 100 *$time_active_total/$time_elapsed_total) ;
    $msg = "Ready in " . ddhhmmss ($time_elapsed_total) . "\n\nTime spent:\n" .
           "User:   $perc_active_user_processes\% ("   . ddhhmmss ($time_active_user_processes) . ")\n" .
           "System: $perc_active_system_processes\% (" . ddhhmmss ($time_active_system_processes) . ")\n" .
           "Total:  $perc_active_total\% ("            . ddhhmmss ($time_active_total) . ")\n" ;
  }

  print "\n\n" . '=' x 80 . "\n" . '=' x 80 . "\n\n" ;
}

sub trace
{
  my $function_name = shift ;

  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;

  print "\n$time $function_name\n" ;
}

# only when perl compiled with malloc
# use Devel::Peek ;
# $ENV {PERL_DEBUG_MSTATS} =  2;
# mstat() ;

1 ;
