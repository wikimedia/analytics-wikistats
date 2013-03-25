package PageViews::Model::Sequential;
use strict;
use warnings;
use File::Basename qw/basename/;
use Data::Dumper;
use List::Util qw/sum max/;
use PageViews::Field::Parser;
use PageViews::BotDetector;
use Time::Piece;

my $MINIMUM_EXPECTED_FIELDS = 9;
my $ONE_DAY = 86_400;

#
# Generate all possible valid urls for mobile pages and make a hash with those as keys.
# The values will indicate what kind of url it is.
#

sub build_accepted_url_map {
  my $h = {};
  my @languages = (
    'en', 'de', 'fr', 'nl', 'it', 'pl', 'es', 'ru', 'ja', 'pt', 'sv', 'zh', 'uk', 'ca', 
    'no', 'fi', 'cs', 'hu', 'tr', 'ro', 'ko', 'vi', 'da', 'ar', 'eo', 'sr', 'id', 'lt', 
    'vo', 'sk', 'he', 'fa', 'bg', 'sl', 'eu', 'war', 'lmo', 'et', 'hr', 'new', 'te',
    'nn', 'th', 'gl', 'el', 'ceb', 'simple', 'ms', 'ht', 'bs', 'bpy', 'lb', 'ka', 'is',
    'sq', 'la', 'br', 'hi', 'az', 'bn', 'mk', 'mr', 'sh', 'tl', 'cy', 'io', 'pms',
    'lv', 'ta', 'su', 'oc', 'jv', 'nap', 'nds', 'scn', 'be', 'ast', 'ku', 'wa', 'af',
    'be-x-old', 'an', 'ksh', 'szl', 'fy', 'frr', 'yue', 'ur', 'ia', 'ga', 'yi', 'sw', 'als',
    'hy', 'am', 'roa-rup', 'map-bms', 'bh', 'co', 'cv', 'dv', 'nds-nl', 'fo', 'fur', 'glk', 'gu',
    'ilo', 'kn', 'pam', 'csb', 'kk', 'km', 'lij', 'li', 'ml', 'gv', 'mi', 'mt', 'nah',
    'ne', 'nrm', 'se', 'nov', 'qu', 'os', 'pi', 'pag', 'ps', 'pdc', 'rm', 'bat-smg', 'sa',
    'gd', 'sco', 'sc', 'si', 'tg', 'roa-tara', 'tt', 'to', 'tk', 'hsb', 'uz', 'vec', 'fiu-vro',
    'wuu', 'vls', 'yo', 'diq', 'zh-min-nan', 'zh-classical', 'frp', 'lad', 'bar', 'bcl', 'kw', 'mn', 'haw',
    'ang', 'ln', 'ie', 'wo', 'tpi', 'ty', 'crh', 'jbo', 'ay', 'zea', 'eml', 'ky', 'ig',
    'or', 'mg', 'cbk-zam', 'kg', 'arc', 'rmy', 'gn', '(closed)', 'so', 'kab', 'ks', 'stq', 'ce',
    'udm', 'mzn', 'pap', 'cu', 'sah', 'tet', 'sd', 'lo', 'ba', 'pnb', 'iu', 'na', 'got',
    'bo', 'dsb', 'chr', 'cdo', 'hak', 'om', 'my', 'sm', 'ee', 'pcd', 'ug', 'as', 'ti',
    'av', 'bm', 'zu', 'pnt', 'nv', 'cr', 'pih', 'ss', 've', 'bi', 'rw', 'ch', 'arz',
    'xh', 'kl', 'ik', 'bug', 'dz', 'ts', 'tn', 'kv', 'tum', 'xal', 'st', 'tw', 'bxr',
    'ak', 'ab', 'ny', 'fj', 'lbe', 'ki', 'za', 'ff', 'lg', 'sn', 'ha', 'sg', 'ii',
    'cho', 'rn', 'mh', 'chy', 'ng', 'kj', 'ho', 'mus', 'kr', 'hz', 'mwl', 'pa', 'xmf', 'lez'
  );
  for my $l(@languages) {
    for my $p1 ("http","https") {
      for my $p2 ("","www") {
        for my $p3 ("m","zero") {
          $h->{ "$p1://$p2$l.$p3.wikipedia.org/wiki/"} = ["wiki_basic",$l];
        };
      };
    };
  };

  return $h;
}


