package IsKernel::CandyAntivirus::Infrastructure::FileLogger;

use warnings;
use strict;
use v5.14;

use IsKernel::CandyAntivirus::Infrastructure::FileHelperBase;
use base qw(IsKernel::CandyAntivirus::Infrastructure::FileHelperBase);

=pod
Description:
	Creates a new instance of FileHandler
Parameters:
	path - the path to the file used by the logger
Returns
	A reference to the object
Type:
	Constructor
=cut
sub new
{
	(my $class, my $path) = @_;
	my $self = $class->SUPER::new($path);
	bless $self, $class;
	return $self; 
} 

=pod
Description:
	Appends the string to the logfile
Parameters:
	message - the message which will be appended
Returns
	None
Type:
	Public
=cut
sub appendString
{
	(my $self, my $message) = @_;
	open(my $handle, 
		 ">>",
		 $self->getPath(),
		) or die("Could not append message to file");
	print $handle $message;
	close($handle);
}
=pod
Description
	Returns the content of the file as an array
Parameters:
	None
Returns:
	An array containing each line of the content
Type:
	Public
=cut
sub getContentAsArray
{
	(my $self) = @_;
	open(my $handle, 
		 "<",
		 $self->getPath()
		) or die("Could not open file");
	my @lines = <$handle>;
	close($handle);
	return @lines;
}
=pod
Description
	Returns the content of the file as a string
Parameters:
	None
Returns:
	A string containing the entire content of the file
Type:
	Public
=cut
sub getContentAsString
{
	(my $self) = @_;
	my @lines = $self->getContentAsArray();
	my $result = join("",@lines);
	return $result;
}
#END OF MODULE
1;