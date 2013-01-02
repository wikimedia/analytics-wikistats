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

  # origins are wikipedia languages present

  my $retval = [];

  my $languages_present_uniq = {};
  my @months_present = sort { $a cmp $b }  keys %{ $self->{counts} };

  for my $month ( @months_present ) {
    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      $languages_present_uniq->{$language} = 1;
    };
  };

  my @unsorted_languages_present = keys %$languages_present_uniq;

  push @$retval , ['month' , @unsorted_languages_present ];

  for my $month ( @months_present ) {
    my $new_row = [];
    push @$new_row, $month;
    for my $language ( @unsorted_languages_present ) {
      push @$new_row, $self->{counts}->{$month}->{$language};
    };
    push @$retval , $new_row;
  };

  return {
    data => $retval
  };
};

1;
