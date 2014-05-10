package IsKernel::CandyAntivirus::Engine;

use warnings;
use strict;
use v5.14;

use File::Find;
use File::Basename;
use File::Spec::Functions;
use LWP::Simple;

use IsKernel::Infrastructure::FileHelper;
use IsKernel::Infrastructure::FileUtilities;
use IsKernel::Infrastructure::StringHelper;
use IsKernel::CandyAntivirus::EventLogger;
use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::VirusScanner;
use IsKernel::CandyAntivirus::EngineResponse;

#The length of a random filename used by a quarantined file
use constant RANDOM_FILENAME_LENGTH => 30;
use constant ALL_EXTENSIONS => "all";

=pod
Description:
	Generates a new object
Parameters:
	configuration - a configuration object
	directory - the path to working directory
Returns:
	A reference to the new object
=cut
sub new
{
	(my $class, my $configuration, my $directory) = @_;
	my $self = {};	
	$self->{"Configuration"} = $configuration;
	$self->{"Scanner"} = IsKernel::CandyAntivirus::VirusScanner->new($configuration->get_virus_database_path());
	$self->{"EventLogger"} = IsKernel::CandyAntivirus::EventLogger->new($configuration->get_path_to_log());
	$self->{"QuarantineLogger"} = IsKernel::Infrastructure::FileHelper->new($configuration->get_path_to_quarantine_log());	
	bless $self, $class;
	$self->set_working_directory($directory);
	return $self;
}

=pod
Description:
	Changes the configuration object
Parameters:
	configuration - the new configuration object
Returns:
	None
=cut
sub set_configuration
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
=cut
sub set_working_directory
{
	my $self = shift;
	my $directory = shift;
	my $response = undef;
	if( defined $directory )
	{
		if(-d $directory)
		{
			$self->{"Directory"} = $directory;
		}
		else
		{
			$self->{"Directory"} = $self->get_configuration()->get_default_working_directory_path();			
		}
	}
	else
	{		
		$self->{"Directory"} = $self->get_configuration()->get_default_working_directory_path();
	}
	$response = IsKernel::CandyAntivirus::EngineResponse->new("Directory set to ".$self->{"Directory"});
	return $response;
}
=pod
Description:
	Returns the configuration object used by the engine
Parameters:
	None
Returns:
	The configuration object used by the engine
=cut
sub get_configuration
{
	my $self = shift;
	return $self->{"Configuration"};
}

=pod
Description:
	Returns the working directory used by the engine
Parameters:
	None
Returns:
	The working directory used by the engine
=cut
sub get_working_directory
{
	my $self = shift;
	return $self->{"Directory"};
}

=pod
Description:
	Returns the virus scanner 
Parameters:
	None
Returns:
	The virus scanner
=cut
sub get_scanner
{
	my $self = shift;
	return $self->{"Scanner"};
}

=pod
Description:
	Returns the event logger
Parameters:
	None
Returns:
	The event logger
=cut
sub get_event_logger
{
	my $self = shift;
	return $self->{"EventLogger"};
}

=pod
Description:
	Returns the quarantine logger
Parameters:
	None
Returns:
	The quarantine logger
=cut
sub get_quarantine_logger
{
	my $self = shift;
	return $self->{"QuarantineLogger"};
}

=pod
Description:
	Verifies if a file has a virus.
Parameters:
	path - the path to the scanned file
Returns:
	A scan response object
Type:
	Public
=cut
sub action_detect
{
	(my $self, my $path) = @_;
	my $file_helper = IsKernel::Infrastructure::FileHelper->new($path);
	my $content = $file_helper->get_content_as_string();
	my $response = $self->get_scanner()->scan($content);
	return $response;
}

=pod
Description:
	Deletes a file
Parameters:
	path - the path to the deleted file
Returns:
	engine_response - object containing a message and the operation stats
Type:
	Public
=cut
sub action_delete
{
	(my $self, my $path) = @_;
	my $result = unlink($path);
	my $response = undef;
	
	#The file was deleted successfully
	if($result)
	{		
		my $to_print = $path." "."was deleted from system\n";
		$response = IsKernel::CandyAntivirus::EngineResponse->new($to_print, 1);		
	}
	#The file was not deleted successfully
	else
	{
		my $to_print = $path." "."was NOT deleted from system\n";
		$response = IsKernel::CandyAntivirus::EngineResponse->new($to_print, 0);
	}
	#Writes to log file
	$self->get_event_logger()->append_to_file($response->get_log_response());
	return $response;
}

=pod
Description:
	Quarantines a file
Parameters:
	path - the path to the file which needs to be quarantined
Returns:
	An EngineResponse object 
