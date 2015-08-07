use Modern::Perl;
use Test::More;
use Test::Exception;

require_ok('CDD::Card');
use_ok('CDD::Card');
dies_ok {CDD::Card->new()} 'new no args dies';
dies_ok {CDD::Card->new(rank=>'A')} 'new rank only dies';
dies_ok {CDD::Card->new(rank=>'A', suit=>'S')} 'new rank suit only dies';
dies_ok {CDD::Card->new(rank=>11, suit=>'S', val=>1)} 'new bad rank';
dies_ok {CDD::Card->new(rank=>10, suit=>'G', val=>1)} 'new bad suit';
dies_ok {CDD::Card->new(rank=>10, suit=>'C', val=>0)} 'new bad val';

lives_ok {CDD::Card->new(rank=>'A', suit=>'S', val=>2)} 'new lives';
my $c = CDD::Card->new(rank=>'A', suit=>'S', val=>2);
is $c->rank, 'A', 'get rank';
is $c->suit, 'S', 'get suit';
is $c->val, 2, 'get val';
is "$c", "AS", 'stringify';
dies_ok {$c->rank(4)} 'set rank dies';
dies_ok {$c->suit('C')} 'set suit dies';
dies_ok {$c->val(2)} 'set val dies';

done_testing;