sub new {
  my ($class) = @_;
  my $raw_obj = {
    current_file_processed      => undef,
    # counts is  counts_wiki_basic + counts_wiki_index + counts_api
    counts                      => {},

    # count for /wiki/
    counts_wiki_basic           => {},
    # count for /w/index.php
    counts_wiki_index           => {},
    # count for /w/api.php
    counts_api                  => {},

    bdetector                   => PageViews::BotDetector->new(),

    last_ymd                    => undef,
    fh_dbg_accepted             => undef,
    fh_dbg_discarded            => undef,

    counts_discarded_bots       => {},
    counts_discarded_url        => {},
    counts_discarded_time       => {},
    counts_discarded_fields     => {},
    counts_discarded_status     => {},
    counts_discarded_mimetype   => {},

    counts_mimetype             => {},
    accept_hash                 => build_accepted_url_map(),
  };
  $raw_obj->{bdetector}->load_ip_ranges();
  $raw_obj->{bdetector}->load_useragent_regex();

  my $obj     = bless $raw_obj,$class;

  return $obj;
};


sub discard_rule_time {
  my ($self,$tp) = @_;
  if(!$tp) {
    return 1;
  };
  
  if(!(defined($tp) && ($tp >= $self->{tp_start} && $tp < $self->{tp_end}) )) {
    #print {$self->{fh_dbg_discarded}} $line;
    if($self->{last_ymd}) {
      $self->{counts_discarded_time}->{$self->{last_ymd}}++;
    };
    return 1;
  };

  return 0;
}

sub discard_rule_bot_ua {
  my ($self,$ua) = @_;
  my $bdetector = $self->{bdetector};
  if( defined($ua) && $bdetector->match_ua($ua) ) {
    #print "[DBG] bot_ua_discard\n";
    #print { $self->{fh_dbg_bots} } $line;
    $self->{counts_discarded_bots}->{$self->{last_ymd}}++;
    return 1;
  };

  return 0;
}

sub discard_rule_status_code {
  my ($self,$req_status) = @_;
  #302 304 and 20x
  if(!( defined($req_status) && $req_status =~ m{20\d|30[24]}  )) {
    #print "[DBG] reqstatus_discarded\n";
    #print { $self->{fh_dbg_status} } $line;
    $self->{counts_discarded_status}->{$self->{last_ymd}}++;
    return 1;
  };
  return 0;
}

sub discard_rule_bot_ip {
  my ($self,$ip) = @_;
  my $bdetector = $self->{bdetector};
  my $label_ip = $bdetector->match_ip($ip);

  if( $label_ip ) {
    $self->{counts_discarded_bots}->{$self->{last_ymd}}++;
    return 1;
  };
  return 0;
}

