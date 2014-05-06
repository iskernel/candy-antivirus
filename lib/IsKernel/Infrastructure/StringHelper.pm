package IsKernel::Infrastructure::StringHelper;

use warnings;
use strict;
use v5.14;

=pod
Description:
	Creates a new RandomStringGenerator object
Parameters:
	length - the default length used if otherwise unspecified
Returns:
	A reference to the object
Type:
	Public
=cut
sub new
{
	(my $class, my $length) = @_;
	my $self->{"length"} = $length;
	bless $self, $class;
	return $self;
}
=pod
Description:
	Generates a random string of characters
Parameters:
	length - the length of the string
Returns:
	the random string
Type:
	Public
=cut
sub generate_random
{
	(my $self, my $length) = @_;
	$length = $self->{"length"} unless defined $length;
	my @chars=('a'..'z','A'..'Z','0'..'9','_');
	my $string;
	foreach (1..$length) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$string.=$chars[rand @chars];
	}
	return $string;
}

#END OF MODULE
1;