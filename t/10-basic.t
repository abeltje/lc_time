#! perl -w
use strict;
use utf8;
use Encode;

use Test::More;

binmode(STDOUT, ':utf8');
use POSIX ();
my $first_lc_time = POSIX::setlocale(POSIX::LC_TIME());
note("Default LC_TIME: $first_lc_time");
{
    use lc_time 'en_US';
    my $t = strftime('%B %b', 0, 0, 0, 1, 2, 2013);
    is($t, 'March Mar', encode('utf-8', "English: $t"));
}

{
    use lc_time 'nl_NL';
    my $t = strftime('%B %b', 0, 0, 0, 1, 2, 2013);
    is($t, 'maart mrt', encode('utf-8', "Dutch: $t"));
}

{
    use lc_time 'ru_RU';
    my $t = strftime('%B %b', 0, 0, 0, 1, 2, 2013);
    is($t, 'марта мар', encode('utf-8', "Russian: $t"));
}

{
    use lc_time 'de_DE';
    my $t = strftime('%B %b', 0, 0, 0, 1, 2, 2013);
    is($t, 'März Mär', encode('utf-8', "German: $t"));
}

my $curr_lc_time = POSIX::setlocale(POSIX::LC_TIME());
is($curr_lc_time, $first_lc_time, "LC_TIME reverted to $curr_lc_time");

done_testing();
