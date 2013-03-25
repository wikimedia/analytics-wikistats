package PageViews::View::WikiReport;

sub new {
  my ($class) = @_;
  return bless {}, $class;
}

sub set_data {
  my ($self,$data) = @_;
  $self->{data} = $data;
}

sub render {
  my ($self,$params) = @_;

  my $output_path = $params->{"output-path"}."/PageViewsPerDayAll.csv";
  open my $fh,">",$output_path;

  print $fh $self->{data};

  close $fh;
}


1;
