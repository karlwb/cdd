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

my $uni  = $d->as_unicode;
is $uni, '[3♢, 3♧, 3♡, 3♤, 4♢, 4♧, 4♡, 4♤, 5♢, 5♧, 5♡, 5♤, 6♢, 6♧, 6♡, 6♤, 7♢, 7♧, 7♡, 7♤, 8♢, 8♧, 8♡, 8♤, 9♢, 9♧, 9♡, 9♤, 10♢, 10♧, 10♡, 10♤, J♢, J♧, J♡, J♤, Q♢, Q♧, Q♡, Q♤, K♢, K♧, K♡, K♤, A♢, A♧, A♡, A♤, 2♢, 2♧, 2♡, 2♤]', 'string as_unicode';

my $str1 = $d->as_string;
is $str1, '[3D, 3C, 3H, 3S, 4D, 4C, 4H, 4S, 5D, 5C, 5H, 5S, 6D, 6C, 6H, 6S, 7D, 7C, 7H, 7S, 8D, 8C, 8H, 8S, 9D, 9C, 9H, 9S, 10D, 10C, 10H, 10S, JD, JC, JH, JS, QD, QC, QH, QS, KD, KC, KH, KS, AD, AC, AH, AS, 2D, 2C, 2H, 2S]', 'as_string';


is "$d", $str1, "string overload";
my $str2 = $d->shuffle->as_string;
my $str3 = $d->shuffle->as_string;
isnt $str1, $str2, 'shuffle 1';
isnt $str2, $str3, 'shuffle 2';
is $d->sort->as_string, $str1, "sort";

is $d->sort_by('rank', 'asc')->as_string, 
    '[3D, 3C, 3H, 3S, 4D, 4C, 4H, 4S, 5D, 5C, 5H, 5S, 6D, 6C, 6H, 6S, 7D, 7C, 7H, 7S, 8D, 8C, 8H, 8S, 9D, 9C, 9H, 9S, 10D, 10C, 10H, 10S, JD, JC, JH, JS, QD, QC, QH, QS, KD, KC, KH, KS, AD, AC, AH, AS, 2D, 2C, 2H, 2S]',
    'sort by rank asc';
is $d->sort_by('rank', 'desc')->as_string, 
    '[2S, 2H, 2C, 2D, AS, AH, AC, AD, KS, KH, KC, KD, QS, QH, QC, QD, JS, JH, JC, JD, 10S, 10H, 10C, 10D, 9S, 9H, 9C, 9D, 8S, 8H, 8C, 8D, 7S, 7H, 7C, 7D, 6S, 6H, 6C, 6D, 5S, 5H, 5C, 5D, 4S, 4H, 4C, 4D, 3S, 3H, 3C, 3D]',
    'sort by rank desc';
is $d->sort_by('suit', 'asc')->as_string, 
    '[3D, 4D, 5D, 6D, 7D, 8D, 9D, 10D, JD, QD, KD, AD, 2D, 3C, 4C, 5C, 6C, 7C, 8C, 9C, 10C, JC, QC, KC, AC, 2C, 3H, 4H, 5H, 6H, 7H, 8H, 9H, 10H, JH, QH, KH, AH, 2H, 3S, 4S, 5S, 6S, 7S, 8S, 9S, 10S, JS, QS, KS, AS, 2S]',
    'sort by suit asc';
is $d->sort_by('suit', 'desc')->as_string, 
    '[2S, AS, KS, QS, JS, 10S, 9S, 8S, 7S, 6S, 5S, 4S, 3S, 2H, AH, KH, QH, JH, 10H, 9H, 8H, 7H, 6H, 5H, 4H, 3H, 2C, AC, KC, QC, JC, 10C, 9C, 8C, 7C, 6C, 5C, 4C, 3C, 2D, AD, KD, QD, JD, 10D, 9D, 8D, 7D, 6D, 5D, 4D, 3D]',
    'sort by rank desc';
is $d->sort_by('val', 'asc')->as_string, 
    '[3D, 3C, 3H, 3S, 4D, 4C, 4H, 4S, 5D, 5C, 5H, 5S, 6D, 6C, 6H, 6S, 7D, 7C, 7H, 7S, 8D, 8C, 8H, 8S, 9D, 9C, 9H, 9S, 10D, 10C, 10H, 10S, JD, JC, JH, JS, QD, QC, QH, QS, KD, KC, KH, KS, AD, AC, AH, AS, 2D, 2C, 2H, 2S]',
    'sort by val asc';
is $d->sort_by('val', 'desc')->as_string, 
    '[2S, 2H, 2C, 2D, AS, AH, AC, AD, KS, KH, KC, KD, QS, QH, QC, QD, JS, JH, JC, JD, 10S, 10H, 10C, 10D, 9S, 9H, 9C, 9D, 8S, 8H, 8C, 8D, 7S, 7H, 7C, 7D, 6S, 6H, 6C, 6D, 5S, 5H, 5C, 5D, 4S, 4H, 4C, 4D, 3S, 3H, 3C, 3D]',
    'sort by val desc';


done_testing;
