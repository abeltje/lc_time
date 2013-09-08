package lc_time;
use v5.10.1;
use warnings;
use strict;

our $VERSION = 0.1;

require Encode;

use parent 'Exporter';
use POSIX qw/ setlocale LC_TIME LC_CTYPE /;
use I18N::Langinfo qw/ langinfo CODESET /;

our @EXPORT = qw/ strftime /;

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
    __PACKAGE__->export_to_level(1, $pkg, @EXPORT);

    $^H{pragma_LC_TIME} = $locale;
}

sub unimport {
    $^H{pragma_LC_TIME} = undef;
}

sub strftime {
    my ($pattern, @arguments) = @_;
    my $ctrl_h = (caller 0)[10];

    my ($lctime_is, $lctime_was);
    if ($ctrl_h->{pragma_LC_TIME} ) {
        $lctime_was = setlocale(LC_TIME);
        $lctime_is = setlocale(LC_TIME, $ctrl_h->{pragma_LC_TIME})
            or die "Cannot set LC_TIME to '$ctrl_h->{pragma_LC_TIME}'\n";
    }

    my $strftime = POSIX::strftime($pattern, @arguments);

    if ($lctime_was) {
        setlocale(LC_TIME, $lctime_was);
    }
    return Encode::decode(get_locale_encoding($lctime_is), $strftime);
}

sub get_locale_encoding {
    my $lc_time = shift;
    return langinfo(CODESET) if !$lc_time;

    my $tmp = setlocale(LC_CTYPE);
    setlocale(LC_CTYPE, $lc_time);
    my $encoding = langinfo(CODESET);
    setlocale(LC_CTYPE, $tmp);
    return $encoding;
}

1;
