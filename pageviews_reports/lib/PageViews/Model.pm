package PageViews::Model;
use strict;
use warnings;
use Time::Piece;

sub new {
  my ($class) = @_;
  my $raw_obj = {
    counts => {},
  };
  my $obj     = bless $raw_obj,$class;
  return $obj;
};

sub process_line {
  my ($self,$line) = @_;
  my @fields = split(/\s/,$line);
  #use Data::Dumper;
  #warn Dumper \@fields;
  my $time    = $fields[2];
  my $url     = $fields[8];
  my $country = $fields[14];

  #warn "[DBG] line = $line";
  #warn "[DBG] country = $country";
  #warn "[DBG] url     = $url    ";
  #warn "[DBG] time    = $time   ";

  my $tp    = Time::Piece->strptime($time,"%Y-%m-%dT%H:%M:%S.000");
  my $ymd = $tp->year."-".$tp->mon; # = ..

  $self->{counts}->{$ymd}->{$country}++;
};

sub process_file {
  my ($self,$filename) = @_;
  open IN, "-|", "gzip -dc $filename";
  while( my $line = <IN>) {
    $self->process_line($line);
  };
};

sub process_files  {
  my ($self, $params) = @_;
  for my $gz_logfile (split(/\n/,`ls $params->{logs_path}/*.gz`) ) {
    $self->process_file($gz_logfile);
  };
};

sub get_data {
  my ($self) = @_;
  return $self->{counts};
};

1;
