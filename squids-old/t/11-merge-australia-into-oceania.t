#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
require 't/CommonConfig.pm';
use lib "testdata/merge-australia-into-oceania";
use SquidReportArchiveConfig;
use Carp;
use lib "./t";
use Generate::Squid;
use List::Util qw/sum/;
use POSIX 'strftime';

our $__DATA_BASE;
our $__CODE_BASE;

system('echo "==============================================================="');
system("echo $__DATA_BASE");
system("ls   $__DATA_BASE");
system('echo "==============================================================="');
system("ls testdata/");
system('echo "==============================================================="');

# We pick two days and simulate squid/varnish log output for
# them. The days must not be older than one year, or otherwise
# SquidCountArchive.pl will complain. So we resort to the 1st,
# 2nd, ... day of the previous month. That should always work.
#
# We're mostly interested in the 2nd day of the month, and filter for
# that. The 1st day of the month is just there to simulate boundaries.
my @date = gmtime(time);
$date[4]--; # Set month to previous
if ($date[4] < 0) {
    # Month underrun. Make up by borrowing from year.
    $date[4]+=12;
    $date[5]--;
}

# First day of month
$date[3]=1;
my $day_1_ymd = strftime('%Y-%m-%d', @date);

# Second day of month. This is the day we're interested in.
$date[3]++;
my $day_2_ym = strftime('%Y-%m', @date);
my $day_2_ymd_slash = strftime('%Y/%m/%d', @date);

my $o = Generate::Squid->new({
   start_date => $day_1_ymd,
   prefix     => "sampled-1000.log-"  ,
   output_dir => "$__DATA_BASE",
});


$o->generate_line({ geocode=>"--"  });
$o->__increase_day; 
$o->generate_line({ geocode=>"CA"  }) for 1..100;
$o->generate_line({ geocode=>"NL"  }) for 1..100;
$o->generate_line({ geocode=>"AU"  }) for 1..800;
$o->__increase_day; 
$o->generate_line({ geocode=>"--" });
$o->dump_to_disk_and_increase_day;

my $wikistats_run_cmd = qq{
    
    cd $__DATA_BASE;
    rm -f sampled-1000.log*.gz
    ls sampled-1000.log* | xargs gzip;
    cd $__CODE_BASE;

    echo "FINISHED gzip";

    rm -rf $__DATA_BASE/csv/;
    rm -rf $__DATA_BASE/reports/;
    rm -rf $__DATA_BASE/logs/;

    echo "FINISHED cleaning";

    mkdir $__DATA_BASE/csv/;
    ln -s ../../../csv/meta $__DATA_BASE/csv/meta;

    echo "FINISHED cleaning 2";

    ########################
    # Run Count Archive
    ########################
    nice perl			                  \\
    -I ./perl                                     \\
    perl/SquidCountArchive.pl	                  \\
    -d $day_2_ymd_slash-$day_2_ymd_slash          \\
    -r $__DATA_BASE/SquidCountArchiveConfig.pm    \\
    -p 2>&1;

    echo "FINISHED counting";
    ########################
    # Make the reports
    ########################
    nice perl  perl/SquidReportArchive.pl         \\
    -r $__DATA_BASE/SquidReportArchiveConfig.pm   \\
    -m $day_2_ym                                  \\
    -p 2>&1;
};

my $wikistats_run_cmd_output = `$wikistats_run_cmd`;
#warn $wikistats_run_cmd_output;

my $SquidReportCountryData = `cat $__DATA_BASE/reports/$day_2_ym/SquidReportCountryData.htm`;

ok($SquidReportCountryData !~ /All countries in.*Australia/,"Australia is not a region anymore");
ok($SquidReportCountryData =~ /Australia.*Oceania/  , "Australia is under the Oceania region now");


