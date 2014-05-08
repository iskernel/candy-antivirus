use warnings;
use strict;
use v5.14;

use Test::More;

use IsKernel::CandyAntivirus::EngineResponse;

use constant DEFAULT_RESPONSE => "this is a response";

my $engineResponse = IsKernel::CandyAntivirus::EngineResponse->new(DEFAULT_RESPONSE, 1);

ok($engineResponse->get_print_response() eq DEFAULT_RESPONSE, 
   "EngineResponse_GetPrintReponse_NewObject_PrintResponseInitialized");
ok($engineResponse->get_log_response() =~  m/${\(DEFAULT_RESPONSE)}\s*/, 
   "EngineResponse_GetStatus_NewObject_LogResponseInitialized"); 
ok($engineResponse->get_status() eq 1, 
   "EngineResponse_GetStatus_NewObject_StatusInitialized");
   
done_testing();