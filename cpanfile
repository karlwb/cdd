requires 'Modern::Perl';
requires 'Moo';
requires 'MooX::Singleton';
requires 'List::MoreUtils';
requires 'Data::Dump';
requires 'Mojolicious';
requires 'DBD::SQLite';
requires 'Mojo::SQLite';

on 'test' => sub {
   requires 'Test::More';
   requires 'Test::Exception';
};

