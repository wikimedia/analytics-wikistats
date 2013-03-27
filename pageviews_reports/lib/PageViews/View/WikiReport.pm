package PageViews::View::WikiReport;
use strict;
use warnings;
use PageViews::Util;

{
  no strict  'refs';
  *{__PACKAGE__."::how_many_days_month_has"} = \&PageViews::Util::how_many_days_month_has;
  *{__PACKAGE__."::compact_days_to_months" } = \&PageViews::Util::compact_days_to_months ;
  use strict 'refs';
};

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
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
    /;

};




sub get_data_for_csv {
  my ($self)    = @_;

  $self->compact_days_to_months;

  my $lang_uniq = {};
  my $buffer    = "";

  for my $month ( keys $self->{counts}) {
    for my $language ( keys $self->{counts}->{$month} ) {
      $lang_uniq->{$language} = 1;
    };
  };
  my @months_sorted = sort { 
    my @A = split(/-/,$a);
    my @B = split(/-/,$b);
    return $A[0] <=> $B[0] ||
           $A[1] <=> $B[1]  ;
  } (keys %{ $self->{counts} } );
  my @lang_sorted   = sort { $a cmp $b } (keys %$lang_uniq );

  for my $month ( @months_sorted ) {
    for my $language (@lang_sorted) {
      for my $month ( @months_sorted ) {
        my $value  = $self->{counts}->{$month}->{$language};
        my $lang   = lc($language);
        next unless defined($value) && $value > 0;
        $value    *= 1000;
        my ($y,$m) = $month =~ /(\d+)-(\d+)/;
        $m         = sprintf("%02d",$m);
        my $d      = how_many_days_month_has($y,$m);
        my $date   = "$y/$m/$d";
        $buffer   .= "$lang.m,$date,$value\n";
      };
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
