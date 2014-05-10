package IsKernel::CandyAntivirus::VirusScanner;

use strict;
use warnings;
use v5.14;

use IsKernel::Infrastructure::HexConverter;
use IsKernel::Infrastructure::FileHelper;
use IsKernel::CandyAntivirus::ScanResponse;

=pod
Description:
	Creates a new instance of VirusScanner
Parameters:
	path - the path to the file used by the logger
Returns
	A reference to the object
=cut
sub new
{
	(my $class, my $path) = @_;
	my $self = {};
	$self->{"path"} = $path;
	$self->{"hexConverter"} = IsKernel::Infrastructure::HexConverter->new();
	bless $self, $class;
	return $self; 
} 

=pod
Description:
	Returns the hex converter object
Parameters:
	None
Returns
	The hex converter object
=cut
sub _get_hex_converter()
{
	my $self = shift;
	return $self->{"hexConverter"};
}

=pod
Description:
	Scans a content string and returns a scan response 
	(if the file is infected, and the name of the first detected virus).
Parameters:
	path - the content string
Returns
	A scan response object
=cut
sub scan
{
	(my $self, my $content) = @_;
	$content = $self->_get_hex_converter()->ascii_to_hex_dump($content);
	
	my $result = 0;
	my $index = 0;
	open(my $database_handle, 
		 "<",
		 $self->{"path"}
		) or die("Could not open Virus Signature file");
	my $virus_name = undef;
	my $virus_signature = undef;
	while(my $line=<$database_handle>)
	{
		#Parses the name and the virus signature from the line
		($virus_name, $virus_signature) = split("=",$line);
		#Checks if a virus is found
		chomp($virus_signature);
		if($content =~ m/\Q$virus_signature\E\s*/)
		{
			$result = 1;
			last;	#Breaks the loop
		}
	}
	my $response = IsKernel::CandyAntivirus::ScanResponse->new($result, $virus_name);
	return $response;
}

=pod
Description:
	Analyzes a string and removes all virus signatures
Parameters:
	content - the content string
Returns
	Returns the content without any virus signatures 
Type:
	Public
=cut
sub remove_signatures
{
	(my $self, my $content) = @_;
	$content = $self->_get_hex_converter()->ascii_to_hex_dump($content);	
	#Opens the virus signatures database
	open(my $database_handle, 
		 "<",
		 $self->{"path"}
		) or die("Could not open Virus Signature file");
	while(my $line=<$database_handle>)
	{
		#Parses the name and the virus signature from the line
		(my $virus_name, my $virus_signature) = split("=",$line);
		#Checks if a virus is found
		chomp($virus_signature);
		if($content =~ m/\Q$virus_signature\E\s*/)
		{
			$content =~ s/\Q$virus_signature//g;
		}
	}
	$content = $self->_get_hex_converter()->hex_dump_to_ascii($content);
	return $content;
}

#End of module
1;