package IsKernel::CandyAntivirus::Engine;

use warnings;
use strict;
use v5.14;

use File::Find;
use File::Basename;
use File::Spec::Functions;
use LWP::Simple;

use IsKernel::CandyAntivirus::Infrastructure::RandomStringGenerator;
use IsKernel::CandyAntivirus::Infrastructure::FileLogger;
use IsKernel::CandyAntivirus::Infrastructure::HexConverter;
use IsKernel::CandyAntivirus::Infrastructure::FileManager;
use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::VirusScanner;

#The length of a random filename used by a quarantined file
use constant RANDOM_FILENAME_LENGTH => 30;
use constant ALL_EXTENSIONS => "all";

=pod
Description:
	Generates a new Antivirus Engine object
Parameters:
	configuration - an Configuration object
	directory - the working directory
Returns:
	A reference to the new object
Type:
	Constructor
=cut
sub new
{
	(my $class, my $configuration, my $directory) = @_;
	my $self = {};
	$self->{"Configuration"} = $configuration;
	$self->{"HexDumper"} =  IsKernel::CandyAntivirus::Infrastructure::HexConverter->new();
	$self->{"Scanner"} = IsKernel::CandyAntivirus::VirusScanner->new($configuration->getVirusDatabasePath());
	$self->{"EventLogger"} = IsKernel::CandyAntivirus::Infrastructure::FileLogger->new($configuration->getPathToLog());
	$self->{"QuarantineLogger"} = IsKernel::CandyAntivirus::Infrastructure::FileLogger->new($configuration->getPathToQuarantineLog());
	$self->{"RandomFilenameGenerator"} = IsKernel::CandyAntivirus::Infrastructure::RandomStringGenerator->new(RANDOM_FILENAME_LENGTH);
	#If no directory is specified, than the default directory from configuration will be used
	if( (defined $directory) && (-d $directory) )
	{
		$self->{"Directory"} = $directory;
	}
	else
	{
		$self->{"Directory"} = $configuration->getDefaultWorkingDirectory();
	}
	bless $self, $class;
	return $self;
}
=pod
Description:
	Changes the configuration object
Parameters:
	configuration - the new configuration object
Returns:
	None
Type:
	Private
=cut
sub setConfiguration_
{
	my $self = shift;
	$self->{"Configuration"} = shift;
}
=pod
Description:
	Changes the working directory
Parameters:
	path - the path to the new working directory
Returns:
	None
Type:
	Private
=cut
sub setWorkingDirectory
{
	my $self = shift;
	$self->{"Directory"} = shift;
}
=pod
Description:
	Returns the Configuration object used by the Engine
Parameters:
	None
Returns:
	The configuration object used by the engine
Type:
	Private
=cut
sub getConfiguration
{
	my $self = shift;
	return $self->{"Configuration"};
}
=pod
Description:
	Returns the working directory used by the Engine
Parameters:
	None
Returns:
	The working directory used by the engine
Type:
	Private
=cut
sub getWorkingDirectory
{
	my $self = shift;
	return $self->{"Directory"};
}
=pod
Description:
	Returns the hex dumper used by the Engine
Parameters:
	None
Returns:
	The hex dumper used by the engine
Type:
	Private
=cut
sub getHexDumper
{
	my $self = shift;
	return $self->{"HexDumper"};
}
=pod
Description:
	Returns the virus scanner used by the Engine
Parameters:
	None
Returns:
	The virus scanner used by the engine
Type:
	Private
=cut
sub getScanner
{
	my $self = shift;
	return $self->{"Scanner"};
}
=pod
Description:
	Returns the event logger used by the Engine
Parameters:
	None
Returns:
	The event logger used by the engine
Type:
	Private
=cut
sub getEventLogger
{
	my $self = shift;
	return $self->{"EventLogger"};
}
=pod
Description:
	Returns the quarantine logger used by the Engine
Parameters:
	None
Returns:
	The quarantine logger used by the engine
Type:
	Private
=cut
sub getQuarantineLogger()
{
	my $self = shift;
	return $self->{"QuarantineLogger"};
}
=pod
Description:
	Returns the random filename generator used by the Engine
Parameters:
	None
Returns:
	The random filename generator used by the engine
Type:
	Private
=cut
sub getRandomFilenameGenerator()
{
	my $self = shift;
	return $self->{"RandomFilenameGenerator"};
}
=pod
Description:
	Verifies if a file is scannable
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
sub verifyFile
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
	Verifies if a file has a virus.
Parameters:
	fileManager - a FileManager object containing the path to the scanned file
