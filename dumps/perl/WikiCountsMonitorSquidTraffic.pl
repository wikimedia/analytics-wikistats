#!/usr/bin/perl

  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;
  use Time::HiRes ;

  my $url = "http://en.wikipedia.org/wiki/User:Erik_Zachte/NonExistingPageForSquidLogMonitoring" ;
  my $file_csv = "/a/dammit.lt/_DummyCallsForSquidLogTracking.csv" ;

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikistats dummy page requests for throughput monitoring");
  $ua->timeout(30);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://stats.wikimedia.org");

 ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);

  $time_start = Time::HiRes::time() ;
  $response = $ua->request($req);
  $time_spent = Time::HiRes::time - $time_start ;

  $timestamp = sprintf ("%04d/%02d/%02d,%02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec) ;
  $line = $response->status_line ;
  $line =~s /,/&comma;/g ;
  $msg = "$timestamp,$time_spent,404\n" ;

  print $msg ;

  open LOG, '>>', $file_csv ;
  print LOG $msg ;
  close LOG ;


