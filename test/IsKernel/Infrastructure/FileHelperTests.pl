#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use Test::More;

use IsKernel::Infrastructure::FileHelper;

use constant TESTED_FILENAME => "file.txt";
use constant NEW_TESTED_FILENAME => "newfile.txt";

sub get_path_new_object_path_is_read
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	ok($file_helper->get_path() eq TESTED_FILENAME, "FileHelper_GetPath_NewObject_PathIsRead");		
	unlink $file_helper->get_path();
}

sub set_path_new_object_path_is_read
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	$file_helper->set_path(NEW_TESTED_FILENAME);
	ok($file_helper->get_path() eq NEW_TESTED_FILENAME, "FileHelper_SetPath_ReadObject_PathWasSet");
	unlink $file_helper->get_path();
}

sub append_to_file_existing_content_new_content_is_added
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	open(my $handle, ">", $file_helper->get_path()) or die("Could not append message to file");
	print $handle "hello world";
	close($handle);
	$file_helper->append_to_file("\ncontent");	
	$file_helper->get_content_as_string();
	ok($file_helper->get_content_as_string() eq "hello world\ncontent", "FileHelper_AppendToFile_ExistingContent_NewContentIsAdded");
	unlink $file_helper->get_path();
}

sub append_to_file_no_content_content_is_appended_file_is_created
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	$file_helper->append_to_file("\ncontent");	
	ok($file_helper->get_content_as_string() eq "\ncontent", "FileHelper_AppendToFile_FileDoesNotExist_FileIsCreatedContentCreated");
	unlink $file_helper->get_path();
}

sub get_content_as_array_new_object_content_is_read
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	open(my $handle, ">", $file_helper->get_path()) or die("Could not append message to file");
	print $handle "\ncontent";	
	close($handle);
	my @lines = $file_helper->get_content_as_array();
	ok($lines[1] eq "content", "FileHelper_GetContentAsArray_NewFileWithContent_SecondLineIsCorrect");
	unlink $file_helper->get_path();
}

sub get_content_as_string_new_object_content_is_read
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	open(my $handle, ">", $file_helper->get_path()) or die("Could not append message to file");
	print $handle "\ncontent";		
	close($handle);
	ok($file_helper->get_content_as_string() eq "\ncontent", "FileHelper_GetContentAsString_NewFileWithContent_ContentIsRead");
	unlink $file_helper->get_path();
}

sub write_to_file_new_object_with_content_content_is_replaced
{
	my $file_helper = IsKernel::Infrastructure::FileHelper->new(TESTED_FILENAME);
	open(my $handle, ">", $file_helper->get_path()) or die("Could not append message to file");
	print $handle "\ncontent";		
	close($handle);
	$file_helper->write_to_file("hello world");
	ok($file_helper->get_content_as_string() eq "hello world", "FileHelper_GetContentAsString_NewFileWithContent_ContentIsRead");
	unlink $file_helper->get_path();
}

get_path_new_object_path_is_read();
set_path_new_object_path_is_read();
append_to_file_existing_content_new_content_is_added();
append_to_file_no_content_content_is_appended_file_is_created();
get_content_as_array_new_object_content_is_read();
get_content_as_string_new_object_content_is_read();
write_to_file_new_object_with_content_content_is_replaced();

done_testing();