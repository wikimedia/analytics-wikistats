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
chomp $hostname;

our $__CODE_BASE;
if($hostname eq "gallium") {
  # Running on Jenkins
  $__CODE_BASE = "/var/lib/jenkins/jobs/analytics-wikistats/workspace/squids";
} elsif($hostname eq "stat1" && $ENV{HOME} eq "/home/ezachte") {
  # Running on Erik's account on stat1
  $__CODE_BASE = "/home/ezachte/wikistats/squids";
} elsif($hostname eq "stat1" && $ENV{HOME} eq "/home/diederik") {
  # Running on Diederik's account on stat1
  $__CODE_BASE = "/home/diederik/wikistats/squids";
} else {
  # Anywhere else
  $__CODE_BASE = "/a/wikistats_git/squids";
};


1;
