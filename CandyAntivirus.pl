#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Find;

use IsKernel::Infrastructure::FileUtilities;
use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::Engine;

use constant LOOP_RUNNING 
			 => 1;
use constant LOOP_STOPPED
			 => 0;
use constant PATH_TO_CONFIG
			 => "./data/config.cfg";
use constant MAIN_MENU_TEXT 
			 => "\t\t\tWelcome to Candy Antivirus!\n".
				"[1]Start a scan\n".
				"[2]See log\n".
				"[3]Change working directory\n".
				"[4]Download new definitions\n".
				"[5]Restore quarantined files\n".
				"[6]Configure scan filter\n".
				"[7]Exit\n";

#Loads the configuration file and settings
my $configuration = IsKernel::CandyAntivirus::Configuration->new(PATH_TO_CONFIG);
my $engine = IsKernel::CandyAntivirus::Engine->new($configuration, $ARGV[0]);
$engine->get_event_logger()->init_session();

#Initializes the program loop
my $loop_keeper = LOOP_RUNNING;

#Runs the main menu
while($loop_keeper==LOOP_RUNNING)
{
	say("The working directory is: ".$engine->get_working_directory());
	print(MAIN_MENU_TEXT);
	my $key = <STDIN>;
	chomp($key);
	do_actions($engine, $key);
}

sub do_actions
{
	(my $engine, my $key) = @_;
	if($key=="1")
	{
		scan_files($engine);	
	}
	elsif($key=="2")
	{
		show_scan_log($engine);
	}
	elsif($key=="3")
	{
		change_working_directory($engine);
	}
	elsif($key=="4")
	{
		update_definitions($engine);	
	}
	elsif($key=="5")
	{
		restore_from_quarantine($engine);
	}
	elsif($key=="6")
	{
		configure_scan_filter($engine);	
	}
	elsif($key=="7")
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
	find(\&treat_file, $engine->get_working_directory());	
}

sub show_scan_log
{
	my $engine = shift;
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
	say($set_response->get_print_response());
}

sub update_definitions
{
	my $engine = shift;
	eval
	{
		$engine->action_update_definition();
	};
	if(@_)
	{
		say("Could not download new definitions from online database");
	}
}

sub restore_from_quarantine
{
	my $engine = shift;
	my @files = $engine->get_quarantined_files();
	my $index = 0;
	if(scalar(@files) > 0)
	{
		say("Select which file you want to restore: ");
		foreach my $file (@files)
		{
			say("[".$index."]".$file);
			$index++;
		}
		say("[".$index."] Return to menu");
		my $restore_key = <STDIN>;
		chomp($restore_key);
		if( ($restore_key=~m/^\d$/) && ($restore_key >= 0) && ($restore_key <= $index) )
		{
			my $new_index = 0;
			my $chosen_file = undef;
			foreach my $file(@files)
			{
				if($new_index eq $restore_key)
				{
					$chosen_file = $file;
				}
				$new_index++;
			}
			if(defined $chosen_file)
			{
				my $response = $engine->action_restore_quarantined_file($chosen_file);
				say $response->get_print_response();
				if($response->get_status() ==0)
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
	say("Enter the extensions of the files you want scanned separated by space:\n".
		"Write \"all\" or leave blank if you want to scan every file");
	my $extensions = <STDIN>;
	chomp($extensions);
	if($extensions eq "")
	{
		$extensions = "all";
	}
	$engine->action_set_extensions($extensions);
}

sub treat_file
{
	my $path = $File::Find::name;
	my $file_utilities = IsKernel::Infrastructure::FileUtilities->new();
	my $result = $file_utilities->is_ordinary_file($path);
	
	if($result==1)
	{
		my $extension_response = $engine->action_check_extension($path);
		if($extension_response==1)
		{
			my $scan_response = $engine->action_detect($path);
			if($scan_response->has_virus()==1)
			{
				my $menu_text =  $scan_response->virus_name()." was detected at: ".$path." .How should I proceed?\n"
								."[1]Delete file permanently\n"
								."[2]Send file to quarantine\n"
								."[3]Disinfect file\n";				
				my $loop_keeper = LOOP_RUNNING;
				while($loop_keeper==LOOP_RUNNING)
				{
					print $menu_text;
					my $key = <STDIN>;
					chomp($key);
					$loop_keeper = LOOP_STOPPED;
					if($key=="1")
					{
						my $delete_response= $engine->action_delete($path);
						print $delete_response->get_print_response();
						if($delete_response->get_status() ==0)
						{
							$loop_keeper = LOOP_RUNNING;
						}
					}
					elsif($key=="2")
					{
						my $quarantine_response = $engine->action_quarantine($path);
						print $quarantine_response->get_print_response();
						if($quarantine_response->get_status() ==0)
						{
							$loop_keeper = LOOP_RUNNING;
						}
					}
					elsif($key=="3")
					{
						my $disinfect_response = $engine->action_disinfect($path);
						print $disinfect_response->get_print_response();
						if($disinfect_response->get_status() ==0)
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
			else
			{
				say($path." is not infected");
			}
		}
		else
		{
			say($path." skipped");
		}
	}
	elsif($result==0)
	{
		say("Could not open file at ".$path);
	}
	else
	{
		#Not a "normal" file
	}
}