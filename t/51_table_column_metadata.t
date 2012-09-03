#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use t::lib::Test qw/connect_ok @CALL_FUNCS/;
use Test::More;
use Test::NoWarnings;

plan tests => 11 * @CALL_FUNCS + 1;
for my $call_func (@CALL_FUNCS) {
	my $dbh = connect_ok();
	$dbh->do('create table foo (id integer primary key autoincrement, "name space", unique_col integer unique)');

	{
		my $data = $dbh->$call_func(undef, 'foo', 'id', 'table_column_metadata');
		ok $data && ref $data eq ref {}, "got a metadata";
		ok $data->{auto_increment}, "id is auto incremental";
		is $data->{data_type} => 'integer', "data type is correct";
		ok $data->{primary}, "id is a primary key";
		ok !$data->{not_null}, "id is not null";
	}

	{
		my $data = $dbh->$call_func(undef, 'foo', 'name space', 'table_column_metadata');
		ok $data && ref $data eq ref {}, "got a metadata";
		ok !$data->{auto_increment}, "name space is not auto incremental";
		is $data->{data_type} => undef, "data type is not defined";
		ok !$data->{primary}, "name space is not a primary key";
		ok !$data->{not_null}, "name space is not null";
	}
}