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

package Net::XMPP::Query;

=head1 NAME

Net::XMPP::Query - XMPP Query Module

=head1 SYNOPSIS

  Net::XMPP::Query is a companion to the Net::XMPP::IQ module. It
  provides the user a simple interface to set and retrieve all
  parts of an XMPP IQ Query.

=head1 DESCRIPTION

  Net::XMPP::Query differs from the other modules in that its behavior
  and available functions are based off of the XML namespace that is
  set in it.  The current supported namespaces are:

    urn:ietf:params:xml:ns:xmpp-bind
    urn:ietf:params:xml:ns:xmpp-session
    jabber:iq:roster

  For more information on what these namespaces are for read the IETF
  XMPP-Core and XMPP-IM RFCs.

  Each of these namespaces provide Net::XMPP::Query with the functions
  to access the data.  By using the AUTOLOAD function the functions for
  each namespace is used when that namespace is active.

  A Net::XMPP::IQ object is passed to the callback function for the
  message.  Also, the first argument to the callback functions is the
  session ID from XML::Streams.  There are some cases where you might
  want this information, like if you created a Client that connects to
  two servers at once, or for writing a mini server.

    use Net::XMPP qw(Client);

    sub iqCB {
      my ($sid,$IQ) = @_;
      my $query = $IQ->GetQuery();
      .
      .
      .
    }

  You now have access to all of the retrieval functions available for
  that namespace.

  To create a new iq to send to the server:

    use Net::XMPP;

    my $iq = new Net::XMPP::IQ();
    $query = $iq->NewQuery("jabber:iq:roster");

  Now you can call the creation functions for the Query as defined in the
  proper namespaces.  See below for the general <query/> functions, and
  in each query module for those functions.

=head1 METHODS

=head2 Retrieval functions

  GetXMLNS() - returns a string with the namespace of the query that
               the <iq/> contains.

               $xmlns  = $IQ->GetXMLNS();

  GetQuery() - since the behavior of this module depends on the
               namespace, a Query object may contain Query objects.
               This helps to leverage code reuse by making children
               behave in the same manner.  More than likely this
               function will never be called.

               @query = GetQuery()

=head2 Creation functions

  SetXMLNS(string) - sets the xmlns of the <query/> to the string.

                     $query->SetXMLNS("jabber:iq:roster");

In an effort to make maintaining this document easier, I am not going
to go into full detail on each of these functions.  Rather I will
present the functions in a list with a type in the first column to
show what they return, or take as arugments.  Here is the list of
types I will use:

  string  - just a string
  array   - array of strings
  flag    - this means that the specified child exists in the
            XML <child/> and acts like a flag.  get will return
            0 or 1.
  JID     - either a string or Net::XMPP::JID object.
  objects - creates new objects, or returns an array of
            objects.
  master  - this desribes a function that behaves like the
            SetMessage() function in Net::XMPP::Message.
            It takes a hash and sets all of the values defined,
            and the Set returns a hash with the values that
            are defined in the object.

=head1 urn:ietf:params:xml:ns:xmpp-bind

  Type     Get               Set               Defined
  =======  ================  ================  ==================
  jid      GetJID()          SetJID()          DefinedJID()
  string   GetResource()     SetResource()     DefinedResource()
  master   GetBind()         SetBind()

=head1 urn:ietf:params:xml:ns:xmpp-session

  Type     Get               Set               Defined
  =======  ================  ================  ==================
  master   GetSession()      SetSession()

=head1 jabber:iq:roster

  Type     Get               Set               Defined
  =======  ================  ================  ==================
  objects                    AddItem()
  objects  GetItems()

=head1 jabber:iq:roster - item objects

  Type     Get               Set               Defined
  =======  ================  ================  ==================
  string   GetAsk()          SetAsk()          DefinedAsk()
  array    GetGroup()        SetGroup()        DefinedGroup()
  JID      GetJID()          SetJID()          DefinedJID()
  string   GetName()         SetName()         DefinedName()
  string   GetSubscription() SetSubscription() DefinedSubscription()
  master   GetItem()         SetItem()

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

