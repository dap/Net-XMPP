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

package Net::XMPP::Client;

=head1 NAME

Net::XMPP::Client - XMPP Client Module

=head1 SYNOPSIS

  Net::XMPP::Client is a module that provides a developer easy access
  to the Extensible Messaging and Presence Protocol (XMPP).

=head1 DESCRIPTION

  Client.pm uses Protocol.pm to provide enough high level APIs and
  automation of the low level APIs that writing an XMPP Client in
  Perl is trivial.  For those that wish to work with the low level
  you can do that too, but those functions are covered in the
  documentation for each module.

  Net::XMPP::Client provides functions to connect to an XMPP server,
  login, send and receive messages, set personal information, create
  a new user account, manage the roster, and disconnect.  You can use
  all or none of the functions, there is no requirement.

  For more information on how the details for how Net::XMPP is written
  please see the help for Net::XMPP itself.

  For a full list of high level functions available please see
  Net::XMPP::Protocol.

=head2 Basic Functions

    use Net::XMPP qw(Client);

    $Con = new Net::XMPP::Client();

    $Con->Connect(hostname=>"jabber.org");

    if ($Con->Connected()) {
      print "We are connected to the server...\n";
    }

    $status = $Con->Process();
    $status = $Con->Process(5);
    
    #
    # For the list of available function see Net::XMPP::Protocol.
    #

    $Con->Disconnect();

=head1 METHODS

=head2 Basic Functions

    new(debuglevel=>0|1|2, - creates the Client object.  debugfile
        debugfile=>string,   should be set to the path for the debug
        debugtime=>0|1)      log to be written.  If set to "stdout"
                             then the debug will go there.  debuglevel
                             controls the amount of debug.  For more
                             information about the valid setting for
                             debuglevel, debugfile, and debugtime see
                             Net::XMPP::Debug.

    Connect(hostname=>string,      - opens a connection to the server
            port=>integer,           listed in the hostname (default
            timeout=>int             localhost), on the port (default
            connectiontype=>string,  5222) listed, using the
            ssl=>0|1)                connectiontype listed (default
                                     tcpip).  The two connection types
                                     available are:
                                       tcpip  standard TCP socket
                                       http   TCP socket, but with the
                                              headers needed to talk
                                              through a web proxy
                                     If you specify ssl, then it will
                                     be used to connect.

    Execute(hostname=>string,       - Generic inner loop to handle
            port=>int,                connecting to the server, calling
            ssl=>0|1,                 Process, and reconnecting if the
            username=>string,         connection is lost.  There are
            password=>string,         five callbacks available that are
            resource=>string,         called at various places:
            register=>0|1,              onconnect - when the client has
            connectiontype=>string,                 made a connection.
            connecttimeout=>string,     onauth - when the connection is
            connectattempts=>int,                made and user has been
            connectsleep=>int,                   authed.  Essentially,
            processtimeout=>int)                 this is when you can
                                                 start doing things
                                                 as a Client.  Like
                                                 send presence, get your
                                                 roster, etc...
                                        onprocess - this is the most
                                                    inner loop and so
                                                    gets called the most.
                                                    Be very very careful
                                                    what you put here
                                                    since it can
                                                    *DRASTICALLY* affect
                                                    performance.
                                        ondisconnect - when the client
                                                       disconnects from
                                                       the server.
                                        onexit - when the function gives
                                                 up trying to connect and
                                                 exits.
                                      The arguments are passed straight on
                                      to the Connect function, except for
                                      connectattempts and connectsleep.
                                      connectattempts is the number of
                                      times that the Component should try
                                      to connect before giving up.  -1
                                      means try forever.  The default is
                                      -1. connectsleep is the number of
                                      seconds to sleep between each
                                      connection attempt.

                                      If you specify register=>1, then the
                                      Client will attempt to register the
                                      sepecified account for you, if it
                                      does not exist.
            
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

    Disconnect() - closes the connection to the server.

    Connected() - returns 1 if the Transport is connected to the server,
                  and 0 if not.

=head1 AUTHOR

Ryan Eatmon

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use Carp;
use base qw( Net::XMPP::Protocol );

