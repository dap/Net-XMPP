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

package Net::XMPP::IQ;

=head1 NAME

Net::XMPP::IQ - XMPP Info/Query Module

=head1 SYNOPSIS

  Net::XMPP::IQ is a companion to the Net::XMPP module. It
  provides the user a simple interface to set and retrieve all
  parts of an XMPP IQ.

=head1 DESCRIPTION

  Net::XMPP::IQ differs from the other Net::XMPP::* modules in that
  the XMLNS of the query is split out into a submodule under
  IQ.  For specifics on each module please view the documentation
  for the Net::XMPP::Query module.

  A Net::XMPP::IQ object is passed to the callback function for the
  message.  Also, the first argument to the callback functions is the
  session ID from XML::Stream.  There are some cases where you might
  want this information, like if you created a Client that connects to
  two servers at once, or for writing a mini server.

    use Net::XMPP qw(Client);

    sub iq {
      my ($sid,$IQ) = @_;
      .
      .
      .
    }

  You now have access to all of the retrieval functions available.

  To create a new iq to send to the server:

    use Net::XMPP qw(Client);

    $IQ = new Net::XMPP::IQ();
    $IQType = $IQ->NewQuery( type );
    $IQType->SetXXXXX("yyyyy");

  Now you can call the creation functions for the IQ, and for the <query/>
  on the new Query object itself.  See below for the <iq/> functions, and
  in each query module for those functions.

=head1 METHODS

=head2 Retrieval functions

  GetTo()      - returns either a string with the JID, or a
  GetTo("jid")   Net::XMPP::JID object for the person who is
                 going to receive the <iq/>.  To get the JID
                 object set the string to "jid", otherwise leave
                 blank for the text string.

                 $to    = $IQ->GetTo();
                 $toJID = $IQ->GetTo("jid");

  GetFrom()      -  returns either a string with the JID, or a
  GetFrom("jid")    Net::XMPP::JID object for the person who
                    sent the <iq/>.  To get the JID object set
                    the string to "jid", otherwise leave blank for the
                    text string.

                    $from    = $IQ->GetFrom();
                    $fromJID = $IQ->GetFrom("jid");

  GetType() - returns a string with the type <iq/> this is.

              $type = $IQ->GetType();

  GetID() - returns an integer with the id of the <iq/>.

            $id = $IQ->GetID();

  GetError() - returns a string with the text description of the error.

               $error = $IQ->GetError();

  GetErrorCode() - returns a string with the code of error.

                   $errorCode = $IQ->GetErrorCode();

  GetQuery() - returns a Net::XMPP::Query object that contains the data
               in the <query/> of the <iq/>.

               $queryTag = $IQ->GetQuery();

  GetQueryXMLNS() - returns a string with the namespace of the query
                    for this <iq/>, if one exists.

                    $xmlns = $IQ->GetQueryXMLNS();

=head2 Creation functions

  SetIQ(to=>string|JID,    - set multiple fields in the <iq/> at one
        from=>string|JID,    time.  This is a cumulative and over
        id=>string,          writing action.  If you set the "to"
        type=>string,        attribute twice, the second setting is
        errorcode=>string,   what is used.  If you set the status, and
        error=>string)       then set the priority then both will be in
                             the <iq/> tag.  For valid settings read the
                             specific Set functions below.

                             $IQ->SetIQ(type=>"get",
                                        to=>"bob\@jabber.org",
                                        query=>"info");

                             $IQ->SetIQ(to=>"bob\@jabber.org",
                                        errorcode=>403,
                                        error=>"Permission Denied");

  SetTo(string) - sets the to attribute.  You can either pass a string
  SetTo(JID)      or a JID object.  They must be a valid Jabber
                  Identifiers or the server will return an error message.
                  (ie.  bob@jabber.org, etc...)

                  $IQ->SetTo("bob\@jabber.org");

  SetFrom(string) - sets the from attribute.  You can either pass a string
  SetFrom(JID)      or a JID object.  They must be a valid JIDs or the
                    server will return an error message.
                    (ie.  bob@jabber.org, etc...)

                    $IQ->SetFrom("me\@jabber.org");

  SetType(string) - sets the type attribute.  Valid settings are:

                    get      request information
                    set      set information
                    result   results of a get
                    error    there was an error

                    $IQ->SetType("set");

  SetErrorCode(string) - sets the error code of the <iq/>.

                         $IQ->SetErrorCode(403);

  SetError(string) - sets the error string of the <iq/>.

                     $IQ->SetError("Permission Denied");

  NewQuery(string) - creates a new Net::XMPP::Query object with the
                     namespace in the string.  In order for this function
                     to work with a custom namespace, you must define and
                     register that namespace with the IQ module.  For more
                     information please read the documentation for
                     Net::XMPP::Query.

                     $queryObj = $IQ->NewQuery("jabber:iq:auth");
                     $queryObj = $IQ->NewQuery("jabber:iq:roster");

  Reply(hash) - creates a new IQ object and populates the to/from
                fields.  If you specify a hash the same as with SetIQ
                then those values will override the Reply values.

                $iqReply = $IQ->Reply();
                $iqReply = $IQ->Reply(type=>"result");

