#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Find;
use File::Spec;
use File::Copy;

use LWP::Simple qw(head);

use IsKernel::Infrastructure::FileUtilities;
use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::Engine;

use constant LOOP_RUNNING   => 1;
use constant LOOP_STOPPED   => 0;
use constant DEFAULT_PATH_TO_CONFIG => "./data/default_config.cfg";
use constant PATH_TO_CONFIG => "./data/config.cfg";
use constant VIRUS_DETECTED_ASK_USER => "AskUser";
use constant VIRUS_DETECTED_DELETE => "Delete";
use constant VIRUS_DETECTED_DISINFECT => "Disinfect";
use constant VIRUS_DETECTED_QUARANTINE => "Quarantine";
use constant MAIN_MENU_TEXT => "\t\t\tWelcome to Candy Antivirus!\n"
							  . "[a]Start a scan\n"
							  . "[b]See log\n"
							  . "[c]Change working directory\n"
							  . "[d]Download new definitions\n"
							  . "[e]Restore quarantined files\n"
							  . "[f]Configure scan filter\n"
							  . "[g]Change update source\n"
							  . "[h]Change virus handling method\n"
							  . "[i]Reset configuraion file\n"
							  . "[x]Exit\n";

#Loads the configuration file and settings
my $configuration =
  IsKernel::CandyAntivirus::Configuration->new(PATH_TO_CONFIG);
$configuration->make_paths_absolute();
my $engine = IsKernel::CandyAntivirus::Engine->new( $configuration, $ARGV[0] );
$engine->get_event_logger()->init_session();

#Initializes the program loop
my $loop_keeper = LOOP_RUNNING;

#Runs the main menu
while ( $loop_keeper == LOOP_RUNNING )
{
	say( "The working directory is: " . $engine->get_working_directory() );
	print(MAIN_MENU_TEXT);
	my $key = <STDIN>;
	chomp($key);
	do_actions( $engine, $key );
}

sub do_actions
{
	( my $engine, my $key ) = @_;
	if ( $key eq "a" )
	{
		scan_files($engine);
	}
	elsif ( $key eq "b" )
	{
		show_scan_log($engine);
	}
	elsif ( $key eq "c" )
	{
		change_working_directory($engine);
	}
	elsif ( $key eq "d" )
	{
		update_definitions($engine);
	}
	elsif ( $key eq "e" )
	{
		restore_from_quarantine($engine);
	}
	elsif ( $key eq "f" )
	{
		configure_scan_filter($engine);
	}
	elsif ( $key eq "g" )
	{
		change_update_source($engine);
	}
	elsif ( $key eq "h" )
	{
		change_virus_handling_method($engine);
	}
	elsif ( $key eq "i" )
	{
		reset_configuration_file();
	}
	elsif ( $key eq "x" )
	{
		$engine->get_event_logger()->close_session();
		exit(0);
	}
	else
	{
		print("Please select one of the options above\n");
	}
}

sub scan_files
{
	my $engine = shift;
	find( \&treat_file, $engine->get_working_directory() );
}

sub show_scan_log
{
	my $engine  = shift;
	my $content = $engine->get_event_logger()->get_content_as_string();
	say($content);
}

sub change_working_directory
{
	my $engine = shift;
	say("Write the new working directory path: ");
	my $new_directory = <STDIN>;
	chomp($new_directory);
	my $set_response = $engine->set_working_directory($new_directory);
	say( $set_response->get_print_response() );
}

sub update_definitions
{
	my $engine = shift;
	eval { $engine->action_update_definitions(); };
	if (@_)
	{
		say("Could not download new definitions from online database");
	}
	else
	{
		say("Definitions updated.");
	}
}

sub restore_from_quarantine
{
	my $engine = shift;
	my @files  = $engine->get_quarantined_files();
	my $index  = 0;
	print scalar(@files);
	if ( scalar(@files) > 0 )
	{
		say("Select which file you want to restore: ");
		foreach my $file (@files)
		{
			say( "[" . $index . "]" . $file );
			$index++;
		}
		say( "[" . $index . "] Return to menu" );
		my $restore_key = <STDIN>;
		chomp($restore_key);
		if (   ( $restore_key =~ m/^\d$/ )
			&& ( $restore_key >= 0 )
			&& ( $restore_key <= $index ) )
		{
			my $new_index   = 0;
			my $chosen_file = undef;
			foreach my $file (@files)
			{
				if ( $new_index eq $restore_key )
				{
					$chosen_file = $file;
				}
				$new_index++;
			}
			if ( defined $chosen_file )
			{
				my $response =
				  $engine->action_restore_quarantined_file($chosen_file);
				say $response->get_print_response();
				if ( $response->get_status() == 0 )
				{
					say("Original file couldn't be deleted from quarantine.");
				}
			}
		}
		else
		{
			say("Incorrect value scanned. Press any key to return to the main menu");
		}
	}
	else
	{
		say("There no files currently quarantined");
	}
}

sub configure_scan_filter
{
	my $engine = shift;
	say("Enter the extensions of the files you want scanned separated by space:\n"
		."Write \"all\" or leave blank if you want to scan every file" );
	my $extensions = <STDIN>;
	chomp($extensions);
	if ( $extensions eq "" )
	{
		$extensions = "all";
	}
	$engine->action_set_extensions($extensions);
}

