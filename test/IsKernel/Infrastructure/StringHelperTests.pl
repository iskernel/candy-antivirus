#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use Test::More;

use IsKernel::Infrastructure::StringHelper;

sub generate_x_characters_string_is_generated
{
	my $string_helper = IsKernel::Infrastructure::StringHelper->new();
	my $random_string = $string_helper->generate_random(50);
	my $string_length = length($random_string);
	ok($string_length == 50, "StringHelper_GenerateRandom_GivenInput_LengthIsCorrect");
}

generate_x_characters_string_is_generated();
done_testing();