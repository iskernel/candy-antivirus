#!/usr/bin/perl

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#Be careful if you plan to use this script on a Windows platform.
#The signatures for the viruses are real and are interpreted as a threat by the OS.
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

use strict;
use warnings;
use v5.14;

use IsKernel::Infrastructure::HexConverter;
use IsKernel::Infrastructure::FileHelper; 
use IsKernel::Infrastructure::StringHelper;

use Data::Dumper;

#Signatures for the viruses

#Comment these lines to use the script
use constant ABRAXAS_SIG => "";
use constant BADGUY265_SIG => "";
use constant RUSSIANMIRROR_SIG => "";
use constant SIMPLEX_SIG => "";
use constant TRIVIAL36_SIG => "";

#Uncomment these lines to use the script
#use constant ABRAXAS_SIG => "061fba0000b440cd21e87000b43ecd21c3be0801b200b447cd21c30e1fba4901b8023dcd21505bc3";
#use constant BADGUY265_SIG => "ba780190b90b1190b44ecd2190730390eb27ba9e0090b8023d90cd2190730390eb178bd890e83c00ba800090b44f90cd2190730390eb02ebd9b42acd213c0174";
#use constant RUSSIANMIRROR_SIG => "2ea3be015b53b9e201ba0000b440cd21b800425b53b90000ba0000cd21";
#use constant SIMPLEX_SIG => "e800005d81ed03001e06b8450bcd210bc074478cd8488ed8803e00005a753b832e030040832e1200408e0612000e1f8bf5b9090133fff3a533c08ed81ec50684";
#use constant TRIVIAL36_SIG => "b44eba2001b92400cd21ba9e00b8023dcd2193ba0001b440cd21b43ecd21";

#Paths for the virus files
use constant ABRAXAS_PATH => "abraxas.exe";
use constant BADGUY265_PATH => "badguy.txt";
use constant RUSSIANMIRROR_PATH => "russianmirror.exe";
use constant SIMPLEX_PATH => "simplex.txt";
use constant TRIVIAL36_PATH => "trivial.exe";
use constant MULTIV_PATH => "multi.exe";
#Paths for normal files
use constant FILE_1 => "file1.txt";
use constant FILE_2 => "file2.txt";
use constant FILE_3 => "file3.txt";
use constant FILE_4 => "file4.exe";
use constant FILE_5 => "file5.exe";

create_file_with_virus(ABRAXAS_PATH,100,ABRAXAS_SIG);
create_file_with_virus(BADGUY265_PATH,50, BADGUY265_SIG);
create_file_with_virus(RUSSIANMIRROR_PATH,40, RUSSIANMIRROR_SIG);
create_file_with_virus(SIMPLEX_PATH,80, SIMPLEX_SIG);
create_file_with_virus(TRIVIAL36_PATH,500, TRIVIAL36_SIG);
create_file_with_multiple_viruses(MULTIV_PATH, 800, ABRAXAS_SIG, BADGUY265_SIG, RUSSIANMIRROR_SIG);
create_ordinary_txt_file(FILE_1, 1000);
create_ordinary_txt_file(FILE_2, 2000);
create_ordinary_txt_file(FILE_3, 500);
create_ordinary_txt_file(FILE_4, 200);
create_ordinary_txt_file(FILE_5, 5000);

sub create_file_with_virus
{
	my $path = shift;
	my $random_length = shift;
	my $signature = shift;
	my $starter = "At the middle of Vienna, a swan shall fall.";
	my $stopper = "An wise man shall speak, but not before the others"; 
	my $hex_converter = IsKernel::Infrastructure::HexConverter->new();
	my $starter_hex = $hex_converter->ascii_to_hex_dump($starter);
	my $stopper_hex = $hex_converter->ascii_to_hex_dump($stopper);
	my $content = $hex_converter->hex_dump_to_ascii($starter_hex.$signature.$stopper_hex);
	my $file_manager = IsKernel::Infrastructure::FileHelper->new($path);
	$file_manager->write_to_file($content);
}

sub create_file_with_multiple_viruses
{
	my $path = shift;
	my $random_length = shift;
	my $index = 0;
	my @signatures = splice @_;
	my $string_generator = IsKernel::Infrastructure::StringHelper->new($random_length);
	my $hex_converter = IsKernel::Infrastructure::HexConverter->new();
	my $hex_dump ="";
	foreach my $sig (@signatures)
	{
		my $starter_string = $string_generator->generate_random();
		my $stopper_string = $string_generator->generate_random();
		my $started_hex = $hex_converter->ascii_to_hex_dump($starter_string);
		my $stopper_hex = $hex_converter->ascii_to_hex_dump($stopper_string);
		$hex_dump .= $started_hex.$sig.$stopper_hex; 
	}
	my $content = $hex_converter->ascii_to_hex_dump($hex_dump);
	my $file_manager = IsKernel::Infrastructure::FileHelper->new($path);
	$file_manager->write_to_file($content);
}

sub create_ordinary_txt_file
{
	my $path = shift;
	my $random_length = shift;
	my $string_generator = IsKernel::Infrastructure::StringHelper->new($random_length);
	my $content = $string_generator->generate_random();
	my $file_manager = IsKernel::Infrastructure::FileHelper->new($path);
	$file_manager->write_to_file($content);
}
