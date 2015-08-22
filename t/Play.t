use Modern::Perl;
use Test::More;
use Test::Exception;
use Data::Dump;

require_ok 'CDD::Play';
use_ok 'CDD::Play';

# id, size, val, type
subtest singles => sub {
    plan tests => 20;
    is CDD::Play->new('3d')->type, 'single', 'single';
    lives_ok { CDD::Play->new('ad')} 'new lives';
    my $_4h = CDD::Play->new('4h');
    is $_4h->size, 1, 'size right';
    is $_4h->val, 7, 'val right';
    is "$_4h", "[4H]", "string interpolation";
    is $_4h->as_string, '[4H]', "as_string";
    is $_4h->as_unicode,'[4♡]', "as_unicode";
    is $_4h->shuffle->as_string, '[4H]', "shuffle";
    is $_4h->sort->as_string, '[4H]', "sort";
    is_deeply $_4h->cards, [CDD::Card->new('4H')], 'cards';
    
    my $_ad = CDD::Play->new('ad');
    my $_ad2 = CDD::Play->new('ad');
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
};

subtest pairs => sub {
    plan tests => 22;
    is CDD::Play->new('3d', '3c')->type, 'pair', 'pair';
    lives_ok { CDD::Play->new('ad', 'ac')} 'new lives';
    dies_ok { CDD::Play->new('ad', 'ad')} 'new dies: same card';
    dies_ok { CDD::Play->new('ad', 'kd')} 'new dies: different rank';
    dies_ok { CDD::Play->new('ad', 'kd', 'jd')} 'new dies: too many';
    
    my $aces = CDD::Play->new('ad', 'ac');
    is $aces->size, 2, 'size right';
    is $aces->val, 34, 'val right';
    is "$aces", "[AD, AC]", "string interpolation";
    is $aces->as_string, '[AD, AC]', "as_string";
    is $aces->as_unicode,'[A♢, A♧]', "as_unicode";
    is $aces->sort->as_string, '[AD, AC]', "sort";
    is_deeply $aces->cards, [CDD::Card->new('AD'), CDD::Card->new('AC')], 'cards';
    
    my $kings = CDD::Play->new('ks', 'kh');
    my $kings2 = CDD::Play->new('kh', 'ks');
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
};

subtest triples => sub {
    plan tests => 22;
    is CDD::Play->new('3d', '3c', '3h')->type, 'triple', 'triple';
    lives_ok { CDD::Play->new('ad', 'ac', 'ah')} 'new lives';
    dies_ok { CDD::Play->new('ad', 'ad', 'ac')} 'new dies: 2 of same card';
    dies_ok { CDD::Play->new('ad', 'kd', 'ac')} 'new dies: different rank';
    dies_ok { CDD::Play->new('ad', 'kd', 'jd', '2d')} 'new dies: too many';
    
    my $aces = CDD::Play->new('ad', 'ac', 'ah');
    is $aces->size, 3, 'size right';
    is $aces->val, 12, 'val right';
    is "$aces", "[AD, AC, AH]", "string interpolation";
    is $aces->as_string, '[AD, AC, AH]', "as_string";
    is $aces->as_unicode,'[A♢, A♧, A♡]', "as_unicode";
    is $aces->sort->as_string, '[AD, AC, AH]', "sort";
    is_deeply $aces->cards, [CDD::Card->new('AD'), CDD::Card->new('AC'), CDD::Card->new('AH')], 'cards';
    
    my $kings = CDD::Play->new('ks', 'kh', 'kd');
    my $kings2 = CDD::Play->new('kh', 'ks', 'kd');
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

};

