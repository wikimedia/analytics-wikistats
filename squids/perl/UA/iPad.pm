package UA::iPad;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT=qw/ipad_extract_data/;


sub check_values_ok {
  my ($ipad_info) = @_;
  if( defined $ipad_info->{browser}         &&
      length( $ipad_info->{browser})    > 0 &&
      defined $ipad_info->{os_version}      &&
      length( $ipad_info->{os_version}) > 0
    ) {
      return 1;
    } else {
      return 0;
    };
}

sub uri_unescape {
    # Note from RFC1630:  "Sequences which start with a percent sign
    # but are not followed by two hexadecimal characters are reserved
    # for future extension"
    my $str = shift;
    if (@_ && wantarray) {
        # not executed for the common case of a single argument
        my @str = ($str, @_);  # need to copy
        for (@str) {
            s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        }
        return @str;
    }
    $str =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg if defined $str;
    $str;
}

#
# Look for different types of user-agents for iPad and get the version
# and the browser name
#
sub ipad_extract_data {
  my ($user_agent) = @_;

  $user_agent = uri_unescape($user_agent);

  # TODO: adding another field to this hash that will say if it's not iPad , what it is, it may be iPod/iPhone etc
  my $retval = {
    browser         => undef,
    os_version      => undef,
    flag_cfnetworks => 0,
  };

  # we use the if to have the capture variables which are localized and reset after it
  # type1
  # (note that the OS version can be separated by dots or underscores)
  if( 
     ($retval->{browser},
      $retval->{os_version}) = $user_agent =~ /^(.*?)\s*\(iPad.*?OS (\d+[\_\.]\d+)/
  ) {
    # do minor fixups on the version

    $retval->{os_version} =~ s/_/./;

    return $retval;
  };

  $retval->{browser} = undef;
  $retval->{os_version} = undef;

  # type2
  my $cfnetwork_version;
  my $darwin_version;
  my $appname;

  if(index($user_agent,"CFNetwork") != -1) {
    $retval->{flag_cfnetworks} = 1;
    if( 
      ($appname,
       $cfnetwork_version,
       $darwin_version) = $user_agent =~ /^(.*?)iPad\/(\d+\.\d+).*CFNetwork\/(.*) Darwin\/(.*)$/ 
    ) {

      $retval->{os_version} = "other";
      $retval->{browser} = $appname;

      return $retval;
    };
  };



  # type 3 (Opera user agents)
  # again, no OS version here
  if( 
    ($retval->{browser}) = $user_agent =~ /^.*\(iPad;\s*(.*?Opera[^\/]+\/\d+\.\d+).*$/ 
  ) {
    $retval->{os_version} = "other";
    return $retval;
  };


  # type 4
  if( 
    ($retval->{browser},
     $retval->{os_version} ) = $user_agent =~ /^(.*)\(iPad\/(\d+\.\d+).*$/ 
  ) {
    return $retval;
  }

  return undef;
};



1;
