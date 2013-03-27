package PageViews::Model::JSON;
use strict;
use warnings;
use Carp;
use JSON::XS;


# 
# Getting data from a previous run and formatting it to
# our needs
# 

sub new {
  my ($class) = @_;
  return bless {},$class;
}


sub process_files {
  my ($self,$params) = @_;

  my @json_keys = qw/
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
  my $path   = $params->{"input-path"};
  my $json_path = "$path/data.json";
  if(! -f $json_path) {
    confess "[ERROR] expected data.json in $path";
  };
  my $data = decode_json(`cat $json_path`);
  for my $key ( @json_keys ) {
    confess "[ERROR] key $key was supposed to be present in $json_path"
      if !exists $data->{$key};
    $self->{$key} = $data->{$key};
  };
  
}

1;
