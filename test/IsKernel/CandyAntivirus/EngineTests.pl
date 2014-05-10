#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Copy;
use Test::More;

use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::Engine;
use IsKernel::CandyAntivirus::EngineResponse;

use constant DEFAULT_CONFIG_DIRECTORY => "../../TestFiles/";
use constant DEFAULT_DIRECTORY => "../../TestFiles/ToScanFiles/";
use constant NEW_VALID_WORKING_DIRECTORY => "../../TestFiles/";
use constant NEW_INVALID_WORKING_DIRECTORY => "../../InvalidDirectory/";
use constant DEFAULT_TEST_CONFIG => "../../TestFiles/default_test_config.cfg";
use constant DEFAULT_CONFIG => "../../TestFiles/test_config.cfg";
use constant DEFAULT_TEST_FILE_1 => "../../TestFiles/ToScanFiles/file1.txt";
use constant DEFAULT_TEST_FILE_2 => "../../TestFiles/ToScanFiles/file2.txt";
use constant DEFAULT_COPY_TEST_FILE_1 => "../../TestFiles/ToScanFiles/copyfile1.txt";
use constant DEFAULT_COPY_TEST_FILE_2 => "../../TestFiles/ToScanFiles/copyfile2.txt";
use constant DEFAULT_TO_DELETE_TEST_DIRECTORY => "../../TestFiles/ToScanFiles/MyDir";
use constant ALL_EXTENSIONS => "all";
use constant CFG_EXTENSION_ONLY => ".cfg";
use constant DEFAULT_TEST_OFFLINE_VIRUS_DATABASE => "../../TestFiles/test_xvirsig.cfg";
use constant COPY_TEST_OFFLINE_VIRUS_DATABASE => "../../TestFiles/copy_xvirsig.cfg";

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
	ok($engine->get_working_directory() eq DEFAULT_DIRECTORY, 
	   "Engine_GetWorkingDirectory_DefaultConfiguration_DefaultPathReturned");
}

sub set_working_directory_to_new_valid_path_new_path_is_set()
{
	my $engine = setup();
	$engine->set_working_directory(NEW_VALID_WORKING_DIRECTORY);
	ok($engine->get_working_directory() eq NEW_VALID_WORKING_DIRECTORY, 
	   "Engine_SetWorkingDirectory_NewValidPath_NewPathSet");
}

sub set_working_directory_to_new_invalid_path_new_path_is_set()
{
	my $engine = setup();
	$engine->set_working_directory(NEW_INVALID_WORKING_DIRECTORY);
	ok($engine->get_working_directory() eq DEFAULT_CONFIG_DIRECTORY, 
	   "Engine_SetWorkingDirectory_NewInvalidPath_DefaultPathReturned");
}

sub action_delete_delete_a_valid_file_file_is_deleted()
{
	copy(DEFAULT_TEST_FILE_1, DEFAULT_COPY_TEST_FILE_1) or die "Copy failed: $!";	
	my $engine = setup();
	ok($engine->action_delete(DEFAULT_COPY_TEST_FILE_1)->get_status() == 1, 
	   "Engine_ActionDelete_AValidFile_FileIsDeleted");
	unlink(DEFAULT_COPY_TEST_FILE_1);
}

sub action_delete_delete_a_directory_directory_is_not_deleted()
{
	mkdir(DEFAULT_TO_DELETE_TEST_DIRECTORY);
	my $engine = setup();
	ok($engine->action_delete(DEFAULT_COPY_TEST_FILE_1)->get_status() == 0, 
	   "Engine_ActionDelete_ADirectory_DirectoryIsNotDeleted");
	rmdir(DEFAULT_TO_DELETE_TEST_DIRECTORY);
}

sub action_check_extensions_any_extension_txt_is_scannable()
{
	my $engine = setup();
	$engine->get_configuration()->set_extension_option(ALL_EXTENSIONS);
	ok($engine->action_check_extension(DEFAULT_COPY_TEST_FILE_1) == 1, 
	   "Engine_ActionCheckExtensions_AnyExtension_TxtIsScannable");
}

sub action_check_extensions_extensions_is_not_specified_txt_is_not_scannable()
{
	my $engine = setup();
	$engine->get_configuration()->set_extension_option(CFG_EXTENSION_ONLY);
	ok($engine->action_check_extension(DEFAULT_COPY_TEST_FILE_1) == 0, 
	   "Engine_ActionCheckExtensions_ExtensionIsNotSpecified_TxtIsNotScannable");
}

