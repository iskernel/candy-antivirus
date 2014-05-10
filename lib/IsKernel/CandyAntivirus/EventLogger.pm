package IsKernel::CandyAntivirus::EventLogger;

use warnings;
use strict;
use v5.14;

use IsKernel::Infrastructure::FileHelper;
use base qw(IsKernel::Infrastructure::FileHelper);

=pod
Description:
	Creates a new object
Parameters:
	path - the path to the log file
Returns:
	A references to the new object
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
	Writes to the log the beginning of a new session
Parameters:
	None
Returns:
	None
=cut
sub init_session
{
	my $self = shift;
	$self->append_to_file("===Session started at ".localtime."===\n")
}

=pod
Description:
	Writes to the log the beginning of a new session
Parameters:
	None
Returns:
	None
=cut
sub close_session
{
	my $self = shift;
	$self->append_to_file("===Session started at ".localtime."===\n")
}

1;