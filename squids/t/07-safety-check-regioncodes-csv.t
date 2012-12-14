#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use Data::Dumper;
open my $fh,"<csv/meta/RegionCodes.csv";
my $not_ok_rows = 0;
my $wrong_lines = '';
while(my $line = <$fh> ) {
  chomp $line;
  next if $line =~ /^#/;
  my @fields = split(/,/,$line);
  if($fields[1] eq 'XX' && $fields[2] ne 'X') {
    $not_ok_rows++;
    $wrong_lines.="\n$line";
  };
};

ok($not_ok_rows == 0,"Unknown regions aren't north or south, they're unknown.$wrong_lines");


