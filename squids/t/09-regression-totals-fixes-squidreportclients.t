#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
require 't/CommonConfig.pm';
use lib "testdata/regression-totals-fixes-for-squidreportclients";
use SquidReportArchiveConfig;
use Carp;
use lib "./t";
use Generate::Squid;
use List::Util qw/sum/;

#
# What is to be tested and fixed in this test:
#
#
# 1) MSIE 
# 2) Some totals in Browser Engines(right column , bottom)
#    are 100+ as percentages
# 3) Some totals 
#
#
#
#
#



my @UAs = (
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X)%20AppleWebKit/536.26%20(KHTML,%20like%20Gecko)%20Version/6.0%20Mobile/10A403%20Safari/8536.25", "Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Version/5.1%20Mobile/9B206%20Safari/7534.48.3",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_0_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Version/5.1%20Mobile/9A405%20Safari/7534.48.3",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X)%20AppleWebKit/536.26%20(KHTML,%20like%20Gecko)%20Mobile/10A403",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Version/5.1%20Mobile/9B176%20Safari/7534.48.3",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Mobile/9B206",
"Mozilla/5.0%20(Macintosh;%20U;%20Intel%20Mac%20OS%20X%2010_6_3;%20en-us;%20Silk/1.0.22.79_10013310)%20AppleWebKit/533.16%20(KHTML,%20like%20Gecko)%20Version/5.0%20Safari/533.1",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Wikihood%20iPad/1.3.3%20CFNetwork/609%20Darwin/13.0.0",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/5.0%20(PlayBook;%20U;%20RIM%20Tablet%20OS%202.0.1;%20en-US)%20AppleWebKit/535.8+%20(KHTML,%20like%20Gecko)%20Version/7.2.0.1%20Safari/535.8+",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_2_1%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8C148%20Safari/6533.18.5",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20EasyBits%20GO%20v1.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR",
"WikipediaMobile/3.2%20Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X)%20AppleWebKit/536.26%20(KHTML,%20like%20Gecko)%20Mobile/10A403",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%203_2%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/531.21.10%20(KHTML,%20like%20Gecko)%20Version/4.0.4%20Mobile/7B367%20Safari/531.21.10",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_0%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Version/5.1%20Mobile/9A334%20Safari/7534.48.3",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/9B206%20Safari/7534.48.3",
"Wikihood%20iPad/1.3.3%20CFNetwork/548.1.4%20Darwin/11.0.0",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%203_2_2%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/531.21.10%20(KHTML,%20like%20Gecko)%20Version/4.0.4%20Mobile/7B500%20Safari/531.21.1",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J3%20Safari/6533.18.5",
"WikipediaMobile/3.2%20Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Mobile/9B206",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_0_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Mobile/9A405",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_1%20like%20Mac%20OS%20X)%20AppleWebKit/534.46%20(KHTML,%20like%20Gecko)%20Mobile/9B176",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_1%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8G4%20Safari/6533.18.5",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Wikipanion-iPad/1.7.7%20CFNetwork/609%20Darwin/13.0.0",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20es-es)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20fr-fr)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_2%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8H7%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.80%20Mobile/9B206%20Safari/7534.48.3",
"Mozilla/5.0%20(Android;%20Tablet;%20rv:15.0)%20Gecko/15.0%20Firefox/15.0.1",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20en-gb)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20ru-ru)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(Linux;%20U;%20Android%202.3.4;%20en-us;%20Silk/1.0.22.79_10013310)%20AppleWebKit/533.1%20(KHTML,%20like%20Gecko)%20Version/4.0%20Mobile%20Safari/533.1%20Silk-Ac",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(PlayStation%20Vita%201.81)%20AppleWebKit/531.22.8%20(KHTML,%20like%20Gecko)%20Silk/3.2",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20fr-fr)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20ru-ru)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20ru-ru)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20en)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.80%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20es-es)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/5.0%20(Linux;%20U;%20Android%203.1;%20en-us;%20GT-P7510%20Build/HMJ37)%20AppleWebKit/534.13%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.13",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20de-de)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%203_2%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/531.21.10%20(KHTML,%20like%20Gecko)%20Version/4.0.4%20Mobile/7B334b%20Safari/531.21.10",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Mobile/8L1",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20en-gb)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/5.0%20(Linux;%20U;%20Android%204.0.3;%20en-us;%20Transformer%20TF101%20Build/IML74K)%20AppleWebKit/534.30%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.30",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8F191%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20es-es)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/5.0%20(Linux;%20U;%20Android%203.2;%20en-us;%20GT-P7510%20Build/HTJ85B)%20AppleWebKit/534.13%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.13",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20chromeframe/22.0.1229.79;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%2",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8F190%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20en-gb)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/5.0%20(Linux;%20U;%20Android%202.3.5;%20en-us;%20SCH-I800%20Build/GINGERBREAD)%20AppleWebKit/533.1%20(KHTML,%20like%20Gecko)%20Version/4.0%20Mobile%20Safari/533.1",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20GTB7.4;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20ja-jp)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(Linux;%20U;%20Android%204.0.4;%20en-us;%20GT-P3113%20Build/IMM76D)%20AppleWebKit/534.30%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.30",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20ja-jp)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20de-de)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20GTB7.4;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%",
"Mozilla/5.0%20(Linux;%20U;%20Android%204.1.1;%20en-us;%20Xoom%20Build/JRO03H)%20AppleWebKit/534.30%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.30",
"Mozilla/5.0%20(Linux;%20U;%20Android%204.0.4;%20en-us;%20GT-P7510%20Build/IMM76D)%20AppleWebKit/534.30%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.30",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20it-it)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Mobile/8J2",
"Mozilla/5.0%20(Linux;%20U;%20en-us;%20KFTT%20Build/IML74K)%20AppleWebKit/535.19%20(KHTML,%20like%20Gecko)%20Silk/2.1%20Safari/535.19%20Silk-Accelerated=true",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_2_1%20like%20Mac%20OS%20X;%20fr-fr)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8C148%20Safari/6533.18.5",
"Wikipanion-iPad/1.7.7%20CFNetwork/548.1.4%20Darwin/11.0.0",
"Mozilla/5.0%20(Macintosh;%20U;%20Intel%20Mac%20OS%20X%2010_6_3;%20en-us;%20Silk/1.0.22.79_10013310)%20AppleWebKit/533.16%20(KHTML,%20like%20Gecko)%20Version/5.0%20Safari/533.1",
"WikihoodPlusiPad/1.3.3%20CFNetwork/609%20Darwin/13.0.0",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%203_2_1%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/531.21.10%20(KHTML,%20like%20Gecko)%20Version/4.0.4%20Mobile/7B405%20Safari/531.21.1",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(Linux;%20U;%20Android%203.2;%20ru-ru;%20GT-P7500%20Build/HTJ85B)%20AppleWebKit/534.13%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.13",
"Mozilla/5.0%20(Linux;%20U;%20Android%204.0.4;%20en-us;%20Xoom%20Build/IMM76L)%20AppleWebKit/534.30%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.30",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20GTB7.4;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20it-it)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_4%20like%20Mac%20OS%20X;%20en-us)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8K2%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20fr-fr)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20it-it)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20CPU%20OS%206_0%20like%20Mac%20OS%20X;%20de-de)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/10A403%20Safari/7534.48.3",
"Mozilla/5.0%20(Linux;%20U;%20Android%203.1;%20en-gb;%20GT-P7500%20Build/HMJ37)%20AppleWebKit/534.13%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.13",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%203_2_2%20like%20Mac%20OS%20X;%20zh-cn)%20AppleWebKit/531.21.10%20(KHTML,%20like%20Gecko)%20Version/4.0.4%20Mobile/7B500%20Safari/531.21.1",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_5%20like%20Mac%20OS%20X;%20nl-nl)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8L1%20Safari/6533.18.5",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20.NET4.0C",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/4.0%20(compatible;%20MSIE%208.0;%20Windows%20NT%206.1;%20Trident/4.0;%20SLCC2;%20.NET%20CLR%202.0.50727;%20.NET%20CLR%203.5.30729;%20.NET%20CLR%203.0.30729;%20Media%20",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X;%20ru-ru)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/9B206%20Safari/7534.48.3",
"Mozilla/5.0%20(Linux;%20U;%20Android%204.0.3;%20ja-jp;%20Sony%20Tablet%20S%20Build/TISU0R0110)%20AppleWebKit/534.30%20(KHTML,%20like%20Gecko)%20Version/4.0%20Safari/534.30",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_3_3%20like%20Mac%20OS%20X;%20zh-cn)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8J2%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_2_1%20like%20Mac%20OS%20X;%20es-es)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8C148%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%204_2_1%20like%20Mac%20OS%20X;%20ru-ru)%20AppleWebKit/533.17.9%20(KHTML,%20like%20Gecko)%20Version/5.0.2%20Mobile/8C148%20Safari/6533.18.5",
"Mozilla/5.0%20(iPad;%20CPU%20OS%205_1_1%20like%20Mac%20OS%20X;%20es-es)%20AppleWebKit/534.46.0%20(KHTML,%20like%20Gecko)%20CriOS/21.0.1180.82%20Mobile/9B206%20Safari/7534.48.3",
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
      geocode           => "CA"             ,
      client_ip         =>'random_ipv4'     ,
      user_agent_header => $UA              ,
  }) for 1..1;
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
warn $wikistats_run_cmd_output;


use HTML::TreeBuilder::XPath;
my @nodes;
my $p = HTML::TreeBuilder::XPath->new;
$p->parse_file("$__DATA_BASE/reports/2012-10/SquidReportClients.htm");

@nodes = map { $_ } 
         $p->findnodes("//html/body/p[1]/table/tr[2]/td[1]/table/tr[5]");





ok(1,"This test always succeeds");
