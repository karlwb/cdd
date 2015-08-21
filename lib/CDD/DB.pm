package CDD::DB;
use Modern::Perl;
use Mojo::SQLite;
use Carp qw/confess/;
use CDD::DB::Populator;

use constant DB_FILENAME => "cdd.db";  # default

use Moo;
with 'MooX::Singleton';

has file => (is => 'ro');
has sql => (is => 'ro',
            builder => \&_build_sql,
           );
has generated => (is => 'rwp', 
                  default => sub{ '' }
                 );

sub BUILDARGS {
    my ($class, @args) = @_;
    if (@args == 0 ) {
        return { file => DB_FILENAME };
    }
    elsif ( @args == 1 ) {
        if ( ref $args[0] eq 'HASH' ) {
            return $args[0];
        }
        return { file => shift @args };
    }
    return { @args };
}

sub _build_sql {
    my $self = shift;
    state $sqlite = Mojo::SQLite->new->from_filename($self->file);
    my %expect = ( card => 52,
                   grp  => 18878,
                   grpavail => 18878,
                   grpcard => 93844,
                   grptype => 8,
                   suit => 4,);
    my $generate = 0;
    foreach my $table (keys %{expect}) {
        my $count = eval{$sqlite->db->query("select count(*) as count from $table")->hash->{count}};
        if ($@ or $count != $expect{$table}) {
            $generate = 1;
            last;
        }
    }
    if ($generate) {
        CDD::DB::Populator->new(sql=>$sqlite)->generate;
        $self->_set_generated(1);
    }
    say $sqlite if $ENV{VERBOSE};
    return $sqlite;
}

1;
