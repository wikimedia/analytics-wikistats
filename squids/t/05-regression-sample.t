#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
require 't/CommonConfig.pm';
use lib "testdata/regression-sample";
use SquidReportArchiveConfig;
use Carp;
use lib "./t";
use Generate::Squid;
use List::Util qw/sum/;

our $__DATA_BASE;
our $__CODE_BASE;

my $o = Generate::Squid->new({
   start_date => "2012-09-30"         ,
   prefix     => "sampled-1000.log-"  ,
   output_dir => "$__DATA_BASE",
});

$o->generate_line({ geocode=>"XX"  });
$o->__increase_day; 
$o->generate_line({ geocode=>"CA"  }) for 1..100;
$o->generate_line({ geocode=>"US"  }) for 1..60;
$o->generate_line({ geocode=>"BR"  }) for 1..40;
$o->generate_line({ geocode=>"BE"  }) for 1..30;
$o->generate_line({ geocode=>"NL"  }) for 1..30;
$o->__increase_day; 
$o->generate_line();
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


# Here go the tests
#     ||
#     ||
#     \/





ok(1,"This test always succeeds");
