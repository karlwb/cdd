use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::Pair';
use_ok 'CDD::Play::Pair';
lives_ok { CDD::Play::Pair->new('ad', 'ac')} 'new lives';
dies_ok { CDD::Play::Pair->new('ad', 'ad')} 'new dies: same card';
dies_ok { CDD::Play::Pair->new('ad', 'kd')} 'new dies: different rank';
dies_ok { CDD::Play::Pair->new('ad', 'kd', 'jd')} 'new dies: too many';
dies_ok { CDD::Play::Pair->new('ad')} 'new dies: too few';

my $aces = CDD::Play::Pair->new('ad', 'ac');
is $aces->size, 2, 'size right';
is $aces->val, 34, 'val right';
is_deeply $aces->highest, CDD::Card->new('ac'), 'highest';
is "$aces", "[AD, AC]", "string interpolation";
is $aces->as_string, '[AD, AC]', "as_string";
is $aces->as_unicode,'[A♢, A♧]', "as_unicode";
is $aces->sort->as_string, '[AD, AC]', "sort";
is_deeply $aces->cards, [CDD::Card->new('AD'), CDD::Card->new('AC')], 'cards';

my $kings = CDD::Play::Pair->new('ks', 'kh');
my $kings2 = CDD::Play::Pair->new('kh', 'ks');
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

