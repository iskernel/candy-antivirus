package IsKernel::CandyAntivirus::Infrastructure::FileManager;

use warnings;
use strict;
use v5.14;

use IsKernel::CandyAntivirus::Infrastructure::FileHelperBase;
use base qw(IsKernel::CandyAntivirus::Infrastructure::FileHelperBase);

=pod
Description:
	Creates a new FileManager object
Parameters:
	path - the path to the file
	content - the content of the file
Returns:
	A reference to the object
Type:
	Constructor
=cut
sub new
{
	(my $class, my $path, my $content) = @_;
	my $self = $class->SUPER::new($path);
	if(defined $content)
	{
		$self->{"content"} = $content;
	}
	else
	{
		$self->{"content"} = "";
	}
	bless $self, $class;
	return $self;
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
sub createFile
{
	(my $self) = @_;
	open(my $handle, ">", $self->getPath()) or die("Could not create file at ".$self->getPath());
	print $handle $self->{"content"};
	close($handle);
}
=pod
Description:
	Loads the content from the path
Parameters:
	None
Returns:
	Nothing 
Type:
	Public
=cut
sub loadContentFromPath
{
	(my $self) = @_;
	$self->{"content"} = $self->getContentAsString();
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
=pod
Description
	Replaces the content of a file
Parameters:
	content - the new content of the file
Returns:
	None
Type:
	Public
=cut
sub replaceContent
{
	(my $self, my $content) = @_;
	$self->{"content"} = $content;
	open(my $handle, 
		 ">",
		 $self->getPath()
		) or die("Could not open file");
	print $handle $content;
	close($handle);
}

#END OF MODULE
1;