#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
require 't/CommonConfig.pm';
use lib "testdata/regression-test-ipv6-wrong-external-domain/"; 
use SquidReportArchiveConfig;
use POSIX 'strftime';

####################################################################################################
# Outline
####################################################################################################
#
# Wikistats was previously using geoiplogtag which would geocode the ips.
# Now udp-filters has this functionality.
# After the migration we have had cases in the External Origins table in 
# http://stats.wikimedia.org/archive/squid_reports/scrap/2012-10-new/SquidReportOrigins.htm
# where we get external origins like
#
# 2a02- 
# 2a01- 
# 2a00- 
# 2620- 
# 2607- 
# 2602- 
# 2601- 
# 2600- 
# 240f- 
# 2002- 
# 2001- 
#
# As Diederik mentioned these seem to be part of ipv6 ip addresses.
# This test is meant to test that such things should not appear in that table
#
#
# How are we going to test ?
#
# We will create two files from within this script
# test/regression-test-ipv6-wrong-external-domain/sampled-1000.log-${year}${month}01.gz
# test/regression-test-ipv6-wrong-external-domain/sampled-1000.log-${year}${month}02.gz
#
# These two files contain few entries which are present in this file.
# Then we'll run the SquidCountArchive.pl and SquidReportArchive.pl scripts and we
# will check the file SquidDataOrigins.csv  to see if it has any 240f entries.
# If it does have those kinds of entries, the test will fail.
#
# We will also check for multiple illegal divisions which were found in SquidReportArchive.pl
# Code was added to fix those but we want to make sure there are no such things happening.
#
####################################################################################################

# We pick two days and simulate squid/varnish log output for
# them. The days must not be older than one year, or otherwise
# SquidCountArchive.pl will complain. So we resort to the 1st, 2nd,
# and 3rd day of the previous month. That should always work.
#
# We're mostly interested in the 2nd day of the month, and filter for
# that. The 1st and 3rd day of the month are just there to simulate
# boundaries.
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
my $day_2_ymd = strftime('%Y-%m-%d', @date);
my $day_2_ymd_slash = strftime('%Y/%m/%d', @date);
my $day_2_ymd_dense = strftime('%Y%m%d', @date);

# Third day of month
$date[3]++;
my $day_3_ymd = strftime('%Y-%m-%d', @date);
my $day_3_ymd_dense = strftime('%Y%m%d', @date);


my $contents_day_2 = 'ssl4 9060296 ' . $day_1_ymd . 'T07:03:32.607 0.001 240f:0:0:0:0:0:0:0 FAKE_CACHE_STATUS/200 3681 GET http://upload.wikimedia.org/wikipedia/foundation/a/a7/CNtranslatebutton2.png NONE/upload - http://ja.wikipedia.org/wiki/%E5%8C%96%E5%AD%A6%E7%89%A9%E8%B3%AA%E5%AE%89%E5%85%A8%E6%80%A7%E3%83%87%E3%83%BC%E3%82%BF%E3%82%B7%E3%83%BC%E3%83%88 - Mozilla/5.0%20(compatible;%20MSIE%209.0;%20Windows%20NT%206.1;%20WOW64;%20Trident/5.0) XX
sq82.wikimedia.org -1148359703 ' . $day_1_ymd . 'T07:03:34.215 0 0.0.0.0 TCP_IMS_HIT/304 347 GET http://upload.wikimedia.org/wikipedia/foundation/a/a7/CNtranslatebutton2.png NONE/- image/png http://ja.wikipedia.org/wiki/%E5%A4%96%E5%B1%B1%E6%83%A0%E7%90%86 240f:13:98c7:1:54b6:1f15:1b8:aedf Mozilla/5.0%20(compatible;%20MSIE%209.0;%20Windows%20NT%206.1;%20WOW64;%20Trident/5.0;%20Sleipnir/3.7.3) XX
ssl4 9167838 ' . $day_2_ymd . 'T00:22:55.449 0.011 240f:0:0:0:0:0:0:0 FAKE_CACHE_STATUS/200 3186 GET http://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Wikiquote-logo-en.svg/50px-Wikiquote-logo-en.svg.png NONE/upload - http://blog.daum.net/_blog/hdn/ArticleContentsView.do?blogid=0Chpo&articleno=16506447&looping=0&longOpen= - Mozilla/4.0%20(compatible;%20MSIE%207.0;%20Windows%20NT%206.0;%20Trident/5.0;%20SLCC1;%20.NET%20CLR%202.0.50727;%20Media%20Center%20PC%205.1;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20.NET4.0C;%20YTB730;%20BOIE9;JAJP) XX
ssl1 8687318 ' . $day_2_ymd . 'T00:23:59.955 0.000 240f:0:0:0:0:0:0:0 FAKE_CACHE_STATUS/400 0 - http://upload.wikimedia.org- NONE/- - - - - XX
';
# The last line here ^^^  is the one causing the problems

