use Modern::Perl;
use Test::More;
use Test::Exception;

use constant CARD => sub { CDD::Card->new(@_) };

require_ok('CDD::Card');
use_ok('CDD::Card');
dies_ok {CARD->()} 'new no args dies';
dies_ok {CARD->(rank=>'A')} 'new full rank only dies';
dies_ok {CARD->(rank=>'A', suit=>'S')} 'new full rank suit only dies';
dies_ok {CARD->(rank=>11, suit=>'S', val=>1)} 'new full bad rank';
dies_ok {CARD->(rank=>10, suit=>'G', val=>1)} 'new full bad suit';
dies_ok {CARD->(rank=>10, suit=>'C', val=>0)} 'new full bad val 1';
dies_ok {CARD->(rank=>10, suit=>'C', val=>53)} 'new full bad val 2';
lives_ok {CARD->(rank=>'A', suit=>'S', val=>2)} 'new full lives';
lives_ok {CARD->('3D')} 'new short lives';

my $ace = CARD->('as');
is $ace->rank, 'A', 'get rank ace';
is $ace->suit, 'S', 'get suit spades';
is $ace->val, 48, 'get val';
is "$ace", "AS", 'string context';
is $ace->as_string, 'AS', 'as_string';
is $ace->as_unicode, 'A♤', 'as_unicode';
dies_ok {$ace->rank(4)} 'set rank dies';
dies_ok {$ace->suit('C')} 'set suit dies';
dies_ok {$ace->val(2)} 'set val dies';

my $six = CARD->('6H');
my $six2 = CARD->('6h');

cmp_ok $six, '<', $ace, '6H < AS';
cmp_ok $six, '<=', $six2, '6H <= 6h';
cmp_ok $six, '==', $six2, '6H == 6h';
cmp_ok $ace, '>=', $six, 'AS >= 6H';
cmp_ok $ace, '>', $six, 'AS > 6H';

cmp_ok $six, 'lt', $ace, '6H lt AS';
cmp_ok $six, 'le', $six2, '6H le 6h';
cmp_ok $six, 'eq', $six2, '6H eq 6h';
cmp_ok $ace, 'ge', $six, 'AS ge 6H';
cmp_ok $ace, 'gt', $six, 'AS gt 6H';



done_testing;