subtest straights => sub {
    plan tests => 22;
    is CDD::Play->new('3d', '4d', '5d', '6d', '7c')->type, 'straight', 'straight';
    lives_ok { CDD::Play->new('3d', '4c', '5c', '6h', '7d')} 'new lives';
    dies_ok { CDD::Play->new('3d', '4c', '5c', '6h', '6h')} 'new dies: 2 of same card';
    dies_ok { CDD::Play->new('3d', '4c', '5c', '6h', '8d')} 'new dies: different rank';
    dies_ok { CDD::Play->new('3d', '4c', '5c', '6h', '7d', '8c')} 'new dies: too many';

    my $low = CDD::Play->new('3d', '4c', '5c', '6h', '7c');
    is $low->size, 5, 'size right';
    is $low->val, 2, 'val right';
    is "$low", "[3D, 4C, 5C, 6H, 7C]", "string interpolation";
    is $low->as_string, '[3D, 4C, 5C, 6H, 7C]', "as_string";
    is $low->as_unicode,'[3♢, 4♧, 5♧, 6♡, 7♧]', "as_unicode";
    is $low->sort->as_string, '[3D, 4C, 5C, 6H, 7C]', "sort";
    is_deeply $low->cards, [CDD::Card->new('3D'), CDD::Card->new('4C'), CDD::Card->new('5C'), CDD::Card->new('6H'), CDD::Card->new('7C')], 'cards';

    my $lower = CDD::Play->new('3C', '4h', '5d', '6d', '7d');
    my $lower2 = CDD::Play->new('7d', '4h', '6d', '3c', '5d');
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

};

subtest flushes => sub {
    plan tests => 22;
    is CDD::Play->new('3d', '5d', '7d', '9d', 'jd')->type, 'flush', 'flush';
    lives_ok { CDD::Play->new('4d', '5d', '8d', 'JD', '3d')} 'new lives';
    dies_ok { CDD::Play->new('4d', '5d', '8d', 'JD', 'jd')} 'new dies: 2 of same card';
    dies_ok { CDD::Play->new('4d', '5d', '8d', 'JD', '3c')} 'new dies: different suit';
    dies_ok { CDD::Play->new('4d', '5d', '8d', 'JD', '3d', 'qd')} 'new dies: too many';

    my $low = CDD::Play->new('4d', '5d', '8d', 'JD', '3d');
    is $low->size, 5, 'size right';
    is $low->val, 40, 'val right';
    is "$low", "[3D, 4D, 5D, 8D, JD]", "string interpolation";
    is $low->as_string, '[3D, 4D, 5D, 8D, JD]', "as_string";
    is $low->as_unicode,'[3♢, 4♢, 5♢, 8♢, J♢]', "as_unicode";
    is $low->sort->as_string, '[3D, 4D, 5D, 8D, JD]', "sort";
    is_deeply $low->cards, [CDD::Card->new('3D'), CDD::Card->new('4D'), CDD::Card->new('5D'), CDD::Card->new('8D'), CDD::Card->new('JD')], 'cards';

    my $lower = CDD::Play->new('4d', '5d', '8d', '9D', '3d');
    my $lower2 = CDD::Play->new('8d', '4d', '9d', '5d', '3d');
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

};

subtest 'full houses' => sub {
    plan tests => 23;
    is CDD::Play->new('3d', '3c', '3h', '4d', '4c')->type, 'full house', 'full house';
    lives_ok { CDD::Play->new('3d', '3c', '3h', '4d', '4c')} 'new lives';
    dies_ok { CDD::Play->new('3d', '3c', '3h', '4d', '4d')} 'new dies: 2 of same card';
    dies_ok { CDD::Play->new('3d', '3c', '3h', '4d', '5c')} 'new dies: missing pair';
    dies_ok { CDD::Play->new('3d', '3c', '5h', '4d', '4c')} 'new dies: missing triple';
    dies_ok { CDD::Play->new('3d', '3c', '3h', '4d', '4c', '4h')} 'new dies: too many';

    my $low = CDD::Play->new('6d', '6c', '6h', '4d', '4c');
    is $low->size, 5, 'size right';
    is $low->val, 72, 'val right';
    is "$low", "[4D, 4C, 6D, 6C, 6H]", "string interpolation";
    is $low->as_string, '[4D, 4C, 6D, 6C, 6H]', "as_string";
    is $low->as_unicode,'[4♢, 4♧, 6♢, 6♧, 6♡]', "as_unicode";
    is $low->sort->as_string, '[4D, 4C, 6D, 6C, 6H]',  "sort";
    is_deeply $low->cards, [CDD::Card->new('4D'), CDD::Card->new('4C'), CDD::Card->new('6D'), CDD::Card->new('6C'), CDD::Card->new('6H')], 'cards';

    my $lower = CDD::Play->new('4d', '4c', '4h', '5d', '5c');
    my $lower2 = CDD::Play->new('5d', '4c', '4h', '5c', '4d');
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
};

