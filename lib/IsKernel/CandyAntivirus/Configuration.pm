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

sub new
{
	(my $class, my $path) = @_;
	my $self = {};
	$self->{"path"} = $path;
	bless $self, $class;
	$self->load();
	return $self; 
} 

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

sub get_path_to_www_database()
{
	my $self = shift;
	return $self->{"linkToWwwDatabase"};
}

sub get_path_to_quarantine_log()
{
	(my $self) = @_;
	return $self->{"pathToQuarantineLog"};
}

sub get_path_to_log()
{
	(my $self) = @_;
	return $self->{"pathToLog"};
}

sub get_virus_database_path()
{
	(my $self) = @_;
	return $self->{"virusDatabasePath"};
}

sub get_quarantine_path()
{
	(my $self) = @_;
	return $self->{"quarantinePath"};
}

sub get_default_working_directory_path()
{
	(my $self) = @_;
	return $self->{"defaultWorkingDirectory"} ;
}

sub get_extensions_option()
{
	(my $self) = @_;
	return $self->{"extensions"} ;
}

sub get_virus_detected_option()
{
	(my $self) = @_;
	return $self->{"virusDetectedOption"};
}

sub set_path_to_quarantine_log()
{
	(my $self, my $newValue) = @_;
	$self->{"pathToQuarantineLog"} = $newValue;
}

sub set_virus_database_path()
{
	(my $self, my $path) = @_;
	$self->{"virusDatabasePath"} = $path;
}

sub set_quarantine_path()
{
	(my $self, my $path) = @_;
	$self->{"quarantinePath"} = $path;
}

sub set_default_working_drectory()
{
	(my $self, my $path) = @_;
	$self->{"defaultWorkingDirectory"} = $path;
}

sub set_extension_option()
{
	(my $self, my $path) = @_;
	$self->{"extensions"} = $path;
}

sub set_virus_detected_option()
{
	(my $self, my $path) = @_;
	$self->{"virusDetectedOption"} = $path;
}

sub set_path_to_log()
{
	(my $self, my $path) = @_;
	$self->{"pathToLog"} = $path;
}

sub set_path_to_www_database()
{
	my $self = shift;
	$self->{"linkToWwwDatabase"} = shift;
}

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