use Modern::Perl;
use lib 'lib';
use CDD::DB;

my $file = 'cdd.db';
if ( -e $file ) {
    say "Removing $file";
    unlink $file;
    die "Unable to remove $file" if -e $file;
}

{ 
    $CDD::DB::Populator::VERBOSE=1;
#    no warnings 'once';
}
my $obj = CDD::DB->instance;

say "\n\nCreated database $file: (" . $obj->sql->dsn . ")";

