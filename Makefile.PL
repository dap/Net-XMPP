use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'      => 'Net::XMPP',
    'VERSION_FROM' => 'lib/Net/XMPP.pm',
    'PREREQ_PM' => {
        'XML::Stream' => 1.22,
        'Digest::SHA1' => 1.02,
    },
    'dist' => {
        'COMPRESS' => 'gzip --best'
    }
);

