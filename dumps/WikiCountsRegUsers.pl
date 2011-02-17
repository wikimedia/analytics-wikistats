#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

getopt ("f", \%options) ;

if (-e "/home/ezachte/")
{ $file_users = @options {"f"} ; }
else
{ $file_users = "w:/# in dumps/afwiki-20091022-user.sql" ; }

if (! -e $file_users) { die "File $file_users not found" ; }

if ($file_users =~ /\.gz$/)
{ open USERS, "-|", "gzip -dc \"$file_users\"" || abort ("Input file " . $file_users . " could not be opened.") ; }
elsif ($file_users =~ /\.bz2$/)
{ open USERS, "-|", "bzip2 -dc \"$file_users\"" || abort ("Input file " . $file_users . " could not be opened.") ; }
elsif ($file_users =~ /\.7z$/)
{ open USERS, "-|", "./7za e -so \"$file_users\"" || abort ("Input file " . $file_users . " could not be opened.") ; }
else
{ open USERS, "<", $file_users || abort ("Input file " . $file_users . " could not be opened.") ; }

binmode USERS ;

while ($line = <USERS>)
{
  if ($line !~ /^INSERT INTO/) { next ; }
  @records = split ('\)\,\(', $line) ;
  foreach $record (@records)
  {
    $record =~ s/\\'//g ;
    $record =~ s/,('[^']+')/",".($a=$1,$a=~ s#,##g,$a)/ge ;
   ($user_id, $user_name, $user_real_name, $user_password, $user_newpassword, $user_email, $user_options, $user_touched,
    $user_token, $user_email_authenticated, $user_email_token, $user_email_token_expires, $user_registration,
    $user_newpass_time, $user_editcount) = split (',', $record) ;

    $reg_month = "unknown" ;
    if ($user_registration ne "NULL")
    {
      $reg_month = substr ($user_registration,1,6) ;
      if ($reg_month !~ /\d\d\d\d\d\d/)
      {
        print "\n\n$reg_month\n" ;
        print "$record\n" ;
      }
    }

    @reg_months { $reg_month } ++ ;
  }
}
close "USERS" ;

$file_users =~ s/.*\///g ;
$file_users =~ s/\..*// ;

if (-e "/home/ezachte/")
{ $file_users = "/a/wikistats/csv_wp/$file_users\.csv" ; }
else
{ $file_users = "c:/$file_users\.csv" ; }

open CSV, '>', $file_users ;
foreach $month (sort keys %reg_months)
{
  print CSV "$month," . $reg_months {$month} . "\n" ;
  print "$month," . $reg_months {$month} . "\n" ;
}
close CSV ;



