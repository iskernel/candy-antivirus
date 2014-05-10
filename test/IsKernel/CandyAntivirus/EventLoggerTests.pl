#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Copy;
use Test::More;

use IsKernel::CandyAntivirus::EventLogger;
use constant DEFAULT_LOG_FILE => "../../TestFiles/test_log.txt";

my $event_logger = IsKernel::CandyAntivirus::EventLogger->new(DEFAULT_LOG_FILE);
$event_logger->init_session();
ok(1, "EventLogger_InitSession_NormalConditions_DoesNotCrash");
$event_logger->close_session();
ok(1, "EventLogger_CloseSession_NormalConditions_DoesNotCrash");

done_testing();
