use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::XMPP',
    license             => 'lgpl',
    dist_author         => 'xmpplar',
    dist_abstract		=> 'XMPP Support Library',
    dist_version_from   => 'lib/Net/XMPP.pm',
    requires => {
        'XML::Stream' => 1.22,
        'Digest::SHA1' => 1.02,
    	},
    create_makefile_pl => 'passthrough',
);

$builder->create_build_script();