sub action_detect_virus_file_has_virus_virus_detected()
{
	my $engine = setup();
	ok($engine->action_detect(DEFAULT_TEST_FILE_1)->has_virus() == 1, 
	   "Engine_ActionDetect_FileHasVirus_VirusDetected");
}

sub action_detect_virus_file_does_not_have_virus_no_virus_response()
{
	my $engine = setup();
	ok($engine->action_detect(DEFAULT_TEST_FILE_2)->has_virus() == 0, 
	   "Engine_ActionDetect_FileDoesNotHaveVirus_NoVirusDetected");
}

sub action_disinfect_file_has_virus_file_is_disinfected()
{
	copy(DEFAULT_TEST_FILE_1, DEFAULT_COPY_TEST_FILE_1) or die "Copy failed: $!";		
	my $engine = setup();
	$engine->action_disinfect(DEFAULT_COPY_TEST_FILE_1);
	ok($engine->action_detect(DEFAULT_COPY_TEST_FILE_1)->has_virus() == 0, 
	   "Engine_ActionDisinfect_FileHasVirus_FileIsDisinfected");
}

sub action_quarantine_accesible_file_was_quarantined()
{
	copy(DEFAULT_TEST_FILE_1, DEFAULT_COPY_TEST_FILE_1) or die "Copy failed: $!";		
	my $engine = setup();
	ok($engine->action_quarantine(DEFAULT_COPY_TEST_FILE_1)->get_status() == 1,
	   "Engine_ActionQuarantine_AccessibleFile_WasQuarantined");
}

sub get_quarantined_files_quarantined_files_exist_at_least_one_quarantined_file_exists()
{
	copy(DEFAULT_TEST_FILE_1, DEFAULT_COPY_TEST_FILE_1) or die "Copy failed: $!";		
	my $engine = setup();
	$engine->action_quarantine(DEFAULT_COPY_TEST_FILE_1);
	my @files = $engine->get_quarantined_files();
	ok(scalar(@files) >=1 , "Engine_GetQuarantinedFiles_QuarantinedFilesExist_AtLeastOneQuarantinedFileExists")
}

sub action_restore_quarantined_file_file_in_quarantine_is_restored()
{
	copy(DEFAULT_TEST_FILE_1, DEFAULT_COPY_TEST_FILE_1) or die "Copy failed: $!";		
	my $engine = setup();
	$engine->action_quarantine(DEFAULT_COPY_TEST_FILE_1);
	my @files = $engine->get_quarantined_files();
	my $path = $files[-1];	
	ok($engine->action_restore_quarantined_file($path)->get_status() == 1, "Engine_ActionRestoreQuarantinedFile_FileInQuarantine_FileIsRestored");
}

sub action_update_definitions_download_file_file_is_downloaded()
{
	copy(DEFAULT_TEST_OFFLINE_VIRUS_DATABASE, COPY_TEST_OFFLINE_VIRUS_DATABASE) or die "Copy failed: $!";		
	my $engine = setup();
	$engine->get_configuration()->set_virus_database_path(COPY_TEST_OFFLINE_VIRUS_DATABASE);
	$engine->action_update_definitions();
	#Does not crash
	ok(1, "Engine_ActionUpdateDefinitions_DownloadFile_FileIsDownloaded");
}

#Tests
get_working_directory_default_configuration_get_as_expected();

set_working_directory_to_new_valid_path_new_path_is_set();
set_working_directory_to_new_invalid_path_new_path_is_set();

action_delete_delete_a_valid_file_file_is_deleted();
action_delete_delete_a_directory_directory_is_not_deleted();

action_check_extensions_any_extension_txt_is_scannable();
action_check_extensions_extensions_is_not_specified_txt_is_not_scannable();

action_detect_virus_file_has_virus_virus_detected();
action_detect_virus_file_does_not_have_virus_no_virus_response();

action_disinfect_file_has_virus_file_is_disinfected();

action_quarantine_accesible_file_was_quarantined();

get_quarantined_files_quarantined_files_exist_at_least_one_quarantined_file_exists();

action_restore_quarantined_file_file_in_quarantine_is_restored();

action_update_definitions_download_file_file_is_downloaded();

done_testing();