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

our $__DATA_BASE;
our $__CODE_BASE;

my $o = Generate::Squid->new({
   start_date => "2013-01-31"         ,
   prefix     => "sampled-1000.tab.log-"  ,
   output_dir => "$__DATA_BASE",
});

my @ua1 = split(/\n/,`zcat $__DATA_BASE/ua.txt.gz`);
my @ua = @ua1[0..10_000];

$o->generate_line({ geocode=>"--"  }) for 1..30;
$o->__increase_day; 
$o->generate_line({ geocode=>"--"  }) for 1..30;
$o->dump_to_disk; # 2013-02-01


$o->generate_line({ geocode=>"CA"  }) for 1..100;
$o->generate_line({ geocode=>"US"  }) for 1..60;
$o->__increase_day; 

$o->generate_line({ geocode=>"BR" , user_agent_header => $_ }) for @ua;
$o->generate_line({ geocode=>"BE"  }) for 1..30;
$o->generate_line({ geocode=>"NL"  }) for 1..30;
$o->dump_to_disk;  # 2013-02-02


$o->generate_line({ geocode=>"NL"  }) for 1..30;
$o->__increase_day; 
$o->generate_line({ geocode=>"--" });
$o->dump_to_disk;  # 2013-02-03



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
    -d 2013/02/02-2013/02/02                      \\
    -r $__DATA_BASE/SquidCountArchiveConfig.pm    \\
    -p 2>&1;

    echo "FINISHED counting";
    ########################
    # Make the reports
    ########################
    nice perl  perl/SquidReportArchive.pl         \\
    -r $__DATA_BASE/SquidReportArchiveConfig.pm   \\
    -m 2013-02			                  \\
    -p 2>&1;
};

my $wikistats_run_cmd_output = `$wikistats_run_cmd`;

use HTML::TreeBuilder::XPath;
my $p = HTML::TreeBuilder::XPath->new;
$p->parse_file("$__DATA_BASE/reports/2013-02/SquidReportDevices.htm");
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
print "Sum=$sum\n";

ok( @percentages > 2 , "More than 2 device classes");
ok( abs( $sum - 100) < 0.2, "Percentages of device classes add up to 100%");


