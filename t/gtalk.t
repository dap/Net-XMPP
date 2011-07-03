use strict;
use warnings;

use Test::More;


plan tests => 1;

# TODO ask user if it is ok to do network tests!

use Net::XMPP;
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

# if (not defined $status) {
# details => $!, 
# }

__END__

my ($username, $password) = ($ENV{GTALK_USER}, $ENV{GTALK_PW});
SKIP: {
    skip => 'need GTALK_USER and GTALK_PW', 1 if (not $username or not $password);

	my ( $res, $msg ) = $conn->AuthSend(
		username => $username,
		password => $password,
		resource => 'notify v1.0',
	);
	if (not defined $res or $res ne 'ok') {
			$!),
	}

