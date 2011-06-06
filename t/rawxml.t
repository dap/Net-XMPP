use lib "t/lib";
use Test::More tests=>54;

BEGIN{ use_ok( "Net::XMPP" ); }

require "t/mytestlib.pl";

my $message = Net::XMPP::Message->new();
ok( defined($message), "new()");
isa_ok( $message, "Net::XMPP::Message");

testScalar($message, "Body", "body");
testJID($message, "From", "user1", "server1", "resource1");
testScalar($message, "Subject", "subject");
testJID($message, "To", "user2", "server2", "resource2");

$message->InsertRawXML("<foo>bar</foo>");
$message->InsertRawXML("<bar>foo</bar>");

is( $message->GetXML(), "<message from='user1\@server1/resource1' to='user2\@server2/resource2'><body>body</body><subject>subject</subject><foo>bar</foo><bar>foo</bar></message>", "GetXML()" );

$message->ClearRawXML();

is( $message->GetXML(), "<message from='user1\@server1/resource1' to='user2\@server2/resource2'><body>body</body><subject>subject</subject></message>", "GetXML()" );

$message->InsertRawXML("<bar>foo</bar>");

is( $message->GetXML(), "<message from='user1\@server1/resource1' to='user2\@server2/resource2'><body>body</body><subject>subject</subject><bar>foo</bar></message>", "GetXML()" );


my $iq = Net::XMPP::IQ->new();
ok( defined($iq), "new()");
isa_ok( $iq, "Net::XMPP::IQ");

testJID($iq, "From", "user1", "server1", "resource1");
testJID($iq, "To", "user2", "server2", "resource2");

my $query = $iq->NewChild("jabber:iq:auth");
ok( defined($query), "NewChild()");
isa_ok( $query, "Net::XMPP::Stanza" );

testPostScalar( $query, "XMLNS", "jabber:iq:auth");

is( $iq->GetXML(), "<iq from='user1\@server1/resource1' to='user2\@server2/resource2'><query xmlns='jabber:iq:auth'/></iq>", "GetXML()");

$iq->InsertRawXML("<test1/>");

is( $iq->GetXML(), "<iq from='user1\@server1/resource1' to='user2\@server2/resource2'><query xmlns='jabber:iq:auth'/><test1/></iq>", "GetXML()");

$query->InsertRawXML("<test2/>");

is( $query->GetXML(), "<query xmlns='jabber:iq:auth'><test2/></query>", "GetXML()");

is( $iq->GetXML(), "<iq from='user1\@server1/resource1' to='user2\@server2/resource2'><query xmlns='jabber:iq:auth'><test2/></query><test1/></iq>", "GetXML()");