sub change_update_source
{
	my $engine = shift;
	say("Paste the url for new definitions source: ");
	my $new_url = <STDIN>;
	chomp($new_url);
	if (head($new_url) ) 
	{
    	$engine->get_configuration()->set_path_to_www_database($new_url);
    	$engine->get_configuration()->make_paths_absolute();
    	$engine->get_configuration()->save_settings();    	
	} 
	else 
	{
		say("Url is invalid.")
	}
}

sub reset_configuration_file
{
	copy(DEFAULT_PATH_TO_CONFIG,  PATH_TO_CONFIG)  or die "Copy failed: $!";
}

sub change_virus_handling_method
{
	my $engine = shift;
	my $menu_text = "How should virus files be handled?\n"
					."[1]Ask the user\n"
					."[2]Disinfect\n"
					."[3]Delete\n"
					."[4]Quarantine\n";
	my $loop_keeper = LOOP_RUNNING;
	while ( $loop_keeper == LOOP_RUNNING )
	{
		print $menu_text;
		my $key = <STDIN>;
		chomp($key);
		$loop_keeper = LOOP_STOPPED;
		if ( $key == "1" )
		{
			$engine->get_configuration()->set_virus_detected_option(VIRUS_DETECTED_ASK_USER);
			$engine->get_configuration()->save_settings(); 
		}
		elsif ( $key == "2" )
		{
			$engine->get_configuration()->set_virus_detected_option(VIRUS_DETECTED_ASK_USER);
			$engine->get_configuration()->save_settings(); 
		}
		elsif ( $key == "3" )
		{
			$engine->get_configuration()->set_virus_detected_option(VIRUS_DETECTED_ASK_USER);
			$engine->get_configuration()->save_settings(); 			
		}
		else
		{
			say("Incorrect input. Please give another answer");
			$loop_keeper = LOOP_RUNNING;
		}
	}
}

sub treat_file
{
	my $path           = $File::Find::name;
	my $file_utilities = IsKernel::Infrastructure::FileUtilities->new();
	my $result         = $file_utilities->is_ordinary_file($path);
	if ( $result == 1 )
	{	
		my $extension_response = $engine->action_check_extension($path);
		if ( $extension_response == 1 )
		{
			my $scan_response = $engine->action_detect($path);
			if ( $scan_response->has_virus() == 1 )
			{
				my $virus_detected_option = $engine->get_configuration()->get_virus_detected_option();
				if($virus_detected_option eq VIRUS_DETECTED_ASK_USER)
				{
					handle_infection($engine, $scan_response, $path);
				}
				elsif($virus_detected_option eq VIRUS_DETECTED_DISINFECT)
				{
					my $disinfect_response = $engine->action_disinfect($path);
					print $disinfect_response->get_print_response();
				}
				elsif($virus_detected_option eq VIRUS_DETECTED_DELETE)
				{
					my $delete_response = $engine->action_delete($path);
					print $delete_response->get_print_response();
				}
				elsif($virus_detected_option eq VIRUS_DETECTED_QUARANTINE)
				{
					my $quarantine_response = $engine->action_quarantine($path);
					print $quarantine_response->get_print_response();
				}
				else
				{
					say("Unkown option for handling an infection. We shall assume is AskUser");
					handle_infection($engine, $scan_response, $path);					
				}
			}
			else
			{
				say( $path . " is not infected" );
			}
		}
		else
		{
			say( $path . " skipped" );
		}
	}
	elsif ( $result == 0 )
	{
		say( "Could not open file at " . $path );
	}
	else
	{
		#Not a "normal" file
	}
}

sub handle_infection
{
	my $engine = shift;
	my $scan_response = shift;
	my $path = shift;
	my $menu_text =	  $scan_response->virus_name()
				  	  . " was detected at: "
				      . $path
				      . " .How should I proceed?\n"
				      . "[1]Delete file permanently\n"
				      . "[2]Send file to quarantine\n"
				      . "[3]Disinfect file\n";
	my $loop_keeper = LOOP_RUNNING;
	while ( $loop_keeper == LOOP_RUNNING )
	{
		print $menu_text;
		my $key = <STDIN>;
		chomp($key);
		$loop_keeper = LOOP_STOPPED;
		if ( $key == "1" )
		{
			my $delete_response = $engine->action_delete($path);
			print $delete_response->get_print_response();
			if ( $delete_response->get_status() == 0 )
			{
				$loop_keeper = LOOP_RUNNING;
			}
		}
		elsif ( $key == "2" )
		{
			my $quarantine_response =
			  $engine->action_quarantine($path);
			print $quarantine_response->get_print_response();
			if ( $quarantine_response->get_status() == 0 )
			{
				$loop_keeper = LOOP_RUNNING;
			}
		}
		elsif ( $key == "3" )
		{
			my $disinfect_response =
			  $engine->action_disinfect($path);
			print $disinfect_response->get_print_response();
			if ( $disinfect_response->get_status() == 0 )
			{
				$loop_keeper = LOOP_RUNNING;
			}
		}
		else
		{
			say("Incorrect input. Please give another answer");
			$loop_keeper = LOOP_RUNNING;
		}
	}	
}