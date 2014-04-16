#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use UA::iPad;
use Data::Dumper;


# type1
{
  my $res1 = 
  ipad_extract_data("Mozilla/5.0%20(iPad;%20U;%20CPU%20OS%203_2%20like%20Mac%20OS%20X;%20fr-fr)%20AppleWebKit/531.21.10%20(KHTML,%20like%20Gecko)%20Version/4.0.4%20Mobile/7B334b%20Safari/531.21.10");

  ok($res1->{browser} eq "Mozilla/5.0","type1 Browser check");
  ok($res1->{os_version} eq "3.2", "type1 Version check");
};




# Test2 - CFNetwork (for type2)
#
# no iPad version in there
# CFNetwork is an API provided by Apple, Darwin is the OS
{
  my $res2 = 
  ipad_extract_data("Perfect%20Browser-iPad/2.91%20CFNetwork/485.13.9%20Darwin/11.0.0");

  ok($res2->{browser} eq "Perfect Browser-","type2 Browser check");
  ok($res2->{os_version} eq "other", "type2 Version check");
};


# Test3 - Opera user agents (for type3)
{
  my $res3 = 
  ipad_extract_data("Opera/9.80%20(iPad;%20Opera%20Mini/7.2.37083/27.1667;%20U;%20zh)%20Presto/2.8.119%20Version/11.10");

  ok($res3->{browser} eq "Opera Mini/7.2","type3 Browser check");
  ok($res3->{os_version} eq "other", "type3 Version check");
};



# Test4 - Again type1
{
  my $res4 = ipad_extract_data("LineTime%201.1%20(iPad;%20iPhone%20OS%205.0.1;%20id_ID)");
  ok($res4->{browser} eq "LineTime 1.1","type1 Browser check");
  ok($res4->{os_version} eq "5.0", "type1 Version check");
};





# Test5 - for type4


{
  my $res5 = ipad_extract_data("LineTime%201.1%20(iPad;%20iPhone%20OS%205.0.1;%20id_ID)");
  ok($res5->{browser} eq "LineTime 1.1","type4 Browser check");
  ok($res5->{os_version} eq "5.0", "type4 Version check");
}

