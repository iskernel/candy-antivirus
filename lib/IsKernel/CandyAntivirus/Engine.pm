package IsKernel::CandyAntivirus::Engine;

use warnings;
use strict;
use v5.14;

use File::Find;
use File::Basename;
use File::Spec::Functions;
use LWP::Simple;

use IsKernel::Infrastructure::FileHelper;
use IsKernel::Infrastructure::StringHelper;
use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::VirusScanner;

#The length of a random filename used by a quarantined file
use constant RANDOM_FILENAME_LENGTH => 30;
use constant ALL_EXTENSIONS => "all";

=pod
Description:
	Generates a new antivirus engine object
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
	$self->{"Scanner"} = IsKernel::CandyAntivirus::VirusScanner->new($configuration->get_virus_database_path());
	#$self->{"HexConverter"} = IsKernel::Infrastructure::HexConverter->new();
	$self->{"EventLogger"} = IsKernel::CandyAntivirus::FileHelper->new($configuration->get_path_to_log());
	$self->{"QuarantineLogger"} = IsKernel::CandyAntivirus::FileHelper->new($configuration->get_path_to_quarantine_log());
	#$self->{"RandomFilenameGenerator"} = IsKernel::CandyAntivirus::StringHelper->new(RANDOM_FILENAME_LENGTH);
	$self->set_working_directory($directory);	
	bless $self, $class;
	return $self;
}

=pod
Description:
	Returns the hex converter
Parameters:
	None
Returns:
	The hex converter
Type:
	Constructor

