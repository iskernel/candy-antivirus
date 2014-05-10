package IsKernel::CandyAntivirus::Configuration;

use warnings;
use strict;
use v5.14;

use constant VIRUS_DATABASE_PATH_ID =>"VIRUS_SIGNATURES_PATH";
use constant QUARANTINE_PATH_ID => "QUARANTINE_PATH";
use constant DEFAULT_WORKING_DIRECTORY_PATH_ID => "DEFAULT_WORKING_DIRECTORY_PATH";
use constant EXTENSIONS_ID => "EXTENSIONS";
use constant VIRUS_DETECTED_OPTION_ID => "VIRUS_DETECTED_OPTION";
use constant PATH_TO_LOG_ID => "PATH_TO_LOG";
use constant PATH_TO_QUARANTINE_LOG_ID => "PATH_TO_QUARANTINE_LOG";
use constant LINK_TO_WWW_DATABASE => "LINK_TO_WWW_DATABASE";

=pod
Description:
	Creates a new object
Parameters:
	path - the path specific for the configuration file
Returns
	A reference to the object
=cut
sub new
{
	(my $class, my $path) = @_;
	my $self = {};
	$self->{"path"} = $path;
	bless $self, $class;
	$self->load();
	return $self; 
} 

=pod
Description:
	Loads into memory the content of the configuration file
Parameters:
	None
Returns
	None
=cut
sub load()
{
	my $self = shift;
	open(my $handle, 
		 "<",
		 $self->{"path"}
		) or die("Could not open Virus Signature file");
	my @lines = <$handle>;
	foreach my $line (@lines)
	{
		my @params = split("=",$line);
		chomp($params[1]);
		if($params[0] eq VIRUS_DATABASE_PATH_ID)
		{
			$self->{"virusDatabasePath"} = $params[1];
		}
		elsif($params[0] eq QUARANTINE_PATH_ID)
		{
			$self->{"quarantinePath"} = $params[1];
		}
		elsif($params[0] eq DEFAULT_WORKING_DIRECTORY_PATH_ID)
		{
			$self->{"defaultWorkingDirectory"} = $params[1];
		}
		elsif($params[0] eq EXTENSIONS_ID)
		{
			$self->{"extensions"} = $params[1];
		}
		elsif($params[0] eq VIRUS_DETECTED_OPTION_ID)
		{
			$self->{"virusDetectedOption"} = $params[1];
		}
		elsif($params[0] eq PATH_TO_LOG_ID)
		{
			$self->{"pathToLog"} = $params[1];
		}
		elsif($params[0] eq PATH_TO_QUARANTINE_LOG_ID)
		{
			$self->{"pathToQuarantineLog"} = $params[1];
		}
		elsif($params[0] eq LINK_TO_WWW_DATABASE)
		{
			$self->{"linkToWwwDatabase"} = $params[1];
		}
	}	
}

=pod
Description:
	Returns the path to the online virus database
Parameters:
	None
Returns
	The path to the online virus database
=cut
sub get_path_to_www_database()
{
	my $self = shift;
	return $self->{"linkToWwwDatabase"};
}

=pod
Description:
	Returns the path to the quarantine log
Parameters:
	None
Returns
	The path to the quarantine log
=cut
sub get_path_to_quarantine_log()
{
	(my $self) = @_;
	return $self->{"pathToQuarantineLog"};
}

=pod
Description:
	Returns the path to the event log
Parameters:
	None
Returns
	The path to the event log
=cut
sub get_path_to_log()
{
	(my $self) = @_;
	return $self->{"pathToLog"};
}

=pod
Description:
	Returns the path to the offline virus database
Parameters:
	None
Returns
	The path to the offline virus database
=cut
sub get_virus_database_path()
{
	(my $self) = @_;
	return $self->{"virusDatabasePath"};
}

=pod
Description:
	Returns the path to the quarantine directory
Parameters:
	None
Returns
	The path to the quarantine directory
=cut
sub get_quarantine_path()
{
	(my $self) = @_;
	return $self->{"quarantinePath"};
}

