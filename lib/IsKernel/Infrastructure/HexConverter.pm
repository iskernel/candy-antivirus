package IsKernel::Infrastructure::HexConverter;

use warnings;
use strict;
use v5.14;

=pod
Description:
	Creates a new object
Parameters:
	None
Returns:
	A reference to the object
=cut
sub new
{
	(my $class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

=pod
Description
	Converts an array of string to a hexdump
Parameters:
	content - An ASCII string
Returns:
	A string containing the hexdump
=cut
sub ascii_to_hex_dump
{
	(my $self, my $content) = @_;
	my @result;
	my $index = 0;
	my @chars = split("", $content);
	foreach my $char(@chars)
	{
		#Gets the ASCII code of the character
		my $ascii_code = ord($char);
		#Gets the hexadecimal code of the character
		my $hex_code  = sprintf("%x",$ascii_code);
		#Adds 0 in front of single digit numbers
		my $length = length($hex_code);
		if($length==1)
		{
			$hex_code = "0".$hex_code;
		}
		#Adds the number to the string
		$result[$index] = $hex_code;
		$index++;
	}
	my $string = join("",@result);
	return $string;
}
=pod
Description
	Converts a hexdump to a string
Parameters:
	hexdump - the content of the hexdump
Returns:
	An array containing the ASCII string
=cut
sub hex_dump_to_ascii
{
	(my $self, my $hex_dump) = @_;
	my @chars = split("", $hex_dump);
	my $length = @chars;
	my $result;
	for(my $i = 0; $i< ($length - 1); $i+=2)
	{
		my $high_nibble = hex($chars[$i]);
		my $low_nibble  = hex($chars[($i+1)]);
		my $byte = ($high_nibble * 16) + $low_nibble;
		my $char = chr($byte);
		$result = $result.$char;
	}
	return $result;
}

#End module
1;