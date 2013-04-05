package PageViews::Model::JSON;
use strict;
use warnings;
use Carp;
use JSON::XS;

=head1 NAME

  PageViews::Model::JSON - Model which has a json file as data source

=cut


=head1 DESCRIPTION

Because currently a run on 7 months takes around 6hours, it's best to have the results
of all computations stored on disk, so if some tweaks need to be done to the rendering of
the data, these can be done afterwards without the need to rerun the counting.

This module is mainly intended for reusing the data.json produced by a previous run.

=cut


sub new {
  my ($class) = @_;
  return bless {},$class;
}


=head2 process_files($hash)

The parameter to this method is a hash. This hash contains the configuration with which this
module is run.

There are multiple such configuration which can be found in the conf/ sub-directory of this
project.

This method finds the data.json in the input-path, parses the json file and stores the needed
keys in the class.

=cut

sub process_files {
  my ($self,$params) = @_;
  $self->{__config} = $params;

  my @json_keys = qw/
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
