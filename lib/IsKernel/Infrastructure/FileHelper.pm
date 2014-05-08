package IsKernel::Infrastructure::FileHelper;

use warnings;
use strict;
use v5.14;

use IsKernel::Infrastructure::StringHelper;

=pod
Description:
	Creates a new instance of FileHelperBase
Parameters:
	path - the path to the file used by the logger
	content - the content of the file
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


=pod
Description:
	Appends the string to the file
Parameters:
	message - the message which will be appended
Returns
	None
Type:
	Public
=cut
sub append_to_file
{
	(my $self, my $message) = @_;
	open(my $handle, 
		 ">>",
		 $self->get_path(),
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
sub get_content_as_array
{
	(my $self) = @_;
	open(my $handle, 
		 "<",
		 $self->get_path()
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
sub get_content_as_string
{
	(my $self) = @_;
	my @lines = $self->get_content_as_array();
	my $result = join("",@lines);
	return $result;
}

=pod
Description:
	Creates a file at the specified path with the specified content
Parameters:
	path - the path to the file
	content - the content of the file as a scalar
Returns:
	Nothing 
Type:
	Public
=cut
sub write_to_file
{
	(my $self, my $message) = @_;
	open(my $handle, ">", $self->get_path()) or die("Could not create file at ".$self->get_path());
	print $handle $message;
	close($handle);
}

=pod
Description
	Deletes a file
Parameters:
	None
Returns:
	Nothing
Type:
	Public
=cut
sub delete_file()
{
	(my $self) = @_;
	unlink $self->get_path();
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
Type:
	Public
=cut
sub is_ordinary_file()
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
	Generates a unique filename in regards to the files in a specific directory
Parameters:
	random filename generator - a object which has the generate method and returns a string
	directory - the path to the directory
Returns:
	An unique filename for the specified directory
=cut
sub create_random_filename()
{
	my $self = shift;
	my $generator = shift;
	my $path = shift;
	
	#Generates a valid (which doesn't already exist) random filename for the hexdump.
	my $filename_guard = 1;
	my $filename = undef;
	my $new_path = undef;
	while($filename_guard==1)
	{
		$filename = $generator->generate();
		$new_path = catfile($path, $filename);
		if(!-e $new_path)
		{
			$filename_guard = 0;
		}
	}
	
	return $filename;
}

#END OF MODULE
1;