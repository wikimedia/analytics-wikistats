#!/usr/bin/perl

#   this subroutine takes only one parameter, the process id for
#   which memory usage information is to be returned.  If
#   undefined, the current process id is assumed.
#
#   Returns array of two values, raw process memory size and
#   percentage memory utilisation, in this order.  Returns
#   undefined if these values cannot be determined.


  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;


  use Devel::Peek ;
  $ENV {PERL_DEBUG_MSTATS} =  2;
  mstat() ;

  trace_ez_lib () ;

# to do merge: merge test_ez_lib and test_ez_lib2
sub test_ez_lib ($$$)
{
  my ($function,$in,$out) = @_ ;
  $result = &$function ($in) ;
  if ($result ne $out)
  { abort "\nTestEzLib: function $function failed:\nExpected '$in' -> '$out'\nReceived '$result'\n\n" ; }
  print "Test $function OK\n" ;
}

sub test_ez_lib2 ($$$$)
{
  my ($function,$in1,$in2,$out) = @_ ;
  $result = &$function ($in1,$in2) ;
  if ($result ne $out)
  { abort "\nTestEzLib2: function $function failed:\nExpected '$in1','$in2' -> '$out'\nReceived '$result'\n\n" ; }
  print "Test $function OK\n" ;
}

test_ez_lib ('month_english_short',11,'Dec') ;
test_ez_lib ('month_english_short',12,'Jan') ;

test_ez_lib ('ddhhmmss',    0 , '0 sec') ;
test_ez_lib ('ddhhmmss',   14 , '14 sec') ;
test_ez_lib ('ddhhmmss',   60 , '1 min, 0 sec') ;
test_ez_lib ('ddhhmmss',   61 , '1 min, 1 sec') ;
test_ez_lib ('ddhhmmss',  1439*60+59, '23 hrs, 59 min, 59 sec') ;
test_ez_lib ('ddhhmmss',  1440*60, '1 day, 0 hrs, 0 min, 0 sec') ;
test_ez_lib ('ddhhmmss',  1440*60+1, '1 day, 0 hrs, 0 min, 1 sec') ;
test_ez_lib ('ddhhmmss',  2880*60+1, '2 days, 0 hrs, 0 min, 1 sec') ;

test_ez_lib2 ('ddhhmmss', 123456, '%2d sec', '36 sec') ;
test_ez_lib2 ('ddhhmmss', 123456, '%2d min, %2d sec', '17 min, 36 sec') ;
test_ez_lib2 ('ddhhmmss', 123456, '%2d hrs, %2d min, %2d sec', '10 hrs, 17 min, 36 sec') ;
test_ez_lib2 ('ddhhmmss', 123456, '%d days, %2d hrs, %2d min, %2d sec', '1 days, 10 hrs, 17 min, 36 sec') ;

test_ez_lib2 ('blank_text_after', '31/12/2009', 'New feature', '') ;
test_ez_lib2 ('blank_text_after', '31/01/2025', 'New feature', 'New feature') ;

test_ez_lib2 ('days_in_month', 2010, 1, 31) ;
test_ez_lib2 ('days_in_month', 2011, 2, 28) ;
test_ez_lib2 ('days_in_month', 2012, 2, 29) ;

$start_test_ezlib1 = code_started() ;
sleep (1) ;
$start_test_ezlib2 = code_started() ;
sleep (1) ;

code_complete ("start_ez_lib2", $start_test_ezlib2) ;
code_complete ("start_ez_lib1", $start_test_ezlib1) ;

test_ez_lib2 ('divide_if_allowed', 1,2, 0.5) ;
test_ez_lib2 ('divide_if_allowed', 1,0, "") ;

test_ez_lib ('encode_url', 'http://www.yahoo.com', 'http://www.yahoo.com') ;
test_ez_lib ('encode_url', 'http://()<>[].com', 'http://%28%29%3C%3E%5B%5D.com') ;

test_ez_lib2 ('yyyymmddThhmmssDiff', '2010-03-01T01:01:02', '2010-03-01T01:01:01', '1') ;
test_ez_lib2 ('yyyymmddThhmmssDiff', '2010-03-01T00:00:01', '2010-02-28T23:59:59', '2') ;

test_ez_lib2 ('yyyymmddDiffDays', '2010-01-02', '2010-01-01', '1') ;
test_ez_lib2 ('yyyymmddDiffDays', '2010-03-01', '2010-02-01', '28') ;
test_ez_lib2 ('yyyymmddDiffDays', '2010-01-01', '2009-12-31', '1') ;

test_ez_lib2 ('yyyymmDiffDays', '2010-01', '2010-01', '31') ;
test_ez_lib2 ('yyyymmDiffDays', '2010-03', '2010-02', '59') ;
test_ez_lib2 ('yyyymmDiffDays', '2010-01', '2009-12', '62') ;

%plank = (1=>'aap', 2=>'noot', 3=>'mies', 4=>'wim', 5=>'jet') ;

print "sub keys_sorted_by_value_alpha_asc\n" ;
foreach $key (keys_sorted_by_value_alpha_asc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;

print "sub keys_sorted_by_value_alpha_desc\n" ;
foreach $key (reverse keys_sorted_by_value_alpha_desc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;

%plank = (1=>'4', 2=>'3', 3=>'24', 4=>'43', 5=>'11') ;

print "sub keys_sorted_by_value_num_asc\n" ;
foreach $key (keys_sorted_by_value_num_asc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;

print "sub keys_sorted_by_value_num_desc\n" ;
foreach $key (reverse keys_sorted_by_value_num_desc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;

%plank = (12=>'aap', 1=>'noot', 111=>'mies') ;

print "sub keys_sorted_alpha_asc\n" ;
foreach $key (keys_sorted_alpha_asc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;

print "sub keys_sorted_alpha_desc\n" ;
foreach $key (reverse keys_sorted_alpha_desc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;

print "sub keys_sorted_num_asc\n" ;
foreach $key (keys_sorted_num_asc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;

print "sub keys_sorted_num_desc\n" ;
foreach $key (reverse keys_sorted_num_desc(%plank))
{ print "$key $plank{$key} \n" ; }
print "\n" ;


