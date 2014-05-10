use warnings;
use strict;
use v5.14;

use File::Copy;
use File::Spec;
use Test::More;

use IsKernel::Infrastructure::FileHelper;
use IsKernel::Infrastructure::HexConverter;
use IsKernel::CandyAntivirus::VirusScanner;

use constant DEFAULT_VIRUS_DATABASE_FILE => "../../TestFiles/test_xvirsig.cfg";
use constant DEFAULT_VIRUS_FILE => "../../TestFiles/ToScanFiles/file1.txt";

copy("../../TestFiles/ToScanFiles/default_virus_file.txt","../../TestFiles/ToScanFiles/file1.txt") 
or die "Copy failed: $!";

my $virus_scanner = IsKernel::CandyAntivirus::VirusScanner->new(DEFAULT_VIRUS_DATABASE_FILE);
my $file_helper = IsKernel::Infrastructure::FileHelper->new(DEFAULT_VIRUS_FILE);
my $content = $file_helper->get_content_as_string();
my $response = $virus_scanner->scan($content);
ok($response->has_virus() == 1, "VirusScanner_AnalyzeHexDump_VirusContent_VirusFound");
ok($response->virus_name() eq "test_virus1", "VirusScanner_AnalyzeHexDump_VirusContent_VirusNameFound");

my $new_content = $virus_scanner->remove_signatures($content);
my $new_response  = $virus_scanner->scan($new_content);
ok($new_response->has_virus() == 0, "VirusScanner_DisinfectHexDump_VirusFile_VirusSignatureRemoved");

done_testing();