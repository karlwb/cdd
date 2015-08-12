use Modern::Perl;
use Test::More;
use Test::Exception;
use CDD::Card;
use List::MoreUtils qw/any all/;
use Data::Dump;
require_ok 'CDD::Play::Single';
use_ok 'CDD::Play::Single';
lives_ok { CDD::Play::Single->new('ad')} 'new lives';
dies_ok { CDD::Play::Single->new('ad', 'ac')} 'new dies';
my $_4h = CDD::Play::Single->new('4h');
is $_4h->size, 1, 'size right';
is $_4h->val, -1, 'val right';
is_deeply $_4h->highest, CDD::Card->new('4h'), 'highest';
diag "TODO: Fix single val";
is "$_4h", "[4H]", "string interpolation";
is $_4h->as_string, '[4H]', "as_string";
is $_4h->as_unicode,'[4♡]', "as_unicode";
is $_4h->shuffle->as_string, '[4H]', "shuffle";
is $_4h->sort->as_string, '[4H]', "sort";
is_deeply $_4h->cards, [CDD::Card->new('4H')], 'cards';

my $_ad = CDD::Play::Single->new('ad');
my $_ad2 = CDD::Play::Single->new('ad');
cmp_ok $_4h, '<',  $_ad,  '4h < ad';
cmp_ok $_4h, '<=', $_ad,  '4h < ad';
cmp_ok $_ad, '==', $_ad2, 'ad == ad';
cmp_ok $_ad, '>=', $_4h,  'ad >= 4h';
cmp_ok $_ad, '>',  $_4h,  'ad > 4h';

cmp_ok $_4h, 'lt', $_ad,  '4h lt ad';
cmp_ok $_4h, 'le', $_ad,  '4h le ad';
cmp_ok $_ad, 'eq', $_ad2, 'ad eq ad';
cmp_ok $_ad, 'ge', $_4h,  'ad ge 4h';
cmp_ok $_ad, 'gt', $_4h,  'ad gt 4h';


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

