use strict;
use warnings;

use Test::More;

#{
#   package XML::Stream;
#   our $AUTOLOAD;
#   use Data::Dumper;
#
#   sub new {
#       bless {}, shift;
#   }
##  sub Connect {
##  }
##  sub GetErrorCode {
##  }
##
#   AUTOLOAD {
#       print Dumper [$AUTOLOAD, \@_];
#   }
#
#}
#$INC{'XML/Stream.pm'} = 1;


eval "use Test::Memory::Cycle";
my $memory_cycle = ! $@;

my $repeat = 5;
plan tests => 1 + 2 * $repeat;

# TODO ask user if it is ok to do network tests!
print_size('before loading Net::XMPP');
require Net::XMPP;
print_size('after loading Net::XMPP');
# see
# http://blogs.perl.org/users/marco_fontani/2010/03/google-talk-with-perl.html
{
  # monkey-patch XML::Stream to support the google-added JID
  package XML::Stream;
  no warnings 'redefine';

  sub SASLAuth {
    my $self         = shift;
    my $sid          = shift;
    my $first_step   = $self->{SIDS}->{$sid}->{sasl}->{client}->client_start();
    my $first_step64 = MIME::Base64::encode_base64( $first_step, "" );
    $self->Send(
      $sid,
      "<auth xmlns='"
        . &ConstXMLNS('xmpp-sasl')
        . "' mechanism='"
        . $self->{SIDS}->{$sid}->{sasl}->{client}->mechanism() . "' "
        . q{xmlns:ga='http://www.google.com/talk/protocol/auth'
            ga:client-uses-full-bind-result='true'} .    # JID
        ">" . $first_step64 . "</auth>"
    );
  }
}

my $mem1 = run();
my $mem_last = $mem1;
for (2..$repeat) {
    $mem_last = run();
}
TODO: {
   local $TODO = 'Memory leak or expectations being to high?';
   is $mem_last, $mem1, 'expected 0 memory growth';
}


sub run {
    my $conn   = Net::XMPP::Client->new;
    isa_ok $conn, 'Net::XMPP::Client';

    my $status = $conn->Connect(
        hostname       => 'talk.google.com',
        port           => 5222,
        componentname  => 'gmail.com',
        connectiontype => 'tcpip',
        tls            => 1,
        ssl_verify     => 0,
    );

    SKIP: {
        skip 'Needs Test::Memory::Cycle', 1 if not $memory_cycle; 
        memory_cycle_ok($conn, 'after calling Connect');
    }

    return print_size('after calling Connect');
}

# if (not defined $status) {
# details => $!, 
# }
#use Data::Dumper;
#die Dumper \%INC;
#foreach my $k (keys %INC) {
#    if ($k =~ /XML/) {
#       diag $k;
#    }
#}

#my ($username, $password) = ($ENV{GTALK_USER}, $ENV{GTALK_PW});
#SKIP: {
#    skip => 'need GTALK_USER and GTALK_PW', 1 if (not $username or not $password);
#
#	my ( $res, $msg ) = $conn->AuthSend(
#		username => $username,
#		password => $password,
#		resource => 'notify v1.0',
#	);
#	if (not defined $res or $res ne 'ok') {
#			$!),
#	}

sub print_size {
    my ($msg) = @_;
    return 0 if not -x '/bin/ps';
    my @lines = grep { /^$$\s/ } qx{/bin/ps -e -o pid,rss,command};
    chomp @lines;
    my $RSS;
    foreach my $line (@lines) {
        my ($pid, $rss) = split /\s+/, $line;
        diag "RSS: $rss   - $msg";
        $RSS = $rss;
    }
    return $RSS;
}

