#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Copy;
use Test::More;

use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::Engine;
use IsKernel::CandyAntivirus::EngineResponse;

use constant DEFAULT_CONFIG_DIRECTORY => ".";
use constant DEFAULT_DIRECTORY => "../../TestFiles/ToScanFiles";
use constant NEW_VALID_WORKING_DIRECTORY => "../../TestFiles/";
use constant NEW_INVALID_WORKING_DIRECTORY => "../../InvalidDirectory";
use constant DEFAULT_TEST_CONFIG => "../../TestFiles/default_test_config.cfg";
use constant DEFAULT_CONFIG => "../../TestFiles/test_config.cfg";
use constant DEFAULT_TEST_FILE => "../../TestFiles/ToScanFiles/file1.txt";
use constant DEFAULT_COPY_TEST_FILE => "../../TestFiles/ToScanFiles/copyfile1.txt";
use constant DEFAULT_TO_DELETE_TEST_DIRECTORY => "../../TestFiles/ToScanFiles/MyDir";


sub setup()
{
	copy(DEFAULT_TEST_CONFIG, DEFAULT_CONFIG) or die "Copy failed: $!";
	my $configuration = IsKernel::CandyAntivirus::Configuration->new(DEFAULT_CONFIG);
	my $engine = IsKernel::CandyAntivirus::Engine->new($configuration, DEFAULT_DIRECTORY);
	return $engine;
}

sub get_working_directory_default_configuration_get_as_expected()
{
	my $engine = setup();
	ok($engine->get_working_directory() eq DEFAULT_DIRECTORY, "Engine_GetWorkingDirectory_DefaultConfiguration_DefaultPathReturned");
}

sub set_working_directory_to_new_valid_path_new_path_is_set()
{
	my $engine = setup();
	$engine->set_working_directory(NEW_VALID_WORKING_DIRECTORY);
	ok($engine->get_working_directory() eq NEW_VALID_WORKING_DIRECTORY, "Engine_SetWorkingDirectory_NewValidPath_NewPathSet");
}

sub set_working_directory_to_new_invalid_path_new_path_is_set()
{
	my $engine = setup();
	$engine->set_working_directory(NEW_INVALID_WORKING_DIRECTORY);
	ok($engine->get_working_directory() eq DEFAULT_CONFIG_DIRECTORY, "Engine_SetWorkingDirectory_NewInvalidPath_DefaultPathReturned");
}

sub action_delete_delete_a_valid_file_file_is_deleted()
{
	copy(DEFAULT_TEST_FILE, DEFAULT_COPY_TEST_FILE) or die "Copy failed: $!";	
	my $engine = setup();
	ok($engine->action_delete(DEFAULT_COPY_TEST_FILE)->get_status() == 1, "Engine_ActionDelete_AValidFile_FileIsDeleted");
	unlink(DEFAULT_COPY_TEST_FILE);
}

sub action_delete_delete_a_directory_directory_is_not_deleted()
{
	mkdir(DEFAULT_TO_DELETE_TEST_DIRECTORY);
	my $engine = setup();
	ok($engine->action_delete(DEFAULT_COPY_TEST_FILE)->get_status() == 0, "Engine_ActionDelete_ADirectory_DirectoryIsDeleted");
	rmdir(DEFAULT_TO_DELETE_TEST_DIRECTORY);
}



get_working_directory_default_configuration_get_as_expected();
set_working_directory_to_new_valid_path_new_path_is_set();
set_working_directory_to_new_invalid_path_new_path_is_set();
action_delete_delete_a_valid_file_file_is_deleted();
action_delete_delete_a_directory_directory_is_not_deleted();

done_testing();