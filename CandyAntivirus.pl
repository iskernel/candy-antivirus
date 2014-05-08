#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Find;

use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::Engine;

use constant LOOP_RUNNING 
			 => 1;
use constant LOOP_STOPPED
			 => 0;
use constant PATH_TO_CONFIG
			 => "./Settings/config.txt";
use constant MAIN_MENU_TEXT 
			 => "\t\t\tWelcome to Generic Antivirus!\n".
				"[1]Start a scan\n".
				"[2]See log\n".
				"[3]Change working directory\n".
				"[4]Download new definitions\n".
				"[5]Restore quarantined files\n".
				"[6]Configure scan filter\n".
				"[7]Exit\n";

#STARTPOINT
#Loads the configuration file and settings
my $configuration = IsKernel::CandyAntivirus::Configuration->new(PATH_TO_CONFIG);
my $engine = IsKernel::CandyAntivirus::Engine->new($configuration, $ARGV[0]);
$engine->getEventLogger()->appendString("===Session started at ".localtime."===\n");
#Initializes the program loop
my $loopKeeper = LOOP_RUNNING;
#Runs the main menu
while($loopKeeper==LOOP_RUNNING)
{
	say("The working directory is: ".$engine->getWorkingDirectory());
	#Prints the menu
	print(MAIN_MENU_TEXT);
	#Reads the input
	my $key = <STDIN>;
	#Removes trailling whitespace
	chomp($key);
	#Decision
	#Folder scan will be started
	if($key=="1")
	{
		find(\&treatFile, $engine->getWorkingDirectory());			
	}
	#Displayes the scan log
	elsif($key=="2")
	{
		say($engine->getLogFileContents());		
	}
	#Changes the path of the working directory
	elsif($key=="3")
	{
		say("Write the new working directory path: ");
		my $newDirectory = <STDIN>;
		chomp($newDirectory);
		if(-d $newDirectory)
		{
			$engine->setWorkingDirectory($newDirectory);
		}
		else
		{
			say("The path is invalid.");
		}
	}
	#Loads new definitions
	elsif($key=="4")
	{
		eval
		{
			$engine->downloadNewDefinitions();
		};
		if(@_)
		{
			say("Could not download new definitions from online database");
		}
	}
	#Restore files kept in quarantine
	elsif($key=="5")
	{
		my @files = $engine->getQuarantinedFiles();
		my $index = 0;
		if(scalar(@files)>0)
		{
			say("Select which file you want to restore: ");
			foreach my $file(@files)
			{
				say("[".$index."]".$file);
				$index++;
			}
			say("[".$index."] Return to menu");
			my $restoreKey = <STDIN>;
			chomp($restoreKey);
			if( ($restoreKey=~m/^\d$/) && ($restoreKey >= 0) && ($restoreKey <= $index) )
			{
				my $newIndex = 0;
				my $chosenFile = undef;
				foreach my $file(@files)
				{
					if($newIndex eq $restoreKey)
					{
						$chosenFile = $file;
					}
					$newIndex++;
				}
				if(defined $chosenFile)
				{
					(my $response, my $message) = $engine->restoreQuarantinedFile($chosenFile);
					say $message;
					if($response ==0)
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
			say("There no files curently quarantined");
		}
	}
	#Configures scan filter
	elsif($key=="6")
	{
		say("Enter the extensions of the files you want scanned separated by space:\n".
			"Write all or leave blank if you want to scan every file");
		my $extensions = <STDIN>;
		chomp($extensions);
		if($extensions eq "")
		{
			$extensions = "all";
		}
		$engine->changeScanExtensions($extensions);	
	}
	elsif($key=="7")
	{
		#Exits the program	
		$engine->getEventLogger()->appendString("===Session ended at ".localtime."===\n");
		exit(0);
	}
	else
	{
		print("Please select one of the options above\n");		
	}	
}

sub treatFile
{
	my $path = $File::Find::name;

	my $result = $engine->verifyFile($path);
	if($result==1)
	{
		my $extResult = $engine->verifyExtension($path);
		if($extResult==1)
		{
			my $fileManager = Com::IsKernel::Libs::FileHandling::FileManager->new($path);
			(my $hasVirus, my $virusName) = $engine->hasVirus($fileManager);
			if($hasVirus==1)
			{
				my $menuText = 
					$virusName." was detected at: ".$fileManager->getPath()." .How should I proceed?\n".
					"[1]Delete file permanently\n".
					"[2]Send file to quarantine\n".
					"[3]Disinfect file\n";
				
				my $loopKeeper = LOOP_RUNNING;
				while($loopKeeper==LOOP_RUNNING)
				{
					print $menuText;
					my $key = <STDIN>;
					chomp($key);
					$loopKeeper = LOOP_STOPPED;
					if($key=="1")
					{
						(my $response, my $message) = $engine->deleteAction($fileManager);
						print $message;
						if($response ==0)
						{
							$loopKeeper = LOOP_RUNNING;
						}
					}
					elsif($key=="2")
					{
						(my $response, my $message) = $engine->quarantineAction($fileManager);
						print $message;
						if($response ==0)
						{
							$loopKeeper = LOOP_RUNNING;
						}
					}
					elsif($key=="3")
					{
						(my $response, my $message) = $engine->disinfectAction($fileManager);
						print $message;
						if($response ==0)
						{
							$loopKeeper = LOOP_RUNNING;
						}
					}
					else
					{
						say("Incorrect input. Please give another answer");
						$loopKeeper = LOOP_RUNNING;
					}
				}
			}
			else
			{
				say($fileManager->getPath()." is not infected");
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