sub discard_rule_wikiproject {
  my ($self,$url) = @_;
  # arrayref with 2 values
  # first  value is one of "wiki" or "api" depending on whether it is a /wiki/ request or a /w/api.php
  # second value is the actual wikiproject

  my @url_captures = $url =~ m{^(https?://[^\.]+\.(?:m)\.wikipedia.org/wiki/)};
  my $h_key = $url_captures[0];
  if( !defined($h_key) ) {
    #print "$url\n";
    #print {$self->{fh_dbg_discarded}} $line;
    $self->{counts_discarded_url}->{$self->{last_ymd}}++;
    return 0;
  };
  #print "$h_key\n" if $h_key;
  my $wikiproject_pair = $self->{accept_hash}->{$h_key};

  if( !(defined($wikiproject_pair) && @$wikiproject_pair ==2 ) ) {
    $self->{counts_discarded_url}->{$self->{last_ymd}}++;
    return 0;
  };

  return $wikiproject_pair;
}

sub discard_rule_method {
  my ($self,$method) = @_;
  if( $method ne 'GET' ) {
    return 1;
  };

  return 0;
}

sub discard_rule_mimetype {
  my ($self,$mime_type) = @_;
  ## text/html mime types only
  ## (mimetype filtering only occurs for regular pageviews, not for the API ones) 
  if( $mime_type !~ m{text/html|text/vnd\.wap\.wml|application/json}i ) {
    #print "[DBG] mime_discard\n";
    #print { $self->{fh_dbg_mimetype} } $line;
    $self->{counts_discarded_mimetype}->{$self->{last_ymd}}++;
    return 1;
  };
  return 0;
}

sub process_line {
  my ($self,$line) = @_;
  # after 2013-02-01 the logs changed to having tab-separated fields instead of space separated
  my @fields = split(/\s|\t/,$line);

  if(@fields < $MINIMUM_EXPECTED_FIELDS) {
    #print {$self->{fh_dbg_discarded}} $line;
    #print { $self->{fh_dbg_fields} } $line;
    $self->{counts_discarded_fields}->{$self->{last_ymd}}++;
    return;
  };
   
  # get time in format YYYY-MM-DDTHH:MM:SS (without milliseconds)  
  my $time       = substr($fields[2],0,19) ;
  my $method     = $fields[7] ;
  my $url        = $fields[8] ;
  my $ip         = $fields[4] ;
  my $ua         = $fields[13];
  my $req_status = $fields[5] ;
  my $mime_type  = $fields[10];
  my $referer    = $fields[11];

  my $tp = Time::Piece->strptime($time,"%Y-%m-%dT%H:%M:%S");


  my $ymd = $tp->year."-".$tp->mon.'-'.$tp->mday; 
  $self->{last_ymd} = $ymd;


  return if $self->discard_rule_time($tp);
  return if $self->discard_rule_status_code($req_status);
  return if $self->discard_rule_bot_ip($ip);
  return if $self->discard_rule_bot_ua($ua);
  return if !(my $wikiproject_pair = $self->discard_rule_wikiproject($url));
  return if $self->discard_rule_method($method);
  return if $self->discard_rule_mimetype($mime_type);

  my ($pv_type,
      $pv_wikiproject) = @$wikiproject_pair;

  # counts together /wiki/ and /w/api.php
  $self->{"counts"         }->{$ymd}->{$pv_wikiproject}++;
  # counts /wiki/ separated from /w/api.php
  $self->{"counts_$pv_type"}->{$ymd}->{$pv_wikiproject}++;
};

sub open_dbg_fh {
  my ($self) = @_;
  print "[DBG] OPEN_DBG_FH\n";
  print "[DBG] $self->{current_file_processed} \n";
  my $path = "/tmp/discarded/".basename($self->{current_file_processed});
  print "[DBG] $path\n";
  `mkdir /tmp/discarded` if(! -d "/tmp/discarded");

  my $path_accepted   = $path;
  my $path_discarded  = $path;

  $path_accepted             =~ s/\.gz$/.accepted/;
  $path_discarded            =~ s/\.gz$/.discarded/;

  open my $fh_dbg_accepted   , ">$path_accepted" ;
  open my $fh_dbg_discarded  , ">$path_discarded";

  $self->{fh_dbg_accepted}   = $fh_dbg_accepted  ;
  $self->{fh_dbg_discarded}  = $fh_dbg_discarded ;
};

sub close_dbg_fh {
  my ($self) = @_;
  for my $key (%$self) {
    next unless $key =~ /^fh_dbg_/;
    close($self->{$key});
  };
};

sub process_file {
  my ($self,$filename) = @_;
  $self->{current_file_processed} = $filename;
  $self->open_dbg_fh;

  print "[DBG] process_file => $filename\n";
  open IN, "-|", "unpigz -c $filename";
  #open IN, "-|", "gzip -dc $filename";
  while( my $line = <IN>) {
    $self->process_line($line);
  };
  close IN;
  $self->close_dbg_fh;
};

# adds zero padding for a 2 digit number
sub padding_2 { 
    $_[0]<10 ? "0$_[0]" : $_[0];
};

sub get_files_in_interval {
  my ($self,$params) = @_;
  my @retval = ();
  my $squid_logs_path   = $params->{"input-path"};
  my $squid_logs_prefix = $params->{"logs-prefix"};

  $params->{start}->{month} = padding_2($params->{start}->{month});
  $params->{end}->{month}   = padding_2($params->{end}->{month});

  my $time_start    = $params->{start}->{year}."-".$params->{start}->{month}."-01T00:00:00";
  my $time_end      = $params->{end}->{year}."-"  .$params->{end}->{month}."-01T00:00:00";
  my $tp_start      = Time::Piece->strptime($time_start,"%Y-%m-%dT%H:%M:%S"); 
  my $tp_end1       = Time::Piece->strptime(  $time_end,"%Y-%m-%dT%H:%M:%S");
  my $lday          = $tp_end1->month_last_day;
  my $tp_end        = Time::Piece->strptime($params->{end}->{year}."-".$params->{end}->{month}."-".$lday."T00:00:00","%Y-%m-%dT%H:%M:%S");
  $tp_end          += $ONE_DAY;

  $self->{tp_start} = $tp_start;
  $self->{tp_end}   = $tp_end;


  #print "start=>$tp_start\n";
  #print "  end=>$tp_end\n";
  my @all_squid_files =
  sort {
    ($a=~/(\d{8})/)[0] <=>
    ($b=~/(\d{8})/)[0]
  } <$squid_logs_path/$squid_logs_prefix*.gz>;
  for my $log_filename (@all_squid_files) {
    if(my ($y,$m,$d) = $log_filename =~ /(\d{4})(\d{2})(\d{2})\.gz$/) {
      my  $tp_log  =  Time::Piece->strptime( "$y-$m-$d"."T00:00:00" ,"%Y-%m-%dT%H:%M:%S"); 
      if( $tp_log >= $tp_start && $tp_log < $tp_end ) {
        #print "fn=>$log_filename\n";
        push @retval,$log_filename;
      };
    };
  };

  #warn Dumper \@retval;
  #exit 0;
  return @retval;
};

sub process_files  {
  my ($self, $params) = @_;
  for my $gz_logfile ($self->get_files_in_interval($params)) {
    $self->process_file($gz_logfile);
  };
};


# safe division, truncate to 2 decimals
sub safe_division {
  my ($self,$numerator,$denominator) = @_;
  my $retval;

  if(defined($numerator) && defined($denominator)) {
    my $percent;
    if($denominator == 0) {
      if($numerator == 0) {
        $percent = 0;
      } else {
        $percent = 100;
      };
    } else {
      $percent = ($numerator / $denominator) * 100;
    };

    $retval = sprintf("%.2f", $percent);
  } else {
    $retval = 0;
  };

  return $retval;
};


sub format_delta {
  my ($self,$val) = @_;

  if(defined($val)) {
    my $sign;
    if(        $val > 0) {
      $sign = "+";
      $val = "$sign$val%";
    } elsif(   $val < 0) {
      $val = "$val%";
    };
  };

  return $val;
};

sub format_rank {
  my ($self,$rank) = @_;
  if(     $rank == 1) {
    $rank  = "1st";
  } elsif($rank == 2) {
    $rank  = "2nd";
  } elsif($rank == 3) {
    $rank  = "3rd";
  } else {
    $rank .= "th";
  };
  return $rank;
};


sub _simulate_big_numbers {
  my ($self) = @_;
  for my $month ( keys %{$self->{counts}} ) {
    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      #$self->{counts}->{$month}->{$language} *= 1000;
      if($self->{counts}->{$month}->{$language} <= 300) {
         $self->{counts}->{$month}->{$language} *= 100;
      } else {
         $self->{counts}->{$month}->{$language} *= 1000;
      };
    };
  };
};

# gets languages sorted by absolute total
#
sub get_totals_sorted_months_present_in_data {
  my ($self,$languages_present_uniq,$language_totals) = @_;
  my @unsorted_languages_present = keys %$languages_present_uniq;
  my @sorted_languages_present = 
    sort { $language_totals->{$b} <=> $language_totals->{$a} }
    @unsorted_languages_present;

  return @sorted_languages_present;
};

# gets temporaly sorted months present in data
# 
sub get_time_sorted_months_present_in_data {
  my ($self) = @_;
  my @retval =
    sort 
      { 
        my ($Y_a,$m_a) = $a =~ /^(\d+)-(\d+)$/;
        my ($Y_b,$m_b) = $b =~ /^(\d+)-(\d+)$/;
        
        $Y_a <=> $Y_b ||
        $m_a <=> $m_b  ;
      }  
        keys %{ $self->{counts} };

  #warn Dumper \@retval;
  return @retval;
};



sub third_pass_chart_data {
  my ($self,$languages,$months) = @_;

  my $chart_data             = {};
  for my $month ( @$months ) {
    for my $language ( keys %$languages ) {
      $chart_data->{$language}->{counts} //= [];
      $chart_data->{$language}->{months} //= [];
      push @{ $chart_data->{$language}->{counts} } , ($self->{counts}->{$month}->{$language} // 0);
      push @{ $chart_data->{$language}->{months} } , $month;
    };
  };

  return $chart_data;

};



sub first_pass_languages_totals {
  my ($self) = @_;

  my @months_present = $self->get_time_sorted_months_present_in_data;

  my $languages_present_uniq = {};
  my $month_totals           = {};
  my $month_rankings         = {};
  my $language_totals        = {};

  # mark all languages present in a hash
  # calculate monthly  totals
  # calculate monthly  rankings
  # calculate language totals
  for my $month ( @months_present ) {
    # languages sorted for this month

    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      $languages_present_uniq->{$language}  = 1;
      $month_totals->{$month}              += $self->{counts}->{$month}->{$language}  ;
      $language_totals->{$language}        += $self->{counts}->{$month}->{$language}  ;
    };

  };

  return {
    months_present          => \@months_present       ,
    languages_present_uniq  => $languages_present_uniq,
    month_totals            => $month_totals          ,
    month_rankings          => $month_rankings        ,
    language_totals         => $language_totals       ,
  };
};

sub second_pass_rankings {
  my ($self,$languages,$months) = @_;

  my $month_rankings = {};
  for my $month ( @$months ) {
    # compute rankings and store them in $month_rankings
    my $rankings = {};

    my $month_languages_sorted = [];

    for my $language ( keys %$languages ) {
       push @$month_languages_sorted, 
              [ $language, ($self->{counts}->{$month}->{$language} // 0) ];
    };

    @$month_languages_sorted = 
      sort { $b->[1] <=> $a->[1]  } 
      @$month_languages_sorted;

    $rankings->{$month_languages_sorted->[$_]->[0]} = 1+$_
      for 0..(-1+@$month_languages_sorted);

    $month_rankings->{$month} = $rankings;
  };
  return $month_rankings;
};

sub scale_m_to_30 {
  my ($self,$month,$value) = @_;
  my $SCALE_FACTOR = 30;
  my $days_month_has = how_many_days_month_has(split(/-/,$month));
  my $scaled_value = int( ($value / $days_month_has) * $SCALE_FACTOR );
  return $scaled_value;
};

sub scale_months_to_30 {
  my ($self) = @_;

  my @to_scale1 = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
  /;

  my @to_scale2 = qw/
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  my $scaled = {};

  # take all monthly language counts, add them up
  for my $month ( keys %{ $self->{counts} } ) {
    # initialized scale hash for this month
    for my $property ( @to_scale1, @to_scale2 ) {
      if($property ~~ @to_scale1) {
        $scaled->{$property}->{$month} //= {};
        for my $language ( keys %{ $self->{counts}->{$month} } ) {
          $self->{$property}->{$month}->{$language} //= 0;
          my $month_language_value = $self->{$property}->{$month}->{$language};
          $scaled->{$property}->{$month}->{$language} = $self->scale_m_to_30($month,$month_language_value);
        };
      } elsif($property ~~ @to_scale2) {
        $scaled->{$property}->{$month} //= 0;
        $scaled->{$property}->{$month}  += $self->{$property}->{$month};
      };
    };
  };

  # place scaled property hashes back into the current object

  for my $property ( @to_scale1, @to_scale2 ) {
    $self->{$property} = $scaled->{$property};
  };
};


# 
# 
# 
# 

sub get_data_view_wikireport {
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



#
# Group the counts from days to months
# (basically adding everything as needed)
#

sub compact_days_to_months {
  my ($self) = @_;
  my @to_compact1 = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
  /;

  my @to_compact2 = qw/
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  my $compact = {};

  my $month;
  # take all monthly language counts, add them up
  for my $day ( keys %{ $self->{counts} } ) {
    ($month) = $day =~ /^(\d{4}-\d{2})/;
    # initialized scale hash for this month
    for my $property ( @to_compact1, @to_compact2 ) {
      $compact->{$property}->{$month} //= {};
      for my $language ( keys %{ $self->{counts}->{$day} } ) {
        if($property ~~ @to_compact1) {
          $compact->{$property}->{$month}->{$language} //= 0;
          $compact->{$property}->{$month}->{$language}  += 
             $self->{$property}->{$day}->{$language};
        };
        if($property ~~ @to_compact2) {
          $compact->{$property}->{$month} //= 0;
          $compact->{$property}->{$month}  += 
             $self->{$property}->{$day};
        };
      };
    };
  };

  for my $property ( @to_compact1, @to_compact2 ) {
    $self->{$property} = $compact->{$property};
  };
}


#
# Format data in a nice way so we can pass it to the templating engine
# (for PageViews::View::Web
#

sub get_data_view_web {
  my ($self) = @_;

  $self->compact_days_to_months;
  $self->scale_months_to_30;

  my $data = [];

  #$self->_simulate_big_numbers();

  my $__first_pass_retval    = $self->first_pass_languages_totals;

  my @months_present         = @{ $__first_pass_retval->{months_present} };
  my $languages_present_uniq =    $__first_pass_retval->{languages_present_uniq};
  my $month_totals           =    $__first_pass_retval->{month_totals};
  my $language_totals        =    $__first_pass_retval->{language_totals};

  my $month_rankings         = $self->second_pass_rankings(  $languages_present_uniq , \@months_present );
  my $chart_data             = $self->third_pass_chart_data( $languages_present_uniq , \@months_present );

  my $min_language_delta = +999_999;
  my $max_language_delta = -999_999;

  # TODO: call function here to produce the many hashes

  my $LANGUAGES_COLUMNS_SHIFT = 2;

  my @sorted_languages_present = 
    $self->get_totals_sorted_months_present_in_data(
      $languages_present_uniq,
      $language_totals
    );

  for my $idx_month ( 0..$#months_present ) {
    my $month = $months_present[$idx_month];

    warn "[DBG] Processing month => $month";
    my   $new_row = [];
    push @$new_row, $month;
    push @$new_row, $month_totals->{$month};

    # idx_language is the index of the current language inside sorted_languages_present
    for my $idx_language ( 0..$#sorted_languages_present ) {
      my $language = $sorted_languages_present[$idx_language];
      #warn "language=$language";
      # hash containing actual count, percentage of monthly total, increase over past month
      my $percentage_of_monthly_total ;
      my $monthly_delta               ;
      my $monthly_count               ;
      my $monthly_count_previous      ;

      if(@$data > 0) {
        #warn "[DBG] idx_language = $idx_language";
        #warn Dumper $data->[-1];
        $monthly_count_previous = $data->[-1]->[$idx_language + $LANGUAGES_COLUMNS_SHIFT]->{monthly_count} // 0;
      } else {
        $monthly_count_previous = 0;
      };
      $monthly_count               = $self->{counts}->{$month}->{$language} // 0;
      $percentage_of_monthly_total = $self->safe_division($monthly_count , $month_totals->{$month});

      # safety check
      # if we have at least one month to compare to
      # and the previous month has a non-zero count

      #warn "[DBG] monthly_count_previous = $monthly_count_previous";
      $monthly_delta               = $self->safe_division(
                                        $monthly_count - $monthly_count_previous,
                                        ($monthly_count_previous // 0) 
                                     );

      $min_language_delta = 
            $monthly_delta <= $min_language_delta 
             ? $monthly_delta 
             : $min_language_delta;

      $max_language_delta = 
            $monthly_delta >= $max_language_delta 
             ? $monthly_delta 
             : $max_language_delta;



      my $__monthly_delta               =  $self->format_delta($monthly_delta);
      my $rank                          =  $self->format_rank($month_rankings->{$month}->{$language} );
      my $__percentage_of_monthly_total = "$percentage_of_monthly_total%";


      push @$new_row, {
          language                      =>   $language,
          monthly_count                 =>   $monthly_count,

          breakdown_count_wiki_basic    =>   ($self->{counts_wiki_basic}->{$month}->{$language} // 0),
          breakdown_count_wiki_index    =>   ($self->{counts_wiki_index}->{$month}->{$language} // 0),
          breakdown_count_api           =>   ($self->{counts_api}->{ $month}->{$language}       // 0),

          monthly_count_wiki            =>   ( 
                                               ($self->{counts_wiki_basic}->{$month}->{$language} // 0) + 
                                               ($self->{counts_wiki_index}->{$month}->{$language} // 0)
                                             ),
          monthly_count_api             =>   ($self->{counts_api}->{ $month}->{$language} // 0),
          monthly_delta__               =>   ($idx_month == 0 ? "--" : $__monthly_delta),
          monthly_delta                 =>   ($idx_month == 0 ? 0 : $monthly_delta ),
          percentage_of_monthly_total__ =>   $__percentage_of_monthly_total,
          rank                          =>     $rank,
      };
    };
    push @$data , $new_row;
  };

  #exit -1;

  # reverse order of months
  @$data = reverse(@$data);

  # pre-pend headers
  unshift @$data, ['month' , '&Sigma;', @sorted_languages_present ];

  warn "[DBG] data.length = ".~~(@$data);
  my $big_total_processed = sum( values %$language_totals                  ) // 0;
  my $big_total_discarded = sum( values %{$self->{monthly_discarded_count}}) // 0;
  my $big_total_bots      = sum( values %{$self->{monthly_bots_count}}     ) // 0;

  my $retval = {
    # actual data for each language for each month
    data                     => $data                            ,
    # the chart data for each wikiproject
    chart_data               => $chart_data                      ,
    # the following values are used by the color ramps
    min_language_delta       => $min_language_delta              ,
    max_language_delta       => $max_language_delta              ,
    months_present           => \@months_present                 ,
    languages_present        => [ keys %$languages_present_uniq ],
    language_totals          => $language_totals                 ,
    big_total_processed      => $big_total_processed             ,
    big_total_discarded      => $big_total_discarded             ,
    big_total_bots           => $big_total_bots                  ,
  };

  $retval->{$_} = $self->{$_}
    for qw/
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

  return $retval;
};

1;
