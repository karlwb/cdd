use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::Straight';
use_ok 'CDD::Play::Straight';
lives_ok { CDD::Play::Straight->new('3d', '4c', '5c', '6h', '7d')} 'new lives';
dies_ok { CDD::Play::Straight->new('3d', '4c', '5c', '6h', '6h')} 'new dies: 2 of same card';
dies_ok { CDD::Play::Straight->new('3d', '4c', '5c', '6h', '8d')} 'new dies: different rank';
dies_ok { CDD::Play::Straight->new('3d', '4c', '5c', '6h', '7d', '8c')} 'new dies: too many';
dies_ok { CDD::Play::Straight->new('ad')} 'new dies: too few';

my $low = CDD::Play::Straight->new('3d', '4c', '5c', '6h', '7c');
is $low->size, 5, 'size right';
is $low->val, -1, 'val right';
is_deeply $low->highest, CDD::Card->new('7c'), 'highest';
is "$low", "[7C, 6H, 5C, 4C, 3D]", "string interpolation";
is $low->as_string, '[7C, 6H, 5C, 4C, 3D]', "as_string";
is $low->as_unicode,'[7♧, 6♡, 5♧, 4♧, 3♢]', "as_unicode";
is $low->sort->as_string, '[3D, 4C, 5C, 6H, 7C]', "sort";
is_deeply $low->cards, [CDD::Card->new('3D'), CDD::Card->new('4C'), CDD::Card->new('5C'), CDD::Card->new('6H'), CDD::Card->new('7C')], 'cards';

my $lower = CDD::Play::Straight->new('3C', '4h', '5d', '6d', '7d');
my $lower2 = CDD::Play::Straight->new('7d', '4h', '6d', '3c', '5d');
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

