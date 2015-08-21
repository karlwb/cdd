use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::StraightFlush';
use_ok 'CDD::Play::StraightFlush';
lives_ok { CDD::Play::StraightFlush->new('4d', '5d', '6d', '7D', '8d')} 'new lives';
dies_ok { CDD::Play::StraightFlush->new('4d', '5d', '6d', '8D', '8d')} 'new dies: 2 of same card';
dies_ok { CDD::Play::StraightFlush->new('4d', '5d', '6d', '7D', '8c')} 'new dies: different suit';
dies_ok { CDD::Play::StraightFlush->new('4d', '5d', '6d', '7D', '9d')} 'new dies: different rank';
dies_ok { CDD::Play::StraightFlush->new('4d', '5d', '6d', '7D', '8d', '9d')} 'new dies: too many';
dies_ok { CDD::Play::StraightFlush->new('ad')} 'new dies: too few';

my $low = CDD::Play::StraightFlush->new('4d', '5d', '6d', '7D', '8d');
is $low->size, 5, 'size right';
is $low->val, 99, 'val right';
is "$low", "[4D, 5D, 6D, 7D, 8D]", "string interpolation";
is $low->as_string, '[4D, 5D, 6D, 7D, 8D]', "as_string";
is $low->as_unicode,'[4♢, 5♢, 6♢, 7♢, 8♢]', "as_unicode";
is $low->sort->as_string, '[4D, 5D, 6D, 7D, 8D]', "sort";
is_deeply $low->cards, [CDD::Card->new('4D'), CDD::Card->new('5D'), CDD::Card->new('6D'), CDD::Card->new('7D'), CDD::Card->new('8D')], 'cards';

my $lower = CDD::Play::StraightFlush->new('3d', '4d', '5d', '6D', '7d');
my $lower2 = CDD::Play::StraightFlush->new('7d', '4d', '3d', '5d', '6d');
cmp_ok $lower, '<',  $low,  'lower < low';
cmp_ok $lower, '<=', $low,  'lower <= low';
cmp_ok $lower, '==', $lower2, 'lower == lower';
cmp_ok $low, '>=', $lower,  'low >= lower';
cmp_ok $low, '>',  $lower,  'low > lower';

cmp_ok $lower, 'lt', $low,  'lower lt low';
cmp_ok $lower, 'le', $low,  'lower le low';
cmp_ok $lower, 'eq', $lower2, 'lower eq lower2';
cmp_ok $low, 'ge', $lower,  'low ge lower';
cmp_ok $low, 'gt', $lower,  'low gt lower';

done_testing;