Returns:
	(hasVirus, virusName)
	hasVirus = 1 => The file has a virus
	hasVirus = 0 => The file has no virus
	virusName - the name of the virus, if any
Type:
	Public
=cut
sub hasVirus
{
	(my $self, my $fileManager) = @_;
	my $content = $fileManager->getContentAsString();
	my $hexDump = $self->getHexDumper()->convertAsciiToHexDump($content);
	(my $hasVirus, my $virusName) = $self->getScanner()->analyzeHexDump($hexDump);
	return ($hasVirus, $virusName);
}
=pod
Description:
	Deletes a file
Parameters:
	fileManager - a FileManager object containing the path to the scanned file
Returns:
	(retVal, printResponse)
	retVal = 1 => The file was deleted successfully
	retVal = 0 => The file was not deleted
	printResponse - a message detailing the result of the operation
Type:
	Public
=cut
sub deleteAction
{
	(my $self, my $fileManager) = @_;
	my $result = unlink($fileManager->getPath());
	
	my $nowTime = localtime;
	
	my $printResponse = undef;
	my $logResponse = undef;
	my $retVal = undef;
	#The file was deleted successfully
	if($result)
	{
		$printResponse = $fileManager->getPath()." "."was deleted from system\n";
		$logResponse = $nowTime." ".$printResponse;
		$retVal = 1;
	}
	#The file was not deleted successfully
	else
	{
		$printResponse = $fileManager->getPath()." "."was NOT deleted from system\n";
		$logResponse = $nowTime." ".$printResponse;
		$retVal = 0;
	}
	#Writes to log file
	$self->getEventLogger()->appendString($logResponse);
	return ($retVal, $printResponse);
}
=pod
Description:
	Quarantines a file
Parameters:
	fileManager - a FileManager object containing the path to the scanned file
Returns:
	(retVal, printResponse)
	retVal = 1 => The file was quarantined successfully
	retVal = 0 => The file was not quarantined
	printResponse - a message detailing the result of the operation
Type:
	Public
=cut
sub quarantineAction
{
	(my $self, my $fileManager) = @_;
	#Puts in memory the content of the original file
	my $fileContent = $fileManager->getContentAsString();
	
	#Deletes the original file
	my $result = unlink($fileManager->getPath());
	
	my $nowTime = localtime;
	my $oldPath = $fileManager->getPath();
	print $oldPath;
	
	my $logResponse = undef;
	my $printResponse = undef;
	my $retVal = 0;
	
	if($result)
	{
		#Dumps file to hex
		my $fileHexDump = $self->getHexDumper()->convertAsciiToHexDump($fileContent);
		my $filenameGuard = 1;
		my $filename = undef;
		my $newPath = undef;
		#Generates a valid (which doesn't already exist) random filename for the hexdump.
		while($filenameGuard==1)
		{
			$filename = $self->getRandomFilenameGenerator()->generate();
			$newPath = catfile($self->getConfiguration->getQuarantinePath(), $filename);
			if(!-e $newPath)
			{
				$filenameGuard = 0;
			}
		}
		#Creates the hexdump
		my $hexFileManager = Com::IsKernel::Libs::FileHandling::FileManager->new($newPath, $fileHexDump);
		#Creates the file
		$hexFileManager->createFile();
		#Adds definition to the quarantine logger in case the user wants to restore the file
		$self->getQuarantineLogger->appendString($oldPath."=".$newPath."\n");
		$printResponse = $oldPath." was quarantined from system\n";
		$logResponse = $nowTime." ".$printResponse;
		$retVal = 1;
	}
	else
	{
		$printResponse = $oldPath." was NOT quarantined successfully\n";
		$logResponse = $nowTime." ".$printResponse;
		
	}
	#Writes event to event logger
	$self->getEventLogger()->appendString($logResponse);
	
	return ($retVal, $printResponse);
}
=pod
Description:
	Disinfects a file
Parameters:
	fileManager - a FileManager object containing the path to the scanned file
Returns:
	(retVal, printResponse)
	retVal = 1 => The file was disinfected successfully
	retVal = 0 => The file was not disinfected
	printResponse - a message detailing the result of the operation
Type:
	Public
=cut
sub disinfectAction
{
	(my $self, my $fileManager) = @_;
	my $fileContent = $fileManager->getContentAsString();
	#Dumps the content of the file to hex
	my $fileHexDump = $self->getHexDumper()->convertAsciiToHexDump($fileContent);
	#Removes all virus signatures
	$fileHexDump = $self->getScanner()->disinfectHexDump($fileHexDump);
	#Converts the newly created hex to ASCII
	$fileContent = $self->getHexDumper()->convertHexDumpToAscii($fileHexDump);
	#Replaces the content in the original file
	$fileManager->replaceContent($fileContent);
	
	my $nowTime = localtime;
	my $printResponse = $fileManager->getPath()." "."was disinfected successfully\n";
	my $logResponse = $nowTime." ".$printResponse;
	$self->getEventLogger()->appendString($logResponse);
	
	return (1,$printResponse);	
}
=pod
Description:
	Returns the content of the log file