require 5.003;
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

    $self->{DEBUGHEADER} = "Query";

    $self->{DATA} = {};
    $self->{CHILDREN} = {};

    $self->{TAG} = "query";

    if ("@_" ne (""))
    {
        if (ref($_[0]) eq "Net::XMPP::Query")
        {
            return $_[0];
        }
        elsif (ref($_[0]) eq "")
        {
            $self->{TAG} = shift;
            $self->{TREE} = new XML::Stream::Node($self->{TAG});
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


$FUNCTIONS{XMLNS}->{XPath}->{Path} = '@xmlns';

$FUNCTIONS{Query}->{XPath}->{Type} = 'node';
$FUNCTIONS{Query}->{XPath}->{Path} = '*[@xmlns]';
$FUNCTIONS{Query}->{XPath}->{Child} = 'Query';
$FUNCTIONS{Query}->{XPath}->{Calls} = ['Get','Defined'];

$FUNCTIONS{X}->{XPath}->{Type} = 'node';
$FUNCTIONS{X}->{XPath}->{Path} = '*[@xmlns]';
$FUNCTIONS{X}->{XPath}->{Child} = 'X';
$FUNCTIONS{X}->{XPath}->{Calls} = ['Get','Defined'];

my $ns;

#------------------------------------------------------------------------------
# __netxmpp__:query:test
#------------------------------------------------------------------------------

$ns = "__netxmpptest__:query:test";

$TAGS{$ns} = "test";

$NAMESPACES{$ns}->{Bar}->{XPath}->{Path} = 'bar/text()';

$NAMESPACES{$ns}->{Foo}->{XPath}->{Path} = '@foo';

$NAMESPACES{$ns}->{Test}->{XPath}->{Type} = 'master';

#------------------------------------------------------------------------------
# __netxmpp__:query:test:two
#------------------------------------------------------------------------------

$ns = "__netxmpptest__:query:test:two";

$TAGS{$ns} = "test";

$NAMESPACES{$ns}->{Bob}->{XPath}->{Path} = 'owner/@bob';

$NAMESPACES{$ns}->{Joe}->{XPath}->{Path} = 'joe/text()';

$NAMESPACES{$ns}->{Test}->{XPath}->{Type} = 'master';

#-----------------------------------------------------------------------------
# urn:ietf:params:xml:ns:xmpp-bind
#-----------------------------------------------------------------------------
$ns = "urn:ietf:params:xml:ns:xmpp-bind";

$TAGS{$ns} = "bind";

$NAMESPACES{$ns}->{JID}->{XPath}->{Type} = 'jid';
$NAMESPACES{$ns}->{JID}->{XPath}->{Path} = 'jid/text()';

$NAMESPACES{$ns}->{Resource}->{XPath}->{Path} = 'resource/text()';

$NAMESPACES{$ns}->{Bind}->{XPath}->{Type} = 'master';

#-----------------------------------------------------------------------------
# urn:ietf:params:xml:ns:xmpp-session
#-----------------------------------------------------------------------------
$ns = "urn:ietf:params:xml:ns:xmpp-session";

$TAGS{$ns} = "session";

$NAMESPACES{$ns}->{Session}->{XPath}->{Type} = 'master';

#-----------------------------------------------------------------------------
# jabber:iq:privacy
#-----------------------------------------------------------------------------
$ns = "jabber:iq:privacy";

$TAGS{$ns} = "query";

$NAMESPACES{$ns}->{Active}->{XPath}->{Path} = 'active/@name';

$NAMESPACES{$ns}->{Default}->{XPath}->{Path} = 'default/@name';

$NAMESPACES{$ns}->{List}->{XPath}->{Type} = 'node';
$NAMESPACES{$ns}->{List}->{XPath}->{Path} = 'list';
$NAMESPACES{$ns}->{List}->{XPath}->{Child} = ['Query','__netxmpp__:iq:privacy:list'];
$NAMESPACES{$ns}->{List}->{XPath}->{Calls} = ['Add'];

$NAMESPACES{$ns}->{Lists}->{XPath}->{Type} = 'children';
$NAMESPACES{$ns}->{Lists}->{XPath}->{Path} = 'list';
$NAMESPACES{$ns}->{Lists}->{XPath}->{Child} = ['Query','__netxmpp__:iq:privacy:list'];
$NAMESPACES{$ns}->{Lists}->{XPath}->{Calls} = ['Get'];

#-----------------------------------------------------------------------------
# __netxmpp__:iq:privacy:list
#-----------------------------------------------------------------------------
$ns = '__netxmpp__:iq:privacy:list';

$NAMESPACES{$ns}->{Name}->{XPath}->{Path} = '@ask';

$NAMESPACES{$ns}->{Item}->{XPath}->{Type} = 'node';
$NAMESPACES{$ns}->{Item}->{XPath}->{Path} = 'item';
$NAMESPACES{$ns}->{Item}->{XPath}->{Child} = ['Query','__netxmpp__:iq:privacy:list:item'];
$NAMESPACES{$ns}->{Item}->{XPath}->{Calls} = ['Add'];

$NAMESPACES{$ns}->{Items}->{XPath}->{Type} = 'children';
$NAMESPACES{$ns}->{Items}->{XPath}->{Path} = 'item';
$NAMESPACES{$ns}->{Items}->{XPath}->{Child} = ['Query','__netxmpp__:iq:privacy:list:item'];
$NAMESPACES{$ns}->{Items}->{XPath}->{Calls} = ['Get'];

#-----------------------------------------------------------------------------
# __netxmpp__:iq:privacy:list:item
#-----------------------------------------------------------------------------
$ns = '__netxmpp__:iq:privacy:list:item';

$NAMESPACES{$ns}->{Action}->{XPath}->{Path} = '@action';

$NAMESPACES{$ns}->{IQ}->{XPath}->{Type} = 'flag';
$NAMESPACES{$ns}->{IQ}->{XPath}->{Path} = 'iq';

$NAMESPACES{$ns}->{Message}->{XPath}->{Type} = 'flag';
$NAMESPACES{$ns}->{Message}->{XPath}->{Path} = 'message';

$NAMESPACES{$ns}->{Order}->{XPath}->{Path} = '@order';

$NAMESPACES{$ns}->{PresenceIn}->{XPath}->{Type} = 'flag';
$NAMESPACES{$ns}->{PresenceIn}->{XPath}->{Path} = 'presence-in';

$NAMESPACES{$ns}->{PresenceOut}->{XPath}->{Type} = 'flag';
$NAMESPACES{$ns}->{PresenceOut}->{XPath}->{Path} = 'presence-out';

$NAMESPACES{$ns}->{Type}->{XPath}->{Path} = '@type';

$NAMESPACES{$ns}->{Value}->{XPath}->{Path} = '@value';

$NAMESPACES{$ns}->{Item}->{XPath}->{Type} = 'master';

#-----------------------------------------------------------------------------
# jabber:iq:roster
#-----------------------------------------------------------------------------
$ns = 'jabber:iq:roster';

$TAGS{$ns} = "query";

$NAMESPACES{$ns}->{Item}->{XPath}->{Type} = 'node';
$NAMESPACES{$ns}->{Item}->{XPath}->{Path} = 'item';
$NAMESPACES{$ns}->{Item}->{XPath}->{Child} = ['Query','__netxmpp__:iq:roster:item'];
$NAMESPACES{$ns}->{Item}->{XPath}->{Calls} = ['Add'];

$NAMESPACES{$ns}->{Items}->{XPath}->{Type} = 'children';
$NAMESPACES{$ns}->{Items}->{XPath}->{Path} = 'item';
$NAMESPACES{$ns}->{Items}->{XPath}->{Child} = ['Query','__netxmpp__:iq:roster:item'];
$NAMESPACES{$ns}->{Items}->{XPath}->{Calls} = ['Get'];

#-----------------------------------------------------------------------------
# __netxmpp__:iq:roster:item
#-----------------------------------------------------------------------------
$ns = '__netxmpp__:iq:roster:item';

$NAMESPACES{$ns}->{Ask}->{XPath}->{Path} = '@ask';

$NAMESPACES{$ns}->{Group}->{XPath}->{Type} = 'array';
$NAMESPACES{$ns}->{Group}->{XPath}->{Path} = 'group/text()';

$NAMESPACES{$ns}->{JID}->{XPath}->{Type} = 'jid';
$NAMESPACES{$ns}->{JID}->{XPath}->{Path} = '@jid';

$NAMESPACES{$ns}->{Name}->{XPath}->{Path} = '@name';

$NAMESPACES{$ns}->{Subscription}->{XPath}->{Path} = '@subscription';

$NAMESPACES{$ns}->{Item}->{XPath}->{Type} = 'master';

1;
