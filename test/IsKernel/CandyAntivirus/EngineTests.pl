#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Copy;
use Test::More;

use IsKernel::CandyAntivirus::Configuration;
use IsKernel::CandyAntivirus::Engine;

use constant DEFAULT_DIRECTORY => "./ToScanFiles";

copy("default_test_config.cfg","test_config.cfg") or die "Copy failed: $!";

my $configuration = IsKernel::CandyAntivirus::Configuration->new("test_config.cfg");
my $engine = IsKernel::CandyAntivirus::Engine->new($configuration, DEFAULT_DIRECTORY);

done_testing();