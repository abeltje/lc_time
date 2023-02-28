#! perl -w
use v5.10.1;
use strict;

use ExtUtils::MakeMaker;

die "OS unsupported" if $^O eq 'openbsd';

WriteMakefile(
    ABSTRACT_FROM => 'lib/lc_time.pm',
    NAME          => 'lc_time',
    VERSION_FROM  => 'lib/lc_time.pm',
    LICENSE       => 'perl_5',

    PREREQ_PM => {
        'Encode' => 0,
        'POSIX'  => 0,
        'parent' => 0,
    },

    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.56,
    },

    BUILD_REQUIRES => {
        'Test::More'     => '0.88',
        'Test::Warnings' => '0',
        'Test::Fatal'    => '0',
    },

    MIN_PERL_VERSION => 5.010001,
    META_ADD => {
        'meta-spec' => {
            version => 2,
        },
        'resources' => {
            repository => {
                type => 'git',
                url  => 'git@github.com:abeltje/lc_time.git',
                web  => 'https://github.com/abeltje/lc_time',
            },
        },
        bugtracker => {
            web => 'https://github.com/abeltje/lc_time/issues',
        },
    },
);
