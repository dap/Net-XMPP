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

package Net::XMPP::Namespaces;

=head1 NAME

Net::XMPP::Namespaces - In depth discussion on how
                        namespaces are handled

=head1 SYNOPSIS

  Net::XMPP::Namespaces is a pure documentation
  module.  It provides no code for execution, just
  documentation on how the Net::XMPP modules handle
  namespaces.

=head1 DESCRIPTION

  XMPP as a protocol is very well defined.  There are
  three main top level packets (message, iq, and presence).
  There is also a way to extend the protocol in a very
  clear and strucutred way, via namespaces.

  Two major ways that namespaces are used in Jabber is
  for making the <iq/> a generic wrapper, and as a way
  for adding data to any packet via a child tag <x/>.
  We will use <x/> to represent the packet, but in reality
  it could be any child tag: <foo/>, <data/>, <error/>, etc.

  The Info/Query <iq/> packet uses namespaces to determine
  the type of information to access.  Usually there is a
  <query/> tag in the <iq/> that represents the namespace,
  but in fact it can be any tag.  The definition of the
  Query portion, is the first tag that has a namespace.

    <iq type="get"><query xmlns="..."/></iq>

      or

    <iq type="get"><foo xmlns="..."/></iq>

  After that Query stanza can be any number of other stanzas
  (<x/> tags) you want to include.  The Query packet is
  represented and available by calling GetQuery(), and the
  other namespaces are available by calling GetX().

  The X tag is just a way to piggy back data on other
  packets.  Like embedding the timestamp for a message
  using jabber:x:delay, or signing you presence for
  encryption using jabber:x:signed.

  To this end, Net::XMPP has sought to find a way to
  easily, and clearly define the functions needed to
  access the XML for a namespace.  We will go over the
  full docs, and then show two examples of real namespaces
  so that you can see what we are talking about.

=head2 Overview

  To avoid a lot of nasty modules populating memory that
  are not used, and to avoid having to change 15 modules
  when a minor change is introduced, the Net::XMPP modules
  have taken AUTOLOADing to the extreme.  Query.pm and X.pm
  are nothing but a hash of hashes that is accessed by the
  XMPP.pm AUTOLOAD function to do something.  (This will
  make sense, I promise.)

  Before going on, I highly suggest you read a Perl book
  on AUTOLOAD and how it works.  From this point on I will
  assume that you understand it.

  When you create a Net::XMPP::IQ object and add a Query
  to it (NewQuery) several things are happening in the
  background.  The argument to NewQuery is the namespace
  you want to add. (custom-namespace)

  Now that you have a Query object to work with you will
  call the GetXXX functions, and SetXXX functions to set
  the data.  There are no defined GetXXX and SetXXXX
  functions.  You cannot look in the Query.pm file and
  find them.  Instead you will find something like this:

$ns = "namespace";

$TAGS{$ns} = "mytag";

$NAMESPACES{$ns}->{Username}->{Path} = 'username';

$NAMESPACES{$ns}->{JID}->{Type} = 'jid';
$NAMESPACES{$ns}->{JID}->{Path} = '@jid';

  When the GetUsername() function is called, the AUTOLOAD
  function looks in the Query.pm %NAMESPACES hash for
  a "Username" key.  Based on the Type of the field
  (scalar being the default) it will use the Path as
  an XPath to retrieve the data and call the XPathGet()
  method in XMPP.pm.

=head2 Net::XMPP private namespaces

  Now this is where this starts to get a little sticky.
  When you see a namespace with __netxmpp__, or
  __netjabber__ from Net::Jabber, at the beginning it is
  usually something custom to Net::XMPP and NOT part of
  the actual XMPP protocol.

  There are some places where the structure of the XML
  is a little more loose and not strongly structured.
  While it is still strongly defined, it is not 100%
  clear on how exactly to handle the tags.  The main
  places you will see this behavior is where you have
  multiple tags with the same name and those have
  children under them (jabber:iq:roster), or where the
  tags are not defined but are to be treated as children
  just because they are there (jabber:iq:browse).

  In jabber:iq:roster, the <item/> tag can be repeated
  multiple times, and is sort of like a mini-namespace
  in itself.  To that end, we treat it like a seperate
  namespace and defined a __netjabber__:iq:roster:item
  namespace to hold it.  What happens is this, in my code
  I define that the <item/>s tag is "item" and anything
  with that tag name is to create a new Net::XMPP::Query
  object with the namespace __netjabber__:iq:roster:item
  which then becomes a {query} child of the jabber:iq:roster
  Query object.  Also, when you want to add a new item
  to a jabber:iq:roster project you call NewQuery with
  the private namespace.

  In jabber:iq:browse, the children are not defined.
  Any child node you see under that <iq/> tag defines
  what the child type is.  So I again created a private
  namespace, and add every child, except <ns/>, as a
  new Query object.

  I know this sounds complicated.  And if after reading
  this entire document it is still complicated, email me,
  ask questions, and I will monitor it and adjust these
  docs to answer the questions that people ask.

