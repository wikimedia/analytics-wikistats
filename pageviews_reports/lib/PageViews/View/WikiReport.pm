package PageViews::View::WikiReport;
use strict;
use warnings;
use PageViews::Util;
use Storable;

my $SQUID_SAMPLING_FACTOR = 1000;

{
  no strict  'refs';
  *{__PACKAGE__."::how_many_days_month_has"    } = \&PageViews::Util::how_many_days_month_has    ;
  *{__PACKAGE__."::compact_days_to_months"     } = \&PageViews::Util::compact_days_to_months     ;
  *{__PACKAGE__."::sorted_months_in_counts"    } = \&PageViews::Util::sorted_months_in_counts    ;
  *{__PACKAGE__."::sorted_languages_in_counts" } = \&PageViews::Util::sorted_languages_in_counts ;
  *{__PACKAGE__."::extrapolate"                } = \&PageViews::Util::extrapolate                ;
  use strict 'refs';
};

=head1 METHODS

=cut

sub new {
  my ($class) = @_;
  return bless {}, $class;
}

sub get_data_from_model {
  my ($self,$model) = @_;

  $self->{$_} = $model->{$_}
  for 
    qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_referer
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
    __config
    /;

};


=head2 get_data_for_csv($self)

=begin html

The csv file for wikistats( PageViewsPerMonthAll.csv ) requires a csv file
with the following columns:

<ul>
  <li> language
  <li> date
  <li> pageview count
</ul>

The date column must be the last day of the month in Y/M/D format.

=end html

This method produces the necessary csv and returns it as a string


=cut


sub get_data_for_csv {
  my ($self)    = @_;
  $self->compact_days_to_months;
  my $buffer    = "";
  my @lang_sorted   = $self->sorted_languages_in_counts;
  my @months_sorted = $self->sorted_months_in_counts;
  my $D             = $self->extrapolate($SQUID_SAMPLING_FACTOR);

  for my $language (@lang_sorted) {
    for my $month ( @months_sorted ) {
      my $value  = $D->{counts}->{$month}->{$language};
      next unless defined($value) && $value > 0;
      my $lang   = lc($language);
      my ($y,$m) = $month =~ /(\d+)-(\d+)/;
      $m         = sprintf("%02d",$m);
      my $d      = how_many_days_month_has($y,$m);
      my $date   = "$y/$m/$d";
      $buffer   .= "$lang.m,$date,$value\n";
    };
  };

  return $buffer;
}


sub render {
  my ($self,$params) = @_;

  my $data = $self->get_data_for_csv();

  my $output_path = $params->{"output-path"}."/PageViewsPerMonthAll.csv";
  open my $fh,">",$output_path;

  print $fh $data;

  close $fh;
}


1;