subtest 'quad+1s' => sub {
    plan tests => 23;
    is CDD::Play->new('3d', '3c', '3h', '3s', '4d')->type, 'quad+1', 'quad+1';
    lives_ok { CDD::Play->new('3d', '3c', '3h', '3s', '4c')} 'new lives';
    dies_ok { CDD::Play->new('3d', '3c', '3h', '3h', '4d')} 'new dies: 2 of same card';
    dies_ok { CDD::Play->new('3d', '3c', '3h', '3s', '3s')} 'new dies: missing single';
    dies_ok { CDD::Play->new('3d', '3c', '3h', '4d', '5c')} 'new dies: missing quad';
    dies_ok { CDD::Play->new('3d', '3c', '3h', '3s', '4c', '4h')} 'new dies: too many';

    my $low = CDD::Play->new('6d', '6c', '6h', '6s', '4c');
    is $low->size, 5, 'size right';
    is $low->val, 85, 'val right';
    is "$low", "[4C, 6D, 6C, 6H, 6S]", "string interpolation";
    is $low->as_string, '[4C, 6D, 6C, 6H, 6S]', "as_string";
    is $low->as_unicode,'[4♧, 6♢, 6♧, 6♡, 6♤]', "as_unicode";
    is $low->sort->as_string, '[4C, 6D, 6C, 6H, 6S]',  "sort";
    is_deeply $low->cards, [CDD::Card->new('4C'), CDD::Card->new('6D'), CDD::Card->new('6C'), CDD::Card->new('6h'), CDD::Card->new('6s')], 'cards';

    my $lower = CDD::Play->new('4d', '4c', '4h', '4s', '5c');
    my $lower2 = CDD::Play->new('5c', '4c', '4h', '4s', '4d');
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

};

subtest 'straight flushes' => sub {
    plan tests => 21;
    is CDD::Play->new('3d', '4d', '5d', '6d', '7d')->type, 'straight flush', 'straight flush';
    lives_ok { CDD::Play->new('4d', '5d', '6d', '7D', '8d')} 'new lives';
    dies_ok { CDD::Play->new('4d', '5d', '6d', '8D', '8d')} 'new dies: 2 of same card';
    dies_ok { CDD::Play->new('4d', '5d', '6d', '7D', '8d', '9d')} 'new dies: too many';

    my $low = CDD::Play->new('4d', '5d', '6d', '7D', '8d');
    is $low->size, 5, 'size right';
    is $low->val, 99, 'val right';
    is "$low", "[4D, 5D, 6D, 7D, 8D]", "string interpolation";
    is $low->as_string, '[4D, 5D, 6D, 7D, 8D]', "as_string";
    is $low->as_unicode,'[4♢, 5♢, 6♢, 7♢, 8♢]', "as_unicode";
    is $low->sort->as_string, '[4D, 5D, 6D, 7D, 8D]', "sort";
    is_deeply $low->cards, [CDD::Card->new('4D'), CDD::Card->new('5D'), CDD::Card->new('6D'), CDD::Card->new('7D'), CDD::Card->new('8D')], 'cards';

    my $lower = CDD::Play->new('3d', '4d', '5d', '6D', '7d');
    my $lower2 = CDD::Play->new('7d', '4d', '3d', '5d', '6d');
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
};

done_testing;

