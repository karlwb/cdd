use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::Quad';
use_ok 'CDD::Play::Quad';
lives_ok { CDD::Play::Quad->new('ad', 'ac', 'ah', 'as')} 'new lives';
dies_ok { CDD::Play::Quad->new('ad', 'ad', 'ac', 'ah')} 'new dies: 2 of same card';
dies_ok { CDD::Play::Quad->new('ad', 'kd', 'ac', 'as')} 'new dies: different rank';
dies_ok { CDD::Play::Quad->new('ad', 'kd', 'jd', '2d', 'ah')} 'new dies: too many';
dies_ok { CDD::Play::Quad->new('ad')} 'new dies: too few';

my $aces = CDD::Play::Quad->new('ad', 'ac', 'ah', 'as');
is $aces->size, 4, 'size right';
is $aces->val, 12, 'val right';
is_deeply $aces->highest, CDD::Card->new('as'), 'highest';
is "$aces", "[AS, AH, AC, AD]", "string interpolation";
is $aces->as_string, '[AS, AH, AC, AD]', "as_string";
is $aces->as_unicode,'[A♤, A♡, A♧, A♢]', "as_unicode";
is $aces->sort->as_string, '[AD, AC, AH, AS]', "sort";
is_deeply $aces->cards, [CDD::Card->new('AD'), CDD::Card->new('AC'), CDD::Card->new('AH'), CDD::Card->new('AS')], 'cards';

my $kings = CDD::Play::Quad->new('ks', 'kh', 'kd', 'kc');
my $kings2 = CDD::Play::Quad->new('kh', 'ks', 'kd', 'kc');
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

