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

our $__DATA_BASE;
our $__CODE_BASE;

system('echo "==============================================================="');
system("echo $__DATA_BASE");
system("ls   $__DATA_BASE");
system('echo "==============================================================="');
system("ls testdata/");
system('echo "==============================================================="');

my $o = Generate::Squid->new({
   start_date => "2012-09-30"         ,
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
    -d 2012/10/01-2012/10/01                      \\
    -r $__DATA_BASE/SquidCountArchiveConfig.pm    \\
    -p 2>&1;

    echo "FINISHED counting";
    ########################
    # Make the reports
    ########################
    nice perl  perl/SquidReportArchive.pl         \\
    -r $__DATA_BASE/SquidReportArchiveConfig.pm   \\
    -m 2012-10			                  \\
    -p 2>&1;
};

my $wikistats_run_cmd_output = `$wikistats_run_cmd`;
#warn $wikistats_run_cmd_output;

my $SquidReportCountryData = `cat $__DATA_BASE/reports/2012-10/SquidReportCountryData.htm`;

ok($SquidReportCountryData !~ /All countries in.*Australia/,"Australia is not a region anymore");
ok($SquidReportCountryData =~ /Australia.*Oceania/  , "Australia is under the Oceania region now");


