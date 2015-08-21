use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::FullHouse';
use_ok 'CDD::Play::FullHouse';
lives_ok { CDD::Play::FullHouse->new('3d', '3c', '3h', '4d', '4c')} 'new lives';
dies_ok { CDD::Play::FullHouse->new('3d', '3c', '3h', '4d', '4d')} 'new dies: 2 of same card';
dies_ok { CDD::Play::FullHouse->new('3d', '3c', '3h', '4d', '5c')} 'new dies: missing pair';
dies_ok { CDD::Play::FullHouse->new('3d', '3c', '5h', '4d', '4c')} 'new dies: missing triple';
dies_ok { CDD::Play::FullHouse->new('3d', '3c', '3h', '4d', '4c', '4h')} 'new dies: too many';
dies_ok { CDD::Play::FullHouse->new('ad')} 'new dies: too few';

my $low = CDD::Play::FullHouse->new('6d', '6c', '6h', '4d', '4c');
is $low->size, 5, 'size right';
is $low->val, 72, 'val right';
is "$low", "[4D, 4C, 6D, 6C, 6H]", "string interpolation";
is $low->as_string, '[4D, 4C, 6D, 6C, 6H]', "as_string";
is $low->as_unicode,'[4♢, 4♧, 6♢, 6♧, 6♡]', "as_unicode";
is $low->sort->as_string, '[4D, 4C, 6D, 6C, 6H]',  "sort";
is_deeply $low->cards, [CDD::Card->new('4D'), CDD::Card->new('4C'), CDD::Card->new('6D'), CDD::Card->new('6C'), CDD::Card->new('6H')], 'cards';

my $lower = CDD::Play::FullHouse->new('4d', '4c', '4h', '5d', '5c');
my $lower2 = CDD::Play::FullHouse->new('5d', '4c', '4h', '5c', '4d');
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