Parameters:
	None
Returns:
	The content of the log file
Type:
	Public
=cut
sub getLogFileContents
{
	my $self = shift;
	return $self->getEventLogger()->getContentAsString();
}
=pod
Description:
	Downloads new virus definitions from the internetz and saves them
	to the virus database file
Parameters:
	None
Returns:
	None
Type:
	Public
=cut
sub downloadNewDefinitions
{
	my $self = shift;
	my $content = get($self->getConfiguration()->getPathToWwwDatabase()) 
				  or die("Could not get content from online database");
	my $fileManager = Com::IsKernel::Libs::FileHandling::FileManager->new($self->getConfiguration()->getVirusDatabasePath());
	$fileManager->replaceContent($content);
}
=pod
Description:
	Returns a list of the file who were quarantined (their original paths)
Parameters:
	None
Returns:
	a list of the file who were quarantined
Type:
	Public
=cut
sub getQuarantinedFiles
{
	my $self = shift;
	my $fileManager = Com::IsKernel::Libs::FileHandling::FileManager->new($self->getConfiguration()->getPathToQuarantineLog());
	my @lines = $fileManager->getContentAsArray();
	my @files;
	my $index = 0;
	foreach my $line (@lines)
	{
		(my $oldPath, my $newPath) = split("=",$line);
		chomp($oldPath);
		$files[$index] = $oldPath;
		$index++;
	}
	return @files;
}
=pod
Description:
	Restores a quarantined file
Parameters:
	The old location of the file
Returns:
	none
Type:
	Public
=cut
sub restoreQuarantinedFile
{
	my $self = shift;
	my $path = shift;
	my $quarantineManager = Com::IsKernel::Libs::FileHandling::FileManager->new(
										   $self->getConfiguration()->getPathToQuarantineLog());
	my @lines = $quarantineManager->getContentAsArray();
	my @files;
	my $index = 0;
	#Searches for the file
	foreach my $line (@lines)
	{
		(my $oldPath, my $newPath) = split("=",$line);
		chomp($oldPath);
		chomp($newPath);
		if($path eq $oldPath)
		{
			#The file was found
			my $newFileManager = Com::IsKernel::Libs::FileHandling::FileManager->new($newPath);
			#Converts the hexdump to ASCII
			my $content = $self->getHexDumper()->convertHexDumpToAscii(
								$newFileManager->getContentAsString());
			#Restores the file
			$newFileManager->setPath($oldPath);
			$newFileManager->createFile();
			$newFileManager->replaceContent($content);
			my $response = unlink($newPath);
			my $result = 0;
			if($response)
			{
				#If restoration was successful, removes the coresponding line from the quarantine log
				my $quarantineContent = $quarantineManager->getContentAsString();
				$quarantineContent =~ s/\Q$line//g;
				$quarantineManager->replaceContent($quarantineContent);
				$result = 1;
			}
			my $nowTime = localtime;
			my $printResponse = $newFileManager->getPath()." "."was restored successfully\n";
			my $logResponse = $nowTime." ".$printResponse;
			$self->getEventLogger()->appendString($logResponse);
	
			return ($result,$printResponse);
		}
	}
		
}
=pod
Description:
	Changes the extensions used by the scanner
Parameters:
	A line containing the new extensions used
Returns:
	none
Type:
	Public
=cut
sub changeScanExtensions
{
	my $self= shift;
	my $newExtensions = shift;
	$self->getConfiguration()->setExtensions($newExtensions);
}
=pod
Description:
	Verifies if a file has one of the specified extensions
Parameters:
	path - the path to the file
Returns:
	1 - the file should be scanned
	0 - the file should be skipped
Type:
	Public
=cut
sub verifyExtension
{
	my $self = shift;
	my $path = shift;
	my $result = 0;
	my $extensionString = $self->getConfiguration()->getExtensions();
	if($extensionString eq ALL_EXTENSIONS)
	{
		$result = 1;
	}
	else
	{
		my $ext = ($path =~ m/([^.]+)$/)[0];
		my @extensions = split(" ",$extensionString);
		foreach my $extension (@extensions)
		{
			if($extension eq $ext)
			{
				$result = 1;
				last;
			}
		}
	}
	return $result;	
}
#END OF MODULE
1;