package IsKernel::CandyAntivirus::VirusScanner;

use strict;
use warnings;
use v5.14;

use IsKernel::CandyAntivirus::Infrastructure::HexConverter;
use IsKernel::CandyAntivirus::Infrastructure::FileHelperBase;
use base qw(IsKernel::CandyAntivirus::Infrastructure::FileHelperBase);

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
	my $self = $class->SUPER::new($path);
	bless $self, $class;
	return $self; 
} 
=pod
Description:
	Analyzes a Hexdump and returns a list of the viruses
	and viruses signatures found.
Parameters:
	path - the path to the file
Returns
	Returns 1 if hex contains a virus signature.
	Otherwise returns 0.
Type:
	Public
=cut
sub analyzeHexDump
{
	(my $self, my $content) = @_;
	#Initializes the return array
	my $result = 0;
	#Initializes the index of the return array
	my $index = 0;
	#Opens the virus signatures database
	open(my $databaseHandle, 
		 "<",
		 $self->getPath()
		) or die("Could not open Virus Signature file");
	my $virusName = undef;
	my $virusSignature = undef;
	while(my $line=<$databaseHandle>)
	{
		#Parses the name and the virus signature from the line
		($virusName, $virusSignature) = split("=",$line);
		#Checks if a virus is found
		chomp($virusSignature);
		if($content =~ m/\Q$virusSignature\E/)
		{
			$result = 1;
			last;	#Breaks the loop
		}
	}
	return ($result, $virusName);
}

=pod
Description:
	Analyzes a Hexdump and removes all virus signatures
Parameters:
	path - the path to the file
Returns
	Returns 1 if hex contains a virus signature.
	Otherwise returns 0.
Type:
	Public
=cut
sub disinfectHexDump
{
	(my $self, my $content) = @_;
	#Opens the virus signatures database
	open(my $databaseHandle, 
		 "<",
		 $self->getPath()
		) or die("Could not open Virus Signature file");
	while(my $line=<$databaseHandle>)
	{
		#Parses the name and the virus signature from the line
		(my $virusName, my $virusSignature) = split("=",$line);
		#Checks if a virus is found
		chomp($virusSignature);
		if($content =~ m/\Q$virusSignature\E/)
		{
			$content =~ s/\Q$virusSignature//g;
		}
	}
	return $content;
}

#End of module
1;