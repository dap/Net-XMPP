##############################################################################
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the
#  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
#  Boston, MA  02111-1307, USA.
#
#  Copyright (C) 1998-2004 Jabber Software Foundation http://jabber.org/
#
##############################################################################

package Net::XMPP::X;

=head1 NAME

Net::XMPP::X - XMPP X Module

=head1 SYNOPSIS

  Net::XMPP::X is a companion to the Net::XMPP module. It
  provides the user a simple interface to set and retrieve all
  parts of an XMPP X.

=head1 DESCRIPTION

  Net::XMPP::X differs from the other modules in that its behavior
  and available functions are based off of the XML namespace that is
  set in it.  This module is mainly a place holder for Net::Jabber or
  others to inherit and populate with their own namespaces.

  Each of these namespaces provide Net::XMPP::X with the functions
  to access the data.  By using the AUTOLOAD function the functions for
  each namespace is used when that namespace is active.

  A Net::XMPP can be retrieved from another object passed to a callback
  function.  Also, the first argument to the callback functions is the
  session ID from XML::Streams.  There are some cases where you might
  want this information, like if you created a Client that connects to
  two servers at once, or for writing a mini server.

    use Net::XMPP qw(Client);

    sub messageCB {
      my ($Mess) = @_;
      my $x = $Mess->GetX("custom:namespace");
      .
      .
      .
    }

  You now have access to all of the retrieval functions available.

  To create a new x to send to the server:

    use Net::XMPP qw(Client);

    my $message = new Net::XMPP::Message();
    my $x = $message->NewX("other-custom-namespace");

  Now you can call the creation functions for the X as defined in the
  proper namespace.  See below for the general <x/> functions broken down
  by namespace.

=head1 METHODS

=head2 Generic Retrieval functions

  GetXMLNS() - returns a string with the namespace of the packet that
               the <x/> contains.

               $xmlns = $X->GetXMLNS();

  GetX(string) - since the behavior of this module depends on the
                 namespace, an X object may contain X objects. This
                 helps to leverage code reuse by making children
                 behave in the same manner.  More than likely this
                 function will never be called.

                 @x = GetX();
                 @x = GetX("urn:you:xml:data");

=head2 Generic Creation functions

  SetXMLNS(string) - sets the xmlns of the <x/> to the string.

                     $X->SetXMLNS("http://server/unique/path");


=head1 CUSTOM NAMESPACES

  Part of the flexability of this module is that you can define your own
  namespace.  For more information on this topic, please read the
  Net::XMPP::Namespaces man page.

=head1 AUTHOR

Ryan Eatmon

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use Carp;
use vars qw( %FUNCTIONS %NAMESPACES %TAGS );
use base qw( Net::XMPP );

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = { };

    bless($self, $proto);

    $self->{DEBUGHEADER} = "X";

    $self->{DATA} = {};
    $self->{CHILDREN} = {};

    $self->{TAG} = "x";

    if ("@_" ne (""))
    {
        if (ref($_[0]) eq "Net::XMPP::X")
        {
            return $_[0];
        }
        else
        {
            $self->{TREE} = shift;
            $self->{TAG} = $self->{TREE}->get_tag();
            $self->ParseXMLNS();
            $self->ParseTree();
        }
    }
    else
    {
        $self->{TREE} = new XML::Stream::Node($self->{TAG});
    }

    return $self;
}


$FUNCTIONS{XMLNS}->{XPath}->{Path}  = '@xmlns';

$FUNCTIONS{X}->{XPath}->{Type}  = 'node';
$FUNCTIONS{X}->{XPath}->{Path}  = '*[@xmlns]';
$FUNCTIONS{X}->{XPath}->{Child} = 'X';
$FUNCTIONS{X}->{XPath}->{Calls} = ['Get','Defined'];

my $ns;

#------------------------------------------------------------------------------
# __netxmpp__:x:test
#------------------------------------------------------------------------------

$ns = "__netxmpptest__:x:test";

$TAGS{$ns} = "test";

$NAMESPACES{$ns}->{Bar}->{XPath}->{Path} = 'bar/text()';

$NAMESPACES{$ns}->{Foo}->{XPath}->{Path} = '@foo';

$NAMESPACES{$ns}->{Test}->{XPath}->{Type} = 'master';

#------------------------------------------------------------------------------
# __netxmpp__:x:test:two
#------------------------------------------------------------------------------

$ns = "__netxmpptest__:x:test:two";

$TAGS{$ns} = "test";

$NAMESPACES{$ns}->{Bob}->{XPath}->{Path} = 'owner/@bob';

$NAMESPACES{$ns}->{Joe}->{XPath}->{Path} = 'joe/text()';

$NAMESPACES{$ns}->{Test}->{XPath}->{Type} = 'master';

1;
