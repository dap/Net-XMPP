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

package Net::XMPP::Protocol;

=head1 NAME

Net::XMPP::Protocol - XMPP Protocol Module

=head1 SYNOPSIS

  Net::XMPP::Protocol is a module that provides a developer easy
  access to the XMPP Instant Messaging protocol.  It provides high
  level functions to the Net::XMPP Client object.  These functions are
  inherited by that modules.

=head1 DESCRIPTION

  Protocol.pm seeks to provide enough high level APIs and automation of
  the low level APIs that writing a XMPP Client in Perl is trivial.  For
  those that wish to work with the low level you can do that too, but
  those functions are covered in the documentation for each module.

  Net::XMPP::Protocol provides functions to login, send and receive
  messages, set personal information, create a new user account, manage
  the roster, and disconnect.  You can use all or none of the functions,
  there is no requirement.

  For more information on how the details for how Net::XMPP is written
  please see the help for Net::XMPP itself.

  For more information on writing a Client see Net::XMPP::Client.

=head2 Modes

  Several of the functions take a mode argument that let you specify how
  the function should behave:

    block - send the packet with an ID, and then block until an answer
            comes back.  You can optionally specify a timeout so that
            you do not block forever.
           
    nonblock - send the packet with an ID, but then return that id and
               control to the master program.  Net::XMPP is still
               tracking this packet, so you must use the CheckID function
               to tell when it comes in.  (This might not be very
               useful...)

    passthru - send the packet with an ID, but do NOT register it with
               Net::XMPP, then return the ID.  This is useful when
               combined with the XPath function because you can register
               a one shot function tied to the id you get back.
               

=head2 Basic Functions

    use Net::XMPP qw( Client );
    $Con = new Net::XMPP::Client();                  # From
    $status = $Con->Connect(hostname=>"jabber.org"); # Net::XMPP::Client

    $Con->SetCallBacks(send=>\&sendCallBack,
                       receive=>\&receiveCallBack,
                       message=>\&messageCallBack,
                       iq=>\&handleTheIQTag);

    $Con->SetMessageCallBacks(normal=>\&messageNormalCB,
                              chat=>\&messageChatCB);

    $Con->SetPresenceCallBacks(available=>\&presenceAvailableCB,
                               unavailable=>\&presenceUnavailableCB);

    $Con->SetIQCallBacks("custom-namespace"=>
                                             {
                                                 get=>\&iqCustomGetCB,
                                                 set=>\&iqCustomSetCB,
                                                 result=>\&iqCustomResultCB,
                                             },
                                             etc...
                                            );

    $Con->SetXPathCallBacks("/message[@type='chat']"=>&messageChatCB,
                            "/message[@type='chat']"=>&otherMessageChatCB,
                            ...
                           );

    $Con->RemovePathCallBacks("/message[@type='chat']"=>&otherMessageChatCB);

    $error = $Con->GetErrorCode();
    $Con->SetErrorCode("Timeout limit reached");

    $status = $Con->Process();
    $status = $Con->Process(5);

    $Con->Send($object);
    $Con->Send("<tag>XML</tag>");

    $Con->Send($object,1);
    $Con->Send("<tag>XML</tag>",1);

    $Con->Disconnect();

=head2 ID Functions

    $id         = $Con->SendWithID($sendObj);
    $id         = $Con->SendWithID("<tag>XML</tag>");
    $receiveObj = $Con->SendAndReceiveWithID($sendObj);
    $receiveObj = $Con->SendAndReceiveWithID($sendObj,
                                             10);
    $receiveObj = $Con->SendAndReceiveWithID("<tag>XML</tag>");
    $receiveObj = $Con->SendAndReceiveWithID("<tag>XML</tag>",
                                             5);
    $yesno      = $Con->ReceivedID($id);
    $receiveObj = $Con->GetID($id);
    $receiveObj = $Con->WaitForID($id);
    $receiveObj = $Con->WaitForID($id,
                                  20);

=head2 Namespace Functions

    $Con->DefineNamespace(xmlns=>"foo:bar",
                         type=>"Query",
                         functions=>[{name=>"Foo",
                                      get=>"foo",
                                      set=>["scalar","foo"],
                                      defined=>"foo",
                                      hash=>"child-data"},
                                     {name=>"Bar",
                                      get=>"bar",
                                      set=>["scalar","bar"],
                                      defined=>"bar",
                                      hash=>"child-data"},
                                     {name=>"FooBar",
                                      get=>"__netjabber__:master",
                                      set=>["master"]}]);

=head2 Message Functions

    $Con->MessageSend(to=>"bob@jabber.org",
                      subject=>"Lunch",
                      body=>"Let's go grab some...\n",
                      thread=>"ABC123",
                      priority=>10);

=head2 Presence Functions

    $Con->PresenceSend();
    $Con->PresenceSend(type=>"unavailable");
    $Con->PresenceSend(show=>"away");
    $Con->PresenceSend(signature=>...signature...);

=head2 Subscription Functions

    $Con->Subscription(type=>"subscribe",
                       to=>"bob@jabber.org");

    $Con->Subscription(type=>"unsubscribe",
                       to=>"bob@jabber.org");

    $Con->Subscription(type=>"subscribed",
                       to=>"bob@jabber.org");

    $Con->Subscription(type=>"unsubscribed",
                       to=>"bob@jabber.org");

=head2 Presence DB Functions

    $Con->PresenceDBParse(Net::XMPP::Presence);

    $Con->PresenceDBDelete("bob\@jabber.org");
    $Con->PresenceDBDelete(Net::XMPP::JID);

    $Con->PresenceDBClear();

    $presence  = $Con->PresenceDBQuery("bob\@jabber.org");
    $presence  = $Con->PresenceDBQuery(Net::XMPP::JID);

    @resources = $Con->PresenceDBResources("bob\@jabber.org");
    @resources = $Con->PresenceDBResources(Net::XMPP::JID);

=head2 IQ  Functions

=head2 Auth Functions

    @result = $Con->AuthSend();
    @result = $Con->AuthSend(username=>"bob",
                             password=>"bobrulez",
                             resource=>"Bob");

=head2 Roster Functions

    %roster = $Con->RosterParse($iq);
    %roster = $Con->RosterGet();
    $Con->RosterRequest();
    $Con->RosterAdd(jid=>"bob\@jabber.org",
                    name=>"Bob");
    $Con->RosterRemove(jid=>"bob@jabber.org");


=head1 METHODS

