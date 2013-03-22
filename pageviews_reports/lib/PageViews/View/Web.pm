package PageViews::View::Web;
use strict;
use warnings;
use Template;
use Carp;

sub new {
  my ($class,$data) = @_;
  my $raw_obj = {};
  my $obj     = bless $raw_obj,$class;
  return $obj;
};

sub set_data {
  my ($self,$data) = @_;
  $self->{data} = $data;
};

sub render {
  my ($self,$params) = @_;

  confess "[ERR] expected param output-path"
    unless exists $params->{"output-path"};
  confess "[ERR] output-path doesn't exist on disk"
    unless     -d $params->{"output-path"};

  my $output_path = $params->{"output-path"};

  `mkdir -p $output_path`;
  my $tt = Template->new({
      INCLUDE_PATH => "./templates",
      OUTPUT_PATH  => $output_path,
      DEBUG        => 1,
  }); 
  $tt->process(
    "pageviews.tt",
    $self->{data} ,
    "pageviews.html",
  ) || confess $tt->error();

  `cp -r static/ $output_path`;

};

1;
