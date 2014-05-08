use warnings;
use strict;
use v5.14;

use File::Copy;
use File::Spec;
use Test::More;

use IsKernel::Infrastructure::FileHelper;
use IsKernel::Infrastructure::HexConverter;
use IsKernel::CandyAntivirus::VirusScanner;

use constant DEFAULT_VIRUS_DATABASE_FILE => "xvirsig.cfg";
use constant DEFAULT_VIRUS_FILE => "./ToScanFiles/file1.txt";

copy("./ToScanFiles/default_virus_file.txt","./ToScanFiles/file1.txt") or die "Copy failed: $!";

my $virusScanner = IsKernel::CandyAntivirus::VirusScanner->new(DEFAULT_VIRUS_DATABASE_FILE);
my $fileHelper = IsKernel::Infrastructure::FileHelper->new(DEFAULT_VIRUS_FILE);
my $content = $fileHelper->get_content_as_string();
(my $result, my $virusName) = $virusScanner->analyze_content($content);
ok($result == 1, "VirusScanner_AnalyzeHexDump_VirusContent_VirusFound");
ok($virusName eq "test_virus1", "VirusScanner_AnalyzeHexDump_VirusContent_VirusNameFound");

my $newContent = $virusScanner->disinfect_content($content);
(my $newResult, my $newVirusName) = $virusScanner->analyze_content($newContent);
ok($newResult == 0, "VirusScanner_DisinfectHexDump_VirusFile_VirusSignatureRemoved");

done_testing();