#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
require 't/CommonConfig.pm';
use lib "testdata/regression-tablets-discrepancy_for_config_editors";
use SquidReportArchiveConfig;
use Carp;
use lib "./t";
use Generate::Squid;
use List::Util qw/sum/;
my $SAMPLE_UA_TABLET_ANDROID_MOZILLA = "Mozilla/5.0%20(Android;%20Tablet;%20rv:10.0.5)%20Gecko/10.0.5%20Firefox/10.0.5%20Fennec/10.0.5";
my $SAMPLE_UA_TABLET_IPAD_SAFARI     = "Mozilla/5.0%20(iPad;%20CPU%20iPhone%20OS%205_0_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Version/5.1%20Mobile/9A405%20Safari/7534.48.3";
my $SAMPLE_UA_TABLET_ANDROID_OPERA   = "Opera/9.80%20(Android%202.1.1;%20Linux;%20Opera%20Tablet/ADR-1106291546;%20U;%20ru)%20Presto/2.8.149%20Version/11.10";
my $SAMPLE_UA_TABLETPC_MSIE          = "Mozilla/4.0%20(compatible;%20MSIE%206.0;%20Windows%20NT%205.1;%20SV1;%20Tablet%20PC%201.7;%20.NET%20CLR%201.0.3705;%20.NET%20CLR%201.1.4322;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.0.04506.30;%20.NET%20CLR%203.0.04506.648)";

my @UAs = (
  #{ ua_string => undef                             , count     => 2 },
   { ua_string => $SAMPLE_UA_TABLET_ANDROID_MOZILLA , count     => 1 },
   { ua_string => $SAMPLE_UA_TABLET_IPAD_SAFARI     , count     => 1 },
   { ua_string => $SAMPLE_UA_TABLET_ANDROID_OPERA   , count     => 1 },
   { ua_string => $SAMPLE_UA_TABLETPC_MSIE          , count     => 1 },
);

our $__DATA_BASE;
our $__CODE_BASE;

my $o = Generate::Squid->new({
   start_date => "2012-09-30"         ,
   prefix     => "sampled-1000.log-"  ,
   output_dir => "$__DATA_BASE",
});

$o->generate_line({ geocode=>"--"  });
$o->__increase_day; 

for my $UA (@UAs) {
  $o->generate_line({ 
      geocode           => "CA"        ,
      user_agent_header => $UA->{ua_string} ,
  }) for 1..$UA->{count};
};
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


use Data::Dumper;
use HTML::TreeBuilder::XPath;
my @nodes;
my $p = HTML::TreeBuilder::XPath->new;
$p->parse_file("$__DATA_BASE/reports/2012-10/SquidReportClients.htm");

@nodes = map { $_ } 
         $p->findnodes("//html/body/p[1]/table/tr[2]/td[1]/table/tr[5]");

my $tablets = {};
my $R = $nodes[0];
while($R->as_HTML !~ /Total/) {
  my $C_name    = ($R->descendants)[0];
  my $C_percent = ($R->descendants)[3];
  #warn $C_name->as_text."    ".$C_percent->as_text;
  if($C_percent->as_text =~ /(\d+\.\d+)%/) {
    $tablets->{ $C_name->as_text } = $1;
  };
  $R=$R->right; 
};

ok(exists $tablets->{Safari}  ,"Safari tablet exists");
ok(exists $tablets->{MSIE}    ,"MSIE tablet exists");
ok(exists $tablets->{Opera}   ,"Opera tablet exists");
ok(exists $tablets->{Firefox} ,"Firefox tablet exists");
is(sum(map { $tablets->{$_} } qw/Safari MSIE Opera Firefox/),
   100,
   "All tablets together make up 100%");

ok($wikistats_run_cmd_output !~ /Illegal division by zero/ , "No illegal division");

ok(1,"This test always succeeds");
