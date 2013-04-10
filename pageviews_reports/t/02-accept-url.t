#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use lib "./lib";
use PageViews::Model::Sequential;
use Data::Dumper;

#######################################
# Testing build_accepted_url_regex1()
#######################################

my $re_str = PageViews::Model::Sequential::build_accepted_url_regex1();

my $re = qr/$re_str/;

my $u1 = "http://en.m.wikipedia.org/wiki/Mr.T";
my $u2 = "http://de.m.wikibooks.org/w/index.php/Mr.T";
my $u3 = "http://ja.m.wikinews.org/w/api.php?action=mobileview";
my $u4 = "http://ja.m.wikinews.org/w/api.php?action=view";
my $u5 = "http://en.m.wiktionary.org/wiki/Special:MobileOptions";

# After receiving feedback from Mobile team on 08-April-2012
my $u6 = "https://en.m.wikipedia.org/w/api.php?format=json&action=query&prop=langlinks&llurl=true&lllimit=max&titles=Tropical+cyclone";
my $u7 = "https://en.m.wikipedia.org/w/api.php?format=json&action=mobileview&page=Tornado&variant=en&redirects=yes&prop=sections%7Ctext&noheadings=yes&sectionprop=level%7Cline%7Canchor&sections=all";
my $u8 = "https://en.m.wikipedia.org/w/api.php?format=json&action=mobileview&page=Tornadoes+of+2013&variant=en&redirects=yes&prop=sections%7Ctext&noheadings=yes&sectionprop=level%7Cline%7Canchor&sections=all";


my @c1 = $u1 =~ $re;
my @c2 = $u2 =~ $re;
my @c3 = $u3 =~ $re;
my @c4 = $u4 =~ $re;
my @c5 = $u5 =~ $re;
my @c6 = $u6 =~ $re;
my @c7 = $u7 =~ $re;
my @c8 = $u8 =~ $re;

ok(@c1==9,"u1 test has 8 captures");
ok(@c2==9,"u2 test has 8 captures");
ok(@c3==9,"u3 test has 8 captures");
ok(@c4==9,"u4 test has 8 captures");
ok(@c5==9,"u5 test has 8 captures");
ok(@c6==9,"u6 test has 8 captures");
ok(@c7==9,"u7 test has 8 captures");
ok(@c8==9,"u8 test has 8 captures");



#print Dumper \@c4;

#######################################
# Testing accept_rule_url for API
#######################################

{
  my $u = "http://ja.m.wikinews.org/w/api.php?action=view&title=Radix_tree";
  my $o = PageViews::Model::Sequential->new;
  $o->{last_ymd} = "2013-2";
  my $a = $o->accept_rule_url($u);
  #print Dumper $a;
  ok($a->{language}        eq 'ja'        &&
     $a->{"pageview-type"} eq 'api'       &&
     $a->{"title"}         eq 'Radix_tree',
     "API output of accept_rule_url");
};

#########################################
# Testing accept_rule_url for WIKI_BASIC
#########################################


{
  my $u = "http://en.m.wikipedia.org/wiki/Mr.T";
  my $o = PageViews::Model::Sequential->new;
  $o->{last_ymd} = "2013-2";
  my $a = $o->accept_rule_url($u);
  ok($a->{language}        eq 'en'          &&
     $a->{"pageview-type"} eq 'wiki_basic'  ,
     "WIKI_BASIC output of accept_rule_url");
};

#########################################
# Testing accept_rule_url for WIKI_INDEX
#########################################

{
  my $u = "http://de.m.wikibooks.org/w/index.php/Mr.T";
  my $o = PageViews::Model::Sequential->new;
  $o->{last_ymd} = "2013-2";
  my $a = $o->accept_rule_url($u);
  ok($a->{language}        eq 'de'          &&
     $a->{"pageview-type"} eq 'wiki_index'  ,
     "WIKI_INDEX output of accept_rule_url");

  #print Dumper $a;
};

#########################################
# Testing accept_rule_url_and_referer
#########################################

{
  my $o = PageViews::Model::Sequential->new;
  $o->{last_ymd} = "2013-2";

  my $u1 = "http://ja.m.wikinews.org/w/api.php?action=mobileview&page=Radix_tree";
  my $r1 = "http://ja.m.wikinews.org/w/api.php?action=mobileview&page=Radix_tree";

  my $U1 = $o->accept_rule_url($u1);
  my $R1 = $o->accept_rule_url($r1);

  ok(!$o->accept_rule_url_and_referer($U1,$R1,$r1),"Rule url_and_referer works");

  my $u2 = "http://ja.m.wikinews.org/w/api.php?page=Radix_tree&action=mobileview";
  my $r2 = "http://ja.m.wikinews.org/w/api.php?action=mobileview&page=Radix_tree";
  my $U2 = $o->accept_rule_url($u2);
  my $R2 = $o->accept_rule_url($r2);
  ok(!$o->accept_rule_url_and_referer($U2,$R2,$r2),"Rule url_and_referer works for arbitrary parameter order");

  my $u3 = "http://ja.m.wikinews.org/w/api.php?page=Radix_tree&action=mobileview&param=true";
  my $r3 = "http://ja.m.wikinews.org/w/api.php?action=mobileview&page=Radix_tree&param=true";
  my $U3 = $o->accept_rule_url($u3);
  my $R3 = $o->accept_rule_url($r3);

  ok(!$o->accept_rule_url_and_referer($U3,$R3,$r3),"Rule url_and_referer works with arbitrary param order and some additional params");
}


############################################################
# Testing accept_rule_url_and_referer
# (new logic received on 2013-04-09)
# Email subject => Fwd: feedback mobile pageview definition
############################################################

{
  my $o = PageViews::Model::Sequential->new;
  $o->{last_ymd} = "2013-2";
  my $u1 = "https://en.m.wikipedia.org/w/api.php?format=json&action=query&prop=langlinks&llurl=true&lllimit=max&titles=Tropical+cyclone";
  my $r1 = "https://en.m.wikipedia.org/wiki/Tropical_cyclone";
  my $U1 = $o->accept_rule_url($u1);
  my $R1 = $o->accept_rule_url($r1);

  ok(!$o->accept_rule_url_and_referer($U1,$R1,$r1),"1st case mobile team");

  my $u2 = "https://en.m.wikipedia.org/w/api.php?format=json&action=mobileview&page=Tornado&variant=en&redirects=yes&prop=sections%7Ctext&noheadings=yes&sectionprop=level%7Cline%7Canchor&sections=all";
  my $r2 = "https://en.m.wikipedia.org/wiki/Tropical_cyclone";
  my $U2 = $o->accept_rule_url($u2); 
  my $R2 = $o->accept_rule_url($r2);

  ok( $o->accept_rule_url_and_referer($U2,$R2,$r2),"2nd case mobile team");

  my $u3 = "https://en.m.wikipedia.org/w/api.php?format=json&action=mobileview&page=Tornadoes+of+2013&variant=en&redirects=yes&prop=sections%7Ctext&noheadings=yes&sectionprop=level%7Cline%7Canchor&sections=all";
  my $r3 = "https://en.m.wikipedia.org/wiki/Tornado";
  my $U3 = $o->accept_rule_url($u3); 
  my $R3 = $o->accept_rule_url($r3);
  ok( $o->accept_rule_url_and_referer($U3,$R3,$r3),"3nd case mobile team");
};


