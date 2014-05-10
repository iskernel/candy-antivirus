package IsKernel::CandyAntivirus::ScanResponse;

use warnings;
use strict;
use v5.14;

=pod
Description:
	Creates a new object
Parameters
	has_virus - signifies that a file has a virus
	virus_name - the name of the virus, if the file contains a virus
Returns
	A reference to the object
=cut
sub new
{
	(my $class, my $has_virus, my $virus_name) = @_;
	my $self = {};
	$self->{"HasVirus"} = $has_virus;
	$self->{"VirusName"} = $virus_name;
	bless $self, $class;	
	return $self;
}

=pod
Description:
	Returns the scan status for a file
Parameters
	None
Returns
	1 - the file has a virus
	0 - the file does not have a virus
=cut
sub has_virus()
{
	my $self = shift;
	return $self->{"HasVirus"};
}

=pod
Description:
	Returns the name of the viruses, if any
Parameters
	None
Returns
	The name of the virus
=cut
sub virus_name()
{
	my $self = shift;
	return $self->{"VirusName"};
}

1;