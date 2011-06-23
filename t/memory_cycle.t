use strict;
use warnings;

use Test::More;
my $fail;
BEGIN {
	eval "use Test::Memory::Cycle";
	$fail = $@;
}
plan skip_all => 'Need Test::Memory::Cycle' if $fail;


plan tests => 1;

use Net::XMPP;

my $conn   = Net::XMPP::Client->new;

memory_cycle_ok($conn);

