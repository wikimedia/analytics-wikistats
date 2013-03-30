package PageViews::View::JSON;
use strict;
use warnings;
use JSON::XS;

sub new {
  my ($class) = @_;

  return bless {},$class;
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
    /;

};


sub render {
  my ($self,$params) = @_;
  my $data = {};
  $data->{$_} = $self->{$_} 
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
  /;

  my $output_path = $params->{"output-path"}."/data.json";
  open my $fh,">",$output_path;

  print $fh JSON::XS
            ->new
            ->canonical(1)
            ->pretty(1)
            ->encode($data);

  close $fh;
}

1;
