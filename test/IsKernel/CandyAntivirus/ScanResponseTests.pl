use warnings;
use strict;
use v5.14;

use Test::More;

use IsKernel::CandyAntivirus::ScanResponse;

use constant DEFAULT_RESPONSE => "virus_name";

my $scan_response = IsKernel::CandyAntivirus::ScanResponse->new(1, DEFAULT_RESPONSE);

ok($scan_response->virus_name eq DEFAULT_RESPONSE, "ScanResponse_GetVirusName_NewObject_ExpectedVirusName"); 
ok($scan_response->has_virus() eq 1, "ScanResponse_HasVirus_NewObject_VirusDetected");
   
done_testing();