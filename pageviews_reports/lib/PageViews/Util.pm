package PageViews::Util;
use strict;
use warnings;
use Time::Piece;
use Carp;

=head1 NAME

  PageViews::Util - role with reusable methods

=cut


=head1 DESCRIPTION

This is a role consumed by the classes which need methods from it.
Methods are imported into the classes selectively, as needed.

=cut

=head2 how_many_days_month_has($y,$m)

This is a function which returns how many days the month has. It receives as parameters the year and the month.

=cut

sub how_many_days_month_has {
  my ($y,$m) = @_;
  $m = sprintf("%02d",$m);
  my $t = Time::Piece->strptime("$y-$m-01","%Y-%m-%d");
  return $t->month_last_day;
}



=head2 compact_days_to_months($self)

Because there are multiple formats of outputting the data, the processed counts are at granular as needed(for now).
We have counts for each day. Some of the views require rendering in terms of months. This method goes over all hashes
and adds up the counts from each day. It then replaces the daily counts inside the class with the monthly counts.

=cut

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


=head2 sorted_languages_in_counts($self)

This method finds a list of all the languages present in the counts.
The languages returned are sorted alphabetically.

=cut

sub sorted_languages_in_counts {
  my ($self) = @_;

  my $lang_uniq = {};
  for my $month ( keys %{ $self->{counts} } ) {
    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      $lang_uniq->{$language} = 1;
    };
  };

  return 
    sort { $a cmp $b } (keys %$lang_uniq );
}

=head2 sorted_months_in_counts($self)

This method finds all the months present in the counts.
We sort the months chronologically.

=cut

sub sorted_months_in_counts {
  my ($self) = @_;
  return
  sort { 
    my @A = split(/-/,$a);
    my @B = split(/-/,$b);
    return $A[0] <=> $B[0] ||
           $A[1] <=> $B[1]  ;
  } (keys %{ $self->{counts} } )
}


=head2 extrapolate($self,$factor)

To be implemented. This method would theoretically multiply all the pageviews by a certain factor.
It would be used in order to scale the sampled input back to the original magnitude.

=cut


sub extrapolate {
  my ($self,$factor) = @_;

  my @to_extrapolate1 = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
  /;

  my @to_extrapolate2 = qw/
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  my $D = {};

  # take all monthly language counts, add them up
  for my $month ( keys %{ $self->{counts} } ) {
    # initialized scale hash for this month
    for my $property ( @to_extrapolate1, @to_extrapolate2 ) {
      if($property ~~ @to_extrapolate1) {
        $D->{$property}->{$month} //= {};
        for my $language ( keys %{ $self->{counts}->{$month} } ) {
          $self->{$property}->{$month}->{$language} //= 0;
          my $month_language_value = $self->{$property}->{$month}->{$language};
          $D->{$property}->{$month}->{$language} = $factor * $month_language_value;
        };
      } elsif($property ~~ @to_extrapolate2) {
        $D->{$property}->{$month} //= 0;
        my $month_value = $self->{$property}->{$month} // 0;
        $D->{$property}->{$month} = $factor * $month_value;
      };
    };
  };

  return $D;
}

=head1 SEE ALSO

=begin html

<ul>
 <li> <a href="http://en.wikipedia.org/wiki/Monkey_patch">http://en.wikipedia.org/wiki/Monkey_patch</a>
 <li> <a href="http://stackoverflow.com/questions/449690/how-can-i-monkey-patch-an-instance-method-in-perl">Stackoverflow page on monkey patching</a>
</ul>

=end html

=cut

1;
