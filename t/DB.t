use Modern::Perl;
use Test::More;
use Test::Exception;
use Data::Dump;

if ( not $ENV{TEST_AUTHOR} ) {
   plan skip_all => 'Author test. Set TEST_AUTHOR to test';
}

require_ok('CDD::DB');
use_ok('CDD::DB');
{
    no warnings 'once';
    $CDD::DB::Populator::VERBOSE = $ENV{VERBOSE} // 1; # 0 say nothing, 1 just overview, 2 data
}

my $file = 'test.db';
unlink $file if -e $file;

is -e $file, undef, "no $file";
diag "generating $file...";
my $obj = CDD::DB->new(file=>$file);
is -e $file, 1, "$file created";
is ref($obj), 'CDD::DB', 'isa CDD::DB';
is $obj->generated, 1, 'generated is true';
is $obj->sql->db->query('select count(*) as n from suit')->hash->{n}, 4, 'got 4 suits';
is $obj->sql->db->query('select count(*) as n from card')->hash->{n}, 52, 'got 52 cards';
is $obj->sql->db->query('select count(*) as n from grp')->hash->{n}, 18878, 'got 18878 groups/plays';
is $obj->sql->db->query('select count(*) as n from grpavail')->hash->{n}, 18878, 'got 18878 available groups/plays';
is $obj->sql->db->query('select count(*) as n from grpcard')->hash->{n}, 93844, 'got 93844 cards in available groups/plays';
is $obj->sql->db->query('select count(*) as n from grptype')->hash->{n}, 8, 'got 8 group/play types';

my $expect = [
    {n => 52,   name => "single"},
    {n => 78,   name => "pair"},
    {n => 52,   name => "triple"},
    {n => 9180, name => "straight"},
    {n => 5112, name => "flush"},
    {n => 3744, name => "full house"},
    {n => 624,  name => "quad+1"},
    {n => 36,   name => "straight flush"},
];
is_deeply $obj->sql->db->query(q~
  select grptype.name,
         count(*) as n
  from grp
  join grptype on grptype.id = grp.grptype_id
  group by name
  order by grp.numcards, grp.value
~)->hashes, $expect,
    "got expected plays per single, pair, triple, straight, flush, full house, quad, straight flush";

$obj = CDD::DB->new(file=>$file); # use existing db
is $obj->generated, '', 'generated is false';
is $obj->sql->db->query('select count(*) as n from suit')->hash->{n}, 4, 'existing db works';

#unlink $file if -e $file;
done_testing;
