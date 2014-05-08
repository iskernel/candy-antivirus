package IsKernel::Infrastructure::HexConverter;

use warnings;
use strict;
use v5.14;

=pod
Description:
	Creates a new HexConverter object
Parameters:
	None
Returns:
	A reference to the object
Type:
	Constructor
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
Type:
	Public
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
		my $asciiCode = ord($char);
		#Gets the hexadecimal code of the character
		my $hexaCode  = sprintf("%x",$asciiCode);
		#Adds 0 in front of single digit numbers
		my $length = length($hexaCode);
		if($length==1)
		{
			$hexaCode = "0".$hexaCode;
		}
		#Adds the number to the string
		$result[$index] = $hexaCode;
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
Type:
	Public
=cut
sub hex_dump_to_ascii
{
	(my $self, my $hexDump) = @_;
	my @chars = split("", $hexDump);
	my $length = @chars;
	my $result;
	for(my $i = 0; $i< ($length - 1); $i+=2)
	{
		my $highNibble = hex($chars[$i]);
		my $lowNibble  = hex($chars[($i+1)]);
		my $byte = ($highNibble * 16) + $lowNibble;
		my $char = chr($byte);
		$result = $result.$char;
	}
	return $result;
}

#End module
1;