=cut
sub action_quarantine
{
	(my $self, my $path) = @_;
	
	my $file_manager = IsKernel::Infrastructure::FileHelper->new($path);
	
	#Puts in memory the content of the original file
	my $file_content = $file_manager->get_content_as_string();	
	#Deletes the original file
	my $result = unlink($file_manager->get_path());
	#The old path to the file
	my $old_path = $file_manager->get_path();
	
	my $response = undef;
	
	if($result)
	{
		#Creates the hexdump file path
		my $file_utility = IsKernel::Infrastructure::FileUtilities->new();
		my $new_path = $file_utility->create_random_filename(RANDOM_FILENAME_LENGTH, 
															 $self->get_configuration()->get_quarantine_path());
		my $hex_file_manager = IsKernel::Infrastructure::FileHelper->new($new_path);
		#Writes the hexdump
		my $hex_converter = IsKernel::Infrastructure::HexConverter->new();
		my $hex_dump_content = $hex_converter->ascii_to_hex_dump($file_content);		
		$hex_file_manager->write_to_file($hex_dump_content);
		#Adds a definition to the quarantine logger in case the user wants to restore the file
		my $log_message = $old_path."=".$new_path."\n";
		$self->get_quarantine_logger()->append_to_file($log_message);
		my $print_response = $old_path." was quarantined from system\n";
		#Generates response
		$response = IsKernel::CandyAntivirus::EngineResponse->new($print_response,1);		
	}
	else
	{
		my $print_response = $old_path." was NOT quarantined successfully\n";
		$response = IsKernel::CandyAntivirus::EngineResponse->new($print_response,0);
		
	}
	#Writes event to event logger
	$self->get_event_logger()->append_to_file($response->get_log_response());
	
	return $response;
}
=pod
Description:
	Disinfects a file
Parameters:
	path - the path to the scanned file
Returns:
	response - an EngineResponse object
=cut
sub action_disinfect
{
	(my $self, my $path) = @_;
	my $file_manager = IsKernel::Infrastructure::FileHelper->new($path);	
	my $file_content = $file_manager->get_content_as_string();
	$file_content = $self->get_scanner()->remove_signatures($file_content);	
	$file_manager->write_to_file($file_content);
	
	my $print_response = $file_manager->get_path()." "."was disinfected successfully\n";	
	my $response = IsKernel::CandyAntivirus::EngineResponse->new($print_response, 1);
	$self->get_event_logger()->append_to_file($response->get_log_response());
	
	return $response;
}

=pod
Description:
	Downloads new virus definitions from the internetz and saves them
	to the virus database file
Parameters:
	None
Returns:
	None
=cut
sub action_update_definitions
{
	my $self = shift;
	my $content = get($self->get_configuration()->get_path_to_www_database()) 
				  or die("Could not download content from online database");
    open(my $handle, ">", $self->get_configuration()->get_virus_database_path()) 
    	 or die("Could not create file at ".$self->get_configuration()->get_virus_database_path());
    binmode($handle, ":utf8");
	print $handle $content;
	close($handle);
}
=pod
Description:
	Returns a list of the file who were quarantined (their original paths)
Parameters:
	None
Returns:
	a list of the files who were quarantined
=cut
sub get_quarantined_files
{
	my $self = shift;
	my $file_manager = IsKernel::Infrastructure::FileHelper->new($self->get_configuration()->get_path_to_quarantine_log());
	my @lines = $file_manager->get_content_as_array();
	my @files = undef;
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
=cut
sub action_restore_quarantined_file
{
	(my $self, my $path) = @_;
	my $quarantine_manager = IsKernel::Infrastructure::FileHelper->new($self->get_configuration()->get_path_to_quarantine_log());
	my @lines = $quarantine_manager->get_content_as_array();
	my $index = 0;
	#Searches for the file
	foreach my $line (@lines)
	{
		(my $old_path, my $new_path) = split("=",$line);
		chomp($old_path);
		chomp($new_path);
		if($path eq $old_path)
		{
			#Converts the hexdump to ASCII
			my $new_file_manager = IsKernel::Infrastructure::FileHelper->new($new_path);			
			my $hex_converter = IsKernel::Infrastructure::HexConverter->new();
			my $content = $hex_converter->hex_dump_to_ascii($new_file_manager->get_content_as_string());
			#Restores the file
			$new_file_manager->set_path($old_path);
			$new_file_manager->write_to_file($content);
			my $wasFileDeleted = unlink($new_path);
			my $response = undef;
			if($wasFileDeleted)
			{
				#If restoration was successful, removes the coresponding line from the quarantine log
				my $quarantine_content = $quarantine_manager->get_content_as_string();
				$quarantine_content =~ s/\Q$line//g;
				$quarantine_manager->write_to_file($quarantine_content);
				my $print_response = $new_file_manager->get_path()." "."was restored successfully\n";
				$response = IsKernel::CandyAntivirus::EngineResponse->new($print_response, 1);
			}
			else
			{
				my $print_response = $new_file_manager->get_path()." "."was not restored successfully\n";
				$response = IsKernel::CandyAntivirus::EngineResponse->new($print_response, 0);
			}
			$self->get_event_logger()->append_to_file($response->get_log_response());	
			return $response;
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
sub action_set_extensions
{
	my $self= shift;
	my $new_extensions = shift;
	$self->get_configuration()->set_extension_option($new_extensions);
}
=pod
Description:
	Verifies if a file's extension is a specified extesion 
Parameters:
	path - the path to the file
Returns:
	1 - the file should be scanned
	0 - the file should be skipped
=cut
sub action_check_extension
{
	my $self = shift;
	my $path = shift;
	my $result = 0;
	my $extension_content = $self->get_configuration()->get_extensions_option();
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