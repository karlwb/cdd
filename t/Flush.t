use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::Flush';
use_ok 'CDD::Play::Flush';
lives_ok { CDD::Play::Flush->new('4d', '5d', '8d', 'JD', '3d')} 'new lives';
dies_ok { CDD::Play::Flush->new('4d', '5d', '8d', 'JD', 'jd')} 'new dies: 2 of same card';
dies_ok { CDD::Play::Flush->new('4d', '5d', '8d', 'JD', '3c')} 'new dies: different suit';
dies_ok { CDD::Play::Flush->new('3d', '4d', '5d', '6d', '7d')} 'new dies: straight flush';
dies_ok { CDD::Play::Flush->new('4d', '5d', '8d', 'JD', '3d', 'qd')} 'new dies: too many';
dies_ok { CDD::Play::Flush->new('ad')} 'new dies: too few';

my $low = CDD::Play::Flush->new('4d', '5d', '8d', 'JD', '3d');
is $low->size, 5, 'size right';
is $low->val, -1, 'val right';
is_deeply $low->highest, CDD::Card->new('JD'), 'highest';
is "$low", "[JD, 8D, 5D, 4D, 3D]", "string interpolation";
is $low->as_string, '[JD, 8D, 5D, 4D, 3D]', "as_string";
is $low->as_unicode,'[J♢, 8♢, 5♢, 4♢, 3♢]', "as_unicode";
is $low->sort->as_string, '[3D, 4D, 5D, 8D, JD]', "sort";
is_deeply $low->cards, [CDD::Card->new('3D'), CDD::Card->new('4D'), CDD::Card->new('5D'), CDD::Card->new('8D'), CDD::Card->new('JD')], 'cards';

my $lower = CDD::Play::Flush->new('4d', '5d', '8d', '9D', '3d');
my $lower2 = CDD::Play::Flush->new('8d', '4d', '9d', '5d', '3d');
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