sub new
{
    my $proto = shift;
    my $self = { };

    my %args;
    while($#_ >= 0) { $args{ lc(pop(@_)) } = pop(@_); }

    bless($self, $proto);

    $self->{DEBUG} =
        new Net::XMPP::Debug(level=>exists($args{debuglevel}) ? $args{debuglevel} : -1,
                             file=>exists($args{debugfile}) ? $args{debugfile} : "stdout",
                             time=>exists($args{debugtime}) ? $args{debugtime} : 0,
                             setdefault=>1,
                             header=>"XMPP::Client"
                    );

    $self->{SERVER} = {hostname => "localhost",
                       port => 5222 ,
                       ssl=>(exists($args{ssl}) ? $args{ssl} : 0),
                       connectiontype=>(exists($args{connectiontype}) ? $args{connectiontype} : "tcpip")
                      };

    $self->{CONNECTED} = 0;
    $self->{DISCONNECTED} = 0;

    $self->{STREAM} = new XML::Stream(style=>"node",
                                      debugfh=>$self->{DEBUG}->GetHandle(),
                                      debuglevel=>$self->{DEBUG}->GetLevel(),
                                      debugtime=>$self->{DEBUG}->GetTime());

    $self->{LIST}->{currentID} = 0;

    $self->callbackInit();

    return $self;
}


###########################################################################
#
# Connect - Takes a has and opens the connection to the specified server.
#           Registers CallBack as the main callback for all packets from
#           the server.
#
#           NOTE:  Need to add some error handling if the connection is
#           not made because the server hostname is wrong or whatnot.
#
###########################################################################
sub Connect
{
    my $self = shift;

    while($#_ >= 0) { $self->{SERVER}{ lc pop(@_) } = pop(@_); }

    $self->{DEBUG}->Log1("Connect: hostname($self->{SERVER}->{hostname})");

    $self->{SERVER}->{timeout} = 10 unless exists($self->{SERVER}->{timeout});

    delete($self->{SESSION});
    $self->{SESSION} =
        $self->{STREAM}->
            Connect(hostname=>$self->{SERVER}->{hostname},
                    port=>$self->{SERVER}->{port},
                    namespace=>"jabber:client",
                    connectiontype=>$self->{SERVER}->{connectiontype},
                    ssl=>$self->{SERVER}->{ssl},
                    timeout=>$self->{SERVER}->{timeout},
                   );

    if ($self->{SESSION}) {
        $self->{DEBUG}->Log1("Connect: connection made");

        $self->{STREAM}->SetCallBacks(node=>sub{ $self->CallBack(@_) });
        $self->{CONNECTED} = 1;
        return 1;
    } else {
        $self->SetErrorCode($self->{STREAM}->GetErrorCode());
        return;
    }
}


###############################################################################
#
#  Process - If a timeout value is specified then the function will wait
#            that long before returning.  This is useful for apps that
#            need to handle other processing while still waiting for
#            packets.  If no timeout is listed then the function waits
#            until a packet is returned.  Either way the function exits
#            as soon as a packet is returned.
#
###############################################################################
sub Process
{
    my $self = shift;
    my ($timeout) = @_;
    my %status;

    if (exists($self->{PROCESSERROR}) && ($self->{PROCESSERROR} == 1))
    {
        croak("There was an error in the last call to Process that you did not check for and\nhandle.  You should always check the output of the Process call.  If it was\nundef then there was a fatal error that you need to check.  There is an error\nin your program");
    }

    $self->{DEBUG}->Log1("Process: timeout($timeout)") if defined($timeout);

    if (!defined($timeout) || ($timeout eq ""))
    {
        while(1)
        {
            %status = $self->{STREAM}->Process();
            $self->{DEBUG}->Log1("Process: status($status{$self->{SESSION}->{id}})");
            last if ($status{$self->{SESSION}->{id}} != 0);
            select(undef,undef,undef,.25);
        }
        $self->{DEBUG}->Log1("Process: return($status{$self->{SESSION}->{id}})");
        if ($status{$self->{SESSION}->{id}} == -1)
        {
            $self->{PROCESSERROR} = 1;
            return;
        }
        else
        {
            return $status{$self->{SESSION}->{id}};
        }
    }
    else
    {
        %status = $self->{STREAM}->Process($timeout);
        if ($status{$self->{SESSION}->{id}} == -1)
        {
            $self->{PROCESSERROR} = 1;
            return;
        }
        else
        {
            return $status{$self->{SESSION}->{id}};
        }
    }
}


###########################################################################
#
# Disconnect - Sends the string to close the connection cleanly.
#
###########################################################################
sub Disconnect
{
    my $self = shift;

    $self->{STREAM}->Disconnect($self->{SESSION}->{id})
        if ($self->{CONNECTED} == 1);
    $self->{CONNECTED} = 0;
    $self->{DISCONNECTED} = 1;
    $self->{DEBUG}->Log1("Disconnect: bye bye");
}


###########################################################################
#
# Connected - returns 1 if the Transport is connected to the server, 0
#             otherwise.
#
###########################################################################
sub Connected
{
    my $self = shift;

    $self->{DEBUG}->Log1("Connected: ($self->{CONNECTED})");
    return $self->{CONNECTED};
}


###########################################################################
#
# Execute - generic inner loop to listen for incoming messages, stay
#           connected to the server, and do all the right things.  It
#           calls a couple of callbacks for the user to put hooks into
#           place if they choose to.
#
###########################################################################
sub Execute
{
    my $self = shift;
    my %args;
    while($#_ >= 0) { $args{ lc pop(@_) } = pop(@_); }

    $args{connectattempts} = -1 unless exists($args{connectattempts});
    $args{connectsleep} = 5 unless exists($args{connectsleep});
    $args{register} = 0 unless exists($args{register});

    my %connect;
    $connect{hostname} = $args{hostname};
    $connect{port} = $args{port}
        if exists($args{port});
    $connect{connectiontype} = $args{connectiontype}
        if exists($args{connectiontype});
    $connect{timeout} = $args{connecttimeout}
        if exists($args{connecttimeout});
    $connect{ssl} = $args{ssl} if exists($args{ssl});
    
    $self->{DEBUG}->Log1("Execute: begin");

    my $connectAttempt = $args{connectattempts};

    while(($connectAttempt == -1) || ($connectAttempt > 0))
    {

        $self->{DEBUG}->Log1("Execute: Attempt to connect ($connectAttempt)");

        my $status = $self->Connect(%connect);

        if (!(defined($status)))
        {
            $self->{DEBUG}->Log1("Execute: Server is not answering.  (".$self->GetErrorCode().")");
            $self->{CONNECTED} = 0;

            $connectAttempt-- unless ($connectAttempt == -1);
            sleep($args{connectsleep});
            next;
        }

        $self->{DEBUG}->Log1("Execute: Connected...");
        &{$self->{CB}->{onconnect}}() if exists($self->{CB}->{onconnect});

        my @result = $self->AuthSend(username=>$args{username},
                                     password=>$args{password},
                                     resource=>$args{resource}
                                     );
        if ($result[0] ne "ok")
        {
            $self->{DEBUG}->Log1("Execute: Could not auth with server: ($result[0]: $result[1])");
            &{$self->{CB}->{onauthfail}}()
                if exists($self->{CB}->{onauthfail});
            
            if ($args{register} == 0)
            {
                $self->{DEBUG}->Log1("Execute: Register turned off.  Exiting.");
                $self->Disconnect();
                &{$self->{CB}->{ondisconnect}}()
                    if exists($self->{CB}->{ondisconnect});
                $connectAttempt = 0;
            }
            else
            {
                my %fields = $self->RegisterRequest();

                $fields{username} = $args{username};
                $fields{password} = $args{password};

                $self->RegisterSend(%fields);
                
                @result = $self->AuthSend(username=>$args{username},
                                          password=>$args{password},
                                          resource=>$args{resource}
                                         );

                if ($result[0] ne "ok")
                {
                    $self->{DEBUG}->Log1("Execute: Register failed.  Exiting.");
                    &{$self->{CB}->{onregisterfail}}()
                        if exists($self->{CB}->{onregisterfail});
            
                    $self->Disconnect();
                    &{$self->{CB}->{ondisconnect}}()
                        if exists($self->{CB}->{ondisconnect});
                    $connectAttempt = 0;
                }
                else
                {
                    &{$self->{CB}->{onauth}}()
                        if exists($self->{CB}->{onauth});
                }
            }
        }
        else
        {
            &{$self->{CB}->{onauth}}()
                if exists($self->{CB}->{onauth});
        }
 
        while($self->Connected())
        {

            while(defined($status = $self->Process($args{processtimeout})))
            {
                &{$self->{CB}->{onprocess}}()
                    if exists($self->{CB}->{onprocess});
            }

            if (!defined($status))
            {
                $self->Disconnect();
                $self->{DEBUG}->Log1("Execute: Connection to server lost...");
                &{$self->{CB}->{ondisconnect}}()
                    if exists($self->{CB}->{ondisconnect});

                $connectAttempt = $args{connectattempts};
                next;
            }
        }

        last if $self->{DISCONNECTED};
    }

    $self->{DEBUG}->Log1("Execute: end");
    &{$self->{CB}->{onexit}}() if exists($self->{CB}->{onexit});
}


1;
