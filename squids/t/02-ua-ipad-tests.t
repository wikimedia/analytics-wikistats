#!/usr/bin/env perl
use strict;
use warnings;

my @user_agents = qw{
Appcelerator%20Titanium/1.6.2%20(iPad/4.3.3;%20iPhone%20OS;%20ja_JP;)
Appcelerator%20Titanium/1.6.2%20(iPad/4.3.5;%20iPhone%20OS;%20ja_JP;)
Wikihood%20iPad/1.3.3%20CFNetwork/548.0.4%20Darwin/11.0.0
Wikihood%20iPad/1.3.3%20CFNetwork/548.1.4%20Darwin/11.0.0
Wikihood%20iPad/1.3.3%20CFNetwork/609%20Darwin/13.0.0
Wikihood%2520iPad/1.3.3%20CFNetwork/548.1.4%20Darwin/11.0.0
Wikihood%2520iPad/1.3.3%20CFNetwork/609%20Darwin/13.0.0
WikihoodPlusiPad/1.3.3%20CFNetwork/548.0.3%20Darwin/11.0.0
WikihoodPlusiPad/1.3.3%20CFNetwork/548.0.4%20Darwin/11.0.0
WikihoodPlusiPad/1.3.3%20CFNetwork/548.1.4%20Darwin/11.0.0
WikihoodPlusiPad/1.3.3%20CFNetwork/609%20Darwin/13.0.0
Wikipanion-iPad/1.6.1%20CFNetwork/467.12%20Darwin/10.3.1
Wikipanion-iPad/1.6.1%20CFNetwork/485.12.7%20Darwin/10.4.0
Wikipanion-iPad/1.6.5.1%20CFNetwork/485.12.7%20Darwin/10.4.0
};

=begin



=cut

sub make_log_line {
  my ($useragent) = @_;
  my $line = qq{cp1008.eqiad.wmnet 469409767 2012-07-01T00:07:46.757 0 0.0.0.0 TCP_MISS/200 13722 GET http://en.wikipedia.org/wiki/Wellington_Silva CARP/10.64.0.137 text/html http://es.wikipedia.org/wiki/Wellington_Silva - };

  $line = $line.$useragent."\n";

  return $line;
}



=begin

  Create a log file to test the results

=cut

sub create_log_file {
  my $timestamp = `date +%s`;
  chomp $timestamp;
  my $sandbox_dir = "/tmp/wikistats.sandbox.$timestamp"; 
  `rm -rf $sandbox_dir; mkdir $sandbox_dir`;
  my $sandbox_log = "$sandbox_dir/ua-ipad-tests.log";

  open my $fh,">$sandbox_log";
  for my $user_agent(@user_agents) {
    my $generated_line = make_log_line($user_agent);
    print $fh $generated_line;
  };
  close $fh;

};





create_log_file;
