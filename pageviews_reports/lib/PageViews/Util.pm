package PageViews::Util;
use strict;
use warnings;
use Time::Piece;

#
# This module contains methods that are injected where they are needed.
#
# More details:
#
#   * http://en.wikipedia.org/wiki/Monkey_patch
#   * http://stackoverflow.com/questions/449690/how-can-i-monkey-patch-an-instance-method-in-perl
#
#


sub how_many_days_month_has {
  my ($y,$m) = @_;
  $m = sprintf("%02d",$m);
  my $t = Time::Piece->strptime("$y-$m-01","%Y-%m-%d");
  return $t->month_last_day;
}


#
# Group the counts from days to months
# (basically adding everything as needed)
#

sub compact_days_to_months {
  my ($self) = @_;
  my @to_compact1 = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
  /;

  my @to_compact2 = qw/
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  my $compact = {};

  my $month;
  # take all monthly language counts, add them up
  for my $day ( keys %{ $self->{counts} } ) {
    ($month) = $day =~ /^(\d{4}-\d+)-/;
    # initialized scale hash for this month
    for my $property ( @to_compact1, @to_compact2 ) {
      $compact->{$property}           //= {};
      $compact->{$property}->{$month} //= {};
      for my $language ( keys %{ $self->{counts}->{$day} } ) {
        if($property ~~ @to_compact1) {
          $compact->{$property}->{$month}->{$language} //= 0;
          $compact->{$property}->{$month}->{$language}  += 
             $self->{$property}->{$day}->{$language};
        };
        if($property ~~ @to_compact2) {
          $compact->{$property}->{$month} //= 0;
          $compact->{$property}->{$month}  += 
             $self->{$property}->{$day};
        };
      };
    };
  };

  for my $property ( @to_compact1, @to_compact2 ) {
    $self->{$property} = $compact->{$property};
  };
}

1;
