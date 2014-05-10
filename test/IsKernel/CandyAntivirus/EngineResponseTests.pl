use warnings;
use strict;
use v5.14;

use Test::More;

use IsKernel::CandyAntivirus::EngineResponse;

use constant DEFAULT_RESPONSE => "this is a response";

my $engine_response = IsKernel::CandyAntivirus::EngineResponse->new(DEFAULT_RESPONSE, 1);

ok($engine_response->get_print_response() eq DEFAULT_RESPONSE, 
   "EngineResponse_GetPrintReponse_NewObject_PrintResponseInitialized");
ok($engine_response->get_log_response() =~  m/${\(DEFAULT_RESPONSE)}\s*/, 
   "EngineResponse_GetStatus_NewObject_LogResponseInitialized"); 
ok($engine_response->get_status() eq 1, 
   "EngineResponse_GetStatus_NewObject_StatusInitialized");
   
done_testing();