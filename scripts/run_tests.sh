#!/bin/bash

cd ..
default_dir=`pwd`

export PERL5LIB=$default_dir/lib

#Run infrastructure tests
cd test/IsKernel/Infrastructure
perl FileHelperTests.pl
perl HexConverterTests.pl 
perl StringHelperTests.pl 

cd $default_dir