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
is $aces->val, -1, 'val right';
is_deeply $aces->highest, CDD::Card->new('ac'), 'highest';
diag "TODO: Fix pair val";
is "$aces", "[AC, AD]", "string interpolation";
is $aces->as_string, '[AC, AD]', "as_string";
is $aces->as_unicode,'[A♧, A♢]', "as_unicode";
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
__END__

my $g = TestGroup->new;
is_deeply $g->cards, [], "empty group";

$g = TestGroup->new('6d', '3d', '5c', '7d', '4h',);
is "$g", '[6D, 3D, 5C, 7D, 4H]', 'group as strings';
is $g->sort->as_string, '[3D, 4H, 5C, 6D, 7D]', 'sort';
is $g->sort_by('rank', 'desc')->as_string, '[7D, 6D, 5C, 4H, 3D]', 'sort_by rank desc';
is $g->sort_by('rank', 'asc')->as_string, '[3D, 4H, 5C, 6D, 7D]', 'sort_by rank asc';
is $g->sort_by('suit', 'desc')->as_string, '[4H, 5C, 7D, 6D, 3D]', 'sort_by suit desc';
is $g->sort_by('suit', 'asc')->as_string, '[3D, 6D, 7D, 5C, 4H]', 'sort_by suit asc';
is $g->sort_by('val', 'desc')->as_string, '[7D, 6D, 5C, 4H, 3D]', 'sort_by val desc';
is $g->sort_by('val', 'asc')->as_string, '[3D, 4H, 5C, 6D, 7D]', 'sort_by val asc';
my $str = $g->as_string;
is "$g", $str, "overloaded string";
my $x = any { $g->shuffle->as_string ne $str } (1..5); #hopefully 
is $x, 1, 'shuffle';

done_testing;

