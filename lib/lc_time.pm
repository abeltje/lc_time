package lc_time;
use v5.10.1;
use warnings;
use strict;

our $VERSION = 0.1;

require Encode;

use parent 'Exporter';
use POSIX qw/ setlocale LC_TIME /;

our @EXPORT_OK = qw/ strftime /;

=head1 NAME

lc_time - Lexical pragma for strftime.

=head1 SYNOPSIS

    {
        use lc_time 'nl_NL';
        printf "Today in nl: %s\n", strftime("%d %b %Y");
    }

=head1 DESCRIPTION

=cut

sub import {
    my $self = shift;
    my ($locale) = @_;

    my ($pkg) = caller(0);
    __PACKAGE__->export_to_level(1, $pkg, @EXPORT_OK);

    $^H{LC_TIME} = $locale;
}

sub unimport {
    $^H{LC_TIME} = undef;
}

sub strftime {
    my ($pattern, @arguments) = @_;
    my $ctrl_h = (caller 0)[10];

    my $lctime_was;
    if ($ctrl_h->{LC_TIME} ) {
        $lctime_was = setlocale(LC_TIME);
        my $ret = setlocale(LC_TIME, $ctrl_h->{LC_TIME}) // '<undef>';
    }

    my $strftime = POSIX::strftime($pattern, @arguments);

    setlocale(LC_TIME, $lctime_was) if $lctime_was;
    return Encode::decode('utf8', $strftime);
}

1;