=head2 Get() function

  The values of the argument come in two forms, either a
  string or an array.  For the most part, you will only
  use a string. The string is the key into the hash in the
  Query object. So above code would look into the Query
  hash for the "username" key and return the value from
  there.  The string also represents the value of the tag
  or attribute in the XML.

    "username" -> hash{username} -> <username/>

  One of the functions introduced early on in the Net::XMPP
  lifecycle was one that you could call and set all of the
  values of an object.  SetIQ() in the IQ.pm module for
  example.  Moving into this new AUTOLOAD format I added
  a GetIQ() function that would return a hash with the
  values populated as if you had called SetIQ().  This is
  done when you set the string to "__netjabber__:master".
  So for the jabber:iq:register example above:

$NAMESPACES{"jabber:iq:register"}->{Register}->{Get} =
  "__netjabber__:master";
$NAMESPACES{"jabber:iq:register"}->{Register}->{Set} =
  ["master"];

  GetReigster() would return a hash with the data in the
  Query.

  The second form is an array:
    [ key, namespace ]

  like GetItem under the jabber:iq:search namespace:
    [ "query", "__netjabber__:iq:search" ]

  This is used only when the GetXXXXX function is supposed
  to return another object.  For example, under
  jabber:iq:search, the agent can return multiple <item/>
  tags.  These are turned in to Query objects as well and
  stored in the {DATA}->{query} hash array.  The array value
  tells the Get() function where to look "query", and which
  Query objects to return, anything with the namespace
  "__netjabber__:iq:search".

=head2 Set() function

  This arguement value is always an array.  Though the
  array can take a few forms depending on what you are
  trying to set.

  The first is the simplest, and the one you will more
  than likely only use:

    [ type, key ]

  In our jabber:iq:register example above {Username}->{Set}
  is [ "scalar", "username" ].  The type is scalar, and
  the key is username (again the key is the hash entry, and
  the XML Tag or attribute).  The valid types are:

    scalar  - store the value as a string or number
    array   - store the value as an array (like in
              jabber:iq:roster with <group/>)
    flag    - sets the value to "" just to show that the
              XML should appear as a flag.  <tag/>
    jid     - Stores the value as a Net::XMPP::JID
              object
    master  - run through all of the SetXXXX functions
              and set the value based on the hash passed
              in as an argument.  (More on this below...)
    special - there are several cases where we want to
              default the value if there is none there.
              mainly used in the jabber:iq:time and
              jabber:iq:version functions, these will
              default the value to something that makes
              sense.  You will probably never use this.

  As I mentioned, one of the functions introduced early on
  in the Net::XMPP lifecycle was one that you could call
  and set all of the values of an object.  SetIQ() in the
  IQ.pm module for example.  This is where the "master"
  type comes in.  When you declare that something is the
  "master" it means that it can set all of the things in
  the object via the SetXXXXXX functions based on the hash
  that is passed to it.  So for jabber:iq:register:

$NAMESPACES{"jabber:iq:register"}->{Register}->{Set} =
  ["master"];

  SetRegister(%hash) is considered to be the "master"
  function for that namespace.

  The second is more complicated and involves adding a new
  XML child into the current tag.  This is only done
  inside of the ParseTree function when taking XML and
  building the Net::XMPP::xxxxxx objects that represent
  the tree.  It takes the form:

    [ "add", object type, namespace ]
    [ "add", object type, namespace, tags to ignore ]

  Looking at the jabber:iq:roster namespace:

$NAMESPACES{"jabber:iq:roster"}->{Item}->{Set} =
  ["add","Query","__netjabber__:iq:roster:item"];

  A call to SetItem will add a new Net::XMPP::Query,
  with the namespace __netjabber__:iq:roster:item, and
  then populate the new Query object with the data you
  passed to the SetItem function.  (This will be covered
  more under the ParseTree function described at the end.)

  Looking at the __netjabber__:iq:browse:item namespace:

$NAMESPACES{"__netjabber__:iq:browse"}->{Item}->{Set} =
  ["add","Query","__netjabber__:iq:browse","ns"];

  Everything looks the same except for the extra "ns"
  at the end.  This tells Net::XMPP that you can create
  a new object from this XML data *UNLESS* the tag name
  is <ns/>.  If you look at the jabber:iq:browse namespace
  in the JPG, you will see that the children can have
  any name, except for <ns/> which is used to define which
  namespaces the jid provides.  (This will be covered
  more under the ParseTree function described at the end.)

