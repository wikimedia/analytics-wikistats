#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
require 't/CommonConfig.pm';
use lib "testdata/regression-mingle-356-bugzilla-46269";
use Data::Dumper;
use SquidReportArchiveConfig;
use Carp;
use lib "./t";
use Generate::Squid;
use List::Util qw/sum/;
use POSIX 'strftime';

our $__DATA_BASE;
our $__CODE_BASE;

my @date = gmtime(time);
$date[4]--; # Set month to previous
if ($date[4] < 0) {
    # Month underrun. Make up by borrowing from year.
    $date[4]+=12;
    $date[5]--;
};
$date[3]=1;
my $day_1_ymd = strftime('%Y-%m-%d', @date);

$date[3]++;
my $day_2_ym = strftime('%Y-%m', @date);

$date[3]++;
my $day_3_ymd_slash = strftime('%Y/%m/%d', @date);


my $o = Generate::Squid->new({
   start_date => $day_1_ymd      ,
   prefix     => "sampled-1000.tab.log-"  ,
   output_dir => "$__DATA_BASE",
});

my @ua1 = split(/\n/,`zcat $__DATA_BASE/ua.txt.gz`);
my $ua_size_cutoff = 8_000;
my @ua = @ua1[0..($ua_size_cutoff-1)];

$o->generate_line({ geocode=>"--"  }) for 1..30;
$o->__increase_day; # before this line, any generated log-lines
                    # were for the 1st day of the month
                    # after  this line, we'll generate for the 2nd day of the month
$o->generate_line({ geocode=>"--"  }) for 1..30;
$o->dump_to_disk; # 2nd day of month dumped to disk


$o->generate_line({ geocode=>"CA"  }) for 1..100;
$o->generate_line({ geocode=>"US"  }) for 1..60;
$o->__increase_day; # 3rd day of the month after this line

$o->generate_line({ geocode=>"BR" , user_agent_header => $_ }) for @ua;
$o->generate_line({ geocode=>"BE"  }) for 1..30;
$o->generate_line({ geocode=>"NL"  }) for 1..30;
$o->dump_to_disk;  # 3rd day of month dumped to disk


$o->generate_line({ geocode=>"NL"  }) for 1..30;
$o->__increase_day; # 4th day of the month after this line
$o->generate_line({ geocode=>"--" });
$o->dump_to_disk;  # 4th day of month dumped to disk

## We're interested in the 3rd day of the month, that's where
## we've generated log lines with many different UAs.
##
## To see how the report looks like, run
##  analytics-wikistats/squids$ firefox  testdata/regression-mingle-356-bugzilla-46269/reports/2014-03/SquidReportClients.htm

my $wikistats_run_cmd = qq{
   
    cd $__DATA_BASE;
    rm -f sampled-1000.*.gz;
    ls    sampled-1000.tab* | grep -v "\.gz" | xargs gzip;
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
    -d $day_3_ymd_slash-$day_3_ymd_slash          \\
    -r $__DATA_BASE/SquidCountArchiveConfig.pm    \\
    -p 2>&1;

    echo "FINISHED counting";
    ########################
    # Make the reports
    ########################
    nice perl  perl/SquidReportArchive.pl         \\
    -r $__DATA_BASE/SquidReportArchiveConfig.pm   \\
    -m $day_2_ym		                  \\
    -p 2>&1;
};

my $wikistats_run_cmd_output = `$wikistats_run_cmd`;

use HTML::TreeBuilder::XPath;
my $p = HTML::TreeBuilder::XPath->new;

my $squid_report_devices_path = "$__DATA_BASE/reports/$day_2_ym/SquidReportDevices.htm";
ok(-f $squid_report_devices_path, "SquidReportDevices.htm exists");

$p->parse_file($squid_report_devices_path);
# 3rd column
my @percentages =  map {
    my @d   = $_->descendants("/td");
    my $val;
    if(@d==8) {
      if($d[0]->as_text) {
        $val = $d[3]->as_text;
      };
    };
    $val;
  } $p->findnodes("/html/body/p/table/tr");

@percentages = map { /(\d+\.\d+)/ } grep { defined } @percentages;


my $sum = sum(@percentages);
my  $device_classes_count = scalar(@percentages);
ok( $device_classes_count < $ua_size_cutoff , "device classes < distinct UAs");
ok( $device_classes_count > 2 , "> 2 device classes");
ok(      abs( $sum - 100) < 0.2, "Percentages of device classes add up to 100%");