=head2 Test functions

  DefinedTo() - returns 1 if the to attribute is defined in the <iq/>, 
                0 otherwise.

                $test = $IQ->DefinedTo();

  DefinedFrom() - returns 1 if the from attribute is defined in the <iq/>, 
                  0 otherwise.

                  $test = $IQ->DefinedFrom();

  DefinedID() - returns 1 if the id attribute is defined in the <iq/>, 
                0 otherwise.

                $test = $IQ->DefinedID();

  DefinedType() - returns 1 if the type attribute is defined in the <iq/>, 
                  0 otherwise.

                  $test = $IQ->DefinedType();

  DefinedError() - returns 1 if <error/> is defined in the <iq/>, 
                   0 otherwise.

                   $test = $IQ->DefinedError();

  DefinedErrorCode() - returns 1 if the code attribute is defined in
                       <error/>, 0 otherwise.

                       $test = $IQ->DefinedErrorCode();

=head1 AUTHOR

Ryan Eatmon

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

require 5.003;
use strict;
use Carp;
use vars qw( %FUNCTIONS );
use base qw( Net::XMPP );

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = { };

    bless($self, $proto);

    $self->{DEBUGHEADER} = "IQ";

    $self->{DATA} = {};
    $self->{CHILDREN} = {};

    $self->{TAG} = "iq";

    if ("@_" ne (""))
    {
        if (ref($_[0]) eq "Net::XMPP::IQ")
        {
            return $_[0];
        }
        else
        {
            $self->{TREE} = shift;
            $self->ParseTree();
        }
    }
    else
    {
        $self->{TREE} = new XML::Stream::Node($self->{TAG});
    }

    return $self;
}


$FUNCTIONS{Error}->{XPath}->{Path} = 'error/text()';

$FUNCTIONS{ErrorCode}->{XPath}->{Path} = 'error/@code';

$FUNCTIONS{From}->{XPath}->{Type} = 'jid';
$FUNCTIONS{From}->{XPath}->{Path} = '@from';

$FUNCTIONS{ID}->{XPath}->{Path} = '@id';

$FUNCTIONS{To}->{XPath}->{Type} = 'jid';
$FUNCTIONS{To}->{XPath}->{Path} = '@to';

$FUNCTIONS{Type}->{XPath}->{Path} = '@type';

$FUNCTIONS{IQ}->{XPath}->{Type}  = 'master';

$FUNCTIONS{Query}->{XPath}->{Type}  = 'node';
$FUNCTIONS{Query}->{XPath}->{Path}  = '*[@xmlns]';
$FUNCTIONS{Query}->{XPath}->{Child} = 'Query';
$FUNCTIONS{Query}->{XPath}->{Calls} = ['Get','Defined'];

$FUNCTIONS{X}->{XPath}->{Type}  = 'node';
$FUNCTIONS{X}->{XPath}->{Path}  = '*[@xmlns]';
$FUNCTIONS{X}->{XPath}->{Child} = 'X';
$FUNCTIONS{X}->{XPath}->{Calls} = ['Get','Defined'];


##############################################################################
#
# GetQueryXMLNS - returns the xmlns of the <query/> tag
#
##############################################################################
sub GetQueryXMLNS
{
    my $self = shift;
    ### XXX fix this
    return $self->{CHILDREN}->{query}->[0]->GetXMLNS() if exists($self->{CHILDREN}->{query});
}


##############################################################################
#
# Reply - returns a Net::XMPP::IQ object with the proper fields
#         already populated for you.
#
##############################################################################
sub Reply
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }

    my $reply = new Net::XMPP::IQ();

    $reply->SetID($self->GetID()) if ($self->GetID() ne "");
    $reply->SetType("result");

    $reply->NewQuery($self->GetQueryXMLNS());

    $reply->SetIQ((($self->GetFrom() ne "") ?
                   (to=>$self->GetFrom()) :
                   ()
                  ),
                  (($self->GetTo() ne "") ?
                   (from=>$self->GetTo()) :
                   ()
                  ),
                 );
    $reply->SetIQ(%args);

    return $reply;
}


1;
