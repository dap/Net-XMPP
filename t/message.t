use lib "t/lib";
use Test::More tests=>94;

BEGIN{ use_ok( "Net::XMPP","Client" ); }

require "t/mytestlib.pl";

#------------------------------------------------------------------------------
# message
#------------------------------------------------------------------------------
my $message = new Net::XMPP::Message();
ok( defined($message), "new()");
isa_ok( $message, "Net::XMPP::Message");

testScalar($message, "Body", "body");
testScalar($message, "Error", "error");
testScalar($message, "ErrorCode", "401");
testJID($message, "From", "user1", "server1", "resource1");
testScalar($message, "ID", "id");
testScalar($message, "Subject", "subject");
testScalar($message, "Thread", "thread");
testJID($message, "To", "user2", "server2", "resource2");
testScalar($message, "Type", "Type");

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my $xoob = $message->NewX("__netxmpp__:x:test");
ok( defined( $xoob ), "NewX - __netxmpp__:x:test" );
isa_ok( $xoob, "Net::XMPP::X" );

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x = $message->GetX();
is( $x[0], $xoob, "Is the first x the oob?");

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my $xroster = $message->NewX("__netxmpp__:x:test:two");
ok( defined( $xoob ), "NewX - __netxmpp__:x:test:two" );
isa_ok( $xoob, "Net::XMPP::X" );

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x2 = $message->GetX();
is( $x2[0], $xoob, "Is the first x the oob?");
is( $x2[1], $xroster, "Is the second x the roster?");

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x3 = $message->GetX("__netxmpp__:x:test");
is( $#x3, 0, "filter on xmlns - only one x... right?");
is( $x3[0], $xoob, "Is the first x the oob?");

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x4 = $message->GetX("__netxmpp__:x:test:two");
is( $#x4, 0, "filter on xmlns - only one x... right?");
is( $x4[0], $xroster, "Is the first x the roster?");

ok( $message->DefinedX(), "DefinedX - yes");
ok( $message->DefinedX("__netxmpp__:x:test:two"), "DefinedX - __netxmpp__:x:test:two - yes");
ok( $message->DefinedX("__netxmpp__:x:test"), "DefinedX - __netxmpp__:x:test - yes");
ok( !$message->DefinedX("foo:bar"), "DefinedX - foo:bar - no");

#------------------------------------------------------------------------------
# message
#------------------------------------------------------------------------------
my $message2 = new Net::XMPP::Message();
ok( defined($message2), "new()");
isa_ok( $message2, "Net::XMPP::Message");

#------------------------------------------------------------------------------
# defined
#------------------------------------------------------------------------------
is( $message2->DefinedBody(), '', "body not defined" );
is( $message2->DefinedError(), '', "error not defined" );
is( $message2->DefinedErrorCode(), '', "errorcode not defined" );
is( $message2->DefinedFrom(), '', "from not defined" );
is( $message2->DefinedID(), '', "id not defined" );
is( $message2->DefinedSubject(), '', "subject not defined" );
is( $message2->DefinedThread(), '', "thread not defined" );
is( $message2->DefinedTo(), '', "to not defined" );
is( $message2->DefinedType(), '', "type not defined" );

#------------------------------------------------------------------------------
# set it
#------------------------------------------------------------------------------
$message2->SetMessage(body=>"body",
                      error=>"error",
                      errorcode=>"401",
                      from=>"user1\@server1/resource1",
                      id=>"id",
                      subject=>"subject",
                      thread=>"thread",
                      to=>"user2\@server2/resource2",
                      type=>"type");

testPostScalar($message2, "Body", "body");
testPostScalar($message2, "Error", "error");
testPostScalar($message2, "ErrorCode", "401");
testPostJID($message2, "From", "user1", "server1", "resource1");
testPostScalar($message2, "ID", "id");
testPostScalar($message2, "Subject", "subject");
testPostScalar($message2, "Thread", "thread");
testPostJID($message2, "To", "user2", "server2", "resource2");
testPostScalar($message2, "Type", "type");

