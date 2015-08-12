use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::Triple';
use_ok 'CDD::Play::Triple';
lives_ok { CDD::Play::Triple->new('ad', 'ac', 'ah')} 'new lives';
dies_ok { CDD::Play::Triple->new('ad', 'ad', 'ac')} 'new dies: 2 of same card';
dies_ok { CDD::Play::Triple->new('ad', 'kd', 'ac')} 'new dies: different rank';
dies_ok { CDD::Play::Triple->new('ad', 'kd', 'jd', '2d')} 'new dies: too many';
dies_ok { CDD::Play::Triple->new('ad')} 'new dies: too few';

my $aces = CDD::Play::Triple->new('ad', 'ac', 'ah');
is $aces->size, 3, 'size right';
is $aces->val, -1, 'val right';
is_deeply $aces->highest, CDD::Card->new('ah'), 'highest';
diag "TODO: Fix triple val";
is "$aces", "[AH, AC, AD]", "string interpolation";
is $aces->as_string, '[AH, AC, AD]', "as_string";
is $aces->as_unicode,'[A♡, A♧, A♢]', "as_unicode";
is $aces->sort->as_string, '[AD, AC, AH]', "sort";
is_deeply $aces->cards, [CDD::Card->new('AD'), CDD::Card->new('AC'), CDD::Card->new('AH')], 'cards';

my $kings = CDD::Play::Triple->new('ks', 'kh', 'kd');
my $kings2 = CDD::Play::Triple->new('kh', 'ks', 'kd');
cmp_ok $kings, '<',  $aces,  'kings < aces';
cmp_ok $kings, '<=', $aces,  'kings <= aces';
cmp_ok $kings, '==', $kings2, 'kings == kings';
cmp_ok $aces, '>=', $kings,  'aces >= kings';
cmp_ok $aces, '>',  $kings,  'aces > kings';

cmp_ok $kings, 'lt', $aces,  'kings lt aces';
cmp_ok $kings, 'le', $aces,  'kings le aces';
cmp_ok $kings, 'eq', $kings2, 'kings eq kings2';
cmp_ok $aces, 'ge', $kings,  'aces ge kings';
cmp_ok $aces, 'gt', $kings,  'aces gt kings';


done_testing;