sub get_hex_converter()
{
	my $self = shift;
	return $self->{"HexConverter"};
}
=cut

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
sub set_configuration()
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
sub set_working_directory()
{
	my $self = shift;
	my $directory = shift;
	my $response = undef;
	if( defined $directory )
	{
		if(-d $directory)
		{
			$self->{"Directory"} = $directory;
			$response = IsKernel::CandyAntivirus::EngineResponse->new("Directory set");
		}
		else
		{
			$self->{"Directory"} = $self->get_configuration()->get_default_working_directory();			
		}
	}
	else
	{		
		$self->{"Directory"} = $self->get_configuration()->get_default_working_directory();
	}
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
sub get_configuration()
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
sub get_working_directory()
{
	my $self = shift;
	return $self->{"Directory"};
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
sub get_scanner()
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
sub get_event_logger()
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
sub get_quarantine_logger()
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
sub get_random_filename_generator()
{
	my $self = shift;
	return $self->{"RandomFilenameGenerator"};
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
sub has_virus()
{
	(my $self, my $file_helper) = @_;
	my $content = $file_helper->get_content_as_string();
	(my $hasVirus, my $virusName) = $self->getScanner()->analyze_content($content);
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
sub delete_action
{
	(my $self, my $file_manager) = @_;
	my $result = unlink($file_manager->getPath());
	
	my $now_time = localtime;
	
	my $print_response = undef;
	my $log_response = undef;
	my $ret_val = undef;
	#The file was deleted successfully
	if($result)
	{
		$print_response = $file_manager->get_path()." "."was deleted from system\n";
		$log_response = $now_time." ".$print_response;
		$ret_val = 1;
	}
	#The file was not deleted successfully
	else
	{
		$print_response = $file_manager->get_path()." "."was NOT deleted from system\n";
		$log_response = $now_time." ".$print_response;
		$ret_val = 0;
	}
	#Writes to log file
	$self->get_event_logger()->append_to_file($log_response);
	return ($ret_val, $print_response);
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
sub quarantine_action
{
	(my $self, my $file_manager) = @_;
	
	#Puts in memory the content of the original file
	my $file_content = $file_manager->get_content_as_string();
	
	#Deletes the original file
	my $result = unlink($file_manager->get_path());
	
	my $now_time = localtime;
	my $old_path = $file_manager->get_path();
	
	my $log_response = undef;
	my $print_response = undef;
	my $ret_val = 0;
	
	if($result)
	{
		#Creates the hexdump file
		my $hex_file_manager = IsKernel::Infrastructure::FileHelper->new(".");
		my $new_path = $hex_file_manager->create_random_filename();
		$hex_file_manager->set_path($new_path);
		#Writes the hexdump
		my $hex_dump_content = $self->get_hex_converter()->ascii_to_hex_dump($file_content);		
		$hex_file_manager->write_to_file($hex_dump_content);
		#Adds a definition to the quarantine logger in case the user wants to restore the file
		my $log_message = $old_path."=".$new_path."\n";
		$self->get_quarantine_logger()->append_to_file($log_message);
		$print_response = $old_path." was quarantined from system\n";
		$log_response = $now_time." ".$print_response;
		$ret_val = 1;
	}
	else
	{
		$print_response = $old_path." was NOT quarantined successfully\n";
		$log_response = $now_time." ".$print_response;
		
	}
	#Writes event to event logger
	$self->get_event_logger()->append_to_file($log_response);
	
	return ($ret_val, $print_response);
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
sub disinfect_action()
{
	(my $self, my $file_manager) = @_;
	my $file_content = $file_manager->get_content_as_string();
	#Dumps the content of the file to hex
	my $file_hex_dump = $self->get_hex_converter()->ascii_to_hex_dump($file_content);
	#Removes all virus signatures
	$file_hex_dump = $self->get_scanner()->disinfect_content($file_hex_dump);
	#Converts the newly created hex to ASCII
	$file_content = $self->get_hex_converter()->hex_dump_to_ascii($file_hex_dump);
	#Replaces the content in the original file
	$file_manager->write_to_file($file_content);
	
	my $now_time = localtime;
	my $print_response = $file_manager->get_path()." "."was disinfected successfully\n";
	my $log_response = $now_time." ".$print_response;
	$self->getEventLogger()->appendString($log_response);
	
	return (1,$print_response);	
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
sub get_log_file_content()
{
	my $self = shift;
	return $self->get_event_logger()->get_content_as_string();
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
sub download_new_definitions()
{
	my $self = shift;
	my $content = get($self->get_configuration()->get_path_to_www_database()) 
				  or die("Could not get content from online database");
    open(my $handle, ">", $self->get_configuration()->get_virus_database_path()) 
    	 or die("Could not create file at ".$self->get_configuration()->get_virus_database_path());
	print $handle $content;
	close($handle);
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
sub get_quarantined_files()
{
	my $self = shift;
	my $file_manager = IsKernel::Infrastructure::FileHelper->new($self->get_configuration()->get_path_to_quarantine_log());
	my @lines = $file_manager->get_content_as_array();
	my @files;
	my $index = 0;
	foreach my $line (@lines)
	{
		(my $old_path, my $new_path) = split("=",$line);
		chomp($old_path);
		$files[$index] = $old_path;
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
sub restore_quarantined_file()
{
	my $self = shift;
	my $path = shift;
	my $quarantine_manager = IsKernel::Infrastructure::FileHelper->new($self->get_configuration()->get_path_to_quarantine_log());
	my @lines = $quarantine_manager->get_content_as_array();
	my @files;
	my $index = 0;
	#Searches for the file
	foreach my $line (@lines)
	{
		(my $old_path, my $new_path) = split("=",$line);
		chomp($old_path);
		chomp($new_path);
		if($path eq $old_path)
		{
			#The file was found
			my $new_file_manager = IsKernel::Infrastructure::FileHelper->new($new_path);
			#Converts the hexdump to ASCII
			my $content = $self->get_hex_converter()->hex_dump_to_ascii($new_file_manager->get_content_as_string());
			#Restores the file
			$new_file_manager->set_path($old_path);
			$new_file_manager->write_to_file($content);
			my $response = unlink($new_path);
			my $result = 0;
			if($response)
			{
				#If restoration was successful, removes the coresponding line from the quarantine log
				my $quarantine_content = $quarantine_manager->get_content_as_string();
				$quarantine_content =~ s/\Q$line//g;
				$quarantine_manager->write_to_file($quarantine_content);
				$result = 1;
			}
			my $now_time = localtime;
			my $print_response = $new_file_manager->get_path()." "."was restored successfully\n";
			my $log_response = $now_time." ".$print_response;
			$self->get_event_logger()->append_to_file($log_response);
	
			return ($result,$print_response);
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
sub set_scan_extensions
{
	my $self= shift;
	my $new_extensions = shift;
	$self->get_configuration()->set_extensions($new_extensions);
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
sub verify_extension()
{
	my $self = shift;
	my $path = shift;
	my $result = 0;
	my $extension_content = $self->get_configuration()->get_extensions();
	if($extension_content eq ALL_EXTENSIONS)
	{
		$result = 1;
	}
	else
	{
		my $ext = ($path =~ m/([^.]+)$/)[0];
		my @extensions = split(" ",$extension_content);
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