=head2 Defined() function

  This function always takes a string as the argument.
  The string is the key value for the data hash, and tells
  Net::XMPP where to go look to see if the value is
  defined.  This one should not need any more explantion
  other than that.  All it does is check for exists() on
  the data hash for this value.

=head2 Hash() function

  This function takes only a string as its argument.
  The value of the string determines how this bit
  of data is handled when Net::XMPP attempts to read
  or set the XML.  The valid values are:

    att             - in the parent XML this bit of
                      data is an attribute on the root
                      tag in the XML you are currently
                      processing.
    data            - in the parent XML this bit of
                      data is the CDATA of the root
                      tag in the XML you are currently
                      processing.
    child-data      - in the parent XML this bit of
                      data is the CDATA of a child tag
                      (defined by the NAMESPACES hash)
                      of the root tag in the XML you
                      are currently processing.
    child-flag      - in the parent XML this bit of
                      data says to include an empty child
                      tag (defined by the NAMESPACES hash)
                      of the root tag in the XML you
                      are currently processing.
    child-add       - in the parent XML this bit of
                      data says to create a new XML
                      child and populate it by recursing
                      and looking at the Hash() values
                      for its data.
    att-<tag>-<att> - in the parent XML this bit of
                      data says to set the <att>
                      attribute on the child with tag
                      <tag> in the root tag you are
                      currently processing.

  I know this sounds really complicated, but its not.
  Just look over the %NAMESPACES structures and think
  about how the XML looks for the namespace you are
  looking at.

=head2 Add() function

  This function takes an array as its argument.  The array
  has two very similer forms:

    [ object type, namespace, Set* function to call ]
    [ object type, namespace, Set* function to call, tag value ]

  When the Add function gets called it will create a
  Net::XMPP::"object type" object with the namespace
  specified, and then call the SetXXXXX function based
  on the third value.  If a tag value is specified in
  the array, then that becomes the root tag for that
  object, otherwise the first argument to the AddXXXXX
  function defines the root tag.

  Looking at the jabber:iq:roster namespace:

$NAMESPACES{"jabber:iq:roster"}->{Item}->{Add} =
  ["Query","__netjabber__:iq:roster:item","Item","item"];

  A call to AddItem() will create a Net::XMPP::Query
  object with __netjabber__:iq:roster:item as the namespace.
  It will call SetItem on this new object to handle the
  data passed to AddItem(), *AND* it will set the root
  tag to "item" so that an <item/> tag is created.

  Looking at the jabber:iq:browse namespace:

$NAMESPACES{"jabber:iq:browse"}->{Item}->{Add} =
  ["Query","__netjabber__:iq:browse","Browse"];

  A call to AddItem() will create a Net::XMPP::Query
  object with __netjabber__:iq:browse:item as the namespace.
  It will call SetBrowse on this new object to handle the
  data passed to AddItem().  The root tag of new object
  is not defined though.  Instead, since the
  jabber:iq:browse namespaces does not define the
  children tags, and uses the value of the tag to
  set what the browse item means, the call to AddItem()
  must include the root tag as the first argument:

    my $browseItem =
      $browseQuery->
        AddItem("conference",
                type=>"private",
                jid=>"conference.jabber.org",
                name=>"Private Chatrooms");

=head2 ParseTree() function

  This function you will never call, but it will
  be calling the functions that you define in your
  call to DefineNamespace.  We will quickly run through
  how it works so you can get a better understanding
  of how the all of the above fits together.

  ParseTree() takes an XML::Stream::Hash tree and
  runs through every function that hash a {Set} entry
  in the definition Hash (see above).  For each
  function it calls Hash() on that function name
  to get the method of XML access for that function.
  Based on that value, it reaches into the
  XML::Stream::Hash and pulls the needed data out and
  calls the appropritate SetXXXXXXX() function to store
  that data.  If the Hash type is "child-add", then
  it calls Add() and passes it the XML::Stream::Hash
  tree with the {root} tag altered and ultimatly
  ParseTree is called on that new tree and starts again.

  After the defined {Set} functions have been looked at,
  the function looks for any child tags that have xmlns
  as an attribute.  If the current object is an <iq/>
  then it treats the first tag with an xmlns as the
  <query/> and creates that.  Otherwise, if the current
  object is a Query object, then this must be a private
  namespace for Net::XMPP, so create a Query object.
  Finally, if that fails, and this is not the first
  child with xmlns, or this is not a Query object then
  create an X object.

  Scrub.

  Rinse.

  Repeat.

=head2 Wrap Up

  Well.  I hope that I have not scared you off from
  writing a custom namespace for you application and
  use Net::XMPP.  Look in the Net::XMPP::Protocol
  manpage for an example on using the DefineNamespace
  function to register your custom namespace so that
  Net::XMPP can properly handle it.

=head1 AUTHOR

By Ryan Eatmon in May 2001 for http://jabber.org/

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
