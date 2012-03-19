#!perl
use strict;
use warnings;
use inc::Module::Install 0.91;

name 'Git-PurePerl';
version_from 'lib/Git/PurePerl.pm';
author(
    'Leon Brocard <acme@astray.com>',
    'Tokuhiro Matsuno <tokuhirom+cpan@gmail.com>',
    'Fayland <fayland@gmail.com>',
    'Chris Reinhardt <chris@triv.org>',
    'Tomas Doran <bobtfish@bobtfish.net>',
    'Jesse Luehrs <doy@cpan.org>',
    'Alex Vandiver <cpan@chmrr.net>',
    'Dagfinn Ilmari Mannsåker <ilmari+cpan@ilmari.org>',
    'Dan Brook <mr.daniel.brook@gmail.com>',
    'Christian Walde <walde.christian@googlemail.com>',
);
abstract 'A Pure Perl interface to Git repositories';
license 'perl';

resources(
    repository => 'git://github.com/GitPurePerl/git-pureperl.git',
    homepage => 'https://github.com/GitPurePerl/git-pureperl',
    bugtracker => 'https://github.com/GitPurePerl/git-pureperl/issues'
);

requires        'Archive::Extract'           => '0';
requires        'Compress::Raw::Zlib'        => '0';
requires        'Compress::Zlib'             => '0';
requires        'Config::GitLike'            => '0';
requires        'Data::Stream::Bulk'         => '0';
requires        'DateTime'                   => '0';
requires        'File::Find::Rule'           => '0';
requires        'IO::Digest'                 => '0';
requires        'Moose'                      => '0';
requires        'MooseX::StrictConstructor'  => '0';
requires        'MooseX::Types::Path::Class' => '0';
requires 'namespace::autoclean';

test_requires   'Test::More'                 => '0.88';
test_requires   'Test::utf8'                 => '0.02';

WriteAll;
