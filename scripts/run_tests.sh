#!/bin/bash

cd ..
default_dir=`pwd`

export PERL5LIB=$default_dir/lib

#Run infrastructure tests
cd test/IsKernel/Infrastructure
perl FileHelperTests.pl
perl HexConverterTests.pl 
perl StringHelperTests.pl 

#Run candy antivrus tests
cd $default_dir
cd test/IsKernel/CandyAntivirus
perl ConfigurationTests.pl
perl VirusScannerTests.pl 
perl EngineTests.pl
