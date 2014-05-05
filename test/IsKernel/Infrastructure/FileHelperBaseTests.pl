use warnings;
use strict;
use v5.14;

use Test::More;

use IsKernel::CandyAntivirus::Infrastructure::FileHelperBase;

use constant TESTED_FILENAME => "file.txt";
use constant NEW_TESTED_FILENAME => "newfile.txt";

my $file_helper = IsKernel::CandyAntivirus::Infrastructure::FileHelperBase->new(TESTED_FILENAME);
ok($file_helper->get_path() eq TESTED_FILENAME, "FileHelperBase_GetPath_NewObject_PathIsRead");
$file_helper->set_path(NEW_TESTED_FILENAME);
ok($file_helper->get_path() eq NEW_TESTED_FILENAME, "FileHelperBase_SetPath_ReadObject_PathWasSet");

done_testing();