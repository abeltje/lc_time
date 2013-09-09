package lc_time;
use v5.10.1;
use warnings;
use strict;

our $VERSION = 0.1;

require Encode;

use parent 'Exporter';
use POSIX qw/ setlocale LC_TIME LC_CTYPE LC_ALL /;
use constant MY_LC_TIME => $^O eq 'MSWin32' ? LC_ALL : LC_TIME;

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
    if (my $lctime = $ctrl_h->{pragma_LC_TIME} ) {
        $lctime_was = setlocale(MY_LC_TIME);
        $lctime_is = setlocale(MY_LC_TIME, $lctime)
            or die "Cannot set LC_TIME to '$lctime'\n";
    }

    my $strftime = POSIX::strftime($pattern, @arguments);

    if ($lctime_was) {
        setlocale(MY_LC_TIME, $lctime_was);
    }

    my $encoding = get_locale_encoding($lctime_is);
    return $encoding ? Encode::decode($encoding, $strftime) : $strftime;
}

sub get_locale_encoding {
    my $lc_time = shift;
    eval 'require I18N::Langinfo;';
    my $has_i18n_langinfo = !$@;

    if (!$lc_time) {
        return $has_i18n_langinfo
            ? I18N::Langinfo::langinfo(I18N::Langinfo::CODESET())
            : '';
    }

    my $encoding;
    if ($has_i18n_langinfo) {
        my $tmp = setlocale(LC_CTYPE);
        setlocale(LC_CTYPE, $lc_time);
        $encoding = I18N::Langinfo::langinfo(I18N::Langinfo::CODESET());
        setlocale(LC_CTYPE, $tmp);
    }

    return $encoding || guess_locale_encoding($lc_time);
}

sub guess_locale_encoding {
    my $lc_time = shift;

    (my $encoding = $lc_time) =~ s/.+?(?:\.|$)//;
    if ($encoding =~ /^[0-9]+$/) { # Windows cp...
        $encoding = "cp$encoding";
    }
    if (!$encoding && $^O eq 'darwin') {
        $encoding = 'UTF-8';
    }
    return $encoding;
}

1;
