use Modern::Perl;
use Test::More;

require_ok('CDD::Deck');
use_ok('CDD::Deck');
my $d = CDD::Deck->new;
is join('', map{$_->rank} @{$d->cards}), 
    join('', map{$_ x 4} qw/3 4 5 6 7 8 9 10 J Q K A 2/), 
    'ranks set ok';
is join('', map{$_->suit} @{$d->cards}),
    join('', 'DCHS' x 13),
    'suits set ok';
is join('', map{$_->val} @{$d->cards}), 
    join('', 1..52), 
    'vals set ok';

my $str1 = $d->as_string;
is $str1, '3D, 3C, 3H, 3S, 4D, 4C, 4H, 4S, 5D, 5C, 5H, 5S, 6D, 6C, 6H, 6S, 7D, 7C, 7H, 7S, 8D, 8C, 8H, 8S, 9D, 9C, 9H, 9S, 10D, 10C, 10H, 10S, JD, JC, JH, JS, QD, QC, QH, QS, KD, KC, KH, KS, AD, AC, AH, AS, 2D, 2C, 2H, 2S', 'as_string';

my $str2 = $d->shuffle->as_string;
my $str3 = $d->shuffle->as_string;
isnt $str1, $str2, 'shuffle 1';
isnt $str2, $str3, 'shuffle 2';

done_testing;