my $contents_day_3 = 'ssl4 9094050 ' . $day_3_ymd . 'T00:00:00 0.002 240f:0:0:0:0:0:0:0 FAKE_CACHE_STATUS/200 13585 GET http://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/San_Siro.jpg/220px-San_Siro.jpg NONE/upload - http://ja.wikipedia.org/wiki/%E3%82%A4%E3%83%B3%E3%83%86%E3%83%AB%E3%83%8A%E3%83%84%E3%82%A3%E3%82%AA%E3%83%8A%E3%83%BC%E3%83%AC%E3%83%BB%E3%83%9F%E3%83%A9%E3%83%8E - Mozilla/5.0%20(compatible;%20MSIE%209.0;%20Windows%20NT%206.1;%20Trident/5.0) XX';



our $__DATA_BASE;

# Making sure $__DATA_BASE identification worked (i.e.: it is a
# directory), as otherwise creating files will fail badly and not give
# much hints what wehn wrong.
ok(-d $__DATA_BASE, '$__DATA_BASE points to directory');

################################
# Creating input for test
################################

open my $sampled_day_2_fh,">$__DATA_BASE/sampled-1000.log-${day_2_ymd_dense}";
open my $sampled_day_3_fh,">$__DATA_BASE/sampled-1000.log-${day_3_ymd_dense}";
print $sampled_day_2_fh $contents_day_2;
print $sampled_day_3_fh $contents_day_3;
close $sampled_day_2_fh;
close $sampled_day_3_fh;

my $wikistats_run_cmd = qq{
    gzip -f $__DATA_BASE/sampled-1000.log-${day_2_ymd_dense};
    gzip -f $__DATA_BASE/sampled-1000.log-${day_3_ymd_dense};


    echo "FINISHED gzip";

    rm -rf testdata/regression-test-ipv6-wrong-external-domain/csv/;
    rm -rf testdata/regression-test-ipv6-wrong-external-domain/reports/;
    rm -rf testdata/regression-test-ipv6-wrong-external-domain/logs/;

    echo "FINISHED cleaning";

    mkdir testdata/regression-test-ipv6-wrong-external-domain/csv/;
    ln -s ../../../csv/meta testdata/regression-test-ipv6-wrong-external-domain/csv/meta;

    echo "FINISHED cleaning 2";

    ########################
    # Run Count Archive
    ########################
    nice perl			                                                              \\
    -I ./perl                                                                                 \\
    perl/SquidCountArchive.pl	                                                              \\
    -d $day_2_ymd_slash-$day_2_ymd_slash                                                      \\
    -r testdata/regression-test-ipv6-wrong-external-domain/SquidCountArchiveConfig.pm         \\
    -p 2>&1;

    echo "FINISHED counting";
    ########################
    # Make the reports
    ########################
    nice perl  perl/SquidReportArchive.pl                                                     \\
    -r testdata/regression-test-ipv6-wrong-external-domain/SquidReportArchiveConfig.pm        \\
    -m $day_2_ym                                                                              \\
    -p 2>&1;
};



################################
# Setting up the test run
# and running the scripts
################################

my $wikistats_run_cmd_output = `$wikistats_run_cmd`;


#######################################################
# Tests for invalid ipv6-like domain names starts here
#######################################################

my $ERRONEOUS_DOMAIN_NAME       = "240f";
my $path_to_origins_csv         = "$__DATA_BASE/csv/$day_2_ym/$day_2_ymd/public/SquidDataOrigins.csv";
my $external_domains_240f_count = `cat $path_to_origins_csv | grep "external,$ERRONEOUS_DOMAIN_NAME" | wc -l`;

ok(-f $path_to_origins_csv                         , "Origins CSV found") or die "[ERROR] Critical, exiting";
ok($external_domains_240f_count == 0               , "External domain list does not contain any 240f ipv6-like values");
ok($wikistats_run_cmd_output !~ /Illegal division by zero/ , "No illegal division");
