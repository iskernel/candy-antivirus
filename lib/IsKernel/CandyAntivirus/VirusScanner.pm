package IsKernel::CandyAntivirus::VirusScanner;

use strict;
use warnings;
use v5.14;

use IsKernel::Infrastructure::HexConverter;
use IsKernel::Infrastructure::FileHelper;

=pod
Description:
	Creates a new instance of VirusScanner
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
	my $self = {};
	$self->{"path"} = $path;
	$self->{"hexConverter"} = IsKernel::Infrastructure::HexConverter->new();
	bless $self, $class;
	return $self; 
} 


sub _get_hex_converter()
{
	my $self = shift;
	return $self->{"hexConverter"};
}

=pod
Description:
	Analyzes a string and returns a list of the viruses
	and viruses signatures found.
Parameters:
	path - the path to the file
Returns
	Returns 1 if hex contains a virus signature.
	Otherwise returns 0.
Type:
	Public
=cut
sub analyze_content
{
	(my $self, my $content) = @_;
	$content = $self->_get_hex_converter()->ascii_to_hex_dump($content);
	
	#Initializes the return array
	my $result = 0;
	#Initializes the index of the return array
	my $index = 0;
	#Opens the virus signatures database
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
	return ($result, $virus_name);
}

=pod
Description:
	Analyzes a string and removes all virus signatures
Parameters:
	path - the path to the file
Returns
	Returns 1 if hex contains a virus signature.
	Otherwise returns 0.
Type:
	Public
=cut
sub disinfect_content
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