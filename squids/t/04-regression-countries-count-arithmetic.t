#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
require 't/CommonConfig.pm';
use lib "testdata/regression-countries-count-arithmetic";
use SquidReportArchiveConfig;
use Carp;
use lib "./t";
use Generate::Squid;
use List::Util qw/sum/;

our $__DATA_BASE;
our $__CODE_BASE;

################################
# Generating data for test
################################

warn $__DATA_BASE;
my $o = Generate::Squid->new({
   start_date => "2012-09-30"       ,
   prefix     => "sampled-1000.log-",
   output_dir => $__DATA_BASE,
});

my @countries_data = 
    (
      ["CA" => 700],
      ["US" => 500],
      ["PL" => 100],
      ["GB" => 100],
      ["FR" => 100]
    );

# Date is 2012-09-30
$o->generate_line({ geocode=>"XX"  });
$o->__increase_day; 
# Date is 2012-10-01
for(@countries_data) {
  my ($country,$count) = @$_;
  $o->generate_line({ geocode=> $country }) for (1..$count);
};
$o->__increase_day;
# Date is 2012-10-02
$o->generate_line({ geocode=>"XX"  });
$o->dump_to_disk_and_increase_day;


confess "[ERROR] problem with path, should have \"testdata\" substring in it"
  unless $__DATA_BASE =~ /testdata/;

################################
# Setting up the test run
# and running the scripts
################################

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
warn $wikistats_run_cmd_output;


#####################################################
# Actual tests start here(testing CSV files mostly)
#####################################################

my $sum_csv;
my $sum_planned=sum(map {$_->[1]} @countries_data);
open my $countries_views_csv_fh,"<$__DATA_BASE/csv/2012-10/2012-10-01/public/SquidDataCountriesViews.csv";
while(my $line=<$countries_views_csv_fh>) {
  chomp $line;
  my @fields = split(/,/,$line);
  next if @fields < 4; # we know that CSV has at least 4 fields
  $sum_csv += $fields[-1];
};

ok($sum_csv == $sum_planned,"Totals in Squid CSV filles generated for Countries report is the same as the one we planned here");
ok(1,"Sample test");
