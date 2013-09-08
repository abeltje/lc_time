#! perl -w
use strict;
use utf8;
use Encode;

use Test::More;

use POSIX ();

my %test = (
    en_US => {
        lang    => 'English',
        lc_time => 'en_US',
        expect  => 'March Mar',
    },
    nl_NL => {
        lang    => 'Dutch',
        lc_time => 'nl_NL',
        expect  => 'maart mrt',
    },
    de_DE => {
        lang    => 'German',
        lc_time => 'de_DE',
        expect  => 'März Mär',
    },
    ru_RU => {
        lang    => 'Russian',
        lc_time => 'ru_RU',
        expect  => 'марта мар',
    },
    uk_UA => {
        lang => 'Ukraenian',
        lc_time => 'uk_UA',
        expect => 'березень бер',
    },
);

chomp(my @locale_avail = qx/locale -a/);

binmode(STDOUT, ':encoding(utf8)');
my $first_lc_time = POSIX::setlocale(POSIX::LC_TIME());
note("Default LC_TIME: $first_lc_time");

for my $lc (keys %test) {
    SKIP: {
        my ($first_lc) = grep /^$test{$lc}{lc_time}/, @locale_avail;
        if (!$first_lc) {
            skip("No locale for $test{$lc}{lang} ($test{$lc}{lc_time})", 1);
        }

        note("Testing with $lc == $first_lc");
        my $prog = << "        EOP";
use warnings;
use strict;
use lc_time '$first_lc';
strftime('%B %b', 0, 0, 0, 1, 2, 2013);
        EOP
        my $t = eval $prog;
        is($t, $test{$lc}{expect}, encode('utf-8', "$test{$lc}{lang}: $t"));
    }
}

my $curr_lc_time = POSIX::setlocale(POSIX::LC_TIME());
is($curr_lc_time, $first_lc_time, "LC_TIME reverted to $curr_lc_time");

done_testing();
