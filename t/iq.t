use lib "t/lib";
use Test::More tests=>86;

BEGIN{ use_ok( "Net::XMPP","Client" ); }

require "t/mytestlib.pl";

#------------------------------------------------------------------------------
# iq
#------------------------------------------------------------------------------
my $iq = new Net::XMPP::IQ();
ok( defined($iq), "new()");
isa_ok( $iq, "Net::XMPP::IQ");

testScalar($iq, "Error", "error");
testScalar($iq, "ErrorCode", "401");
testJID($iq, "From", "user1", "server1", "resource1");
testScalar($iq, "ID", "id");
testJID($iq, "To", "user2", "server2", "resource2");
testScalar($iq, "Type", "Type");

is( $iq->DefinedX("__netxmpptest__:x:test"), "", "not DefinedX - __netxmpptest__:x:test" );
is( $iq->DefinedX("__netxmpptest__:x:test:two"), "", "not DefinedX - __netxmpptest__:x:test:two" );

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my $xoob = $iq->NewX("__netxmpptest__:x:test");
ok( defined( $xoob ), "NewX - __netxmpptest__:x:test" );
isa_ok( $xoob, "Net::XMPP::X" );
is( $iq->DefinedX(), 1, "DefinedX" );
is( $iq->DefinedX("__netxmpptest__:x:test"), 1, "DefinedX - __netxmpptest__:x:test" );

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x = $iq->GetX();
is( $x[0], $xoob, "Is the first x the oob?");

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my $xroster = $iq->NewX("__netxmpptest__:x:test:two");
ok( defined( $xoob ), "NewX - __netxmpptest__:x:test:two" );
isa_ok( $xoob, "Net::XMPP::X" );
is( $iq->DefinedX(), 1, "DefinedX" );
is( $iq->DefinedX("__netxmpptest__:x:test"), 1, "DefinedX - __netxmpptest__:x:test" );
is( $iq->DefinedX("__netxmpptest__:x:test:two"), 1, "DefinedX - __netxmpptest__:x:test:two" );

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x2 = $iq->GetX();
is( $x2[0], $xoob, "Is the first x the oob?");
is( $x2[1], $xroster, "Is the second x the roster?");

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x3 = $iq->GetX("__netxmpptest__:x:test");
is( $#x3, 0, "filter on xmlns - only one x... right?");
is( $x3[0], $xoob, "Is the first x the oob?");

#------------------------------------------------------------------------------
# X
#------------------------------------------------------------------------------
my @x4 = $iq->GetX("__netxmpptest__:x:test:two");
is( $#x4, 0, "filter on xmlns - only one x... right?");
is( $x4[0], $xroster, "Is the first x the roster?");

is( $iq->DefinedX("__netxmpptest__:x:test:three"), "", "not DefinedX - __netxmpptest__:x:test:three" );

#------------------------------------------------------------------------------
# iq
#------------------------------------------------------------------------------
my $iq2 = new Net::XMPP::IQ();
ok( defined($iq2), "new()");
isa_ok( $iq2, "Net::XMPP::IQ");

#------------------------------------------------------------------------------
# defined
#------------------------------------------------------------------------------
is( $iq2->DefinedError(), '', "error not defined" );
is( $iq2->DefinedErrorCode(), '', "errorcode not defined" );
is( $iq2->DefinedFrom(), '', "from not defined" );
is( $iq2->DefinedID(), '', "id not defined" );
is( $iq2->DefinedTo(), '', "to not defined" );
is( $iq2->DefinedType(), '', "type not defined" );

#------------------------------------------------------------------------------
# set it
#------------------------------------------------------------------------------
$iq2->SetIQ(error=>"error",
            errorcode=>"401",
            from=>"user1\@server1/resource1",
            id=>"id",
            to=>"user2\@server2/resource2",
            type=>"type");

testPostScalar($iq, "Error", "error");
testPostScalar($iq, "ErrorCode", "401");
testPostJID($iq, "From", "user1", "server1", "resource1");
testPostScalar($iq, "ID", "id");
testPostJID($iq, "To", "user2", "server2", "resource2");
testPostScalar($iq, "Type", "Type");


my $iq3 = new Net::XMPP::IQ();
ok( defined($iq3), "new()");
isa_ok( $iq3, "Net::XMPP::IQ");

$iq3->SetIQ(error=>"error",
            errorcode=>"401",
            from=>"user1\@server1/resource1",
            id=>"id",
            to=>"user2\@server2/resource2",
            type=>"type");

my $query = $iq3->NewQuery("__netxmpptest__:query:test");
ok( defined($query), "new()");
isa_ok( $query, "Net::XMPP::Query");

$query->SetTest(Bar=>"bar",
                Foo=>"foo");

is( $iq3->GetXML(), "<iq from='user1\@server1/resource1' id='id' to='user2\@server2/resource2' type='type'><error code='401'>error</error><test foo='foo' xmlns='__netxmpptest__:query:test'><bar>bar</bar></test></iq>", "GetXML()");

my $reply = $iq3->Reply();

is( $reply->GetXML(), "<iq from='user2\@server2/resource2' id='id' to='user1\@server1/resource1' type='result'><test xmlns='__netxmpptest__:query:test'/></iq>", "GetXML()");


