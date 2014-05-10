#!/bin/bash

cd ..
default_dir=`pwd`

export PERL5LIB=$default_dir/lib

#Run infrastructure tests
cd test/IsKernel/Infrastructure
perl FileHelperTests.pl
perl FileUtilitiesTests.pl
perl HexConverterTests.pl 
perl StringHelperTests.pl 

#Run candy antivrus tests
cd $default_dir
cd test/IsKernel/CandyAntivirus
perl ConfigurationTests.pl
perl EngineResponseTests.pl
perl ScanResponseTests.pl
perl VirusScannerTests.pl 
perl EngineTests.pl
perl EventLoggerTests.pl
