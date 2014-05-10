package IsKernel::Infrastructure::FileUtilities;

use warnings;
use strict;
use v5.14;

use File::Spec::Functions;
use IsKernel::Infrastructure::StringHelper;

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
Description:
	Verifies if a file is modifiable
Parameters:
	path - the path to the file
Returns:
	-1 - Error
	1 - the file is ordinary, writable and readable
	0 - the file is ordinary, but is not writable or not readable
	2 - the file is not ordinary
=cut
sub is_ordinary_file
{
	(my $self, my $path) = @_;
	my $result = -1;
	if( (-f $path) )
	{
		if( (-w $path) && (-r $path) )
		{
			$result = 1;
		}
		else
		{
			$result = 0;
		}
	}
	else
	{
		$result = 2;
	}
	return $result;
}

=pod
Description:
	Generates a unique filename in regards to the files in the specified directory
Parameters:
	length - the length of the new filename
	directory_path - the path to the directory
Returns:
	An unique filename for the specified directory
=cut
sub create_random_filename
{
	my $self = shift;
	my $length = shift;
	my $directory_path = shift;
	
	my $generator = IsKernel::Infrastructure::StringHelper->new($length);
	
	my $filename_guard = 1;
	my $filename = undef;
	my $new_path = undef;
	while($filename_guard==1)
	{
		$filename = $generator->generate_random($length);
		$new_path = catfile($directory_path, $filename);
		if(!-e $new_path)
		{
			$filename_guard = 0;
		}
	}
	
	return $new_path;
}

1;