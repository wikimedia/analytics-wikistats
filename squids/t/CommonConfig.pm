#!/usr/bin/perl
use List::Util qw/first/;

# This is a configuration module used to establish the paths where the tests will be
# running from.
# 
#
# This code sets paths depending on which environment we're running on.
# For jenkins the path is some place, for stat1 the paths are some other place.
# This should be refactored and used by all tests in order to know where the output is
# located.
#

my $hostname = `hostname`;
my $pwd      = `pwd`;
chomp $hostname;

our $__CODE_BASE;
if($hostname eq "stat1" && $ENV{HOME} eq "/home/ezachte") {
  # Running on Erik's account on stat1
  $__CODE_BASE = "/home/ezachte/wikistats/squids";
} elsif($hostname eq "stat1" && $ENV{HOME} eq "/home/diederik") {
  # Running on Diederik's account on stat1
  $__CODE_BASE = "/home/diederik/wikistats/squids";
} elsif($pwd   =~ /\/travis\//) {
  $__CODE_BASE = "/home/travis/build/wsdookadr/analytics-wikistats/squids";
} else {
  # Anywhere else

  # If WORKSPACE seems to point to a checkout, we use it (Allowing for
  # easier local testing, and use through Jenkins). Otherwise we fall
  # back to the usual wmf setup.
  $__CODE_BASE = $ENV{WORKSPACE}."/squids";
  if(! -d $__CODE_BASE) {
    $__CODE_BASE = "/a/wikistats_git/squids";
  }
};


1;
