package PageViews::View;
use strict;
use warnings;
use Template;
use Carp;

sub new {
  my ($class,$data) = @_;
  my $raw_obj = {
    data => $data,
  };
  my $obj     = bless $raw_obj,$class;
  return $obj;
};

sub render {
  my ($self,$params) = @_;

  confess "[ERR]  expected param output_path"
    unless 
      exists $params->{output_path} && 
      -d $params->{output_path};

  my $output_path = $params->{output_path};

  `mkdir -p $output_path`;
  my $tt = Template->new({
      INCLUDE_PATH => "./templates",
      OUTPUT_PATH  =>  $output_path,
  }); 
  $tt->process(
    "pageviews.tt",
    $self->{data} ,
    "pageviews.html",
  ) || confess $tt->error();

  `cp -r static/ $output_path`;

};

1;
