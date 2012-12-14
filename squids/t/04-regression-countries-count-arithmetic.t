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


#
# SquidCountArchiveConfig file
# SquidReportArchiveConfig file
# .t file
# sub-directory inside testdata/regression-*
#



our $__DATA_BASE;
our $__CODE_BASE;

my $SAMPLE_USER_AGENT_KINDLE = "Mozilla/5.0%20(Linux;%20U;%20en-GB)%20AppleWebKit/528.5+%20(KHTML,%20like%20Gecko,%20Safari/528.5+)%20Version/4.0%20Kindle/3.0%20(screen%20600x800;%20rotate)";
my $SAMPLE_USER_AGENT_IPAD   = "Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Version/5.1%20Mobile/9B206%20Safari/7534.48.3";
my $SAMPLE_USER_AGENT_NEXUS  = "Mozilla/5.0%20(Linux;%20U;%20Android%204.1.1;%20en-gb;%20Galaxy%20Nexus%20Build/JRO03C)%20AppleWebKit/534.30%20(KHTML,%20like%20Gecko)%20Version/4.0%20Mobile%20Safari/534.30";
my $SAMPLE_URL_MOBILE        = "http://en.m.wikipedia.org/wiki/Manhattan_Project";
my $SAMPLE_URL_MIMETYPE_SVG  = "http://en.wikipedia.org/wiki/File:Great-Lakes-Basin.svg";

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
      { code => "CA" , mobile_pageviews => "200", non_mobile_pageviews => "0" },
      { code => "US" , mobile_pageviews => "300", non_mobile_pageviews => "0" },
      { code => "PL" , mobile_pageviews => "100", non_mobile_pageviews => "0" },
      { code => "GB" , mobile_pageviews => "100", non_mobile_pageviews => "0" },
    );

# Date is 2012-09-30
$o->generate_line({ geocode=>"--"  });
$o->__increase_day; 
# Date is 2012-10-01
for my $country (@countries_data) {

  my $mobile_pageviews     = $country->{mobile_pageviews};
  my $non_mobile_pageviews = $country->{non_mobile_pageviews};
  # Generate a tablet pageview
  $o->generate_line({ geocode           => $country->{code}         , 
                      user_agent_header => $SAMPLE_USER_AGENT_IPAD  ,
                      url               => $SAMPLE_URL_MOBILE       ,
                      #mime_content_type => "image/png"              ,
                   }) for (1..$mobile_pageviews);
  # Generate a non-mobile pageview (user_agent_header is by default Mozilla Firefox running on Windows)
  $o->generate_line({ geocode           => $country->{code} }) for (1..$non_mobile_pageviews);
};
$o->__increase_day;
# Date is 2012-10-02
$o->generate_line({ geocode=>"--"  });
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
#warn $wikistats_run_cmd_output;


#################################################################################################################
# Test that the numbers we injected into the reports sum up to the values present in SquidDataCountriesViews.csv
#################################################################################################################

my $sum_csv;
my $sum_planned=sum(map { $_->{non_mobile_pageviews} + $_->{mobile_pageviews} } @countries_data);

open my $countries_views_csv_fh,"<$__DATA_BASE/csv/2012-10/2012-10-01/public/SquidDataCountriesViews.csv";
while(my $line=<$countries_views_csv_fh>) {
  chomp $line;
  my @fields = split(/,/,$line);
  next if @fields < 4; # we know that CSV has at least 4 fields
  $sum_csv += $fields[-1];
};

is($sum_csv,$sum_planned,"Totals in Squid CSV filles generated for Countries report is the same as the one we planned here");
ok(1,"Sample test");



########################################################################################################
# Test SquidReportRequests.htm and check that tables have enough columns per each
# row.
# 
# Note:
#    You can use Firepath to find out XPath expressions 
#    ( https://addons.mozilla.org/en-US/firefox/addon/firepath/ )
########################################################################################################

use HTML::TreeBuilder::XPath;
use Data::Dumper;
my $p = HTML::TreeBuilder::XPath->new;
$p->parse_file("$__DATA_BASE/reports/2012-10/SquidReportRequests.htm");
my @table_1_row_header = $p->findnodes("/html/body/p[1]/table/tr[1]/*");
my @table_1_row_1      = $p->findnodes("/html/body/p[1]/table/tr[3]/*");
my @table_1_row_total  = $p->findnodes("/html/body/p[1]/table/tr[4]/*");

is(scalar(@table_1_row_header), 5 , "First table in SquidReportRequests.htm  has 6 columns in header row");
is(scalar(@table_1_row_1)     , 8 , "First table in SquidReportRequests.htm  has 8 columns in row 1");
is(scalar(@table_1_row_total) , 8 , "First table in SquidReportRequests.htm  has 8 columns in the Total row");

