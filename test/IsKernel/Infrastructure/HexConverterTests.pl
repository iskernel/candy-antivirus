#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use Test::More;

use IsKernel::Infrastructure::HexConverter;

sub ascii_to_hex_dump_normal_conversion_result_is_correct()
{
	my $hex_converter = IsKernel::Infrastructure::HexConverter->new();
	my $result = $hex_converter->ascii_to_hex_dump("text");
	ok($result = "74657874", "HexConverter_AsciiToHexDump_NormalConversion_ResultIsCorect");
}

sub hex_dump_to_ascii_normal_conversion_result_is_correct()
{
	my $hex_converter = IsKernel::Infrastructure::HexConverter->new();
	my $result = $hex_converter->hex_dump_to_ascii("74657874");
	ok($result eq "text", "HexConverter_AsciiToHexDump_NormalConversion_NoErrorIsTriggered");
}

ascii_to_hex_dump_normal_conversion_result_is_correct();
hex_dump_to_ascii_normal_conversion_result_is_correct();
done_testing();