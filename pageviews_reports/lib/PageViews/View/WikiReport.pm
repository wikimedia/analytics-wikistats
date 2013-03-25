package PageViews::View::WikiReport;
use strict;
use warnings;

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
  my $lang_uniq = {};
  my $buffer    = "";
  for my $day ( keys $self->{counts}) {
    for my $language ( keys $self->{counts}->{$day} ) {
      $lang_uniq->{$language} = 1;
    };
  };
  my @days_sorted = sort { $a cmp $b } (keys %{ $self->{counts} } );
  my @lang_sorted = sort { $a cmp $b } (keys %$lang_uniq );

  for my $day ( @days_sorted ) {
    for my $language (@lang_sorted) {
      for my $day ( @days_sorted ) {
        my $value  = $self->{counts}->{$day}->{$language};
        my $lang   = lc($language);
        my $date   = $day;
        next unless defined($value) && $value > 0;
        $date      =~ s/-/\//;
        $buffer   .= "$lang.m,$date,$value\n";
      };
    };
  };

  return $buffer;
}


sub render {
  my ($self,$params) = @_;

  my $data = $self->get_data_for_csv();

  my $output_path = $params->{"output-path"}."/PageViewsPerDayAll.csv";
  open my $fh,">",$output_path;

  print $fh $data;

  close $fh;
}


1;
