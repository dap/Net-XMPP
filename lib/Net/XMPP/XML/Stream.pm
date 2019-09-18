package Net::XMPP::XML::Stream;
use XML::Stream;
use base qw(XML::Stream);

=pod

=head2 SASLClient

This is a helper function to perform all of the required steps for doing SASL with the server.

Parameters:

sid - session id, required
username - username, without domain, required
password - raw password, required
resource - jabber resource, optional
sasl_opts - optional hashref with specific auth opts for SASL

The structure of sasl_opts is:
{
  allowed_mechanisms => arrayref, with allowed auth methods, for example ['PLAIN', 'CRAM-MD5']
  use_authzid => 0|1, to set if field authzid will be sent during auth, some servers handle this incorrectly
}

=cut


sub SASLClient
{
    my $self = shift;
    my $sid = shift;
    my $username = shift;
    my $password = shift;
    my $resource =  shift(@_) || time;
    my $sasl_opts = shift(@_) || {};

    if (!defined($sasl_opts->{allowed_mechanisms})) {
        $sasl_opts->{allowed_mechanisms} = [
            'ANONYMOUS', 'CRAM-MD5', 'DIGEST-MD5', 'EXTERNAL', 'GSSAPI',
            'LOGIN', 'PLAIN',
        ];
    };

    if (!defined($sasl_opts->{use_authzid})) {
        $sasl_opts->{'use_authzid'} = 0;
    }

    # check which mechanisms among available we can use
    my %am = ();
    foreach (@{$sasl_opts->{allowed_mechanisms}}) { $am{$_} = 1;  }

    my $available_mechanisms = $self->GetStreamFeature($sid,"xmpp-sasl");
    my $mechanisms = [];

    foreach (@$available_mechanisms) { push(@$mechanisms, $_) if $am{$_}; }

    # no avaialable mechanisms - no auth
    return unless (scalar(@$mechanisms));

    # Here we assume that if 'to' is available, then a domain is being
    # specified that does not match the hostname of the jabber server
    # and that we should use that to form the bare JID for SASL auth.
    my $domain .=  $self->{SIDS}->{$sid}->{to}
        ? $self->{SIDS}->{$sid}->{to}
        : $self->{SIDS}->{$sid}->{hostname};

    my $authname = $username . '@' . $domain . '/' . $resource;

    my $callbacks = {
        user     => $username,
        pass     => $password
    };

    if ($sasl_opts->{'use_authzid'}) {
        $callbacks->{'authname'} = $authname;
    }

    my $sasl = Authen::SASL->new(mechanism=>join(" ",@{$mechanisms}),
                                callback=> $callbacks
                               );

    $self->{SIDS}->{$sid}->{sasl}->{client} = $sasl->client_new('xmpp', $domain);
    $self->{SIDS}->{$sid}->{sasl}->{username} = $username;
    $self->{SIDS}->{$sid}->{sasl}->{password} = $password;
    $self->{SIDS}->{$sid}->{sasl}->{authed} = 0;
    $self->{SIDS}->{$sid}->{sasl}->{done} = 0;

    $self->SASLAuth($sid);
}

1;
