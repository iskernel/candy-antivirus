package IsKernel::CandyAntivirus::Infrastructure::FileHelperBase;

use warnings;
use strict;
use v5.14;

=pod
Description:
	Creates a new instance of FileHelperBase
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
	my $self->{"path"} = $path;
	bless $self, $class;
	return $self; 
}

=pod
Description:
	Returns the path used by the file handler
Parameters:
	None
Returns
	The path used by the file handler
Type:
	Public
=cut
sub set_path
{
	(my $self, my $new_path) = @_;
	$self->{"path"} = $new_path;
}

=pod
Description:
	Sets the path used by the file handler
Parameters:
	path - the new path that will be used by the file handler
Returns
	None
Type:
	Public
=cut
sub get_path
{
	my $self = shift;
	my $temp = $self->{"path"};
	return $temp;
}
#END_OF_MODULE
1;