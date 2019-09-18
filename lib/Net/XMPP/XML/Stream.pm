package Net::XMPP::XML::Stream;
use XML::Stream;
use base qw(XML::Stream);

# This file is added on 2019.09.18 only to make Net::XMPP work with
# servers supporting SASL Auth via Digest-md5 method. If the original
# XML::Stream will remove force setting callback for "authname" field,
# you can switch back to it. To do it remove this file and fix
# Connection.pm to use XML::Stream instead of Net::XMPP::XML::Stream.

sub SASLClient
{
    my $self = shift;
    my $sid = shift;
    my $username = shift;
    my $password = shift;

    my $mechanisms = $self->GetStreamFeature($sid,"xmpp-sasl");

    return unless defined($mechanisms);

    # Here we assume that if 'to' is available, then a domain is being
    # specified that does not match the hostname of the jabber server
    # and that we should use that to form the bare JID for SASL auth.
    my $domain .=  $self->{SIDS}->{$sid}->{to}
        ? $self->{SIDS}->{$sid}->{to}
        : $self->{SIDS}->{$sid}->{hostname};

    my $authname = $username . '@' . $domain;

    my $sasl = Authen::SASL->new(mechanism=>join(" ",@{$mechanisms}),
                                callback=>{
                                           user     => $username,
                                           pass     => $password
                                          }
                               );

    $self->{SIDS}->{$sid}->{sasl}->{client} = $sasl->client_new('xmpp', $domain);
    $self->{SIDS}->{$sid}->{sasl}->{username} = $username;
    $self->{SIDS}->{$sid}->{sasl}->{password} = $password;
    $self->{SIDS}->{$sid}->{sasl}->{authed} = 0;
    $self->{SIDS}->{$sid}->{sasl}->{done} = 0;

    $self->SASLAuth($sid);
}

1;
