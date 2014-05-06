package IsKernel::CandyAntivirus::Configuration;

use warnings;
use strict;
use v5.14;

use base qw(IsKernel::Infrastructure::FileHelper);


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
	Creates a new instance of Configuration
Parameters:
	path - the path to the configuration file
Returns
	A reference to the object
Type:
	Constructor
=cut
sub new
{
	(my $class, my $path) = @_;
	my $self = $class->SUPER::new($path);
	open(my $handle, 
		 "<",
		 $self->getPath()
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
	bless $self, $class;
	return $self; 
} 

sub getPathToWwwDatabase
{
	my $self = shift;
	return $self->{"linkToWwwDatabase"};
}

sub getPathToQuarantineLog
{
	(my $self) = @_;
	return $self->{"pathToQuarantineLog"};
}

sub getPathToLog()
{
	(my $self) = @_;
	return $self->{"pathToLog"};
}

sub getVirusDatabasePath()
{
	(my $self) = @_;
	return $self->{"virusDatabasePath"};
}

sub getQuarantinePath()
{
	(my $self) = @_;
	return $self->{"quarantinePath"};
}

sub getDefaultWorkingDirectory()
{
	(my $self) = @_;
	return $self->{"defaultWorkingDirectory"} ;
}

sub getExtensions()
{
	(my $self) = @_;
	return $self->{"extensions"} ;
}

sub getVirusDetectedOption()
{
	(my $self) = @_;
	return $self->{"virusDetectedOption"};
}

sub setVirusDatabasePath()
{
	(my $self, my $path) = @_;
	$self->{"virusDatabasePath"} = $path;
}

sub setQuarantinePath()
{
	(my $self, my $path) = @_;
	$self->{"quarantinePath"} = $path;
}

sub setDefaultWorkingDirectory()
{
	(my $self, my $path) = @_;
	$self->{"defaultWorkingDirectory"} = $path;
}

sub setExtensions()
{
	(my $self, my $path) = @_;
	$self->{"extensions"} = $path;
}

sub setVirusDetectedOption()
{
	(my $self, my $path) = @_;
	$self->{"virusDetectedOption"} = $path;
}

sub setPathToLog()
{
	(my $self, my $path) = @_;
	$self->{"pathToLog"} = $path;
}

sub setPathToWwwDatabase
{
	my $self = shift;
	$self->{"linkToWwwDatabase"} = shift;
}

sub makeSettingsDefault()
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
		 $self->getPath()
		) or die("Could not open Virus Signature file");
	print $handle $content;
}

#END OF MODULE
1;