=head2 Basic Functions

    GetErrorCode() - returns a string that will hopefully contain some
                     useful information about why a function returned
                     an undef to you.

    SetErrorCode(string) - set a useful error message before you return
                           an undef to the caller.

    SetCallBacks(message=>function,  - sets the callback functions for
                 presence=>function,   the top level tags listed.  The
                 iq=>function,         available tags to look for are
                 send=>function,       <message/>, <presence/>, and
                 receive=>function,    <iq/>.  If a packet is received
                 update=>function)     with an ID which is found in the
                                       registerd ID list (see RegisterID
                                       below) then it is not sent to
                                       these functions, instead it
                                       is inserted into a LIST and can
                                       be retrieved by some functions
                                       we will mention later.

                                       send and receive are used to
                                       log what XML is sent and received.
                                       update is used as way to update
                                       your program while waiting for
                                       a packet with an ID to be
                                       returned (useful for GUI apps).

                                       A major change that came with
                                       the last release is that the
                                       session id is passed to the
                                       callback as the first argument.
                                       This was done to facilitate
                                       the Server module.

                                       The next argument depends on
                                       which callback you are talking
                                       about.  message, presence, and iq
                                       all get passed in Net::XMPP
                                       objects that match those types.
                                       send and receive get passed in
                                       strings.  update gets passed
                                       nothing, not even the session id.

                                       If you set the function to undef,
                                       then the callback is removed from
                                       the list.

    SetPresenceCallBacks(type=>function - sets the callback functions for
                         etc...)          the specified presence type. The
                                          function takes types as the main
                                          key, and lets you specify a
                                          function for each type of packet
                                          you can get.
                                            "available"
                                            "unavailable"
                                            "subscribe"
                                            "unsubscribe"
                                            "subscribed"
                                            "unsubscribed"
                                            "probe"
                                            "error"
                                          When it gets a <presence/> packet
                                          it checks the type='' for a defined
                                          callback.  If there is one then it
                                          calls the function with two
                                          arguments:
                                            the session ID, and the
                                            Net::XMPP::Presence object.

                                          If you set the function to undef,
                                          then the callback is removed from
                                          the list.

                        NOTE: If you use this, which is a cleaner method,
                              then you must *NOT* specify a callback for
                              presence in the SetCallBacks function.
 
                                          Net::XMPP defines a few default
                                          callbacks for various types:
 
                                          "subscribe" -
                                            replies with subscribed
                                          
                                          "unsubscribe" -
                                            replies with unsubscribed
                                          
                                          "subscribed" -
                                            replies with subscribed
                                          
                                          "unsubscribed" -
                                            replies with unsubscribed
                                         

    SetMessageCallBacks(type=>function, - sets the callback functions for
                        etc...)           the specified message type. The 
                                          function takes types as the main
                                          key, and lets you specify a
                                          function for each type of packet
                                          you can get.
                                           "normal"
                                           "chat"
                                           "groupchat"
                                           "headline"
                                           "error"
                                         When it gets a <message/> packet
                                         it checks the type='' for a
                                         defined callback. If there is one
                                         then it calls the function with
                                         two arguments:
                                           the session ID, and the
                                           Net::XMPP::Message object.

                                         If you set the function to undef,
                                         then the callback is removed from
                                         the list.

                       NOTE: If you use this, which is a cleaner method,
                             then you must *NOT* specify a callback for
                             message in the SetCallBacks function.


    SetIQCallBacks(namespace=>{      - sets the callback functions for
                     get=>function,    the specified namespace. The
                     set=>function,    function takes namespaces as the
                     result=>function  main key, and lets you specify a
                   },                  function for each type of packet
                   etc...)             you can get.
                                         "get"
                                         "set"
                                         "result"
                                       When it gets an <iq/> packet it
                                       checks the type='' and the
                                       xmlns='' for a defined callback.
                                       If there is one then it calls
                                       the function with two arguments:
                                       the session ID, and the
                                       Net::XMPP::xxxx object.

                                       If you set the function to undef,
                                       then the callback is removed from
                                       the list.

                       NOTE: If you use this, which is a cleaner method,
                             then you must *NOT* specify a callback for
                             iq in the SetCallBacks function.

    SetXPathCallBacks(xpath=>function, - registers a callback function for
                        etc...)          each xpath specified.  If
                                         Net::XMPP matches the xpath,
                                         then it calls the function with
                                         two arguments:
                                           the session ID, and the
                                           Net::XMPP::Message object.

                                         Xpaths are rooted at each packet:
                                           /message[@type="chat"]
                                           /iq/*[xmlns="jabber:iq:roster"][1]
                                           ...

    RemoveXPathCallBacks(xpath=>function, - unregisters a callback function
                        etc...)             for each xpath specified.

    Process(integer) - takes the timeout period as an argument.  If no
                       timeout is listed then the function blocks until
                       a packet is received.  Otherwise it waits that
                       number of seconds and then exits so your program
                       can continue doing useful things.  NOTE: This is
                       important for GUIs.  You need to leave time to
                       process GUI commands even if you are waiting for
                       packets.  The following are the possible return
                       values, and what they mean:

                           1   - Status ok, data received.
                           0   - Status ok, no data received.
                         undef - Status not ok, stop processing.
                       
                       IMPORTANT: You need to check the output of every
                       Process.  If you get an undef then the connection
                       died and you should behave accordingly.

    Send(object,         - takes either a Net::XMPP::xxxxx object or
         ignoreActivity)   an XML string as an argument and sends it to
    Send(string,           the server.  If you set ignoreActivty to 1,
         ignoreActivity)   then the XML::Stream module will not record
                           this packet as couting towards user activity.
=head2 ID Functions

    SendWithID(object) - takes either a Net::XMPP::xxxxx object or an
    SendWithID(string)   XML string as an argument, adds the next
                         available ID number and sends that packet to
                         the server.  Returns the ID number assigned.

    SendAndReceiveWithID(object,  - uses SendWithID and WaitForID to
                         timeout)   provide a complete way to send and
    SendAndReceiveWithID(string,    receive packets with IDs.  Can take
                         timeout)   either a Net::XMPP::xxxxx object
                                    or an XML string.  Returns the
                                    proper Net::XMPP::xxxxx object
                                    based on the type of packet
                                    received.  The timeout is passed
                                    on to WaitForID, see that function
                                    for how the timeout works.

    ReceivedID(integer) - returns 1 if a packet has been received with
                          specified ID, 0 otherwise.

    GetID(integer) - returns the proper Net::XMPP::xxxxx object based
                     on the type of packet received with the specified
                     ID.  If the ID has been received the GetID returns
                     0.

    WaitForID(integer, - blocks until a packet with the ID is received.
              timeout)   Returns the proper Net::XMPP::xxxxx object
                         based on the type of packet received.  If the
                         timeout limit is reached then if the packet
                         does come in, it will be discarded.


    NOTE:  Only <iq/> officially support ids, so sending a <message/>, or
           <presence/> with an id is a risk.  The server will ignore the
           id tag and pass it through, so both clients must support the
           id tag for these functions to be useful.

=head2 Namespace Functions

    DefineNamespace(xmlns=>string,    - This function is very complex.
                    type=>string,       It is a little too complex to
                    functions=>array)   discuss within the confines of
                                        this small paragraph.  Please
                                        refer to the man page for
                                        Net::XMPP::Namespaces for the
                                        full documentation on this
                                        subject.

=head2 Message Functions

    MessageSend(hash) - takes the hash and passes it to SetMessage in
                        Net::XMPP::Message (refer there for valid
                        settings).  Then it sends the message to the
                        server.

=head2 Presence Functions

    PresenceSend()                  - no arguments will send an empty
    PresenceSend(hash,                Presence to the server to tell it
                 signature=>string)   that you are available.  If you
                                      provide a hash, then it will pass
                                      that hash to the SetPresence()
                                      function as defined in the
                                      Net::XMPP::Presence module.
                                      Optionally, you can specify a
                                      signature and a jabber:x:signed
                                      will be placed in the <presence/>.

=head2 Subscription Functions

    Subscription(hash) - taks the hash and passes it to SetPresence in
                         Net::XMPP::Presence (refer there for valid
                         settings).  Then it sends the subscription to
                         server.

                         The valid types of subscription are:

                           subscribe    - subscribe to JID's presence
                           unsubscribe  - unsubscribe from JID's presence
                           subscribed   - response to a subscribe
                           unsubscribed - response to an unsubscribe

=head2 Presence DB Functions

    PresenceDBParse(Net::XMPP::Presence) - for every presence that you
                                             receive pass the Presence
                                             object to the DB so that
                                             it can track the resources
                                             and priorities for you.
                                             Returns either the presence
                                             passed in, if it not able
                                             to parsed for the DB, or the
                                             current presence as found by
                                             the PresenceDBQuery
                                             function.

    PresenceDBDelete(string|Net::XMPP::JID) - delete thes JID entry
                                                from the DB.

    PresenceDBClear() - delete all entries in the database.

    PresenceDBQuery(string|Net::XMPP::JID) - returns the NJ::Presence
                                               that was last received for
                                               the highest priority of
                                               this JID.  You can pass
                                               it a string or a NJ::JID
                                               object.

    PresenceDBResources(string|Net::XMPP::JID) - returns an array of
                                                   resources in order
                                                   from highest priority
                                                   to lowest.

=head2 IQ Functions

=head2 Auth Functions

    AuthSend(username=>string, - takes all of the information and
             password=>string,   builds a Net::XMPP::IQ::Auth packet.
             resource=>string)   It then sends that packet to the
                                 server with an ID and waits for that
                                 ID to return.  Then it looks in
                                 resulting packet and determines if
                                 authentication was successful for not.
                                 The array returned from AuthSend looks
                                 like this:
                                   [ type , message ]
                                 If type is "ok" then authentication
                                 was successful, otherwise message
                                 contains a little more detail about the
                                 error.

=head2 Roster Functions

    RosterParse(IQ object) - returns a hash that contains the roster
                             parsed into the following data structure:

                  $roster{'bob@jabber.org'}->{name}
                                      - Name you stored in the roster

                  $roster{'bob@jabber.org'}->{subscription}
                                      - Subscription status
                                        (to, from, both, none)

                  $roster{'bob@jabber.org'}->{ask}
                                      - The ask status from this user
                                        (subscribe, unsubscribe)

                  $roster{'bob@jabber.org'}->{groups}
                                      - Array of groups that
                                        bob@jabber.org is in

    RosterGet() - sends an empty Net::XMPP::IQ::Roster tag to the
                  server so the server will send the Roster to the
                  client.  Returns the above hash from RosterParse.

    RosterRequest() - sends an empty Net::XMPP::IQ::Roster tag to the
                      server so the server will send the Roster to the
                      client.

    RosterAdd(hash) - sends a packet asking that the jid be
                      added to the roster.  The hash format
                      is defined in the SetItem function
                      in the Net::XMPP::Query jabber:iq:roster
                      namespace.

    RosterRemove(hash) - sends a packet asking that the jid be
                         removed from the roster.  The hash
                         format is defined in the SetItem function
                         in the Net::XMPP::Query jabber:iq:roster
                         namespace.

=head1 AUTHOR

Ryan Eatmon

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use Carp;

sub new
{
    my $proto = shift;
    my $self = { };

    bless($self, $proto);
    return $self;
}


###############################################################################
#+-----------------------------------------------------------------------------
#|
#| Base API
#|
#+-----------------------------------------------------------------------------
###############################################################################

###############################################################################
#
# GetErrorCode - if you are returned an undef, you can call this function
#                and hopefully learn more information about the problem.
#
###############################################################################
sub GetErrorCode
{
    my $self = shift;
    return ((exists($self->{ERRORCODE}) && ($self->{ERRORCODE} ne "")) ?
            $self->{ERRORCODE} :
            $!
           );
}


###############################################################################
#
# SetErrorCode - sets the error code so that the caller can find out more
#                information about the problem
#
###############################################################################
sub SetErrorCode
{
    my $self = shift;
    my ($errorcode) = @_;
    $self->{ERRORCODE} = $errorcode;
}


###############################################################################
#
# CallBack - Central callback function.  If a packet comes back with an ID
#            and the tag and ID have been registered then the packet is not
#            returned as normal, instead it is inserted in the LIST and
#            stored until the user wants to fetch it.  If the tag and ID
#            are not registered the function checks if a callback exists
#            for this tag, if it does then that callback is called,
#            otherwise the function drops the packet since it does not know
#            how to handle it.
#
###############################################################################
sub CallBack
{
    my $self = shift;
    my $sid = shift;
    my ($object) = @_;

    my $tag;
    my $id;
    my $tree;
    
    if (ref($object) !~ /^Net::XMPP/)
    {
        if ($self->{DEBUG}->GetLevel() >= 1 || exists($self->{CB}->{receive}))
        {
            my $xml = $object->GetXML();
            $self->{DEBUG}->Log1("CallBack: sid($sid) received($xml)");
            &{$self->{CB}->{receive}}($sid,$xml) if exists($self->{CB}->{receive});
        }

        $tag = $object->get_tag();
        $id = "";
        $id = $object->get_attrib("id")
            if defined($object->get_attrib("id"));
        $tree = $object;
    }
    else
    {
        $tag = $object->GetTag();
        $id = $object->GetID();
        $tree = $object->GetTree();
    }

    $self->{DEBUG}->Log1("CallBack: tag($tag)");
    $self->{DEBUG}->Log1("CallBack: id($id)") if ($id ne "");

    my $pass = 1;
    $pass = 0
        if (!exists($self->{CB}->{$tag}) &&
            !exists($self->{CB}->{XPath}) &&
            !$self->CheckID($tag,$id)
           );

    if ($pass)
    {
        $self->{DEBUG}->Log1("CallBack: we either want it or were waiting for it.");

        my $NJObject;
        if (ref($object) !~ /^Net::XMPP/)
        {
            $NJObject = $self->BuildObject($tag,$object);
        }
        else
        {
            $NJObject = $object;
        }

        if ($NJObject == -1)
        {
            $self->{DEBUG}->Log1("CallBack: DANGER!! DANGER!! We didn't build a packet!  We're all gonna die!!");
        }
        else
        {
            if ($self->CheckID($tag,$id))
            {
                $self->{DEBUG}->Log1("CallBack: found registry entry: tag($tag) id($id)");
                $self->DeregisterID($tag,$id);
                if ($self->TimedOutID($id))
                {
                    $self->{DEBUG}->Log1("CallBack: dropping packet due to timeout");
                    $self->CleanID($id);
                }
                else
                {
                    $self->{DEBUG}->Log1("CallBack: they still want it... we still got it...");
                    $self->GotID($id,$NJObject);
                }
            }
            else
            {
                $self->{DEBUG}->Log1("CallBack: no registry entry");

                foreach my $xpath (keys(%{$self->{CB}->{XPath}}))
                {
                    if ($NJObject->GetTree()->XPathCheck($xpath))
                    {
                        foreach my $func (keys(%{$self->{CB}->{XPath}->{$xpath}}))
                        {
                            $self->{DEBUG}->Log1("CallBack: goto xpath($xpath) function($func)");
                            &{$self->{CB}->{XPath}->{$xpath}->{$func}}($sid,$NJObject);
                        }
                    }
                }
                
                if (exists($self->{CB}->{$tag}))
                {
                    $self->{DEBUG}->Log1("CallBack: goto user function($self->{CB}->{$tag})");
                    &{$self->{CB}->{$tag}}($sid,$NJObject);
                }
                else
                {
                    $self->{DEBUG}->Log1("CallBack: no defined function.  Dropping packet.");
                }
            }
        }
    }
    else
    {
        $self->{DEBUG}->Log1("CallBack: a packet that no one wants... how sad. =(");
    }
}


###############################################################################
#
# BuildObject - turn the packet into an object.
#
###############################################################################
sub BuildObject
{
    my $self = shift;
    my ($tag,$object) = @_;

    my $NJObject = -1;
    if ($tag eq "iq")
    {
        $NJObject = new Net::XMPP::IQ($object);
    }
    elsif ($tag eq "presence")
    {
        $NJObject = new Net::XMPP::Presence($object);
    }
    elsif ($tag eq "message")
    {
        $NJObject = new Net::XMPP::Message($object);
    }
    elsif ($tag eq "xdb")
    {
        $NJObject = new Net::XMPP::XDB($object);
    }
    elsif ($tag eq "db:result")
    {
        $NJObject = new Net::XMPP::Dialback::Result($object);
    }
    elsif ($tag eq "db:verify")
    {
        $NJObject = new Net::XMPP::Dialback::Verify($object);
    }

    return $NJObject;
}


###############################################################################
#
# SetCallBacks - Takes a hash with top level tags to look for as the keys
#                and pointers to functions as the values.  The functions
#                are called and passed the XML::Parser::Tree objects
#                generated by XML::Stream.
#
###############################################################################
sub SetCallBacks
{
    my $self = shift;
    while($#_ >= 0)
    {
        my $func = pop(@_);
        my $tag = pop(@_);
        $self->{DEBUG}->Log1("SetCallBacks: tag($tag) func($func)");
        if (defined($func))
        {
            $self->{CB}->{$tag} = $func;
        }
        else
        {
            delete($self->{CB}->{$tag});
        }
        $self->{STREAM}->SetCallBacks(update=>$func) if ($tag eq "update");
    }
}


###############################################################################
#
# SetIQCallBacks - define callbacks for the namespaces inside an iq.
#
###############################################################################
sub SetIQCallBacks
{
    my $self = shift;

    while($#_ >= 0)
    {
        my $hash = pop(@_);
        my $namespace = pop(@_);

        foreach my $type (keys(%{$hash}))
        {
            if (defined($hash->{$type}))
            {
                $self->{CB}->{IQns}->{$namespace}->{$type} = $hash->{$type};
            }
            else
            {
                delete($self->{CB}->{IQns}->{$namespace}->{$type});
            }
        }
    }
}


###############################################################################
#
# SetPresenceCallBacks - define callbacks for the different presence packets.
#
###############################################################################
sub SetPresenceCallBacks
{
    my $self = shift;
    my (%types) = @_;

    foreach my $type (keys(%types))
    {
        if (defined($types{$type}))
        {
            $self->{CB}->{Pres}->{$type} = $types{$type};
        }
        else
        {
            delete($self->{CB}->{Pres}->{$type});
        }
    }
}


###############################################################################
#
# SetMessageCallBacks - define callbacks for the different message packets.
#
###############################################################################
sub SetMessageCallBacks
{
    my $self = shift;
    my (%types) = @_;

    foreach my $type (keys(%types))
    {
        if (defined($types{$type}))
        {
            $self->{CB}->{Mess}->{$type} = $types{$type};
        }
        else
        {
            delete($self->{CB}->{Mess}->{$type});
        }
    }
}


###############################################################################
#
# SetXPathCallBacks - define callbacks for packets based on XPath.
#
###############################################################################
sub SetXPathCallBacks
{ 
    my $self = shift;
    my (%xpaths) = @_;

    foreach my $xpath (keys(%xpaths))
    {
        $self->{DEBUG}->Log1("SetXPathCallBacks: xpath($xpath) func($xpaths{$xpath})");
        $self->{CB}->{XPath}->{$xpath}->{$xpaths{$xpath}} = $xpaths{$xpath};
    }
}


###############################################################################
#
# RemoveXPathCallBacks - remove callbacks for packets based on XPath.
#
###############################################################################
sub RemoveXPathCallBacks
{
    my $self = shift;
    my (%xpaths) = @_;

    foreach my $xpath (keys(%xpaths))
    {
        $self->{DEBUG}->Log1("RemoveXPathCallBacks: xpath($xpath) func($xpaths{$xpath})");
        delete($self->{CB}->{XPath}->{$xpath}->{$xpaths{$xpath}});
    }
}


###############################################################################
#
# Send - Takes either XML or a Net::XMPP::xxxx object and sends that
#        packet to the server.
#
###############################################################################
sub Send
{
    my $self = shift;
    my $object = shift;
    my $ignoreActivity = shift;
    $ignoreActivity = 0 unless defined($ignoreActivity);

    if (ref($object) eq "")
    {
        $self->SendXML($object,$ignoreActivity);
    }
    else
    {
        $self->SendXML($object->GetXML(),$ignoreActivity);
    }
}


###############################################################################
#
# SendXML - Sends the XML packet to the server
#
###############################################################################
sub SendXML
{
    my $self = shift;
    my $xml = shift;
    my $ignoreActivity = shift;
    $ignoreActivity = 0 unless defined($ignoreActivity);

    $self->{DEBUG}->Log1("SendXML: sent($xml)");
    &{$self->{CB}->{send}}($self->{SESSION}->{id},$xml) if exists($self->{CB}->{send});
    $self->{STREAM}->IgnoreActivity($self->{SESSION}->{id},$ignoreActivity);
    $self->{STREAM}->Send($self->{SESSION}->{id},$xml);
    $self->{STREAM}->IgnoreActivity($self->{SESSION}->{id},0);
}


###############################################################################
#
# SendWithID - Take either XML or a Net::XMPP::xxxx object and send it
#              with the next available ID number.  Then return that ID so
#              the client can track it.
#
###############################################################################
sub SendWithID
{
    my $self = shift;
    my ($object) = @_;

    #--------------------------------------------------------------------------
    # Take the current XML stream and insert an id attrib at the top level.
    #--------------------------------------------------------------------------
    my $id = $self->UniqueID();

    $self->{DEBUG}->Log1("SendWithID: id($id)");

    my $xml;
    if (ref($object) eq "")
    {
        $self->{DEBUG}->Log1("SendWithID: in($object)");
        $xml = $object;
        $xml =~ s/^(\<[^\>]+)(\>)/$1 id\=\'$id\'$2/;
        my ($tag) = ($xml =~ /^\<(\S+)\s/);
        $self->RegisterID($tag,$id);
    }
    else
    {
        $self->{DEBUG}->Log1("SendWithID: in(",$object->GetXML(),")");
        $object->SetID($id);
        $xml = $object->GetXML();
        $self->RegisterID($object->GetTag(),$id);
    }
    $self->{DEBUG}->Log1("SendWithID: out($xml)");

    #--------------------------------------------------------------------------
    # Send the new XML string.
    #--------------------------------------------------------------------------
    $self->SendXML($xml);

    #--------------------------------------------------------------------------
    # Return the ID number we just assigned.
    #--------------------------------------------------------------------------
    return $id;
}


###############################################################################
#
# UniqueID - Increment and return a new unique ID.
#
###############################################################################
sub UniqueID
{
    my $self = shift;

    my $id_num = $self->{LIST}->{currentID};

    $self->{LIST}->{currentID}++;

    return "netjabber-$id_num";
}


###############################################################################
#
# SendAndReceiveWithID - Take either XML or a Net::XMPP::xxxxx object and
#                        send it with the next ID.  Then wait for that ID
#                        to come back and return the response in a
#                        Net::XMPP::xxxx object.
#
###############################################################################
sub SendAndReceiveWithID
{
    my $self = shift;
    my ($object,$timeout) = @_;
    &{$self->{CB}->{startwait}}() if exists($self->{CB}->{startwait});
    $self->{DEBUG}->Log1("SendAndReceiveWithID: object($object)");
    my $id = $self->SendWithID($object);
    $self->{DEBUG}->Log1("SendAndReceiveWithID: sent with id($id)");
    my $packet = $self->WaitForID($id,$timeout);
    &{$self->{CB}->{endwait}}() if exists($self->{CB}->{endwait});
    return $packet;
}


###############################################################################
#
# ReceivedID - returns 1 if a packet with the ID has been received, or 0
#              if it has not.
#
###############################################################################
sub ReceivedID
{
    my $self = shift;
    my ($id) = @_;

    $self->{DEBUG}->Log1("ReceivedID: id($id)");
    return 1 if exists($self->{LIST}->{$id});
    $self->{DEBUG}->Log1("ReceivedID: nope...");
    return 0;
}


###############################################################################
#
# GetID - Return the Net::XMPP::xxxxx object that is stored in the LIST
#         that matches the ID if that ID exists.  Otherwise return 0.
#
###############################################################################
sub GetID
{
    my $self = shift;
    my ($id) = @_;

    $self->{DEBUG}->Log1("GetID: id($id)");
    return $self->{LIST}->{$id} if $self->ReceivedID($id);
    $self->{DEBUG}->Log1("GetID: haven't gotten that id yet...");
    return 0;
}


###############################################################################
#
# CleanID - Delete the list entry for this id since we don't want a leak.
#
###############################################################################
sub CleanID
{
    my $self = shift;
    my ($id) = @_;

    $self->{DEBUG}->Log1("CleanID: id($id)");
    delete($self->{LIST}->{$id});
}


###############################################################################
#
# WaitForID - Keep looping and calling Process(1) to poll every second
#             until the response from the server occurs.
#
###############################################################################
sub WaitForID
{
    my $self = shift;
    my ($id,$timeout) = @_;
    $timeout = "300" unless defined($timeout);

    $self->{DEBUG}->Log1("WaitForID: id($id)");
    my $endTime = time + $timeout;
    while(!$self->ReceivedID($id) && ($endTime >= time))
    {
        $self->{DEBUG}->Log1("WaitForID: haven't gotten it yet... let's wait for more packets");
        return unless (defined($self->Process(1)));
        &{$self->{CB}->{update}}() if exists($self->{CB}->{update});
    }
    if (!$self->ReceivedID($id))
    {
        $self->TimeoutID($id);
        $self->{DEBUG}->Log1("WaitForID: timed out...");
        return;
    }
    else
    {
        $self->{DEBUG}->Log1("WaitForID: we got it!");
        my $packet = $self->GetID($id);
        $self->CleanID($id);
        return $packet;
    }
}


###############################################################################
#
# GotID - Callback to store the Net::XMPP::xxxxx object in the LIST at
#         the ID index.  This is a private helper function.
#
###############################################################################
sub GotID
{
    my $self = shift;
    my ($id,$object) = @_;

    $self->{DEBUG}->Log1("GotID: id($id) xml(",$object->GetXML(),")");
    $self->{LIST}->{$id} = $object;
}


###############################################################################
#
# CheckID - Checks the ID registry if this tag and ID have been registered.
#           0 = no, 1 = yes
#
###############################################################################
sub CheckID
{
    my $self = shift;
    my ($tag,$id) = @_;
    $id = "" unless defined($id);

    $self->{DEBUG}->Log1("CheckID: tag($tag) id($id)");
    return 0 if ($id eq "");
    $self->{DEBUG}->Log1("CheckID: we have that here somewhere...");
    return exists($self->{IDRegistry}->{$tag}->{$id});
}


###############################################################################
#
# TimeoutID - Timeout the tag and ID in the registry so that the CallBack
#             can know what to put in the ID list and what to pass on.
#
###############################################################################
sub TimeoutID
{
    my $self = shift;
    my ($id) = @_;

    $self->{DEBUG}->Log1("TimeoutID: id($id)");
    $self->{LIST}->{$id} = 0;
}


###############################################################################
#
# TimedOutID - Timeout the tag and ID in the registry so that the CallBack
#             can know what to put in the ID list and what to pass on.
#
###############################################################################
sub TimedOutID
{
    my $self = shift;
    my ($id) = @_;

    return (exists($self->{LIST}->{$id}) && ($self->{LIST}->{$id} == 0));
}


###############################################################################
#
# RegisterID - Register the tag and ID in the registry so that the CallBack
#              can know what to put in the ID list and what to pass on.
#
###############################################################################
sub RegisterID
{
    my $self = shift;
    my ($tag,$id) = @_;

    $self->{DEBUG}->Log1("RegisterID: tag($tag) id($id)");
    $self->{IDRegistry}->{$tag}->{$id} = 1;
}


###############################################################################
#
# DeregisterID - Delete the tag and ID in the registry so that the CallBack
#                can knows that it has been received.
#
###############################################################################
sub DeregisterID
{
    my $self = shift;
    my ($tag,$id) = @_;

    $self->{DEBUG}->Log1("DeregisterID: tag($tag) id($id)");
    delete($self->{IDRegistry}->{$tag}->{$id});
}


###############################################################################
#
# DefineNamespace - adds the namespace and corresponding functions onto the
#                   of available functions based on namespace.
#
###############################################################################
sub DefineNamespace
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }

    croak("You must specify xmlns=>'' for the function call to DefineNamespace")
        if !exists($args{xmlns});
    croak("You must specify type=>'' for the function call to DefineNamespace")
        if !exists($args{type});
    croak("You must specify functions=>'' for the function call to DefineNamespace")
        if !exists($args{functions});
    
    eval("delete(\$Net::XMPP::$args{type}::NAMESPACES{\$args{xmlns}}) if exists(\$Net::XMPP::$args{type}::NAMESPACES{\$args{xmlns}})");
    
    foreach my $function (@{$args{functions}})
    {
        my %tempHash = %{$function};
        my %funcHash;
        foreach my $func (keys(%tempHash))
        {
            $funcHash{ucfirst(lc($func))} = $tempHash{$func};
        }

        croak("You must specify name=>'' for each function in call to DefineNamespace")
            if !exists($funcHash{Name});

        my $name = delete($funcHash{Name});

        if (!exists($funcHash{Set}) && exists($funcHash{Get}))
        {
            croak("The DefineNamespace arugments have changed, and I cannot determine the\nnew values automatically for name($name).  Please read the man page\nfor Net::XMPP::Namespaces.  I apologize for this incompatability.\n");
        }

        if (exists($funcHash{Type}) || exists($funcHash{Path}) ||
            exists($funcHash{Child}) || exists($funcHash{Calls}))
        {
            foreach my $type (keys(%funcHash))
            {
                eval("\$Net::XMPP::$args{type}::NAMESPACES{'$args{xmlns}'}->{'$name'}->{XPath}->{'$type'} = \$funcHash{'$type'};");
            }
            next;
        }
        
        my $type = $funcHash{Set}->[0];
        my $xpath = $funcHash{Set}->[1];
        if (exists($funcHash{Hash}))
        {
            $xpath = "text()" if ($funcHash{Hash} eq "data");
            $xpath .= "/text()" if ($funcHash{Hash} eq "child-data");
            $xpath = "\@$xpath" if ($funcHash{Hash} eq "att");
            $xpath = "$1/\@$2" if ($funcHash{Hash} =~ /^att-(\S+)-(.+)$/);
        }

        if ($type eq "master")
        {
            eval("\$Net::XMPP::$args{type}::NAMESPACES{\$args{xmlns}}->{\$name}->{XPath}->{Type} = 'master';");
            next;
        }
        
        if ($type eq "scalar")
        {
            eval("\$Net::XMPP::$args{type}::NAMESPACES{\$args{xmlns}}->{\$name}->{XPath}->{Path} = '$xpath';");
            next;
        }
        
        if ($type eq "flag")
        {
            eval("\$Net::XMPP::$args{type}::NAMESPACES{\$args{xmlns}}->{\$name}->{XPath}->{Type} = 'flag';");
            eval("\$Net::XMPP::$args{type}::NAMESPACES{\$args{xmlns}}->{\$name}->{XPath}->{Path} = '$xpath';");
            next;
        }

        if (($funcHash{Hash} eq "child-add") && exists($funcHash{Add}))
        {
            eval("\$Net::XMPP::$args{type}::NAMESPACES{'$args{xmlns}'}->{'$name'}->{XPath}->{Type}  = 'node';");
            eval("\$Net::XMPP::$args{type}::NAMESPACES{'$args{xmlns}'}->{'$name'}->{XPath}->{Path}  = \$funcHash{Add}->[3];");
            eval("\$Net::XMPP::$args{type}::NAMESPACES{'$args{xmlns}'}->{'$name'}->{XPath}->{Child} = [\$funcHash{Add}->[0],\$funcHash{Add}->[1]];");
            eval("\$Net::XMPP::$args{type}::NAMESPACES{'$args{xmlns}'}->{'$name'}->{XPath}->{Calls} = ['Add'];");
            next;
        }
    }
}


###############################################################################
#
# MessageSend - Takes the same hash that Net::XMPP::Message->SetMessage
#               takes and sends the message to the server.
#
###############################################################################
sub MessageSend
{
    my $self = shift;

    my $mess = new Net::XMPP::Message();
    $mess->SetMessage(@_);
    $self->Send($mess);
}


###############################################################################
#
# PresenceDBParse - adds the presence information to the Presence DB so
#                   you can keep track of the current state of the JID and
#                   all of it's resources.
#
###############################################################################
sub PresenceDBParse
{
    my $self = shift;
    my ($presence) = @_;

    my $type = $presence->GetType();
    $type = "" unless defined($type);
    return $presence unless (($type eq "") ||
                 ($type eq "available") ||
                 ($type eq "unavailable"));

    my $fromJID = $presence->GetFrom("jid");
    my $fromID = $fromJID->GetJID();
    $fromID = "" unless defined($fromID);
    my $resource = $fromJID->GetResource();
    $resource = " " unless ($resource ne "");
    my $priority = $presence->GetPriority();
    $priority = 0 unless defined($priority);

    $self->{DEBUG}->Log1("PresenceDBParse: fromJID(",$fromJID->GetJID("full"),") resource($resource) priority($priority) type($type)");
    $self->{DEBUG}->Log2("PresenceDBParse: xml(",$presence->GetXML(),")");

    if (exists($self->{PRESENCEDB}->{$fromID}))
    {
        my $oldPriority = $self->{PRESENCEDB}->{$fromID}->{resources}->{$resource};
        $oldPriority = "" unless defined($oldPriority);

        my $loc = 0;
        foreach my $index (0..$#{$self->{PRESENCEDB}->{$fromID}->{priorities}->{$oldPriority}})
        {
            $loc = $index
               if ($self->{PRESENCEDB}->{$fromID}->{priorities}->{$oldPriority}->[$index]->{resource} eq $resource);
        }
        splice(@{$self->{PRESENCEDB}->{$fromID}->{priorities}->{$oldPriority}},$loc,1);
        delete($self->{PRESENCEDB}->{$fromID}->{resources}->{$resource});
        delete($self->{PRESENCEDB}->{$fromID}->{priorities}->{$oldPriority})
            if (exists($self->{PRESENCEDB}->{$fromID}->{priorities}->{$oldPriority}) &&
        ($#{$self->{PRESENCEDB}->{$fromID}->{priorities}->{$oldPriority}} == -1));
        delete($self->{PRESENCEDB}->{$fromID})
            if (scalar(keys(%{$self->{PRESENCEDB}->{$fromID}})) == 0);

        $self->{DEBUG}->Log1("PresenceDBParse: remove ",$fromJID->GetJID("full")," from the DB");
    }

    if (($type eq "") || ($type eq "available"))
    {
        my $loc = -1;
        foreach my $index (0..$#{$self->{PRESENCEDB}->{$fromID}->{priorities}->{$priority}}) {
            $loc = $index
                if ($self->{PRESENCEDB}->{$fromID}->{priorities}->{$priority}->[$index]->{resource} eq $resource);
        }
        $loc = $#{$self->{PRESENCEDB}->{$fromID}->{priorities}->{$priority}}+1
            if ($loc == -1);
        $self->{PRESENCEDB}->{$fromID}->{resources}->{$resource} = $priority;
        $self->{PRESENCEDB}->{$fromID}->{priorities}->{$priority}->[$loc]->{presence} =
            $presence;
        $self->{PRESENCEDB}->{$fromID}->{priorities}->{$priority}->[$loc]->{resource} =
            $resource;

        $self->{DEBUG}->Log1("PresenceDBParse: add ",$fromJID->GetJID("full")," to the DB");
    }

    my $currentPresence = $self->PresenceDBQuery($fromJID);
    return (defined($currentPresence) ? $currentPresence : $presence);
}


###############################################################################
#
# PresenceDBDelete - delete the JID from the DB completely.
#
###############################################################################
sub PresenceDBDelete
{
    my $self = shift;
    my ($jid) = @_;

    my $indexJID = $jid;
    $indexJID = $jid->GetJID() if (ref($jid) eq "Net::XMPP::JID");

    return if !exists($self->{PRESENCEDB}->{$indexJID});
    delete($self->{PRESENCEDB}->{$indexJID});
    $self->{DEBUG}->Log1("PresenceDBDelete: delete ",$indexJID," from the DB");
}


###############################################################################
#
# PresenceDBClear - delete all of the JIDs from the DB completely.
#
###############################################################################
sub PresenceDBClear
{
    my $self = shift;

    $self->{DEBUG}->Log1("PresenceDBClear: clearing the database");
    foreach my $indexJID (keys(%{$self->{PRESENCEDB}}))
    {
        delete($self->{PRESENCEDB}->{$indexJID});
        $self->{DEBUG}->Log3("PresenceDBClear: deleting ",$indexJID," from the DB");
    }
    $self->{DEBUG}->Log3("PresenceDBClear: database is empty");
}


###############################################################################
#
# PresenceDBQuery - retrieve the last Net::XMPP::Presence received with
#                  the highest priority.
#
###############################################################################
sub PresenceDBQuery
{
    my $self = shift;
    my ($jid) = @_;

    my $indexJID = $jid;
    $indexJID = $jid->GetJID() if (ref($jid) eq "Net::XMPP::JID");

    return if !exists($self->{PRESENCEDB}->{$indexJID});
    return if (scalar(keys(%{$self->{PRESENCEDB}->{$indexJID}->{priorities}})) == 0);

    my $highPriority =
        (sort {$b cmp $a} keys(%{$self->{PRESENCEDB}->{$indexJID}->{priorities}}))[0];

    return $self->{PRESENCEDB}->{$indexJID}->{priorities}->{$highPriority}->[0]->{presence};
}


###############################################################################
#
# PresenceDBResources - returns a list of the resources from highest
#                       priority to lowest.
#
###############################################################################
sub PresenceDBResources
{
    my $self = shift;
    my ($jid) = @_;

    my $indexJID = $jid;
    $indexJID = $jid->GetJID() if (ref($jid) eq "Net::XMPP::JID");

    my @resources;

    return if !exists($self->{PRESENCEDB}->{$indexJID});

    foreach my $priority (sort {$b cmp $a} keys(%{$self->{PRESENCEDB}->{$indexJID}->{priorities}}))
    {
        foreach my $index (0..$#{$self->{PRESENCEDB}->{$indexJID}->{priorities}->{$priority}})
        {
            next if ($self->{PRESENCEDB}->{$indexJID}->{priorities}->{$priority}->[$index]->{resource} eq " ");
            push(@resources,$self->{PRESENCEDB}->{$indexJID}->{priorities}->{$priority}->[$index]->{resource});
        }
    }
    return @resources;
}


###############################################################################
#
# PresenceSend - Sends a presence tag to announce your availability
#
###############################################################################
sub PresenceSend
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }

    $args{ignoreactivity} = 0 unless exists($args{ignoreactivity});
    my $ignoreActivity = delete($args{ignoreactivity});

    my $presence = new Net::XMPP::Presence();

    if (exists($args{signature}))
    {
        my $xSigned = $presence->NewX("jabber:x:signed");
        $xSigned->SetSigned(signature=>delete($args{signature}));
    }

    $presence->SetPresence(%args);
    $self->Send($presence,$ignoreActivity);
    return $presence;
}


###############################################################################
#
# PresenceProbe - Sends a presence probe to the server
#
###############################################################################
sub PresenceProbe
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }
    delete($args{type});

    my $presence = new Net::XMPP::Presence();
    $presence->SetPresence(type=>"probe",
                           %args);
    $self->Send($presence);
}


###############################################################################
#
# Subscription - Sends a presence tag to perform the subscription on the
#                specified JID.
#
###############################################################################
sub Subscription
{
    my $self = shift;

    my $presence = new Net::XMPP::Presence();
    $presence->SetPresence(@_);
    $self->Send($presence);
}


###############################################################################
#
# AuthSend - This is a self contained function to send a login iq tag with
#            an id.  Then wait for a reply what the same id to come back
#            and tell the caller what the result was.
#
###############################################################################
sub AuthSend
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }

    carp("AuthSend requires a username arguement")
        unless exists($args{username});
    carp("AuthSend requires a password arguement")
        unless exists($args{password});
    carp("AuthSend requires a resource arguement")
        unless exists($args{resource});

    my $authType = "digest";
    my $token;
    my $sequence;

    #--------------------------------------------------------------------------
    # First let's ask the sever what all is available in terms of auth types.
    # If we get an error, then all we can do is digest or plain.
    #--------------------------------------------------------------------------
    my $iqAuthProbe = new Net::XMPP::IQ();
    $iqAuthProbe->SetIQ(type=>"get");
    my $iqAuthProbeQuery = $iqAuthProbe->NewQuery("jabber:iq:auth");
    $iqAuthProbeQuery->SetUsername($args{username});
    $iqAuthProbe = $self->SendAndReceiveWithID($iqAuthProbe);

    return unless defined($iqAuthProbe);
    return ( $iqAuthProbe->GetErrorCode() , $iqAuthProbe->GetError() )
        if ($iqAuthProbe->GetType() eq "error");

    if ($iqAuthProbe->GetType() eq "error")
    {
        $authType = "digest";
    }
    else
    {
        $iqAuthProbeQuery = $iqAuthProbe->GetQuery();
        $authType = "plain" if $iqAuthProbeQuery->DefinedPassword();
        $authType = "digest" if $iqAuthProbeQuery->DefinedDigest();
        $authType = "zerok" if ($iqAuthProbeQuery->DefinedSequence() &&
                    $iqAuthProbeQuery->DefinedToken());
        $token = $iqAuthProbeQuery->GetToken() if ($authType eq "zerok");
        $sequence = $iqAuthProbeQuery->GetSequence() if ($authType eq "zerok");
    }

    delete($args{digest});
    delete($args{type});

    #--------------------------------------------------------------------------
    # 0k authenticaion (http://core.jabber.org/0k.html)
    #
    # Tell the server that we want to connect this way, the server sends back
    # a token and a sequence number.  We take that token + the password and
    # SHA1 it.  Then we SHA1 it sequence number more times and send that hash.
    # The server SHA1s that hash one more time and compares it to the hash it
    # stored last time.  IF they match, we are in and it stores the hash we sent
    # for the next time and decreases the sequence number, else, no go.
    #--------------------------------------------------------------------------
    if ($authType eq "zerok")
    {
        my $hashA = Digest::SHA1::sha1_hex(delete($args{password}));
        $args{hash} = Digest::SHA1::sha1_hex($hashA.$token);

        for (1..$sequence)
        {
            $args{hash} = Digest::SHA1::sha1_hex($args{hash});
        }
    }

    #--------------------------------------------------------------------------
    # If we have access to the SHA-1 digest algorithm then let's use it.
    # Remove the password from the hash, create the digest, and put the
    # digest in the hash instead.
    #
    # Note: Concat the Session ID and the password and then digest that
    # string to get the server to accept the digest.
    #--------------------------------------------------------------------------
    if ($authType eq "digest")
    {
        my $password = delete($args{password});
        $args{digest} = Digest::SHA1::sha1_hex($self->{SESSION}->{id}.$password);
    }

    #--------------------------------------------------------------------------
    # Create a Net::XMPP::IQ object to send to the server
    #--------------------------------------------------------------------------
    my $iqLogin = new Net::XMPP::IQ();
    $iqLogin->SetIQ(type=>"set");
    my $iqAuth = $iqLogin->NewQuery("jabber:iq:auth");
    $iqAuth->SetAuth(%args);

    #--------------------------------------------------------------------------
    # Send the IQ with the next available ID and wait for a reply with that
    # id to be received.  Then grab the IQ reply.
    #--------------------------------------------------------------------------
    $iqLogin = $self->SendAndReceiveWithID($iqLogin);

    #--------------------------------------------------------------------------
    # From the reply IQ determine if we were successful or not.  If yes then
    # return "".  If no then return error string from the reply.
    #--------------------------------------------------------------------------
    return unless defined($iqLogin);
    return ( $iqLogin->GetErrorCode() , $iqLogin->GetError() )
        if ($iqLogin->GetType() eq "error");
    return ("ok","");
}


###############################################################################
#
# RosterAdd - Takes the Jabber ID of the user to add to their Roster and
#             sends the IQ packet to the server.
#
###############################################################################
sub RosterAdd
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }

    my $iq = new Net::XMPP::IQ();
    $iq->SetIQ(type=>"set");
    my $roster = $iq->NewQuery("jabber:iq:roster");
    my $item = $roster->AddItem();
    $item->SetItem(%args);

    $self->{DEBUG}->Log1("RosterAdd: xml(",$iq->GetXML(),")");
    $self->Send($iq);
}


###############################################################################
#
# RosterAdd - Takes the Jabber ID of the user to remove from their Roster
#             and sends the IQ packet to the server.
#
###############################################################################
sub RosterRemove
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }
    delete($args{subscription});

    my $iq = new Net::XMPP::IQ();
    $iq->SetIQ(type=>"set");
    my $roster = $iq->NewQuery("jabber:iq:roster");
    my $item = $roster->AddItem();
    $item->SetItem(%args,
         subscription=>"remove");
    $self->Send($iq);
}


###############################################################################
#
# RosterParse - Returns a hash of roster items.
#
###############################################################################
sub RosterParse
{
    my $self = shift;
    my($iq) = @_;

    my $query = $iq->GetQuery();
    my @items = $query->GetItems();

    my %roster;
    foreach my $item (@items)
    {
        my $jid = $item->GetJID();
        $roster{$jid}->{name} = $item->GetName();
        $roster{$jid}->{subscription} = $item->GetSubscription();
        $roster{$jid}->{ask} = $item->GetAsk();
        $roster{$jid}->{groups} = [ $item->GetGroup() ];
    }

    return %roster;
}


###############################################################################
#
# RosterGet - Sends an empty IQ to the server to request that the user's
#             Roster be sent to them.  Returns a hash of roster items.
#
###############################################################################
sub RosterGet
{
    my $self = shift;

    my $iq = new Net::XMPP::IQ();
    $iq->SetIQ(type=>"get");
    my $query = $iq->NewQuery("jabber:iq:roster");

    $iq = $self->SendAndReceiveWithID($iq);
    return unless defined($iq);

    return $self->RosterParse($iq);
}


###############################################################################
#
# RosterRequest - Sends an empty IQ to the server to request that the user's
#                 Roster be sent to them, and return to let the user's program
#                 handle parsing the return packet.
#
###############################################################################
sub RosterRequest
{
    my $self = shift;

    my $iq = new Net::XMPP::IQ();
    $iq->SetIQ(type=>"get");
    my $query = $iq->NewQuery("jabber:iq:roster");

    $self->Send($iq);
}


###############################################################################
#
# RosterDBParse - takes an iq packet that containsa roster, parses it, and puts
#                 the roster into the Roster DB.
#
###############################################################################
sub RosterDBParse
{
    my $self = shift;
    my ($iq) = @_;

    my $type = $iq->GetType();
    return unless (($type eq "set") || ($type eq "result"));

    my %newroster = $self->RosterParse($iq);

    $self->RosterDBProcessParsed(%newroster);
}


###############################################################################
#
# RosterDBProcessParsed - takes a parsed roster and puts it into the Roster DB.
#
###############################################################################
sub RosterDBProcessParsed
{
    my $self = shift;
    my (%roster) = @_;

    foreach my $jid (keys(%roster))
    {
        if ($roster{$jid}->{subscription} eq "remove")
        {
            $self->RosterDBRemove($jid);
        }
        else
        {
            $self->RosterDBAdd($jid, %{$roster{$jid}} );
        }
    }
}


###############################################################################
#
# RosterDBAdd - adds the entry to the Roster DB.
#
###############################################################################
sub RosterDBAdd
{
    my $self = shift;
    my ($jid,%item) = @_;

    $self->{ROSTERDB}->{$jid} = \%item;
}


###############################################################################
#
# RosterDBRemove - removes the JID from the Roster DB.
#
###############################################################################
sub RosterDBRemove
{
    my $self = shift;
    my ($jid) = @_;

    delete($self->{ROSTERDB}->{$jid}) if exists($self->{ROSTERDB}->{$jid});
}


###############################################################################
#
# RosterDBQuery - allows you to get one of the pieces of info from the
#                 Roster DB.
#
###############################################################################
sub RosterDBQuery
{
    my $self = shift;
    my ($jid,$key) = @_;

    return unless exists($self->{ROSTERDB});
    return unless exists($self->{ROSTERDB}->{$jid});
    return unless exists($self->{ROSTERDB}->{$jid}->{$key});
    return $self->{ROSTERDB}->{$jid}->{$key};
}                        


###############################################################################
#+-----------------------------------------------------------------------------
#|
#| Default CallBacks
#|
#+-----------------------------------------------------------------------------
###############################################################################


###############################################################################
#
# callbackInit - initialize the default callbacks
#
###############################################################################
sub callbackInit
{
    my $self = shift;

    $self->SetCallBacks(iq=>sub{ $self->callbackIQ(@_) },
                        presence=>sub{ $self->callbackPresence(@_) },
                        message=>sub{ $self->callbackMessage(@_) },
                        );

    $self->SetPresenceCallBacks(available=>sub{ $self->callbackPresenceAvailable(@_) },
                                subscribe=>sub{ $self->callbackPresenceSubscribe(@_) },
                                unsubscribe=>sub{ $self->callbackPresenceUnsubscribe(@_) },
                                subscribed=>sub{ $self->callbackPresenceSubscribed(@_) },
                                unsubscribed=>sub{ $self->callbackPresenceUnsubscribed(@_) },
                               );
}


###############################################################################
#
# callbackMessage - default callback for <message/> packets.
#
###############################################################################
sub callbackMessage
{
    my $self = shift;
    my $sid = shift;
    my $message = shift;

    my $type = "normal";
    $type = $message->GetType() if $message->DefinedType();

    if (exists($self->{CB}->{Mess}->{$type}) &&
        (ref($self->{CB}->{Mess}->{$type}) eq "CODE"))
    {
        &{$self->{CB}->{Mess}->{$type}}($sid,$message);
    }
}


###############################################################################
#
# callbackPresence - default callback for <presence/> packets.
#
###############################################################################
sub callbackPresence
{
    my $self = shift;
    my $sid = shift;
    my $presence = shift;

    my $type = "available";
    $type = $presence->GetType() if $presence->DefinedType();

    if (exists($self->{CB}->{Pres}->{$type}) &&
        (ref($self->{CB}->{Pres}->{$type}) eq "CODE"))
    {
        &{$self->{CB}->{Pres}->{$type}}($sid,$presence);
    }
}


###############################################################################
#
# callbackIQ - default callback for <iq/> packets.
#
###############################################################################
sub callbackIQ
{
    my $self = shift;
    my $sid = shift;
    my $iq = shift;

    return unless $iq->DefinedQuery();
    my $query = $iq->GetQuery();
    return unless defined($query);

    my $type = $iq->GetType();
    my $ns = $query->GetXMLNS();

    if (exists($self->{CB}->{IQns}->{$ns}) &&
        (ref($self->{CB}->{IQns}->{$ns}) eq "CODE"))
    {
        &{$self->{CB}->{IQns}->{$ns}}($sid,$iq);

    } elsif (exists($self->{CB}->{IQns}->{$ns}->{$type}) &&
             (ref($self->{CB}->{IQns}->{$ns}->{$type}) eq "CODE"))
    {
        &{$self->{CB}->{IQns}->{$ns}->{$type}}($sid,$iq);
    }
}


###############################################################################
#
# callbackPresenceAvailable - default callback for available packets.
#
###############################################################################
sub callbackPresenceAvailable
{ 
    my $self = shift;
    my $sid = shift;
    my $presence = shift;

    my $reply = $presence->Reply();
    $self->Send($reply,1);
}


###############################################################################
#
# callbackPresenceSubscribe - default callback for subscribe packets.
#
###############################################################################
sub callbackPresenceSubscribe
{
    my $self = shift;
    my $sid = shift;
    my $presence = shift;

    my $reply = $presence->Reply(type=>"subscribed");
    $self->Send($reply,1);
    $reply->SetType("subscribe");
    $self->Send($reply,1);
}


###############################################################################
#
# callbackPresenceUnsubscribe - default callback for unsubscribe packets.
#
###############################################################################
sub callbackPresenceUnsubscribe
{
    my $self = shift;
    my $sid = shift;
    my $presence = shift;

    my $reply = $presence->Reply(type=>"unsubscribed");
    $self->Send($reply,1);
}

   
###############################################################################
#
# callbackPresenceSubscribed - default callback for subscribed packets.
#
###############################################################################
sub callbackPresenceSubscribed
{
    my $self = shift;
    my $sid = shift;
    my $presence = shift;

    my $reply = $presence->Reply(type=>"subscribed");
    $self->Send($reply,1);
}


###############################################################################
#
# callbackPresenceUnsubscribed - default callback for unsubscribed packets.
#
###############################################################################
sub callbackPresenceUnsubscribed
{
    my $self = shift;
    my $sid = shift;
    my $presence = shift;

    my $reply = $presence->Reply(type=>"unsubscribed");
    $self->Send($reply,1);
}


1;
