#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use Test::More;
use File::Basename;

use IsKernel::Infrastructure::FileHelper;
use IsKernel::Infrastructure::FileUtilities;

use constant TESTED_FILENAME => "file.txt";
use constant TESTED_DIRECTORY => "directory";
use constant TESTED_SYMLINK => "file";
use constant FILENAME_LENGTH => 30;

sub is_ordinary_file_ordinary_file_is_true
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	$file_helper->write_to_file("");
	my $file_utilities = IsKernel::Infrastructure::FileUtilities->new();
	ok($file_utilities->is_ordinary_file($file_helper->get_path()) == 1, "FileUtilities_IsOrdinaryFile_OrdinaryFile_IsTrue");		
	unlink $file_helper->get_path();
}

sub is_ordinary_file_directory_file_is_false
{
	mkdir(TESTED_DIRECTORY);
	my $file_utilities = IsKernel::Infrastructure::FileUtilities->new();
	ok($file_utilities->is_ordinary_file(TESTED_DIRECTORY) == 2, "FileUtilities_IsOrdinaryFile_Directory_IsFalse");
	rmdir(TESTED_DIRECTORY);
}

sub is_ordinary_file_symlink_file_is_false
{
	symlink(TESTED_FILENAME, TESTED_SYMLINK);
	my $file_utilities = IsKernel::Infrastructure::FileUtilities->new();
	ok($file_utilities->is_ordinary_file(TESTED_SYMLINK) == 2, "FileUtilities_IsOrdinaryFile_Symlink_IsFalse");
	unlink(TESTED_SYMLINK);
}

sub create_random_filename_specified_length_length_is_equal_to_specified_value
{
	my $file_utilities = IsKernel::Infrastructure::FileUtilities->new();
	my $path = $file_utilities->create_random_filename(FILENAME_LENGTH,".");
	my $file_name = basename($path);
	ok(length($file_name) == FILENAME_LENGTH, "FileUtilities_CreateRandomFilename_SpecifiedLength_LengthIsEqualToSpecifiedValue")
}

sub create_random_filename_filename_is_created_is_created
{
	my $file_utilities = IsKernel::Infrastructure::FileUtilities->new();
	my $path = $file_utilities->create_random_filename(FILENAME_LENGTH,".");
	my $file_helper = IsKernel::Infrastructure::FileHelper->new($path);
	$file_helper->write_to_file("");
	ok($file_utilities->is_ordinary_file($file_helper->get_path()) == 1, "FileUtilities_CreateRandomFilename_CreateFilename_FilenameIsValid");		
	unlink $file_helper->get_path();
}

is_ordinary_file_ordinary_file_is_true();
is_ordinary_file_directory_file_is_false();
is_ordinary_file_symlink_file_is_false();
create_random_filename_specified_length_length_is_equal_to_specified_value();
create_random_filename_filename_is_created_is_created();

done_testing();