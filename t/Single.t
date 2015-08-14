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
is $_4h->val, 7, 'val right';
is_deeply $_4h->highest, CDD::Card->new('4h'), 'highest';
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