=pod
Description:
	Returns the path to the default working directory
Parameters:
	None
Returns
	The path to the default working directory
=cut
sub get_default_working_directory_path()
{
	(my $self) = @_;
	return $self->{"defaultWorkingDirectory"} ;
}

=pod
Description:
	Returns the scannable file extensions.
Parameters:
	None
Returns
	The scannable file extensions
=cut
sub get_extensions_option()
{
	(my $self) = @_;
	return $self->{"extensions"} ;
}

=pod
Description:
	Returns the default user action for virus detection.
Parameters:
	None
Returns
	The default user action in case of virus detection
=cut
sub get_virus_detected_option()
{
	(my $self) = @_;
	return $self->{"virusDetectedOption"};
}

=pod
Description:
	Sets the new quarantine log file path.
Parameters:
	path - the new path to the quarantine log
Returns
	None
=cut
sub set_path_to_quarantine_log()
{
	(my $self, my $newValue) = @_;
	$self->{"pathToQuarantineLog"} = $newValue;
}

=pod
Description:
	Sets the new path to the offline virus database
Parameters:
	path - the new path to the offline virus database
Returns
	None
=cut
sub set_virus_database_path()
{
	(my $self, my $path) = @_;
	$self->{"virusDatabasePath"} = $path;
}

=pod
Description:
	Sets the new path to the quarantine directory
Parameters:
	path - the new path to the quarantine directory
Returns
	None
=cut
sub set_quarantine_path()
{
	(my $self, my $path) = @_;
	$self->{"quarantinePath"} = $path;
}

=pod
Description:
	Sets the new path to the default working directory
Parameters:
	path - the new path to the default working directory
Returns
	None
=cut
sub set_default_working_drectory()
{
	(my $self, my $path) = @_;
	$self->{"defaultWorkingDirectory"} = $path;
}

=pod
Description:
	Sets the new scannable extensions
Parameters:
	path - the new scannable extensions
Returns
	None
=cut
sub set_extension_option()
{
	(my $self, my $path) = @_;
	$self->{"extensions"} = $path;
}

=pod
Description:
	Sets the new default user action in case of virus detection
Parameters:
	path - the new default user action in case of virus detection
Returns
	None
=cut
sub set_virus_detected_option()
{
	(my $self, my $path) = @_;
	$self->{"virusDetectedOption"} = $path;
}

=pod
Description:
	Sets the new path for the event logger
Parameters:
	path - the new path to the event logger
Returns
	None
=cut
sub set_path_to_log()
{
	(my $self, my $path) = @_;
	$self->{"pathToLog"} = $path;
}

=pod
Description:
	Sets the new url for the www database
Parameters:
	url - the new url for the www database
Returns
	None
=cut
sub set_path_to_www_database()
{
	my $self = shift;
	$self->{"linkToWwwDatabase"} = shift;
}

=pod
Description:
	Writes the settings to the configuraion file
Parameters:
	None
Returns
	None
=cut
sub save_settings()
{
	(my $self) = @_;
	my $content = 
		VIRUS_DATABASE_PATH_ID."=".$self->{"virusDatabasePath"}."\n".
		QUARANTINE_PATH_ID."=".$self->{"quarantinePath"}."\n".
		DEFAULT_WORKING_DIRECTORY_PATH_ID."=".$self->{"defaultWorkingDirectory"}."\n".
		EXTENSIONS_ID."=".$self->{"extensions"}."\n".
		VIRUS_DETECTED_OPTION_ID."=".$self->{"virusDetectedOption"}."\n".
		PATH_TO_LOG_ID."=".$self->{"pathToLog"}."\n".
		PATH_TO_QUARANTINE_LOG_ID."=".$self->{"pathToQuarantineLog"}."\n".
		LINK_TO_WWW_DATABASE."=".$self->{"linkToWwwDatabase"}."\n";
	open(my $handle, 
		 ">",
		 $self->{"path"}
		) or die("Could not open Virus Signature file");
	print $handle $content;
}

#END OF MODULE
1;